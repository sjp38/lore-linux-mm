Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 6EFBC6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 19:46:44 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6338035pbb.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 16:46:42 -0700 (PDT)
Date: Fri, 29 Jun 2012 16:46:38 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
Message-ID: <20120629234638.GA27797@google.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
 <1340315835-28571-2-git-send-email-riel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340315835-28571-2-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Thu, Jun 21, 2012 at 05:57:05PM -0400, Rik van Riel wrote:
>  /*
> + * largest_free_gap - returns the largest free gap "nearby"
> + *
> + * This function is called when propagating information on the
> + * free spaces between VMAs "up" the VMA rbtree. It returns the
> + * largest of:
> + *
> + * 1. The gap between this VMA and vma->vm_prev.
> + * 2. The largest gap below us and to our left in the rbtree.
> + * 3. The largest gap below us and to our right in the rbtree.
> + */
> +static unsigned long largest_free_gap(struct rb_node *node)
> +{
> +	struct vm_area_struct *vma, *prev, *left = NULL, *right = NULL;
> +	unsigned long largest = 0;
> +
> +	if (node->rb_left)
> +		left = rb_to_vma(node->rb_left);
> +	if (node->rb_right)
> +		right = rb_to_vma(node->rb_right);
> +
> +	/* Calculate the free gap size between us and the VMA to our left. */
> +	vma = rb_to_vma(node);
> +	prev = vma->vm_prev;
> +
> +	if (prev)
> +		largest = vma->vm_start - prev->vm_end;
> +	else
> +		largest = vma->vm_start;
> +
> +	/* We propagate the largest of our own, or our children's free gaps. */
> +	if (left)
> +		largest = max(largest, left->free_gap);
> +	if (right)
> +		largest = max(largest, right->free_gap);
> +
> +	return largest;
> +}

I second PeterZ's suggestion of having an helper function

static unsigned long free_gap(struct rb_node *node)
{
	struct vm_area_struct *vma = rb_to_vma(node);
	unsigned long gap = vma->vm_start;
	if (vma->vm_prev)
		gap -= vma->vm_prev->vm_end;
	return gap;
}

Which you can then use to simplify the largest_free_gap() implementation.

> +/*
> + * Use the augmented rbtree code to propagate info on the largest
> + * free gap between VMAs up the VMA rbtree.
> + */
> +static void adjust_free_gap(struct vm_area_struct *vma)
> +{
> +	rb_augment_erase_end(&vma->vm_rb, vma_rb_augment_cb, NULL);
> +}
> @@ -398,6 +454,10 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
>  {
>  	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
>  	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
> +	adjust_free_gap(vma);
> +	/* Propagate the new free gap between next and us up the tree. */
> +	if (vma->vm_next)
> +		adjust_free_gap(vma->vm_next);
>  }

So this will work, and may be fine for a first implementation. However,
the augmented rbtree support really seems inadequate here. What we
would want is for adjust_free_gap to adjust the node's free_gap as
well as its parents, and *stop* when it reaches a node that already
has the desired free_gap instead of going all the way to the root as
it does now. But, to do that we would also need rb_insert_color() to
adjust free_gap as needed when doing tree rotations, and it doesn't
have the necessary support there.

Basically, I think lib/rbtree.c should provide augmented rbtree support
in the form of (versions of) rb_insert_color() and rb_erase() being able to
callback to adjust the augmented node information around tree rotations,
instead of using (conservative, overkill) loops to adjust the augmented
node information after the fact in all places that might have been affected
by such rotations. Doing it after the fact is necessarity overkill because
it visits O(log N) nodes, while the number of rotations that might have
occured is only O(1).

I'm interested in this stuff, please CC me if you do a v3 :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
