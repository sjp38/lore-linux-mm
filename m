Subject: Re: [PATCH][V7]make get_user_pages interruptible
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
References: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 03 Dec 2008 10:03:40 -0500
Message-Id: <1228316620.6693.34.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-12-02 at 21:17 -0800, Ying Han wrote:
> From: Ying Han <yinghan@google.com>
> 
> make get_user_pages interruptible
> The initial implementation of checking TIF_MEMDIE covers the cases of OOM
> killing. If the process has been OOM killed, the TIF_MEMDIE is set and it
> return immediately. This patch includes:
> 
> 1. add the case that the SIGKILL is sent by user processes. The process can
> try to get_user_pages() unlimited memory even if a user process has sent a
> SIGKILL to it(maybe a monitor find the process exceed its memory limit and
> try to kill it). In the old implementation, the SIGKILL won't be handled
> until the get_user_pages() returns.
> 
> 2. change the return value to be ERESTARTSYS. It makes no sense to return
> ENOMEM if the get_user_pages returned by getting a SIGKILL signal.
> Considering the general convention for a system call interrupted by a
> signal is ERESTARTNOSYS, so the current return value is consistant to that.
> 
> Signed-off-by:	Paul Menage <menage@google.com>
> Signed-off-by:	Ying Han <yinghan@google.com>
> 
<snip>

Couple of things:

* I tested your previous patch [that was "just too ugly to live
with" :)] overnight with my swap/unevictable-lru/mlocked-pages stress
test on both x86_64 and ia64.  I replaced the two patches in mmotm
081201 with the "ugly one".  Both systems ran for ~16:40 [hh:mm] without
error, before I stopped the tests.

* Your patch--bailing out of get_user_pages() when current has SIGKILL
pending--breaks munlock on exit when SIGKILL is pending.  This results
in freeing of mlocked pages [not so bad, I guess] and possibly leaving,
e.g., shared library pages mlocked and unevictable after last VM_LOCKED
vma is removed.  I noticed this because SIGKILL is how the test harness
kills off the running tests.  I have a patch that fixes this.  The
overnight runs included this patch.  I'll post it after rebasing and a
quick retest [he says optimistically] on mmotm-081203.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
