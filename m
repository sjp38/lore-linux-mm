Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 419586B002C
	for <linux-mm@kvack.org>; Sat, 15 Oct 2011 15:05:00 -0400 (EDT)
Date: Sat, 15 Oct 2011 21:00:37 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/X] uprobes: write_opcode: the new page needs PG_uptodate
Message-ID: <20111015190037.GB30243@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111015190007.GA30243@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

write_opcode()->__replace_page() installs the new anonymous page,
this new_page is PageSwapBacked() and it can be swapped out.

However it forgets to do SetPageUptodate(), fix write_opcode().

For example, this is needed if do_swap_page() finds that orginial
page in the the swap cache (and doesn't try to read it back), in
this case it returns VM_FAULT_SIGBUS.
---
 kernel/uprobes.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 3928bcc..52b20c8 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -200,6 +200,8 @@ static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
 		goto put_out;
 	}
 
+	__SetPageUptodate(new_page);
+
 	/*
 	 * lock page will serialize against do_wp_page()'s
 	 * PageAnon() handling
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
