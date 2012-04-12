Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 04D2C6B00EC
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 05:29:40 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <prashanth@linux.vnet.ibm.com>;
	Thu, 12 Apr 2012 03:29:40 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id EB666C40004
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 03:29:36 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3C9TbQr176286
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 03:29:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3C9Taqm023275
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 03:29:37 -0600
Message-ID: <4F86A060.1010604@linux.vnet.ibm.com>
Date: Thu, 12 Apr 2012 14:59:04 +0530
From: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] perf/probe: verify instruction/offset in perf before
 adding a uprobe
References: <20120412085748.23484.53789.stgit@nprashan.in.ibm.com>
In-Reply-To: <20120412085748.23484.53789.stgit@nprashan.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

To verify instruction/offset in perf, before adding a uprobe we
need to use arc/x86/lib/insn.c from perf code. Since perf Makefile
enables -Wswitch-default flag it causes build warnings/failures. This
patch is to address the build warnings in insn.c.


Signed-off-by: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
---

 arch/x86/lib/insn.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/arch/x86/lib/insn.c b/arch/x86/lib/insn.c
index 25feb1a..b9e42f1 100644
--- a/arch/x86/lib/insn.c
+++ b/arch/x86/lib/insn.c
@@ -397,6 +397,8 @@ static void __get_moffset(struct insn *insn)
 		insn->moffset2.value = get_next(int, insn);
 		insn->moffset2.nbytes = 4;
 		break;
+	default:
+		break;
 	}
 	insn->moffset1.got = insn->moffset2.got = 1;

@@ -417,6 +419,8 @@ static void __get_immv32(struct insn *insn)
 		insn->immediate.value = get_next(int, insn);
 		insn->immediate.nbytes = 4;
 		break;
+	default:
+		break;
 	}

 err_out:
@@ -441,6 +445,8 @@ static void __get_immv(struct insn *insn)
 		insn->immediate2.value = get_next(int, insn);
 		insn->immediate2.nbytes = 4;
 		break;
+	default:
+		break;
 	}
 	insn->immediate1.got = insn->immediate2.got = 1;

@@ -463,6 +469,8 @@ static void __get_immptr(struct insn *insn)
 	case 8:
 		/* ptr16:64 is not exist (no segment) */
 		return;
+	default:
+		break;
 	}
 	insn->immediate2.value = get_next(unsigned short, insn);
 	insn->immediate2.nbytes = 2;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
