Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id EDEBF6B038B
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 15:29:53 -0400 (EDT)
Message-ID: <1340652578.21991.18.camel@twins>
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 25 Jun 2012 21:29:38 +0200
In-Reply-To: <4FE4922D.8070501@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	    <1340315835-28571-2-git-send-email-riel@surriel.com>
	   <1340359115.18025.57.camel@twins> <4FE47D0E.3000804@redhat.com>
	  <1340374439.18025.75.camel@twins> <4FE48054.5090407@redhat.com>
	 <1340375872.18025.77.camel@twins> <4FE4922D.8070501@surriel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On Fri, 2012-06-22 at 11:41 -0400, Rik van Riel wrote:
> Let me try implementing your algorithm with arbitrary
> address constraints and alignment/colouring.=20

Right, so the best I could come up with for a range search is=20
O((log n)^2), it does need another pointer in the vma though :/

Instead of storing the single right sub-tree pointer, you store a single
linked list of right sub-tree pointers using that extra vma member.

Then when no gap was found on the left downward path, try each
successive right sub-tree (bottom-up per the LIFO single linked list and
top-down) and do a right-path and left subtree search for those.

So you get a log n walk, with a log n walk for each right sub-tree,
giving a 1/2 * log n * log n aka O((log n)^2).

If you do the search without right limit, the first right subtree search
is sufficient and you'll revert back to O(log n).



I've also thought about the update cost and I think I can make the
vma_adjust case cheaper if you keep the max(vm_end) as second
augmentation, this does add another word to the vma though.

Using this max(vm_end) of the subtree you can do a rb_augment_path()
variant over a specified range (the range that gets modified by
vma_adjust etc..) in O(m log n) worst time, but much better on average.

You still do the m iteration on the range, but you stop the path upwards
whenever the subtree max(vm_end) covers the given range end. Except for
the very last of m, at which point you'll go all the way up.

This should avoid many of the duplicate path traversals the naive
implementation does.


Sadly we've just added two words to the vma and are 2 words over the
cacheline size for the fields used in the update.

This too could be fixed by removing vm_{prev,next} and making
rb_{prev,next} O(1) instead of O(log n) as they are now. Like:
http://en.wikipedia.org/wiki/Threaded_binary_tree


I haven't had any good ideas on the alignment thing though, I keep
getting back to O(n) or worse if you want a guarantee you find a hole if
you have it.

The thing you propose, the double search, once for len, and once for len
+align-1 doesn't guarantee you'll find a hole. All holes of len might be
mis-aligned but the len+align-1 search might overlook a hole of suitable
size and alignment, you'd have to search the entire range: [len, len
+align-1], and that's somewhat silly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
