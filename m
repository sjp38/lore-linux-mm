Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9168F6B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 18:18:10 -0500 (EST)
Date: Wed, 18 Nov 2009 15:18:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]  [for mmotm-1113] mm: Simplify try_to_unmap_one()
Message-Id: <20091118151803.35f55ca3.akpm@linux-foundation.org>
In-Reply-To: <20091117173759.3DF6.A69D9226@jp.fujitsu.com>
References: <20091117173759.3DF6.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 2009 17:39:27 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> +out_mlock:
> +	pte_unmap_unlock(pte, ptl);
> +
> +	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> +		if (vma->vm_flags & VM_LOCKED) {
> +			mlock_vma_page(page);
> +			ret = SWAP_MLOCK;
>  		}
> +		up_read(&vma->vm_mm->mmap_sem);

It's somewhat unobvious why we're using a trylock here.  Ranking versus
lock_page(), perhaps?

In general I think a trylock should have an associated comment which explains

a) why it is being used at this site and

b) what happens when the trylock fails - why this isn't a
   bug, how the kernel recovers from the inconsistency, what its
   overall effect is, etc.

<wonders why we need to take mmap_sem here at all>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
