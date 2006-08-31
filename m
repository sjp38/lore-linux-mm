Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7V61Ljs022357
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 02:01:21 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7V61LmZ299908
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 00:01:21 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7V60IHN031804
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 00:00:18 -0600
Date: Wed, 30 Aug 2006 23:00:36 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: libnuma interleaving oddness
Message-ID: <20060831060036.GA18661@us.ibm.com>
References: <20060829231545.GY5195@us.ibm.com> <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com> <20060830002110.GZ5195@us.ibm.com> <200608300919.13125.ak@suse.de> <20060830072948.GE5195@us.ibm.com> <Pine.LNX.4.64.0608301401290.4217@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608301401290.4217@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 30.08.2006 [14:04:40 -0700], Christoph Lameter wrote:
> > I took out the mlock() call, and I get the same results, FWIW.
> 
> What zones are available on your box? Any with HIGHMEM?

How do I tell the available zones from userspace? This is ppc64 with
about 64GB of memory total, it looks like. So, none of the nodes
(according to /sys/devices/system/node/*/meminfo) have highmem.

> Also what kernel version are we talking about? Before 2.6.18?

The SuSE default, 2.6.16.21 -- I thought I mentioned that in one of my
replies, sorry.

Tim and I spent most of this afternoon debugging the huge_zonelist()
callpath with kprobes and jprobes. We found the following via a jprobe
to offset_li_node():

jprobe: vma=0xc000000006dc2d78, pol->policy=0x3, pol->v.nodes=0xff, off=0x0
jprobe: vma=0xc00000000f247e30, pol->policy=0x3, pol->v.nodes=0xff, off=0x1000
jprobe: vma=0xc000000006dbf648, pol->policy=0x3, pol->v.nodes=0xff, off=0x2000
...
jprobe: vma=0xc00000000f298870, pol->policy=0x3, pol->v.nodes=0xff, off=0x17000
jprobe: vma=0xc00000000f298368, pol->policy=0x3, pol->v.nodes=0xff, off=0x18000

So, it's quite clear that the nodemask is set appropriately and so is
the policy. The problem, in fact, is the "offset" being passed into
offset_li_node().

The problem, I think, is from interleave_nid():

	off = vma->vm_pgoff;
	off += (addr - vma->vm_start) >> shift;
	return offset_il_node(pol, vma, off);

For hugetlbfs vma's, since vm_pgoff is in units of small pages, the lower
(HPAGE_SHIFT - PAGE_SHIFT) bits of vma->vm_pgoff and off will always be zero
(12 in this case).  Thus, when we get into offset_li_node():

        unsigned nnodes = nodes_weight(pol->v.nodes);
        unsigned target = (unsigned)off % nnodes;
        int c;
        int nid = -1;

        c = 0;
        do {
                nid = next_node(nid, pol->v.nodes);
                c++;
        } while (c <= target);
        return nid;

nnodes is 8 (the number of nodes). Our offset (some multiple of 4096) is
always going to be evenly divided by 8. So, our target node is always
node 0! Note, that when we took out a bit in our nodemask, nnodes
changed accordingly and 7 did not evenly divide the offset, and we got
interleaving as expected.

To test my hypothesis (my analysis may be a bit hand-wavy, sorry), I
changed interleave_nid() to shift off right by (HPAGE_SHIFT -
PAGE_SHIFT) only #if CONFIG_HUGETLB_PAGE. This fixes the behavior for
the page-by-page case. But I'm not sure this is an acceptable mainline
change, but I've included my signed-off-but-not-for-inclusion patch.

Note, that when I try this with my testcase that makes each allocation
be 4 hugepages large, I get 4 hugepages on node 0, then 4 on node 4,
then 4 on node 0, and so on. I believe this is because the offset ends
up being the same for all of the 4 hugepages in each set, so they go to
the same node

Many thanks to Tim for his help debugging.

---

Once again, not for inclusion!

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff -urpN 2.6.18-rc5/mm/mempolicy.c 2.6.18-rc5-dev/mm/mempolicy.c
--- 2.6.18-rc5/mm/mempolicy.c	2006-08-30 22:55:33.000000000 -0700
+++ 2.6.18-rc5-dev/mm/mempolicy.c	2006-08-30 22:56:43.000000000 -0700
@@ -1169,6 +1169,7 @@ static unsigned offset_il_node(struct me
 	return nid;
 }
 
+#ifndef CONFIG_HUGETLBFS
 /* Determine a node number for interleave */
 static inline unsigned interleave_nid(struct mempolicy *pol,
 		 struct vm_area_struct *vma, unsigned long addr, int shift)
@@ -1182,8 +1183,22 @@ static inline unsigned interleave_nid(st
 	} else
 		return interleave_nodes(pol);
 }
+#else
+/* Determine a node number for interleave */
+static inline unsigned interleave_nid(struct mempolicy *pol,
+		 struct vm_area_struct *vma, unsigned long addr, int shift)
+{
+	if (vma) {
+		unsigned long off;
+
+		off = vma->vm_pgoff;
+		off += (addr - vma->vm_start) >> shift;
+		off >>= (HPAGE_SHIFT - PAGE_SHIFT);
+		return offset_il_node(pol, vma, off);
+	} else
+		return interleave_nodes(pol);
+}
 
-#ifdef CONFIG_HUGETLBFS
 /* Return a zonelist suitable for a huge page allocation. */
 struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr)
 {

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
