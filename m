Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 51C0E6B00A9
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 17:06:34 -0500 (EST)
Date: Tue, 22 Nov 2011 14:06:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
Message-Id: <20111122140630.9f37c907.akpm@linux-foundation.org>
In-Reply-To: <1321612791-4764-1-git-send-email-amwang@redhat.com>
References: <1321612791-4764-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Fri, 18 Nov 2011 18:39:50 +0800
Cong Wang <amwang@redhat.com> wrote:

> It seems that systemd needs tmpfs to support fallocate,
> see http://lkml.org/lkml/2011/10/20/275. This patch adds
> fallocate support to tmpfs.
> 
> As we already have shmem_truncate_range(), it is also easy
> to add FALLOC_FL_PUNCH_HOLE support too.
> 
>
> ...
>
> +static long shmem_fallocate(struct file *file, int mode,
> +				loff_t offset, loff_t len)
> +{
> +	struct inode *inode = file->f_path.dentry->d_inode;
> +	pgoff_t start = offset >> PAGE_CACHE_SHIFT;
> +	pgoff_t end = DIV_ROUND_UP((offset + len), PAGE_CACHE_SIZE);
> +	pgoff_t index = start;
> +	loff_t i_size = i_size_read(inode);
> +	struct page *page = NULL;
> +	int ret = 0;
> +
> +	mutex_lock(&inode->i_mutex);

It would be saner and less racy-looking to read i_size _after_ taking
i_mutex.

And if you do that, there's no need to use i_size_read() - just a plain
old

	i_size = inode->i_size;

is OK.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
