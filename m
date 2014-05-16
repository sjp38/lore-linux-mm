Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB426B0035
	for <linux-mm@kvack.org>; Fri, 16 May 2014 19:42:21 -0400 (EDT)
Received: by mail-yh0-f44.google.com with SMTP id b6so4969776yha.3
        for <linux-mm@kvack.org>; Fri, 16 May 2014 16:42:21 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id q58si13337418yhh.187.2014.05.16.16.42.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 May 2014 16:42:21 -0700 (PDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 16 May 2014 17:42:19 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id ADCDA19D8040
	for <linux-mm@kvack.org>; Fri, 16 May 2014 17:42:11 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4GNfIFr10551692
	for <linux-mm@kvack.org>; Sat, 17 May 2014 01:41:26 +0200
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4GNfj5l008732
	for <linux-mm@kvack.org>; Fri, 16 May 2014 17:41:45 -0600
Date: Fri, 16 May 2014 16:41:20 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH 2/2] powerpc: numa: enable CONFIG_HAVE_MEMORYLESS_NODES
Message-ID: <20140516234120.GJ8941@linux.vnet.ibm.com>
References: <20140516233945.GI8941@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140516233945.GI8941@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, Anton Blanchard <anton@samba.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Ben Herrenschmidt <benh@kernel.crashing.org>

Based off fd1197f1 for ia64, enable CONFIG_HAVE_MEMORYLESS_NODES if
NUMA. Initialize the local memory node in start_secondary.

With this commit and the preceding to enable
CONFIG_USER_PERCPU_NUMA_NODE_ID, which is a prerequisite, in a PowerKVM
guest with the following topology:

numactl --hardware
available: 3 nodes (0-2)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46
47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70
71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94
95 96 97 98 99
node 0 size: 1998 MB
node 0 free: 521 MB
node 1 cpus: 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114
115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132
133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150
151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168
169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186
187 188 189 190 191 192 193 194 195 196 197 198 199
node 1 size: 0 MB
node 1 free: 0 MB
node 2 cpus:
node 2 size: 2039 MB
node 2 free: 1739 MB
node distances:
node   0   1   2
  0:  10  40  40
  1:  40  10  40
  2:  40  40  10

the unreclaimable slab is reduced by close to 130M:

Before:
        Slab:             418176 kB
        SReclaimable:      26624 kB
        SUnreclaim:       391552 kB

After:
        Slab:             298944 kB
        SReclaimable:      31744 kB
        SUnreclaim:       267200 kB

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 9125964..bd6dd6e 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -457,6 +457,10 @@ config USE_PERCPU_NUMA_NODE_ID
 	def_bool y
 	depends on NUMA
 
+config HAVE_MEMORYLESS_NODES
+	def_bool y
+	depends on NUMA
+
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 	depends on PPC64
diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
index b95be24..ebd7b9d 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -754,6 +754,7 @@ void start_secondary(void *unused)
 	 * numa_node_id() works after this.
 	 */
 	set_numa_node(numa_cpu_lookup_table[cpu]);
+	set_numa_mem(local_memory_node(numa_cpu_lookup_table[cpu]));
 
 	smp_wmb();
 	notify_cpu_starting(cpu);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
