Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C27696B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 06:37:22 -0400 (EDT)
Date: Thu, 29 Oct 2009 11:36:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091029103658.GJ9640@random.random>
References: <20091026185130.GC4868@random.random>
 <87ljiwk8el.fsf@basil.nowhere.org>
 <20091027193007.GA6043@random.random>
 <20091028042805.GJ7744@basil.fritz.box>
 <20091029094344.GA1068@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091029094344.GA1068@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello Ingo, Andi, everyone,

On Thu, Oct 29, 2009 at 10:43:44AM +0100, Ingo Molnar wrote:
> 
> * Andi Kleen <andi@firstfloor.org> wrote:
> 
> > > 1GB pages can't be handled by this code, and clearly it's not 
> > > practical to hope 1G pages to materialize in the buddy (even if we
> > 
> > That seems short sightened. You do this because 2MB pages give you x% 
> > performance advantage, but then it's likely that 1GB pages will give 
> > another y% improvement and why should people stop at the smaller 
> > improvement?
> > 
> > Ignoring the gigantic pages now would just mean that this would need 
> > to be revised later again or that users still need to use hacks like 
> > libhugetlbfs.
> 
> I've read the patch and have read through this discussion and you are 
> missing the big point that it's best to do such things gradually - one 
> step at a time.
> 
> Just like we went from 2 level pagetables to 3 level pagetables, then to 
> 4 level pagetables - and we might go to 5 level pagetables in the 
> future. We didnt go from 2 level pagetables to 5 level page tables in 
> one go, despite predictions clearly pointing out the exponentially 
> increasing need for RAM.

I totally agree with your assessment.

> So your obsession with 1GB pages is misguided. If indeed transparent 
> largepages give us real benefits we can extend it to do transparent 
> gbpages as well - should we ever want to. There's nothing 'shortsighted' 
> about being gradual - the change is already ambitious enough as-is, and 
> brings very clear benefits to a difficult, decade-old problem no other 
> person was able to address.
> 
> In fact introducing transparent 2MBpages makes 1GB pages support 
> _easier_ to merge: as at that point we'll already have a (finally..) 
> successful hugetlb facility happility used by an increasing range of 
> applications.

Agreed.

> Hugetlbfs's big problem was always that it wasnt transparent and hence 
> wasnt gradual for applications. It was an opt-in and constituted an 
> interface/ABI change - that is always a big barrier to app adoption.
> 
> So i give Andrea's patch a very big thumbs up - i hope it gets reviewed 
> in fine detail and added to -mm ASAP. Our lack of decent, automatic 
> hugepage support is sticking out like a sore thumb and is hurting us in 
> high-performance setups. If largepage support within Linux has a chance, 
> this might be the way to do it.

Thanks a lot for your review!

> A small comment regarding the patch itself: i think it could be 
> simplified further by eliminating CONFIG_TRANSPARENT_HUGEPAGE and by 
> making it a natural feature of hugepage support. If the code is correct 
> i cannot see any scenario under which i wouldnt want a hugepage enabled 
> kernel i'm booting to not have transparent hugepage support as well.

The two reasons why I added a config option are:

1) because it was easy enough, gcc is smart enough to eliminate the
external calls so I didn't need to add ifdefs with the exception of
returning 0 from pmd_trans_huge and pmd_trans_frozen. I only had to
make the exports of huge_memory.c visible unconditionally so it doesn't
warn, after that I don't need to build and link huge_memory.o.

2) to avoid breaking build of archs not implementing pmd_trans_huge
and that may never be able to take advantage of it

But we could move CONFIG_TRANSPARENT_HUGEPAGE to an arch define forced
to Y on x86-64 and N on power.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
