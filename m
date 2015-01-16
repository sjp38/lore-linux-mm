Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id E3E1F6B006E
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:17:28 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id a108so8010095qge.12
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 06:17:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id dt10si1201372qcb.2.2015.01.16.06.17.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 06:17:28 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH 1/2] documentation: proc: add /proc/pid/numa_maps interface explanation snippet
Date: Fri, 16 Jan 2015 08:50:50 -0500
Message-Id: <a80ea9c286d71d9f619af6ebb476ad879c14da7d.1421415776.git.aquini@redhat.com>
In-Reply-To: <cover.1421415776.git.aquini@redhat.com>
References: <cover.1421415776.git.aquini@redhat.com>
In-Reply-To: <cover.1421415776.git.aquini@redhat.com>
References: <cover.1421415776.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, jweiner@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

This patch adds a small section to proc.txt doc in order to document its
/proc/pid/numa_maps interface. It does not introduce any functional changes,
just documentation.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 Documentation/filesystems/proc.txt | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 13b5809..0be178f 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -144,6 +144,8 @@ Table 1-1: Process specific entries in /proc
  stack		Report full stack trace, enable via CONFIG_STACKTRACE
  smaps		a extension based on maps, showing the memory consumption of
 		each mapping and flags associated with it
+ numa_maps	an extension based on maps, showing the memory locality and
+		binding policy as well as mem usage (in pages) of each mapping.
 ..............................................................................
 
 For example, to get the status information of a process, all you have to do is
@@ -498,6 +500,37 @@ The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
 using /proc/kpageflags and number of times a page is mapped using
 /proc/kpagecount. For detailed explanation, see Documentation/vm/pagemap.txt.
 
+The /proc/pid/numa_maps is an extension based on maps, showing the memory
+locality and binding policy, as well as the memory usage (in pages) of
+each mapping. The output follows a general format where mapping details get
+summarized separated by blank spaces, one mapping per each file line:
+
+address   policy    mapping details
+
+00400000 default file=/usr/local/bin/app kernelpagesize_kB=4 mapped=1 active=0 N3=1
+00600000 default file=/usr/local/bin/app kernelpagesize_kB=4 anon=1 dirty=1 N3=1
+3206000000 default file=/lib64/ld-2.12.so kernelpagesize_kB=4 mapped=26 mapmax=6 N0=24 N3=2
+320621f000 default file=/lib64/ld-2.12.so kernelpagesize_kB=4 anon=1 dirty=1 N3=1
+3206220000 default file=/lib64/ld-2.12.so kernelpagesize_kB=4 anon=1 dirty=1 N3=1
+3206221000 default kernelpagesize_kB=4 anon=1 dirty=1 N3=1
+3206800000 default file=/lib64/libc-2.12.so kernelpagesize_kB=4 mapped=59 mapmax=21 active=55 N0=41 N3=18
+320698b000 default file=/lib64/libc-2.12.so
+3206b8a000 default file=/lib64/libc-2.12.so kernelpagesize_kB=4 anon=2 dirty=2 N3=2
+3206b8e000 default file=/lib64/libc-2.12.so kernelpagesize_kB=4 anon=1 dirty=1 N3=1
+3206b8f000 default kernelpagesize_kB=4 anon=3 dirty=3 active=1 N3=3
+7f4dc10a2000 default kernelpagesize_kB=4 anon=3 dirty=3 N3=3
+7f4dc10b4000 default kernelpagesize_kB=4 anon=2 dirty=2 active=1 N3=2
+7f4dc1200000 default file=/anon_hugepage\040(deleted) huge kernelpagesize_kB=2048 anon=1 dirty=1 N3=1
+7fff335f0000 default stack kernelpagesize_kB=4 anon=3 dirty=3 N3=3
+7fff3369d000 default kernelpagesize_kB=4 mapped=1 mapmax=35 active=0 N3=1
+
+Where:
+"address" is the starting address for the mapping;
+"policy" reports the NUMA memory policy set for the mapping (see vm/numa_memory_policy.txt);
+"mapping details" summarizes mapping data such as mapping type, page usage counters,
+node locality page counters (N0 == node0, N1 == node1, ...) and the kernel page
+size, in KB, that is backing the mapping up.
+
 1.2 Kernel data
 ---------------
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
