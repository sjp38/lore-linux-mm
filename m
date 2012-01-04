Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C9FCF6B00B9
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 20:51:42 -0500 (EST)
Received: by iacb35 with SMTP id b35so38369831iac.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 17:51:42 -0800 (PST)
Date: Tue, 3 Jan 2012 17:51:22 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] sysvshm: SHM_LOCK use lru_add_drain_all_async()
In-Reply-To: <1325403025-22688-2-git-send-email-kosaki.motohiro@gmail.com>
Message-ID: <alpine.LSU.2.00.1201031724300.1254@eggly.anvils>
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com> <1325403025-22688-2-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Sun, 1 Jan 2012, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> shmctl also don't need synchrounous pagevec drain. This patch replace it with
> lru_add_drain_all_async().
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Let me answer this 2/2 first since it's easier.

I'm going to thank you for bringing this lru_add_drain_all()
to my attention, I had not noticed it; but Nak the patch itself.

The reason being, that particular lru_add_drain_all() serves no
useful purpose, so let's delete it instead of replacing it.  I believe
that it serves no purpose for SHM_LOCK and no purpose for SHM_UNLOCK.

I'm dabbling in this area myself, since you so cogently pointed out that
I'd tried to add a cond_resched() to scan_mapping_unevictable_pages()
(which is a helper for SHM_UNLOCK here) while it's under spinlock.

In testing my fix for that, I find that there has been no attempt to
keep the Unevictable count accurate on SysVShm: SHM_LOCK pages get
marked unevictable lazily later as memory pressure discovers them -
which perhaps mirrors the way in which SHM_LOCK makes no attempt to
instantiate pages, unlike mlock.

Since nobody has complained about that in the two years since we've
had an Unevictable count in /proc/meminfo, I don't see any need to
add code (it would need more than just your change here; would need
more even than calling scan_mapping_unevictable_pages() at SHM_LOCK
time - though perhaps along with your 1/2 that could handle it) and
overhead to satisfy a need that nobody has.

I'll delete that lru_add_drain_all() in my patch, okay?

(But in writing this, realize I still don't quite understand why
the Unevictable count takes a second or two to get back to 0 after
SHM_UNLOCK: perhaps I've more to discover.)

Hugh

> ---
>  ipc/shm.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 02ecf2c..1eb25f0 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -872,8 +872,6 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
>  	{
>  		struct file *uninitialized_var(shm_file);
>  
> -		lru_add_drain_all();  /* drain pagevecs to lru lists */
> -
>  		shp = shm_lock_check(ns, shmid);
>  		if (IS_ERR(shp)) {
>  			err = PTR_ERR(shp);
> @@ -911,6 +909,8 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
>  			shp->mlock_user = NULL;
>  		}
>  		shm_unlock(shp);
> +		/* prevent user visible mismatch of unevictable accounting */
> +		lru_add_drain_all_async();
>  		goto out;
>  	}
>  	case IPC_RMID:
> -- 
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
