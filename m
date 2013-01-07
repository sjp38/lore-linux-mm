Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 6B0E46B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:06:32 -0500 (EST)
Date: Mon, 7 Jan 2013 12:06:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch]mm: make madvise(MADV_WILLNEED) support swap file
 prefetch
Message-Id: <20130107120630.82ba51ad.akpm@linux-foundation.org>
In-Reply-To: <20130107081237.GB21779@kernel.org>
References: <20130107081237.GB21779@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com

On Mon, 7 Jan 2013 16:12:37 +0800
Shaohua Li <shli@kernel.org> wrote:

> 
> Make madvise(MADV_WILLNEED) support swap file prefetch. If memory is swapout,
> this syscall can do swapin prefetch. It has no impact if the memory isn't
> swapout.

Seems sensible.

> @@ -140,6 +219,18 @@ static long madvise_willneed(struct vm_a
>  {
>  	struct file *file = vma->vm_file;
>  
> +#ifdef CONFIG_SWAP

It's odd that you put the ifdef in there, but then didn't test it!


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix

fix CONFIG_SWAP=n build

Cc: Shaohua Li <shli@fusionio.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/madvise.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN mm/madvise.c~mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix mm/madvise.c
--- a/mm/madvise.c~mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix
+++ a/mm/madvise.c
@@ -134,6 +134,7 @@ out:
 	return error;
 }
 
+#ifdef CONFIG_SWAP
 static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 	unsigned long end, struct mm_walk *walk)
 {
@@ -209,6 +210,7 @@ static void force_shm_swapin_readahead(s
 
 	lru_add_drain();	/* Push any new pages onto the LRU now */
 }
+#endif		/* CONFIG_SWAP */
 
 /*
  * Schedule all required I/O operations.  Do not wait for completion.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
