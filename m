Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 98C566B0272
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 12:32:53 -0500 (EST)
Received: by qkfb125 with SMTP id b125so5592385qkf.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 09:32:53 -0800 (PST)
Received: from mx4-phx2.redhat.com (mx4-phx2.redhat.com. [209.132.183.25])
        by mx.google.com with ESMTPS id f2si20392788qhd.2.2015.12.07.09.32.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Dec 2015 09:32:52 -0800 (PST)
Date: Mon, 7 Dec 2015 12:32:27 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <1526714685.24984914.1449509547835.JavaMail.zimbra@redhat.com>
In-Reply-To: <20151207160715.GA6373@twins.programming.kicks-ass.net>
References: <5665703F.4090302@redhat.com> <5665A346.4030403@redhat.com> <20151207154459.GC6356@twins.programming.kicks-ass.net> <20151207160715.GA6373@twins.programming.kicks-ass.net>
Subject: Re: kernel BUG at mm/filemap.c:238! (4.4.0-rc4)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>





----- Original Message -----
> From: "Peter Zijlstra" <peterz@infradead.org>
> To: "Jan Stancek" <jstancek@redhat.com>
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Oleg Nesterov" <oleg@redhat.com>
> Sent: Monday, 7 December, 2015 5:07:15 PM
> Subject: Re: kernel BUG at mm/filemap.c:238! (4.4.0-rc4)
> 
> On Mon, Dec 07, 2015 at 04:44:59PM +0100, Peter Zijlstra wrote:
> > On Mon, Dec 07, 2015 at 04:18:30PM +0100, Jan Stancek wrote:
> > > So, according to bisect first bad commit is:
> > > 
> > > commit 68985633bccb6066bf1803e316fbc6c1f5b796d6
> > > Author: Peter Zijlstra <peterz@infradead.org>
> > > Date:   Tue Dec 1 14:04:04 2015 +0100
> > > 
> > >     sched/wait: Fix signal handling in bit wait helpers
> > > 
> > > which seems to me is only exposing problem elsewhere.
> > > 
> > 
> > Nope, I think I messed that up, just not sure how to fix it proper then.
> > Let me have a ponder.
> 
> Blergh I hate signals :/
> 
> The below compiles, does it work?

Yes, it does. I applied your patch on 4.4-rc4 and I can't
reproduce it any longer.

> 
> ---
>  fs/cifs/inode.c      |    6 +++---
>  fs/nfs/inode.c       |    6 +++---
>  fs/nfs/internal.h    |    2 +-
>  fs/nfs/pagelist.c    |    2 +-
>  fs/nfs/pnfs.c        |    4 ++--
>  include/linux/wait.h |   10 +++++-----
>  kernel/sched/wait.c  |   20 ++++++++++----------
>  net/sunrpc/sched.c   |    6 +++---
>  8 files changed, 28 insertions(+), 28 deletions(-)
> 
> diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
> index 6b66dd5..a329f5b 100644
> --- a/fs/cifs/inode.c
> +++ b/fs/cifs/inode.c
> @@ -1831,11 +1831,11 @@ cifs_invalidate_mapping(struct inode *inode)
>   * @word: long word containing the bit lock
>   */
>  static int
> -cifs_wait_bit_killable(struct wait_bit_key *key)
> +cifs_wait_bit_killable(struct wait_bit_key *key, int mode)
>  {
> -	if (fatal_signal_pending(current))
> -		return -ERESTARTSYS;
>  	freezable_schedule_unsafe();
> +	if (signal_pending_state(mode, current))
> +		return -ERESTARTSYS;
>  	return 0;
>  }
>  
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 31b0a52..c7e8b87 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -75,11 +75,11 @@ nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
>   * nfs_wait_bit_killable - helper for functions that are sleeping on bit
>   locks
>   * @word: long word containing the bit lock
>   */
> -int nfs_wait_bit_killable(struct wait_bit_key *key)
> +int nfs_wait_bit_killable(struct wait_bit_key *key, int mode)
>  {
> -	if (fatal_signal_pending(current))
> -		return -ERESTARTSYS;
>  	freezable_schedule_unsafe();
> +	if (signal_pending_state(mode, current))
> +		return -ERESTARTSYS;
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(nfs_wait_bit_killable);
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 56cfde2..9dea85f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -379,7 +379,7 @@ extern int nfs_drop_inode(struct inode *);
>  extern void nfs_clear_inode(struct inode *);
>  extern void nfs_evict_inode(struct inode *);
>  void nfs_zap_acl_cache(struct inode *inode);
> -extern int nfs_wait_bit_killable(struct wait_bit_key *key);
> +extern int nfs_wait_bit_killable(struct wait_bit_key *key, int mode);
>  
>  /* super.c */
>  extern const struct super_operations nfs_sops;
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index fe3ddd2..452a011 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -129,7 +129,7 @@ __nfs_iocounter_wait(struct nfs_io_counter *c)
>  		set_bit(NFS_IO_INPROGRESS, &c->flags);
>  		if (atomic_read(&c->io_count) == 0)
>  			break;
> -		ret = nfs_wait_bit_killable(&q.key);
> +		ret = nfs_wait_bit_killable(&q.key, TASK_KILLABLE);
>  	} while (atomic_read(&c->io_count) != 0 && !ret);
>  	finish_wait(wq, &q.wait);
>  	return ret;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 5a8ae21..bec0384 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1466,11 +1466,11 @@ static bool pnfs_within_mdsthreshold(struct
> nfs_open_context *ctx,
>  }
>  
>  /* stop waiting if someone clears NFS_LAYOUT_RETRY_LAYOUTGET bit. */
> -static int pnfs_layoutget_retry_bit_wait(struct wait_bit_key *key)
> +static int pnfs_layoutget_retry_bit_wait(struct wait_bit_key *key, int mode)
>  {
>  	if (!test_bit(NFS_LAYOUT_RETRY_LAYOUTGET, key->flags))
>  		return 1;
> -	return nfs_wait_bit_killable(key);
> +	return nfs_wait_bit_killable(key, mode);
>  }
>  
>  static bool pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr *lo)
> diff --git a/include/linux/wait.h b/include/linux/wait.h
> index 1e1bf9f..513b36f 100644
> --- a/include/linux/wait.h
> +++ b/include/linux/wait.h
> @@ -145,7 +145,7 @@ __remove_wait_queue(wait_queue_head_t *head, wait_queue_t
> *old)
>  	list_del(&old->task_list);
>  }
>  
> -typedef int wait_bit_action_f(struct wait_bit_key *);
> +typedef int wait_bit_action_f(struct wait_bit_key *, int mode);
>  void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
>  void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void
>  *key);
>  void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr,
>  void *key);
> @@ -960,10 +960,10 @@ int wake_bit_function(wait_queue_t *wait, unsigned
> mode, int sync, void *key);
>  	} while (0)
>  
>  
> -extern int bit_wait(struct wait_bit_key *);
> -extern int bit_wait_io(struct wait_bit_key *);
> -extern int bit_wait_timeout(struct wait_bit_key *);
> -extern int bit_wait_io_timeout(struct wait_bit_key *);
> +extern int bit_wait(struct wait_bit_key *, int);
> +extern int bit_wait_io(struct wait_bit_key *, int);
> +extern int bit_wait_timeout(struct wait_bit_key *, int);
> +extern int bit_wait_io_timeout(struct wait_bit_key *, int);
>  
>  /**
>   * wait_on_bit - wait for a bit to be cleared
> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index f10bd87..f15d6b6 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -392,7 +392,7 @@ __wait_on_bit(wait_queue_head_t *wq, struct
> wait_bit_queue *q,
>  	do {
>  		prepare_to_wait(wq, &q->wait, mode);
>  		if (test_bit(q->key.bit_nr, q->key.flags))
> -			ret = (*action)(&q->key);
> +			ret = (*action)(&q->key, mode);
>  	} while (test_bit(q->key.bit_nr, q->key.flags) && !ret);
>  	finish_wait(wq, &q->wait);
>  	return ret;
> @@ -431,7 +431,7 @@ __wait_on_bit_lock(wait_queue_head_t *wq, struct
> wait_bit_queue *q,
>  		prepare_to_wait_exclusive(wq, &q->wait, mode);
>  		if (!test_bit(q->key.bit_nr, q->key.flags))
>  			continue;
> -		ret = action(&q->key);
> +		ret = action(&q->key, mode);
>  		if (!ret)
>  			continue;
>  		abort_exclusive_wait(wq, &q->wait, mode, &q->key);
> @@ -581,43 +581,43 @@ void wake_up_atomic_t(atomic_t *p)
>  }
>  EXPORT_SYMBOL(wake_up_atomic_t);
>  
> -__sched int bit_wait(struct wait_bit_key *word)
> +__sched int bit_wait(struct wait_bit_key *word, int mode)
>  {
>  	schedule();
> -	if (signal_pending(current))
> +	if (signal_pending_state(mode, current))
>  		return -EINTR;
>  	return 0;
>  }
>  EXPORT_SYMBOL(bit_wait);
>  
> -__sched int bit_wait_io(struct wait_bit_key *word)
> +__sched int bit_wait_io(struct wait_bit_key *word, int mode)
>  {
>  	io_schedule();
> -	if (signal_pending(current))
> +	if (signal_pending_state(mode, current))
>  		return -EINTR;
>  	return 0;
>  }
>  EXPORT_SYMBOL(bit_wait_io);
>  
> -__sched int bit_wait_timeout(struct wait_bit_key *word)
> +__sched int bit_wait_timeout(struct wait_bit_key *word, int mode)
>  {
>  	unsigned long now = READ_ONCE(jiffies);
>  	if (time_after_eq(now, word->timeout))
>  		return -EAGAIN;
>  	schedule_timeout(word->timeout - now);
> -	if (signal_pending(current))
> +	if (signal_pending_state(mode, current))
>  		return -EINTR;
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(bit_wait_timeout);
>  
> -__sched int bit_wait_io_timeout(struct wait_bit_key *word)
> +__sched int bit_wait_io_timeout(struct wait_bit_key *word, int mode)
>  {
>  	unsigned long now = READ_ONCE(jiffies);
>  	if (time_after_eq(now, word->timeout))
>  		return -EAGAIN;
>  	io_schedule_timeout(word->timeout - now);
> -	if (signal_pending(current))
> +	if (signal_pending_state(mode, current))
>  		return -EINTR;
>  	return 0;
>  }
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index f14f24e..73ad57a 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -250,11 +250,11 @@ void rpc_destroy_wait_queue(struct rpc_wait_queue
> *queue)
>  }
>  EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
>  
> -static int rpc_wait_bit_killable(struct wait_bit_key *key)
> +static int rpc_wait_bit_killable(struct wait_bit_key *key, int mode)
>  {
> -	if (fatal_signal_pending(current))
> -		return -ERESTARTSYS;
>  	freezable_schedule_unsafe();
> +	if (signal_pending_state(mode, current))
> +		return -ERESTARTSYS;
>  	return 0;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
