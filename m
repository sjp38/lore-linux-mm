Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 67BD56B00A0
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 17:38:26 -0400 (EDT)
Message-ID: <4FF3662A.9070700@redhat.com>
Date: Tue, 03 Jul 2012 17:37:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
References: <1340315835-28571-1-git-send-email-riel@surriel.com> <1340315835-28571-2-git-send-email-riel@surriel.com> <20120629234638.GA27797@google.com>
In-Reply-To: <20120629234638.GA27797@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On 06/29/2012 07:46 PM, Michel Lespinasse wrote:

I have the free_gap(node) function now.

>>   	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
>>   	rb_insert_color(&vma->vm_rb,&mm->mm_rb);
>> +	adjust_free_gap(vma);
>> +	/* Propagate the new free gap between next and us up the tree. */
>> +	if (vma->vm_next)
>> +		adjust_free_gap(vma->vm_next);
>>   }
>
> So this will work, and may be fine for a first implementation. However,
> the augmented rbtree support really seems inadequate here. What we
> would want is for adjust_free_gap to adjust the node's free_gap as
> well as its parents, and *stop* when it reaches a node that already
> has the desired free_gap instead of going all the way to the root as
> it does now. But, to do that we would also need rb_insert_color() to
> adjust free_gap as needed when doing tree rotations, and it doesn't
> have the necessary support there.
>
> Basically, I think lib/rbtree.c should provide augmented rbtree support
> in the form of (versions of) rb_insert_color() and rb_erase() being able to
> callback to adjust the augmented node information around tree rotations,
> instead of using (conservative, overkill) loops to adjust the augmented
> node information after the fact

That is what I originally worked on.

I threw out that code after people told me (at LSF/MM) in
no uncertain terms that I should use the augmented rbtree
code :)

Will CC you on the next version.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
