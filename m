Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3FC16B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 21:54:06 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k101so17742379iod.1
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 18:54:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d10sor4259416ioe.203.2017.09.26.18.54.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 18:54:05 -0700 (PDT)
Date: Tue, 26 Sep 2017 20:54:00 -0500
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: percpu allocation failures
Message-ID: <20170927015323.GA19100@Big-Sky.local>
References: <87efqttqr6.fsf@hermes>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87efqttqr6.fsf@hermes>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luis Henriques <lhenriques@suse.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Luis,

This seems to be an issue with the reserved chunk being unable to
allocate memory when loading kernel modules. Unfortunately, I have not 
been successful in reproducing this with the reserved chunk allocation
path exposed or by inserting the nft_meta module.

Could you please send me the output when ran with the following patch
and the output of the percpu memory statistics file before and after
inserting the module (PERCPU_STATS)? The stats are in
/sys/kernel/debug/percpu_stats.

Thanks,
Dennis

---
 mm/percpu.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 59d44d6..031fd91 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1335,6 +1335,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 {
 	static int warn_limit = 10;
 	struct pcpu_chunk *chunk;
+	struct pcpu_block_md *block;
 	const char *err;
 	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
 	int slot, off, cpu, ret;
@@ -1371,17 +1372,43 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	if (reserved && pcpu_reserved_chunk) {
 		chunk = pcpu_reserved_chunk;
 
+		printk(KERN_DEBUG "percpu: reserved chunk: %d, %d, %d, %d, %d, %d, %d",
+		       chunk->free_bytes, chunk->contig_bits,
+		       chunk->contig_bits_start, chunk->first_bit,
+		       chunk->start_offset, chunk->end_offset,
+		       chunk->nr_pages);
+
+		printk(KERN_DEBUG "percpu: rchunk md blocks");
+		for (block = chunk->md_blocks;
+		     block < chunk->md_blocks + pcpu_chunk_nr_blocks(chunk);
+		     block++) {
+			printk(KERN_DEBUG "   percpu: %d, %d, %d, %d, %d",
+			       block->contig_hint,
+			       block->contig_hint_start,
+			       block->left_free,
+			       block->right_free,
+			       block->first_free);
+		}
+
 		off = pcpu_find_block_fit(chunk, bits, bit_align, is_atomic);
+
+		printk(KERN_DEBUG "percpu: pcpu_find_block_fit: %d, %zu, %zu",
+		       off, bits, bit_align);
+
 		if (off < 0) {
-			err = "alloc from reserved chunk failed";
+			err = "alloc from reserved chunk failed to find fit";
 			goto fail_unlock;
 		}
 
 		off = pcpu_alloc_area(chunk, bits, bit_align, off);
+
+		printk(KERN_DEBUG "percpu: pcpu_alloc_area: %d, %zu, %zu",
+		       off, bits, bit_align);
+
 		if (off >= 0)
 			goto area_found;
 
-		err = "alloc from reserved chunk failed";
+		err = "alloc from reserved chunk failed to alloc area";
 		goto fail_unlock;
 	}
 
@@ -1547,6 +1574,7 @@ void __percpu *__alloc_reserved_percpu(size_t size, size_t align)
 {
 	return pcpu_alloc(size, align, true, GFP_KERNEL);
 }
+EXPORT_SYMBOL_GPL(__alloc_reserved_percpu);
 
 /**
  * pcpu_balance_workfn - manage the amount of free chunks and populated pages
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
