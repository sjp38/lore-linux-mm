Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 87F096B0083
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 23:24:25 -0400 (EDT)
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Subject: [PATCH -tip ] x86: Handle failures of getting immediates in
 instruction decoder
Date: Fri, 13 Apr 2012 12:24:27 +0900
Message-ID: <20120413032427.32577.42602.stgit@localhost.localdomain>
In-Reply-To: <4F86A060.1010604@linux.vnet.ibm.com>
References: <4F86A060.1010604@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, yrl.pp-manager.tt@hitachi.comMasami Hiramatsu <masami.hiramatsu.pt@hitachi.com>

Correctly handle failures when getting immediate operands
in x86 instruction decoder. This can be happen if the
instruction is badly longer than maximum length, or
insn->opnd_bytes is manually changed.

This patch also fixes warnings from -Wswitch-default flag.

Reported-by: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
Signed-off-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
---

 arch/x86/lib/insn.c |   53 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 36 insertions(+), 17 deletions(-)

diff --git a/arch/x86/lib/insn.c b/arch/x86/lib/insn.c
index 25feb1a..b1e6c4b 100644
--- a/arch/x86/lib/insn.c
+++ b/arch/x86/lib/insn.c
@@ -379,8 +379,8 @@ err_out:
 	return;
 }
 
-/* Decode moffset16/32/64 */
-static void __get_moffset(struct insn *insn)
+/* Decode moffset16/32/64. Return 0 if failed */
+static int __get_moffset(struct insn *insn)
 {
 	switch (insn->addr_bytes) {
 	case 2:
@@ -397,15 +397,19 @@ static void __get_moffset(struct insn *insn)
 		insn->moffset2.value = get_next(int, insn);
 		insn->moffset2.nbytes = 4;
 		break;
+	default:	/* opnd_bytes must be modified manually */
+		goto err_out;
 	}
 	insn->moffset1.got = insn->moffset2.got = 1;
 
+	return 1;
+
 err_out:
-	return;
+	return 0;
 }
 
-/* Decode imm v32(Iz) */
-static void __get_immv32(struct insn *insn)
+/* Decode imm v32(Iz). Return 0 if failed */
+static int __get_immv32(struct insn *insn)
 {
 	switch (insn->opnd_bytes) {
 	case 2:
@@ -417,14 +421,18 @@ static void __get_immv32(struct insn *insn)
 		insn->immediate.value = get_next(int, insn);
 		insn->immediate.nbytes = 4;
 		break;
+	default:	/* opnd_bytes must be modified manually */
+		goto err_out;
 	}
 
+	return 1;
+
 err_out:
-	return;
+	return 0;
 }
 
-/* Decode imm v64(Iv/Ov) */
-static void __get_immv(struct insn *insn)
+/* Decode imm v64(Iv/Ov), Return 0 if failed */
+static int __get_immv(struct insn *insn)
 {
 	switch (insn->opnd_bytes) {
 	case 2:
@@ -441,15 +449,18 @@ static void __get_immv(struct insn *insn)
 		insn->immediate2.value = get_next(int, insn);
 		insn->immediate2.nbytes = 4;
 		break;
+	default:	/* opnd_bytes must be modified manually */
+		goto err_out;
 	}
 	insn->immediate1.got = insn->immediate2.got = 1;
 
+	return 1;
 err_out:
-	return;
+	return 0;
 }
 
 /* Decode ptr16:16/32(Ap) */
-static void __get_immptr(struct insn *insn)
+static int __get_immptr(struct insn *insn)
 {
 	switch (insn->opnd_bytes) {
 	case 2:
@@ -462,14 +473,17 @@ static void __get_immptr(struct insn *insn)
 		break;
 	case 8:
 		/* ptr16:64 is not exist (no segment) */
-		return;
+		return 0;
+	default:	/* opnd_bytes must be modified manually */
+		goto err_out;
 	}
 	insn->immediate2.value = get_next(unsigned short, insn);
 	insn->immediate2.nbytes = 2;
 	insn->immediate1.got = insn->immediate2.got = 1;
 
+	return 1;
 err_out:
-	return;
+	return 0;
 }
 
 /**
@@ -489,7 +503,8 @@ void insn_get_immediate(struct insn *insn)
 		insn_get_displacement(insn);
 
 	if (inat_has_moffset(insn->attr)) {
-		__get_moffset(insn);
+		if (!__get_moffset(insn))
+			goto err_out;
 		goto done;
 	}
 
@@ -517,16 +532,20 @@ void insn_get_immediate(struct insn *insn)
 		insn->immediate2.nbytes = 4;
 		break;
 	case INAT_IMM_PTR:
-		__get_immptr(insn);
+		if (!__get_immptr(insn))
+			goto err_out;
 		break;
 	case INAT_IMM_VWORD32:
-		__get_immv32(insn);
+		if (!__get_immv32(insn))
+			goto err_out;
 		break;
 	case INAT_IMM_VWORD:
-		__get_immv(insn);
+		if (!__get_immv(insn))
+			goto err_out;
 		break;
 	default:
-		break;
+		/* Here, insn must have an immediate, but failed */
+		goto err_out;
 	}
 	if (inat_has_second_immediate(insn->attr)) {
 		insn->immediate2.value = get_next(char, insn);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
