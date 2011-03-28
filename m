Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1FB138D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 12:58:43 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH]mmap: not merge cloned VMA
References: <1301277534.3981.26.camel@sli10-conroe>
Date: Mon, 28 Mar 2011 09:57:06 -0700
In-Reply-To: <1301277534.3981.26.camel@sli10-conroe> (Shaohua Li's message of
	"Mon, 28 Mar 2011 09:58:54 +0800")
Message-ID: <m2k4fj18v1.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Shaohua Li <shaohua.li@intel.com> writes:

> Avoid merging a VMA with another VMA which is cloned from parent process. The
> cloned VMA shares lock with parent process's VMA. If we do the merge, more vma
> area (even the new range is only for current process) uses perent process's
> anon_vma lock, so introduces scalability issues.
> find_mergeable_anon_vma already considers this.

In theory this could prevent quite some VMA merging, but I guess the 
tradeoff is worth it and that should be unlikely to hit anyways.

>  static inline int is_mergeable_anon_vma(struct anon_vma *anon_vma1,
> -					struct anon_vma *anon_vma2)
> +					struct anon_vma *anon_vma2,
> +					struct vm_area_struct *vma)
>  {
> -	return !anon_vma1 || !anon_vma2 || (anon_vma1 == anon_vma2);
> +	if ((!anon_vma1 || !anon_vma2) && (!vma ||
> +		list_is_singular(&vma->anon_vma_chain)))
> +		return 1;

I think this if () needs a comment.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
