Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB906B0254
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 06:47:19 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id mv3so101368337igc.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 03:47:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si963391igq.87.2015.12.15.03.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 03:47:18 -0800 (PST)
Date: Tue, 15 Dec 2015 12:47:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] mm: change find_vma() function
Message-ID: <20151215114714.GL4598@redhat.com>
References: <1450090945-4020-1-git-send-email-yalin.wang2010@gmail.com>
 <20151214121107.GB4201@node.shutemov.name>
 <20151214175509.GA25681@redhat.com>
 <20151214211132.GA7390@node.shutemov.name>
 <5603C6DF-DDA5-4B57-9608-63335282B966@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5603C6DF-DDA5-4B57-9608-63335282B966@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Oleg Nesterov <oleg@redhat.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, gang.chen.5i5j@gmail.com, mhocko@suse.com, kwapulinski.piotr@gmail.com, dcashman@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 15, 2015 at 02:41:21PM +0800, yalin wang wrote:
> 
> > On Dec 15, 2015, at 05:11, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Mon, Dec 14, 2015 at 06:55:09PM +0100, Oleg Nesterov wrote:
> >> On 12/14, Kirill A. Shutemov wrote:
> >>> 
> >>> On Mon, Dec 14, 2015 at 07:02:25PM +0800, yalin wang wrote:
> >>>> change find_vma() to break ealier when found the adderss
> >>>> is not in any vma, don't need loop to search all vma.
> >>>> 
> >>>> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> >>>> ---
> >>>> mm/mmap.c | 3 +++
> >>>> 1 file changed, 3 insertions(+)
> >>>> 
> >>>> diff --git a/mm/mmap.c b/mm/mmap.c
> >>>> index b513f20..8294c9b 100644
> >>>> --- a/mm/mmap.c
> >>>> +++ b/mm/mmap.c
> >>>> @@ -2064,6 +2064,9 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
> >>>> 			vma = tmp;
> >>>> 			if (tmp->vm_start <= addr)
> >>>> 				break;
> >>>> +			if (!tmp->vm_prev || tmp->vm_prev->vm_end <= addr)
> >>>> +				break;
> >>>> +
> >>> 
> >>> This 'break' would return 'tmp' as found vma.
> >> 
> >> But this would be right?
> > 
> > Hm. Right. Sorry for my tone.
> > 
> > I think the right condition is 'tmp->vm_prev->vm_end < addr', not '<=' as
> > vm_end is the first byte after the vma. But it's equivalent in practice
> > here.
> > 
> this should be <= here,
> because vmaa??s effect address space doesna??t include vm_end add,
> so if an address vm_end <= add , this means this addr dona??t belong to this vma,

We need to return the vma with lowest vm_end that satisifes "addr <
vm_end", so if vm_prev has "addr >= vm_end" would imply we can return
"tmp", that includes if addr == vm_prev->vm_end yes. If we'd spend CPU
for this it's worth to optimize for the case of tmp->vm_start ==
tmp->vm_prev->vm_end too and stop in such case too.

> 
> > Anyway, I don't think it's possible to gain anything measurable from this
> > optimization.
> > 
> the advantage is that if addr dona??t belong to any vma, we dona??t need loop all vma,
> we can break earlier if we found the most closest vma which vma->end_add > addr,

But that costs CPU for all cases were we cannot stop: it would waste
cachelines to check vmas that we would otherwise not even touch at
all. All those vmas are in different addresses, they're not
contiguous, plus the vma is pretty large object anyway (even if they
were contiguous).

So this will requires 2 cachelines instead of 1, for each vma we
encounter during the rbtree lookup. And for a large tree we may not
have to rescan those vmas of the vm_prev while moving down, so even if
the CPU cache could fit those extra vm_prev cachelines they would be
just useless as we continue the lookup down the tree.

So if a tree is very large and this optimization only allows us to
skip the last few level of tree walk, it'll still double up the
cachline cost of all the upper level lookups. Which may greatly exceed
the last few levels we skept.

Proper (probably non trivial) math could calculate the exact
probability this ends up being an optimization vs a slowdown. My gut
feeling is that for a small tree this increases performance, for a
large tree this decreases performance and the breakpoint is somewhere
in the middle. However a small tree runs fast anyway.

Last but not the least, one easy thing we can trivially tell already,
is that the worst case latency for the worst possible slowest lookup
would definitely be worsened and it would almost double with this
patch applied. So this is enough for me to be against applying this
patch.

All special cases we already hard optimize it with vmacache_find so if
that is about a special case with userland knowledge that should go
elsewhere and we already do those kind of fast path optimizations.

The patched code is the one that runs if we're not in a special
userland fast path case and to me the highest priority for this piece
of code is to optimize to guarantee the least harmful worst case for
the most inefficient lookup, and this patch would make the worst case
twice as slow as it is now for the worst case.

I think keeping the worst case as fast as possible is the highest
priority here.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
