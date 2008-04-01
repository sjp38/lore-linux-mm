From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 9/9] XPMEM: Simple example
Date: Tue, 01 Apr 2008 13:55:40 -0700
Message-ID: <20080401205637.839049326@sgi.com>
References: <20080401205531.986291575@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename=xpmem_test
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Hugh Dickins <hugh@veritas.com>
Cc: steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org
List-Id: linux-mm.kvack.org

A simple test program (well actually a pair).  They are fairly easy to use.

NOTE: the xpmem.h is copied from the kernel/drivers/misc/xp/xpmem.h
file.

Type make.  Then from one session, type ./A1.  Grab the first
line of output which should begin with ./A2 and paste the whole line
into a second session.  Paste as many times as you like.  Each pass will
increment the value one additional time.  When you are tired, hit enter
in the first window.  You should see the same value printed from A1 as
you most recently received from A2.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 xpmem_test/A1.c     |   64 +++++++++++++++++++++++++
 xpmem_test/A2.c     |   70 ++++++++++++++++++++++++++++
 xpmem_test/Makefile |   14 +++++
 xpmem_test/xpmem.h  |  130 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 278 insertions(+)

Index: linux-2.6/xpmem_test/A1.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/xpmem_test/A1.c	2008-04-01 13:36:06.982428295 -0700
@@ -0,0 +1,64 @@
+/*
+ *  Simple test program.  Makes a segment then waits for an input line
+ * and finally prints the value of the first integer of that segment.
+ */
+
+#include <errno.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <stropts.h>
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <unistd.h>
+
+#include "xpmem.h"
+
+int xpmem_fd;
+
+int
+main(int argc, char **argv)
+{
+	char input[32];
+	struct xpmem_cmd_make make_info;
+	int *data_block;
+	int ret;
+	__s64 segid;
+
+	xpmem_fd = open("/dev/xpmem", O_RDWR);
+	if (xpmem_fd == -1) {
+		perror("Opening /dev/xpmem");
+		return -1;
+	}
+
+	data_block = mmap(NULL, getpagesize(), PROT_READ | PROT_WRITE,
+			  MAP_SHARED | MAP_ANONYMOUS, 0, 0);
+	if (data_block == MAP_FAILED) {
+		perror("Creating mapping.");
+		return -1;
+	}
+	data_block[0] = 1;
+
+	make_info.vaddr = (__u64) data_block;
+	make_info.size = getpagesize();
+	make_info.permit_type = XPMEM_PERMIT_MODE;
+	make_info.permit_value = (__u64) 0600;
+	ret = ioctl(xpmem_fd, XPMEM_CMD_MAKE, &make_info);
+	if (ret != 0) {
+		perror("xpmem_make");
+		return -1;
+	}
+
+	segid = make_info.segid;
+	printf("./A2 %d %d %d %d\ndata_block[0] = %d\n",
+	       (int)(segid >> 48 & 0xffff), (int)(segid >> 32 & 0xffff),
+	       (int)(segid >> 16 & 0xffff), (int)(segid & 0xffff),
+	       data_block[0]);
+	printf("Waiting for input before exiting.\n");
+	fscanf(stdin, "%s", input);
+
+	printf("data_block[0] = %d\n", data_block[0]);
+
+	return 0;
+}
Index: linux-2.6/xpmem_test/A2.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/xpmem_test/A2.c	2008-04-01 13:36:09.498469523 -0700
@@ -0,0 +1,70 @@
+/*
+ * Simple test program that gets then attaches an xpmem segment identified
+ * on the command line then increments the first integer of that buffer by
+ * one and exits.
+ */
+
+#include <errno.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <stropts.h>
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <unistd.h>
+
+#include "xpmem.h"
+
+int xpmem_fd;
+
+int
+main(int argc, char **argv)
+{
+	int ret;
+	__s64 segid;
+	__s64 apid;
+	struct xpmem_cmd_get get_info;
+	struct xpmem_cmd_attach attach_info;
+	int *attached_buffer;
+
+	xpmem_fd = open("/dev/xpmem", O_RDWR);
+	if (xpmem_fd == -1) {
+		perror("Opening /dev/xpmem");
+		return -1;
+	}
+
+	segid = (__s64) atoi(argv[1]) << 48;
+	segid |= (__s64) atoi(argv[2]) << 32;
+	segid |= (__s64) atoi(argv[3]) << 16;
+	segid |= (__s64) atoi(argv[4]);
+	get_info.segid = segid;
+	get_info.flags = XPMEM_RDWR;
+	get_info.permit_type = XPMEM_PERMIT_MODE;
+	get_info.permit_value = (__u64) NULL;
+	ret = ioctl(xpmem_fd, XPMEM_CMD_GET, &get_info);
+	if (ret != 0) {
+		perror("xpmem_get");
+		return -1;
+	}
+	apid = get_info.apid;
+
+	attach_info.apid = get_info.apid;
+	attach_info.offset = 0;
+	attach_info.size = getpagesize();
+	attach_info.vaddr = (__u64) NULL;
+	attach_info.fd = xpmem_fd;
+	attach_info.flags = 0;
+
+	ret = ioctl(xpmem_fd, XPMEM_CMD_ATTACH, &attach_info);
+	if (ret != 0) {
+		perror("xpmem_attach");
+		return -1;
+	}
+
+	attached_buffer = (int *)attach_info.vaddr;
+	attached_buffer[0]++;
+
+	printf("Just incremented the value to %d\n", attached_buffer[0]);
+	return 0;
+}
Index: linux-2.6/xpmem_test/Makefile
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/xpmem_test/Makefile	2008-04-01 13:36:19.218628862 -0700
@@ -0,0 +1,14 @@
+
+default:	A1 A2
+
+A1:	A1.c xpmem.h
+	gcc -Wall -o A1 A1.c
+
+A2:	A2.c xpmem.h
+	gcc -Wall -o A2 A2.c
+
+indent:
+	indent -npro -kr -i8 -ts8 -sob -l80 -ss -ncs -cp1 -psl -npcs A1.c A2.c
+
+clean:
+	rm -f A1 A2 *~
Index: linux-2.6/xpmem_test/xpmem.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/xpmem_test/xpmem.h	2008-04-01 13:36:24.418714133 -0700
@@ -0,0 +1,130 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+/*
+ * Cross Partition Memory (XPMEM) structures and macros.
+ */
+
+#ifndef _ASM_IA64_SN_XPMEM_H
+#define _ASM_IA64_SN_XPMEM_H
+
+#include <linux/types.h>
+#include <linux/ioctl.h>
+
+/*
+ * basic argument type definitions
+ */
+struct xpmem_addr {
+	__s64 apid;		/* apid that represents memory */
+	off_t offset;		/* offset into apid's memory */
+};
+
+#define XPMEM_MAXADDR_SIZE	(size_t)(-1L)
+
+#define XPMEM_ATTACH_WC		0x10000
+#define XPMEM_ATTACH_GETSPACE	0x20000
+
+/*
+ * path to XPMEM device
+ */
+#define XPMEM_DEV_PATH  "/dev/xpmem"
+
+/*
+ * The following are the possible XPMEM related errors.
+ */
+#define XPMEM_ERRNO_NOPROC	2004	/* unknown thread due to fork() */
+
+/*
+ * flags for segment permissions
+ */
+#define XPMEM_RDONLY	0x1
+#define XPMEM_RDWR	0x2
+
+/*
+ * Valid permit_type values for xpmem_make().
+ */
+#define XPMEM_PERMIT_MODE	0x1
+
+/*
+ * ioctl() commands used to interface to the kernel module.
+ */
+#define XPMEM_IOC_MAGIC		'x'
+#define XPMEM_CMD_VERSION	_IO(XPMEM_IOC_MAGIC, 0)
+#define XPMEM_CMD_MAKE		_IO(XPMEM_IOC_MAGIC, 1)
+#define XPMEM_CMD_REMOVE	_IO(XPMEM_IOC_MAGIC, 2)
+#define XPMEM_CMD_GET		_IO(XPMEM_IOC_MAGIC, 3)
+#define XPMEM_CMD_RELEASE	_IO(XPMEM_IOC_MAGIC, 4)
+#define XPMEM_CMD_ATTACH	_IO(XPMEM_IOC_MAGIC, 5)
+#define XPMEM_CMD_DETACH	_IO(XPMEM_IOC_MAGIC, 6)
+#define XPMEM_CMD_COPY		_IO(XPMEM_IOC_MAGIC, 7)
+#define XPMEM_CMD_BCOPY		_IO(XPMEM_IOC_MAGIC, 8)
+#define XPMEM_CMD_FORK_BEGIN	_IO(XPMEM_IOC_MAGIC, 9)
+#define XPMEM_CMD_FORK_END	_IO(XPMEM_IOC_MAGIC, 10)
+
+/*
+ * Structures used with the preceding ioctl() commands to pass data.
+ */
+struct xpmem_cmd_make {
+	__u64 vaddr;
+	size_t size;
+	int permit_type;
+	__u64 permit_value;
+	__s64 segid;		/* returned on success */
+};
+
+struct xpmem_cmd_remove {
+	__s64 segid;
+};
+
+struct xpmem_cmd_get {
+	__s64 segid;
+	int flags;
+	int permit_type;
+	__u64 permit_value;
+	__s64 apid;		/* returned on success */
+};
+
+struct xpmem_cmd_release {
+	__s64 apid;
+};
+
+struct xpmem_cmd_attach {
+	__s64 apid;
+	off_t offset;
+	size_t size;
+	__u64 vaddr;
+	int fd;
+	int flags;
+};
+
+struct xpmem_cmd_detach {
+	__u64 vaddr;
+};
+
+struct xpmem_cmd_copy {
+	__s64 src_apid;
+	off_t src_offset;
+	__s64 dst_apid;
+	off_t dst_offset;
+	size_t size;
+};
+
+#ifndef __KERNEL__
+extern int xpmem_version(void);
+extern __s64 xpmem_make(void *, size_t, int, void *);
+extern int xpmem_remove(__s64);
+extern __s64 xpmem_get(__s64, int, int, void *);
+extern int xpmem_release(__s64);
+extern void *xpmem_attach(struct xpmem_addr, size_t, void *);
+extern void *xpmem_attach_wc(struct xpmem_addr, size_t, void *);
+extern void *xpmem_attach_getspace(struct xpmem_addr, size_t, void *);
+extern int xpmem_detach(void *);
+extern int xpmem_bcopy(struct xpmem_addr, struct xpmem_addr, size_t);
+#endif
+
+#endif /* _ASM_IA64_SN_XPMEM_H */

-- 

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
