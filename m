Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id A632D6B0071
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 00:14:30 -0500 (EST)
Received: by qcsd17 with SMTP id d17so9425185qcs.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 21:14:29 -0800 (PST)
Message-ID: <4EFBF732.1070303@gmail.com>
Date: Thu, 29 Dec 2011 00:14:26 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: cond_resched in scan_mapping_unevictable_pages
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282035250.1362@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112282035250.1362@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

(12/28/11 11:36 PM), Hugh Dickins wrote:
> scan_mapping_unevictable_pages() is used to make SysV SHM_LOCKed pages
> evictable again once the shared memory is unlocked or destroyed (the
> latter seems rather a waste of time, but meets internal expectations).
> It does pagevec_lookup()s across the whole object: methinks a
> cond_resched() every PAGEVEC_SIZE pages would be worthwhile.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ---
>   mm/vmscan.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> --- mmotm.orig/mm/vmscan.c	2011-12-28 16:49:36.000000000 -0800
> +++ mmotm/mm/vmscan.c	2011-12-28 17:03:07.647220248 -0800
> @@ -3583,8 +3583,8 @@ void scan_mapping_unevictable_pages(stru
>   		pagevec_release(&pvec);
>
>   		count_vm_events(UNEVICTABLE_PGSCANNED, pg_scanned);
> +		cond_resched();
>   	}

Hmm...
scan_mapping_unevictable_pages() is always under spinlock?



int shmem_lock(struct file *file, int lock, struct user_struct *user)
{
         spin_lock(&info->lock);
	(snip)
                 smp_mb__after_clear_bit();
                 scan_mapping_unevictable_pages(file->f_mapping);
	(snip)
out_nomem:
         spin_unlock(&info->lock);
         return retval;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
