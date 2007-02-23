Received: by nz-out-0506.google.com with SMTP id f1so379271nzc
        for <linux-mm@kvack.org>; Thu, 22 Feb 2007 22:33:02 -0800 (PST)
Date: Fri, 23 Feb 2007 07:32:28 +0100
From: Jaya Kumar <jayakumar.lkml@gmail.com>
Subject: [RFC 2.6.20 1/1] fbdev,mm: Deferred IO and hecubafb driver
Message-ID: <20070223063228.GA9906@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Tony, Paul, Peter, fbdev, lkml, and mm,

This is a first pass at abstracting deferred IO out from hecubafb and
into fbdev as was discussed before: 
http://marc.theaimsgroup.com/?l=linux-fbdev-devel&m=117187443327466&w=2

Please let me know your feedback and if it looks okay so far.

Thanks,
jaya

Signed-off-by: Jaya Kumar <jayakumar.lkml@gmail.com>

---

 Documentation/fb/deferred_io.txt |  114 ++++++++
 drivers/video/Kconfig            |   20 +
 drivers/video/Makefile           |    2 
 drivers/video/fb_defio.c         |  104 +++++++
 drivers/video/fbmem.c            |    2 
 drivers/video/hecubafb.c         |  513 +++++++++++++++++++++++++++++++++++++++
 include/linux/fb.h               |   25 +
 mm/rmap.c                        |    1 
 8 files changed, 781 insertions(+)

diff --git a/Documentation/fb/deferred_io.txt b/Documentation/fb/deferred_io.txt
new file mode 100644
index 0000000..be74dcc
--- /dev/null
+++ b/Documentation/fb/deferred_io.txt
@@ -0,0 +1,114 @@
+Deferred IO
+-----------
+
+Deferred IO is a way to delay and repurpose IO. It uses host memory as a
+buffer and the MMU pagefault as a pretrigger for when to perform the device
+IO. The following example may be a useful explaination of how one such setup
+works:
+
+- userspace app like Xfbdev mmaps framebuffer
+- deferred IO and driver sets up nopage and page_mkwrite handlers
+- userspace app tries to write to mmaped vaddress
+- we get pagefault and reach nopage handler
+- nopage handler finds and returns physical page
+- we get page_mkwrite where we add this page to a list
+- schedule a workqueue task to be run after a delay
+- app continues writing to that page with no additional cost. this is
+  the key benefit.
+- the workqueue task comes in and mkcleans the pages on the list, then
+ completes the work associated with updating the framebuffer. this is
+  the real work talking to the device.
+- app tries to write to the address (that has now been mkcleaned)
+- get pagefault and the above sequence occurs again
+
+As can be seen from above, one benefit is roughly to allow bursty framebuffer
+writes to occur at minimum cost. Then after some time when hopefully things
+have gone quiet, we go and really update the framebuffer which would be
+a relatively more expensive operation.
+
+For some types of nonvolatile high latency displays, the desired image is
+the final image rather than the intermediate stages which is why it's okay
+to not update for each write that is occuring.
+
+It may be the case that this is useful in other scenarios as well. Paul Mundt
+has mentioned a case where it is beneficial to use the page count to decide
+whether to coalesce and issue SG DMA or to do memory bursts.
+
+Another one may be if one has a device framebuffer that is in an usual format,
+say diagonally shifting RGB, this may then be a mechanism for you to allow
+apps to pretend to have a normal framebuffer but reswizzle for the device
+framebuffer at vsync time based on the touched pagelist.
+
+How to use it: (for applications)
+---------------------------------
+No changes needed. mmap the framebuffer like normal and just use it.
+
+How to use it: (for fbdev drivers)
+----------------------------------
+The following example may be helpful.
+
+1. Setup your mmap and vm_ops structures. Eg:
+
+static struct fb_deferred_io hecubafb_defio = {
+	.delay		= HZ,
+	.deferred_io	= hecubafb_dpy_deferred_io,
+};
+
+The delay is the minimum delay between when the page_mkwrite trigger occurs
+and when the deferred_io callback is called. The deferred_io callback is
+explained below.
+
+static struct vm_operations_struct hecubafb_vm_ops = {
+	.nopage   	= hecubafb_vm_nopage,
+	.page_mkwrite	= fb_deferred_io_mkwrite,
+};
+
+You will need a nopage routine to find and retrive the struct page for your
+framebuffer pages. You must set page_mkwrite to fb_deferred_io_mkwrite.
+Here's the example nopage for hecubafb where it is a vmalloced framebuffer. 
+
+static int hecubafb_mmap(struct fb_info *info, struct vm_area_struct *vma)
+{
+	vma->vm_ops = &hecubafb_vm_ops;
+	vma->vm_flags |= ( VM_IO | VM_RESERVED | VM_DONTEXPAND );
+	vma->vm_private_data = info;
+	return 0;
+}
+
+static struct page* hecubafb_vm_nopage(struct vm_area_struct *vma, 
+					unsigned long vaddr, int *type)
+{
+	unsigned long offset;
+	struct page *page;
+	struct fb_info *info = vma->vm_private_data;
+
+	offset = (vaddr - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
+	if (offset >= (DPY_W*DPY_H)/8)
+		return NOPAGE_SIGBUS;
+
+	page = vmalloc_to_page(info->screen_base + offset);
+	if (!page)
+		return NOPAGE_OOM;
+
+	get_page(page);
+	if (type)
+		*type = VM_FAULT_MINOR;
+	return page;
+}
+
+2. Setup your deferred IO callback. Eg:
+static void hecubafb_dpy_deferred_io(struct fb_info *info,
+				struct list_head *pagelist)
+
+The deferred_io callback is where you would perform all your IO to the display
+device. You receive the pagelist which is the list of pages that were written
+to during the delay. You must not modify this list. This callback is called
+from a workqueue. 
+
+3. Call init (done inside register_framebuffer)
+	info->fbdefio = &hecubafb_defio;
+
+	retval = register_framebuffer(info);
+
+4. Call cleanup (done inside unregister_framebuffer)
+		unregister_framebuffer(info);
diff --git a/drivers/video/Kconfig b/drivers/video/Kconfig
index 8874cf2..a03c772 100644
--- a/drivers/video/Kconfig
+++ b/drivers/video/Kconfig
@@ -85,6 +85,12 @@ config FB_CFB_IMAGEBLIT
 	  blitting. This is used by drivers that don't provide their own
 	  (accelerated) version.
 
+# used by hecubafb
+config FB_DEFERRED_IO
+	bool
+	depends on FB
+	default n
+
 config FB_SVGALIB
 	tristate
 	depends on FB
@@ -540,6 +546,20 @@ config FB_IMAC
 	help
 	  This is the frame buffer device driver for the Intel-based Macintosh
 
+config FB_HECUBA
+	tristate "Hecuba board support"
+	depends on FB && X86 && MMU
+	select FB_CFB_FILLRECT
+	select FB_CFB_COPYAREA
+	select FB_CFB_IMAGEBLIT
+	select FB_DEFERRED_IO
+	help
+	  This enables support for the Hecuba board. This driver was tested 
+	  with an E-Ink 800x600 display and x86 SBCs through a 16 bit GPIO
+	  interface (8 bit data, 4 bit control). If you anticpate using
+	  this driver, say Y or M; otherwise say N. You must specify the
+	  GPIO IO address to be used for setting control and data.
+
 config FB_HGA
 	tristate "Hercules mono graphics support"
 	depends on FB && X86
diff --git a/drivers/video/Makefile b/drivers/video/Makefile
index 6801edf..c36a323 100644
--- a/drivers/video/Makefile
+++ b/drivers/video/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_FB_CFB_IMAGEBLIT) += cfbimgblt.o
 obj-$(CONFIG_FB_SVGALIB)       += svgalib.o
 obj-$(CONFIG_FB_MACMODES)      += macmodes.o
 obj-$(CONFIG_FB_DDC)           += fb_ddc.o
+obj-$(CONFIG_FB_DEFERRED_IO)   += fb_defio.o
 
 # Hardware specific drivers go first
 obj-$(CONFIG_FB_AMIGA)            += amifb.o c2p.o
@@ -65,6 +66,7 @@ obj-$(CONFIG_FB_SGIVW)            += sgivwfb.o
 obj-$(CONFIG_FB_ACORN)            += acornfb.o
 obj-$(CONFIG_FB_ATARI)            += atafb.o
 obj-$(CONFIG_FB_MAC)              += macfb.o
+obj-$(CONFIG_FB_HECUBA)           += hecubafb.o
 obj-$(CONFIG_FB_HGA)              += hgafb.o
 obj-$(CONFIG_FB_IGA)              += igafb.o
 obj-$(CONFIG_FB_APOLLO)           += dnfb.o
diff --git a/drivers/video/fb_defio.c b/drivers/video/fb_defio.c
new file mode 100644
index 0000000..c3e57cc
--- /dev/null
+++ b/drivers/video/fb_defio.c
@@ -0,0 +1,104 @@
+/*
+ *  linux/drivers/video/fb_defio.c
+ *
+ *  Copyright (C) 2006 Jaya Kumar
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file COPYING in the main directory of this archive
+ * for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/fb.h>
+#include <linux/list.h>
+#include <asm/uaccess.h>
+
+/* to support deferred IO */
+#include <linux/rmap.h>
+#include <linux/pagemap.h>
+
+/* workqueue callback */
+static void fb_deferred_io_work(struct work_struct *work)
+{
+	struct fb_info *info = container_of(work, struct fb_info, 
+						deferred_work.work);
+	struct list_head *node, *next;
+	struct page *cur;
+	struct fb_deferred_io *fbdefio = info->fbdefio;
+
+	/* here we mkclean the pages, then do all deferred IO */
+	mutex_lock(&fbdefio->lock);
+	list_for_each_entry(cur, &fbdefio->pagelist, lru) {
+		lock_page(cur);
+		page_mkclean(cur);
+		unlock_page(cur);
+	}
+
+	/* driver's callback with pagelist */
+	fbdefio->deferred_io(info, &fbdefio->pagelist); 
+
+	/* clear the list */
+	list_for_each_safe(node, next, &fbdefio->pagelist) {
+		list_del(node);
+	}
+	mutex_unlock(&fbdefio->lock);
+}
+
+/* vm_ops->page_mkwrite handler */
+int fb_deferred_io_mkwrite(struct vm_area_struct *vma, 
+					struct page *page)
+{
+	struct fb_info *info = vma->vm_private_data;
+	struct fb_deferred_io *fbdefio = info->fbdefio;
+
+	/* this is a callback we get when userspace first tries to 
+	write to the page. we schedule a workqueue. that workqueue 
+	will eventually mkclean the touched pages and execute the 
+	deferred framebuffer IO. then if userspace touches a page 
+	again, we repeat the same scheme */
+
+	/* protect against the workqueue changing the page list */
+	mutex_lock(&fbdefio->lock);
+	list_add(&page->lru, &fbdefio->pagelist);
+	mutex_unlock(&fbdefio->lock);
+
+	/* come back after delay to process the deferred IO */
+	schedule_delayed_work(&info->deferred_work, fbdefio->delay);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(fb_deferred_io_mkwrite);
+
+void fb_deferred_io_init(struct fb_info *info)
+{
+	struct fb_deferred_io *fbdefio = info->fbdefio;
+
+	if (!fbdefio)
+		return;
+	mutex_init(&fbdefio->lock);
+	INIT_DELAYED_WORK(&info->deferred_work, fb_deferred_io_work);
+	INIT_LIST_HEAD(&fbdefio->pagelist);
+	if (fbdefio->delay == 0) /* set a default of 1 s */
+		fbdefio->delay = HZ;
+}
+EXPORT_SYMBOL_GPL(fb_deferred_io_init);
+
+void fb_deferred_io_cleanup(struct fb_info *info)
+{
+	struct fb_deferred_io *fbdefio = info->fbdefio;
+
+	if (!fbdefio)
+		return;
+	cancel_delayed_work(&info->deferred_work);
+	flush_scheduled_work();
+}
+EXPORT_SYMBOL_GPL(fb_deferred_io_cleanup);
+
+MODULE_LICENSE("GPL");
diff --git a/drivers/video/fbmem.c b/drivers/video/fbmem.c
index 2822526..863126a 100644
--- a/drivers/video/fbmem.c
+++ b/drivers/video/fbmem.c
@@ -1325,6 +1325,7 @@ register_framebuffer(struct fb_info *fb_info)
 
 	event.info = fb_info;
 	fb_notifier_call_chain(FB_EVENT_FB_REGISTERED, &event);
+	fb_deferred_io_init(fb_info);
 	return 0;
 }
 
@@ -1355,6 +1356,7 @@ unregister_framebuffer(struct fb_info *fb_info)
 	fb_destroy_modelist(&fb_info->modelist);
 	registered_fb[i]=NULL;
 	num_registered_fb--;
+	fb_deferred_io_cleanup(fb_info);
 	fb_cleanup_device(fb_info);
 	device_destroy(fb_class, MKDEV(FB_MAJOR, i));
 	event.info = fb_info;
diff --git a/drivers/video/hecubafb.c b/drivers/video/hecubafb.c
new file mode 100644
index 0000000..519659a
--- /dev/null
+++ b/drivers/video/hecubafb.c
@@ -0,0 +1,513 @@
+/*
+ * linux/drivers/video/hecubafb.c -- FB driver for Hecuba controller
+ *
+ * Copyright (C) 2006, Jaya Kumar 
+ * This work was sponsored by CIS(M) Sdn Bhd
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License. See the file COPYING in the main directory of this archive for
+ * more details.
+ *
+ * Layout is based on skeletonfb.c by James Simmons and Geert Uytterhoeven.
+ * This work was possible because of apollo display code from E-Ink's website
+ * http://support.eink.com/community
+ * All information used to write this code is from public material made
+ * available by E-Ink on its support site. Some commands such as 0xA4
+ * were found by looping through cmd=0x00 thru 0xFF and supplying random
+ * values. There are other commands that the display is capable of,
+ * beyond the 5 used here but they are more complex. 
+ *
+ * This driver is written to be used with the Hecuba display controller
+ * board, and tested with the EInk 800x600 display in 1 bit mode. 
+ * The interface between Hecuba and the host is TTL based GPIO. The
+ * GPIO requirements are 8 writable data lines and 6 lines for control.
+ * Only 4 of the controls are actually used here but 6 for future use.
+ * The driver requires the IO addresses for data and control GPIO at 
+ * load time. It is also possible to use this display with a standard 
+ * PC parallel port. 
+ *
+ * General notes:
+ * - User must set hecubafb_enable=1 to enable it
+ * - User must set dio_addr=0xIOADDR cio_addr=0xIOADDR c2io_addr=0xIOADDR
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/fb.h>
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/list.h>
+#include <asm/uaccess.h>
+
+/* Apollo controller specific defines */
+#define APOLLO_START_NEW_IMG	0xA0
+#define APOLLO_STOP_IMG_DATA	0xA1
+#define APOLLO_DISPLAY_IMG	0xA2
+#define APOLLO_ERASE_DISPLAY	0xA3
+#define APOLLO_INIT_DISPLAY	0xA4
+
+/* Hecuba interface specific defines */
+/* WUP is inverted, CD is inverted, DS is inverted */
+#define HCB_NWUP_BIT	0x01
+#define HCB_NDS_BIT 	0x02
+#define HCB_RW_BIT 	0x04
+#define HCB_NCD_BIT 	0x08
+#define HCB_ACK_BIT 	0x80
+
+/* Display specific information */
+#define DPY_W 600
+#define DPY_H 800
+
+struct hecubafb_par {
+	unsigned long dio_addr;
+	unsigned long cio_addr;
+	unsigned long c2io_addr;
+	unsigned char ctl;
+	struct fb_info *info;
+	unsigned int irq;
+};
+
+static struct fb_fix_screeninfo hecubafb_fix __initdata = {
+	.id =		"hecubafb",
+	.type =		FB_TYPE_PACKED_PIXELS,
+	.visual =	FB_VISUAL_MONO01,
+	.xpanstep =	0,
+	.ypanstep =	0,
+	.ywrapstep =	0,
+	.accel =	FB_ACCEL_NONE,
+};
+
+static struct fb_var_screeninfo hecubafb_var __initdata = {
+	.xres		= DPY_W,
+	.yres		= DPY_H,
+	.xres_virtual	= DPY_W,
+	.yres_virtual	= DPY_H,
+	.bits_per_pixel	= 1,
+	.nonstd		= 1,
+};
+
+static unsigned long dio_addr;
+static unsigned long cio_addr;
+static unsigned long c2io_addr;
+static unsigned long splashval;
+static unsigned int nosplash;
+static unsigned int hecubafb_enable;
+static unsigned int irq;
+
+static DECLARE_WAIT_QUEUE_HEAD(hecubafb_waitq);
+
+static void hcb_set_ctl(struct hecubafb_par *par)
+{
+	outb(par->ctl, par->cio_addr);
+}
+
+static unsigned char hcb_get_ctl(struct hecubafb_par *par)
+{
+	return inb(par->c2io_addr);
+}
+
+static void hcb_set_data(struct hecubafb_par *par, unsigned char value)
+{
+	outb(value, par->dio_addr);
+}
+
+static int __devinit apollo_init_control(struct hecubafb_par *par)
+{
+	unsigned char ctl;
+	/* for init, we want the following setup to be set:
+	WUP = lo
+	ACK = hi
+	DS = hi
+	RW = hi
+	CD = lo 
+	*/
+
+	/* write WUP to lo, DS to hi, RW to hi, CD to lo */
+	par->ctl = HCB_NWUP_BIT | HCB_RW_BIT | HCB_NCD_BIT ;
+	par->ctl &= ~HCB_NDS_BIT;
+	hcb_set_ctl(par);
+
+	/* check ACK is not lo */
+	ctl = hcb_get_ctl(par);
+	if ((ctl & HCB_ACK_BIT)) {
+		printk(KERN_ERR "Fail because ACK is already low\n");
+		return -ENXIO;
+	}
+
+	return 0;
+}
+
+void hcb_wait_for_ack(struct hecubafb_par *par)
+{
+
+	int timeout;
+	unsigned char ctl;
+
+	timeout=500;
+	do {
+		ctl = hcb_get_ctl(par);
+		if ((ctl & HCB_ACK_BIT)) 
+			return;
+		udelay(1);
+	} while (timeout--);
+	printk(KERN_ERR "timed out waiting for ack\n");
+}
+
+void hcb_wait_for_ack_clear(struct hecubafb_par *par)
+{
+
+	int timeout;
+	unsigned char ctl;
+
+	timeout=500;
+	do {
+		ctl = hcb_get_ctl(par);
+		if (!(ctl & HCB_ACK_BIT)) 
+			return;
+		udelay(1);
+	} while (timeout--);
+	printk(KERN_ERR "timed out waiting for clear\n");
+}
+
+void apollo_send_data(struct hecubafb_par *par, unsigned char data)
+{
+	/* set data */
+	hcb_set_data(par, data);
+
+	/* set DS low */
+	par->ctl |= HCB_NDS_BIT;
+	hcb_set_ctl(par);
+
+	hcb_wait_for_ack(par);
+
+	/* set DS hi */
+	par->ctl &= ~(HCB_NDS_BIT);
+	hcb_set_ctl(par);
+	
+	hcb_wait_for_ack_clear(par);
+}
+
+void apollo_send_command(struct hecubafb_par *par, unsigned char data)
+{
+	/* command so set CD to high */
+	par->ctl &= ~(HCB_NCD_BIT);
+	hcb_set_ctl(par);
+
+	/* actually strobe with command */
+	apollo_send_data(par, data);
+
+	/* clear CD back to low */
+	par->ctl |= (HCB_NCD_BIT);
+	hcb_set_ctl(par);
+}
+
+/* main hecubafb functions */
+
+static void hecubafb_dpy_update(struct hecubafb_par *par)
+{
+	int i;
+	unsigned char *buf = par->info->screen_base;
+
+	apollo_send_command(par, 0xA0);
+
+	for (i=0; i < (DPY_W*DPY_H/8); i++) {
+		apollo_send_data(par, *(buf++));
+	}
+
+	apollo_send_command(par, 0xA1);
+	apollo_send_command(par, 0xA2);
+}
+
+/* this is called back from the deferred io workqueue */
+static void hecubafb_dpy_deferred_io(struct fb_info *info, 
+				struct list_head *pagelist)
+{
+	hecubafb_dpy_update(info->par);
+}
+
+static void hecubafb_fillrect(struct fb_info *info,
+				   const struct fb_fillrect *rect)
+{
+	struct hecubafb_par *par = info->par;
+
+	cfb_fillrect(info, rect);
+
+	hecubafb_dpy_update(par);
+}
+
+static void hecubafb_copyarea(struct fb_info *info,
+				   const struct fb_copyarea *area)
+{
+	struct hecubafb_par *par = info->par;
+
+	cfb_copyarea(info, area);
+
+	hecubafb_dpy_update(par);
+}
+
+static void hecubafb_imageblit(struct fb_info *info, 
+				const struct fb_image *image)
+{
+	struct hecubafb_par *par = info->par;
+
+	cfb_imageblit(info, image);
+
+	hecubafb_dpy_update(par);
+}
+
+/*
+ * this is the slow path from userspace. they can seek and write to
+ * the fb. it's inefficient to do anything less than a full screen draw 
+ */
+static ssize_t hecubafb_write(struct file *file, const char __user *buf, 
+				size_t count, loff_t *ppos)
+{
+	struct inode *inode;
+	int fbidx;
+	struct fb_info *info;
+	unsigned long p;
+	int err=-EINVAL;
+	struct hecubafb_par *par;
+	unsigned int xres;
+	unsigned int fbmemlength;
+
+	p = *ppos;
+	inode = file->f_dentry->d_inode;
+	fbidx = iminor(inode);
+	info = registered_fb[fbidx];
+
+	if (!info || !info->screen_base)
+		return -ENODEV;
+
+	par = info->par;
+	xres = info->var.xres;
+	fbmemlength = (xres * info->var.yres)/8;
+
+	if (p > fbmemlength)
+		return -ENOSPC;
+
+	err = 0;
+	if ((count + p) > fbmemlength) {
+		count = fbmemlength - p;
+		err = -ENOSPC;
+	}
+
+	if (count) {
+		char *base_addr;
+
+		base_addr = info->screen_base;
+		count -= copy_from_user(base_addr + p, buf, count);
+		*ppos += count;
+		err = -EFAULT;
+	}
+
+	hecubafb_dpy_update(par);
+
+	if (count)
+		return count;
+
+	return err;
+}
+
+/* this is to find and return the vmalloc-ed fb pages */
+static struct page* hecubafb_vm_nopage(struct vm_area_struct *vma, 
+					unsigned long vaddr, int *type)
+{
+	unsigned long offset;
+	struct page *page;
+	struct fb_info *info = vma->vm_private_data;
+
+	offset = (vaddr - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
+	if (offset >= (DPY_W*DPY_H)/8)
+		return NOPAGE_SIGBUS;
+
+	page = vmalloc_to_page(info->screen_base + offset);
+	if (!page)
+		return NOPAGE_OOM;
+
+	get_page(page);
+	if (type)
+		*type = VM_FAULT_MINOR;
+	return page;
+}
+
+static struct vm_operations_struct hecubafb_vm_ops = {
+	.nopage   	= hecubafb_vm_nopage,
+	.page_mkwrite	= fb_deferred_io_mkwrite,
+};
+
+static int hecubafb_mmap(struct fb_info *info, struct vm_area_struct *vma)
+{
+	vma->vm_ops = &hecubafb_vm_ops;
+	vma->vm_flags |= ( VM_IO | VM_RESERVED | VM_DONTEXPAND );
+	vma->vm_private_data = info;
+	return 0;
+}
+
+static struct fb_ops hecubafb_ops = {
+	.owner		= THIS_MODULE,
+	.fb_write	= hecubafb_write,
+	.fb_fillrect	= hecubafb_fillrect,
+	.fb_copyarea	= hecubafb_copyarea,
+	.fb_imageblit	= hecubafb_imageblit,
+	.fb_mmap	= hecubafb_mmap,
+};
+
+static struct fb_deferred_io hecubafb_defio = {
+	.delay		= HZ,
+	.deferred_io	= hecubafb_dpy_deferred_io,
+};
+
+static int __devinit hecubafb_probe(struct platform_device *dev)
+{
+	struct fb_info *info;
+	int retval = -ENOMEM;
+	int videomemorysize;
+	unsigned char *videomemory;
+	struct hecubafb_par *par;
+
+	videomemorysize = (DPY_W*DPY_H)/8;
+
+	if (!(videomemory = vmalloc(videomemorysize)))
+		return retval;
+
+	memset(videomemory, 0, videomemorysize);
+
+	info = framebuffer_alloc(sizeof(struct hecubafb_par), &dev->dev);
+	if (!info)
+		goto err;
+
+	info->screen_base = (char __iomem *) videomemory;
+	info->fbops = &hecubafb_ops;
+
+	info->var = hecubafb_var;
+	info->fix = hecubafb_fix;
+	par = info->par;
+	par->info = info;
+
+	if (!dio_addr || !cio_addr || !c2io_addr) {
+		printk(KERN_WARNING "no IO addresses supplied\n");
+		goto err1;
+	}
+	par->dio_addr = dio_addr;
+	par->cio_addr = cio_addr;
+	par->c2io_addr = c2io_addr;
+	info->flags = FBINFO_FLAG_DEFAULT;
+
+	info->fbdefio = &hecubafb_defio;
+
+	retval = register_framebuffer(info);
+	if (retval < 0)
+		goto err1;
+	platform_set_drvdata(dev, info);
+
+	printk(KERN_INFO
+	       "fb%d: Hecuba frame buffer device, using %dK of video memory\n",
+	       info->node, videomemorysize >> 10);
+
+	/* this inits the dpy */
+	apollo_init_control(par);
+
+	apollo_send_command(par, APOLLO_INIT_DISPLAY);
+	apollo_send_data(par, 0x81);
+
+	/* have to wait while display resets */
+	udelay(1000);
+
+	/* if we were told to splash the screen, we just clear it */
+	if (!nosplash) {
+		apollo_send_command(par, APOLLO_ERASE_DISPLAY);
+		apollo_send_data(par, splashval);
+	}
+
+	return 0;
+err1:
+	framebuffer_release(info);
+err:
+	vfree(videomemory);
+	return retval;
+}
+
+static int __devexit hecubafb_remove(struct platform_device *dev)
+{
+	struct fb_info *info = platform_get_drvdata(dev);
+
+	if (info) {
+		unregister_framebuffer(info);
+		vfree(info->screen_base);
+		framebuffer_release(info);
+	}
+	return 0;
+}
+
+static struct platform_driver hecubafb_driver = {
+	.probe	= hecubafb_probe,
+	.remove = hecubafb_remove,
+	.driver	= {
+		.name	= "hecubafb",
+	},
+};
+
+static struct platform_device *hecubafb_device;
+
+static int __init hecubafb_init(void)
+{
+	int ret;
+
+	if (!hecubafb_enable) {
+		printk(KERN_ERR "Use hecubafb_enable to enable the device\n");
+		return -ENXIO;
+	}
+
+	ret = platform_driver_register(&hecubafb_driver);
+	if (!ret) {
+		hecubafb_device = platform_device_alloc("hecubafb", 0);
+		if (hecubafb_device) 
+			ret = platform_device_add(hecubafb_device);
+		else 
+			ret = -ENOMEM;
+
+		if (ret) {
+			platform_device_put(hecubafb_device);
+			platform_driver_unregister(&hecubafb_driver);
+		}
+	}
+	return ret;
+
+}
+
+static void __exit hecubafb_exit(void)
+{
+	platform_device_unregister(hecubafb_device);
+	platform_driver_unregister(&hecubafb_driver);
+}
+
+module_param(nosplash, uint, 0);
+MODULE_PARM_DESC(nosplash, "Disable doing the splash screen");
+module_param(hecubafb_enable, uint, 0);
+MODULE_PARM_DESC(hecubafb_enable, "Enable communication with Hecuba board");
+module_param(dio_addr, ulong, 0);
+MODULE_PARM_DESC(dio_addr, "IO address for data, eg: 0x480");
+module_param(cio_addr, ulong, 0);
+MODULE_PARM_DESC(cio_addr, "IO address for control, eg: 0x400");
+module_param(c2io_addr, ulong, 0);
+MODULE_PARM_DESC(c2io_addr, "IO address for secondary control, eg: 0x408");
+module_param(splashval, ulong, 0);
+MODULE_PARM_DESC(splashval, "Splash pattern: 0x00 is black, 0x01 is white");
+module_param(irq, uint, 0);
+MODULE_PARM_DESC(irq, "IRQ for the Hecuba board");
+
+module_init(hecubafb_init);
+module_exit(hecubafb_exit);
+
+MODULE_DESCRIPTION("fbdev driver for Hecuba board");
+MODULE_AUTHOR("Jaya Kumar");
+MODULE_LICENSE("GPL");
diff --git a/include/linux/fb.h b/include/linux/fb.h
index a78e256..88a6c53 100644
--- a/include/linux/fb.h
+++ b/include/linux/fb.h
@@ -559,6 +559,16 @@ struct fb_pixmap {
 	void (*readio) (struct fb_info *info, void *dst, void __iomem *src, unsigned int size);
 };
 
+#ifdef CONFIG_FB_DEFERRED_IO
+struct fb_deferred_io {
+	/* delay between mkwrite and deferred handler */
+	unsigned long delay;	
+	struct mutex lock; /* mutex that protects the page list */
+	struct list_head pagelist; /* list of touched pages */
+	/* callback */
+	void (*deferred_io)(struct fb_info *info, struct list_head *pagelist);
+};
+#endif
 
 /*
  * Frame buffer operations
@@ -779,6 +789,10 @@ struct fb_info {
 	/* Backlight level curve */
 	u8 bl_curve[FB_BACKLIGHT_LEVELS];
 #endif
+#ifdef CONFIG_FB_DEFERRED_IO
+	struct delayed_work deferred_work;
+	struct fb_deferred_io *fbdefio;
+#endif
 
 	struct fb_ops *fbops;
 	struct device *device;		/* This is the parent */
@@ -914,6 +928,17 @@ static inline void __fb_pad_aligned_buffer(u8 *dst, u32 d_pitch,
 	}
 }
 
+#ifdef CONFIG_FB_DEFERRED_IO
+/* drivers/video/fb_defio.c */
+extern void fb_deferred_io_init(struct fb_info *info);
+extern void fb_deferred_io_cleanup(struct fb_info *info);
+extern int fb_deferred_io_mkwrite(struct vm_area_struct *vma, 
+					struct page *page);
+#else
+#define fb_deferred_io_init(fb_info)	do { } while (0)
+#define fb_deferred_io_cleanup(fb_info)	do { } while (0)
+#endif
+
 /* drivers/video/fbsysfs.c */
 extern struct fb_info *framebuffer_alloc(size_t size, struct device *dev);
 extern void framebuffer_release(struct fb_info *info);
diff --git a/mm/rmap.c b/mm/rmap.c
index 669acb2..0fa0521 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -496,6 +496,7 @@ int page_mkclean(struct page *page)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(page_mkclean);
 
 /**
  * page_set_anon_rmap - setup new anonymous rmap

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
