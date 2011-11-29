Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E66496B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 01:03:51 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C07B03EE0AE
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 15:03:48 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A600645DE54
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 15:03:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ABA945DE4E
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 15:03:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D9051DB8042
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 15:03:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 41C751DB8037
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 15:03:48 +0900 (JST)
Date: Tue, 29 Nov 2011 15:02:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [V4 PATCH 1/2] tmpfs: add fallocate support
Message-Id: <20111129150210.ad266dd7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322544793-2676-1-git-send-email-amwang@redhat.com>
References: <1322544793-2676-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 29 Nov 2011 13:33:12 +0800
Cong Wang <amwang@redhat.com> wrote:

> Systemd needs tmpfs to support fallocate [1], to be able
> to safely use mmap(), regarding SIGBUS, on files on the
> /dev/shm filesystem. The glibc fallback loop for -ENOSYS
> on fallocate is just ugly.
> 
> This patch adds fallocate support to tmpfs, and as we
> already have shmem_truncate_range(), it is also easy to
> add FALLOC_FL_PUNCH_HOLE support too.
> 
> 1. http://lkml.org/lkml/2011/10/20/275
> 

one question.


> V3->V4:
> Handle 'undo' ENOSPC more correctly.
> 
> V2->V3:
> a) Read i_size directly after holding i_mutex;
> b) Call page_cache_release() too after shmem_getpage();
> c) Undo previous changes when -ENOSPC.
> 
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Lennart Poettering <lennart@poettering.net>
> Cc: Kay Sievers <kay.sievers@vrfy.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 
> ---
>  mm/shmem.c |   90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 90 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d672250..90c835b 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -30,6 +30,7 @@
>  #include <linux/mm.h>
>  #include <linux/export.h>
>  #include <linux/swap.h>
> +#include <linux/falloc.h>
>  
>  static struct vfsmount *shm_mnt;
>  
> @@ -1016,6 +1017,35 @@ failed:
>  	return error;
>  }
>  
> +static void shmem_putpage_noswap(struct inode *inode, pgoff_t index)
> +{
> +	struct address_space *mapping = inode->i_mapping;
> +	struct shmem_inode_info *info;
> +	struct shmem_sb_info *sbinfo;
> +	struct page *page;
> +
> +	page = find_lock_page(mapping, index);
> +

You can't know whether the 'page' is allocated by alloc_page() in fallocate()
or just found as exiting one.
Then, yourwill corrupt existing pages in error path.
Is it allowed ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
