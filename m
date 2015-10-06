Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6EF6B0299
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 04:42:39 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so203249767pab.3
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 01:42:39 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id cj4si47217169pbc.126.2015.10.06.01.42.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 01:42:38 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [arc-linux-dev] Re: New helper to free highmem pages in larger
 chunks
Date: Tue, 6 Oct 2015 08:42:32 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D781AB9A@IN01WEMBXB.internal.synopsys.com>
References: <560FD031.3030909@synopsys.com>
 <20151005150955.3e1da261449ae046e1be3989@linux-foundation.org>
 <C2D7FE5348E1B147BCA15975FBA23075D781AB03@IN01WEMBXB.internal.synopsys.com>
Reply-To: "arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>, Robin Holt <robin.m.holt@gmail.com>, Nathan Zimmer <nzimmer@sgi.com>, Jiang Liu <liuj97@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On Tuesday 06 October 2015 11:06 AM, Vineet Gupta wrote:=0A=
> On Tuesday 06 October 2015 03:40 AM, Andrew Morton wrote:=0A=
>> On Sat, 3 Oct 2015 18:25:13 +0530 Vineet Gupta <Vineet.Gupta1@synopsys.c=
om> wrote:=0A=
>>=0A=
>>> Hi,=0A=
>>>=0A=
>>> I noticed increased boot time when enabling highmem for ARC. Turns out =
that=0A=
>>> freeing highmem pages into buddy allocator is done page at a time, whil=
e it is=0A=
>>> batched for low mem pages. Below is call flow.=0A=
>>>=0A=
>>> I'm thinking of writing free_highmem_pages() which takes start and end =
pfn and=0A=
>>> want to solicit some ideas whether to write it from scratch or preferab=
ly call=0A=
>>> existing __free_pages_memory() to reuse the logic to convert a pfn rang=
e into=0A=
>>> {pfn, order} tuples.=0A=
>>>=0A=
>>> For latter however there are semantical differences as you can see belo=
w which I'm=0A=
>>> not sure of:=0A=
>>>   -highmem page->count is set to 1, while 0 for low mem=0A=
>> That would be weird.=0A=
>>=0A=
>> Look more closely at __free_pages_boot_core() - it uses=0A=
>> set_page_refcounted() to set the page's refcount to 1.  Those=0A=
>> set_page_count() calls look superfluous to me.=0A=
> If you closer still, set_page_refcounted() is called outside the loop for=
 the=0A=
> first page only. For all pages, loop iterator sets them to 1. Turns out t=
here's=0A=
> more fun here....=0A=
>=0A=
> I ran this under a debugger and much earlier in boot process, there's exi=
sting=0A=
> setting of page count to 1 for *all* pages of *all* zones (include highme=
m pages).=0A=
> See call flow below.=0A=
>=0A=
> free_area_init_node=0A=
>     free_area_init_core=0A=
>         loops thru all zones=0A=
>             memmap_init_zone=0A=
>                loops thru all pages of zones=0A=
>                __init_single_page=0A=
>=0A=
> This means the subsequent setting of page count to 0 (or 1 for the specia=
l first=0A=
> page) is superfluous - actually buggy at best. I will send a patch to fix=
 that. I=0A=
> hope I don't break some obscure init path which doesn't hit the above ini=
t.=0A=
=0A=
So I took a stab at it and broke it royally. I was too naive for this to be=
gin=0A=
with. The explicit setting to 1 for high mem pages, 0 for all low mem pages=
 except=0A=
1st page in @order which has 1 is all by design.=0A=
=0A=
__free_pages() called by both code paths,  always decrements the refcount o=
f=0A=
struct page. In case of page batch (order !=3D0) it only decrements the fir=
st page's=0A=
refcount. This was my find of the month - but you probably have known this =
for=0A=
longest amount of time ! Live and learn.=0A=
=0A=
The current High mem page only uses order =3D=3D 0, so init ref count of 1 =
is needed=0A=
(although done from __init_single_page is sufficient - no need to do that a=
gain in=0A=
free_highmem_page()). The low mem pages though typically call free_pages() =
with=0A=
order > 0, thus the caller carefully setsup the first page in @order to ref=
count 1=0A=
(using set_page_refcounted()), while rest of pages are set to 0 refcount in=
 the loop.=0A=
=0A=
Thus the seeming redundant setting of 0 seems to be fine IMHO - perhaps bet=
ter to=0A=
document it - assuming I got it right so far.=0A=
=0A=
=0A=
>>>   -atomic clearing of page reserved flag vs. non atomic=0A=
>> I doubt if the atomic is needed - who else can be looking at this page=
=0A=
>> at this time?=0A=
> I'll send another one to separately fix that as well. Seems like boot mem=
 setup is=0A=
> a relatively neglect part of kernel.=0A=
>=0A=
> -Vineet=0A=
>=0A=
>=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
