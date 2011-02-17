Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7E68D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 03:13:49 -0500 (EST)
Message-Id: <201102170813.p1H8DhOJ083597@www262.sakura.ne.jp>
Subject: Re: [2.6.32 ubuntu] I/O hang at start_this_handle
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Feb 2011 17:13:43 +0900
References: <201102080526.p185Q0mL034909@www262.sakura.ne.jp> <20110215151633.GG17313@quack.suse.cz> <201102160652.BDI60469.JOVFSFOHLQOFtM@I-love.SAKURA.ne.jp> <20110216155317.GD5592@quack.suse.cz>
In-Reply-To: <20110216155317.GD5592@quack.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jack@suse.cz
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Jan Kara wrote:
> You can verify this by looking at disassembly of start_this_handle() in your
> kernel and finding out where offset 0x22d is in the function...

I confirmed that the function

  [<c02c7ead>] start_this_handle+0x22d/0x390

is the one in fs/jbd/transaction.o .

c02c7ea4:       eb 07                   jmp    c02c7ead <start_this_handle+0x22d>
c02c7ea6:       66 90                   xchg   %ax,%ax
c02c7ea8:       e8 93 a6 2e 00          call   c05b2540 <schedule>
c02c7ead:       89 d8                   mov    %ebx,%eax
c02c7eaf:       b9 02 00 00 00          mov    $0x2,%ecx
c02c7eb4:       8d 55 e0                lea    -0x20(%ebp),%edx
c02c7eb7:       e8 d4 82 ea ff          call   c0170190 <prepare_to_wait>
c02c7ebc:       8b 46 18                mov    0x18(%esi),%eax
c02c7ebf:       85 c0                   test   %eax,%eax
c02c7ec1:       75 e5                   jne    c02c7ea8 <start_this_handle+0x228>
c02c7ec3:       8b 45 cc                mov    -0x34(%ebp),%eax
c02c7ec6:       8d 55 e0                lea    -0x20(%ebp),%edx
c02c7ec9:       e8 e2 81 ea ff          call   c01700b0 <finish_wait>
c02c7ece:       e9 08 fe ff ff          jmp    c02c7cdb <start_this_handle+0x5b>

The location in that function is

        /* Wait on the journal's transaction barrier if necessary */
        if (journal->j_barrier_count) {
                spin_unlock(&journal->j_state_lock);
                wait_event(journal->j_wait_transaction_locked,
                                journal->j_barrier_count == 0);
                goto repeat;
        }

. (Disassembly with mixed code attached at the bottom.)

> But in this case - does the process (sh) eventually resume or is it stuck
> forever?

I waited for a few hours but the process did not resume. Thus, I gave up.

Regards.
----------
00000940 <start_this_handle>:
 * to begin.  Attach the handle to a transaction and set up the
 * transaction's buffer credits.
 */

static int start_this_handle(journal_t *journal, handle_t *handle)
{
     940:	55                   	push   %ebp
     941:	89 e5                	mov    %esp,%ebp
     943:	57                   	push   %edi
     944:	56                   	push   %esi
     945:	53                   	push   %ebx
     946:	83 ec 48             	sub    $0x48,%esp
     949:	e8 fc ff ff ff       	call   94a <start_this_handle+0xa>
     94e:	89 c6                	mov    %eax,%esi
     950:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	transaction_t *transaction;
	int needed;
	int nblocks = handle->h_buffer_credits;
     953:	8b 42 04             	mov    0x4(%edx),%eax
     956:	89 45 d8             	mov    %eax,-0x28(%ebp)
	transaction_t *new_transaction = NULL;
	int ret = 0;

	if (nblocks > journal->j_max_transaction_buffers) {
     959:	8b 86 ec 00 00 00    	mov    0xec(%esi),%eax
     95f:	39 45 d8             	cmp    %eax,-0x28(%ebp)
     962:	0f 8f ed 02 00 00    	jg     c55 <start_this_handle+0x315>

	/*
	 * We need to hold j_state_lock until t_updates has been incremented,
	 * for proper journal barrier handling
	 */
	spin_lock(&journal->j_state_lock);
     968:	8d 46 14             	lea    0x14(%esi),%eax
	}

	/* Wait on the journal's transaction barrier if necessary */
	if (journal->j_barrier_count) {
		spin_unlock(&journal->j_state_lock);
		wait_event(journal->j_wait_transaction_locked,
     96b:	8d 56 3c             	lea    0x3c(%esi),%edx
	spin_lock_init(&transaction->t_handle_lock);

	/* Set up the commit timer for the new transaction. */
	journal->j_commit_timer.expires =
				round_jiffies_up(transaction->t_expires);
	add_timer(&journal->j_commit_timer);
     96e:	8d 8e f4 00 00 00    	lea    0xf4(%esi),%ecx

	/*
	 * We need to hold j_state_lock until t_updates has been incremented,
	 * for proper journal barrier handling
	 */
	spin_lock(&journal->j_state_lock);
     974:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	}

	/* Wait on the journal's transaction barrier if necessary */
	if (journal->j_barrier_count) {
		spin_unlock(&journal->j_state_lock);
		wait_event(journal->j_wait_transaction_locked,
     977:	89 55 cc             	mov    %edx,-0x34(%ebp)
     97a:	64 a1 00 00 00 00    	mov    %fs:0x0,%eax
	spin_lock_init(&transaction->t_handle_lock);

	/* Set up the commit timer for the new transaction. */
	journal->j_commit_timer.expires =
				round_jiffies_up(transaction->t_expires);
	add_timer(&journal->j_commit_timer);
     980:	89 4d d0             	mov    %ecx,-0x30(%ebp)
     983:	89 45 c8             	mov    %eax,-0x38(%ebp)
     986:	89 45 c0             	mov    %eax,-0x40(%ebp)
		ret = -ENOSPC;
		goto out;
	}

alloc_transaction:
	if (!journal->j_running_transaction) {
     989:	8b 7e 30             	mov    0x30(%esi),%edi
     98c:	85 ff                	test   %edi,%edi
     98e:	0f 84 85 02 00 00    	je     c19 <start_this_handle+0x2d9>
     994:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)

	/*
	 * We need to hold j_state_lock until t_updates has been incremented,
	 * for proper journal barrier handling
	 */
	spin_lock(&journal->j_state_lock);
     99b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     99e:	e8 fc ff ff ff       	call   99f <start_this_handle+0x5f>
 * transactions.
 */

static inline int is_journal_aborted(journal_t *journal)
{
	return journal->j_flags & JFS_ABORT;
     9a3:	8b 06                	mov    (%esi),%eax
repeat_locked:
	if (is_journal_aborted(journal) ||
     9a5:	a8 02                	test   $0x2,%al
     9a7:	74 66                	je     a0f <start_this_handle+0xcf>
     9a9:	e9 5a 01 00 00       	jmp    b08 <start_this_handle+0x1c8>
     9ae:	66 90                	xchg   %ax,%ax

	/*
	 * If the current transaction is locked down for commit, wait for the
	 * lock to be released.
	 */
	if (transaction->t_state == T_LOCKED) {
     9b0:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
     9b4:	0f 84 fe 00 00 00    	je     ab8 <start_this_handle+0x178>
	/*
	 * If there is not enough space left in the log to write all potential
	 * buffers requested by this operation, we need to stall pending a log
	 * checkpoint to free some more log space.
	 */
	spin_lock(&transaction->t_handle_lock);
     9ba:	8d 7b 3c             	lea    0x3c(%ebx),%edi
     9bd:	89 f8                	mov    %edi,%eax
     9bf:	90                   	nop
     9c0:	e8 fc ff ff ff       	call   9c1 <start_this_handle+0x81>
	needed = transaction->t_outstanding_credits + nblocks;
     9c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
     9c8:	03 43 44             	add    0x44(%ebx),%eax

	if (needed > journal->j_max_transaction_buffers) {
     9cb:	3b 86 ec 00 00 00    	cmp    0xec(%esi),%eax
     9d1:	0f 8f c1 01 00 00    	jg     b98 <start_this_handle+0x258>
	 * committing_transaction->t_outstanding_credits plus "enough" for
	 * the log control blocks.
	 * Also, this test is inconsitent with the matching one in
	 * journal_extend().
	 */
	if (__log_space_left(journal) < jbd_space_needed(journal)) {
     9d7:	89 f0                	mov    %esi,%eax
     9d9:	e8 fc ff ff ff       	call   9da <start_this_handle+0x9a>
 * before a new transaction may be started.  Must be called under j_state_lock.
 */
static inline int jbd_space_needed(journal_t *journal)
{
	int nblocks = journal->j_max_transaction_buffers;
	if (journal->j_committing_transaction)
     9de:	8b 4e 34             	mov    0x34(%esi),%ecx
 * Return the minimum number of blocks which must be free in the journal
 * before a new transaction may be started.  Must be called under j_state_lock.
 */
static inline int jbd_space_needed(journal_t *journal)
{
	int nblocks = journal->j_max_transaction_buffers;
     9e1:	8b 96 ec 00 00 00    	mov    0xec(%esi),%edx
	if (journal->j_committing_transaction)
     9e7:	85 c9                	test   %ecx,%ecx
     9e9:	74 03                	je     9ee <start_this_handle+0xae>
		nblocks += journal->j_committing_transaction->
     9eb:	03 51 44             	add    0x44(%ecx),%edx
     9ee:	39 d0                	cmp    %edx,%eax
     9f0:	0f 8d ea 01 00 00    	jge    be0 <start_this_handle+0x2a0>
     9f6:	89 f8                	mov    %edi,%eax
     9f8:	ff 15 14 00 00 00    	call   *0x14
		jbd_debug(2, "Handle %p waiting for checkpoint...\n", handle);
		spin_unlock(&transaction->t_handle_lock);
		__log_wait_for_space(journal);
     9fe:	89 f0                	mov    %esi,%eax
     a00:	e8 fc ff ff ff       	call   a01 <start_this_handle+0xc1>
 * transactions.
 */

static inline int is_journal_aborted(journal_t *journal)
{
	return journal->j_flags & JFS_ABORT;
     a05:	8b 06                	mov    (%esi),%eax
	 * We need to hold j_state_lock until t_updates has been incremented,
	 * for proper journal barrier handling
	 */
	spin_lock(&journal->j_state_lock);
repeat_locked:
	if (is_journal_aborted(journal) ||
     a07:	a8 02                	test   $0x2,%al
     a09:	0f 85 f9 00 00 00    	jne    b08 <start_this_handle+0x1c8>
	    (journal->j_errno != 0 && !(journal->j_flags & JFS_ACK_ERR))) {
     a0f:	8b 5e 04             	mov    0x4(%esi),%ebx
     a12:	85 db                	test   %ebx,%ebx
     a14:	74 08                	je     a1e <start_this_handle+0xde>
	 * We need to hold j_state_lock until t_updates has been incremented,
	 * for proper journal barrier handling
	 */
	spin_lock(&journal->j_state_lock);
repeat_locked:
	if (is_journal_aborted(journal) ||
     a16:	a8 04                	test   $0x4,%al
     a18:	0f 84 ea 00 00 00    	je     b08 <start_this_handle+0x1c8>
		ret = -EROFS;
		goto out;
	}

	/* Wait on the journal's transaction barrier if necessary */
	if (journal->j_barrier_count) {
     a1e:	8b 4e 18             	mov    0x18(%esi),%ecx
     a21:	85 c9                	test   %ecx,%ecx
     a23:	0f 85 07 01 00 00    	jne    b30 <start_this_handle+0x1f0>
		wait_event(journal->j_wait_transaction_locked,
				journal->j_barrier_count == 0);
		goto repeat;
	}

	if (!journal->j_running_transaction) {
     a29:	8b 5e 30             	mov    0x30(%esi),%ebx
     a2c:	85 db                	test   %ebx,%ebx
     a2e:	75 80                	jne    9b0 <start_this_handle+0x70>
		if (!new_transaction) {
     a30:	8b 7d dc             	mov    -0x24(%ebp),%edi
     a33:	85 ff                	test   %edi,%edi
     a35:	0f 84 d0 01 00 00    	je     c0b <start_this_handle+0x2cb>
 */

static transaction_t *
get_transaction(journal_t *journal, transaction_t *transaction)
{
	transaction->t_journal = journal;
     a3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
     a3e:	89 32                	mov    %esi,(%edx)
	transaction->t_state = T_RUNNING;
     a40:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	transaction->t_start_time = ktime_get();
     a47:	e8 fc ff ff ff       	call   a48 <start_this_handle+0x108>
     a4c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
     a4f:	89 41 54             	mov    %eax,0x54(%ecx)
     a52:	89 51 58             	mov    %edx,0x58(%ecx)
	transaction->t_tid = journal->j_transaction_sequence++;
     a55:	8b 86 cc 00 00 00    	mov    0xcc(%esi),%eax
     a5b:	89 41 04             	mov    %eax,0x4(%ecx)
     a5e:	83 c0 01             	add    $0x1,%eax
     a61:	89 86 cc 00 00 00    	mov    %eax,0xcc(%esi)
	transaction->t_expires = jiffies + journal->j_commit_interval;
     a67:	a1 00 00 00 00       	mov    0x0,%eax
     a6c:	03 86 f0 00 00 00    	add    0xf0(%esi),%eax
	spin_lock_init(&transaction->t_handle_lock);
     a72:	c7 41 3c 00 00 00 00 	movl   $0x0,0x3c(%ecx)
{
	transaction->t_journal = journal;
	transaction->t_state = T_RUNNING;
	transaction->t_start_time = ktime_get();
	transaction->t_tid = journal->j_transaction_sequence++;
	transaction->t_expires = jiffies + journal->j_commit_interval;
     a79:	89 41 50             	mov    %eax,0x50(%ecx)
	spin_lock_init(&transaction->t_handle_lock);

	/* Set up the commit timer for the new transaction. */
	journal->j_commit_timer.expires =
				round_jiffies_up(transaction->t_expires);
     a7c:	e8 fc ff ff ff       	call   a7d <start_this_handle+0x13d>
	transaction->t_tid = journal->j_transaction_sequence++;
	transaction->t_expires = jiffies + journal->j_commit_interval;
	spin_lock_init(&transaction->t_handle_lock);

	/* Set up the commit timer for the new transaction. */
	journal->j_commit_timer.expires =
     a81:	89 86 fc 00 00 00    	mov    %eax,0xfc(%esi)
				round_jiffies_up(transaction->t_expires);
	add_timer(&journal->j_commit_timer);
     a87:	8b 45 d0             	mov    -0x30(%ebp),%eax
     a8a:	e8 fc ff ff ff       	call   a8b <start_this_handle+0x14b>

	J_ASSERT(journal->j_running_transaction == NULL);
     a8f:	8b 5e 30             	mov    0x30(%esi),%ebx
     a92:	85 db                	test   %ebx,%ebx
     a94:	0f 85 b7 01 00 00    	jne    c51 <start_this_handle+0x311>
	journal->j_running_transaction = transaction;
     a9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
     a9d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
     aa4:	89 c3                	mov    %eax,%ebx
     aa6:	89 46 30             	mov    %eax,0x30(%esi)

	/*
	 * If the current transaction is locked down for commit, wait for the
	 * lock to be released.
	 */
	if (transaction->t_state == T_LOCKED) {
     aa9:	83 7b 08 01          	cmpl   $0x1,0x8(%ebx)
     aad:	0f 85 07 ff ff ff    	jne    9ba <start_this_handle+0x7a>
     ab3:	90                   	nop
     ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
		DEFINE_WAIT(wait);
     ab8:	8b 55 c0             	mov    -0x40(%ebp),%edx
     abb:	8d 4d ec             	lea    -0x14(%ebp),%ecx

		prepare_to_wait(&journal->j_wait_transaction_locked,
     abe:	8b 45 cc             	mov    -0x34(%ebp),%eax
	/*
	 * If the current transaction is locked down for commit, wait for the
	 * lock to be released.
	 */
	if (transaction->t_state == T_LOCKED) {
		DEFINE_WAIT(wait);
     ac1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
     ac4:	89 4d f0             	mov    %ecx,-0x10(%ebp)

		prepare_to_wait(&journal->j_wait_transaction_locked,
     ac7:	b9 02 00 00 00       	mov    $0x2,%ecx
	/*
	 * If the current transaction is locked down for commit, wait for the
	 * lock to be released.
	 */
	if (transaction->t_state == T_LOCKED) {
		DEFINE_WAIT(wait);
     acc:	89 55 e4             	mov    %edx,-0x1c(%ebp)

		prepare_to_wait(&journal->j_wait_transaction_locked,
     acf:	8d 55 e0             	lea    -0x20(%ebp),%edx
	/*
	 * If the current transaction is locked down for commit, wait for the
	 * lock to be released.
	 */
	if (transaction->t_state == T_LOCKED) {
		DEFINE_WAIT(wait);
     ad2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
     ad9:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

		prepare_to_wait(&journal->j_wait_transaction_locked,
     ae0:	e8 fc ff ff ff       	call   ae1 <start_this_handle+0x1a1>
     ae5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     ae8:	ff 15 14 00 00 00    	call   *0x14
		spin_unlock(&transaction->t_handle_lock);
		prepare_to_wait(&journal->j_wait_transaction_locked, &wait,
				TASK_UNINTERRUPTIBLE);
		__log_start_commit(journal, transaction->t_tid);
		spin_unlock(&journal->j_state_lock);
		schedule();
     aee:	e8 fc ff ff ff       	call   aef <start_this_handle+0x1af>
		finish_wait(&journal->j_wait_transaction_locked, &wait);
     af3:	8b 45 cc             	mov    -0x34(%ebp),%eax
     af6:	8d 55 e0             	lea    -0x20(%ebp),%edx
     af9:	e8 fc ff ff ff       	call   afa <start_this_handle+0x1ba>
     afe:	e9 98 fe ff ff       	jmp    99b <start_this_handle+0x5b>
     b03:	90                   	nop
     b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
     b08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     b0b:	ff 15 14 00 00 00    	call   *0x14
     b11:	bb e2 ff ff ff       	mov    $0xffffffe2,%ebx
	spin_unlock(&transaction->t_handle_lock);
	spin_unlock(&journal->j_state_lock);

	lock_map_acquire(&handle->h_lockdep_map);
out:
	if (unlikely(new_transaction))		/* It's usually NULL */
     b16:	8b 4d dc             	mov    -0x24(%ebp),%ecx
     b19:	85 c9                	test   %ecx,%ecx
     b1b:	0f 85 66 01 00 00    	jne    c87 <start_this_handle+0x347>
		kfree(new_transaction);
	return ret;
}
     b21:	83 c4 48             	add    $0x48,%esp
     b24:	89 d8                	mov    %ebx,%eax
     b26:	5b                   	pop    %ebx
     b27:	5e                   	pop    %esi
     b28:	5f                   	pop    %edi
     b29:	5d                   	pop    %ebp
     b2a:	c3                   	ret    
     b2b:	90                   	nop
     b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
     b30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     b33:	ff 15 14 00 00 00    	call   *0x14
	}

	/* Wait on the journal's transaction barrier if necessary */
	if (journal->j_barrier_count) {
		spin_unlock(&journal->j_state_lock);
		wait_event(journal->j_wait_transaction_locked,
     b39:	8b 56 18             	mov    0x18(%esi),%edx
     b3c:	85 d2                	test   %edx,%edx
     b3e:	0f 84 57 fe ff ff    	je     99b <start_this_handle+0x5b>
     b44:	8b 55 c8             	mov    -0x38(%ebp),%edx
     b47:	8d 4d ec             	lea    -0x14(%ebp),%ecx
     b4a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
     b51:	8b 5d cc             	mov    -0x34(%ebp),%ebx
     b54:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
     b5b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
     b5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
     b61:	89 4d f0             	mov    %ecx,-0x10(%ebp)
     b64:	eb 07                	jmp    b6d <start_this_handle+0x22d>
     b66:	66 90                	xchg   %ax,%ax
     b68:	e8 fc ff ff ff       	call   b69 <start_this_handle+0x229>
     b6d:	89 d8                	mov    %ebx,%eax
     b6f:	b9 02 00 00 00       	mov    $0x2,%ecx
     b74:	8d 55 e0             	lea    -0x20(%ebp),%edx
     b77:	e8 fc ff ff ff       	call   b78 <start_this_handle+0x238>
     b7c:	8b 46 18             	mov    0x18(%esi),%eax
     b7f:	85 c0                	test   %eax,%eax
     b81:	75 e5                	jne    b68 <start_this_handle+0x228>
		prepare_to_wait(&journal->j_wait_transaction_locked, &wait,
				TASK_UNINTERRUPTIBLE);
		__log_start_commit(journal, transaction->t_tid);
		spin_unlock(&journal->j_state_lock);
		schedule();
		finish_wait(&journal->j_wait_transaction_locked, &wait);
     b83:	8b 45 cc             	mov    -0x34(%ebp),%eax
     b86:	8d 55 e0             	lea    -0x20(%ebp),%edx
     b89:	e8 fc ff ff ff       	call   b8a <start_this_handle+0x24a>
     b8e:	e9 08 fe ff ff       	jmp    99b <start_this_handle+0x5b>
     b93:	90                   	nop
     b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
		/*
		 * If the current transaction is already too large, then start
		 * to commit it: we can then go back and attach this handle to
		 * a new transaction.
		 */
		DEFINE_WAIT(wait);
     b98:	8b 55 c8             	mov    -0x38(%ebp),%edx
     b9b:	8d 4d ec             	lea    -0x14(%ebp),%ecx
     b9e:	89 f8                	mov    %edi,%eax
     ba0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
     ba7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
     bae:	89 4d ec             	mov    %ecx,-0x14(%ebp)
     bb1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
     bb4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
     bb7:	ff 15 14 00 00 00    	call   *0x14

		jbd_debug(2, "Handle %p starting new commit...\n", handle);
		spin_unlock(&transaction->t_handle_lock);
		prepare_to_wait(&journal->j_wait_transaction_locked, &wait,
     bbd:	8b 45 cc             	mov    -0x34(%ebp),%eax
     bc0:	8d 55 e0             	lea    -0x20(%ebp),%edx
     bc3:	b9 02 00 00 00       	mov    $0x2,%ecx
     bc8:	e8 fc ff ff ff       	call   bc9 <start_this_handle+0x289>
				TASK_UNINTERRUPTIBLE);
		__log_start_commit(journal, transaction->t_tid);
     bcd:	8b 53 04             	mov    0x4(%ebx),%edx
     bd0:	89 f0                	mov    %esi,%eax
     bd2:	e8 fc ff ff ff       	call   bd3 <start_this_handle+0x293>
     bd7:	e9 09 ff ff ff       	jmp    ae5 <start_this_handle+0x1a5>
     bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	}

	/* OK, account for the buffers that this operation expects to
	 * use and add the handle to the running transaction. */

	handle->h_transaction = transaction;
     be0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
     be3:	89 f8                	mov    %edi,%eax
     be5:	89 1a                	mov    %ebx,(%edx)
	transaction->t_outstanding_credits += nblocks;
     be7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
     bea:	01 4b 44             	add    %ecx,0x44(%ebx)
	transaction->t_updates++;
     bed:	83 43 40 01          	addl   $0x1,0x40(%ebx)
	transaction->t_handle_count++;
     bf1:	83 43 5c 01          	addl   $0x1,0x5c(%ebx)
     bf5:	ff 15 14 00 00 00    	call   *0x14
     bfb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     bfe:	ff 15 14 00 00 00    	call   *0x14
     c04:	31 db                	xor    %ebx,%ebx
     c06:	e9 0b ff ff ff       	jmp    b16 <start_this_handle+0x1d6>
     c0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     c0e:	ff 15 14 00 00 00    	call   *0x14
     c14:	e9 70 fd ff ff       	jmp    989 <start_this_handle+0x49>
extern void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags);
#else
static __always_inline void *
kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
{
	return kmem_cache_alloc(s, gfpflags);
     c19:	ba 50 88 00 00       	mov    $0x8850,%edx
     c1e:	b8 7c 04 00 00       	mov    $0x47c,%eax
     c23:	e8 fc ff ff ff       	call   c24 <start_this_handle+0x2e4>
			if (!s)
				return ZERO_SIZE_PTR;

			ret = kmem_cache_alloc_notrace(s, flags);

			trace_kmalloc(_THIS_IP_, ret, size, s->size, flags);
     c28:	8b 15 80 04 00 00    	mov    0x480,%edx
	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"}		\
	) : "GFP_NOWAIT"

TRACE_EVENT(kmalloc,
     c2e:	83 3d 04 00 00 00 00 	cmpl   $0x0,0x4
     c35:	89 55 bc             	mov    %edx,-0x44(%ebp)
extern void *kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags);
#else
static __always_inline void *
kmem_cache_alloc_notrace(struct kmem_cache *s, gfp_t gfpflags)
{
	return kmem_cache_alloc(s, gfpflags);
     c38:	89 45 dc             	mov    %eax,-0x24(%ebp)
     c3b:	75 58                	jne    c95 <start_this_handle+0x355>

alloc_transaction:
	if (!journal->j_running_transaction) {
		new_transaction = kzalloc(sizeof(*new_transaction),
						GFP_NOFS|__GFP_NOFAIL);
		if (!new_transaction) {
     c3d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
     c41:	0f 85 54 fd ff ff    	jne    99b <start_this_handle+0x5b>
	spin_unlock(&journal->j_state_lock);

	lock_map_acquire(&handle->h_lockdep_map);
out:
	if (unlikely(new_transaction))		/* It's usually NULL */
		kfree(new_transaction);
     c47:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
     c4c:	e9 d0 fe ff ff       	jmp    b21 <start_this_handle+0x1e1>
	/* Set up the commit timer for the new transaction. */
	journal->j_commit_timer.expires =
				round_jiffies_up(transaction->t_expires);
	add_timer(&journal->j_commit_timer);

	J_ASSERT(journal->j_running_transaction == NULL);
     c51:	0f 0b                	ud2a   
     c53:	eb fe                	jmp    c53 <start_this_handle+0x313>
	int nblocks = handle->h_buffer_credits;
	transaction_t *new_transaction = NULL;
	int ret = 0;

	if (nblocks > journal->j_max_transaction_buffers) {
		printk(KERN_ERR "JBD: %s wants too many credits (%d > %d)\n",
     c55:	8b 4d d8             	mov    -0x28(%ebp),%ecx
     c58:	bb e4 ff ff ff       	mov    $0xffffffe4,%ebx
     c5d:	64 8b 15 00 00 00 00 	mov    %fs:0x0,%edx
     c64:	89 44 24 0c          	mov    %eax,0xc(%esp)
     c68:	8d 82 0c 03 00 00    	lea    0x30c(%edx),%eax
     c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
     c72:	89 4c 24 08          	mov    %ecx,0x8(%esp)
     c76:	c7 04 24 84 00 00 00 	movl   $0x84,(%esp)
     c7d:	e8 fc ff ff ff       	call   c7e <start_this_handle+0x33e>
		       current->comm, nblocks,
		       journal->j_max_transaction_buffers);
		ret = -ENOSPC;
		goto out;
     c82:	e9 9a fe ff ff       	jmp    b21 <start_this_handle+0x1e1>
	spin_unlock(&journal->j_state_lock);

	lock_map_acquire(&handle->h_lockdep_map);
out:
	if (unlikely(new_transaction))		/* It's usually NULL */
		kfree(new_transaction);
     c87:	8b 45 dc             	mov    -0x24(%ebp),%eax
     c8a:	e8 fc ff ff ff       	call   c8b <start_this_handle+0x34b>
     c8f:	90                   	nop
     c90:	e9 8c fe ff ff       	jmp    b21 <start_this_handle+0x1e1>
     c95:	8b 1d 10 00 00 00    	mov    0x10,%ebx
     c9b:	85 db                	test   %ebx,%ebx
     c9d:	74 9e                	je     c3d <start_this_handle+0x2fd>
     c9f:	8b 3b                	mov    (%ebx),%edi
     ca1:	8b 4d bc             	mov    -0x44(%ebp),%ecx
     ca4:	83 c3 04             	add    $0x4,%ebx
     ca7:	b8 19 0c 00 00       	mov    $0xc19,%eax
     cac:	8b 55 dc             	mov    -0x24(%ebp),%edx
     caf:	c7 44 24 04 50 88 00 	movl   $0x8850,0x4(%esp)
     cb6:	00 
     cb7:	89 0c 24             	mov    %ecx,(%esp)
     cba:	b9 64 00 00 00       	mov    $0x64,%ecx
     cbf:	ff d7                	call   *%edi
     cc1:	8b 3b                	mov    (%ebx),%edi
     cc3:	85 ff                	test   %edi,%edi
     cc5:	75 da                	jne    ca1 <start_this_handle+0x361>
     cc7:	e9 71 ff ff ff       	jmp    c3d <start_this_handle+0x2fd>
     ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
