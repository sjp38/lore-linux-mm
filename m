Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 02 of 11] get_task_mm
Message-Id: <c5badbefeee07518d9d1.1210170952@duo.random>
In-Reply-To: <patchbomb.1210170950@duo.random>
Date: Wed, 07 May 2008 16:35:52 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1210115127 -7200
# Node ID c5badbefeee07518d9d1acca13e94c981420317c
# Parent  e20917dcc8284b6a07cfcced13dda4cbca850a9c
get_task_mm

get_task_mm should not succeed if mmput() is running and has reduced
the mm_users count to zero. This can occur if a processor follows
a tasks pointer to an mm struct because that pointer is only cleared
after the mmput().

If get_task_mm() succeeds after mmput() reduced the mm_users to zero then
we have the lovely situation that one portion of the kernel is doing
all the teardown work for an mm while another portion is happily using
it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -465,7 +465,8 @@ struct mm_struct *get_task_mm(struct tas
 		if (task->flags & PF_BORROWED_MM)
 			mm = NULL;
 		else
-			atomic_inc(&mm->mm_users);
+			if (!atomic_inc_not_zero(&mm->mm_users))
+				mm = NULL;
 	}
 	task_unlock(task);
 	return mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
