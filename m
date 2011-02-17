Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4B9DB8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 10:38:52 -0500 (EST)
Date: Thu, 17 Feb 2011 16:38:47 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [2.6.32 ubuntu] I/O hang at start_this_handle
Message-ID: <20110217153847.GE4947@quack.suse.cz>
References: <201102080526.p185Q0mL034909@www262.sakura.ne.jp>
 <20110215151633.GG17313@quack.suse.cz>
 <201102160652.BDI60469.JOVFSFOHLQOFtM@I-love.SAKURA.ne.jp>
 <20110216155317.GD5592@quack.suse.cz>
 <201102170813.p1H8DhOJ083597@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201102170813.p1H8DhOJ083597@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: jack@suse.cz, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

  Hello,

On Thu 17-02-11 17:13:43, Tetsuo Handa wrote:
> Jan Kara wrote:
> > You can verify this by looking at disassembly of start_this_handle() in your
> > kernel and finding out where offset 0x22d is in the function...
> 
> I confirmed that the function
> 
>   [<c02c7ead>] start_this_handle+0x22d/0x390
> 
> is the one in fs/jbd/transaction.o .
> 
> c02c7ea4:       eb 07                   jmp    c02c7ead <start_this_handle+0x22d>
> c02c7ea6:       66 90                   xchg   %ax,%ax
> c02c7ea8:       e8 93 a6 2e 00          call   c05b2540 <schedule>
> c02c7ead:       89 d8                   mov    %ebx,%eax
> c02c7eaf:       b9 02 00 00 00          mov    $0x2,%ecx
> c02c7eb4:       8d 55 e0                lea    -0x20(%ebp),%edx
> c02c7eb7:       e8 d4 82 ea ff          call   c0170190 <prepare_to_wait>
> c02c7ebc:       8b 46 18                mov    0x18(%esi),%eax
> c02c7ebf:       85 c0                   test   %eax,%eax
> c02c7ec1:       75 e5                   jne    c02c7ea8 <start_this_handle+0x228>
> c02c7ec3:       8b 45 cc                mov    -0x34(%ebp),%eax
> c02c7ec6:       8d 55 e0                lea    -0x20(%ebp),%edx
> c02c7ec9:       e8 e2 81 ea ff          call   c01700b0 <finish_wait>
> c02c7ece:       e9 08 fe ff ff          jmp    c02c7cdb <start_this_handle+0x5b>
> 
> The location in that function is
> 
>         /* Wait on the journal's transaction barrier if necessary */
>         if (journal->j_barrier_count) {
>                 spin_unlock(&journal->j_state_lock);
>                 wait_event(journal->j_wait_transaction_locked,
>                                 journal->j_barrier_count == 0);
>                 goto repeat;
>         }
> 
> . (Disassembly with mixed code attached at the bottom.)
  Great, thanks for analysis.

> > But in this case - does the process (sh) eventually resume or is it stuck
> > forever?
> 
> I waited for a few hours but the process did not resume. Thus, I gave up.
OK, so stuck forever ;). Interesting. So we probably missed a wakeup
somehow or j_barrier_count got corrupted. I suppose you are not able to
reproduce the hang, are you?  Looking at the code, it looks safe and I have
no clue how it could happen. So unless you are able to see the issue again
(so that we can gather some more debug information), I'm not able to help...
I'm sorry.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
