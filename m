Date: Fri, 4 May 2007 09:14:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: incoming
Message-Id: <20070504091434.106ad04d.akpm@linux-foundation.org>
In-Reply-To: <20070504133728.GA19460@kroah.com>
References: <20070502150252.7ddf67ac.akpm@linux-foundation.org>
	<20070504133728.GA19460@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Roland McGrath <roland@redhat.com>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007 06:37:28 -0700 Greg KH <greg@kroah.com> wrote:

> On Wed, May 02, 2007 at 03:02:52PM -0700, Andrew Morton wrote:
> > - One little security patch
> 
> Care to cc: linux-stable with it so we can do a new 2.6.21 release with
> it if needed?
> 

Ah.  The patch affects security code, but it doesn't actually address any
insecurity.  I didn't think it was needed for -stable?



From: Roland McGrath <roland@redhat.com>

wait* syscalls return -ECHILD even when an individual PID of a live child
was requested explicitly, when security_task_wait denies the operation. 
This means that something like a broken SELinux policy can produce an
unexpected failure that looks just like a bug with wait or ptrace or
something.

This patch makes do_wait return -EACCES (or other appropriate error returned
from security_task_wait() instead of -ECHILD if some children were ruled out
solely because security_task_wait failed.

[jmorris@namei.org: switch error code to EACCES]
Signed-off-by: Roland McGrath <roland@redhat.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Chris Wright <chrisw@sous-sol.org>
Cc: James Morris <jmorris@namei.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/exit.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff -puN kernel/exit.c~return-eperm-not-echild-on-security_task_wait-failure kernel/exit.c
--- a/kernel/exit.c~return-eperm-not-echild-on-security_task_wait-failure
+++ a/kernel/exit.c
@@ -1033,6 +1033,8 @@ asmlinkage void sys_exit_group(int error
 
 static int eligible_child(pid_t pid, int options, struct task_struct *p)
 {
+	int err;
+
 	if (pid > 0) {
 		if (p->pid != pid)
 			return 0;
@@ -1066,8 +1068,9 @@ static int eligible_child(pid_t pid, int
 	if (delay_group_leader(p))
 		return 2;
 
-	if (security_task_wait(p))
-		return 0;
+	err = security_task_wait(p);
+	if (err)
+		return err;
 
 	return 1;
 }
@@ -1449,6 +1452,7 @@ static long do_wait(pid_t pid, int optio
 	DECLARE_WAITQUEUE(wait, current);
 	struct task_struct *tsk;
 	int flag, retval;
+	int allowed, denied;
 
 	add_wait_queue(&current->signal->wait_chldexit,&wait);
 repeat:
@@ -1457,6 +1461,7 @@ repeat:
 	 * match our criteria, even if we are not able to reap it yet.
 	 */
 	flag = 0;
+	allowed = denied = 0;
 	current->state = TASK_INTERRUPTIBLE;
 	read_lock(&tasklist_lock);
 	tsk = current;
@@ -1472,6 +1477,12 @@ repeat:
 			if (!ret)
 				continue;
 
+			if (unlikely(ret < 0)) {
+				denied = ret;
+				continue;
+			}
+			allowed = 1;
+
 			switch (p->state) {
 			case TASK_TRACED:
 				/*
@@ -1570,6 +1581,8 @@ check_continued:
 		goto repeat;
 	}
 	retval = -ECHILD;
+	if (unlikely(denied) && !allowed)
+		retval = denied;
 end:
 	current->state = TASK_RUNNING;
 	remove_wait_queue(&current->signal->wait_chldexit,&wait);
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
