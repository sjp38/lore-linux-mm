Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id EB2E56B0068
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 21:23:29 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so3689523ied.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 18:23:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121101005052.GB26256@bbox>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <20121031143524.0509665d.akpm@linux-foundation.org> <CAPM31RKm89s6PaAnfySUD-f+eGdoZP6=9DHy58tx_4Zi8Z9WPQ@mail.gmail.com>
 <20121101005052.GB26256@bbox>
From: Paul Turner <pjt@google.com>
Date: Wed, 31 Oct 2012 18:22:58 -0700
Message-ID: <CAPM31RLNN3w5HOpuY8vX0af4j9FEPVLx1nPTrEA3ukGhG_Ssbg@mail.gmail.com>
Subject: Re: [RFC v2] Support volatile range for anon vma
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, sanjay@google.com, David Rientjes <rientjes@google.com>

On Wed, Oct 31, 2012 at 5:50 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hello,
>
> On Wed, Oct 31, 2012 at 02:59:07PM -0700, Paul Turner wrote:
>> On Wed, Oct 31, 2012 at 2:35 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>> >
>> > On Tue, 30 Oct 2012 10:29:54 +0900
>> > Minchan Kim <minchan@kernel.org> wrote:
>> >
>> > > This patch introudces new madvise behavior MADV_VOLATILE and
>> > > MADV_NOVOLATILE for anonymous pages. It's different with
>> > > John Stultz's version which considers only tmpfs while this patch
>> > > considers only anonymous pages so this cannot cover John's one.
>> > > If below idea is proved as reasonable, I hope we can unify both
>> > > concepts by madvise/fadvise.
>> > >
>> > > Rationale is following as.
>> > > Many allocators call munmap(2) when user call free(3) if ptr is
>> > > in mmaped area. But munmap isn't cheap because it have to clean up
>> > > all pte entries and unlinking a vma so overhead would be increased
>> > > linearly by mmaped area's size.
>> >
>> > Presumably the userspace allocator will internally manage memory in
>> > large chunks, so the munmap() call frequency will be much lower than
>> > the free() call frequency.  So the performance gains from this change
>> > might be very small.
>>
>> I don't think I strictly understand the motivation from a
>> malloc-standpoint here.
>>
>> These days we (tcmalloc) use madvise(..., MADV_DONTNEED) when we want
>> to perform discards on Linux.    For any reasonable allocator (short
>> of binding malloc --> mmap, free --> unmap) this seems a better
>> choice.
>>
>> Note also from a performance stand-point I doubt any allocator (which
>> case about performance) is going to want to pay the cost of even a
>> null syscall about typical malloc/free usage (consider: a tcmalloc
>
> Good point.
>
>> malloc/free pairis currently <20ns).  Given then that this cost is
>> amortized once you start doing discards on larger blocks MADV_DONTNEED
>> seems a preferable interface:
>> - You don't need to reconstruct an arena when you do want to allocate
>> since there's no munmap/mmap for the region to change about
>> - There are no syscalls involved in later reallocating the block.
>
> Above benefits are applied on MADV_VOLATILE, too.
> But as you pointed out, there is a little bit overhead than DONTNEED
> because allocator should call madvise(MADV_NOVOLATILE) before allocation.
> For mavise(NOVOLATILE) does just mark vma flag, it does need mmap_sem
> and could be a problem on parallel malloc/free workload as KOSAKI pointed out.
>
> In such case, we can change semantic so malloc doesn't need to call
> madivse(NOVOLATILE) before allocating. Then, page fault handler have to
> check whether this page fault happen by access of volatile vma. If so,
> it could return zero page instead of SIGBUS and mark the vma isn't volatile
> any more.

I think being able to determine whether the backing was discarded
(about a atomic transition to non-volatile) would be a required
property to make this useful for non-malloc use-cases.

>
>>
>> The only real additional cost is address-space.  Are you strongly
>> concerned about the 32-bit case?
>
> No. I believe allocators have a logic to clean up them once address space is
> almost full.
>
> Thanks, Paul.
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
