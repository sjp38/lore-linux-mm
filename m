Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1E6418D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 16:53:03 -0500 (EST)
Subject: Re: [2.6.32 ubuntu] I/O hang at start_this_handle
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201102080526.p185Q0mL034909@www262.sakura.ne.jp>
	<20110215151633.GG17313@quack.suse.cz>
In-Reply-To: <20110215151633.GG17313@quack.suse.cz>
Message-Id: <201102160652.BDI60469.JOVFSFOHLQOFtM@I-love.SAKURA.ne.jp>
Date: Wed, 16 Feb 2011 06:52:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jack@suse.cz
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Jan Kara wrote:
>   Ext3 looks innocent here. That is a standard call path for open(..,
> O_TRUNC). But apparently something broke in SLUB allocator. Adding proper
> list to CC...

Thanks.

Both fs/jbd/transaction.c and fs/jbd2/transaction.c provide start_this_handle()
and I don't know which one was called.

But

	if (!journal->j_running_transaction) {
		new_transaction = kzalloc(sizeof(*new_transaction),
					  GFP_NOFS|__GFP_NOFAIL);
		if (!new_transaction) {
			ret = -ENOMEM;
			goto out;
		}
	}

does kzalloc(GFP_NOFS|__GFP_NOFAIL) causes /proc/$PID/status to show

  State:  D (disk sleep)

line? I thought this is either

	if (transaction->t_state == T_LOCKED) {
		DEFINE_WAIT(wait);

		prepare_to_wait(&journal->j_wait_transaction_locked,
				&wait, TASK_UNINTERRUPTIBLE);
		spin_unlock(&journal->j_state_lock);
		schedule();
		finish_wait(&journal->j_wait_transaction_locked, &wait);
		goto repeat;
	}

or

	if (needed > journal->j_max_transaction_buffers) {
		/*
		 * If the current transaction is already too large, then start
		 * to commit it: we can then go back and attach this handle to
		 * a new transaction.
		 */
		DEFINE_WAIT(wait);

		jbd_debug(2, "Handle %p starting new commit...\n", handle);
		spin_unlock(&transaction->t_handle_lock);
		prepare_to_wait(&journal->j_wait_transaction_locked, &wait,
				TASK_UNINTERRUPTIBLE);
		__jbd2_log_start_commit(journal, transaction->t_tid);
		spin_unlock(&journal->j_state_lock);
		schedule();
		finish_wait(&journal->j_wait_transaction_locked, &wait);
		goto repeat;
	}

within start_this_handle().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
