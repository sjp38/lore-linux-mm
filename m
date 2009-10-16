Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 88DAF6B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 07:29:23 -0400 (EDT)
Date: Fri, 16 Oct 2009 06:29:20 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 0/2] x86, UV: fixups for configurations with a large
	number of nodes.
Message-ID: <20091016112920.GZ8903@sgi.com>
References: <20091015223959.783988000@alcatraz.americas.sgi.com> <20091016063405.GB20388@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091016063405.GB20388@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Robin Holt <holt@sgi.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Cliff Whickman <cpw@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 16, 2009 at 08:34:05AM +0200, Ingo Molnar wrote:
> 
> * Robin Holt <holt@sgi.com> wrote:
> 
> > We need the __uv_hub_info structure to contain the correct values for 
> > n_val, gpa_mask, and lowmem_remap_*.  The first patch in the series 
> > accomplishes this.  Could this be included in the stable tree as well. 
> > Without this patch, booting a large configuration hits a problem where 
> > the upper bits of the gnode affect the pnode and the bau will not 
> > operate.
> 
> i've applied this one.

Thank you for applying this one.

> > The second patch cleans up the broadcast assist unit code a small bit.
> 
> Seems to be more than just a 'cleanup'. It changes:

I am going to rearrange a bit:

> +       return gpa >> uv_hub_info->m_val & ((1UL << uv_hub_info->n_val) - 1);
> 
> note that >> has higher priority than bitwise & - is that intended? I 
> think the intention was:
> 
> +       return gpa >> (uv_hub_info->m_val & ((1UL << uv_hub_info->n_val) - 1));

The intention was (gpa >> m_val) & (n_mask);  I love the clarity of
making it an explicitly stated mask.  Much more readable.

> 
>   uv_nshift = uv_hub_info->m_val;
> 
> to (in essence):
> 
>               uv_hub_info->m_val & ((1UL << uv_hub_info->n_val) - 1)
> 
> which is not the same. Furthermore, the new inline is:

You have an excellent point there.  That was a bug as well.  That may
explain a few of our currently unexplained bau hangs.  The value is
supposed to be a pnode instead of the current gnode.

Robin

---

Create an inline function to extract the pnode from a global physical
address and then convert the broadcast assist unit to use the newly
created uv_gpa_to_pnode function.

To: Ingo Molnar <mingo@elte.hu>
To: tglx@linutronix.de
Signed-off-by: Robin Holt <holt@sgi.com>
Acked-by: Cliff Whickman <cpw@sgi.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---
 arch/x86/include/asm/uv/uv_hub.h |   16 +++++++++++++++-
 arch/x86/kernel/tlb_uv.c         |    7 ++-----
 2 files changed, 17 insertions(+), 6 deletions(-)
Index: linux/arch/x86/include/asm/uv/uv_hub.h
===================================================================
--- linux.orig/arch/x86/include/asm/uv/uv_hub.h	2009-10-16 06:02:23.000000000 -0500
+++ linux/arch/x86/include/asm/uv/uv_hub.h	2009-10-16 06:07:52.000000000 -0500
@@ -114,7 +114,7 @@
 /*
  * The largest possible NASID of a C or M brick (+ 2)
  */
-#define UV_MAX_NASID_VALUE	(UV_MAX_NUMALINK_NODES * 2)
+#define UV_MAX_NASID_VALUE	(UV_MAX_NUMALINK_BLADES * 2)
 
 struct uv_scir_s {
 	struct timer_list timer;
@@ -230,6 +230,20 @@ static inline unsigned long uv_gpa(void 
 	return uv_soc_phys_ram_to_gpa(__pa(v));
 }
 
+/* gnode -> pnode */
+static inline unsigned long uv_gpa_to_gnode(unsigned long gpa)
+{
+	return gpa >> uv_hub_info->m_val;
+}
+
+/* gpa -> pnode */
+static inline int uv_gpa_to_pnode(unsigned long gpa)
+{
+	unsigned long n_mask = (1UL << uv_hub_info->n_val) - 1;
+
+	return uv_gpa_to_gnode(gpa) & n_mask;
+}
+
 /* pnode, offset --> socket virtual */
 static inline void *uv_pnode_offset_to_vaddr(int pnode, unsigned long offset)
 {
Index: linux/arch/x86/kernel/tlb_uv.c
===================================================================
--- linux.orig/arch/x86/kernel/tlb_uv.c	2009-10-16 06:02:27.000000000 -0500
+++ linux/arch/x86/kernel/tlb_uv.c	2009-10-16 06:02:28.000000000 -0500
@@ -23,8 +23,6 @@
 static struct bau_control	**uv_bau_table_bases __read_mostly;
 static int			uv_bau_retry_limit __read_mostly;
 
-/* position of pnode (which is nasid>>1): */
-static int			uv_nshift __read_mostly;
 /* base pnode in this partition */
 static int			uv_partition_base_pnode __read_mostly;
 
@@ -723,7 +721,7 @@ uv_activation_descriptor_init(int node, 
 	BUG_ON(!adp);
 
 	pa = uv_gpa(adp); /* need the real nasid*/
-	n = pa >> uv_nshift;
+	n = uv_gpa_to_pnode(pa);
 	m = pa & uv_mmask;
 
 	uv_write_global_mmr64(pnode, UVH_LB_BAU_SB_DESCRIPTOR_BASE,
@@ -778,7 +776,7 @@ uv_payload_queue_init(int node, int pnod
 	 * need the pnode of where the memory was really allocated
 	 */
 	pa = uv_gpa(pqp);
-	pn = pa >> uv_nshift;
+	pn = uv_gpa_to_pnode(pa);
 	uv_write_global_mmr64(pnode,
 			      UVH_LB_BAU_INTD_PAYLOAD_QUEUE_FIRST,
 			      ((unsigned long)pn << UV_PAYLOADQ_PNODE_SHIFT) |
@@ -843,7 +841,6 @@ static int __init uv_bau_init(void)
 				       GFP_KERNEL, cpu_to_node(cur_cpu));
 
 	uv_bau_retry_limit = 1;
-	uv_nshift = uv_hub_info->m_val;
 	uv_mmask = (1UL << uv_hub_info->m_val) - 1;
 	nblades = uv_num_possible_blades();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
