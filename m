Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A471830A3
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 13:19:44 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so40626516pac.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:19:44 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id wf7si3356675pac.96.2016.08.18.10.19.42
        for <linux-mm@kvack.org>;
        Thu, 18 Aug 2016 10:19:43 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
	<20160817005905.GA5372@bbox>
	<87inv0kv3r.fsf@yhuang-mobile.sh.intel.com>
	<20160817050743.GB5372@bbox>
	<1471454696.2888.94.camel@linux.intel.com>
	<20160818083955.GA12296@bbox>
Date: Thu, 18 Aug 2016 10:19:32 -0700
In-Reply-To: <20160818083955.GA12296@bbox> (Minchan Kim's message of "Thu, 18
	Aug 2016 17:39:55 +0900")
Message-ID: <8760qyq9jv.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Minchan Kim <minchan@kernel.org> writes:

> Hi Tim,
>
> On Wed, Aug 17, 2016 at 10:24:56AM -0700, Tim Chen wrote:
>> On Wed, 2016-08-17 at 14:07 +0900, Minchan Kim wrote:
>> > On Tue, Aug 16, 2016 at 07:06:00PM -0700, Huang, Ying wrote:
>> > >=20
>> > >
>> > > >=20
>> > > > I think Tim and me discussed about that a few weeks ago.
>> > > I work closely with Tim on swap optimization.=A0This patchset is the=
 part
>> > > of our swap optimization plan.
>> > >=20
>> > > >=20
>> > > > Please search below topics.
>> > > >=20
>> > > > [1] mm: Batch page reclamation under shink_page_list
>> > > > [2] mm: Cleanup - Reorganize the shrink_page_list code into smalle=
r functions
>> > > >=20
>> > > > It's different with yours which focused on THP swapping while the =
suggestion
>> > > > would be more general if we can do so it's worth to try it, I thin=
k.
>> > > I think the general optimization above will benefit both normal pages
>> > > and THP at least for now.=A0And I think there are no hard conflict
>> > > between those two patchsets.
>> > If we could do general optimzation, I guess THP swap without splitting
>> > would be more straight forward.
>> >=20
>> > If we can reclaim batch a certain of pages all at once, it helps we can
>> > do scan_swap_map(si, SWAP_HAS_CACHE, nr_pages). The nr_pages could be
>> > greater or less than 512 pages. With that, scan_swap_map effectively
>> > search empty swap slots from scan_map or free cluser list.
>> > Then, needed part from your patchset is to just delay splitting of THP.
>> >=20
>> > >=20
>> > >=20
>> > > The THP swap has more opportunity to be optimized, because we can ba=
tch
>> > > 512 operations together more easily.=A0For full THP swap support, un=
map a
>> > > THP could be more efficient with only one swap count operation inste=
ad
>> > > of 512, so do many other operations, such as add/remove from swap ca=
che
>> > > with multi-order radix tree etc.=A0And it will help memory fragmenta=
tion.
>> > > THP can be kept after swapping out/in, need not to rebuild THP via
>> > > khugepaged.
>> > It seems you increased cluster size to 512 and search a empty cluster
>> > for a THP swap. With that approach, I have a concern that once clusters
>> > will be fragmented, THP swap support doesn't take benefit at all.
>> >=20
>> > Why do we need a empty cluster for swapping out 512 pages?
>> > IOW, below case could work for the goal.
>> >=20
>> > A : Allocated slot
>> > F : Free slot
>> >=20
>> > cluster A=A0cluster B
>> > AAAAFFFF=A0-=A0FFFFAAAA
>> >=20
>> > That's one of the reason I suggested batch reclaim work first and
>> > support THP swap based on it. With that, scan_swap_map can be aware of=
 nr_pages
>> > and selects right clusters.
>> >=20
>> > With the approach, justfication of THP swap support would be easier, t=
oo.
>> > IOW, I'm not sure how only THP swap support is valuable in real worklo=
ad.
>> >=20
>> > Anyways, that's just my two cents.
>>=20
>> Minchan,
>>=20
>> Scanning for contiguous slots that span clusters may take quite a
>> long time under fragmentation, and may eventually fail. In that case the=
 addition scan
>> time overhead may go to waste and defeat the purpose of fast swapping of=
 large page.
>>=20
>> The empty cluster lookup on the other hand is very fast.
>> We treat the empty cluster available case as an opportunity for fast path
>> swap out of large page. Otherwise, we'll revert to the current
>> slow path behavior of breaking into normal pages so there's no
>> regression, and we may get speed up. We can be considerably faster when =
a lot of large
>> pages are used.=20
>
> I didn't mean we should search scan_swap_map firstly without peeking
> free cluster but what I wanted was we might abstract it into
> scan_swap_map.
>
> For example, if nr_pages is greather than the size of cluster, we can
> get empty cluster first and nr_pages - sizeof(cluster) for other free
> cluster or scanning of current CPU per-cpu cluster. If we cannot find
> used slot during scanning, we can bail out simply. Then, although we
> fail to get all* contiguous slots, we get a certain of contiguous slots
> so it would be benefit for seq write and lock batching point of view
> at the cost of a little scanning. And it's not specific to THP algorighm.

Firstly, if my understanding were correct, to batch the normal pages
swapping out, the swap slots need not to be continuous.  But for the THP
swap support, we need the continuous swap slots.  So I think the
requirements are quite different between them.

And with the current design of the swap space management, it is quite
hard to implement allocating nr_pages continuous free swap slots.  To
reduce the contention of sis->lock, even to scan one free swap slot, the
sis->lock is unlocked during scanning.  When we scan nr_pages free swap
slots, and there are no nr_pages continuous free swap slots, we need to
scan from sis->lowest_bit to sis->highest_bit, and record the largest
continuous free swap slots.  But when we lock sis->lock again to check,
some swap slot inside the largest continuous free swap slots we found
may be allocated by other processes.  So we may end up with a much
smaller number of swap slots or we need to startover again.  So I think
the simpler solution is to

- When a whole cluster is requested (for the THP), try to allocate a
  free cluster.  Give up if there are no free clusters.

- When a small number of swap slots are requested (for normal swap
  batching), check only sis->percpu_cluster and return next N free swap
  slots in it.  Because we only scan very small number of swap slots, we
  can do that with sis->lock held.

BTW: The sis->lock is under heavy contention after the lock contention of
swap cache radix tree lock is reduced via batching in 8 processes
sequential swapping out test.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
