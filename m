Date: Wed, 20 Apr 2005 14:23:10 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: swap space address layout improvements in -mm
Message-ID: <20050420172310.GA8871@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

I have spent some time reading your swap space allocation patch.

+ * We divide the swapdev into 1024 kilobyte chunks.  We use the cookie and the
+ * upper bits of the index to select a chunk and the rest of the index as the
+ * offset into the selected chunk.
+ */
+#define CHUNK_SHIFT    (20 - PAGE_SHIFT)
+#define CHUNK_MASK     (-1UL << CHUNK_SHIFT)
+
+static int
+scan_swap_map(struct swap_info_struct *si, void *cookie, pgoff_t index)
+{
+       unsigned long chunk;
+       unsigned long nchunks;
+       unsigned long block;
+       unsigned long scan;
+
+       nchunks = si->max >> CHUNK_SHIFT;
+       chunk = 0;
+       if (nchunks)
+               chunk = hash_long((unsigned long)cookie + (index & CHUNK_MASK),
+                                       BITS_PER_LONG) % nchunks;
+
+       block = (chunk << CHUNK_SHIFT) + (index & ~CHUNK_MASK);

>From what I can understand you're aiming at having virtually contiguous pages sequentially 
allocated on disk.  

I just dont understand how you want that to be achieved using the hash function, which is 
quite randomic... In practice, the calculated hash values have most of its MostSignificantBit's 
changed at each increment of 255, resulting in non sequential block values at such 
index increments. 

The first and subsequent block allocations are simply randomic, instead of being sequential.
Hit me with your cluebat.
 
>From what I know, it is interesting to allocate from (0 in direction to -> end block) 
(roughly what sct allocation scheme does).

I suspect a more advanced fs-like swap allocation scheme is wanted. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
