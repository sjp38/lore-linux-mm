From: Jesse Barnes <jbarnes@engr.sgi.com>
Subject: Re: [PATCH] don't pass mem_map into init functions
Date: Wed, 28 Jul 2004 15:39:40 -0700
References: <1091048123.2871.435.camel@nighthawk> <200407281501.19181.jbarnes@engr.sgi.com> <1091053187.2871.526.camel@nighthawk>
In-Reply-To: <1091053187.2871.526.camel@nighthawk>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_ssCCBzsXjapiTYq"
Message-Id: <200407281539.40049.jbarnes@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm <linux-mm@kvack.org>, LSE <lse-tech@lists.sourceforge.net>, Anton Blanchard <anton@samba.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, davidm@hpl.hp.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

--Boundary-00=_ssCCBzsXjapiTYq
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday, July 28, 2004 3:19 pm, Dave Hansen wrote:
> On Wed, 2004-07-28 at 15:01, Jesse Barnes wrote:
> > On Wednesday, July 28, 2004 1:55 pm, Dave Hansen wrote:
> > > Compile tested on SMP x86 and NUMAQ.  I plan to give it a run on ppc64
> > > in a bit.  I'd appreciate if one of the ia64 guys could make sure it's
> > > OK for them as well.
> >
> > Which tree is this against?  It doesn't apply to the bk tree or
> > linux-2.6.8-rc2-mm1.
>
> Put this one before it, and it should apply cleanly.  I posted this one
> earlier today, and didn't realize that the new one was dependent.

You're missing this little bit from your patchset.  Cc'ing Tony and David.

Jesse

--Boundary-00=_ssCCBzsXjapiTYq
Content-Type: text/plain;
  charset="iso-8859-1";
  name="memmap-cleanup-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="memmap-cleanup-fix.patch"

diff -Napur -X /home/jbarnes/dontdiff linux-2.5-memmap.orig/arch/ia64/mm/init.c linux-2.5-memmap/arch/ia64/mm/init.c
--- linux-2.5-memmap.orig/arch/ia64/mm/init.c	2004-07-28 15:42:32.000000000 -0700
+++ linux-2.5-memmap/arch/ia64/mm/init.c	2004-07-28 15:38:19.000000000 -0700
@@ -433,14 +433,17 @@ virtual_memmap_init (u64 start, u64 end,
 }
 
 void
-memmap_init (struct page *start, unsigned long size, int nid,
-	     unsigned long zone, unsigned long start_pfn)
+memmap_init (unsigned long size, int nid, unsigned long zone,
+	     unsigned long start_pfn)
 {
 	if (!vmem_map)
 		memmap_init_zone(size, nid, zone, start_pfn);
 	else {
+		struct page *start;
 		struct memmap_init_callback_data args;
 
+		start = pfn_to_page(start_pfn);
+
 		args.start = start;
 		args.end = start + size;
 		args.nid = nid;
diff -Napur -X /home/jbarnes/dontdiff linux-2.5-memmap.orig/include/asm-ia64/pgtable.h linux-2.5-memmap/include/asm-ia64/pgtable.h
--- linux-2.5-memmap.orig/include/asm-ia64/pgtable.h	2004-07-28 15:42:04.000000000 -0700
+++ linux-2.5-memmap/include/asm-ia64/pgtable.h	2004-07-28 15:38:45.000000000 -0700
@@ -515,7 +515,7 @@ do {											\
 #  ifdef CONFIG_VIRTUAL_MEM_MAP
   /* arch mem_map init routine is needed due to holes in a virtual mem_map */
 #   define __HAVE_ARCH_MEMMAP_INIT
-    extern void memmap_init (struct page *start, unsigned long size, int nid, unsigned long zone,
+    extern void memmap_init (unsigned long size, int nid, unsigned long zone,
 			     unsigned long start_pfn);
 #  endif /* CONFIG_VIRTUAL_MEM_MAP */
 # endif /* !__ASSEMBLY__ */

--Boundary-00=_ssCCBzsXjapiTYq--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
