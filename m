Date: Fri, 22 Feb 2008 10:31:26 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch] my mmu notifiers
Message-ID: <20080222163126.GA32146@sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080219234049.GA27856@sgi.com> <20080221044256.GA15215@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080221044256.GA15215@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, andrea@qumranet.com
Cc: akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

> Also, I'll try to post the driver within the next few days. It is
> still in development but it compiles and can successfully run most
> workloads on a system simulator.

Here is the source of the GRU driver. It is still in development but
it compiles & runs (on IA64) in a system simulator.

The GRU is a hardware resource located in the chipset. It is
mmaped into the user address space. The GRU contains functions such
as load/store, scatter/gather, bcopy, etc. It is directly accessed
by user instructions using user virtual addresses. GRU instructions
(ex., bcopy) use user virtual addresses for operands. The GRU
contains a large TLB that is functionally very similar to processor TLBs.


This version uses the V7 mmu notifier patch from Christoph. The changes
to switch to Andrea's patch are trivial. (Note, however, that XPMEM still
requires Christoph's patch).


The interesting parts relating to mmu_notifiers are in the
following functions:
	gru_try_dropin() - does TLB dropins
	gru_flush_tlb_range() - TLB flushing
	gru_mmuops_...() - all functions starting with "gru_mmuops_"
	gru_register_mmu_notifier() - registers notifiers


I have no doubt that there are bugs in the code. If you find them, please
let me know where they are ....    :-)

Other comments appreciated, too.




Portions are rough but this 
 arch/ia64/sn/kernel/sn2/sn2_smp.c |    5 
 drivers/Makefile                  |    1 
 drivers/gru/Makefile              |    4 
 drivers/gru/gru.h                 |  348 +++++++++++++
 drivers/gru/gru_instructions.h    |  502 +++++++++++++++++++
 drivers/gru/grufault.c            |  557 ++++++++++++++++++++++
 drivers/gru/grufile.c             |  453 +++++++++++++++++
 drivers/gru/gruhandles.h          |  655 +++++++++++++++++++++++++
 drivers/gru/grukservices.c        |  129 +++++
 drivers/gru/grulib.h              |   84 +++
 drivers/gru/grumain.c             |  958 ++++++++++++++++++++++++++++++++++++++
 drivers/gru/grummuops.c           |  376 ++++++++++++++
 drivers/gru/gruprocfs.c           |  309 ++++++++++++
 drivers/gru/grutables.h           |  517 ++++++++++++++++++++
 drivers/sn/Kconfig                |    7 
 15 files changed, 4905 insertions(+)



Index: linux/drivers/Makefile
===================================================================
--- linux.orig/drivers/Makefile	2008-02-22 09:37:21.759206853 -0600
+++ linux/drivers/Makefile	2008-02-22 09:37:51.722947267 -0600
@@ -5,6 +5,7 @@
 # Rewritten to use lists instead of if-statements.
 #
 
+obj-$(CONFIG_GRU)		+= gru/
 obj-$(CONFIG_PCI)		+= pci/
 obj-$(CONFIG_PARISC)		+= parisc/
 obj-$(CONFIG_RAPIDIO)		+= rapidio/
Index: linux/drivers/gru/Makefile
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/Makefile	2008-02-22 09:37:51.742949764 -0600
@@ -0,0 +1,4 @@
+#
+EXTRA_CFLAGS += -Werror -Wall
+obj-$(CONFIG_GRU) := gru.o
+gru-y := grufile.o grumain.o grufault.o grummuops.o gruprocfs.o grukservices.o
Index: linux/drivers/sn/Kconfig
===================================================================
--- linux.orig/drivers/sn/Kconfig	2008-02-22 09:37:21.803212347 -0600
+++ linux/drivers/sn/Kconfig	2008-02-22 09:37:51.774953759 -0600
@@ -18,4 +18,11 @@ config SGI_IOC3
 	I/O controller or a PCI IOC3 serial card say Y.
 	Otherwise say N.
 
+config GRU
+	tristate "SGI GRU driver"
+	default y
+	---help---
+	This option enables basic support for the SGI UV GRU driver.
+
+
 endmenu
Index: linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
===================================================================
--- linux.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	2008-02-22 09:37:21.831215842 -0600
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2008-02-22 09:37:51.838961749 -0600
@@ -113,6 +113,11 @@ void sn_migrate(struct task_struct *task
 	pda_t *last_pda = pdacpu(task_thread_info(task)->last_cpu);
 	volatile unsigned long *adr = last_pda->pio_write_status_addr;
 	unsigned long val = last_pda->pio_write_status_val;
+	extern void gru_migrate_task(int, int);
+
+	if (current->mm && hlist_empty(&current->mm->mmu_notifier.head) &&
+	    task_thread_info(current)->last_cpu != task_cpu(current))
+		gru_migrate_task(task_thread_info(current)->last_cpu, task_cpu(current));
 
 	/* Drain PIO writes from old CPU's Shub */
 	while (unlikely((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK)
Index: linux/drivers/gru/gru.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/gru.h	2008-02-11 11:22:32.000000000 -0600
@@ -0,0 +1,348 @@
+/*
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All rights reserved.
+ */
+
+#ifndef _GRU_H_
+#define _GRU_H_
+
+#ifdef EMUSUPPORT
+#define _EMUSUPPORT 1
+#else
+#define _EMUSUPPORT 0
+#endif
+
+#ifndef __KERNEL__
+#include <stdlib.h>
+#else
+#include <linux/types.h>
+#endif
+
+/*
+ * Maximum number of GRU segments that a user can have open
+ * ZZZ temp - set higher for testing. Revisit.
+ */
+#define GRU_MAX_OPEN_CONTEXTS		32
+
+/*
+ * Constants for addressing user Gseg
+ */
+#define GRU_CB_BASE             0
+#define GRU_DS_BASE             0x20000
+#define GRU_HANDLE_STRIDE       256
+#define GRU_CACHE_LINE_BYTES	64
+
+
+/*
+ * GRU Segment limits
+ */
+#define GRU_MAX_CB		(128 - 16)
+#define GRU_DS_BYTES		(32768 - 1024)
+
+/*
+ * Pagesize used to map GRU GSeg
+ */
+#ifdef __ia64__
+#define GRU_GSEG_PAGESIZE	(256 * 1024)
+#define GRU_GSEG_PAGESIZE_SHIFT 18
+#else
+#define GRU_GSEG_PAGESIZE	(2 * 1024 * 1024UL)
+#endif
+
+
+/* Basic types  - improve type checking */
+typedef struct { void *cookie; } gru_cookie_t;
+typedef struct gru_control_segment_s gru_segment_t;
+typedef struct gru_control_block_s gru_control_block_t;
+
+/* Flags for GRU options on the gru_create_context() call */
+/* Select one of the follow 4 options to specify how TLB misses are handled */
+#define GRU_OPT_MISS_DEFAULT	0x0000	/* Use default mode */
+#define GRU_OPT_MISS_USER_POLL	0x0001	/* User will poll CB for faults */
+#define GRU_OPT_MISS_FMM_INTR	0x0002	/* Send interrut to cpu to
+					   handle fault */
+#define GRU_OPT_MISS_FMM_POLL	0x0003	/* Use system polling thread */
+#define GRU_OPT_MISS_MASK	0x0003	/* Mask for TLB MISS option */
+
+/*
+ * Ugly testing hack!! - if set, GRU thinks all pages are 1 TB.
+ * Works on emulator only
+ */
+#define GRU_OPT_FAKE_TB_PAGES	0x8000	/* EMU testing only - GRU uses
+					   1 TB pages */
+/*
+ * Get exception detail for CB that failed.
+ */
+
+/*
+ * Structure used to fetch exception detail for CBs that terminate with
+ * CBS_EXCEPTION
+ */
+struct control_block_extended_exc_detail {
+	unsigned long	cb;
+	int		opc;
+	int		ecause;
+	int		exopc;
+	long		exceptdet0;
+	int		exceptdet1;
+};
+
+
+
+/*----------------------------------------------------------------------------
+ * Inline functions for waiting for CB completion & checking CB status
+ */
+
+/*
+ * Control block status and exception codes
+ */
+#define CBS_IDLE			0
+#define CBS_EXCEPTION			1
+#define CBS_ACTIVE			2
+#define CBS_CALL_OS			3
+
+/* CB substatus bitmasks */
+#define CBSS_MSG_QUEUE_MASK		7
+#define CBSS_IMPLICIT_ABORT_ACTIVE_MASK	8
+
+/* CB substatus message queue values (low 3 bits of substatus) */
+#define CBSS_LB_OVERFLOWED		1
+#define CBSS_QLIMIT_REACHED		2
+#define CBSS_PAGE_OVERFLOW		3
+#define CBSS_AMO_NACKED			4
+#define CBSS_PUT_NACKED			5
+
+/*
+ * Control block definition for checking status
+ */
+struct gru_control_block_status {
+	volatile unsigned int	icmd		:1;
+	unsigned int		unused1		:31;
+	unsigned int		unused2		:24;
+	volatile unsigned int	istatus		:2;
+	volatile unsigned int	isubstatus	:4;
+	unsigned int		inused3		:2;
+};
+
+/* Get CB status */
+static inline int gru_get_cb_status(gru_control_block_t *cb)
+{
+	struct gru_control_block_status *cbs = (void *)cb;
+
+	return cbs->istatus;
+}
+
+/* Get CB message queue substatus */
+static inline int gru_get_cb_message_queue_substatus(gru_control_block_t *cb)
+{
+	struct gru_control_block_status *cbs = (void *)cb;
+
+	return cbs->isubstatus & CBSS_MSG_QUEUE_MASK;
+}
+
+/* Get CB substatus */
+static inline int gru_get_cb_substatus(gru_control_block_t *cb)
+{
+	struct gru_control_block_status *cbs = (void *)cb;
+
+	return cbs->isubstatus;
+}
+
+extern int gru_check_status_proc(gru_control_block_t *cb);
+extern int gru_wait_proc(gru_control_block_t *cb);
+extern void gru_wait_abort_proc(gru_control_block_t *cb);
+extern void gru_abort(int, gru_control_block_t *cb, char *str);
+
+/* Check the status of a CB. If the CB is in UPM mode, call the
+ * OS to handle the UPM status.
+ * Returns the CB status field value (0 for normal completion)
+ */
+static inline int gru_check_status(gru_control_block_t *cb)
+{
+	struct gru_control_block_status *cbs = (void *)cb;
+	int ret = cbs->istatus;
+
+	if (_EMUSUPPORT || ret == CBS_CALL_OS)
+		ret = gru_check_status_proc(cb);
+	return ret;
+}
+
+/* Wait for CB to complete.
+ * Returns the CB status field value (0 for normal completion)
+ */
+static inline int gru_wait(gru_control_block_t *cb)
+{
+	struct gru_control_block_status *cbs = (void *)cb;
+
+	if (cbs->istatus != CBS_IDLE)
+		return gru_wait_proc(cb);
+	return cbs->istatus;
+}
+
+/* Wait for CB to complete. Aborts program if error. (Note: error does NOT
+ * mean TLB mis - only fatal errors such as memory parity error or user
+ * bugs will cause termination.
+ */
+static inline void gru_wait_abort(gru_control_block_t *cb)
+{
+	struct gru_control_block_status *cbs = (void *)cb;
+
+	if (cbs->istatus != CBS_IDLE)
+		gru_wait_abort_proc(cb);
+}
+
+#ifndef __KERNEL__
+/* Name of DSO library */
+#define LIBGRU_SO		"libgru.so"
+
+/* Environment variables for controlling behavior*/
+
+/*
+ * Override TLBMISS fault map mode
+ * 	- "user_polling", "interrupt", "os_polling"
+ */
+#define GRU_TLBMISS_MODE_ENV	"GRU_TLBMISS_MODE"
+
+/* Set exception retry count for numalink timeout & memory parity */
+#define GRU_EXCEPTION_RETRY_ENV	"GRU_EXCEPTION_RETRY"
+#define GRU_EXCEPTION_RETRY_DEFAULT	3
+
+
+
+/*
+ * Create a new GRU context
+ *	cookie		- (OUT): magic identifier of the GRU segment
+ *	start 		- starting address for mmaped segments (NULL means
+ *			  OS picks address).
+ *	ctlblks 	- number of active control blocks
+ *	dataseg_bytes 	- number of data segment bytes
+ *	max_threads 	- maximum number of threads that will use the context
+ *	options 	- specifies various options
+ *			  (see constants below)
+ *
+ *  Returns 0 if successful, else error code returned in errno
+ */
+extern int gru_create_context(gru_cookie_t *cookie, void *start,
+			      unsigned int ctlblks, unsigned int dataseg_bytes,
+			      unsigned int max_threads, unsigned int options);
+
+
+/*
+ * Destroy a GRU context
+ * 	cookie	- cookie returned from gru_create_context()
+ *
+ * Returns:
+ * 	 0 - success
+ * 	-1 - failure. See errno for additional status
+ */
+extern int gru_destroy_context(gru_cookie_t cookie);
+
+
+/*
+ * Get the handle to a thread's private GRU context
+ * 	cookie		- cookie returned from gru_create_context()
+ * 	threadnum	- thread number (0 .. #threads-1)
+ *
+ * Returns pointer to GSeg if successful, else returns NULL.
+ * Error code returned in errno
+ */
+gru_segment_t *gru_get_thread_gru_segment(gru_cookie_t cookie, int threadnum);
+
+/*
+ * Flush a range of virtual addresses from the GRU TLB (intended for testcases
+ * only)
+ */
+int gru_flush_tlb(gru_segment_t *gseg, void *vaddr, size_t len);
+
+/*
+ * Unload a GRU context & free GRU resource. Will be reloaded on next
+ * reference.
+ */
+int gru_unload_context(void *gseg);
+
+/*
+ * Get struct control_block_extended_exc_detail for CB.
+ */
+extern int gru_get_cb_exception_detail(gru_control_block_t *cb,
+		       struct control_block_extended_exc_detail *excdet);
+
+/* Get a string that describes the CB exception detail. */
+extern char *gru_get_cb_exception_detail_str(int ret, gru_control_block_t *cb);
+
+
+/*
+ * Get a pointer to a control block
+ * 	gseg	- GSeg address returned from gru_get_thread_gru_segment()
+ * 	index	- index of desired CB
+ */
+static inline gru_control_block_t *gru_get_cb_pointer(gru_segment_t *gseg,
+						      int index)
+{
+	return (gru_control_block_t *)((void *)gseg + GRU_CB_BASE +
+				      index * GRU_HANDLE_STRIDE);
+}
+
+/*
+ * Get a pointer to a cacheline in the data segment portion of a GSeg
+ * 	gseg	- GSeg address returned from gru_get_thread_gru_segment()
+ * 	index	- index of desired cache line
+ */
+static inline void *gru_get_data_pointer(gru_segment_t *gseg, int index)
+{
+	return (void *)((void *)gseg + GRU_DS_BASE +
+			index * GRU_CACHE_LINE_BYTES);
+}
+
+/*
+ * Convert a vaddr into the tri index within the GSEG
+ * 	vaddr		- virtual address of within gseg
+ */
+static inline int gru_get_tri(void *vaddr)
+{
+	return (((unsigned long)vaddr & (GRU_GSEG_PAGESIZE - 1)) - GRU_DS_BASE);
+}
+#endif		/* ! __KERNEL__ */
+
+#ifdef EMUSUPPORT
+/*
+ * Hooks for instruction emulator
+ */
+enum {EMU_ID_SIM2_CHET, EMU_ID_SIM2_SIM2, EMU_ID_MEDUSA};
+int gru_emulator_id(void);
+
+extern void emuloguser(char *fmt, ...);
+extern int is_emu(void);
+# ifdef __KERNEL__
+   extern void emu_writeback_hook(void *p);
+   extern void emu_kwait_hook(void *p, int wait);
+#  define gru_flush_cache_hook(p)	emu_writeback_hook(p)
+#  define gru_emulator_wait_hook(p, w)	emu_kwait_hook(p, w)
+# else
+   extern void lib_cb_wait_hook(void *p, int wait) __attribute__ ((weak));
+   extern void lib_writeback_hook(void *p) __attribute__ ((weak));
+
+#  define gru_flush_cache_hook(p)				\
+	do {							\
+		if (lib_writeback_hook)				\
+			lib_writeback_hook(p);			\
+	 } while (0)
+
+#  define gru_emulator_wait_hook(p, w)				\
+	   do {							\
+		   if (lib_cb_wait_hook)			\
+			lib_cb_wait_hook(p, w);			\
+	   } while (0)
+
+# endif
+#else
+#define emuloguser		printf
+#define gru_flush_cache_hook(p)
+#define gru_emulator_wait_hook(p, w)
+#define is_emu() 0
+#endif
+
+#endif				/* _GRU_H_ */
Index: linux/drivers/gru/gru_instructions.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/gru_instructions.h	2008-01-25 08:13:07.135721041 -0600
@@ -0,0 +1,502 @@
+/*
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All rights reserved.
+ */
+
+#ifndef _GRU_INSTRUCTIONS_H_
+#define _GRU_INSTRUCTIONS_H_
+
+/*
+ * Instruction formats
+ */
+
+/*
+ * Generic instruction format.
+ * This definition has precise bit field definitions.
+ */
+struct gru_instruction_bits {
+    /* DW 0  - low */
+    unsigned int		icmd:      1;
+    unsigned char		ima:	   3;	/* CB_DelRep, unmapped mode */
+    unsigned char		reserved0: 4;
+    unsigned int		xtype:     3;
+    unsigned int		iaa0:      2;
+    unsigned int		iaa1:      2;
+    unsigned char		reserved1: 1;
+    unsigned char		opc:       8;	/* opcode */
+    unsigned char		exopc:     8;	/* extended opcode */
+    /* DW 0  - high */
+    unsigned int		idef2:    22;	/* TRi0 */
+    unsigned char		reserved2: 2;
+    unsigned char		istatus:   2;
+    unsigned char		isubstatus:4;
+    unsigned char		reserved3: 2;
+    /* DW 1 */
+    unsigned long		idef4;		/* 42 bits: TRi1, BufSize */
+    /* DW 2-6 */
+    unsigned long		idef1;		/* BAddr0 */
+    unsigned long		idef5;		/* Nelem */
+    unsigned long		idef6;		/* Stride, Operand1 */
+    unsigned long		idef3;		/* BAddr1, Value, Operand2 */
+    unsigned long		reserved4;
+    /* DW 7 */
+    unsigned long		avalue;		 /* AValue */
+};
+
+/*
+ * Generic instruction with friendlier names. This format is used
+ * for inline instructions.
+ */
+struct gru_instruction {
+    /* DW 0 */
+    volatile unsigned int	op32;    /* icmd,xtype,iaa0,ima,opc */
+    unsigned int		tri0;
+    /* DW 1-7 */
+    unsigned long		tri1_bufsize;
+    unsigned long		baddr0;
+    unsigned long		nelem;
+    unsigned long		op1_stride;
+    unsigned long		op2_value_baddr1;
+    unsigned long		reserved0;
+    unsigned long		avalue;
+};
+
+/* Some shifts and masks for the low 32 bits of a GRU command */
+#define GRU_CB_ICMD_SHFT	0
+#define GRU_CB_ICMD_MASK	0x1
+#define GRU_CB_XTYPE_SHFT	8
+#define GRU_CB_XTYPE_MASK	0x7
+#define GRU_CB_IAA0_SHFT	11
+#define GRU_CB_IAA0_MASK	0x3
+#define GRU_CB_IAA1_SHFT	13
+#define GRU_CB_IAA1_MASK	0x3
+#define GRU_CB_IMA_SHFT		1
+#define GRU_CB_IMA_MASK		0x3
+#define GRU_CB_OPC_SHFT		16
+#define GRU_CB_OPC_MASK		0xff
+#define GRU_CB_EXOPC_SHFT	24
+#define GRU_CB_EXOPC_MASK	0xff
+
+/* GRU instruction opcodes (opc field) */
+#define OP_NOP		0x00
+#define OP_BCOPY	0x01
+#define OP_VLOAD	0x02
+#define OP_IVLOAD	0x03
+#define OP_VSTORE	0x04
+#define OP_IVSTORE	0x05
+#define OP_VSET		0x06
+#define OP_IVSET	0x07
+#define OP_MESQ		0x08
+#define OP_GAMXR	0x09
+#define OP_GAMIR	0x0a
+#define OP_GAMIRR	0x0b
+#define OP_GAMER	0x0c
+#define OP_GAMERR	0x0d
+#define OP_BSTORE	0x0e
+#define OP_VFLUSH	0x0f
+
+
+/* Extended opcodes values (exopc field) */
+
+/* GAMIR - AMOs with implicit operands */
+#define EOP_IR_FETCH	0x01 /* Plain fetch of memory */
+#define EOP_IR_CLR	0x02 /* Fetch and clear */
+#define EOP_IR_INC	0x05 /* Fetch and increment */
+#define EOP_IR_DEC	0x07 /* Fetch and decrement */
+#define EOP_IR_QCHK1	0x0d /* Queue check, 64 byte msg */
+#define EOP_IR_QCHK2	0x0e /* Queue check, 128 byte msg */
+
+/* GAMIRR - Registered AMOs with implicit operands */
+#define EOP_IRR_FETCH	0x01 /* Registered fetch of memory */
+#define EOP_IRR_CLR	0x02 /* Registered fetch and clear */
+#define EOP_IRR_INC	0x05 /* Registered fetch and increment */
+#define EOP_IRR_DEC	0x07 /* Registered fetch and decrement */
+#define EOP_IRR_DECZ	0x0f /* Registered fetch and decrement, update on zero*/
+
+/* GAMER - AMOs with explicit operands */
+#define EOP_ER_SWAP	0x00 /* Exchange argument and memory */
+#define EOP_ER_OR	0x01 /* Logical OR with memory */
+#define EOP_ER_AND	0x02 /* Logical AND with memory */
+#define EOP_ER_XOR	0x03 /* Logical XOR with memory */
+#define EOP_ER_ADD	0x04 /* Add value to memory */
+#define EOP_ER_CSWAP	0x08 /* Compare with operand2, write operand1 if match*/
+#define EOP_ER_CADD	0x0c /* Queue check, operand1*64 byte msg */
+
+/* GAMERR - Registered AMOs with explicit operands */
+#define EOP_ERR_SWAP	0x00 /* Exchange argument and memory */
+#define EOP_ERR_OR	0x01 /* Logical OR with memory */
+#define EOP_ERR_AND	0x02 /* Logical AND with memory */
+#define EOP_ERR_XOR	0x03 /* Logical XOR with memory */
+#define EOP_ERR_ADD	0x04 /* Add value to memory */
+#define EOP_ERR_CSWAP	0x08 /* Compare with operand2, write operand1 if match*/
+#define EOP_ERR_EPOLL	0x09 /* Poll for equality */
+#define EOP_ERR_NPOLL	0x0a /* Poll for inequality */
+
+/* GAMXR - SGI Arithmetic unit */
+
+
+/* Transfer types (xtype field) */
+#define XTYPE_B		0x0	/* byte */
+#define XTYPE_S		0x1	/* short (2-byte) */
+#define XTYPE_W		0x2	/* word (4-byte) */
+#define XTYPE_DW	0x3	/* doubleword (8-byte) */
+#define XTYPE_RSVD4	0x4
+#define XTYPE_RSVD5	0x5
+#define XTYPE_CL	0x6	/* cacheline (64-byte) */
+#define XTYPE_RSVD7	0x7
+
+
+/* Instruction access attributes (iaa0, iaa1 fields) */
+#define IAA_RAM		0x0	/* normal cached RAM access */
+#define IAA_NCRAM	0x2	/* noncoherent RAM access */
+#define IAA_MMIO	0x1	/* noncoherent memory-mapped I/O space */
+#define IAA_REGISTER	0x3	/* memory-mapped registers, etc. */
+
+
+/* Instruction mode attributes (ima field) */
+#define IMA_CB_DELAY	0x1	/* hold read responses until status changes */
+#define IMA_UNMAPPED	0x2	/* bypass the TLBs (OS only) */
+#define IMA_INTERRUPT	0x4	/* Interrupt when instruction completes */
+
+/* CBE ecause bits */
+#define CBE_CAUSE_RI_BIT					0
+#define CBE_CAUSE_INVALID_INSTRUCTION_BIT			1
+#define CBE_CAUSE_UNMAPPED_MODE_FORBIDDEN_BIT			2
+#define CBE_CAUSE_PE_CHECK_DATA_ERROR_BIT			3
+#define CBE_CAUSE_IAA_GAA_MISMATCH_BIT				4
+#define CBE_CAUSE_DATA_SEGMENT_LIMIT_EXCEPTION_BIT		5
+#define CBE_CAUSE_OS_FATAL_TLB_FAULT_BIT			6
+#define CBE_CAUSE_EXECUTION_HW_ERROR_BIT			7
+#define CBE_CAUSE_TLBHW_ERROR_BIT				8
+#define CBE_CAUSE_RA_REQUEST_TIMEOUT_BIT			9
+#define CBE_CAUSE_HA_REQUEST_TIMEOUT_BIT			10
+#define CBE_CAUSE_RA_RESPONSE_FATAL_BIT				11
+#define CBE_CAUSE_RA_RESPONSE_NON_FATAL_BIT			12
+#define CBE_CAUSE_HA_RESPONSE_FATAL_BIT				13
+#define CBE_CAUSE_HA_RESPONSE_NON_FATAL_BIT			14
+#define CBE_CAUSE_ADDRESS_SPACE_DECODE_ERROR_BIT		15
+#define CBE_CAUSE_RESPONSE_DATA_ERROR_BIT			16
+#define CBE_CAUSE_PROTOCOL_STATE_DATA_ERROR_BIT			17
+
+#define CBE_CAUSE_RI				(1 << CBE_CAUSE_RI_BIT)
+#define CBE_CAUSE_INVALID_INSTRUCTION		(1 << CBE_CAUSE_INVALID_INSTRUCTION_BIT)
+#define CBE_CAUSE_UNMAPPED_MODE_FORBIDDEN	(1 << CBE_CAUSE_UNMAPPED_MODE_FORBIDDEN_BIT)
+#define CBE_CAUSE_PE_CHECK_DATA_ERROR		(1 << CBE_CAUSE_PE_CHECK_DATA_ERROR_BIT)
+#define CBE_CAUSE_IAA_GAA_MISMATCH		(1 << CBE_CAUSE_IAA_GAA_MISMATCH_BIT)
+#define CBE_CAUSE_DATA_SEGMENT_LIMIT_EXCEPTION	(1 << CBE_CAUSE_DATA_SEGMENT_LIMIT_EXCEPTION_BIT)
+#define CBE_CAUSE_OS_FATAL_TLB_FAULT		(1 << CBE_CAUSE_OS_FATAL_TLB_FAULT_BIT)
+#define CBE_CAUSE_EXECUTION_HW_ERROR		(1 << CBE_CAUSE_EXECUTION_HW_ERROR_BIT)
+#define CBE_CAUSE_TLBHW_ERROR			(1 << CBE_CAUSE_TLBHW_ERROR_BIT)
+#define CBE_CAUSE_RA_REQUEST_TIMEOUT		(1 << CBE_CAUSE_RA_REQUEST_TIMEOUT_BIT)
+#define CBE_CAUSE_HA_REQUEST_TIMEOUT		(1 << CBE_CAUSE_HA_REQUEST_TIMEOUT_BIT)
+#define CBE_CAUSE_RA_RESPONSE_FATAL		(1 << CBE_CAUSE_RA_RESPONSE_FATAL_BIT)
+#define CBE_CAUSE_RA_RESPONSE_NON_FATAL		(1 << CBE_CAUSE_RA_RESPONSE_NON_FATAL_BIT)
+#define CBE_CAUSE_HA_RESPONSE_FATAL		(1 << CBE_CAUSE_HA_RESPONSE_FATAL_BIT)
+#define CBE_CAUSE_HA_RESPONSE_NON_FATAL		(1 << CBE_CAUSE_HA_RESPONSE_NON_FATAL_BIT)
+#define CBE_CAUSE_ADDRESS_SPACE_DECODE_ERROR	(1 << CBE_CAUSE_ADDRESS_SPACE_DECODE_ERROR_BIT)
+#define CBE_CAUSE_RESPONSE_DATA_ERROR		(1 << CBE_CAUSE_RESPONSE_DATA_ERROR_BIT)
+#define CBE_CAUSE_PROTOCOL_STATE_DATA_ERROR	(1 << CBE_CAUSE_PROTOCOL_STATE_DATA_ERROR_BIT)
+
+
+/* Message queue head structure */
+union gru_mesqhead {
+	unsigned long	val;
+	struct {
+		unsigned int	head;
+		unsigned int	limit;
+	} q;
+};
+
+
+/* Generate the low word of a GRU instruction */
+static inline unsigned int
+opword(unsigned char opcode, unsigned char exopc, unsigned char xtype,
+       unsigned char iaa0, unsigned char iaa1,
+       unsigned char ima)
+{
+    return ((1 << GRU_CB_ICMD_SHFT) |
+	    (iaa0 << GRU_CB_IAA0_SHFT) |
+	    (iaa1 << GRU_CB_IAA1_SHFT) |
+	    (xtype << GRU_CB_XTYPE_SHFT) |
+	    (ima << GRU_CB_IMA_SHFT) |
+	    (opcode << GRU_CB_OPC_SHFT) |
+	    (exopc << GRU_CB_EXOPC_SHFT));
+}
+
+/*
+ * Prefetch a cacheline
+ * 	??? should I use actual "load" or hardware prefetch???
+ */
+static inline void gru_prefetch(void *p)
+{
+	*(volatile char *)p;
+}
+
+
+/*
+ * Use the "fc" instruction as a hook into the emulator
+ * 	ZZZ serialization requirements here???
+ */
+static inline void gru_flush_cache(void *p)
+{
+#if defined(__ia64__)
+	asm volatile ("fc %0"::"r" (p):"memory");
+#elif defined(__x86_64__)
+	asm volatile("clflush %0" :: "m" (p));
+#else
+#error "bad arch"
+#endif
+	gru_flush_cache_hook(p);	/* No code generated unless -D EMUSUPPORT */
+}
+
+
+/* Values for the "hints" parameter of the GRU instruction functions */
+#define HINT_CB_UNMAPPED	IMA_UNMAPPED
+#define HINT_CB_DELAY		IMA_CB_DELAY
+
+/* Convert "hints" to IMA */
+#define CB_IMA(h)		((h) & (IMA_UNMAPPED | IMA_CB_DELAY))
+
+/* Convert data segment cache line index into TRI0 / TRI1 value */
+#define GRU_DINDEX(i)		((i) * GRU_CACHE_LINE_BYTES)
+
+/* Inline functions for GRU instructions.
+ *     Note:
+ *     	- nelem and stride are in elements
+ *     	- tri0/tri1 is in bytes for the beginning of the data segment.
+ */
+static inline void gru_vload(gru_control_block_t *cb, void *mem_addr, int iaa0,
+		unsigned int tri0, unsigned char xtype, unsigned long nelem,
+		unsigned long stride, unsigned long hints)
+{
+	struct gru_instruction *ins = (struct gru_instruction *)cb;
+
+	ins->baddr0 = (long)mem_addr;
+	ins->nelem = nelem;
+	ins->tri0 = tri0;
+	ins->op1_stride = stride;
+	ins->op32 = opword(OP_VLOAD, 0, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_vstore(gru_control_block_t *cb, void *mem_addr, int iaa0,
+		unsigned int tri0, unsigned char xtype, unsigned long nelem,
+		unsigned long stride, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)mem_addr;
+	ins->nelem = nelem;
+	ins->tri0 = tri0;
+	ins->op1_stride = stride;
+	ins->op32 = opword(OP_VSTORE, 0, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_ivload(gru_control_block_t *cb, void *mem_addr, int iaa0,
+		unsigned int tri0, unsigned int tri1, unsigned char xtype,
+		unsigned long nelem, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)mem_addr;
+	ins->nelem = nelem;
+	ins->tri0 = tri0;
+	ins->tri1_bufsize = tri1;
+	ins->op32 = opword(OP_IVLOAD, 0, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_ivstore(gru_control_block_t *cb, void *mem_addr,
+		int iaa0, unsigned int tri0, unsigned int tri1,
+		unsigned char xtype, unsigned long nelem, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)mem_addr;
+	ins->nelem = nelem;
+	ins->tri0 = tri0;
+	ins->tri1_bufsize = tri1;
+	ins->op32 = opword(OP_IVSTORE, 0, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_vset(gru_control_block_t *cb, void *mem_addr, int iaa0,
+		unsigned long value, unsigned char xtype, unsigned long nelem,
+		unsigned long stride, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)mem_addr;
+	ins->op2_value_baddr1 = value;
+	ins->nelem = nelem;
+	ins->op1_stride = stride;
+	ins->op32 = opword(OP_VSET, 0, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_ivset(gru_control_block_t *cb, void *mem_addr, int iaa0,
+		unsigned long value, unsigned int tri1, unsigned char xtype,
+		unsigned long nelem, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)mem_addr;
+	ins->op2_value_baddr1 = value;
+	ins->nelem = nelem;
+	ins->tri1_bufsize = tri1;
+	ins->op32 = opword(OP_IVSET, 0, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_vflush(gru_control_block_t *cb, void *mem_addr, int iaa0,
+		unsigned long nelem, unsigned char xtype, unsigned long stride,
+		unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)mem_addr;
+	ins->op1_stride = stride;
+	ins->nelem = nelem;
+	ins->op32 = opword(OP_VFLUSH, 0, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_nop(gru_control_block_t *cb, int hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->op32 = opword(OP_NOP, 0, 0, 0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+
+static inline void gru_bcopy(gru_control_block_t *cb, const void *src,
+		int iaa0, void *dest, int iaa1,
+		unsigned long nelem, unsigned int xtype, unsigned int tri0,
+		unsigned int bufsize, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)src;
+	ins->op2_value_baddr1 = (long)dest;
+	ins->nelem = nelem;
+	ins->tri0 = tri0;
+	ins->tri1_bufsize = bufsize;
+	ins->op1_stride = 1;
+	ins->op32 = opword(OP_BCOPY, 0, xtype, iaa0, iaa1, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_bstore(gru_control_block_t *cb, const void *src,
+		void *dest, int iaa0, unsigned long nelem, unsigned int xtype,
+		unsigned int tri0, unsigned int stride, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)src;
+	ins->op2_value_baddr1 = (long)dest;
+	ins->nelem = nelem;
+	ins->tri0 = tri0;
+	ins->op1_stride = stride;
+	ins->op32 = opword(OP_BSTORE, 0, xtype, iaa0, iaa0, CB_IMA(hints));
+	/* ZZZ iaa0 or iaa1 */
+	gru_flush_cache(ins);
+}
+
+static inline void gru_gamir(gru_control_block_t *cb, int exopc, void *src,
+		int iaa0, unsigned int xtype, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)src;
+	ins->op32 = opword(OP_GAMIR, exopc, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_gamirr(gru_control_block_t *cb, int exopc, void *src,
+		int iaa0, unsigned int xtype, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)src;
+	ins->op32 = opword(OP_GAMIRR, exopc, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_gamer(gru_control_block_t *cb, int exopc, void *src,
+		int iaa0, unsigned int xtype,
+		unsigned long operand1, unsigned long operand2,
+		unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)src;
+	ins->op2_value_baddr1 = operand1;
+	ins->op1_stride = operand2;
+	ins->op32 = opword(OP_GAMER, exopc, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_gamerr(gru_control_block_t *cb, int exopc, void *src,
+		int iaa0, unsigned int xtype, unsigned long operand1,
+		unsigned long operand2, unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)src;
+	ins->op2_value_baddr1 = operand1;
+	ins->op1_stride = operand2;
+	ins->op32 = opword(OP_GAMERR, exopc, xtype, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline void gru_mesq(gru_control_block_t *cb, void *queue, int iaa0,
+		unsigned long msg_bytes, unsigned long tri0,
+		unsigned long hints)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	ins->baddr0 = (long)queue;
+	ins->nelem = msg_bytes / GRU_CACHE_LINE_BYTES;
+	ins->tri0 = tri0;
+	ins->op32 = opword(OP_MESQ, 0, XTYPE_CL, iaa0, 0, CB_IMA(hints));
+	gru_flush_cache(ins);
+}
+
+static inline unsigned long gru_get_amo_value(gru_control_block_t *cb)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	return ins->avalue;
+}
+
+static inline int gru_get_amo_value_head(gru_control_block_t *cb)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	return (ins->avalue & 0xffffffff);
+}
+
+static inline int gru_get_amo_value_limit(gru_control_block_t *cb)
+{
+	struct gru_instruction *ins = (void *)cb;
+
+	return ins->avalue >> 32;
+}
+
+static inline union gru_mesqhead  gru_mesq_head(int head, int limit)
+{
+	union gru_mesqhead mqh;
+
+	mqh.q.head = head;
+	mqh.q.limit = limit;
+	return mqh;
+}
+
+
+#endif				/* _GRU_INSTRUCTIONS_H_ */
Index: linux/drivers/gru/grufault.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/grufault.c	2008-02-19 10:19:25.876327857 -0600
@@ -0,0 +1,557 @@
+/*
+ * SN Platform GRU Driver
+ *
+ *              FAULT HANDLER FOR GRU DETECTED TLB MISSES
+ *
+ * This file contains code that handles TLB misses within the GRU.
+ * These misses are reported either via interrupts or user polling of
+ * the user CB.
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+#ifdef EMU
+#include "preemu.h"
+#endif
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/hugetlb.h>
+#include <linux/device.h>
+#include <asm/uaccess.h>
+#include <asm/pgtable.h>
+#include "gru.h"
+#include "grutables.h"
+#include "grulib.h"
+#include "gru_instructions.h"
+#ifdef EMU
+#include "emu.h"
+#endif
+
+/*
+ * Test if a physical address is a valid GRU GSEG address
+ */
+static inline int is_gru_paddr(unsigned long paddr)
+{
+	return (paddr >= gru_start_paddr && paddr < gru_end_paddr);
+}
+
+/*
+ * Find and lock the gts that contains the specified user vaddr.
+ *
+ * Returns:
+ * 	- *gts with the mmap_sem locked for read and the GTS locked.
+ *	- NULL if vaddr invalid OR is not a valid GSEG vaddr.
+ */
+
+static struct gru_thread_state *gru_find_and_lock_gts(unsigned long vaddr)
+{
+	struct vm_area_struct *vma;
+	struct gru_thread_state *gts;
+
+	down_read(&current->mm->mmap_sem);
+	vma = find_vma(current->mm, vaddr);
+	if (vma && vma->vm_start <= vaddr && vma->vm_ops == &gru_vm_ops) {
+		gts = gru_find_thread_state(vma, TSID(vaddr - vma->vm_start));
+		if (gts) {
+			down(&gts->ts_ctxsem);
+			return gts;
+		}
+	}
+	up_read(&current->mm->mmap_sem);
+	return NULL;
+}
+
+/*
+ * Unlock a GTS that was previously locked with gru_find_and_lock_gts().
+ */
+static void gru_unlock_gts(struct gru_thread_state *gts)
+{
+	up(&gts->ts_ctxsem);
+	up_read(&current->mm->mmap_sem);
+}
+
+/*
+ * Set a CB.istatus to active using a user virtual address. This must be done
+ * just prior to a TFH RESTART. The new cb.istatus is an in-cache status ONLY.
+ * If the line is evicted, the status may be lost. The in-cache update
+ * is necessary to prevent the user from seeing a stale cb.istatus that will
+ * change as soon as the TFH restart is complete. Races may cause an
+ * occasional failure to clear the cb.istatus, but that is ok.
+ */
+static void gru_cb_set_istatus_active(unsigned long __user *cb)
+{
+	union {
+		struct gru_instruction_bits bits;
+		unsigned long dw;
+	} u;
+
+	if (cb) {
+		get_user(u.dw, cb);
+		u.bits.istatus = CBS_ACTIVE;
+		put_user(u.dw, cb);
+	}
+}
+
+/*
+ * Convert a interrupt IRQ to a pointer to the GRU GTS that caused the
+ * interrupt. Interrupts are always sent to a cpu on the blade that contains the
+ * GRU (except for headless blades which are not currently supported). A blade
+ * has N grus; a block of N consecutive IRQs is assigned to the GRUs. The IRQ
+ * number uniquely identifies the GRU chipleton the local blade that caused the
+ * interrupt. Always called in interrupt context.
+ */
+static inline struct gru_state *irq_to_gru(int irq)
+{
+	return &gru_base[numa_blade_id()]->bs_grus[irq - IRQ_GRU];
+}
+
+/*
+ * Read & clear a TFM
+ *
+ * The GRU has an array of fault maps. A map is private to a cpu
+ * Only one cpu will be accessing a cpu's fault map.
+ *
+ * This function scans the cpu-private fault map & clears all bits that
+ * are set. The function returns a bitmap that indicates the bits that
+ * were cleared. Note that sense the maps may be updated asynchronously by
+ * the GRU, atomic operations must be used to clear bits.
+ */
+static void get_clear_fault_map(struct gru_state *gru,
+				struct gru_tlb_fault_map *map)
+{
+	unsigned long i, k;
+	struct gru_tlb_fault_map *tfm;
+
+	tfm = get_tfm_for_cpu(gru, gru_cpu_fault_map_id());
+	prefetchw(tfm);		/* Helps on hardware, required for emulator */
+	for (i = 0; i < BITS_TO_LONGS(GRU_NUM_CBE); i++) {
+		k = tfm->fault_bits[i];
+		if (k)
+			k = xchg(&tfm->fault_bits[i], 0UL);
+		map->fault_bits[i] = k;
+	}
+
+	/*
+	 * Not functionally required but helps performance. (Required
+	 * on emulator)
+	 */
+	gru_flush_cache(tfm);
+}
+
+/*
+ * Atomic (interrupt context) & non-atomic (user context) functions to
+ * convert a vaddr into a physical address & pagesize.
+ * 	returns:
+ * 		  0 - successful
+ * 		< 0 - error code
+ * 		  1 - (atomic only) try again in non-atomic context
+ */
+static int non_atomic_pte_lookup(struct vm_area_struct *vma,
+				 unsigned long vaddr, int write,
+				 unsigned long *paddr, int *pagesize)
+{
+	struct page *page;
+
+	if (get_user_pages
+	    (current, current->mm, vaddr, 1, write, 1, &page, NULL) <= 0)
+		return -EFAULT;
+	*paddr = page_to_phys(page);
+	*pagesize =
+	    is_vm_hugetlb_page(vma) ? GRU_PAGESIZE(HPAGE_SHIFT) :
+	    GRU_PAGESIZE(PAGE_SHIFT);
+	put_page(page);
+	return 0;
+}
+
+static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
+			     int write, unsigned long *paddr, int *pagesize)
+{
+	struct page *page;
+
+	page = follow_page(vma, vaddr, (write ? FOLL_WRITE : 0));
+	if (!page)
+		return 1;
+	*paddr = page_to_phys(page);
+	*pagesize =
+	    is_vm_hugetlb_page(vma) ? GRU_PAGESIZE(HPAGE_SHIFT) :
+	    GRU_PAGESIZE(PAGE_SHIFT);
+	return 0;
+}
+
+/*
+ * Drop a TLB entry into the GRU. The fault is described by info in an TFH.
+ *	Input:
+ *		cb    Address of user CBR. Null if not running in user context
+ * 	Return:
+ * 		  0 = dropin, exception, or switch to UPM successful
+ * 		  1 = range invalidate active
+ * 		  2 = asid == 0
+ * 		< 0 = error code
+ *
+ */
+static int gru_try_dropin(struct gru_thread_state *gts,
+			  struct gru_tlb_fault_handle *tfh,
+			  unsigned long __user *cb)
+{
+	struct mm_struct *mm = gts->ts_mm;
+	struct vm_area_struct *vma;
+	int pagesize, asid, write, ret;
+	unsigned long paddr, vaddr;
+
+	/*
+	 * NOTE: The GRU contains magic hardware that eliminates races between
+	 * TLB invalidates and TLB dropins. If an invalidate occurs
+	 * in the window between reading the TFH and the subsequent TLB dropin,
+	 * the dropin is ignored. This eliminates the need for additional locks.
+	 */
+	write = (tfh->cause & TFHCAUSE_TLB_MOD) != 0;
+	vaddr = tfh->missvaddr;
+	asid = tfh->missasid;
+	if (asid == 0)
+		goto failnoasid;
+
+	rmb();	/* TFH must be cache resident before reading ms_range_active */
+
+	/*
+	 * TFH is cache resident - at least briefly. Fail the dropin
+	 * if a range invalidate is active.
+	 */
+	if (atomic_read(&gts->ts_ms->ms_range_active))
+		goto failactive;
+
+	vma = find_vma(mm, vaddr);
+	if (!vma)
+		goto failinval;
+
+	/*
+	 * Atomic lookup is faster & usually works even if called in non-atomic
+	 * context.
+	 */
+	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &pagesize);
+	if (ret) {
+		if (!cb)
+			goto failupm;
+		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &pagesize))
+			goto failinval;
+	}
+	if (is_gru_paddr(paddr))
+		goto failinval;
+	gru_cb_set_istatus_active(cb);
+	tfh_write_restart(tfh, paddr, GAA_RAM, vaddr, asid, write, pagesize);
+	STAT(tlb_dropin);
+	gru_dbg(grudev,
+		"%s: tfh 0x%p, vaddr 0x%lx, asid 0x%x, ps %d, paddr 0x%lx\n",
+		ret ? "non-atomic" : "atomic", tfh, vaddr, asid, pagesize,
+		paddr);
+	return 0;
+
+failnoasid:
+	/* No asid (delayed unload). */
+	STAT(tlb_dropin_fail_no_asid);
+	gru_dbg(grudev, "FAILED no_asid tfh: 0x%p, vaddr 0x%lx\n", tfh, vaddr);
+	if (!cb)
+		tfh_user_polling_mode(tfh);
+	return 2;
+
+failupm:
+	/* Atomic failure switch CBR to UPM */
+	STAT(tlb_dropin_fail_upm);
+	gru_dbg(grudev, "FAILED upm tfh: 0x%p, vaddr 0x%lx\n", tfh, vaddr);
+	tfh_user_polling_mode(tfh);
+	return 1;
+
+failinval:
+	/* All errors (atomic & non-atomic) switch CBR to EXCEPTION state */
+	STAT(tlb_dropin_fail_invalid);
+	gru_dbg(grudev, "FAILED inval tfh: 0x%p, vaddr 0x%lx\n", tfh, vaddr);
+	tfh_exception(tfh);
+	return -EFAULT;
+
+failactive:
+	/* Range invalidate active. Switch to UPM iff atomic */
+	STAT(tlb_dropin_fail_range_active);
+	gru_dbg(grudev, "FAILED range active: tfh 0x%p, vaddr 0x%lx\n",
+		tfh, vaddr);
+	if (!cb)
+		tfh_user_polling_mode(tfh);
+	return 1;
+}
+
+/*
+ * Process an external interrupt from the GRU. This interrupt is
+ * caused by a TLB miss.
+ * Note that this is the interrupt handler that is registered with linux
+ * interrupt handlers.
+ */
+irqreturn_t gru_intr(int irq, void *dev_id)
+{
+	struct gru_state *gru;
+	struct gru_tlb_fault_map map;
+	struct gru_thread_state *gts;
+	struct gru_tlb_fault_handle *tfh = NULL;
+	int cbrnum, ctxnum;
+
+	STAT(intr);
+
+	gru = irq_to_gru(irq);
+	if (!gru) {
+		dev_err(grudev, "GRU: invalid interrupt: cpu %d, irq %d\n",
+			raw_smp_processor_id(), irq);
+		return IRQ_NONE;
+	}
+	get_clear_fault_map(gru, &map);
+	gru_dbg(grudev, "irq %d, gru %x, map 0x%lx\n", irq, gru->gs_gid,
+		map.fault_bits[0]);
+
+	for_each_cbr_in_tfm(cbrnum, map.fault_bits) {
+		tfh = get_tfh_by_index(gru, cbrnum);
+		prefetchw(tfh);	/* Helps on hdw, required for emulator */
+
+		/*
+		 * When hardware sets a bit in the faultmap, it implicitly
+		 * locks the GRU context so that it cannot be unloaded.
+		 * gs_gts cannot change until a TFH start/writestart command
+		 * is issued
+		 */
+		ctxnum = tfh->ctxnum;
+		gts = gru->gs_gts[ctxnum];
+		if (down_read_trylock(&gts->ts_mm->mmap_sem)) {
+			gru_try_dropin(gts, tfh, NULL);
+			up_read(&gts->ts_mm->mmap_sem);
+		} else {
+			tfh_user_polling_mode(tfh);
+		}
+	}
+	return IRQ_HANDLED;
+}
+
+/*
+ * UPM call but nothing found in TFH. It _could_ be a race that was lost,
+ * a user bug, or a hardware bug. Try to determine which.
+ */
+static int gru_check_for_bug(unsigned long arg,
+			     struct gru_tlb_fault_handle *tfh)
+{
+	struct gru_instruction_bits ins, *cb = (void *)arg;
+
+	STAT(call_os_check_for_bug);
+	gru_dbg(grudev, "cb %p\n", cb);
+	if (copy_from_user(&ins, cb, sizeof(ins)))
+		return -EFAULT;
+	if (cb->istatus != CBS_CALL_OS)
+		return 0;
+	barrier();
+	gru_flush_cache(cb);
+	if (copy_from_user(&ins, cb, sizeof(ins)))
+		return -EFAULT;
+	if (cb->istatus != CBS_CALL_OS) {
+		dev_info(grudev, "cb %p: Possible coherency bug\n", cb);
+		return 0;
+	}
+
+	gru_flush_cache(tfh);
+	barrier();
+
+	if (tfh->state == TFHSTATE_MISS_UPM) {
+		dev_info(grudev, "tfh %p: Possible coherency bug\n", cb);
+		return -EAGAIN;
+	}
+	gru_dbg(grudev, "cb %p: CB in UPM state but no TFH fault\n", cb);
+	return -EIO;
+
+}
+
+static int gru_user_dropin(struct gru_thread_state *gts,
+			   struct gru_tlb_fault_handle *tfh,
+			   unsigned long __user *cb)
+{
+	struct gru_mm_struct *gms = gts->ts_ms;
+	int ret;
+
+	while (1) {
+		wait_event(gms->ms_wait_queue,
+			   atomic_read(&gms->ms_range_active) == 0);
+		prefetchw(tfh);	/* Helps on hdw, required for emulator */
+		ret = gru_try_dropin(gts, tfh, cb);
+		if (ret <= 0)
+			return ret;
+		STAT(call_os_wait_queue);
+	}
+}
+
+/*
+ * This interface is called as a result of a user detecting a "call OS" bit
+ * in a user CB. Normally means that a TLB fault has occurred.
+ * 	cb - user virtual address of the CB
+ */
+int gru_handle_user_call_os(unsigned long cb)
+{
+	struct gru_tlb_fault_handle *tfh;
+	struct gru_thread_state *gts;
+	unsigned long __user *cbp;
+	int ucbnum, cbrnum, ret = -EINVAL;
+
+	STAT(call_os);
+	gru_dbg(grudev, "address 0x%lx\n", cb);
+
+	/* sanity check the cb pointer */
+	ucbnum = UCBNUM(cb);
+	if ((cb & (GRU_HANDLE_STRIDE - 1)) || ucbnum >= GRU_NUM_CB)
+		return -EINVAL;
+	cbp = (unsigned long *)cb;
+
+	gts = gru_find_and_lock_gts(cb);
+	if (!gts)
+		return -EINVAL;
+
+	if (ucbnum >= gts->ts_cbr_au_count * GRU_CBR_AU_SIZE) {
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	/*
+	 * If force_unload is set, the UPM TLB fault is phony. The task
+	 * has migrated to another node and the GSEG must be moved. Just
+	 * unload the context. The task will page fault and assign a new
+	 * context.
+	 */
+	ret = -EAGAIN;
+	cbrnum = thread_cbr_number(gts, ucbnum);
+	if (gts->ts_force_unload) {
+		gru_unload_context(gts, 1);
+	} else if (gts->ts_gru) {
+		tfh = get_tfh_by_index(gts->ts_gru, cbrnum);
+		prefetchw(tfh);	/* Helps on hdw, required for emulator */
+		if (tfh->state == TFHSTATE_IDLE) {
+			gru_dbg(grudev, "UNEXPECTED: tfh %p idle\n", tfh);
+			gru_flush_cache(tfh);
+			STAT(call_os_tfh_idle);
+		}
+		if (tfh->state == TFHSTATE_MISS_UPM)
+			ret = gru_user_dropin(gts, tfh, cbp);
+		else
+			ret = gru_check_for_bug(cb, tfh);
+	}
+exit:
+	gru_unlock_gts(gts);
+	return ret;
+}
+
+/*
+ * Fetch the exception detail information for a CB that terminated with
+ * an exception.
+ */
+int gru_get_exception_detail(unsigned long arg)
+{
+	struct control_block_extended_exc_detail excdet;
+	struct gru_control_block_extended *cbe;
+	struct gru_thread_state *gts;
+	int ucbnum, cbrnum, ret;
+
+	STAT(user_exception);
+	if (copy_from_user(&excdet, (void __user *)arg, sizeof(excdet)))
+		return -EFAULT;
+
+	gru_dbg(grudev, "address 0x%lx\n", excdet.cb);
+	gts = gru_find_and_lock_gts(excdet.cb);
+	if (!gts)
+		return -EINVAL;
+
+	if (gts->ts_gru) {
+		ucbnum = UCBNUM(excdet.cb);
+		cbrnum = thread_cbr_number(gts, ucbnum);
+		cbe = get_cbe_by_index(gts->ts_gru, cbrnum);
+		excdet.opc = cbe->opccpy;
+		excdet.exopc = cbe->exopccpy;
+		excdet.ecause = cbe->ecause;
+		excdet.exceptdet0 = cbe->idef1upd;
+		excdet.exceptdet1 = cbe->idef3upd;
+		ret = 0;
+	} else {
+		ret = -EAGAIN;
+	}
+	gru_unlock_gts(gts);
+
+	gru_dbg(grudev, "address 0x%lx, ecause 0x%x\n", excdet.cb,
+		excdet.ecause);
+	if (!ret && copy_to_user((void __user *)arg, &excdet, sizeof(excdet)))
+		ret = -EFAULT;
+	return ret;
+}
+
+/*
+ * User request to unload a context. Content is saved for possible reload.
+ */
+int gru_user_unload_context(unsigned long arg)
+{
+	struct gru_thread_state *gts;
+	struct gru_unload_context_req req;
+
+	STAT(user_unload_context);
+	if (copy_from_user(&req, (void __user *)arg, sizeof(req)))
+		return -EFAULT;
+
+	gru_dbg(grudev, "vaddr 0x%lx\n", req.vaddr);
+
+	gts = gru_find_and_lock_gts(req.vaddr);
+	if (!gts)
+		return -EINVAL;
+
+	if (gts->ts_gru)
+		gru_unload_context(gts, 1);
+	gru_unlock_gts(gts);
+
+	return 0;
+}
+
+/*
+ * User request to flush a range of virtual addresses from the GRU TLB
+ * (Mainly for testing).
+ */
+int gru_user_flush_tlb(unsigned long arg)
+{
+	struct gru_thread_state *gts;
+	struct gru_flush_tlb_req req;
+
+	STAT(user_flush_tlb);
+	if (copy_from_user(&req, (void __user *)arg, sizeof(req)))
+		return -EFAULT;
+
+	gru_dbg(grudev, "gseg 0x%lx, vaddr 0x%lx, len 0x%lx\n", req.gseg,
+		req.vaddr, req.len);
+
+	gts = gru_find_and_lock_gts(req.gseg);
+	if (!gts)
+		return -EINVAL;
+
+	gru_flush_tlb_range(gts->ts_ms, req.vaddr, req.vaddr + req.len);
+	gru_unlock_gts(gts);
+
+	return 0;
+}
+
+/*
+ * Register the current task as the user of the GSEG slice.
+ * Needed for TLB fault interrupt targeting.
+ */
+int gru_set_task_slice(long address)
+{
+	struct gru_thread_state *gts;
+
+	STAT(set_task_slice);
+	gru_dbg(grudev, "address 0x%lx\n", address);
+	gts = gru_find_and_lock_gts(address);
+	if (!gts)
+		return -EINVAL;
+
+	gts->ts_tgid_owner = current->tgid;
+	gru_unlock_gts(gts);
+
+	return 0;
+}
Index: linux/drivers/gru/grufile.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/grufile.c	2008-02-19 09:30:53.000000000 -0600
@@ -0,0 +1,453 @@
+/*
+ * SN Platform GRU Driver
+ *
+ *              FILE OPERATIONS & DRIVER INITIALIZATION
+ *
+ * This file supports the user system call for file open, close, mmap, etc.
+ * This also incudes the driver initialization code.
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+#ifdef EMU
+#include "preemu.h"
+#endif
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/smp_lock.h>
+#include <linux/spinlock.h>
+#include <linux/device.h>
+#include <linux/miscdevice.h>
+#include <linux/proc_fs.h>
+#include <linux/interrupt.h>
+#include <asm/uaccess.h>
+#include "gru.h"
+#include "grulib.h"
+#include "grutables.h"
+#ifdef __ia64__
+#include <asm/sn/addrs.h>
+#include <asm/sn/sn_cpuid.h>
+#else
+#define cnodeid_to_nasid(n)	0	/* ZZZ fixme */
+#endif
+#ifdef EMU
+#include "emu.h"
+#endif
+
+#ifndef EMU
+struct gru_stats_s gru_stats;
+struct gru_blade_state *gru_base[GRU_MAX_BLADES];
+unsigned long gru_start_paddr, gru_end_paddr;
+#endif
+
+static struct file_operations gru_fops;
+static struct miscdevice gru_miscdev;
+
+/*
+ * gru_vma_open
+ *
+ * Called when a device mapping is created by a means other than mmap
+ * (via fork, etc.).  Increments the reference count on the underlying
+ * gru data so it is not freed prematurely.
+ */
+STATIC void gru_vma_open(struct vm_area_struct *vma)
+{
+	struct gru_thread_state *gts;
+	struct gru_thread_data *gtd;
+
+	if (IS_THREAD_DATA(vma->vm_private_data)) {
+		gtd = vma->vm_private_data;
+	} else {
+		gts = gru_find_thread_state(vma, TSID(0));
+		down(&gts->ts_ctxsem);
+		zap_page_range(vma, UGRUADDR(gts), GRU_GSEG_PAGESIZE, NULL);
+		if (gts->ts_gru)
+			gru_unload_context(gts, 1);
+		gtd = gts->ts_td;
+		up(&gts->ts_ctxsem);
+	}
+
+	atomic_inc(&gtd->td_refcnt);
+	vma->vm_private_data = gtd;
+	gru_dbg(grudev, "vma %p, gtd %p, refcnt %d\n", vma, gtd,
+		atomic_read(&gtd->td_refcnt));
+}
+
+/*
+ * gru_vma_close
+ *
+ * Called when unmapping a device mapping. Frees all gru resources
+ * and tables belonging to the vma.
+ */
+STATIC void gru_vma_close(struct vm_area_struct *vma)
+{
+	struct gru_vma_data *vdata;
+	struct gru_thread_state *gts;
+	struct list_head *entry, *next;
+
+	if (IS_THREAD_DATA(vma->vm_private_data)) {
+		gru_dbg(grudev, "vma %p, td %p\n", vma, vma->vm_private_data);
+		gtd_drop(vma->vm_private_data);
+	} else {
+		vdata = vma->vm_private_data;
+		vma->vm_private_data = NULL;
+		gru_dbg(grudev, "vma %p, vdata %p\n", vma, vdata);
+		list_for_each_safe(entry, next, &vdata->vd_head) {
+			gts =
+			    list_entry(entry, struct gru_thread_state, ts_next);
+			list_del(&gts->ts_next);
+			down(&gts->ts_ctxsem);
+			if (gts->ts_gru)
+				gru_unload_context(gts, 0);
+			up(&gts->ts_ctxsem);
+			gtd_drop(gts->ts_td);
+			gts_drop(gts);
+		}
+		kfree(vdata);
+		STAT(vdata_free);
+	}
+}
+
+/*
+ * gru_file_open
+ *
+ * Called when the GRU is opened.
+ */
+STATIC int gru_file_open(struct inode *inode, struct file *file)
+{
+	struct gru_file_data *fdata;
+
+	fdata = kzalloc(sizeof(*fdata), GFP_KERNEL);
+	if (!fdata)
+		return -ENOMEM;
+
+	STAT(fdata_alloc);
+	file->private_data = (void *)fdata;
+	gru_dbg(grudev, "file %p, fdata %p\n", file, fdata);
+	return 0;
+}
+
+/*
+ * gru_file_release
+ *
+ * Called when the GRU is released - last "open" has been closed.
+ */
+STATIC int gru_file_release(struct inode *inode, struct file *file)
+{
+	gru_dbg(grudev, "file %p, fdata %p\n", file, file->private_data);
+	kfree(file->private_data);
+	STAT(fdata_free);
+	return 0;
+}
+
+/*
+ * gru_file_mmap
+ *
+ * Called when mmaping the device.  Initializes the vma with a fault handler
+ * and private data structure necessary to allocate, track, and free the
+ * underlying pages.
+ */
+STATIC int gru_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct gru_file_data *fdata = file->private_data;
+
+	if ((vma->vm_flags & (VM_SHARED | VM_WRITE)) != (VM_SHARED | VM_WRITE))
+		return -EPERM;
+
+	if (vma->vm_start & (GRU_GSEG_PAGESIZE - 1) ||
+	    CONTEXT_WINDOW_BYTES(fdata->fd_thread_slices) !=
+	    vma->vm_end - vma->vm_start)
+		return -EINVAL;
+
+	vma->vm_flags |=
+	    (VM_IO | VM_LOCKED | VM_DONTEXPAND | VM_PFNMAP | VM_RESERVED);
+	vma->vm_page_prot = PAGE_SHARED;
+	vma->vm_ops = &gru_vm_ops;
+
+	vma->vm_private_data = gru_alloc_vma_data(vma, TSID(0), NULL);
+	if (!vma->vm_private_data)
+		return -ENOMEM;
+
+	gru_dbg(grudev, "file %p, fdata %p, vaddr 0x%lx, vma %p, vdata %p\n",
+		file, file->private_data, vma->vm_start, vma,
+		vma->vm_private_data);
+	return 0;
+}
+
+/*
+ * Create a new GRU context
+ */
+static int gru_create_new_context(unsigned long arg,
+				  struct gru_file_data *fdata)
+{
+	struct gru_create_context_req req;
+
+	if (copy_from_user(&req, (void __user *)arg, sizeof(req)))
+		return -EFAULT;
+
+	if (req.data_segment_bytes == 0
+	    || req.data_segment_bytes > GRU_NUM_USER_DSR_BYTES)
+		return -EINVAL;
+	if (req.control_blocks == 0 || req.control_blocks > GRU_NUM_USER_CBR)
+		return -EINVAL;
+	if (req.maximum_thread_count == 0 || req.maximum_thread_count > NR_CPUS)
+		return -EINVAL;
+
+	if (!(req.options & GRU_OPT_MISS_MASK))
+		req.options |= GRU_OPT_MISS_USER_POLL;	/* ZZZ change default */
+
+	fdata->fd_dsr_au_count = GRU_DS_BYTES_TO_AU(req.data_segment_bytes);
+	fdata->fd_user_options = req.options;
+	fdata->fd_cbr_au_count = GRU_CB_COUNT_TO_AU(req.control_blocks);
+	fdata->fd_thread_slices = req.maximum_thread_count;
+
+	return 0;
+}
+
+/*
+ * Get GRU configuration info (temp - for emulator testing)
+ */
+static long gru_get_config_info(unsigned long arg)
+{
+	struct gru_config_info info;
+
+	info.cpus = num_online_cpus();
+	info.nodes = num_online_nodes();
+	info.blades = info.nodes / NODESPERBLADE;
+	info.chiplets = GRU_CHIPLETS_PER_BLADE * info.blades;
+
+	if (copy_to_user((void __user *)arg, &info, sizeof(info)))
+		return -EFAULT;
+	return 0;
+}
+
+/*
+ * gru_file_unlocked_ioctl
+ *
+ * Called to update file attributes via IOCTL calls.
+ */
+STATIC long gru_file_unlocked_ioctl(struct file *file, unsigned int req,
+				    unsigned long arg)
+{
+	int err = -EBADRQC;
+
+	gru_dbg(grudev, "file %p, fdata %p\n", file, file->private_data);
+
+	switch (req) {
+	case GRU_CREATE_CONTEXT:
+		err = gru_create_new_context(arg, file->private_data);
+		break;
+	case GRU_SET_TASK_SLICE:
+		err = gru_set_task_slice(arg);
+		break;
+	case GRU_USER_GET_EXCEPTION_DETAIL:
+		err = gru_get_exception_detail(arg);
+		break;
+	case GRU_USER_UNLOAD_CONTEXT:
+		err = gru_user_unload_context(arg);
+		break;
+	case GRU_USER_FLUSH_TLB:
+		err = gru_user_flush_tlb(arg);
+		break;
+	case GRU_USER_CALL_OS:
+		err = gru_handle_user_call_os(arg);
+		break;
+	case GRU_GET_CONFIG_INFO:
+		err = gru_get_config_info(arg);
+		break;
+	}
+	return err;
+}
+
+/*
+ * Called at init time to build tables for all GRUs that are present in the
+ * system.
+ */
+static void gru_init_chiplet(struct gru_state *gru, unsigned long paddr,
+			void *vaddr, int base_nasid, int nid, int bid, int grunum)
+{
+	spin_lock_init(&gru->gs_lock);
+	spin_lock_init(&gru->gs_asid_lock);
+	gru->gs_gru_base_paddr = paddr;
+	gru->gs_gru_base_vaddr = vaddr;
+	gru->gs_gid = bid * GRUS_PER_HUB + grunum;
+	gru->gs_blade = gru_base[bid];
+	gru->gs_present = 1;
+	gru->gs_blade_id = bid;
+	gru->gs_cbr_map = (GRU_CBR_AU == 64) ? ~0 : (1UL << GRU_CBR_AU) - 1;
+	gru->gs_dsr_map = (1UL << GRU_DSR_AU) - 1;
+	gru_tgh_flush_init(gru);
+	gru_dbg(grudev, "bid %d, nid %d, gru %x, vaddr %p (0x%lx)\n",
+			bid, nid, gru->gs_gid, gru->gs_gru_base_vaddr,
+			gru->gs_gru_base_paddr);
+	gru_kservices_init(gru);
+}
+
+static int gru_init_tables(unsigned long gru_base_paddr, void *gru_base_vaddr,
+			   int base_nasid)
+{
+	int nasid, nid, bid, grunum;
+	int order = get_order(sizeof(struct gru_blade_state));
+	struct page *page;
+	struct gru_state *gru;
+	unsigned long paddr;
+	void *vaddr;
+
+	for_each_online_node(nid) {
+		bid = nid_to_blade(nid);
+		nasid = cnodeid_to_nasid(nid);
+		if (gru_base[bid])
+			continue;
+		page = alloc_pages_node(nid, GFP_KERNEL, order);
+		if (!page)
+			goto fail;
+		gru_base[bid] = page_address(page);
+		memset(gru_base[bid], 0, sizeof(struct gru_blade_state));
+		gru_base[bid]->bs_lru_gru = &gru_base[bid]->bs_grus[0];
+		spin_lock_init(&gru_base[bid]->bs_lock);
+
+		for (gru = gru_base[bid]->bs_grus, grunum = 0;
+		     		grunum < GRU_CHIPLETS_PER_BLADE; grunum++, gru++) {
+			paddr = gru_base_paddr + GRUCHIPOFFSET(nasid, base_nasid, grunum);
+			vaddr = gru_base_vaddr + GRUCHIPOFFSET(nasid, base_nasid, grunum);
+			gru_init_chiplet(gru, paddr, vaddr, nasid, bid, nid, grunum);
+		}
+	}
+
+	return 0;
+
+fail:
+	for (nid--; nid >= 0; nid--)
+		free_pages((unsigned long)gru_base[nid], order);
+	return -ENOMEM;
+}
+
+/*
+ * gru_init
+ *
+ * Called at boot or module load time to initialize the GRUs.
+ */
+STATIC int __init gru_init(void)
+{
+	int ret, irqno;
+	char id[10];
+	void *gru_start_vaddr;
+	int base_nasid;
+
+#ifdef EMU
+	gru_start_paddr = GRUPSEGBASE;
+	gru_end_paddr = GRUPSEGBASE + MAX_NUMNODES * GRU_SIZE;
+	gru_start_vaddr = GRUVSEGBASE;
+	base_nasid = 0;
+#else
+	/* Need real addresses from ACPI */
+	gru_start_paddr = 0xd000000000UL;
+	gru_end_paddr = 0xd000000000UL + MAX_NUMNODES * GRU_SIZE;
+	gru_start_vaddr = __va(gru_start_paddr);
+	base_nasid = 0;
+#endif
+	printk(KERN_INFO "GRU space: 0x%lx - 0x%lx\n",
+	       gru_start_paddr, gru_end_paddr);
+	for (irqno = 0; irqno < GRU_CHIPLETS_PER_BLADE; irqno++) {
+		ret = request_irq(IRQ_GRU + irqno, gru_intr, 0, id, NULL);
+		if (ret) {
+			printk(KERN_ERR "%s: request_irq failed\n",
+			       GRU_DRIVER_ID_STR);
+			goto exit1;
+		}
+	}
+
+	ret = misc_register(&gru_miscdev);
+	if (ret) {
+		printk(KERN_ERR "%s: misc_register failed\n",
+		       GRU_DRIVER_ID_STR);
+		goto exit1;
+	}
+
+	ret = gru_proc_init();
+	if (ret) {
+		printk(KERN_ERR "%s: proc init failed\n", GRU_DRIVER_ID_STR);
+		goto exit2;
+	}
+
+	ret = gru_init_tables(gru_start_paddr, gru_start_vaddr, base_nasid);
+	if (ret) {
+		printk(KERN_ERR "%s: init tables failed\n", GRU_DRIVER_ID_STR);
+		goto exit3;
+	}
+
+	printk(KERN_INFO "%s: v%s\n", GRU_DRIVER_ID_STR, REVISION);
+	return 0;
+
+exit3:
+	gru_proc_exit();
+exit2:
+	misc_deregister(&gru_miscdev);
+exit1:
+	for (--irqno; irqno >= 0; irqno--)
+		free_irq(IRQ_GRU + irqno, NULL);
+	return ret;
+
+}
+
+static void __exit gru_exit(void)
+{
+	int i, bid;
+	int order = get_order(sizeof(struct gru_state) * GRU_CHIPLETS_PER_BLADE);
+
+	for (i = 0; i < GRU_CHIPLETS_PER_BLADE; i++)
+		free_irq(IRQ_GRU + i, NULL);
+
+	for (bid = 0; bid < GRU_MAX_BLADES; bid++)
+		free_pages((unsigned long)gru_base[bid], order);
+
+	misc_deregister(&gru_miscdev);
+	gru_proc_exit();
+}
+
+static struct file_operations gru_fops = {
+	.owner = THIS_MODULE,
+	.open = gru_file_open,
+	.release = gru_file_release,
+	.unlocked_ioctl = gru_file_unlocked_ioctl,
+	.mmap = gru_file_mmap,
+};
+
+static struct miscdevice gru_miscdev = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name = "gru",
+	.fops = &gru_fops,
+};
+
+struct vm_operations_struct gru_vm_ops = {
+	.open = gru_vma_open,
+	.close = gru_vma_close,
+	.nopfn = gru_nopfn,
+};
+
+module_init(gru_init);
+module_exit(gru_exit);
+
+#ifndef MODULE
+static int set_debug_options(char *str)
+{
+	int val;
+
+	get_option(&str, &val);
+	options = val;
+	return 1;
+}
+
+__setup("gru_debug=", set_debug_options);
+#endif
+
+MODULE_AUTHOR("Silicon Graphics, Inc.");
+MODULE_DESCRIPTION("Driver for SGI GRU");
+MODULE_LICENSE("GPL");
Index: linux/drivers/gru/gruhandles.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/gruhandles.h	2008-02-19 09:30:53.000000000 -0600
@@ -0,0 +1,655 @@
+/*
+ * SN Platform GRU Driver
+ *
+ *              GRU HANDLE DEFINITION
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+#ifndef _ASM_IA64_SN_GRUHANDLES_H
+#define _ASM_IA64_SN_GRUHANDLES_H
+
+/*
+ * Manifest constants for GRU Memory Map
+ */
+#define GRU_GSEG0_BASE		0
+#define GRU_MCS_BASE		(64 * 1024 * 1024)
+#define GRU_SIZE		(128UL * 1024 * 1024)
+
+/* Handle & resource counts */
+#define GRU_NUM_CB		128
+#define GRU_NUM_DSR_BYTES	(32 * 1024)
+#define GRU_NUM_TFM		16
+#define GRU_NUM_TGH		24
+#define GRU_NUM_CBE		128
+#define GRU_NUM_TFH		128
+#define GRU_NUM_CCH		16
+#define GRU_NUM_GSH		1
+
+/* Resources PERMANENTLY reserved for kernel use */
+#define GRU_NUM_KERNEL_CBR	16
+#define GRU_NUM_KERNEL_DSR_BYTES 1024
+#define KERNEL_CTXNUM		15
+
+/* Maximum resource counts that can be reserved by user programs */
+#define GRU_NUM_USER_CBR	(GRU_NUM_CBE - GRU_NUM_KERNEL_CBR)
+#define GRU_NUM_USER_DSR_BYTES	(GRU_NUM_DSR_BYTES - GRU_NUM_KERNEL_DSR_BYTES)
+
+/* Bytes per handle & handle stride. Code assumes all cb, tfh, cbe handles
+ * are the same */
+#define GRU_HANDLE_BYTES	64
+#define GRU_HANDLE_STRIDE	256
+
+/* Base addresses of handles */
+#define GRU_TFM_BASE		(GRU_MCS_BASE + 0x00000)
+#define GRU_TGH_BASE		(GRU_MCS_BASE + 0x08000)
+#define GRU_CBE_BASE		(GRU_MCS_BASE + 0x10000)
+#define GRU_TFH_BASE		(GRU_MCS_BASE + 0x18000)
+#define GRU_CCH_BASE		(GRU_MCS_BASE + 0x20000)
+#define GRU_GSH_BASE		(GRU_MCS_BASE + 0x30000)
+
+/* User gseg constants */
+#define GRU_GSEG_STRIDE		(4 * 1024 * 1024)
+#ifdef __ia64__
+#define GRU_GSEG_PAGESIZE	(256 * 1024)
+#define GRU_GSEG_PAGESIZE_SHIFT	18
+#else
+#define GRU_GSEG_PAGESIZE	(2 * 1024 * 1024UL)
+#endif
+#define GSEG_BASE(a)		((a) & ~(GRU_GSEG_PAGESIZE - 1))
+
+/* Data segment constants */
+#define GRU_DSR_AU_BYTES	1024
+#define GRU_DSR_CL		(GRU_NUM_DSR_BYTES / GRU_CACHE_LINE_BYTES)
+#define GRU_DSR_AU_CL		(GRU_DSR_AU_BYTES / GRU_CACHE_LINE_BYTES)
+#define GRU_DSR_AU		(GRU_NUM_DSR_BYTES / GRU_DSR_AU_BYTES)
+
+/* Control block constants */
+#define GRU_CBR_AU_SIZE		2
+#define GRU_CBR_AU		(GRU_NUM_CBE / GRU_CBR_AU_SIZE)
+
+/* Convert resource counts to the number of AU */
+#define GRU_DS_BYTES_TO_AU(n)	(((n) + GRU_DSR_AU_BYTES - 1) / \
+				 GRU_DSR_AU_BYTES)
+#define GRU_CB_COUNT_TO_AU(n)	(((n) + GRU_CBR_AU_SIZE - 1) / 	\
+				 GRU_CBR_AU_SIZE)
+
+/* UV limits */
+#define GRUS_PER_HUB		2
+#define GRU_HUBS_PER_BLADE	1
+#define GRU_CHIPLETS_PER_BLADE	(GRU_HUBS_PER_BLADE * GRUS_PER_HUB)
+
+/* User GRU Gseg offsets */
+#define GRU_CB_BASE		0
+#define GRU_CB_LIMIT		(GRU_CB_BASE + GRU_HANDLE_STRIDE * GRU_NUM_CBE)
+#define GRU_DS_BASE		0x20000
+#define GRU_DS_LIMIT		(GRU_DS_BASE + GRU_NUM_DSR_BYTES)
+
+/* General addressing macros. b=grubase, c=ctxnum, i=cbnum, cl=cacheline#  */
+#define GRU_GSEG(b, c)		((void *)((b) + GRU_GSEG0_BASE + GRU_GSEG_STRIDE * (c)))
+#define GRU_GSEG_CB(b, c, i)	((void *)(GRU_GSEG((b), (c)) + GRU_CB_BASE + GRU_HANDLE_STRIDE * (i)))
+#define GRU_GSEG_DS(b, c, cl)	((void *)(GRU_GSEG((b), (c)) + GRU_DS_BASE + GRU_CACHE_LINE_BYTES * (cl)))
+#define GRU_TFM(b, c)		((struct gru_tlb_fault_map *)((unsigned long)(b) + GRU_TFM_BASE + (c) * GRU_HANDLE_STRIDE))
+#define GRU_TGH(b, c)		((struct gru_tlb_global_handle *)((unsigned long)(b) + GRU_TGH_BASE + (c) * GRU_HANDLE_STRIDE))
+#define GRU_CBE(b, n)		((struct gru_control_block_extended *)((unsigned long)(b) + GRU_CBE_BASE + (n) * GRU_HANDLE_STRIDE))
+#define GRU_TFH(b, n)		((struct gru_tlb_fault_handle *)((unsigned long)(b) + GRU_TFH_BASE + (n) * GRU_HANDLE_STRIDE))
+#define GRU_CCH(b, n)		((struct gru_context_configuration_handle *)((unsigned long)(b) + GRU_CCH_BASE + (n) * GRU_HANDLE_STRIDE))
+#define GRU_GSH(b)		((struct gru_global_status_handle *)((unsigned long)(b) + GRU_GSH_BASE))
+
+/* Test if an offset is a valid kernel handle address. Ex:  TYPE_IS(CBE, chiplet_offset) */
+#define TYPE_IS(hid, h)		((h) >= GRU_##hid##_BASE && (h) < GRU_##hid##_BASE + GRU_NUM_##hid * GRU_HANDLE_STRIDE	\
+				 && (((h) & (GRU_HANDLE_STRIDE - 1)) == 0))
+
+/* Test a GRU physical address to determine the type of address range (does NOT validate holes) */
+#define IS_MCS_PADDR(h)		(((h) & (GRU_SIZE - 1)) >= GRU_MCS_BASE)
+#define IS_CBR_PADDR(h)		(((h) & (GRU_SIZE - 1)) < GRU_MCS_BASE && (((h) & (GRU_GSEG_STRIDE - 1)) < GRU_DS_BASE))
+#define IS_DSR_PADDR(h)		(((h) & (GRU_SIZE - 1)) < GRU_MCS_BASE && (((h) & (GRU_GSEG_STRIDE - 1)) >= GRU_DS_BASE))
+
+/* Convert an arbitrary handle address to the beginning of the GRU segment */
+#ifndef __PLUGIN__
+#define GRUBASE(h)		((void *)((unsigned long)(h) & ~(GRU_SIZE - 1)))
+#else
+/* Emulator hack */
+extern void *gmu_grubase(void *h);
+#define GRUBASE(h)		gmu_grubase(h)
+#endif
+
+/* Convert a GRU physical address to the chiplet offset */
+#define GSEGPOFF(h) ((h) & (GRU_SIZE - 1))
+
+/* Convert a GSEG CB address to the relative CB number within the user gseg context */
+#define UCBNUM(cb) ((((unsigned long)(cb) - GRU_CB_BASE) % GRU_GSEG_PAGESIZE) / GRU_HANDLE_STRIDE)
+
+/* Convert a TFH address to the relative TFH number within the GRU*/
+#define TFHNUM(tfh) ((((unsigned long)(tfh) - GRU_TFH_BASE) % GRU_SIZE) / GRU_HANDLE_STRIDE)
+
+/* Convert a CCH address to the relative context number within the GRU*/
+#define CCHNUM(cch) ((((unsigned long)(cch) - GRU_CCH_BASE) % GRU_SIZE) / GRU_HANDLE_STRIDE)
+
+/* Convert a CBE address to the relative context number within the GRU*/
+#define CBENUM(cbe) ((((unsigned long)(cbe) - GRU_CBE_BASE) % GRU_SIZE) / GRU_HANDLE_STRIDE)
+
+/* Convert a TFM address to the relative context number within the GRU*/
+#define TFMNUM(tfm) ((((unsigned long)(tfm) - GRU_TFM_BASE) % GRU_SIZE) / GRU_HANDLE_STRIDE)
+
+/* byte offset to a specific GRU chiplet. (n=nasid, bn=base_nasid for first node, c=chiplet (0 or 1)*/
+#define GRUCHIPOFFSET(n, bn, c) (GRU_SIZE * ((n) - (bn) + (c)))
+
+#ifndef BITS_TO_LONGS
+#define BITS_TO_LONGS(bits)     (((bits)+64-1)/64)
+#endif
+
+/*
+ * GSH - GRU Status Handle
+ *
+ */
+struct gru_global_status_handle {
+	unsigned long bits[BITS_TO_LONGS(GRU_NUM_CBE) * 2];
+	unsigned long fill[4];
+};
+
+enum gru_gsh_status {
+	GSHSTATUS_INACTIVE,
+	GSHSTATUS_IDLE,
+	GSHSTATUS_ACTIVE,
+	GSHSTATUS_INTERRUPTED
+};
+
+/*
+ * Global TLB Fault Map
+ *
+ */
+struct gru_tlb_fault_map {
+	unsigned long fault_bits[BITS_TO_LONGS(GRU_NUM_CBE)];
+	unsigned long fill0[2];
+	unsigned long done_bits[BITS_TO_LONGS(GRU_NUM_CBE)];
+	unsigned long fill1[2];
+};
+
+/*
+ * TGH - TLB Global Handle
+ *
+ */
+struct gru_tlb_global_handle {
+	unsigned int cmd:1;		/* DW 0 */
+	unsigned int delresp:1;
+	unsigned int opc:1;
+	unsigned int fill1:5;
+
+	unsigned int fill2:8;
+
+	unsigned int status:2;
+	unsigned long fill3:2;
+	unsigned int state:3;
+	unsigned long fill4:1;
+
+	unsigned int cause:3;
+	unsigned long fill5:37;
+
+	unsigned long vaddr:64;		/* DW 1 */
+
+	unsigned int asid:24;		/* DW 2 */
+	unsigned int fill6:8;
+
+	unsigned int pagesize:5;
+	unsigned int fill7:11;
+
+	unsigned int global:1;
+	unsigned int fill8:15;
+
+	unsigned long vaddrmask:39;	/* DW 3 */
+	unsigned int fill9:9;
+	unsigned int n:10;
+	unsigned int fill10:6;
+
+	unsigned int ctxbitmap:16;	/* DW4 */
+	unsigned long fill11[3];
+};
+
+enum gru_tgh_cmd {
+	TGHCMD_START
+};
+
+enum gru_tgh_opc {
+	TGHOP_TLBNOP,
+	TGHOP_TLBINV
+};
+
+enum gru_tgh_status {
+	TGHSTATUS_IDLE,
+	TGHSTATUS_EXCEPTION,
+	TGHSTATUS_ACTIVE
+};
+
+enum gru_tgh_state {
+	TGHSTATE_IDLE,
+	TGHSTATE_PE_INVAL,
+	TGHSTATE_INTERRUPT_INVAL,
+	TGHSTATE_WAITDONE,
+	TGHSTATE_RESTART_CTX,
+};
+
+/*
+ * TFH - TLB Global Handle
+ *
+ */
+struct gru_tlb_fault_handle {
+	unsigned int cmd:1;		/* DW 0 - low 32*/
+	unsigned int delresp:1;
+	unsigned int fill0:2;
+	unsigned int opc:3;
+	unsigned int fill1:9;
+
+	unsigned int status:2;
+	unsigned int fill2:1;
+	unsigned int color:1;
+	unsigned int state:3;
+	unsigned int fill3:1;
+
+	unsigned int cause:7;		/* DW 0 - high 32 */
+	unsigned int fill4:1;
+
+	unsigned int indexway:12;
+	unsigned int fill5:4;
+
+	unsigned int ctxnum:4;
+	unsigned int fill6:12;
+
+	unsigned long missvaddr:64;	/* DW 1 */
+
+	unsigned int missasid:24;	/* DW 2 */
+	unsigned int fill7:8;
+	unsigned int fillasid:24;
+	unsigned int dirty:1;
+	unsigned int gaa:2;
+	unsigned long fill8:5;
+
+	unsigned long pfn:41;		/* DW 3 */
+	unsigned int fill9:7;
+	unsigned int pagesize:5;
+	unsigned int fill10:11;
+
+	unsigned long fillvaddr:64;	/* DW 4 */
+
+	unsigned long fill11[3];
+};
+
+enum gru_tfh_opc {
+	TFHOP_NOOP,
+	TFHOP_RESTART,
+	TFHOP_WRITE_ONLY,
+	TFHOP_WRITE_RESTART,
+	TFHOP_EXCEPTION,
+	TFHOP_USER_POLLING_MODE = 7,
+};
+
+enum tfh_status {
+	TFHSTATUS_IDLE,
+	TFHSTATUS_EXCEPTION,
+	TFHSTATUS_ACTIVE,
+};
+
+enum tfh_state {
+	TFHSTATE_INACTIVE,
+	TFHSTATE_IDLE,
+	TFHSTATE_MISS_UPM,
+	TFHSTATE_MISS_FMM,
+	TFHSTATE_HW_ERR,
+	TFHSTATE_WRITE_TLB,
+	TFHSTATE_RESTART_CBR,
+};
+
+/* TFH cause bits */
+enum tfh_cause {
+	TFHCAUSE_NONE,
+	TFHCAUSE_TLB_MISS,
+	TFHCAUSE_TLB_MOD,
+	TFHCAUSE_HW_ERROR_RR,
+	TFHCAUSE_HW_ERROR_MAIN_ARRAY,
+	TFHCAUSE_HW_ERROR_VALID,
+	TFHCAUSE_HW_ERROR_PAGESIZE,
+	TFHCAUSE_INSTRUCTION_EXCEPTION,
+	TFHCAUSE_UNCORRECTIBLE_ERROR,
+};
+
+/* GAA values */
+#define GAA_RAM				0x0
+#define GAA_NCRAM			0x2
+#define GAA_MMIO			0x1
+#define GAA_REGISTER			0x3
+
+/* GRU paddr shift for pfn. (NOTE: shift is NOT by actual pagesize) */
+#define GRU_PADDR_SHIFT			12
+
+/*
+ * Context Configuration handle
+ *
+ */
+struct gru_context_configuration_handle {
+	unsigned int cmd:1;			/* DW0 */
+	unsigned int delresp:1;
+	unsigned int opc:3;
+	unsigned int unmap_enable:1;
+	unsigned int req_slice_set_enable:1;
+	unsigned int req_slice:2;
+	unsigned int cb_int_enable:1;
+	unsigned int tlb_int_enable:1;
+	unsigned int tfm_fault_bit_enable:1;
+	unsigned int tlb_int_select:4;
+
+	unsigned int status:2;
+	unsigned int state:2;
+	unsigned int reserved2:4;
+
+	unsigned int cause:4;
+	unsigned int tfm_done_bit_enable:1;
+	unsigned int unused:3;
+
+	unsigned int dsr_allocation_map;
+
+	unsigned long cbr_allocation_map;	/* DW1 */
+
+	unsigned int asid[8];			/* DW 2 - 5 */
+	unsigned short sizeavail[8];		/* DW 6 - 7 */
+} __attribute__ ((packed));
+
+enum gru_cch_opc {
+	CCHOP_START = 1,
+	CCHOP_ALLOCATE,
+	CCHOP_INTERRUPT,
+	CCHOP_DEALLOCATE,
+	CCHOP_INTERRUPT_SYNC,
+};
+
+enum gru_cch_status {
+	CCHSTATUS_IDLE,
+	CCHSTATUS_EXCEPTION,
+	CCHSTATUS_ACTIVE,
+};
+
+enum gru_cch_state {
+	CCHSTATE_INACTIVE,
+	CCHSTATE_MAPPED,
+	CCHSTATE_ACTIVE,
+	CCHSTATE_INTERRUPTED,
+};
+
+/* CCH Exception cause */
+enum gru_cch_cause {
+	CCHCAUSE_REGION_REGISTER_WRITE_ERROR = 1,
+	CCHCAUSE_ILLEGAL_OPCODE = 2,
+	CCHCAUSE_INVALID_START_REQUEST = 3,
+	CCHCAUSE_INVALID_ALLOCATION_REQUEST = 4,
+	CCHCAUSE_INVALID_DEALLOCATION_REQUEST = 5,
+	CCHCAUSE_INVALID_INTERRUPT_REQUEST = 6,
+	CCHCAUSE_CCH_BUSY = 7,
+	CCHCAUSE_NO_CBRS_TO_ALLOCATE = 8,
+	CCHCAUSE_BAD_TFM_CONFIG = 9,
+	CCHCAUSE_CBR_RESOURCES_OVERSUBSCRIPED = 10,
+	CCHCAUSE_DSR_RESOURCES_OVERSUBSCRIPED = 11,
+	CCHCAUSE_CBR_DEALLOCATION_ERROR = 12,
+};
+/*
+ * CBE - Control Block Extended
+ *
+ */
+struct gru_control_block_extended {
+	unsigned int reserved0:1;	/* DW 0  - low */
+	unsigned int imacpy:3;
+	unsigned int reserved1:4;
+	unsigned int xtypecpy:3;
+	unsigned int iaa0cpy:2;
+	unsigned int iaa1cpy:2;
+	unsigned int reserved2:1;
+	unsigned int opccpy:8;
+	unsigned int exopccpy:8;
+
+	unsigned int idef2cpy:22;	/* DW 0  - high */
+	unsigned int reserved3:10;
+
+	unsigned int idef4cpy:22;	/* DW 1 */
+	unsigned int reserved4:10;
+	unsigned int idef4upd:22;
+	unsigned int reserved5:10;
+
+	unsigned long idef1upd:64;	/* DW 2 */
+
+	unsigned long idef5cpy:64;	/* DW 3 */
+
+	unsigned long idef6cpy:64;	/* DW 4 */
+
+	unsigned long idef3upd:64;	/* DW 5 */
+
+	unsigned long idef5upd:64;	/* DW 6 */
+
+	unsigned int idef2upd:22;	/* DW 7 */
+	unsigned int reserved6:10;
+
+	unsigned int ecause:20;
+	unsigned int cbrstate:4;
+	unsigned int cbrexecstatus:8;
+};
+
+enum gru_cbr_state {
+	CBRSTATE_INACTIVE,
+	CBRSTATE_IDLE,
+	CBRSTATE_PE_CHECK,
+	CBRSTATE_QUEUED,
+	CBRSTATE_WAIT_RESPONSE,
+	CBRSTATE_INTERRUPTED,
+	CBRSTATE_INTERRUPTED_MISS_FMM,
+	CBRSTATE_BUSY_INTERRUPT_MISS_FMM,
+	CBRSTATE_INTERRUPTED_MISS_UPM,
+	CBRSTATE_BUSY_INTERRUPTED_MISS_UPM,
+	CBRSTATE_REQUEST_ISSUE,
+	CBRSTATE_BUSY_INTERRUPT,
+};
+
+/* CBE cbrexecstatus bits */
+#define CBR_EXS_ABORT_OCC_BIT				0
+#define CBR_EXS_INT_OCC_BIT				1
+#define CBR_EXS_PENDING_BIT				2
+#define CBR_EXS_QUEUED_BIT				3
+#define CBR_EXS_TLBHW_BIT				4
+#define CBR_EXS_EXCEPTION_BIT				5
+
+#define CBR_EXS_ABORT_OCC				(1 << CBR_EXS_ABORT_OCC_BIT)
+#define CBR_EXS_INT_OCC					(1 << CBR_EXS_INT_OCC_BIT)
+#define CBR_EXS_PENDING					(1 << CBR_EXS_PENDING_BIT)
+#define CBR_EXS_QUEUED					(1 << CBR_EXS_QUEUED_BIT)
+#define CBR_EXS_TLBHW					(1 << CBR_EXS_TLBHW_BIT)
+#define CBR_EXS_EXCEPTION				(1 << CBR_EXS_EXCEPTION_BIT)
+
+/* CBE ecause bits  - defined in gru_instructions.h */
+
+/*
+ * Convert a processor pagesize into the strange encoded pagesize used by the GRU.
+ * Processor pagesize is encoded as log of bytes per page. (or PAGE_SHIFT)
+ * 	pagesize	log pagesize	grupagesize
+ * 	  4k			12	0
+ * 	  8k			13	1
+ * 	 16k 			14	2
+ * 	 64k			16	3
+ * 	256k			18	4
+ * 	...
+ */
+#define GRU_PAGESIZE(sh)		(((sh) <= 14) ? (sh) - 12 : ((sh) >> 1) - 5)
+#define GRU_SIZEAVAIL(sh)		(1UL << GRU_PAGESIZE(sh))
+
+/* minimum TLB purge count to ensure a full purge */
+#define GRUMAXINVAL			1024UL
+
+/* convert the weird GRU encoded pagesize to a pageshift or pagesize */
+#define GRUPAGESHIFT(e)			(((e) < 2) ? (12UL + (e)) : (14UL + 2UL * ((e) - 2)))
+#define GRUPAGESIZE(e)			(1UL << GRUPAGESHIFT(e))
+
+/*-----------------------------------------------------------------------------------------
+ *
+ * Handle operations
+ */
+
+#define cch_to_gsh(c)		GRU_GSH(GRUBASE(c))
+#define cch_to_tfh(c, i)	GRU_TFH(GRUBASE(c), (i))
+#define cch_to_cbe(c, i)	GRU_CBE(GRUBASE(c), (i))
+#define cbe_to_tfh(c)		GRU_TFH(GRUBASE(c), CBENUM(c))
+#define cbe_to_cch(c)		GRU_CCH(GRUBASE(c), CBENUM(c))
+#define tfh_to_cbe(c)		GRU_CBE(GRUBASE(c), TFHNUM(c))
+
+#ifdef __KERNEL__
+#include "gru_instructions.h"
+
+/* Extract the status field from a kernel handle */
+#define GET_MSEG_HANDLE_STATUS(h)	(((*(unsigned long*)(h)) >> 16) & 3)
+
+static inline void start_instruction(void *h)
+{
+	unsigned long *w0 = h;
+
+	wmb();		/* setting CMD bit must be last */
+	*w0 = *w0 | 1;
+	gru_flush_cache(h);
+}
+
+static inline int wait_instruction_complete(void *h)
+{
+	int status;
+
+	do {
+		gru_emulator_wait_hook(h, 1);	/* No code generated unless -D EMUSUPPORT */
+		cpu_relax();
+		barrier();
+		status = GET_MSEG_HANDLE_STATUS(h);
+	} while (status == CCHSTATUS_ACTIVE);
+	return status;
+}
+
+static inline int cch_allocate(struct gru_context_configuration_handle *cch,
+			       int asidval, unsigned long cbrmap,
+			       unsigned long dsrmap)
+{
+	int i;
+
+#if defined(__ia64__)
+	for (i = 0; i <= RGN_HPAGE; i++) {	/*  assume HPAGE is last region */
+		cch->asid[i] = (asidval++);
+		if (i == RGN_HPAGE)
+			cch->sizeavail[i] = GRU_SIZEAVAIL(hpage_shift);
+#ifdef EMU
+		else if (fake_tb_pages)
+			cch->sizeavail[i] = GRU_SIZEAVAIL(40);
+#endif
+		else
+			cch->sizeavail[i] = GRU_SIZEAVAIL(PAGE_SHIFT);
+	}
+#else
+	for (i = 0; i < 8; i++) {
+		cch->asid[i] = asidval++;
+		cch->sizeavail[i] = GRU_SIZEAVAIL(PAGE_SHIFT);	/* ZZZ hugepages??? */
+	}
+#endif
+
+	cch->dsr_allocation_map = dsrmap;
+	cch->cbr_allocation_map = cbrmap;
+	cch->opc = CCHOP_ALLOCATE;
+	start_instruction(cch);
+	return wait_instruction_complete(cch);
+}
+
+static inline int cch_start(struct gru_context_configuration_handle *cch)
+{
+	cch->opc = CCHOP_START;
+	start_instruction(cch);
+	return wait_instruction_complete(cch);
+}
+
+static inline int cch_interrupt(struct gru_context_configuration_handle *cch)
+{
+	cch->opc = CCHOP_INTERRUPT;
+	start_instruction(cch);
+	return wait_instruction_complete(cch);
+}
+
+static inline int cch_deallocate(struct gru_context_configuration_handle *cch)
+{
+	cch->opc = CCHOP_DEALLOCATE;
+	start_instruction(cch);
+	return wait_instruction_complete(cch);
+}
+
+static inline int cch_interrupt_sync(struct gru_context_configuration_handle
+				     *cch)
+{
+	cch->opc = CCHOP_INTERRUPT_SYNC;
+	start_instruction(cch);
+	return wait_instruction_complete(cch);
+}
+
+static inline int tgh_invalidate(struct gru_tlb_global_handle *tgh,
+				 unsigned long vaddr, unsigned long vaddrmask,
+				 int asid, int pagesize, int global, int n,
+				 unsigned short ctxbitmap)
+{
+	tgh->vaddr = vaddr;
+	tgh->asid = asid;
+	tgh->pagesize = pagesize;
+	tgh->n = n;
+	tgh->global = global;
+	tgh->vaddrmask = vaddrmask;
+	tgh->ctxbitmap = ctxbitmap;
+	tgh->opc = TGHOP_TLBINV;
+	start_instruction(tgh);
+	return wait_instruction_complete(tgh);
+}
+
+static inline void tfh_write_only(struct gru_tlb_fault_handle *tfh,
+				  unsigned long pfn, unsigned long vaddr,
+				  int asid, int dirty, int pagesize)
+{
+	tfh->fillasid = asid;
+	tfh->fillvaddr = vaddr;
+	tfh->pfn = pfn;
+	tfh->dirty = dirty;
+	tfh->pagesize = pagesize;
+	tfh->opc = TFHOP_WRITE_ONLY;
+	start_instruction(tfh);
+}
+
+static inline void tfh_write_restart(struct gru_tlb_fault_handle *tfh,
+				     unsigned long paddr, int gaa,
+				     unsigned long vaddr, int asid, int dirty,
+				     int pagesize)
+{
+	tfh->fillasid = asid;
+	tfh->fillvaddr = vaddr;
+	tfh->pfn = paddr >> GRU_PADDR_SHIFT;
+	tfh->gaa = gaa;
+	tfh->dirty = dirty;
+	tfh->pagesize = pagesize;
+	tfh->opc = TFHOP_WRITE_RESTART;
+	start_instruction(tfh);
+}
+
+static inline void tfh_restart(struct gru_tlb_fault_handle *tfh)
+{
+	tfh->opc = TFHOP_RESTART;
+	start_instruction(tfh);
+}
+
+static inline void tfh_user_polling_mode(struct gru_tlb_fault_handle *tfh)
+{
+	tfh->opc = TFHOP_USER_POLLING_MODE;
+	start_instruction(tfh);
+}
+
+static inline void tfh_exception(struct gru_tlb_fault_handle *tfh)
+{
+	tfh->opc = TFHOP_EXCEPTION;
+	start_instruction(tfh);
+}
+#endif /* __KERNEL__ */
+
+#endif /* _ASM_IA64_SN_GRUHANDLES_H */
Index: linux/drivers/gru/grukservices.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/grukservices.c	2008-02-15 13:56:45.652296396 -0600
@@ -0,0 +1,129 @@
+/*
+ * SN Platform GRU Driver
+ *
+ *              KERNEL SERVICES THAT USE THE GRU
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2007-2008 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+#ifdef EMU
+#include "preemu.h"
+#endif
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/smp_lock.h>
+#include <linux/spinlock.h>
+#include <linux/device.h>
+#include <linux/miscdevice.h>
+#include <linux/proc_fs.h>
+#include <linux/interrupt.h>
+#include <asm/uaccess.h>
+#include "gru.h"
+#include "grulib.h"
+#include "grutables.h"
+#include "gru_instructions.h"
+#ifdef __ia64__
+#include <asm/sn/addrs.h>
+#include <asm/sn/sn_cpuid.h>
+#endif
+#ifdef EMU
+#include "emu.h"
+#endif
+
+#ifdef EMU
+#define PADDR(v)	(emu_vtop((unsigned long)v))
+#elif defined(__ia64__)
+#define PADDR(v)	((void *)__pa(ia64_imva(v)))
+#else
+#define PADDR(v)	((void *)__pa(v))
+#endif
+
+#define MAGIC	0x1234567887654321UL
+
+static __cacheline_aligned unsigned long word0;
+static __cacheline_aligned unsigned long word1;
+
+static inline int gruwait(gru_control_block_t *cb)
+{
+	struct gru_control_block_status *cbs = (void *)cb;
+
+	while (cbs->istatus >= CBS_ACTIVE) {
+		gru_emulator_wait_hook(cb, 1); /* No code unless -DEMUSUPPORT */
+		cpu_relax();
+		barrier();
+	}
+	return cbs->istatus;
+}
+
+static int quicktest(struct gru_state *gru)
+{
+	void *cb;
+
+	cb = GRU_GSEG(gru->gs_gru_base_vaddr, KERNEL_CTXNUM);
+	word0 = MAGIC;
+
+	gru_vload(cb, (void *)PADDR(&word0), IAA_RAM, 0, XTYPE_DW, 1, 1,
+		  HINT_CB_UNMAPPED | HINT_CB_DELAY);
+	if (gruwait(cb) != CBS_IDLE)
+		BUG();
+
+	gru_vstore(cb, (void *)PADDR(&word1), IAA_RAM, 0, XTYPE_DW, 1, 1,
+		   HINT_CB_UNMAPPED | HINT_CB_DELAY);
+	if (gruwait(cb) != CBS_IDLE)
+		BUG();
+
+	if (word0 != word1 || word0 != MAGIC) {
+		printk
+		    ("GRU quicktest err: gru %d, found 0x%lx, expected 0x%lx\n",
+		     gru->gs_gid, word1, MAGIC);
+		BUG();		/* ZZZ should not be fatal */
+	}
+
+	return 0;
+}
+
+int gru_kservices_init(struct gru_state *gru)
+{
+	struct gru_context_configuration_handle *cch;
+	unsigned long cbr_map, dsr_map;
+	int err;
+
+	cbr_map =
+	    reserve_gru_cb_resources(gru,
+				     GRU_CB_COUNT_TO_AU(GRU_NUM_KERNEL_CBR),
+				     NULL);
+	dsr_map =
+	    reserve_gru_ds_resources(gru,
+				     GRU_DS_BYTES_TO_AU
+				     (GRU_NUM_KERNEL_DSR_BYTES), NULL);
+	__set_bit(KERNEL_CTXNUM, &gru->gs_context_map);
+	gru->gs_active_contexts++;
+	cch = GRU_CCH(gru->gs_gru_base_vaddr, KERNEL_CTXNUM);
+
+	lock_handle(cch);
+	cch->tfm_fault_bit_enable = 0;
+	cch->tlb_int_enable = 0;
+	cch->tfm_done_bit_enable = 0;
+	cch->unmap_enable = 1;
+	err = cch_allocate(cch, 0, cbr_map, dsr_map);
+	if (err) {
+		gru_dbg(grudev,
+			"Unable to allocate kernel CCH: gru %d, err %d\n",
+			gru->gs_gid, err);
+		BUG();
+	}
+	if (cch_start(cch)) {
+		gru_dbg(grudev, "Unable to start kernel CCH: gru %d, err %d\n",
+			gru->gs_gid, err);
+		BUG();
+	}
+	unlock_handle(cch);
+
+	return quicktest(gru);
+}
Index: linux/drivers/gru/grulib.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/grulib.h	2008-02-15 13:56:46.440393908 -0600
@@ -0,0 +1,84 @@
+/*
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All rights reserved.
+ */
+
+#ifndef _GRULIB_H_
+#define _GRULIB_H_
+
+#define GRU_BASENAME		"gru"
+#define GRU_FULLNAME		"/dev/gru"
+#define GRU_IOCTL_NUM 		 'G'
+#ifdef __ia64__
+#define GRU_GSEG_PAGESIZE	(256 * 1024)
+#define GRU_GSEG_PAGESIZE_SHIFT 18
+#else
+#define GRU_GSEG_PAGESIZE	(2 * 1024 * 1024UL)
+#endif
+
+/* Set Number of Request Blocks */
+#define GRU_CREATE_CONTEXT		_IOWR(GRU_IOCTL_NUM, 1, void *)
+
+/* Register task as using the slice */
+#define GRU_SET_TASK_SLICE		_IOWR(GRU_IOCTL_NUM, 5, void *)
+
+/* Fetch exception detail */
+#define GRU_USER_GET_EXCEPTION_DETAIL	_IOWR(GRU_IOCTL_NUM, 6, void *)
+
+/* For user call_os handling - normally a TLB fault */
+#define GRU_USER_CALL_OS		_IOWR(GRU_IOCTL_NUM, 8, void *)
+
+/* For user unload context */
+#define GRU_USER_UNLOAD_CONTEXT		_IOWR(GRU_IOCTL_NUM, 9, void *)
+
+/* For user TLB flushing (primarily for tests) */
+#define GRU_USER_FLUSH_TLB		_IOWR(GRU_IOCTL_NUM, 50, void *)
+
+/* Get some config options (primarily for tests & emulator) */
+#define GRU_GET_CONFIG_INFO		_IOWR(GRU_IOCTL_NUM, 51, void *)
+
+#define CONTEXT_WINDOW_BYTES(th)        (GRU_GSEG_PAGESIZE * (th))
+#define THREAD_POINTER(p, th)		(p + GRU_GSEG_PAGESIZE * (th))
+
+/*
+ * Structure used to pass TLB flush parameters to the driver
+ */
+struct gru_create_context_req {
+	unsigned int		data_segment_bytes;
+	unsigned int		control_blocks;
+	unsigned int		maximum_thread_count;
+	unsigned int		options;
+};
+
+/*
+ * Structure used to pass unload context parameters to the driver
+ */
+struct gru_unload_context_req {
+	unsigned long	vaddr;
+};
+
+/*
+ * Structure used to pass TLB flush parameters to the driver
+ */
+struct gru_flush_tlb_req {
+	unsigned long	gseg;
+	unsigned long	vaddr;
+	size_t		len;
+};
+
+/*
+ * GRU configuration info (temp - for testing)
+ */
+struct gru_config_info {
+	int		cpus;
+	int		blades;
+	int		nodes;
+	int		chiplets;
+	int		fill[16];
+};
+
+#endif /* _GRULIB_H_ */
Index: linux/drivers/gru/grumain.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/grumain.c	2008-02-19 09:30:53.000000000 -0600
@@ -0,0 +1,958 @@
+/*
+ * SN Platform GRU Driver
+ *
+ *            DRIVER TABLE MANAGER + GRU CONTEXT LOAD/UNLOAD
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+#ifdef EMU
+#include "preemu.h"
+#endif
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/spinlock.h>
+#include <linux/sched.h>
+#include <linux/device.h>
+#include <linux/list.h>
+#include "gru.h"
+#include "grutables.h"
+#include "gruhandles.h"
+#ifdef EMU
+#include "emu.h"
+#endif
+
+unsigned long options;
+
+static struct device_driver gru_driver = {
+	.name = "gru"
+};
+
+static struct device gru_device = {
+	.bus_id = {0},
+	.driver = &gru_driver,
+};
+
+struct device *grudev = &gru_device;
+
+/*
+ * Select a gru fault map to be used by the current cpu. Note that
+ * multiple cpus may be using the same map.
+ *	ZZZ should "shift" be used?? Depends on HT cpu numbering
+ *	ZZZ should be inline but did not work on emulator
+ */
+int gru_cpu_fault_map_id(void)
+{
+	return blade_processor_id() % GRU_NUM_TFM;
+}
+
+
+/*--------- ASID Management -------------------------------------------
+ *
+ *  Initially, assign asids sequentially from MIN_ASID .. MAX_ASID.
+ *  Once MAX is reached, flush the TLB & start over. However,
+ *  some asids may still be in use. There won't be many (percentage wise) still
+ *  in use. Search active contexts & determine the value of the first
+ *  asid in use ("x"s below). Set "limit" to this value.
+ *  This defines a block of assignable asids.
+ *
+ *  When "limit" is reached, search forward from limit+1 and determine the
+ *  next block of assignable asids.
+ *
+ *  Repeat until MAX_ASID is reached, then start over again.
+ *
+ *  Each time MAX_ASID is reached, increment the asid generation. Since
+ *  the search for in-use asids only checks contexts with GRUs currently
+ *  assigned, asids in some contexts will be missed. Prior to loading
+ *  a context, the asid generation of the GTS asid is rechecked. If it
+ *  doesn't match the current generation, a new asid will be assigned.
+ *
+ *   	0---------------x------------x---------------------x----|
+ *	  ^-next	^-limit	   				^-MAX_ASID
+ *
+ * All asid manipulation & context loading/unloading is protected by the
+ * gs_lock.
+ */
+
+/* Hit the asid limit. Start over */
+static int gru_wrap_asid(struct gru_state *gru)
+{
+	gru_dbg(grudev, "gru %p\n", gru);
+	STAT(asid_wrap);
+	gru->gs_asid_gen++;
+	gru_flush_all_tlb(gru);
+	return MIN_ASID;
+}
+
+/* Find the next chunk of unused asids */
+static int gru_reset_asid_limit(struct gru_state *gru, int asid)
+{
+	int i, gid, inuse_asid, limit;
+
+	gru_dbg(grudev, "gru %p, asid 0x%x\n", gru, asid);
+	STAT(asid_next);
+	limit = MAX_ASID;
+	if (asid >= limit)
+		asid = gru_wrap_asid(gru);
+	gid = gru->gs_gid;
+again:
+	for (i = 0; i < GRU_NUM_CCH; i++) {
+		if (!gru->gs_gts[i])
+			continue;
+		inuse_asid = gru->gs_gts[i]->ts_ms->ms_asids[gid].mt_asid;
+		gru_dbg(grudev, "gru %p, inuse_asid 0x%x, cxtnum %d, gts %p\n",
+			gru, inuse_asid, i, gru->gs_gts[i]);
+		if (inuse_asid == asid) {
+			asid += ASID_INC;
+			if (asid >= limit) {
+				/*
+				 * empty range: reset the range limit and
+				 * start over
+				 */
+				limit = MAX_ASID;
+				if (asid >= MAX_ASID)
+					asid = gru_wrap_asid(gru);
+				goto again;
+			}
+		}
+
+		if ((inuse_asid > asid) && (inuse_asid < limit))
+			limit = inuse_asid;
+	}
+	gru->gs_asid_limit = limit;
+	gru->gs_asid = asid;
+	gru_dbg(grudev, "gru %p, new asid 0x%x, new_limit 0x%x\n", gru, asid,
+		limit);
+	return asid;
+}
+
+/* Assign a new ASID to a thread context.  */
+static int gru_assign_asid(struct gru_state *gru)
+{
+	int asid;
+
+	spin_lock(&gru->gs_asid_lock);
+	gru->gs_asid += ASID_INC;
+	asid = gru->gs_asid;
+	if (asid >= gru->gs_asid_limit)
+		asid = gru_reset_asid_limit(gru, asid);
+	spin_unlock(&gru->gs_asid_lock);
+
+	gru_dbg(grudev, "gru %p, asid 0x%x\n", gru, asid);
+	return asid;
+}
+
+/*
+ * Clear n bits in a word. Return a word indicating the bits that were cleared.
+ * Optionally, build an array of chars that contain the bit numbers allocated.
+ */
+static unsigned long reserve_resources(unsigned long *p, int n, int mmax,
+				       char *idx)
+{
+	unsigned long bits = 0;
+	int i;
+
+	do {
+		i = find_first_bit(p, mmax);
+		if (i == mmax)
+			BUG();
+		__clear_bit(i, p);
+		__set_bit(i, &bits);
+		if (idx)
+			*idx++ = i;
+	} while (--n);
+	return bits;
+}
+
+unsigned long reserve_gru_cb_resources(struct gru_state *gru, int cbr_au_count,
+				       char *cbmap)
+{
+	return reserve_resources(&gru->gs_cbr_map, cbr_au_count, GRU_CBR_AU,
+				 cbmap);
+}
+
+unsigned long reserve_gru_ds_resources(struct gru_state *gru, int dsr_au_count,
+				       char *dsmap)
+{
+	return reserve_resources(&gru->gs_dsr_map, dsr_au_count, GRU_DSR_AU,
+				 dsmap);
+}
+
+static void reserve_gru_resources(struct gru_state *gru,
+				  struct gru_thread_state *gts)
+{
+	gru->gs_active_contexts++;
+	gts->ts_cbr_map =
+	    reserve_gru_cb_resources(gru, gts->ts_cbr_au_count,
+				     gts->ts_cbr_idx);
+	gts->ts_dsr_map =
+	    reserve_gru_ds_resources(gru, gts->ts_dsr_au_count, NULL);
+}
+
+static void free_gru_resources(struct gru_state *gru,
+			       struct gru_thread_state *gts)
+{
+	gru->gs_active_contexts--;
+	gru->gs_cbr_map |= gts->ts_cbr_map;
+	gru->gs_dsr_map |= gts->ts_dsr_map;
+}
+
+/*
+ * Check if a GRU has sufficient free resources to satisfy an allocation
+ * request. Note: GRU locks may or may not be held when this is called. If
+ * not held, recheck after acquiring the appropriate locks.
+ *
+ * Returns 1 if sufficient resources, 0 if not
+ */
+static int check_gru_resources(struct gru_state *gru, int cbr_au_count,
+			       int dsr_au_count, int max_active_contexts)
+{
+	return (hweight64(gru->gs_cbr_map) >= cbr_au_count
+		&& hweight64(gru->gs_dsr_map) >= dsr_au_count
+		&& gru->gs_active_contexts < max_active_contexts);
+}
+
+/*
+ * TLB manangment requires tracking all GRU chiplets that have loaded a GSEG
+ * context.
+ */
+static int gru_load_mm_tracker(struct gru_state *gru, struct gru_mm_struct *gms,
+			       int ctxnum)
+{
+	struct gru_mm_tracker *asids = &gms->ms_asids[gru->gs_gid];
+	unsigned short ctxbitmap = (1 << ctxnum);
+	int asid;
+
+	spin_lock(&gms->ms_asid_lock);
+	asid = asids->mt_asid;
+
+	if (asid == 0 || asids->mt_asid_gen != gru->gs_asid_gen) {
+		asid = gru_assign_asid(gru);
+		asids->mt_asid = asid;
+		asids->mt_asid_gen = gru->gs_asid_gen;
+		STAT(asid_new);
+	} else {
+		STAT(asid_reuse);
+	}
+
+	BUG_ON(asids->mt_ctxbitmap & ctxbitmap);
+	asids->mt_ctxbitmap |= ctxbitmap;
+	if (!test_bit(gru->gs_gid, gms->ms_asidmap))
+		__set_bit(gru->gs_gid, gms->ms_asidmap);
+	spin_unlock(&gms->ms_asid_lock);
+
+	gru_dbg(grudev,
+		"gru %x, gms %p, ctxnum 0x%d, asid 0x%x, asidmap 0x%lx\n",
+		gru->gs_gid, gms, ctxnum, asid, gms->ms_asidmap[0]);
+	return asid;
+}
+
+static void gru_unload_mm_tracker(struct gru_state *gru,
+				  struct gru_mm_struct *gms, int ctxnum)
+{
+	struct gru_mm_tracker *asids;
+	unsigned short ctxbitmap;
+
+	asids = &gms->ms_asids[gru->gs_gid];
+	ctxbitmap = (1 << ctxnum);
+	spin_lock(&gms->ms_asid_lock);
+	BUG_ON((asids->mt_ctxbitmap & ctxbitmap) != ctxbitmap);
+	asids->mt_ctxbitmap ^= ctxbitmap;
+	gru_dbg(grudev, "gru %x, gms %p, ctxnum 0x%d, asidmap 0x%lx\n",
+		gru->gs_gid, gms, ctxnum, gms->ms_asidmap[0]);
+	spin_unlock(&gms->ms_asid_lock);
+}
+
+/*
+ * Decrement the reference count on a GTD structure. Free the structure
+ * if the reference count goes to zero.
+ */
+void gtd_drop(struct gru_thread_data *gtd)
+{
+	if (gtd && atomic_dec_return(&gtd->td_refcnt) == 0) {
+		kfree(gtd);
+		STAT(gtd_free);
+	}
+}
+
+/*
+ * Decrement the reference count on a GTS structure. Free the structure
+ * if the reference count goes to zero.
+ */
+void gts_drop(struct gru_thread_state *gts)
+{
+	if (gts && atomic_dec_return(&gts->ts_refcnt) == 0) {
+		gru_drop_mmu_notifier(gts->ts_ms);
+		kfree(gts);
+		STAT(gts_free);
+	}
+}
+
+/*
+ * Locate the GTS structure for the current thread.
+ */
+static struct gru_thread_state *gru_find_current_gts_nolock(struct gru_vma_data
+							    *vdata, int tsid)
+{
+	struct gru_thread_state *gts;
+
+	list_for_each_entry(gts, &vdata->vd_head, ts_next)
+	    if (gts->ts_tsid == tsid)
+		return gts;
+	return NULL;
+}
+
+/*
+ * Break a copy-on-write reference to a gru thread data struct.
+ */
+static int gru_break_cow(struct vm_area_struct *vma,
+			 struct gru_thread_state *gts)
+{
+	struct gru_thread_data *gtd;
+	struct gru_vma_data *vdata = vma->vm_private_data;
+
+	gtd = kmalloc(THREADDATABYTES(vdata), GFP_KERNEL);
+	if (!gtd)
+		return 0;
+	STAT(gtd_alloc);
+	STAT(break_cow);
+	memcpy(gtd, gts->ts_td, THREADDATABYTES(vdata));
+	atomic_set(&gtd->td_refcnt, 1);
+	gtd_drop(gts->ts_td);
+	gts->ts_td = gtd;
+	gru_dbg(grudev, "alloc gts %p, new gtd %p\n", gts, gtd);
+	return 1;
+}
+
+/*
+ * Allocate a thread data structure.
+ */
+static struct gru_thread_data *gru_alloc_gtd(struct gru_vma_data *vdata,
+					     struct gru_thread_state *gts)
+{
+	struct gru_thread_data *gtd;
+	int bytes = THREADDATABYTES(vdata);
+
+	gtd = kzalloc(bytes, GFP_KERNEL);
+	if (!gtd)
+		return NULL;
+
+	STAT(gtd_alloc);
+	atomic_set(&gtd->td_refcnt, 1);
+	gtd->td_magic = TD_MAGIC;
+	gru_dbg(grudev, "alloc vdata %p, new gtd %p\n", vdata, gtd);
+	return gtd;
+}
+
+/*
+ * Allocate a thread state structure.
+ */
+static struct gru_thread_state *gru_alloc_gts(struct vm_area_struct *vma,
+					      struct gru_vma_data *vdata,
+					      int tsid,
+					      struct gru_thread_data *gtd)
+{
+	struct gru_thread_state *gts;
+
+	gts = kzalloc(sizeof(*gts), GFP_KERNEL);
+	if (!gts)
+		return NULL;
+
+	STAT(gts_alloc);
+	atomic_set(&gts->ts_refcnt, 1);
+	sema_init(&gts->ts_ctxsem, 1);
+	gts->ts_cbr_au_count = vdata->vd_cbr_au_count;
+	gts->ts_dsr_au_count = vdata->vd_dsr_au_count;
+	gts->ts_tsid = tsid;
+	gts->ts_user_options = vdata->vd_user_options;
+	gts->ts_ctxnum = NULLCTX;
+	gts->ts_mm = current->mm;
+	gts->ts_vma = vma;
+	gts->ts_tlb_int_select = -1;
+	gts->ts_ms = gru_register_mmu_notifier();
+	if (!gts->ts_ms)
+		goto err;
+
+	if (!gtd)
+		gtd = gru_alloc_gtd(vdata, gts);
+	if (!gtd)
+		goto err;
+
+	gts->ts_td = gtd;
+
+	gru_dbg(grudev, "alloc vdata %p, new gts %p, new gtd %p\n", vdata, gts,
+		gtd);
+	return gts;
+
+err:
+	gts_drop(gts);
+	return NULL;
+}
+
+/*
+ * Allocate a vma private data structure.
+ */
+struct gru_vma_data *gru_alloc_vma_data(struct vm_area_struct *vma, int tsid,
+					void *gtd)
+{
+	struct gru_file_data *fdata;
+	struct gru_vma_data *vdata = NULL;
+	struct gru_thread_state *gts = NULL;
+
+	vdata = kmalloc(sizeof(*vdata), GFP_KERNEL);
+	if (!vdata)
+		return NULL;
+
+	INIT_LIST_HEAD(&vdata->vd_head);
+	spin_lock_init(&vdata->vd_lock);
+	fdata = vma->vm_file->private_data;
+	vdata->vd_cbr_au_count = fdata->fd_cbr_au_count;
+	vdata->vd_dsr_au_count = fdata->fd_dsr_au_count;
+	vdata->vd_thread_slices = fdata->fd_thread_slices;
+	vdata->vd_user_options = fdata->fd_user_options;
+
+	gts = gru_alloc_gts(vma, vdata, TSID(0), gtd);
+	if (!gts) {
+		kfree(vdata);
+		return NULL;
+	}
+	gru_dbg(grudev, "alloc vdata %p, gts %p, gtd %p\n", vdata, gts, gtd);
+	list_add(&gts->ts_next, &vdata->vd_head);
+
+	mb();			/* Make sure head is visible */
+	if (cmpxchg(&vma->vm_private_data, gtd, vdata) != gtd) {
+		if (!gtd)
+			gtd_drop(gts->ts_td);
+		gts_drop(gts);
+		kfree(vdata);
+		STAT(vdata_double_alloc);
+	} else {
+		STAT(vdata_alloc);
+	}
+	return vma->vm_private_data;
+}
+
+/*
+ * Find the thread state structure for the current thread. If none
+ * exists, allocate one.
+ *
+ * Note that the vm_private structure in the vma _may_ be a pointer to
+ * a COW thread data structure. If so, create a vma structure, etc...
+ */
+struct gru_thread_state *gru_find_thread_state(struct vm_area_struct *vma,
+					       int tsid)
+{
+	struct gru_vma_data *vdata;
+	struct gru_thread_state *gts, *ngts;
+
+	vdata = vma->vm_private_data;
+	if (IS_THREAD_DATA(vdata)) {
+		vdata = gru_alloc_vma_data(vma, tsid, vdata);
+		if (!vdata)
+			return NULL;
+	}
+
+	spin_lock(&vdata->vd_lock);
+	gts = gru_find_current_gts_nolock(vdata, tsid);
+	if (gts) {
+		spin_unlock(&vdata->vd_lock);
+		gru_dbg(grudev, "vma %p, gts %p, gtd %p\n", vma, gts,
+			gts->ts_td);
+		return gts;
+	}
+	spin_unlock(&vdata->vd_lock);
+
+	gts = gru_alloc_gts(vma, vdata, tsid, NULL);
+	if (!gts)
+		return NULL;
+
+	spin_lock(&vdata->vd_lock);
+	ngts = gru_find_current_gts_nolock(vdata, tsid);
+	if (ngts) {
+		gts_drop(gts);
+		gts = ngts;
+		STAT(gts_double_allocate);
+	} else {
+		list_add(&gts->ts_next, &vdata->vd_head);
+	}
+	spin_unlock(&vdata->vd_lock);
+
+	gru_dbg(grudev, "vma %p, new gts %p, gtd %p\n", vma, gts, gts->ts_td);
+	return gts;
+}
+
+/*
+ * Free the GRU context assigned to the thread state.
+ */
+static void gru_free_gru_context(struct gru_thread_state *gts)
+{
+	struct gru_state *gru;
+
+	gru = gts->ts_gru;
+	gru_dbg(grudev, "gts %p, gru %p\n", gts, gru);
+
+	spin_lock(&gru->gs_lock);
+	gru->gs_gts[gts->ts_ctxnum] = NULL;
+	free_gru_resources(gru, gts);
+	BUG_ON(test_bit(gts->ts_ctxnum, &gru->gs_context_map) == 0);
+	__clear_bit(gts->ts_ctxnum, &gru->gs_context_map);
+	gts->ts_ctxnum = NULLCTX;
+	gts->ts_gru = NULL;
+	spin_unlock(&gru->gs_lock);
+
+	gts_drop(gts);
+	STAT(free_context);
+}
+
+/*
+ * Prefetching cachelines help hardware performance.
+ */
+static void prefetch_data(void *p, int num, int stride)
+{
+	while (num-- > 0) {
+		prefetchw(p);
+		p += stride;
+	}
+}
+
+static inline long gru_copy_handle(void *d, void *s)
+{
+	memcpy(d, s, GRU_HANDLE_BYTES);
+	return GRU_HANDLE_BYTES;
+}
+
+/* rewrite in assembly & use lots of prefetch */
+static void gru_load_context_data(void *save, void *grubase, int ctxnum,
+				  unsigned long cbrmap, unsigned long dsrmap)
+{
+	void *gseg, *cb, *cbe;
+	unsigned long length;
+	int i, scr;
+
+	gseg = grubase + ctxnum * GRU_GSEG_STRIDE;
+	length = hweight64(dsrmap) * GRU_DSR_AU_BYTES;
+	prefetch_data(gseg + GRU_DS_BASE, length / GRU_CACHE_LINE_BYTES,
+		      GRU_CACHE_LINE_BYTES);
+
+	cb = gseg + GRU_CB_BASE;
+	cbe = grubase + GRU_CBE_BASE;
+	for_each_cbr_in_allocation_map(i, &cbrmap, scr) {
+		prefetch_data(cb, 1, GRU_CACHE_LINE_BYTES);
+		prefetch_data(cbe + i * GRU_HANDLE_STRIDE, 1,
+			      GRU_CACHE_LINE_BYTES);
+		cb += GRU_HANDLE_STRIDE;
+	}
+
+	cb = gseg + GRU_CB_BASE;
+	for_each_cbr_in_allocation_map(i, &cbrmap, scr) {
+		save += gru_copy_handle(cb, save);
+		save += gru_copy_handle(cbe + i * GRU_HANDLE_STRIDE, save);
+		cb += GRU_HANDLE_STRIDE;
+	}
+
+	memcpy(gseg + GRU_DS_BASE, save, length);
+}
+
+static void gru_unload_context_data(void *save, void *grubase, int ctxnum,
+				    unsigned long cbrmap, unsigned long dsrmap)
+{
+	void *gseg, *cb, *cbe;
+	unsigned long length;
+	int i, scr;
+
+	gseg = grubase + ctxnum * GRU_GSEG_STRIDE;
+
+	cb = gseg + GRU_CB_BASE;
+	cbe = grubase + GRU_CBE_BASE;
+	for_each_cbr_in_allocation_map(i, &cbrmap, scr) {
+		save += gru_copy_handle(save, cb);
+		save += gru_copy_handle(save, cbe + i * GRU_HANDLE_STRIDE);
+		cb += GRU_HANDLE_STRIDE;
+	}
+	length = hweight64(dsrmap) * GRU_DSR_AU_BYTES;
+	memcpy(save, gseg + GRU_DS_BASE, length);
+}
+
+void gru_unload_context(struct gru_thread_state *gts, int savestate)
+{
+	struct gru_thread_data *gtd = gts->ts_td;
+	struct gru_state *gru = gts->ts_gru;
+	struct gru_context_configuration_handle *cch;
+	int ctxnum = gts->ts_ctxnum;
+
+	zap_page_range(gts->ts_vma, UGRUADDR(gts), GRU_GSEG_PAGESIZE, NULL);
+	cch = GRU_CCH(gru->gs_gru_base_vaddr, ctxnum);
+
+	lock_handle(cch);
+	if (cch_interrupt_sync(cch))
+		BUG();
+	gru_dbg(grudev, "gts %p, gtd %p\n", gts, gtd);
+
+	gru_unload_mm_tracker(gru, gts->ts_ms, gts->ts_ctxnum);
+	if (savestate)
+		gru_unload_context_data(gtd->td_gdata, gru->gs_gru_base_vaddr,
+					ctxnum, gts->ts_cbr_map,
+					gts->ts_dsr_map);
+
+	if (cch_deallocate(cch))
+		BUG();
+	gts->ts_force_unload = 0;	/* ts_force_unload locked by CCH lock */
+	unlock_handle(cch);
+
+	gru_free_gru_context(gts);
+	STAT(unload_context);
+}
+
+/*
+ * Load a GRU context by copying it from the thread data structure in memory
+ * to the GRU.
+ */
+static void gru_load_context(struct gru_thread_state *gts)
+{
+	struct gru_thread_data *gtd = gts->ts_td;
+	struct gru_state *gru = gts->ts_gru;
+	struct gru_context_configuration_handle *cch;
+	int err, asid, ctxnum = gts->ts_ctxnum;
+
+	gru_dbg(grudev, "gts %p, gtd %p\n", gts, gtd);
+	cch = GRU_CCH(gru->gs_gru_base_vaddr, ctxnum);
+
+	lock_handle(cch);
+	asid = gru_load_mm_tracker(gru, gts->ts_ms, gts->ts_ctxnum);
+	cch->tfm_fault_bit_enable =
+	    (gts->ts_user_options == GRU_OPT_MISS_FMM_POLL
+	     || gts->ts_user_options == GRU_OPT_MISS_FMM_INTR);
+	cch->tlb_int_enable = (gts->ts_user_options == GRU_OPT_MISS_FMM_INTR);
+	if (cch->tlb_int_enable) {
+		gts->ts_tlb_int_select = gru_cpu_fault_map_id();
+		cch->tlb_int_select = gts->ts_tlb_int_select;
+	}
+	cch->tfm_done_bit_enable = 0;
+	err = cch_allocate(cch, asid, gts->ts_cbr_map, gts->ts_dsr_map);
+	if (err) {
+		gru_dbg(grudev,
+			"err %d: cch %p, gts %p, cbr 0x%lx, dsr 0x%lx\n",
+			err, cch, gts, gts->ts_cbr_map, gts->ts_dsr_map);
+		BUG();
+	}
+
+	gru_load_context_data(gtd->td_gdata, gru->gs_gru_base_vaddr, ctxnum,
+			      gts->ts_cbr_map, gts->ts_dsr_map);
+
+	if (cch_start(cch))
+		BUG();
+	unlock_handle(cch);
+
+	STAT(load_context);
+}
+
+/*
+ * Update fields in an active CCH:
+ * 	- retarget interrupts on local blade
+ * 	- force a delayed context unload by clearing the CCH asids. This
+ * 	  forces TLB misses for new GRU instructions. The context is unloaded
+ * 	  when the next TLB miss occurs.
+ */
+static int gru_update_cch(struct gru_thread_state *gts, int int_select)
+{
+	struct gru_context_configuration_handle *cch;
+	struct gru_state *gru = gts->ts_gru;
+	int i, ctxnum = gts->ts_ctxnum, ret = 0;
+
+	cch = GRU_CCH(gru->gs_gru_base_vaddr, ctxnum);
+
+	lock_handle(cch);
+	if (cch->state == CCHSTATE_ACTIVE) {
+		if (gru->gs_gts[gts->ts_ctxnum] != gts)
+			goto exit;
+		if (cch_interrupt(cch))
+			BUG();
+		if (int_select >= 0) {
+			gts->ts_tlb_int_select = int_select;
+			cch->tlb_int_select = int_select;
+		} else {
+			for (i = 0; i < 8; i++)
+				cch->asid[i] = 0;
+			cch->tfm_fault_bit_enable = 0;
+			cch->tlb_int_enable = 0;
+			gts->ts_force_unload = 1;
+		}
+		if (cch_start(cch))
+			BUG();
+		ret = 1;
+	}
+exit:
+	unlock_handle(cch);
+	return ret;
+}
+
+/*
+ * Update CCH tlb interrupt select. Required when all the following is true:
+ * 	- task's GRU context is loaded into a GRU
+ * 	- task is using interrupt notification for TLB faults
+ * 	- task has migrated to a different cpu on the same blade where
+ * 	  it was previously running.
+ */
+static int gru_retarget_intr(struct gru_thread_state *gts)
+{
+	if (gts->ts_tlb_int_select < 0
+	    || gts->ts_tlb_int_select == gru_cpu_fault_map_id())
+		return 0;
+
+	gru_dbg(grudev, "retarget from %d to %d\n", gts->ts_tlb_int_select,
+		gru_cpu_fault_map_id());
+	return gru_update_cch(gts, gru_cpu_fault_map_id());
+}
+
+/*
+ * Try to unload the GRU context. Task has migrated to a different blade.
+ * Called on migration when locks could not be obtained to immediately unload
+ * the context.
+ */
+static int gru_delayed_unload_context(struct gru_thread_state *gts)
+{
+	gru_dbg(grudev, "migration unload context gts %p\n", gts);
+	return gru_update_cch(gts, -1);
+}
+
+/*
+ * All GRU contexts on the local blade are busy. Steal one from another process.
+ * This is a hack until a _real_ resource scheduler is written....
+ */
+#define next_ctxnum(n)		((n) <  GRU_NUM_CCH - 2 ? (n) + 1 : 0)
+#define next_gru(b, g)		(((g) < &(b)->bs_grus[GRU_CHIPLETS_PER_BLADE - 1]) ?  \
+				 ((g)+1) : &(b)->bs_grus[0])
+
+static void gru_steal_context(struct gru_thread_state *gts)
+{
+	struct gru_blade_state *blade;
+	struct gru_state *gru = NULL;
+	struct gru_thread_state *ngts = NULL;
+	int ctxnum, cbr, dsr, ok = 0;
+
+	cbr = gts->ts_cbr_au_count;
+	dsr = gts->ts_dsr_au_count;
+
+	preempt_disable();
+	blade = gru_base[numa_blade_id()];
+	spin_lock(&blade->bs_lock);
+
+	ctxnum = next_ctxnum(blade->bs_lru_ctxnum);
+	gru = blade->bs_lru_gru;
+	if (ctxnum == 0)
+		gru = next_gru(blade, gru);
+	while (1) {
+		spin_lock(&gru->gs_lock);
+		for (; ctxnum < GRU_NUM_CCH; ctxnum++) {
+			if (gru == blade->bs_lru_gru
+			    && ctxnum == blade->bs_lru_ctxnum)
+				break;
+			ok = check_gru_resources(gru, cbr, dsr, GRU_NUM_CCH);
+			if (ok)
+				break;
+			ngts = gru->gs_gts[ctxnum];
+			if (ngts && down_trylock(&ngts->ts_ctxsem) == 0)
+				break;
+			ngts = NULL;
+		}
+		spin_unlock(&gru->gs_lock);
+		if (ok || ngts
+		    || (gru == blade->bs_lru_gru
+			&& ctxnum == blade->bs_lru_ctxnum))
+			break;
+		ctxnum = 0;
+		gru = next_gru(blade, gru);
+	}
+	blade->bs_lru_gru = gru;
+	blade->bs_lru_ctxnum = ctxnum;
+	spin_unlock(&blade->bs_lock);
+	preempt_enable();
+
+	if (ngts) {
+		STAT(steal_context);
+		ngts->ts_steal_jiffies = jiffies;
+		gru_unload_context(ngts, 1);
+		up(&ngts->ts_ctxsem);
+	} else {
+		STAT(steal_context_failed);
+	}
+	gru_dbg(grudev,
+		"stole gru %x, ctxnum %d from gts %p. Need cb %d, ds %d;"
+		" avail cb %ld, ds %ld\n",
+		gru->gs_gid, ctxnum, ngts, cbr, dsr, hweight64(gru->gs_cbr_map),
+		hweight64(gru->gs_dsr_map));
+}
+
+/*
+ * Scan the GRUs on the local blade & assign a GRU context & ASID.
+ */
+static struct gru_state *gru_assign_gru_context(struct gru_thread_state *gts)
+{
+	struct gru_state *gru, *grux;
+	int i, max_active_contexts;
+
+	preempt_disable();
+
+again:
+	gru = NULL;
+	max_active_contexts = GRU_NUM_CCH;
+	for_each_gru_on_blade(grux, numa_blade_id(), i) {
+		if (check_gru_resources(grux, gts->ts_cbr_au_count,
+					gts->ts_dsr_au_count,
+					max_active_contexts)) {
+			gru = grux;
+			max_active_contexts = grux->gs_active_contexts;
+			if (max_active_contexts == 0)
+				break;
+		}
+	}
+
+	if (gru) {
+		spin_lock(&gru->gs_lock);
+		if (!check_gru_resources(gru, gts->ts_cbr_au_count,
+					 gts->ts_dsr_au_count, GRU_NUM_CCH)) {
+			spin_unlock(&gru->gs_lock);
+			goto again;
+		}
+		reserve_gru_resources(gru, gts);
+		gts->ts_gru = gru;
+		gts->ts_ctxnum =
+		    find_first_zero_bit(&gru->gs_context_map, GRU_NUM_CCH);
+		BUG_ON(gts->ts_ctxnum == GRU_NUM_CCH);
+		atomic_inc(&gts->ts_refcnt);
+		gru->gs_gts[gts->ts_ctxnum] = gts;
+		__set_bit(gts->ts_ctxnum, &gru->gs_context_map);
+		spin_unlock(&gru->gs_lock);
+
+		STAT(assign_context);
+		gru_dbg(grudev,
+			"gseg %p, gts %p, gru %x, ctx %d, cbr %d, dsr %d\n",
+			gseg_virtual_address(gts->ts_gru, gts->ts_ctxnum), gts,
+			gts->ts_gru->gs_gid, gts->ts_ctxnum,
+			gts->ts_cbr_au_count, gts->ts_dsr_au_count);
+	} else {
+		gru_dbg(grudev, "failed to allocate a GTS %s\n", "");
+		STAT(assign_context_failed);
+	}
+
+	preempt_enable();
+	return gru;
+}
+
+/*
+ * gru_nopage
+ *
+ * Map the user's GRU segment
+ */
+unsigned long gru_nopfn(struct vm_area_struct *vma, unsigned long address)
+{
+	struct gru_thread_state *gts;
+	unsigned long paddr;
+
+	gru_dbg(grudev, "vma %p, address 0x%lx (0x%lx)\n",
+		vma, address, GSEG_BASE(address));
+	STAT(nopfn);
+
+	gts = gru_find_thread_state(vma, TSID(address - vma->vm_start));
+	if (!gts)
+		return VM_FAULT_SIGBUS;
+
+again:
+	preempt_disable();
+	down(&gts->ts_ctxsem);
+	if (gts->ts_gru) {
+		if (gts->ts_gru->gs_blade_id != numa_blade_id()) {
+			STAT(migrated_nopfn_unload);
+			gru_unload_context(gts, 1);
+		} else {
+			if (gru_retarget_intr(gts))
+				STAT(migrated_nopfn_retarget);
+		}
+	}
+
+	if (!gts->ts_gru) {
+		while (!gru_assign_gru_context(gts)) {
+			up(&gts->ts_ctxsem);
+			preempt_enable();
+			schedule_timeout(GRU_ASSIGN_DELAY);  /* true hack ZZZ */
+			if (gts->ts_steal_jiffies + GRU_STEAL_DELAY < jiffies)
+				gru_steal_context(gts);
+			goto again;
+		}
+		if (atomic_read(&gts->ts_td->td_refcnt) > 1)
+			if (!gru_break_cow(vma, gts)) {
+				up(&gts->ts_ctxsem);
+				return VM_FAULT_SIGBUS;
+			}
+		gru_load_context(gts);
+		paddr = gseg_physical_address(gts->ts_gru, gts->ts_ctxnum);
+		remap_pfn_range(vma, address & ~(GRU_GSEG_PAGESIZE - 1),
+				paddr >> PAGE_SHIFT, GRU_GSEG_PAGESIZE,
+				vma->vm_page_prot);
+	}
+
+	up(&gts->ts_ctxsem);
+	preempt_enable();
+
+	return NOPFN_REFAULT;
+}
+
+/*
+ * gru_migrate_task
+ *
+ * Task has migrated to a different blade or a different cpu on the same blade
+ */
+static int do_migrate_gts(struct gru_state *gru, struct gru_thread_state *gts,
+			   int locked, int pbid, int bid)
+{
+	int again = 0;
+
+	if (pbid == bid) {
+		if (gru_retarget_intr(gts))
+			STAT(migrated_retarget);
+	} else if (locked && down_trylock(&gts->ts_ctxsem) == 0) {
+		spin_unlock(&gru->gs_lock);
+		gru_unload_context(gts, 1);
+		up(&gts->ts_ctxsem);
+		STAT(migrated_unload);
+		again = 1;
+	} else if (gru_delayed_unload_context(gts)) {
+		STAT(migrated_unload_delay);
+	}
+	return again;
+}
+
+void gru_migrate_task(int pcpu, int cpu)
+{
+	struct gru_state *gru;
+	struct gru_thread_state *gts;
+	struct gru_blade_state *blade;
+	struct mm_struct *mm = current->mm;
+	int pbid = cpu_to_blade(pcpu), bid = cpu_to_blade(cpu);
+	int locked = 0, ctxnum, scr;
+
+	STAT(migrate_check);
+	blade = gru_base[bid];
+	if (!blade || !mm)
+		return;
+
+again:
+	if (!locked)
+		locked= down_read_trylock(&mm->mmap_sem);
+	for_each_gru_on_blade(gru, pbid, scr) {
+		spin_lock(&gru->gs_lock);
+		for_each_gts_on_gru(gts, gru, ctxnum)
+			if (gts->ts_tgid_owner == current->tgid && gts->ts_gru)
+				if (do_migrate_gts(gru, gts, locked, pbid, bid))
+					goto again;
+		spin_unlock(&gru->gs_lock);
+	}
+
+	if (locked)
+		up_read(&mm->mmap_sem);
+}
Index: linux/drivers/gru/grummuops.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/grummuops.c	2008-02-19 09:30:53.000000000 -0600
@@ -0,0 +1,376 @@
+/*
+ * SN Platform GRU Driver
+ *
+ * 		MMUOPS callbacks  + TLB flushing
+ *
+ * This file handles mmuops callbacks from the core kernel. The callbacks
+ * are used to update the TLB in the GRU as a result of changes in the
+ * state of a process address space. This file also handles TLB invalidates
+ * from the GRU driver.
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All Rights Reserved.
+ *
+ */
+
+#ifdef EMU
+#include "preemu.h"
+#endif
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/mmu_notifier.h>
+#include <linux/device.h>
+#include <linux/hugetlb.h>
+#include <asm/timex.h>
+#include <asm/processor.h>
+#include <asm/delay.h>
+#include "gru.h"
+#include "grutables.h"
+#ifdef EMU
+#include "emu.h"
+#endif
+
+#define gru_random()	get_cycles()
+
+/* ---------------------------------- TLB Invalidation functions --------
+ * get_tgh_handle
+ *
+ * Find a TGH to use for issuing a TLB invalidate. For GRUs that are on the
+ * local blade, use a fixed TGH that is a function of the blade-local cpu
+ * number. Normally, this TGH is private to the cpu & no contention occurs for
+ * the TGH. For offblade GRUs, select a random TGH in the range above the
+ * private TGHs. A spinlock is required to access this TGH & the lock must be
+ * released when the invalidate is completes. This sucks, but it is the best we
+ * can do.
+ *
+ * Note that the spinlock is IN the TGH handle so locking does not involve
+ * additional cache lines.
+ *
+ */
+static inline int get_off_blade_tgh(struct gru_state *gru)
+{
+	int n;
+
+	n = GRU_NUM_TGH - gru->gs_tgh_first_remote;
+	n = gru_random() % n;
+	n += gru->gs_tgh_first_remote;
+	return n;
+}
+
+static inline int get_on_blade_tgh(struct gru_state *gru)
+{
+	return blade_processor_id() >> gru->gs_tgh_local_shift;
+}
+
+static struct gru_tlb_global_handle *get_lock_tgh_handle(struct gru_state
+							 *gru)
+{
+	struct gru_tlb_global_handle *tgh;
+	int n;
+
+	preempt_disable();
+	if (numa_blade_id() == gru->gs_blade_id)
+		n = get_on_blade_tgh(gru);
+	else
+		n = get_off_blade_tgh(gru);
+	tgh = get_tgh_by_index(gru, n);
+	lock_handle(tgh);
+
+	return tgh;
+}
+
+
+static void get_unlock_tgh_handle(struct gru_tlb_global_handle *tgh)
+{
+	unlock_handle(tgh);
+	preempt_enable();
+}
+
+/*
+ * gru_flush_tlb_range
+ *
+ * General purpose TLB invalidation function. This function scans every GRU in
+ * the ENTIRE system (partition) looking for GRUs where the specified MM has
+ * been accessed by the GRU. For each GRU found, the TLB must be invalidated OR
+ * the ASID invalidated. Invalidating an ASID causes a new ASID to be assigned
+ * on the next fault. This effectively flushes the ENTIRE TLB for the MM at the
+ * cost of (possibly) a large number of future TLBmisses.
+ *
+ * The current algorithm is optimized based on the following (somewhat true)
+ * assumptions:
+ * 	- GRU contexts are not loaded into a GRU unless a reference is made to
+ * 	  the data segment or control block (this is true, not an assumption).
+ * 	  If a DS/CB is referenced, the user will also issue instructions that
+ * 	  cause TLBmisses. It is not necessary to optimize for the case where
+ * 	  contexts are loaded but no instructions cause TLB misses. (I know
+ * 	  this will happen but I'm not optimizing for it).
+ * 	- GRU instructions to invalidate TLB entries are SLOOOOWWW - normally
+ * 	  a few usec but in unusual cases, it could be longer. Avoid if
+ * 	  possible.
+ * 	- intrablade process migration between cpus is not frequent but is
+ * 	  common.
+ * 	- a GRU context is not typically migrated to a different GRU on the
+ * 	  blade because of intrablade migration
+ *	- interblade migration is rare. Processes migrate their GRU context to
+ *	  the new blade.
+ *	- if interblade migration occurs, migration back to the original blade
+ *	  is very very rare (ie., no optimization for this case)
+ *	- most GRU instruction operate on a subset of the user REGIONS. Code
+ *	  & shared library regions are not likely targets of GRU instructions.
+ *
+ * To help improve the efficiency of TLB invalidation, the GMS data
+ * structure is maintained for EACH address space (MM struct). The GMS is
+ * also the structure that contains the pointer to the mmuops callout
+ * functions. This structure is linked to the mm_struct for the address space
+ * using the mmuops "register" function. The mmuops interfaces are used to
+ * provide the callbacks for TLB invalidation. The GMS contains:
+ *
+ * 	- asid[maxgrus] array. ASIDs are assigned to a GRU when a context is
+ * 	  loaded into the GRU.
+ * 	- asidmap[maxgrus]. bitmap to make it easier to find non-zero asids in
+ * 	  the above array
+ *	- ctxbitmap[maxgrus]. Indicates the contexts that are currently active
+ *	  in the GRU for the address space. This bitmap must be passed to the
+ *	  GRU to do an invalidate.
+ *
+ * The current algorithm for invalidating TLBs is:
+ * 	- scan the asidmap for GRUs where the context has been loaded, ie,
+ * 	  asid is non-zero.
+ * 	- for each gru found:
+ * 		- if the ctxtmap is non-zero, there are active contexts in the
+ * 		  GRU. TLB invalidate instructions must be issued to the GRU.
+ *		- if the ctxtmap is zero, no context is active. Set the ASID to
+ *		  zero to force a full TLB invalidation. This is fast but will
+ *		  cause a lot of TLB misses if the context is reloaded onto the
+ *		  GRU
+ *
+ */
+
+void gru_flush_tlb_range(struct gru_mm_struct *gms, unsigned long start,
+			 unsigned long len)
+{
+	struct gru_state *gru;
+	struct gru_mm_tracker *asids;
+	struct gru_tlb_global_handle *tgh;
+	unsigned long num;
+	int grupagesize, pagesize, pageshift, gid, asid;
+
+	pageshift = (is_hugepage(NULL, start) ? HPAGE_SHIFT : PAGE_SHIFT);
+	pagesize = (1UL << pageshift);
+	grupagesize = GRU_PAGESIZE(pageshift);
+	num = min(((len + pagesize - 1) >> pageshift), GRUMAXINVAL);
+
+	STAT(flush_tlb);
+	gru_dbg(grudev, "gms %p, start 0x%lx, len 0x%lx, asidmap 0x%lx\n", gms,
+		start, len, gms->ms_asidmap[0]);
+
+	spin_lock(&gms->ms_asid_lock);
+	for_each_gru_in_bitmap(gid, gms->ms_asidmap) {
+		STAT(flush_tlb_gru);
+		gru = GID_TO_GRU(gid);
+		asids = gms->ms_asids + gid;
+		asid = asids->mt_asid;
+		if (asids->mt_ctxbitmap && asid) {
+			STAT(flush_tlb_gru_tgh);
+			asid = GRUASID(asid, start);
+			gru_dbg(grudev,
+	"  FLUSH gruid %d, asid 0x%x, num %ld, cbmap 0x%x\n",
+				gid, asid, num, asids->mt_ctxbitmap);
+			tgh = get_lock_tgh_handle(gru);
+			tgh_invalidate(tgh, start, 0, asid, grupagesize, 0,
+				       num - 1, asids->mt_ctxbitmap);
+			get_unlock_tgh_handle(tgh);
+		} else {
+			STAT(flush_tlb_gru_zero_asid);
+			asids->mt_asid = 0;
+			__clear_bit(gru->gs_gid, gms->ms_asidmap);
+			gru_dbg(grudev,
+	"  CLEARASID gruid %d, asid 0x%x, cbtmap 0x%x, asidmap 0x%lx\n",
+				gid, asid, asids->mt_ctxbitmap,
+				gms->ms_asidmap[0]);
+		}
+	}
+	spin_unlock(&gms->ms_asid_lock);
+}
+
+/*
+ * Flush the entire TLB on a chiplet.
+ */
+void gru_flush_all_tlb(struct gru_state *gru)
+{
+	struct gru_tlb_global_handle *tgh;
+
+	gru_dbg(grudev, "gru %p, gid %d\n", gru, gru->gs_gid);
+	tgh = get_lock_tgh_handle(gru);
+	tgh_invalidate(tgh, 0, ~0, 0, 1, 1, GRUMAXINVAL - 1, 0);
+	get_unlock_tgh_handle(tgh);
+	preempt_enable();
+}
+
+/*
+ * Called from a mmuops callback to unmap a range of PTEs.
+ *
+ * Called holding the mmap_sem for write.
+ */
+static void gru_mmuops_invalidate_range_begin(struct mmu_notifier *mn,
+				       struct mm_struct *mm,
+				       unsigned long start, unsigned long end,
+				       int atomic)
+{
+	struct gru_mm_struct *gms;
+
+	STAT(mmuops_invalidate_range);
+	gms = container_of(mn, struct gru_mm_struct, ms_notifier);
+	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx, atomic %d\n", gms,
+		start, end, atomic);
+	atomic_inc(&gms->ms_range_active);
+	gru_flush_tlb_range(gms, start, end - start);
+}
+
+static void gru_mmuops_invalidate_range_end(struct mmu_notifier *mn,
+				     struct mm_struct *mm, unsigned long start,
+				     unsigned long end, int atomic)
+{
+	struct gru_mm_struct *gms;
+
+	gms = container_of(mn, struct gru_mm_struct, ms_notifier);
+	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx, atomic %d\n", gms,
+		start, end, atomic);
+	atomic_dec(&gms->ms_range_active);
+	wake_up_all(&gms->ms_wait_queue);
+}
+
+/*
+ * Called from a mmuops callback whenever a valid PTE is unloaded ex. when a
+ * page is paged out by the kernel.
+ *
+ * Called holding the mm->page_table_lock
+ */
+static void gru_mmuops_invalidate_page(struct mmu_notifier *mn,
+				       struct mm_struct *mm,
+				       unsigned long vaddr)
+{
+	struct gru_mm_struct *gms;
+
+	STAT(mmuops_invalidate_page);
+	gms = container_of(mn, struct gru_mm_struct, ms_notifier);
+	gru_dbg(grudev, "gms %p, vaddr 0x%lx\n", gms, vaddr);
+	gru_flush_tlb_range(gms, vaddr, 1);
+}
+
+/*
+ *  Called at start of address space teardown. GTS's still
+ *  hold a reference count on the GMS. Structure is not freed
+ *  until the reference count goes to zero.
+ */
+static void gru_mmuops_release(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	struct gru_mm_struct *gms;
+
+	STAT(mmuops_release);
+	gms = container_of(mn, struct gru_mm_struct, ms_notifier);
+	gru_dbg(grudev, "gms %p\n", gms);
+	gms->ms_released = 1;
+}
+
+static const struct mmu_notifier_ops gru_mmuops = {
+	.release = gru_mmuops_release,
+	.invalidate_range_begin = gru_mmuops_invalidate_range_begin,
+	.invalidate_range_end = gru_mmuops_invalidate_range_end,
+	.invalidate_page = gru_mmuops_invalidate_page,
+};
+
+/* Move this to the basic mmuops file. But for now... */
+static struct mmu_notifier *mmuops_find_ops(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n, *t;
+	struct gru_mm_struct *gms;
+
+	hlist_for_each_entry_safe_rcu(mn, n, t, &mm->mmu_notifier.head, hlist)
+	    if (mn->ops == &gru_mmuops) {
+		gms = container_of(mn, struct gru_mm_struct, ms_notifier);
+		if (atomic_read(&gms->ms_refcnt) > 0)
+			return mn;
+	}
+	return NULL;
+}
+
+struct gru_mm_struct *gru_register_mmu_notifier(void)
+{
+	struct gru_mm_struct *gms;
+	struct mmu_notifier *mn;
+
+	mn = mmuops_find_ops(current->mm);
+	if (mn) {
+		gms = container_of(mn, struct gru_mm_struct, ms_notifier);
+		atomic_inc(&gms->ms_refcnt);
+	} else {
+		gms = kzalloc(sizeof(*gms), GFP_KERNEL);
+		if (gms) {
+			spin_lock_init(&gms->ms_asid_lock);
+			gms->ms_notifier.ops = &gru_mmuops;
+			atomic_set(&gms->ms_refcnt, 1);
+			init_waitqueue_head(&gms->ms_wait_queue);
+			INIT_HLIST_NODE(&gms->ms_notifier.hlist);
+			mmu_notifier_register(&gms->ms_notifier, current->mm);
+			synchronize_rcu();
+		}
+	}
+	return gms;
+}
+
+void gru_drop_mmu_notifier(struct gru_mm_struct *gms)
+{
+	if (atomic_dec_return(&gms->ms_refcnt) == 0) {
+		if (!gms->ms_released)
+			mmu_notifier_unregister(&gms->ms_notifier, current->mm);
+		synchronize_rcu();
+		kfree(gms);
+	}
+}
+
+/*
+ * Setup TGH parameters. There are:
+ * 	- 24 TGH handles per GRU chiplet
+ * 	- a portion (MAX_LOCAL_TGH) of the handles are reserved for
+ * 	  use by blade-local cpus
+ * 	- the rest are used by off-blade cpus. This usage is
+ * 	  less frequent than blade-local usage.
+ *
+ * For now, use 16 handles for local flushes, 8 for remote flushes. If the blade
+ * has less tan or equal to 16 cpus, each cpu has a unique handle that it can
+ * use.
+ */
+#define MAX_LOCAL_TGH	16
+
+void gru_tgh_flush_init(struct gru_state *gru)
+{
+	int cpus, shift = 0, n;
+
+	cpus = nr_cpus_blade(gru->gs_blade_id);
+
+	/* n = cpus rounded up to next power of 2 */
+	if (cpus) {
+		n = 1 << fls(cpus - 1);
+
+		/*
+		 * shift count for converting local cpu# to TGH index
+		 *      0 if cpus <= MAX_LOCAL_TGH,
+		 *      1 if cpus <= 2*MAX_LOCAL_TGH,
+		 *      etc
+		 */
+		shift = max(0, fls(n - 1) - fls(MAX_LOCAL_TGH - 1));
+	}
+	gru->gs_tgh_local_shift = shift;
+
+	/* first starting TGH index to use for remote purges */
+	gru->gs_tgh_first_remote = (cpus + (1 << shift) - 1) >> shift;
+
+}
Index: linux/drivers/gru/gruprocfs.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/gruprocfs.c	2008-02-15 13:56:46.200364209 -0600
@@ -0,0 +1,309 @@
+/*
+ * SN Platform GRU Driver
+ *
+ *              PROC INTERFACES
+ *
+ * This file supports the /proc interfaces for the GRU driver
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+#ifdef EMU
+#include "preemu.h"
+#endif
+#include <linux/proc_fs.h>
+#include <linux/device.h>
+#include <linux/seq_file.h>
+#include <asm/uaccess.h>
+#include "gru.h"
+#include "grulib.h"
+#include "grutables.h"
+#ifdef EMU
+#include "emu.h"
+#endif
+
+#define print_stat(s, f, id)						\
+	seq_printf(s, "%lu: " id, atomic_long_read(&gru_stats.f))
+
+static int statistics_show(struct seq_file *s, void *p)
+{
+	print_stat(s, fdata_alloc, "allocate fdata");
+	print_stat(s, fdata_free, "free fdata");
+	print_stat(s, vdata_alloc, "allocate vdata");
+	print_stat(s, vdata_free, "free vdata");
+	print_stat(s, gts_alloc, "thread state allocate");
+	print_stat(s, gts_free, "thread state free");
+	print_stat(s, gtd_alloc, "thread data allocate");
+	print_stat(s, gtd_free, "thread data free");
+	print_stat(s, vdata_double_alloc, "race in cow vdata alloc");
+	print_stat(s, gts_double_allocate, "race in cow gts alloc");
+
+	print_stat(s, assign_context, "allocate context");
+	print_stat(s, assign_context_failed, "allocate context failed");
+	print_stat(s, free_context, "free GRU context");
+	print_stat(s, load_context, "load GRU context");
+	print_stat(s, unload_context, "unload GRU context");
+	print_stat(s, steal_context, "steal context");
+	print_stat(s, steal_context_failed, "steal context failed");
+	print_stat(s, nopfn, "nopfn");
+	print_stat(s, break_cow, "break cow data fault");
+
+	print_stat(s, asid_new, "asid new");
+	print_stat(s, asid_next, "asid next");
+	print_stat(s, asid_wrap, "asid wrap");
+	print_stat(s, asid_reuse, "asid reuse");
+
+	print_stat(s, intr, "interrupt");
+	print_stat(s, call_os, "user call os");
+	print_stat(s, call_os_tfh_idle, "call_os_tfh_idle");
+	print_stat(s, call_os_check_for_bug, "call_os_check_for_bug");
+	print_stat(s, call_os_wait_queue, "call_os_wait_queue");
+	print_stat(s, user_flush_tlb, "user flush tlb");
+	print_stat(s, user_unload_context, "user unload context");
+	print_stat(s, user_exception, "user exception");
+	print_stat(s, set_task_slice, "set task slice");
+	print_stat(s, migrate_check, "migrate task check");
+	print_stat(s, migrated_retarget, "migrate retarget");
+	print_stat(s, migrated_unload, "migrate unload");
+	print_stat(s, migrated_unload_delay, "migrate unload delay");
+	print_stat(s, migrated_nopfn_retarget, "migrate nopfn retarget");
+	print_stat(s, migrated_nopfn_unload, "migrate nopfn unload");
+	print_stat(s, tlb_dropin, "tlb dropin");
+	print_stat(s, tlb_dropin_fail_no_asid, "tlb_dropin_fail_no_asid");
+	print_stat(s, tlb_dropin_fail_upm, "tlb_dropin_fail_upm");
+	print_stat(s, tlb_dropin_fail_invalid, "tlb_dropin_fail_invalid");
+	print_stat(s, tlb_dropin_fail_range_active, "tlb_dropin_fail_range_active");
+	print_stat(s, mmuops_invalidate_range, "mmuops invalidate range");
+	print_stat(s, mmuops_invalidate_page, "mmuops update page");
+	print_stat(s, mmuops_age_page, "mmuops age page");
+	print_stat(s, mmuops_release, "mmuops release");
+
+	print_stat(s, flush_tlb, "flush tlb");
+	print_stat(s, flush_tlb_gru, "flush tlb gru");
+	print_stat(s, flush_tlb_gru_tgh, "flush tlb tgh");
+	print_stat(s, flush_tlb_gru_zero_asid, "flush tlb zero asid");
+	return 0;
+}
+
+static ssize_t statistics_write(struct file *file, const char __user *userbuf,
+				size_t count, loff_t *data)
+{
+	memset(&gru_stats, 0, sizeof(gru_stats));
+	return count;
+}
+
+static int options_show(struct seq_file *s, void *p)
+{
+	seq_printf(s, "0x%lx\n", options);
+	return 0;
+}
+
+static ssize_t options_write(struct file *file, const char __user *userbuf,
+			     size_t count, loff_t *data)
+{
+	char buf[80];
+
+	if (copy_from_user
+	    (buf, userbuf, count < sizeof(buf) ? count : sizeof(buf)))
+		return -EFAULT;
+	options = simple_strtoul(buf, NULL, 0);
+
+	return count;
+}
+
+static int cch_seq_show(struct seq_file *file, void *data)
+{
+	long gid = *(long *)data;
+	int i;
+	struct gru_state *gru = GID_TO_GRU(gid);
+	struct gru_thread_state *ts;
+	const char *mode[] = { "??", "UPM", "INTR", "OS_POLL" };
+
+	if (gid == 0)
+		seq_printf(file, "#%5s%5s%6s%9s%6s%8s%8s\n", "gid", "bid",
+			   "ctx#", "pid", "cbrs", "dsbytes", "mode");
+	if (gru)
+		for (i = 0; i < GRU_NUM_CCH; i++) {
+			ts = gru->gs_gts[i];
+			if (!ts)
+				continue;
+			seq_printf(file, " %5d%5d%6d%9d%6d%8d%8s\n",
+				   gru->gs_gid, gru->gs_blade_id, i,
+				   ts->ts_tgid_owner,
+				   ts->ts_cbr_au_count * GRU_CBR_AU_SIZE,
+				   ts->ts_cbr_au_count * GRU_DSR_AU_BYTES,
+				   mode[ts->ts_user_options &
+					GRU_OPT_MISS_MASK]);
+		}
+
+	return 0;
+}
+
+static int gru_seq_show(struct seq_file *file, void *data)
+{
+	long gid = *(long *)data, ctxfree, cbrfree, dsrfree;
+	struct gru_state *gru = GID_TO_GRU(gid);
+
+	if (gid == 0) {
+		seq_printf(file, "#%5s%5s%7s%6s%6s%8s%6s%6s\n", "gid", "nid",
+			   "ctx", "cbr", "dsr", "ctx", "cbr", "dsr");
+		seq_printf(file, "#%5s%5s%7s%6s%6s%8s%6s%6s\n", "", "", "busy",
+			   "busy", "busy", "free", "free", "free");
+	}
+	if (gru) {
+		ctxfree = GRU_NUM_CCH - gru->gs_active_contexts;
+		cbrfree = hweight64(gru->gs_cbr_map) * GRU_CBR_AU_SIZE;
+		dsrfree = hweight64(gru->gs_dsr_map) * GRU_DSR_AU_BYTES;
+		seq_printf(file, " %5d%5d%7ld%6ld%6ld%8ld%6ld%6ld\n",
+			   gru->gs_gid, gru->gs_blade_id, GRU_NUM_CCH - ctxfree,
+			   GRU_NUM_CBE - cbrfree, GRU_NUM_DSR_BYTES - dsrfree,
+			   ctxfree, cbrfree, dsrfree);
+	}
+
+	return 0;
+}
+
+static void seq_stop(struct seq_file *file, void *data)
+{
+}
+
+static void *seq_start(struct seq_file *file, loff_t *gid)
+{
+	if (*gid < GRU_MAX_GRUS)
+		return gid;
+	return NULL;
+}
+
+static void *seq_next(struct seq_file *file, void *data, loff_t *gid)
+{
+	(*gid)++;
+	if (*gid < GRU_MAX_GRUS)
+		return gid;
+	return NULL;
+}
+
+static struct seq_operations cch_seq_ops = {
+	.start = seq_start,
+	.next = seq_next,
+	.stop = seq_stop,
+	.show = cch_seq_show
+};
+
+static struct seq_operations gru_seq_ops = {
+	.start = seq_start,
+	.next = seq_next,
+	.stop = seq_stop,
+	.show = gru_seq_show
+};
+
+static int statistics_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, statistics_show, NULL);
+}
+
+static int options_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, options_show, NULL);
+}
+
+static int cch_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &cch_seq_ops);
+}
+
+static int gru_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &gru_seq_ops);
+}
+
+/* *INDENT-OFF* */
+static struct file_operations statistics_fops = {
+	.open 		= statistics_open,
+	.read 		= seq_read,
+	.write 		= statistics_write,
+	.llseek 	= seq_lseek,
+	.release 	= seq_release,
+};
+
+static struct file_operations options_fops = {
+	.open 		= options_open,
+	.read 		= seq_read,
+	.write 		= options_write,
+	.llseek 	= seq_lseek,
+	.release 	= seq_release,
+};
+
+static struct file_operations cch_fops = {
+	.open 		= cch_open,
+	.read 		= seq_read,
+	.llseek 	= seq_lseek,
+	.release 	= seq_release,
+};
+static struct file_operations gru_fops = {
+	.open 		= gru_open,
+	.read 		= seq_read,
+	.llseek 	= seq_lseek,
+	.release 	= seq_release,
+};
+
+static struct proc_entry {
+	char *name;
+	int mode;
+	struct file_operations *fops;
+	struct proc_dir_entry *entry;
+} proc_files[] = {
+	{"statistics", 0644, &statistics_fops},
+	{"debug_options", 0644, &options_fops},
+	{"cch_status", 0444, &cch_fops},
+	{"gru_status", 0444, &gru_fops},
+	{NULL}
+};
+/* *INDENT-ON* */
+
+static struct proc_dir_entry *proc_gru;
+
+static int create_proc_file(struct proc_entry *p)
+{
+	p->entry = create_proc_entry(p->name, p->mode, proc_gru);
+	if (!p->entry)
+		return -1;
+	p->entry->proc_fops = p->fops;
+	return 0;
+}
+
+static void delete_proc_files(void)
+{
+	struct proc_entry *p;
+
+	if (proc_gru) {
+		for (p = proc_files; p->name; p++)
+			if (p->entry)
+				remove_proc_entry(p->name, proc_gru);
+		remove_proc_entry("gru", NULL);
+	}
+}
+
+int gru_proc_init(void)
+{
+	struct proc_entry *p;
+
+	proc_gru = proc_mkdir("gru", NULL);
+
+	for (p = proc_files; p->name; p++)
+		if (create_proc_file(p))
+			goto err;
+	return 0;
+
+err:
+	delete_proc_files();
+	return -1;
+}
+
+void gru_proc_exit(void)
+{
+	delete_proc_files();
+}
Index: linux/drivers/gru/grutables.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/drivers/gru/grutables.h	2008-02-22 09:36:17.000000000 -0600
@@ -0,0 +1,517 @@
+/*
+ * SN Platform GRU Driver
+ *
+ *            GRU DRIVER TABLES, MACROS, externs, etc
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005-2008 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+#ifndef _ASM_IA64_SN_GRUTABLES_H
+#define _ASM_IA64_SN_GRUTABLES_H
+
+/*
+ * Tables:
+ *
+ * 	GFD - GRU File Data     - Holds GSEG options. Used to communicate with
+ * 				  user using ioctls.
+ * 	VDATA-VMA Data		- Holds a few parameters. Head of linked list of
+ * 				  GTS tables for threads using the GSEG
+ * 	GTS - Gru Thread State  - contains info for managing a GSEG context. A
+ * 				  GTS is allocated for each thread accessing a
+ * 				  GSEG.
+ *     	GTD - GRU Thread Data   - contains shadow copy of GRU data when GSEG is
+ *     				  not loaded into a GRU
+ *	GMS - GRU Memory Struct - Used to manage TLB shotdowns. Tracks GRUs
+ *				  where a GSEG has been loaded. Similar to
+ *				  an mm_struct but for GRU.
+ *
+ *	GS  - GRU State 	- Used to manage the state of a GRU chiplet
+ *	BS  - Blade State	- Used to manage state of all GRU chiplets
+ *				  on a blade
+ *
+ *
+ *  Normal task tables for task using GRU.
+ *  		- 2 threads in process
+ *  		- 2 GSEGs open in process
+ *  		- GSEG1 is being used by both tthreads
+ *  		- GSEG2 is used only by thread 2
+ *
+ *       task -->|
+ *       task ---+---> mm ->-- (mmuops) -------------+-> gms
+ *                     |                             |
+ *                     |--> vma -> vdata ---> gts--->|		GSEG1 (thread1)
+ *                     |                  |   gtd    |
+ *                     |                  |          |
+ *                     |                  +-> gts--->|		GSEG1 (thread2)
+ *                     |                      gtd    |
+ *                     |                             |
+ *                     |--> vma -> vdata ---> gts--->|		GSEG2 (thread2)
+ *                     |                      gtd
+ *                     .
+ *                     .
+ *
+ *  GSEGs are logically copy-on-write at fork time.
+ *
+ * At open
+ * 	file.private_data -> gfd
+ *
+ * At mmap,
+ * 	vma -> vdata -> gts -> gtd
+ *
+ * After fork
+ *   parent
+ * 	vma -> vdata -> gts -> gtd	# normal case
+ *   child                  /
+ * 	vma -> ------------/		# gtd shared with parent
+ *
+ *   Parent page fault for GSEG
+ *    before
+ *	vma -> vdata -> gts -> gtd
+ *    after
+ *	vma -> vdata -> gts -> gtd	# allocate a new gtd. Old gtd
+ *					  if left with child
+ *
+ *    Child page fault before
+ * 	 vma -> gtd
+ *     after 
+ *	 vma -> vdata -> gts -> gtd	# Allocate GTS. Move old gtd
+ *	 				  to new gts
+ *
+ */
+
+#include <linux/mmu_notifier.h>
+#include <linux/interrupt.h>
+#include <linux/wait.h>
+#include "gru.h"
+#include "gruhandles.h"
+
+
+ /* Some hacks for running on the hardware simulator */
+#ifdef EMU
+#undef local_irq_disable
+#undef local_irq_enable
+#define local_irq_disable() 	emu_local_irq_disable()
+#define local_irq_enable() 	emu_local_irq_enable()
+void emu_local_irq_disable(void);
+void emu_local_irq_enable(void);
+#define gru_stats		gruhdr->egru_stats
+#define gru_base		gruhdr->egru_base
+#define cpu_trinfo		gruhdr->cpu_trinfo
+#define gru_start_paddr		gruhdr->egru_start_paddr
+#define gru_end_paddr		gruhdr->egru_end_paddr
+#define STATIC
+#else
+extern struct gru_stats_s gru_stats;
+extern struct gru_blade_state *gru_base[];
+extern unsigned long gru_start_paddr, gru_end_paddr;
+#define STATIC static
+#endif
+
+#define GRU_MAX_BLADES		MAX_NUMNODES
+#define GRU_MAX_GRUS		(GRU_MAX_BLADES * GRU_CHIPLETS_PER_BLADE)
+
+#define GRU_DRIVER_ID_STR       "SGI GRU Device Driver"
+#define REVISION                "0.01"
+
+/*
+ * GRU statistics.
+ */
+struct gru_stats_s {
+	atomic_long_t fdata_alloc;
+	atomic_long_t fdata_free;
+	atomic_long_t vdata_alloc;
+	atomic_long_t vdata_free;
+	atomic_long_t gts_alloc;
+	atomic_long_t gts_free;
+	atomic_long_t gtd_alloc;
+	atomic_long_t gtd_free;
+	atomic_long_t vdata_double_alloc;
+	atomic_long_t gts_double_allocate;
+	atomic_long_t assign_context;
+	atomic_long_t assign_context_failed;
+	atomic_long_t free_context;
+	atomic_long_t load_context;
+	atomic_long_t unload_context;
+	atomic_long_t steal_context;
+	atomic_long_t steal_context_failed;
+	atomic_long_t nopfn;
+	atomic_long_t break_cow;
+	atomic_long_t asid_new;
+	atomic_long_t asid_next;
+	atomic_long_t asid_wrap;
+	atomic_long_t asid_reuse;
+	atomic_long_t intr;
+	atomic_long_t call_os;
+	atomic_long_t call_os_tfh_idle;
+	atomic_long_t call_os_check_for_bug;
+	atomic_long_t call_os_wait_queue;
+	atomic_long_t user_flush_tlb;
+	atomic_long_t user_unload_context;
+	atomic_long_t user_exception;
+	atomic_long_t set_task_slice;
+	atomic_long_t migrate_check;
+	atomic_long_t migrated_retarget;
+	atomic_long_t migrated_unload;
+	atomic_long_t migrated_unload_delay;
+	atomic_long_t migrated_nopfn_retarget;
+	atomic_long_t migrated_nopfn_unload;
+	atomic_long_t tlb_dropin;
+	atomic_long_t tlb_dropin_fail_no_asid;
+	atomic_long_t tlb_dropin_fail_upm;
+	atomic_long_t tlb_dropin_fail_invalid;
+	atomic_long_t tlb_dropin_fail_range_active;
+	atomic_long_t mmuops_invalidate_range;
+	atomic_long_t mmuops_invalidate_page;
+	atomic_long_t mmuops_age_page;
+	atomic_long_t mmuops_release;
+	atomic_long_t flush_tlb;
+	atomic_long_t flush_tlb_gru;
+	atomic_long_t flush_tlb_gru_tgh;
+	atomic_long_t flush_tlb_gru_zero_asid;
+};
+
+#define GRU_DEBUG 1
+
+#define OPT_DPRINT	1
+#define OPT_STATS	0x2
+
+#ifdef EMU
+# undef dev_printk
+# define dev_printk(level, dev, s, x...)				\
+			EMULOG(TR_GRU_DEBUG, "DRV", s, x)
+#endif
+
+#define IRQ_GRU			110	/* Starting IRQ number for interrupts */
+
+/* Delay in jiffies between attempts to assign a GRU context */
+#define GRU_ASSIGN_DELAY	((HZ * 20) / 1000)
+
+/* If a process has it's context stolen, min delay in jiffies before trying to
+ * steal a context from another process */
+#define GRU_STEAL_DELAY		((HZ * 200) / 1000)
+
+#ifdef GRU_DEBUG
+#define STAT(id)	do {						\
+				if (options & OPT_STATS)		\
+					atomic_long_inc(&gru_stats.id);	\
+			} while (0)
+
+#define gru_dbg(dev, fmt, x...) do {                                            \
+				if (options & OPT_DPRINT) dev_dbg(dev, "%s: " fmt, __FUNCTION__, x); \
+			   } while (0)
+#else
+#define STAT(id)
+#define gru_dbg(x...)
+#endif
+
+/*-----------------------------------------------------------------------------
+ * ASID management
+ */
+//#define MAX_ASID	0xfffff0
+#define MAX_ASID	0x1f0
+#define MIN_ASID	8
+#define ASID_INC	8	/* number of regions */
+
+/* Generate a GRU asid value from a GRU base asid & a virtual address. */
+#ifdef __ia64__
+#define VADDR_HI_BIT		64
+#elif __x86_64
+#define VADDR_HI_BIT		48
+#else
+#error "bad arch"
+#endif
+#define GRUREGION(addr)		((addr) >> (VADDR_HI_BIT - 3) & 3)
+#define GRUASID(asid, addr)	((asid) + GRUREGION(addr))
+
+/*------------------------------------------------------------------------------
+ *  File & VMS Tables
+ */
+
+struct gru_state;
+
+/*
+ * This is the file_private data structure
+ *   Note: values are used only when GRU is mmaped. At that
+ *   time the current values are copied to the GTS.
+ */
+struct gru_file_data {
+	long		fd_user_options;	/* misc user option flags */
+	int		fd_cbr_au_count;	/* number control blocks AU */
+	int		fd_dsr_au_count;	/* data segment size AU */
+	int		fd_thread_slices;	/* max threads that will access
+						   the context */
+};
+
+/*
+ * This structure is pointed to from the mmstruct via the mmuops pointer. There
+ * is one of these per address space.
+ */
+struct gru_mm_tracker {
+	unsigned int		mt_asid_gen;	/* ASID wrap count */
+	int			mt_asid;	/* current base ASID for gru */
+	unsigned short		mt_ctxbitmap;	/* bitmap of contexts using
+						   asid */
+};
+
+struct gru_mm_struct {
+	struct mmu_notifier	ms_notifier;
+	atomic_t		ms_refcnt;
+	char			ms_released;
+	spinlock_t		ms_asid_lock;
+	atomic_t		ms_range_active;	/* number of range_invals active */
+	wait_queue_head_t	ms_wait_queue;
+	DECLARE_BITMAP(ms_asidmap, GRU_MAX_GRUS);
+	struct gru_mm_tracker	ms_asids[GRU_MAX_GRUS];
+};
+
+/*
+ * One of these structures is allocated when a GSEG is mmaped. The
+ * structure is pointed to by the vma->vm_private_data field in the vma struct.
+ * Note: after a fork, the CHILD's vm_private_data field points to a
+ * "struct gru_thread_data" (the VM open callout can't allocate memory).
+ * The normal vdata/gts/gtd structures are allocated on first fault.
+ */
+struct gru_vma_data {
+	spinlock_t		vd_lock;	/* Serialize access to vma */
+	struct list_head	vd_head;	/* head of linked list of gts */
+	long			vd_user_options;/* misc user option flags */
+	int			vd_cbr_au_count;
+	int			vd_dsr_au_count;
+	int			vd_thread_slices;
+};
+
+/*
+ * One of these is allocated for each thread accessing a mmaped GRU. A linked
+ * list of these structure is hung off the struct gru_vma_data in the mm_struct.
+ */
+struct gru_thread_data {
+	long			td_magic;	/* magic ID for IS_THREAD_DATA */
+	atomic_t		td_refcnt;	/* number of GTS structs sharing data */
+	unsigned long		td_gdata[0];	/* save area for GRU data (CB, DS, CBE) */
+};
+#define TD_MAGIC		0xabcd1235
+#define IS_THREAD_DATA(p)	(*((long *)(p)) == TD_MAGIC)
+
+struct gru_thread_state {
+	struct list_head	ts_next;	/* list - head at vma-private */
+	struct semaphore	ts_ctxsem;	/* load/unload CTX lock */
+	struct mm_struct	*ts_mm;		/* mm currently mapped to context */
+	struct vm_area_struct	*ts_vma;	/* vma of GRU context */
+	struct gru_state	*ts_gru;	/* GRU where the context is loaded */
+	struct gru_mm_struct	*ts_ms;		/* asid & ioproc struct */
+	struct gru_thread_data	*ts_td;		/* gru thread data */
+	unsigned long		ts_steal_jiffies;/* jiffies when context last stolen */
+	pid_t			ts_tgid_owner;	/* task that is using the context - for migration */
+	int			ts_tsid;	/* thread that owns the structure */
+	int			ts_tlb_int_select;/* target cpu if interrupts enabled */
+	int			ts_ctxnum;	/* context number where the context is loaded */
+	atomic_t		ts_refcnt;	/* reference count GTS */
+	long			ts_user_options;/* misc user option flags */
+	unsigned long		ts_cbr_map;	/* map of allocated CBRs */
+	unsigned long		ts_dsr_map;	/* map of allocated DATA resources */
+	unsigned char		ts_dsr_au_count;/* Number of DSR resources requied for contest */
+	unsigned char		ts_cbr_au_count;/* Number of CBR resources requied for contest */
+	char			ts_force_unload;/* force context to be unloaded after migration */
+	char			ts_cbr_idx[GRU_CBR_AU];/* CBR numbers of each allocated CB */
+};
+
+/*
+ * Threaded programs actually allocate an array of GSEGs when a context is created. Each
+ * thread uses a separate GSEG. TSID is the index into the GSEG array.
+ */
+#define TSID(off)		((off) / GRU_GSEG_PAGESIZE)
+#define UGRUADDR(gts)		((gts)->ts_vma->vm_start + (gts)->ts_tsid * GRU_GSEG_PAGESIZE)
+
+#define NULLCTX			-1	/* if context not loaded into GRU */
+
+/*-----------------------------------------------------------------------------
+ *  GRU State Tables
+ */
+
+/*
+ * One of these exists for each GRU chiplet.
+ */
+struct gru_state {
+	struct gru_blade_state	*gs_blade;		/* GRU state for entire blade */
+	unsigned long		gs_gru_base_paddr;	/* Physical address of gru segments (64) */
+	void			*gs_gru_base_vaddr;	/* Virtual address of gru segments (64) */
+	char			gs_present;		/* 0=GRU not present */
+	unsigned char		gs_gid;			/* unique GRU number */
+	char			gs_tgh_local_shift;	/* used to pick TGH for local flush */
+	char			gs_tgh_first_remote;	/* starting TGH# for remote flush */
+	short			gs_blade_id;		/* blade of GRU */
+	spinlock_t		gs_asid_lock;		/* lock used for assigning asids */
+	spinlock_t		gs_lock;		/* lock used for assigning contexts */
+
+	/* ---- the following fields are protected by the gs_asid_lock spinlock ---- */
+	int			gs_asid;		/* Next available ASID */
+	int			gs_asid_limit;		/* Limit of available ASIDs */
+	unsigned int		gs_asid_gen;		/* asid generation. Inc on wrap */
+
+	/* ---- the following fields are protected by the gs_lock spinlock ---- */
+	short			gs_active_contexts;	/* number of contexts in use */
+	unsigned long		gs_context_map;		/* bitmap used to manage contexts in use */
+	unsigned long		gs_cbr_map;		/* bitmap used to manage CB resources */
+	unsigned long		gs_dsr_map;		/* bitmap used to manage DATA resources */
+	struct gru_thread_state	*gs_gts[GRU_NUM_CCH];	/* GTS currently using the context */
+};
+
+/*
+ * This structure contains the GRU state for all the GRUs on a blade.
+ */
+struct gru_blade_state {
+	/* ---- the following fields are protected by the blade bs_lock spinlock ---- */
+	spinlock_t		bs_lock;		/* lock used for stealing contexts */
+	int			bs_lru_ctxnum;		/* STEAL - last context stolen */
+	struct gru_state	*bs_lru_gru;		/* STEAL - last gru stolen */
+
+	struct gru_state	bs_grus[GRU_CHIPLETS_PER_BLADE];
+};
+
+/*-----------------------------------------------------------------------------
+ * Address Primitives
+ */
+#define get_tfm_for_cpu(g, c)	((struct gru_tlb_fault_map *)GRU_TFM((g)->gs_gru_base_vaddr, (c)))
+#define get_tfh_by_index(g, i)	((struct gru_tlb_fault_handle *)GRU_TFH((g)->gs_gru_base_vaddr, (i)))
+#define get_tgh_by_index(g, i)	((struct gru_tlb_global_handle *)GRU_TGH((g)->gs_gru_base_vaddr, (i)))
+#define get_cbe_by_index(g, i)	((struct gru_control_block_extended *)GRU_CBE((g)->gs_gru_base_vaddr, (i)))
+
+/*-----------------------------------------------------------------------------
+ * Useful Macros
+ */
+
+/* Number of bytes to save/restore when unloading/loading GRU contexts */
+#define DSR_BYTES(dsr)		((dsr) * GRU_DSR_AU_BYTES)
+#define CB_CBR_BYTES(cbr)	((cbr) * GRU_HANDLE_BYTES * GRU_CBR_AU_SIZE * 2)
+#define THREADDATABYTES(v) 	(sizeof(struct gru_thread_data) + 		\
+					DSR_BYTES((v)->vd_dsr_au_count)	+	\
+					CB_CBR_BYTES((v)->vd_cbr_au_count))
+
+/* Convert a user CB number to the actual CBRNUM */
+#define thread_cbr_number(gts, n) ((gts)->ts_cbr_idx[(n) / GRU_CBR_AU_SIZE] 	\
+				  * GRU_CBR_AU_SIZE + (n) % GRU_CBR_AU_SIZE)
+
+/* Test if a vaddr is a hugepage */
+#define is_hugepage(m, v)	is_hugepage_only_range(m, (v), PAGE_SIZE)
+
+/* Convert a gid to a pointer to the GRU */
+#define GID_TO_GRU(gid)		(gru_base[(gid) / GRU_CHIPLETS_PER_BLADE] ?	\
+				 (&gru_base[(gid) / GRU_CHIPLETS_PER_BLADE]->	\
+					bs_grus[(gid) % GRU_CHIPLETS_PER_BLADE]) : NULL)
+
+/* Scan all active GRUs in a GRU bitmap */
+#define for_each_gru_in_bitmap(gid, map)					\
+	for (gid = find_first_bit(map, GRU_MAX_GRUS); gid < GRU_MAX_GRUS;	\
+			 gid++, gid = find_next_bit(map, GRU_MAX_GRUS, gid))
+
+/* Scan all active GRUs on a specific blade */
+#define for_each_gru_on_blade(gru, nid, i)					\
+	for (gru = gru_base[nid]->bs_grus, i = 0; i < GRU_CHIPLETS_PER_BLADE; i++, gru++)	\
+		if (gru->gs_present)
+
+/* Scan all active GTSs on a gru. Note: must hold ss_lock to use thsi macro. */
+#define for_each_gts_on_gru(gts, gru, ctxnum)					\
+	if (gru->gs_present)							\
+		for (ctxnum = 0; ctxnum < GRU_NUM_CCH; ctxnum++)		\
+			if ((gts = gru->gs_gts[ctxnum]))
+
+/* Scan each CBR whose bit is set in a TFM (or copy of) */
+#define for_each_cbr_in_tfm(i, map)						\
+	for (i = find_first_bit(map, GRU_NUM_CBE); i < GRU_NUM_CBE;		\
+			 i++, i = find_next_bit(map, GRU_NUM_CBE, i))
+
+/* Scan each CBR in a CBR bitmap. Note: multiple CBRs in an allocation unit */
+#define for_each_cbr_in_allocation_map(i, map, k)				\
+	for (k = find_first_bit(map, GRU_CBR_AU); k < GRU_CBR_AU;		\
+			 k = find_next_bit(map, GRU_CBR_AU, k + 1)) 		\
+		for (i = k*GRU_CBR_AU_SIZE; i < (k + 1) * GRU_CBR_AU_SIZE; i++)
+
+/* Scan each DSR in a DSR bitmap. Note: multiple DSRs in an allocation unit */
+#define for_each_dsr_in_allocation_map(i, map, k)				\
+	for (k = find_first_bit((const unsigned long *)map, GRU_DSR_AU);	\
+			k < GRU_DSR_AU;						\
+			k = find_next_bit((const unsigned long *)map, GRU_DSR_AU, k + 1))\
+		for (i = k*GRU_DSR_AU_CL; i < (k + 1) * GRU_DSR_AU_CL; i++)
+
+#define gseg_physical_address(gru, ctxnum)					\
+		(gru->gs_gru_base_paddr + ctxnum * GRU_GSEG_STRIDE)
+#define gseg_virtual_address(gru, ctxnum)					\
+		(gru->gs_gru_base_vaddr + ctxnum * GRU_GSEG_STRIDE)
+
+/* ZZZ Hacks until we hook up to the rest of the UV infrastructure */
+#define NODESPERBLADE		1
+#define CPUSPERSOCKET		8
+#define SOCKETSPERBLADE		2
+#define CPUSPERBLADE		(CPUSPERSOCKET * SOCKETSPERBLADE)
+#define CPUSPERNODE		(CPUSPERBLADE / NODESPERBLADE)
+
+#define blade_processor_id() 	(smp_processor_id() % CPUSPERBLADE)
+#define numa_blade_id() 	(numa_node_id() / NODESPERBLADE)
+#define nid_to_blade(nid)	((nid) / NODESPERBLADE)
+#define nr_cpus_blade(nid)	(CPUSPERSOCKET * SOCKETSPERBLADE)
+#define cpu_to_blade(cpu)	((cpu) / CPUSPERBLADE)
+
+/*-----------------------------------------------------------------------------
+ * Lock / Unlock GRU handles
+ * 	Use the "delresp" bit in the handle as a "lock" bit.
+ */
+
+static inline void lock_handle(void *h)
+{
+	while (test_and_set_bit(1, h)) {
+		cpu_relax();
+#ifdef EMU
+		my_usleep(100);
+#endif
+	}
+}
+
+static inline void unlock_handle(void *h)
+{
+	clear_bit(1, h);
+}
+
+/*-----------------------------------------------------------------------------
+ * Function prototypes & externs
+ */
+extern struct vm_operations_struct gru_vm_ops;
+extern struct device *grudev;
+struct gru_unload_context_req;
+struct gru_vma_data *gru_alloc_vma_data(struct vm_area_struct *vma, int tsid,
+					void *gtd);
+struct gru_thread_state *gru_find_thread_state(struct vm_area_struct *vma,
+					       int tsid);
+void gru_unload_context(struct gru_thread_state *gts, int savestate);
+void gtd_drop(struct gru_thread_data *gtd);
+void gts_drop(struct gru_thread_state *gts);
+void gru_tgh_flush_init(struct gru_state *gru);
+int gru_kservices_init(struct gru_state *gru);
+irqreturn_t gru_intr(int irq, void *dev_id);
+int gru_handle_user_call_os(unsigned long address);
+int gru_user_flush_tlb(unsigned long arg);
+int gru_user_unload_context(unsigned long arg);
+int gru_get_exception_detail(unsigned long arg);
+int gru_set_task_slice(long address);
+int gru_cpu_fault_map_id(void);
+void gru_flush_all_tlb(struct gru_state *gru);
+void gru_migrate_task(int pcpu, int cpu);
+int gru_proc_init(void);
+void gru_proc_exit(void);
+unsigned long reserve_gru_cb_resources(struct gru_state *gru, int cbr_au_count,
+				       char *cbmap);
+unsigned long reserve_gru_ds_resources(struct gru_state *gru, int dsr_au_count,
+				       char *dsmap);
+extern unsigned long gru_nopfn(struct vm_area_struct *, unsigned long);
+extern struct gru_mm_struct *gru_register_mmu_notifier(void);
+extern void gru_drop_mmu_notifier(struct gru_mm_struct *gms);
+
+void gru_flush_tlb_range(struct gru_mm_struct *gms, unsigned long start,
+                           unsigned long len);
+
+extern unsigned long options;
+
+#endif /* _ASM_IA64_SN_GRUTABLES_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
