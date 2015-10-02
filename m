Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 502BD4402FE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 18:37:05 -0400 (EDT)
Received: by qgt47 with SMTP id 47so107275717qgt.2
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 15:37:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e13si12287989qhc.3.2015.10.02.15.37.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 15:37:04 -0700 (PDT)
Date: Fri, 2 Oct 2015 15:37:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/4] mm, proc: account for shmem swap in
 /proc/pid/smaps
Message-Id: <20151002153702.7bdc4c0483cd9b2ee9e0fba3@linux-foundation.org>
In-Reply-To: <1443792951-13944-3-git-send-email-vbabka@suse.cz>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
	<1443792951-13944-3-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri,  2 Oct 2015 15:35:49 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-backed
> mappings, even if the mapped portion does contain pages that were swapped out.
> This is because unlike private anonymous mappings, shmem does not change pte
> to swap entry, but pte_none when swapping the page out. In the smaps page
> walk, such page thus looks like it was never faulted in.
> 
> This patch changes smaps_pte_entry() to determine the swap status for such
> pte_none entries for shmem mappings, similarly to how mincore_page() does it.
> Swapped out pages are thus accounted for.
> 
> The accounting is arguably still not as precise as for private anonymous
> mappings, since now we will count also pages that the process in question never
> accessed, but only another process populated them and then let them become
> swapped out. I believe it is still less confusing and subtle than not showing
> any swap usage by shmem mappings at all. Also, swapped out pages only becomee a
> performance issue for future accesses, and we cannot predict those for neither
> kind of mapping.
> 
> ...
>
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -60,6 +60,12 @@ extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
>  extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
>  extern int shmem_unuse(swp_entry_t entry, struct page *page);
>  
> +#ifdef CONFIG_SWAP
> +extern unsigned long shmem_swap_usage(struct inode *inode);
> +extern unsigned long shmem_partial_swap_usage(struct address_space *mapping,
> +						pgoff_t start, pgoff_t end);
> +#endif

CONFIG_SWAP is wrong, isn't it?  It should be CONFIG_SHMEM if anything.

I'd just do

--- a/include/linux/shmem_fs.h~mm-proc-account-for-shmem-swap-in-proc-pid-smaps-fix
+++ a/include/linux/shmem_fs.h
@@ -60,11 +60,9 @@ extern struct page *shmem_read_mapping_p
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 
-#ifdef CONFIG_SWAP
 extern unsigned long shmem_swap_usage(struct inode *inode);
 extern unsigned long shmem_partial_swap_usage(struct address_space *mapping,
 						pgoff_t start, pgoff_t end);
-#endif
 
 static inline struct page *shmem_read_mapping_page(
 				struct address_space *mapping, pgoff_t index)


We don't need the ifdefs around declarations and they're a pain to
maintain and they'd add a *ton* of clutter if we even tried to do this
for real.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
