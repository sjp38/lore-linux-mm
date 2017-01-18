Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E35456B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 11:24:33 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r126so4011175wmr.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:24:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si873360wrc.184.2017.01.18.08.24.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 08:24:32 -0800 (PST)
Subject: Re: [RFC 5/4] mm, page_alloc: fix premature OOM due to vma mempolicy
 update
References: <20170117221610.22505-1-vbabka@suse.cz>
 <7c459f26-13a6-a817-e508-b65b903a8378@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a3bc44cd-3c81-c20e-aecb-525eb73b9bfe@suse.cz>
Date: Wed, 18 Jan 2017 17:23:38 +0100
MIME-Version: 1.0
In-Reply-To: <7c459f26-13a6-a817-e508-b65b903a8378@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/18/2017 05:20 PM, Vlastimil Babka wrote:
> By changing the LTP cpuset01 testcase (will post patch as a reply) this was
> confirmed and the problem is also older than the changes in 4.7.

-----8<-----
diff --git a/testcases/kernel/mem/cpuset/cpuset01.c b/testcases/kernel/mem/cpuset/cpuset01.c
index 558420f72f9b..ef673366e15e 100644
--- a/testcases/kernel/mem/cpuset/cpuset01.c
+++ b/testcases/kernel/mem/cpuset/cpuset01.c
@@ -40,6 +40,7 @@
 #include <fcntl.h>
 #include <math.h>
 #if HAVE_NUMAIF_H
+#include <linux/mempolicy.h>
 #include <numaif.h>
 #endif
 #include <signal.h>
@@ -61,6 +62,7 @@ volatile int end;
 static int *nodes;
 static int nnodes;
 static long ncpus;
+static unsigned long nmask[MAXNODES / BITS_PER_LONG] = { 0 };
 
 static void testcpuset(void);
 static void sighandler(int signo LTP_ATTRIBUTE_UNUSED);
@@ -89,7 +91,6 @@ static void testcpuset(void)
 {
 	int lc;
 	int child, i, status;
-	unsigned long nmask[MAXNODES / BITS_PER_LONG] = { 0 };
 	char mems[BUFSIZ], buf[BUFSIZ];
 
 	read_cpuset_files(CPATH, "cpus", buf);
@@ -105,6 +106,7 @@ static void testcpuset(void)
 		for (i = 0; i < nnodes; i++) {
 			if (nodes[i] >= MAXNODES)
 				continue;
+			printf("bind to node %d\n", nodes[i]);
 			set_node(nmask, nodes[i]);
 		}
 		if (set_mempolicy(MPOL_BIND, nmask, MAXNODES) == -1)
@@ -163,6 +165,8 @@ static int mem_hog(void)
 			tst_resm(TFAIL | TERRNO, "mmap");
 			break;
 		}
+		if (mbind(addr, pagesize * 10, MPOL_BIND, nmask, MAXNODES, 0) == -1)
+			tst_brkm(TBROK | TERRNO, cleanup, "set_mempolicy");
 		memset(addr, 0xF7, pagesize * 10);
 		munmap(addr, pagesize * 10);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
