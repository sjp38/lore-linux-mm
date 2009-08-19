Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4E6556B005A
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 07:08:02 -0400 (EDT)
Received: by yxe14 with SMTP id 14so5587369yxe.12
        for <linux-mm@kvack.org>; Wed, 19 Aug 2009 04:08:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090819105829.GH24809@csn.ul.ie>
References: <18eba5a10908181841t145e4db1wc2daf90f7337aa6e@mail.gmail.com>
	 <20090819114408.ab9c8a78.minchan.kim@barrios-desktop>
	 <4A8B7508.4040001@vflare.org>
	 <20090819135105.e6b69a8d.minchan.kim@barrios-desktop>
	 <18eba5a10908182324x45261d06y83e0f042e9ee6b20@mail.gmail.com>
	 <20090819154958.18a34aa5.minchan.kim@barrios-desktop>
	 <20090819103611.GG24809@csn.ul.ie>
	 <20090819195242.4454a35f.minchan.kim@barrios-desktop>
	 <20090819105829.GH24809@csn.ul.ie>
Date: Wed, 19 Aug 2009 20:01:12 +0900
Message-ID: <28c262360908190401y217cf9d0wd502fdfb53cfe174@mail.gmail.com>
Subject: Re: abnormal OOM killer message
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: ????????? <chungki.woo@gmail.com>, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, riel@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 7:58 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> On Wed, Aug 19, 2009 at 07:52:42PM +0900, Minchan Kim wrote:
>> Thanks for good comment, Mel.
>>
>> On Wed, 19 Aug 2009 11:36:11 +0100
>> Mel Gorman <mel@csn.ul.ie> wrote:
>>
>> > On Wed, Aug 19, 2009 at 03:49:58PM +0900, Minchan Kim wrote:
>> > > On Wed, 19 Aug 2009 15:24:54 +0900
>> > > ????????? <chungki.woo@gmail.com> wrote:
>> > >
>> > > > Thank you very much for replys.
>> > > >
>> > > > But I think it seems not to relate with stale data problem in comp=
cache.
>> > > > My question was why last chance to allocate memory was failed.
>> > > > When OOM killer is executed, memory state is not a condition to
>> > > > execute OOM killer.
>> > > > Specially, there are so many pages of order 0. And allocating orde=
r is zero.
>> > > > I think that last allocating memory should have succeeded.
>> > > > That's my worry.
>> > >
>> > > Yes. I agree with you.
>> > > Mel. Could you give some comment in this situation ?
>> > > Is it possible that order 0 allocation is failed
>> > > even there are many pages in buddy ?
>> > >
>> >
>> > Not ordinarily. If it happens, I tend to suspect that the free list da=
ta
>> > is corrupted and would put a check in __rmqueue() that looked like
>> >
>> > =C2=A0 =C2=A0 BUG_ON(list_empty(&area->free_list) && area->nr_free);
>>
>> If memory is corrupt, it would be not satisfied with both condition.
>> It would be better to ORed condition.
>>
>> BUG_ON(list_empty(&area->free_list) || area->nr_free);
>>
>
> But it's perfectly reasonable to have nr_free a positive value. The
> point of the check is ensure the counters make sense. If nr_free > 0 and
> the list is empty, it means accounting is all messed up and the values
> reported for "free" in the OOM message are fiction.

Huh. My mistake.

I confused it with !area->nr_free.
Sorry for confusing you.

Thanks again.



>
>> > The second question is, why are we in direct reclaim this far above th=
e
>> > watermark? It should only be kswapd that is doing any reclaim at that
>> > point. That makes me wonder again are the free lists corrupted.
>>
>> It does make sense!
>>
>> > The other possibility is that the zonelist used for allocation in the
>> > troubled path contains no populated zones. I would put a BUG_ON check =
in
>> > get_page_from_freelist() to check if the first zone in the zonelist ha=
s no
>> > pages. If that bug triggers, it might explain why OOMs are triggering =
for
>> > no good reason.
>>
>> Yes. Chungki. Could you put the both BUG_ON in each function and
>> try to reproduce the problem ?
>>
>> > I consider both of those possibilities abnormal though.
>> >
>> > > >
>> > > > ------------------------------------------------------------------=
---------------------------------------------------------------------------=
--
>> > > > =C2=A0 =C2=A0 =C2=A0 page =3D get_page_from_freelist(gfp_mask|__GF=
P_HARDWALL, order,
>> > > > <=3D=3D this is last chance
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
>> > > > <=3D=3D uses ALLOC_WMARK_HIGH
>> > > > =C2=A0 =C2=A0 =C2=A0 if (page)
>> > > > =C2=A0 =C2=A0 =C2=A0 goto got_pg;
>> > > >
>> > > > =C2=A0 =C2=A0 =C2=A0 out_of_memory(zonelist, gfp_mask, order);
>> > > > =C2=A0 =C2=A0 =C2=A0 goto restart;
>> > > > ------------------------------------------------------------------=
---------------------------------------------------------------------------=
--
>> > > >
>> > > > > Let me have a question.
>> > > > > Now the system has 79M as total swap.
>> > > > > It's bigger than system memory size.
>> > > > > Is it possible in compcache?
>> > > > > Can we believe the number?
>> > > >
>> > > > Yeah, It's possible. 79Mbyte is data size can be swap.
>> > > > It's not compressed data size. It's just original data size.
>> > >
>> > > You means your pages with 79M are swap out in compcache's reserved
>> > > memory?
>> > >
>> >
>> > --
>> > Mel Gorman
>> > Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
>> > University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>>
>>
>> --
>> Kind regards,
>> Minchan Kim
>>
>
> --
> Mel Gorman
> Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
> University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
