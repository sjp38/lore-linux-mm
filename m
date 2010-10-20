Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D79986B00F2
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 06:07:16 -0400 (EDT)
Received: by gwj21 with SMTP id 21so2056333gwj.14
        for <linux-mm@kvack.org>; Wed, 20 Oct 2010 03:07:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101020090124.GA27531@localhost>
References: <20100915122334.3fa7b35f@notabene>
	<20100915082843.GA17252@localhost>
	<20100915184434.18e2d933@notabene>
	<20101018151459.2b443221@notabene>
	<AANLkTimv_zXHdFDGa9ecgXyWmQynOKTDRPC59PZA9mvL@mail.gmail.com>
	<20101019101151.57c6dd56@notabene>
	<AANLkTin3wXWwA-HXhjx6wvzznp3p57Pg6fee8YNkZB79@mail.gmail.com>
	<AANLkTimVu+5gTDs8przJVP2EbWC=FX-zWW7aH08BtrHC@mail.gmail.com>
	<20101020055717.GA12752@localhost>
	<AANLkTinC=xcgfwgXw8Tr-Q_cnxZakjj_W=HwQRV+5vkd@mail.gmail.com>
	<20101020090124.GA27531@localhost>
Date: Wed, 20 Oct 2010 12:07:11 +0200
Message-ID: <AANLkTikwLp=PQ+fNTK9GqM9U5oDeriaSdkWCDfUp0a4R@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Torsten Kaiser <just.for.lkml@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 20, 2010 at 11:01 AM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Wed, Oct 20, 2010 at 03:25:49PM +0800, Torsten Kaiser wrote:
>> On Wed, Oct 20, 2010 at 7:57 AM, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
>> > On Tue, Oct 19, 2010 at 06:06:21PM +0800, Torsten Kaiser wrote:
>> >> swap_writepage() uses get_swap_bio() which uses bio_alloc() to get on=
e
>> >> bio. That bio is the submitted, but the submit path seems to get into
>> >> make_request from raid1.c and that allocates a second bio from
>> >> bio_alloc() via bio_clone().
>> >>
>> >> I am seeing this pattern (swap_writepage calling
>> >> md_make_request/make_request and then getting stuck in mempool_alloc)
>> >> more than 5 times in the SysRq+T output...
>> >
>> > I bet the root cause is the failure of pool->alloc(__GFP_NORETRY)
>> > inside mempool_alloc(), which can be fixed by this patch.
>>
>> No. I tested the patch (ontop of Neils fix and your patch regarding
>> too_many_isolated()), but the system got stuck the same way on the
>> first try to fill the tmpfs.
>> I think the basic problem is, that the mempool that should guarantee
>> progress is exhausted because the raid1 device is stacked between the
>> pageout code and the disks and so the "use only 1 bio"-rule gets
>> violated.
>
> The mempool get exhausted because pool->alloc() failed at least 2
> times. But there are no such high memory pressure except for some
> parallel reclaimers. It seems the below patch does not completely
> stop the page allocation failure, hence does not stop the deadlock.
>
> As you and KOSAKI said, the root cause is BIO_POOL_SIZE being smaller
> than the total possible allocations in the IO stack. Then why not
> bumping up BIO_POOL_SIZE to something like 64? It will be large enough
> to allow multiple stacked IO layers.
>
> And the larger value will allow more concurrent flying IOs for better
> IO throughput in such situation. Commit 5972511b7 lowers it from 256
> to 2 because it believes that pool->alloc() will only fail on somehow
> OOM situation. However truth is __GFP_NORETRY allocations fail much
> more easily in _normal_ operations (whenever there are multiple
> concurrent page reclaimers). We have to be able to perform better in
> such situation. =A0The __GFP_NORETRY patch to reduce failures is one
> option, increasing BIO_POOL_SIZE is another.
>
> So would you try this fix?

While it seems to fix the hang (Just vanilla -rc8, even without the
fix from Neil to raid1.c, did not hang during multiple runs of my
testscript), I believe this is not a fix for the problem.

To quote comment above bio_alloc() from fs/bio.c:
 *      If %__GFP_WAIT is set, then bio_alloc will always be able to alloca=
te
 *      a bio. This is due to the mempool guarantees. To make this work, ca=
llers
 *      must never allocate more than 1 bio at a time from this pool. Calle=
rs
 *      that need to allocate more than 1 bio must always submit the previo=
usly
 *      allocated bio for IO before attempting to allocate a new one. Failu=
re to
 *      do so can cause livelocks under memory pressure.

So it seems that limiting fs_bio_set to only 2 entries was intended.
And the commit comment from the change that reduced this from 256 to 2
even said that this pool is only intended as a last resort to sustain
progress.

And I think in my testcase the important thing is not good
performance, but only to make sure the system does not hang.
Both of the situations that cause the hang for me where more cases of
"what not to do" then anything that should perform good. In the
original case the system started too many gcc's because I'm to lazy to
figure out a better way to organize the parallelization of independent
singlethreaded compiles and parallel makes. The Gentoo package manager
tries to use the load average to that point, but this is foiled if a
compile first has a singlethreaded part (like configure) and only
later switches to parallel compiles. So portage started 4 package
compilations, because during configure the load was low and then the
system had to deal with 20 gcc's (make -j5) eating all of its memory.
And even that seemed to only happen during one part of the compiles,
as in the not hanging cases, the swapping soon stopped. So it would
just have to survive the initial overallocation with the small mempool
and everything is find.
My reduced testcase is even more useless as an example for a real
load: I'm just using multiple dd's to fill a tmpfs as fast as I can to
see if raid1.c::make_request() breaks under memory pressure. And here
too the only goal should be that the kernel should survive this abuse.

Sorry, but increasing BIO_POOL_SIZE just looks like papering over the
real problem...


Torsten

> --- linux-next.orig/include/linux/bio.h 2010-10-20 16:55:57.000000000 +08=
00
> +++ linux-next/include/linux/bio.h =A0 =A0 =A02010-10-20 16:56:54.0000000=
00 +0800
> @@ -286,7 +286,7 @@ static inline void bio_set_completion_cp
> =A0* These memory pools in turn all allocate from the bio_slab
> =A0* and the bvec_slabs[].
> =A0*/
> -#define BIO_POOL_SIZE 2
> +#define BIO_POOL_SIZE =A064
> =A0#define BIOVEC_NR_POOLS 6
> =A0#define BIOVEC_MAX_IDX (BIOVEC_NR_POOLS - 1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
