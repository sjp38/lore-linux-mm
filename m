Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 61BB46B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 10:57:42 -0400 (EDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <holzheu@linux.vnet.ibm.com>;
	Tue, 17 Sep 2013 15:57:40 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3E9C717D8057
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 15:57:47 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8HEvO4u46727380
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 14:57:24 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8HEvaHn010202
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 08:57:36 -0600
Date: Tue, 17 Sep 2013 16:57:34 +0200
From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: [PATCH] mm: Fix bootmem error handling in pcpu_page_first_chunk()
Message-ID: <20130917165734.16aa0226@holzheu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

If memory allocation of in pcpu_embed_first_chunk() fails, the
allocated memory is not released correctly. In the release loop also
the non-allocated elements are released which leads to the following
kernel BUG on systems with very little memory:

[    0.000000] kernel BUG at mm/bootmem.c:307!
[    0.000000] illegal operation: 0001 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.10.0 #22
[    0.000000] task: 0000000000a20ae0 ti: 0000000000a08000 task.ti: 0000000000a08000
[    0.000000] Krnl PSW : 0400000180000000 0000000000abda7a (__free+0x116/0x154)
[    0.000000]            R:0 T:1 IO:0 EX:0 Key:0 M:0 W:0 P:0 AS:0 CC:0 PM:0 EA:3
...
[    0.000000]  [<0000000000abdce2>] mark_bootmem_node+0xde/0xf0
[    0.000000]  [<0000000000abdd9c>] mark_bootmem+0xa8/0x118
[    0.000000]  [<0000000000abcbba>] pcpu_embed_first_chunk+0xe7a/0xf0c
[    0.000000]  [<0000000000abcc96>] setup_per_cpu_areas+0x4a/0x28c

To fix the problem now only allocated elements are released. This then
leads to the correct kernel panic:

[    0.000000] Kernel panic - not syncing: Failed to initialize percpu areas.
...
[    0.000000] Call Trace:
[    0.000000] ([<000000000011307e>] show_trace+0x132/0x150)
[    0.000000]  [<0000000000113160>] show_stack+0xc4/0xd4
[    0.000000]  [<00000000007127dc>] dump_stack+0x74/0xd8
[    0.000000]  [<00000000007123fe>] panic+0xea/0x264
[    0.000000]  [<0000000000b14814>] setup_per_cpu_areas+0x5c/0x28c

Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 mm/percpu.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1705,9 +1705,12 @@ int __init pcpu_embed_first_chunk(size_t
 	goto out_free;
 
 out_free_areas:
-	for (group = 0; group < ai->nr_groups; group++)
+	for (group = 0; group < ai->nr_groups; group++) {
+		if (!areas[group])
+			continue;
 		free_fn(areas[group],
 			ai->groups[group].nr_units * ai->unit_size);
+	}
 out_free:
 	pcpu_free_alloc_info(ai);
 	if (areas)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
