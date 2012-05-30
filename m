Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E5F1C6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 15:17:34 -0400 (EDT)
Date: Wed, 30 May 2012 14:17:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/6] Revert "mm: mempolicy: Let vma_merge and vma_split
 handle vma->vm_policy linkages"
In-Reply-To: <1338368529-21784-2-git-send-email-kosaki.motohiro@gmail.com>
Message-ID: <alpine.DEB.2.00.1205301414020.31768@router.home>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com> <1338368529-21784-2-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, stable@vger.kernel.org, hughd@google.com, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, 30 May 2012, kosaki.motohiro@gmail.com wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
>
> commit 05f144a0d5 removed vma->vm_policy updates code and it is a purpose of
> mbind_range(). Now, mbind_range() is virtually no-op. no-op function don't
> makes any bugs, I agree. but maybe it is not right fix.

I dont really understand the changelog. But to restore the policy_vma() is
the right thing to do since there are potential multiple use cases where
we want to apply a policy to a vma.

Proposed new changelog:

Commit 05f144a0d5 folded policy_vma() into mbind_range(). There are
other use cases of policy_vma(*) though and so revert a piece of
that commit in order to have a policy_vma() function again.

> @@ -655,23 +676,9 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
>  			if (err)
>  				goto out;
>  		}
> -
> -		/*
> -		 * Apply policy to a single VMA. The reference counting of
> -		 * policy for vma_policy linkages has already been handled by
> -		 * vma_merge and split_vma as necessary. If this is a shared
> -		 * policy then ->set_policy will increment the reference count
> -		 * for an sp node.
> -		 */

You are dropping the nice comments by Mel that explain the refcounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
