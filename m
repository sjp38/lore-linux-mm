Message-Id: <20071030160913.946725000@chello.nl>
References: <20071030160401.296770000@chello.nl>
Date: Tue, 30 Oct 2007 17:04:18 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 17/33] sysctl: propagate conv errors
Content-Disposition: inline; filename=sysctl_parse_error.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Currently conv routines will only generate -EINVAL, allow for other
errors to be propagetd.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/sysctl.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -1732,6 +1732,7 @@ static int __do_proc_dointvec(void *tbl_
 	int *i, vleft, first=1, neg, val;
 	unsigned long lval;
 	size_t left, len;
+	int ret = 0;
 	
 	char buf[TMPBUFLEN], *p;
 	char __user *s = buffer;
@@ -1787,14 +1788,16 @@ static int __do_proc_dointvec(void *tbl_
 			s += len;
 			left -= len;
 
-			if (conv(&neg, &lval, i, 1, data))
+			ret = conv(&neg, &lval, i, 1, data);
+			if (ret)
 				break;
 		} else {
 			p = buf;
 			if (!first)
 				*p++ = '\t';
 	
-			if (conv(&neg, &lval, i, 0, data))
+			ret = conv(&neg, &lval, i, 0, data);
+			if (ret)
 				break;
 
 			sprintf(p, "%s%lu", neg ? "-" : "", lval);
@@ -1823,11 +1826,9 @@ static int __do_proc_dointvec(void *tbl_
 			left--;
 		}
 	}
-	if (write && first)
-		return -EINVAL;
 	*lenp -= left;
 	*ppos += *lenp;
-	return 0;
+	return ret;
 #undef TMPBUFLEN
 }
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
