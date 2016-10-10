Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71DF86B0038
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 12:23:25 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id x23so42522296lfi.0
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 09:23:25 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id 140si10602484ljj.1.2016.10.10.09.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 09:23:23 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id x79so7537748lff.2
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 09:23:23 -0700 (PDT)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH v3 0/1] man/set_mempolicy.2,mbind.2: add MPOL_LOCAL NUMA memory policy documentation
Date: Mon, 10 Oct 2016 18:23:10 +0200
Message-Id: <20161010162310.2463-1-kwapulinski.piotr@gmail.com>
In-Reply-To: <alpine.DEB.2.20.1610100854001.27158@east.gentwo.org>
References: <alpine.DEB.2.20.1610100854001.27158@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, a.p.zijlstra@chello.nl, cl@linux.com, riel@redhat.com, lee.schermerhorn@hp.com, jmarchan@redhat.com, joe@perches.com, corbet@lwn.net, iamyooon@gmail.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, kwapulinski.piotr@gmail.com

The MPOL_LOCAL mode has been implemented by
Peter Zijlstra <a.p.zijlstra@chello.nl>
(commit: 479e2802d09f1e18a97262c4c6f8f17ae5884bd8).
Add the documentation for this mode.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
This version fixes grammar
---
 man2/mbind.2         | 28 ++++++++++++++++++++++++----
 man2/set_mempolicy.2 | 19 ++++++++++++++++++-
 2 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/man2/mbind.2 b/man2/mbind.2
index 3ea24f6..854580c 100644
--- a/man2/mbind.2
+++ b/man2/mbind.2
@@ -130,8 +130,9 @@ argument must specify one of
 .BR MPOL_DEFAULT ,
 .BR MPOL_BIND ,
 .BR MPOL_INTERLEAVE ,
+.BR MPOL_PREFERRED ,
 or
-.BR MPOL_PREFERRED .
+.BR MPOL_LOCAL .
 All policy modes except
 .B MPOL_DEFAULT
 require the caller to specify via the
@@ -258,9 +259,26 @@ and
 .I maxnode
 arguments specify the empty set, then the memory is allocated on
 the node of the CPU that triggered the allocation.
-This is the only way to specify "local allocation" for a
-range of memory via
-.BR mbind ().
+
+.B MPOL_LOCAL
+specifies the "local allocation", the memory is allocated on
+the node of the CPU that triggered the allocation, "local node".
+The
+.I nodemask
+and
+.I maxnode
+arguments must specify the empty set. If the "local node" is low
+on free memory the kernel will try to allocate memory from other
+nodes. The kernel will allocate memory from the "local node"
+whenever memory for this node is available. If the "local node"
+is not allowed by the process's current cpuset context the kernel
+will try to allocate memory from other nodes. The kernel will
+allocate memory from the "local node" whenever it becomes allowed
+by the process's current cpuset context. In contrast
+.B MPOL_DEFAULT
+reverts to the policy of the process which may have been set with
+.BR set_mempolicy (2).
+It may not be the "local allocation".
 
 If
 .B MPOL_MF_STRICT
@@ -440,6 +458,8 @@ To select explicit "local allocation" for a memory range,
 specify a
 .I mode
 of
+.B MPOL_LOCAL
+or
 .B MPOL_PREFERRED
 with an empty set of nodes.
 This method will work for
diff --git a/man2/set_mempolicy.2 b/man2/set_mempolicy.2
index 1f02037..22b0f7c 100644
--- a/man2/set_mempolicy.2
+++ b/man2/set_mempolicy.2
@@ -79,8 +79,9 @@ argument must specify one of
 .BR MPOL_DEFAULT ,
 .BR MPOL_BIND ,
 .BR MPOL_INTERLEAVE ,
+.BR MPOL_PREFERRED ,
 or
-.BR MPOL_PREFERRED .
+.BR MPOL_LOCAL .
 All modes except
 .B MPOL_DEFAULT
 require the caller to specify via the
@@ -211,6 +212,22 @@ arguments specify the empty set, then the policy
 specifies "local allocation"
 (like the system default policy discussed above).
 
+.B MPOL_LOCAL
+specifies the "local allocation", the memory is allocated on
+the node of the CPU that triggered the allocation, "local node".
+The
+.I nodemask
+and
+.I maxnode
+arguments must specify the empty set. If the "local node" is low
+on free memory the kernel will try to allocate memory from other
+nodes. The kernel will allocate memory from the "local node"
+whenever memory for this node is available. If the "local node"
+is not allowed by the process's current cpuset context the kernel
+will try to allocate memory from other nodes. The kernel will
+allocate memory from the "local node" whenever it becomes allowed
+by the process's current cpuset context.
+
 The thread memory policy is preserved across an
 .BR execve (2),
 and is inherited by child threads created using
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
