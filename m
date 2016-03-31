Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7DECE6B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 17:01:27 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id 4so77629282pfd.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 14:01:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t73si16286695pfa.240.2016.03.31.14.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 14:01:26 -0700 (PDT)
Date: Thu, 31 Mar 2016 14:01:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
Message-Id: <20160331140124.481acb67ef8f7356778cc4a0@linux-foundation.org>
In-Reply-To: <56FD2285.4080600@suse.cz>
References: <56F4E104.9090505@huawei.com>
	<20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org>
	<56FA7DC8.4000902@suse.cz>
	<56FD2285.4080600@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 31 Mar 2016 15:13:41 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 03/29/2016 03:06 PM, Vlastimil Babka wrote:
> > On 03/25/2016 08:22 PM, Andrew Morton wrote:
> >> Also, mm/mempolicy.c:offset_il_node() worries me:
> >>
> >> 	do {
> >> 		nid = next_node(nid, pol->v.nodes);
> >> 		c++;
> >> 	} while (c <= target);
> >>
> >> Can't `nid' hit MAX_NUMNODES?
> >
> > AFAICS it can. interleave_nid() uses this and the nid is then used e.g.
> > in node_zonelist() where it's used for NODE_DATA(nid). That's quite
> > scary. It also predates git. Why don't we see crashes or KASAN finding this?
> 
> Ah, I see. In offset_il_node(), nid is initialized to -1, and the number 
> of do-while iterations calling next_node() is up to the number of bits 
> set in the pol->v.nodes bitmap, so it can't reach past the last set bit 
> and return MAX_NUMNODES.

Gack.  offset_il_node() should be dragged out, strangled, shot then burnt.

static unsigned offset_il_node(struct mempolicy *pol,
		struct vm_area_struct *vma, unsigned long off)
{
	unsigned nnodes = nodes_weight(pol->v.nodes);
	unsigned target;
	int c;
	int nid = NUMA_NO_NODE;

	if (!nnodes)
		return numa_node_id();
	target = (unsigned int)off % nnodes;
	c = 0;
	do {
		nid = next_node(nid, pol->v.nodes);
		c++;
	} while (c <= target);
	return nid;
}

For starters it is relying upon next_node(-1, ...) behaving like
first_node().  Fair enough I guess, but that isn't very clear.

static inline int __next_node(int n, const nodemask_t *srcp)
{
	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
}

will start from node 0 when it does the n+1.

Also it is relying upon NUMA_NO_NODE having a value of -1.  That's just
grubby - this code shouldn't "know" that NUMA_NO_NODE==-1.  It would have
been better to use plain old "-1" here.


Does this look clearer and correct?

/*
 * Do static interleaving for a VMA with known offset @n.  Returns the n'th
 * node in pol->v.nodes (starting from n=0), wrapping around if n exceeds the
 * number of present nodes.
 */
static unsigned offset_il_node(struct mempolicy *pol,
			       struct vm_area_struct *vma, unsigned long n)
{
	unsigned nnodes = nodes_weight(pol->v.nodes);
	unsigned target;
	int i;
	int nid;

	if (!nnodes)
		return numa_node_id();
	target = (unsigned int)n % nnodes;
	nid = first_node(pol->v.nodes);
	for (i = 0; i < target; i++)
		nid = next_node(nid, pol->v.nodes);
	return nid;
}


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/mempolicy.c:offset_il_node() document and clarify

This code was pretty obscure and was relying upon obscure side-effects of
next_node(-1, ...) and was relying upon NUMA_NO_NODE being equal to -1.

Clean that all up and document the function's intent.

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Laura Abbott <lauraa@codeaurora.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mempolicy.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff -puN mm/mempolicy.c~mm-mempolicyc-offset_il_node-document-and-clarify mm/mempolicy.c
--- a/mm/mempolicy.c~mm-mempolicyc-offset_il_node-document-and-clarify
+++ a/mm/mempolicy.c
@@ -1763,23 +1763,25 @@ unsigned int mempolicy_slab_node(void)
 	}
 }
 
-/* Do static interleaving for a VMA with known offset. */
+/*
+ * Do static interleaving for a VMA with known offset @n.  Returns the n'th
+ * node in pol->v.nodes (starting from n=0), wrapping around if n exceeds the
+ * number of present nodes.
+ */
 static unsigned offset_il_node(struct mempolicy *pol,
-		struct vm_area_struct *vma, unsigned long off)
+			       struct vm_area_struct *vma, unsigned long n)
 {
 	unsigned nnodes = nodes_weight(pol->v.nodes);
 	unsigned target;
-	int c;
-	int nid = NUMA_NO_NODE;
+	int i;
+	int nid;
 
 	if (!nnodes)
 		return numa_node_id();
-	target = (unsigned int)off % nnodes;
-	c = 0;
-	do {
+	target = (unsigned int)n % nnodes;
+	nid = first_node(pol->v.nodes);
+	for (i = 0; i < target; i++)
 		nid = next_node(nid, pol->v.nodes);
-		c++;
-	} while (c <= target);
 	return nid;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
