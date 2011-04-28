Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 630456B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 17:35:54 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p3SLZZMK029417
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 14:35:35 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by hpaq11.eem.corp.google.com with ESMTP id p3SLZJG3002390
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 14:35:34 -0700
Received: by pzk30 with SMTP id 30so2396121pzk.18
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 14:35:33 -0700 (PDT)
Date: Thu, 28 Apr 2011 14:35:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] comm: ext4: Protect task->comm access by using
 get_task_comm()
In-Reply-To: <1303963411-2064-4-git-send-email-john.stultz@linaro.org>
Message-ID: <alpine.DEB.2.00.1104281426210.21665@chino.kir.corp.google.com>
References: <1303963411-2064-1-git-send-email-john.stultz@linaro.org> <1303963411-2064-4-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, 27 Apr 2011, John Stultz wrote:

> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 7b80d54..d37414e 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -124,11 +124,15 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
>  		static unsigned long unaligned_warn_time;
>  
>  		/* Warn about this once per day */
> -		if (printk_timed_ratelimit(&unaligned_warn_time, 60*60*24*HZ))
> +		if (printk_timed_ratelimit(&unaligned_warn_time, 60*60*24*HZ)) {
> +			char comm[TASK_COMM_LEN];
> +
> +			get_task_comm(comm, current);
>  			ext4_msg(inode->i_sb, KERN_WARNING,
>  				 "Unaligned AIO/DIO on inode %ld by %s; "
>  				 "performance will be poor.",
> -				 inode->i_ino, current->comm);
> +				 inode->i_ino, comm);
> +		}
>  		mutex_lock(ext4_aio_mutex(inode));
>  		ext4_aiodio_wait(inode);
>  	}

Thanks very much for looking into concurrent readers of current->comm, 
John!

This patch in the series demonstrates one of the problems with using 
get_task_comm(), however: we must allocate a 16-byte buffer on the stack 
and that could become risky if we don't know its current depth.  We may be 
particularly deep in the stack and then cause an overflow because of the 
16 bytes.

I'm wondering if it would be better for ->comm to be protected by a 
spinlock (or rwlock) other than ->alloc_lock and then just require readers 
to take the lock prior to dereferencing it?  That's what is done in the 
oom killer with task_lock().  Perhaps you could introduce new 
task_comm_lock() and task_comm_unlock() to prevent the extra stack usage 
in over 300 locations within the kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
