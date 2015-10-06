Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 379A66B02E8
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 01:36:34 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so58967530pad.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 22:36:34 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id ck5si46084686pbb.91.2015.10.05.22.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 22:36:33 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: New helper to free highmem pages in larger chunks
Date: Tue, 6 Oct 2015 05:35:57 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D781AB03@IN01WEMBXB.internal.synopsys.com>
References: <560FD031.3030909@synopsys.com>
 <20151005150955.3e1da261449ae046e1be3989@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>, Robin Holt <robin.m.holt@gmail.com>, Nathan Zimmer <nzimmer@sgi.com>, Jiang Liu <liuj97@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On Tuesday 06 October 2015 03:40 AM, Andrew Morton wrote:=0A=
> On Sat, 3 Oct 2015 18:25:13 +0530 Vineet Gupta <Vineet.Gupta1@synopsys.co=
m> wrote:=0A=
>=0A=
>> Hi,=0A=
>>=0A=
>> I noticed increased boot time when enabling highmem for ARC. Turns out t=
hat=0A=
>> freeing highmem pages into buddy allocator is done page at a time, while=
 it is=0A=
>> batched for low mem pages. Below is call flow.=0A=
>>=0A=
>> I'm thinking of writing free_highmem_pages() which takes start and end p=
fn and=0A=
>> want to solicit some ideas whether to write it from scratch or preferabl=
y call=0A=
>> existing __free_pages_memory() to reuse the logic to convert a pfn range=
 into=0A=
>> {pfn, order} tuples.=0A=
>>=0A=
>> For latter however there are semantical differences as you can see below=
 which I'm=0A=
>> not sure of:=0A=
>>   -highmem page->count is set to 1, while 0 for low mem=0A=
> That would be weird.=0A=
>=0A=
> Look more closely at __free_pages_boot_core() - it uses=0A=
> set_page_refcounted() to set the page's refcount to 1.  Those=0A=
> set_page_count() calls look superfluous to me.=0A=
=0A=
If you closer still, set_page_refcounted() is called outside the loop for t=
he=0A=
first page only. For all pages, loop iterator sets them to 1. Turns out the=
re's=0A=
more fun here....=0A=
=0A=
I ran this under a debugger and much earlier in boot process, there's exist=
ing=0A=
setting of page count to 1 for *all* pages of *all* zones (include highmem =
pages).=0A=
See call flow below.=0A=
=0A=
free_area_init_node=0A=
    free_area_init_core=0A=
        loops thru all zones=0A=
            memmap_init_zone=0A=
               loops thru all pages of zones=0A=
               __init_single_page=0A=
=0A=
This means the subsequent setting of page count to 0 (or 1 for the special =
first=0A=
page) is superfluous - actually buggy at best. I will send a patch to fix t=
hat. I=0A=
hope I don't break some obscure init path which doesn't hit the above init.=
=0A=
=0A=
=0A=
>=0A=
>>   -atomic clearing of page reserved flag vs. non atomic=0A=
> I doubt if the atomic is needed - who else can be looking at this page=0A=
> at this time?=0A=
=0A=
I'll send another one to separately fix that as well. Seems like boot mem s=
etup is=0A=
a relatively neglect part of kernel.=0A=
=0A=
-Vineet=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
