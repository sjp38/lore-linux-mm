Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id EA85E6B0395
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 17:53:37 -0400 (EDT)
Message-ID: <4FE8DD80.9040108@redhat.com>
Date: Mon, 25 Jun 2012 17:52:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
References: <1340315835-28571-1-git-send-email-riel@surriel.com>     <1340315835-28571-2-git-send-email-riel@surriel.com>    <1340359115.18025.57.camel@twins> <4FE47D0E.3000804@redhat.com>   <1340374439.18025.75.camel@twins> <4FE48054.5090407@redhat.com>  <1340375872.18025.77.camel@twins> <4FE4922D.8070501@surriel.com> <1340652578.21991.18.camel@twins>
In-Reply-To: <1340652578.21991.18.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On 06/25/2012 03:29 PM, Peter Zijlstra wrote:
> On Fri, 2012-06-22 at 11:41 -0400, Rik van Riel wrote:
>> Let me try implementing your algorithm with arbitrary
>> address constraints and alignment/colouring.
>
> Right, so the best I could come up with for a range search is
> O((log n)^2), it does need another pointer in the vma though :/
>
> Instead of storing the single right sub-tree pointer, you store a single
> linked list of right sub-tree pointers using that extra vma member.
>
> Then when no gap was found on the left downward path, try each
> successive right sub-tree (bottom-up per the LIFO single linked list and
> top-down) and do a right-path and left subtree search for those.
>
> So you get a log n walk, with a log n walk for each right sub-tree,
> giving a 1/2 * log n * log n aka O((log n)^2).
>
> If you do the search without right limit, the first right subtree search
> is sufficient and you'll revert back to O(log n).

That is essentially what my current code does.

> I've also thought about the update cost and I think I can make the
> vma_adjust case cheaper if you keep the max(vm_end) as second
> augmentation, this does add another word to the vma though.
>
> Using this max(vm_end) of the subtree you can do a rb_augment_path()
> variant over a specified range (the range that gets modified by
> vma_adjust etc..) in O(m log n) worst time, but much better on average.
>
> You still do the m iteration on the range, but you stop the path upwards
> whenever the subtree max(vm_end) covers the given range end. Except for
> the very last of m, at which point you'll go all the way up.
>
> This should avoid many of the duplicate path traversals the naive
> implementation does.

One of the benefits of an rbtree is that an insertion
or deletion is accompanied by at most 2 rotations.

These rotations, if there are two, will happen next
to each other, meaning at most 5 nodes will have new
child nodes.

Furthermore, the parent of the area where rotation
happened still has the same set of child nodes as
before (plus or minus the inserted or deleted node).

If we call the augmentation function from inside the
tree manipulation code, we may be able to save on a
lot of walking simply by having it bail out once the
augmented value in a node equals the "new" value.

The downside? This makes the rbtree code somewhat more
complex, vs. the brute force walk up the tree the current
augmented rbtree code does.

> I haven't had any good ideas on the alignment thing though, I keep
> getting back to O(n) or worse if you want a guarantee you find a hole if
> you have it.
>
> The thing you propose, the double search, once for len, and once for len
> +align-1 doesn't guarantee you'll find a hole. All holes of len might be
> mis-aligned but the len+align-1 search might overlook a hole of suitable
> size and alignment, you'd have to search the entire range: [len, len
> +align-1], and that's somewhat silly.

This may still be good enough.

Programs that exhaust their virtual address space to the
point of not being able to find a properly aligned memory
hole should be recompiled as 64 bit systems, or run on
hardware that does not have such requirements (eg. x86).

Also, the memory alignment requirement on AMD Bulldozer,
ARM and MIPS seems to be quite small. On the order of a
handful of pages (4 pages on AMD & ARM, I assume modern
MIPS is fairly sane too).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
