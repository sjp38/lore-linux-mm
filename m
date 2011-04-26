Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 27762900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 03:41:07 -0400 (EDT)
Received: by vws4 with SMTP id 4so431327vws.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 00:41:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426063421.GC19717@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
	<20110426055521.GA18473@localhost>
	<BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
	<BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
	<20110426062535.GB19717@localhost>
	<BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
	<20110426063421.GC19717@localhost>
Date: Tue, 26 Apr 2011 16:41:04 +0900
Message-ID: <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
Subject: Re: readahead and oom
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>

Hi Wu,

On Tue, Apr 26, 2011 at 3:34 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Tue, Apr 26, 2011 at 02:29:15PM +0800, Dave Young wrote:
>> On Tue, Apr 26, 2011 at 2:25 PM, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
>> > On Tue, Apr 26, 2011 at 02:07:17PM +0800, Dave Young wrote:
>> >> On Tue, Apr 26, 2011 at 2:05 PM, Dave Young <hidave.darkstar@gmail.co=
m> wrote:
>> >> > On Tue, Apr 26, 2011 at 1:55 PM, Wu Fengguang <fengguang.wu@intel.c=
om> wrote:
>> >> >> On Tue, Apr 26, 2011 at 01:49:25PM +0800, Dave Young wrote:
>> >> >>> Hi,
>> >> >>>
>> >> >>> When memory pressure is high, readahead could cause oom killing.
>> >> >>> IMHO we should stop readaheading under such circumstances=E3=80=
=82If it's true
>> >> >>> how to fix it?
>> >> >>
>> >> >> Good question. Before OOM there will be readahead thrashings, whic=
h
>> >> >> can be addressed by this patch:
>> >> >>
>> >> >> http://lkml.org/lkml/2010/2/2/229
>> >> >
>> >> > Hi, I'm not clear about the patch, could be regard as below cases?
>> >> > 1) readahead alloc fail due to low memory such as other large alloc=
ation
>> >>
>> >> For example vm balloon allocate lots of memory, then readahead could
>> >> fail immediately and then oom
>> >
>> > If true, that would be the problem of vm balloon. It's not good to
>> > consume lots of memory all of a sudden, which will likely impact lots
>> > of kernel subsystems.
>> >
>> > btw readahead page allocations are completely optional. They are OK to
>> > fail and in theory shall not trigger OOM on themselves. We may
>> > consider passing __GFP_NORETRY for readahead page allocations.
>>
>> Good idea, care to submit a patch?
>
> Here it is :)
>
> Thanks,
> Fengguang
> ---
> readahead: readahead page allocations is OK to fail
>
> Pass __GFP_NORETRY for readahead page allocations.
>
> readahead page allocations are completely optional. They are OK to
> fail and in particular shall not trigger OOM on themselves.
>
> Reported-by: Dave Young <hidave.darkstar@gmail.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =C2=A0include/linux/pagemap.h | =C2=A0 =C2=A05 +++++
> =C2=A0mm/readahead.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +=
-
> =C2=A02 files changed, 6 insertions(+), 1 deletion(-)
>
> --- linux-next.orig/include/linux/pagemap.h =C2=A0 =C2=A0 2011-04-26 14:2=
7:46.000000000 +0800
> +++ linux-next/include/linux/pagemap.h =C2=A02011-04-26 14:29:31.00000000=
0 +0800
> @@ -219,6 +219,11 @@ static inline struct page *page_cache_al
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return __page_cache_alloc(mapping_gfp_mask(x)|=
__GFP_COLD);
> =C2=A0}
>
> +static inline struct page *page_cache_alloc_cold_noretry(struct address_=
space *x)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return __page_cache_alloc(mapping_gfp_mask(x)|__GF=
P_COLD|__GFP_NORETRY);

It makes sense to me but it could make a noise about page allocation
failure. I think it's not desirable.
How about adding __GFP_NOWARAN?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
