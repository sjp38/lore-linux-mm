Received: by ro-out-1112.google.com with SMTP id p7so1352489roc
        for <linux-mm@kvack.org>; Sat, 03 Nov 2007 14:24:11 -0700 (PDT)
From: Jaya Kumar <jayakumar.lkml@gmail.com>
Date: Sat, 03 Nov 2007 17:24:46 -0400
Message-Id: <20071103212446.23631.71478.sendpatchset@apodmy1.cis>
Subject: [RFC 1/1 2.6.22.10] fbdev: defio and Metronomefb
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fbdev-devel@lists.sourceforge.net
Cc: Jaya Kumar <jayakumar.lkml@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Tony, Peter, Hugh, fbdev, mm, lkml,

Appended is my attempt at fixing up the problems identified in defio and
adding a driver, metronomefb that supports Xfbdev with X11 apps on a new
E-Ink controller. 

I would be grateful for a review of the defio changes.

The patch is against 2.6.22.10 since that's the kernel that I've managed to
get running on this board. I will update once I've gotten something more
recent running. I ran xeyes, xclock and nothing panic-ed.

The metronomefb code is still early. I intend to do the following:
- fix xfbdev/metronomefb grayscale handling
- switch to using gpio interrupt for rdy
- support other resolutions for alternative display panels
- expose led and panel border selection through led api
- explore bitmap for page list to optimize and avoid duplicate page copies
and maybe (depending on how the xfbdev issues go)
- change from defio on vm fbmem to defio direct on metromem img

I'm pausing here to see if things are okay so far. I would welcome any
feedback.

Thanks,
jaya

ps: if anyone is curious, here's how the driver and E-Ink display look during
use. http://www.youtube.com/watch?v=Or3R3Q8oyuE [ Apologies for Flash ]

Signed-off-by: Jaya Kumar <jayakumar.lkml@gmail.com>

---

 Kconfig       |   14 
 Makefile      |    1 
 fb_defio.c    |   22 +
 metronomefb.c |  974 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 1009 insertions(+), 2 deletions(-)


diff -uprN -X linux-2.6.22.10-vanilla/Documentation/dontdiff linux-2.6.22.10-vanilla/drivers/video/fb_defio.c linux-2.6.22.10/drivers/video/fb_defio.c
--- linux-2.6.22.10-vanilla/drivers/video/fb_defio.c	2007-10-10 13:50:35.000000000 -0400
+++ linux-2.6.22.10/drivers/video/fb_defio.c	2007-11-03 16:05:01.000000000 -0400
@@ -4,7 +4,7 @@
  *  Copyright (C) 2006 Jaya Kumar
  *
  * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file COPYING in the main directory of this archive
+ * License. See the file COPYING in the main directory of this archive
  * for more details.
  */
 
@@ -32,7 +32,7 @@ static struct page* fb_deferred_io_nopag
 	unsigned long offset;
 	struct page *page;
 	struct fb_info *info = vma->vm_private_data;
-	/* info->screen_base is in System RAM */
+	/* info->screen_base is virtual memory */
 	void *screen_base = (void __force *) info->screen_base;
 
 	offset = (vaddr - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
@@ -44,6 +44,15 @@ static struct page* fb_deferred_io_nopag
 		return NOPAGE_OOM;
 
 	get_page(page);
+
+	if (vma->vm_file)
+		page->mapping = vma->vm_file->f_mapping;
+	else
+		printk(KERN_ERR "no mapping available\n");
+
+	BUG_ON(!page->mapping);
+	page->index = ((vaddr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+
 	if (type)
 		*type = VM_FAULT_MINOR;
 	return page;
@@ -140,11 +149,20 @@ EXPORT_SYMBOL_GPL(fb_deferred_io_init);
 
 void fb_deferred_io_cleanup(struct fb_info *info)
 {
+	void *screen_base = (void __force *) info->screen_base;
 	struct fb_deferred_io *fbdefio = info->fbdefio;
+	struct page *page;
+	int i;
 
 	BUG_ON(!fbdefio);
 	cancel_delayed_work(&info->deferred_work);
 	flush_scheduled_work();
+
+	/* clear out the mapping that we setup */
+	for (i = 0 ; i < info->fix.smem_len; i += PAGE_SIZE) {
+		page = vmalloc_to_page(screen_base + i);
+		page->mapping = NULL;
+	}
 }
 EXPORT_SYMBOL_GPL(fb_deferred_io_cleanup);
 
diff -uprN -X linux-2.6.22.10-vanilla/Documentation/dontdiff linux-2.6.22.10-vanilla/drivers/video/Kconfig linux-2.6.22.10/drivers/video/Kconfig
--- linux-2.6.22.10-vanilla/drivers/video/Kconfig	2007-11-03 15:16:58.000000000 -0400
+++ linux-2.6.22.10/drivers/video/Kconfig	2007-11-03 15:24:58.000000000 -0400
@@ -1829,6 +1829,20 @@ config FB_XILINX
 	  framebuffer. ML300 carries a 640*480 LCD display on the board,
 	  ML403 uses a standard DB15 VGA connector.
 
+config FB_METRONOME
+       tristate "Metronome display controller support"
+       depends on FB && ARCH_PXA && MMU
+       select FB_SYS_FILLRECT
+       select FB_SYS_COPYAREA
+       select FB_SYS_IMAGEBLIT
+       select FB_SYS_FOPS
+       select FB_DEFERRED_IO
+       help
+         This enables support for the Metronome display controller. Tested
+         with an E-Ink 800x600 display and Gumstix Connex through an AMLCD 
+         interface. Please read <file:Documentation/fb/metronomefb.txt> 
+         for more information.
+
 config FB_VIRTUAL
 	tristate "Virtual Frame Buffer support (ONLY FOR TESTING!)"
 	depends on FB
diff -uprN -X linux-2.6.22.10-vanilla/Documentation/dontdiff linux-2.6.22.10-vanilla/drivers/video/Makefile linux-2.6.22.10/drivers/video/Makefile
--- linux-2.6.22.10-vanilla/drivers/video/Makefile	2007-10-10 13:50:35.000000000 -0400
+++ linux-2.6.22.10/drivers/video/Makefile	2007-10-27 14:03:33.000000000 -0400
@@ -113,6 +113,7 @@ obj-$(CONFIG_FB_IBM_GXT4500)	  += gxt450
 obj-$(CONFIG_FB_PS3)		  += ps3fb.o
 obj-$(CONFIG_FB_SM501)            += sm501fb.o
 obj-$(CONFIG_FB_XILINX)           += xilinxfb.o
+obj-$(CONFIG_FB_METRONOME)        += metronomefb.o
 
 # Platform or fallback drivers go here
 obj-$(CONFIG_FB_VESA)             += vesafb.o
diff -uprN -X linux-2.6.22.10-vanilla/Documentation/dontdiff linux-2.6.22.10-vanilla/drivers/video/metronomefb.c linux-2.6.22.10/drivers/video/metronomefb.c
--- linux-2.6.22.10-vanilla/drivers/video/metronomefb.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.22.10/drivers/video/metronomefb.c	2007-11-03 15:57:57.000000000 -0400
@@ -0,0 +1,974 @@
+/*
+ * linux/drivers/video/metronomefb.c -- FB driver for Metronome controller
+ *
+ * Copyright (C) 2007, Jaya Kumar
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License. See the file COPYING in the main directory of this archive for
+ * more details.
+ *
+ * Layout is based on skeletonfb.c by James Simmons and Geert Uytterhoeven.
+ *
+ * This work was made possible by help and equipment support from E-Ink
+ * Corporation. http://support.eink.com/community
+ *
+ * This driver is written to be used with the Metronome display controller.
+ * It was tested with an E-Ink 800x600 Vizplex EPD on a Gumstix Connex board
+ * using the Lyre interface board.
+ *
+ * General notes:
+ * - User must set metronomefb_enable=1 to enable it.
+ * - See Documentation/fb/metronomefb.txt for how metronome works.
+ */
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
+#include <linux/firmware.h>
+#include <linux/dma-mapping.h>
+#include <linux/uaccess.h>
+
+#include <asm/arch/pxa-regs.h>
+
+#define DEBUG 1
+#ifdef DEBUG
+#define DPRINTK(f, a...) printk(KERN_DEBUG "%s: " f, __FUNCTION__ , ## a)
+#else
+#define DPRINTK(f, a...)
+#endif
+
+
+/* Display specific information */
+#define DPY_W 832
+#define DPY_H 622
+
+struct metromem_desc {
+	u32 mFDADR0;
+	u32 mFSADR0;
+	u32 mFIDR0;
+	u32 mLDCMD0;
+};
+
+struct metromem_cmd {
+	u16 opcode;
+	u16 args[((64-2)/2)];
+	u16 csum;
+};
+
+struct metronomefb_par {
+	unsigned char *metromem;
+	struct metromem_desc *metromem_desc;
+	struct metromem_cmd *metromem_cmd;
+	unsigned char *metromem_wfm;
+	unsigned char *metromem_img;
+	int metromemsize;
+	dma_addr_t metromem_dma;
+	dma_addr_t metromem_desc_dma;
+	struct fb_info *info;
+	unsigned int irq;
+	wait_queue_head_t waitq;
+	u8 frame_count;
+};
+
+/* frame differs from image. frame includes non-visible pixels */
+struct epd_frame {
+	int fw; /* frame width */
+	int fh; /* frame height */
+};
+
+static struct epd_frame epd_frame_table[] __devinitdata = {
+	{
+	.fw = 832,
+	.fh = 622
+	},
+};
+
+static struct fb_fix_screeninfo metronomefb_fix __devinitdata = {
+	.id =		"metronomefb",
+	.type =		FB_TYPE_PACKED_PIXELS,
+	.visual =	FB_VISUAL_STATIC_PSEUDOCOLOR,
+//	.visual =	FB_VISUAL_MONO01,
+	.xpanstep =	0,
+	.ypanstep =	0,
+	.ywrapstep =	0,
+	.line_length =	DPY_W,
+	.accel =	FB_ACCEL_NONE,
+};
+
+static struct fb_var_screeninfo metronomefb_var __devinitdata = {
+	.xres		= DPY_W,
+	.yres		= DPY_H,
+	.xres_virtual	= DPY_W,
+	.yres_virtual	= DPY_H,
+	.bits_per_pixel	= 8,
+	.grayscale	= 1,
+	.nonstd		= 1,
+	.red =		{ 0, 8, 0 },
+	.green =	{ 0, 8, 0 },
+	.blue =		{ 0, 8, 0 },
+	.transp =	{ 0, 0, 0 },
+};
+
+static unsigned int metronomefb_enable;
+static unsigned int irq;
+
+struct waveform_hdr {
+	u8 stuff[32];
+
+	u8 wmta[3];
+	u8 fvsn;
+
+	u8 luts;
+	u8 mc;
+	u8 trc;
+	u8 stuff3;
+
+	u8 endb;
+	u8 swtb;
+	u8 stuff2a[2];
+
+	u8 stuff2b[3];
+	u8 wfm_cs;
+} __attribute__ ((packed));
+
+/* main metronomefb functions */
+u8 calc_cksum(int start, int end, u8 *mem)
+{
+	u8 tmp = 0;
+	int i;
+
+	for (i = start; i < end; i++) {
+		tmp += mem[i];
+	}
+	return tmp;
+}
+
+u16 calc_img_cksum(u16 *start, int length)
+{
+	u16 tmp = 0;
+
+	while (length--) {
+		tmp += *start++;
+	}
+
+	return tmp;
+}
+
+int load_waveform(u8 *mem, u8 *metromem, int m, int t, u8 *frame_count)
+{
+	int tta;
+	int wmta;
+	int trn = 0;
+	int i;
+	unsigned char v;
+	u8 cksum;
+	int cksum_idx;
+	int wfm_idx, owfm_idx;
+	int mem_idx = 0;
+	struct waveform_hdr *wfm_hdr;
+
+	wfm_hdr = (struct waveform_hdr *) mem;
+
+	if (wfm_hdr->fvsn != 1) {
+		printk(KERN_ERR "Error: bad fvsn %x\n", wfm_hdr->fvsn);
+		return -EINVAL;
+	}
+	if (wfm_hdr->luts != 0) {
+		printk(KERN_ERR "Error: bad luts %x\n", wfm_hdr->luts);
+		return -EINVAL;
+	}
+	cksum = calc_cksum(32, 47, mem);
+	if (cksum != wfm_hdr->wfm_cs) {
+		printk(KERN_ERR "Error: bad cksum %x != %x\n", cksum,
+					wfm_hdr->wfm_cs);
+		return -EINVAL;
+	}
+	wfm_hdr->mc += 1;
+	wfm_hdr->trc += 1;
+	for (i = 0; i < 5; i++) {
+		if (*(wfm_hdr->stuff2a + i) != 0) {
+			printk(KERN_ERR "Error: unexpected value in padding\n");
+			return -EINVAL;
+		}
+	}
+
+	/* calculating trn. trn is something used to index into
+	the waveform. presumably selecting the right one for the
+	desired temperature. it works out the offset of the first
+	v that exceeds the specified temperature */
+	for (i = sizeof(*wfm_hdr); i <= sizeof(*wfm_hdr) + wfm_hdr->trc; i++) {
+		if (mem[i] > t) {
+			trn = i - sizeof(*wfm_hdr) - 1;
+			break;
+		}
+	}
+
+	/* check temperature range table checksum */
+	cksum_idx = sizeof(*wfm_hdr) + wfm_hdr->trc + 1;
+	cksum = calc_cksum(sizeof(*wfm_hdr), cksum_idx, mem);
+	if (cksum != mem[cksum_idx]) {
+		printk(KERN_ERR "Error: bad temperature range table cksum"
+				" %x != %x\n", cksum, mem[cksum_idx]);
+		return -EINVAL;
+	}
+
+	/* check waveform mode table address checksum */
+	wmta = *((int *) wfm_hdr->wmta) & 0x00FFFFFF;
+	cksum_idx = wmta + m*4 + 3;
+	cksum = calc_cksum(cksum_idx - 3, cksum_idx, mem);
+	if (cksum != mem[cksum_idx]) {
+		printk(KERN_ERR "Error: bad mode table address cksum"
+				" %x != %x\n", cksum, mem[cksum_idx]);
+		return -EINVAL;
+	}
+
+	/* check waveform temperature table address checksum */
+	tta = *((int *) (mem + wmta + m*4)) & 0x00FFFFFF;
+	cksum_idx = tta + trn*4 + 3;
+	cksum = calc_cksum(cksum_idx - 3, cksum_idx, mem);
+	if (cksum != mem[cksum_idx]) {
+		printk(KERN_ERR "Error: bad temperature table address cksum"
+			" %x != %x\n", cksum, mem[cksum_idx]);
+		return -EINVAL;
+	}
+
+	/* here we do the real work of putting the waveform into the
+	metromem buffer. this does runlength decoding of the waveform */
+	owfm_idx = wfm_idx = *((int *) (mem + tta + trn*4)) & 0x00FFFFFF;
+	while (1) {
+		unsigned char rl;
+		v = mem[wfm_idx++];
+		if (v == wfm_hdr->swtb) {
+			while ((v = mem[wfm_idx++]) != wfm_hdr->swtb) {
+				metromem[mem_idx++] = v;
+			}
+			continue;
+		}
+		if (v == wfm_hdr->endb) {
+			break;
+		}
+		rl = mem[wfm_idx++];
+		for (i = 0; i <= rl; i++) {
+			metromem[mem_idx++] = v;
+		}
+	}
+
+	cksum_idx = wfm_idx;
+	cksum = calc_cksum(owfm_idx, cksum_idx, mem);
+	if (cksum != mem[cksum_idx]) {
+		printk(KERN_ERR "Error: bad waveform data cksum"
+				" %x != %x\n", cksum, mem[cksum_idx]);
+		return -EINVAL;
+	}
+	*frame_count = (mem_idx/64);
+
+	return 0;
+}
+
+/* register offsets for gpio control */
+#define LED_GPIO_PIN 51
+#define STDBY_GPIO_PIN 48
+#define RST_GPIO_PIN 49
+#define RDY_GPIO_PIN 32
+#define ERR_GPIO_PIN 17
+#define PCBPWR_GPIO_PIN 16
+
+#define AF_SEL_GPIO_N 0x3
+#define GAFR0_U_OFFSET(pin) ((pin - 16) * 2)
+#define GAFR1_L_OFFSET(pin) ((pin - 32) * 2)
+#define GAFR1_U_OFFSET(pin) ((pin - 48) * 2)
+#define GPDR1_OFFSET(pin) (pin - 32)
+#define GPCR1_OFFSET(pin) (pin - 32)
+#define GPSR1_OFFSET(pin) (pin - 32)
+#define GPCR0_OFFSET(pin) (pin)
+#define GPSR0_OFFSET(pin) (pin)
+
+static void metronome_set_gpio_output(int pin, int val)
+{
+	u8 index;
+
+	index = pin >> 4;
+
+	switch (index) {
+	case 1:
+		if (val)
+			GPSR0 |= (1 << GPSR0_OFFSET(pin));
+		else
+			GPCR0 |= (1 << GPCR0_OFFSET(pin));
+		break;
+	case 2:
+		break;
+	case 3:
+		if (val)
+			GPSR1 |= (1 << GPSR1_OFFSET(pin));
+		else
+			GPCR1 |= (1 << GPCR1_OFFSET(pin));
+		break;
+	default:
+		printk(KERN_ERR "unimplemented\n");
+	}
+}
+
+static void __devinit metronome_init_gpio_pin(int pin, int dir)
+{
+	u8 index;
+	/* dir 0 is output, 1 is input
+	- do 2 things here:
+	- set gpio alternate function to standard gpio
+	- set gpio direction to input or output  */
+
+	index = pin >> 4;
+	switch (index) {
+	case 1:
+		GAFR0_U &= ~(AF_SEL_GPIO_N << GAFR0_U_OFFSET(pin));
+
+		if (dir)
+			GPDR0 &= ~(1 << pin);
+		else
+			GPDR0 |= (1 << pin);
+		break;
+	case 2:
+		GAFR1_L &= ~(AF_SEL_GPIO_N << GAFR1_L_OFFSET(pin));
+
+		if (dir)
+			GPDR1 &= ~(1 << GPDR1_OFFSET(pin));
+		else
+			GPDR1 |= (1 << GPDR1_OFFSET(pin));
+		break;
+	case 3:
+		GAFR1_U &= ~(AF_SEL_GPIO_N << GAFR1_U_OFFSET(pin));
+
+		if (dir)
+			GPDR1 &= ~(1 << GPDR1_OFFSET(pin));
+		else
+			GPDR1 |= (1 << GPDR1_OFFSET(pin));
+		break;
+	default:
+		printk(KERN_ERR "unimplemented\n");
+	}
+}
+
+static void __devinit metronome_init_gpio_regs(void)
+{
+	metronome_init_gpio_pin(LED_GPIO_PIN, 0);
+	metronome_set_gpio_output(LED_GPIO_PIN, 0);
+
+	metronome_init_gpio_pin(STDBY_GPIO_PIN, 0);
+	metronome_set_gpio_output(STDBY_GPIO_PIN, 0);
+
+	metronome_init_gpio_pin(RST_GPIO_PIN, 0);
+	metronome_set_gpio_output(RST_GPIO_PIN, 0);
+
+	metronome_init_gpio_pin(RDY_GPIO_PIN, 1);
+
+	metronome_init_gpio_pin(ERR_GPIO_PIN, 1);
+
+	metronome_init_gpio_pin(PCBPWR_GPIO_PIN, 0);
+	metronome_set_gpio_output(PCBPWR_GPIO_PIN, 0);
+}
+
+/* this technique copied from pxafb */
+static void metronome_disable_lcd_controller(struct metronomefb_par *par)
+{
+	DECLARE_WAITQUEUE(wait, current);
+
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	add_wait_queue(&par->waitq, &wait);
+
+	LCSR = 0xffffffff;	/* Clear LCD Status Register */
+	LCCR0 &= ~LCCR0_LDM;	/* Enable LCD Disable Done Interrupt */
+	LCCR0 |= LCCR0_DIS;	/* Disable LCD Controller */
+
+	schedule_timeout(200 * HZ / 1000);
+	remove_wait_queue(&par->waitq, &wait);
+}
+
+static void metronome_enable_lcd_controller(struct metronomefb_par *par)
+{
+	LCSR = 0xffffffff;
+	FDADR0 = par->metromem_desc_dma;
+	LCCR0 |= LCCR0_ENB;
+}
+
+static void __devinit metronome_init_lcdc_regs(struct metronomefb_par *par)
+{
+	/* here we do:
+	- disable the lcd controller
+	- setup lcd control registers
+	- setup dma descriptor
+	- reenable lcd controller
+	*/
+
+	// disable the lcd controller
+	pxa_set_cken(CKEN_LCD, 1);
+	metronome_disable_lcd_controller(par);
+
+	// setup lcd control registers
+	LCCR0 = LCCR0_LDM | LCCR0_SFM | LCCR0_IUM | LCCR0_EFM | LCCR0_PAS
+		| LCCR0_QDM | LCCR0_BM | LCCR0_OUM;
+
+	LCCR1 = ( epd_frame_table[0].fw/2 - 1 ) // pixels per line
+		| ( 27 << 10 ) // hsync pulse width - 1
+		| ( 33 << 16 ) // eol pixel count
+		| ( 33 << 24 ); // bol pixel count
+
+	LCCR2 = ( epd_frame_table[0].fh - 1 ) // lines per panel
+		| ( 24 << 10 ) // vsync pulse width - 1
+		| ( 2 << 16 ) // eof pixel count
+		| ( 0 << 24 ); // bof pixel count
+
+	LCCR3 = ( 2 ) // pixel clock divisor
+		| ( 24 << 8 ) // AC Bias pin freq
+		| LCCR3_16BPP // BPP
+		| LCCR3_PCP;  // PCP falling edge
+
+	// setup dma descriptor
+	par->metromem_desc->mFDADR0 = par->metromem_desc_dma;
+	par->metromem_desc->mFSADR0 = par->metromem_dma;
+	par->metromem_desc->mFIDR0 = 0;
+	par->metromem_desc->mLDCMD0 = epd_frame_table[0].fw
+					* epd_frame_table[0].fh;
+	// reenable lcd controller
+	metronome_enable_lcd_controller(par);
+}
+
+static int wait_for_ready(int timeout)
+{
+	do {
+		if (GPLR1 & 0x01)
+			return 0;
+		msleep(1);
+	} while (--timeout);
+
+	printk(KERN_ERR "Failure waiting for ready\n");
+	return -EIO;
+}
+
+static int metronome_display_cmd(struct metronomefb_par *par)
+{
+	int i;
+	u16 cs;
+	u16 opcode;
+	static u8 borderval;
+	u8 *ptr;
+
+	/* setup display command
+	we can't immediately set the opcode since the controller
+	will try parse the command before we've set it all up
+	so we just set cs here and set the opcode at the end */
+
+	ptr = par->metromem;
+#if 0
+	for (i=0;i<64;i++) {
+		printk("0x%x,",*(par->metromem_wfm + i));
+	}
+	printk("\nimage:\n");
+	for (i=0;i<64;i++) {
+		printk("0x%x,",*(par->metromem_img + i));
+	}
+	printk("\nline300:\n");
+	for (i=0;i<64;i++) {
+		printk("0x%x,",*(par->metromem_img + (DPY_W*DPY_H/2) + i));
+	}
+	printk("\n");
+#endif
+
+	if (par->metromem_cmd->opcode == 0xCC40)
+		opcode = cs = 0xCC41;
+	else
+		opcode = cs = 0xCC40;
+
+	// set the args ( 2 bytes ) for display
+	i = 0;
+	par->metromem_cmd->args[i] = 	1 << 3 // border update
+					| ((borderval++ % 4) & 0x0F) << 4
+					| (par->frame_count - 1) << 8;
+	cs += par->metromem_cmd->args[i++];
+
+	// the rest are 0
+	memset((u8 *) (par->metromem_cmd->args + i), 0, (32-i)*2);
+
+	par->metromem_cmd->csum = cs;
+	par->metromem_cmd->opcode = opcode; // display cmd
+	msleep(20);
+
+	i = wait_for_ready(1000);
+	return i;
+}
+
+static int __devinit metronome_powerup_cmd(struct metronomefb_par *par)
+{
+	int i;
+	u16 cs;
+
+	// setup power up command
+	par->metromem_cmd->opcode = 0x1234; // pwr up pseudo cmd
+	cs = par->metromem_cmd->opcode;
+
+	// set pwr1,2,3 to 1024
+	for (i = 0; i < 3; i++) {
+		par->metromem_cmd->args[i] = 1024;
+		cs += par->metromem_cmd->args[i];
+	}
+
+	// the rest are 0
+	memset((u8 *) (par->metromem_cmd->args + i), 0, (32-i)*2);
+
+	par->metromem_cmd->csum = cs;
+
+	msleep(1);
+	metronome_set_gpio_output(RST_GPIO_PIN, 1);
+
+	msleep(1);
+	metronome_set_gpio_output(STDBY_GPIO_PIN, 1);
+
+	i = wait_for_ready(1000);
+	return i;
+}
+
+static int __devinit metronome_config_cmd(struct metronomefb_par *par)
+{
+	int i;
+	u16 cs;
+
+	/* setup config command
+	we can't immediately set the opcode since the controller
+	will try parse the command before we've set it all up
+	so we just set cs here and set the opcode at the end */
+
+	cs = 0xCC10;
+
+	// set the 12 args ( 8 bytes ) for config. see spec for meanings
+	i = 0;
+	par->metromem_cmd->args[i] = 	15 // sdlew
+					| 2 << 8 // sdosz
+					| 0 << 11 // sdor
+					| 0 << 12 // sdces
+					| 0 << 15; // sdcer
+	cs += par->metromem_cmd->args[i++];
+
+	par->metromem_cmd->args[i] = 	42 // gdspl
+					| 1 << 8 // gdr1
+					| 1 << 9 // sdshr
+					| 0 << 15; // gdspp
+	cs += par->metromem_cmd->args[i++];
+
+	par->metromem_cmd->args[i] = 	18 // gdspw
+					| 0 << 15; // dispc
+	cs += par->metromem_cmd->args[i++];
+
+	par->metromem_cmd->args[i] = 	599 // vdlc
+					| 0 << 11 // dsi
+					| 0 << 12; // dsic
+	cs += par->metromem_cmd->args[i++];
+
+	// the rest are 0
+	memset((u8 *) (par->metromem_cmd->args + i), 0, (32-i)*2);
+
+	par->metromem_cmd->csum = cs;
+	par->metromem_cmd->opcode = 0xCC10; // config cmd
+
+	msleep(20);
+
+	i = wait_for_ready(1000);
+	return i;
+}
+
+static int __devinit metronome_init_cmd(struct metronomefb_par *par)
+{
+	int i;
+	u16 cs;
+
+	/* setup init command
+	we can't immediately set the opcode since the controller
+	will try parse the command before we've set it all up
+	so we just set cs here and set the opcode at the end */
+
+	cs = 0xCC20;
+
+	// set the args ( 2 bytes ) for init
+	i = 0;
+	par->metromem_cmd->args[i] = 	0;
+	cs += par->metromem_cmd->args[i++];
+
+	// the rest are 0
+	memset((u8 *) (par->metromem_cmd->args + i), 0, (32-i)*2);
+
+	par->metromem_cmd->csum = cs;
+	par->metromem_cmd->opcode = 0xCC20; // init cmd
+
+	msleep(20);
+
+	i = wait_for_ready(1000);
+	return i;
+}
+
+static int __devinit metronome_init_regs(struct metronomefb_par *par)
+{
+	int res;
+
+	metronome_init_gpio_regs();
+	metronome_init_lcdc_regs(par);
+
+	res = metronome_powerup_cmd(par);
+	if (res)
+		return res;
+
+	res = metronome_config_cmd(par);
+	if (res)
+		return res;
+
+	res = metronome_init_cmd(par);
+	if (res)
+		return res;
+
+	return res;
+}
+
+static void metronomefb_dpy_update(struct metronomefb_par *par)
+{
+//	int i;
+	u16 cksum;
+	unsigned char *buf = (unsigned char __force *)par->info->screen_base;
+
+	/* copy from vm to metromem */
+#if 0
+	for (i=0; i < DPY_H; i++) {
+		memcpy(par->metromem_img + (i*epd_frame_table[0].fw), buf, DPY_W);
+	}
+#else
+	memcpy(par->metromem_img, buf, DPY_W*DPY_H);
+#endif
+#if 0
+	for (i = 0; i < DPY_H*DPY_W; i++) {
+		*(par->metromem_img + i) = (buf[i] << 4) & 0xF0;
+	}
+#endif
+
+	cksum = calc_img_cksum((u16 *) par->metromem_img,
+				(epd_frame_table[0].fw * DPY_H)/2);
+	*((u16 *) (par->metromem_img) + 
+			(epd_frame_table[0].fw * DPY_H)/2) = cksum;
+	metronome_display_cmd(par);
+}
+
+static void metronomefb_dpy_update_page(struct metronomefb_par *par, int index)
+{
+	int i;
+	unsigned char *buf = (unsigned char __force *)par->info->screen_base;
+
+	/* swizzle from vm to metromem */
+	for (i = index; i < index + PAGE_SIZE; i++) {
+		*(par->metromem_img + i) = ((buf[i]) << 4) & 0xF0;
+	}
+}
+
+/* this is called back from the deferred io workqueue */
+static void metronomefb_dpy_deferred_io(struct fb_info *info,
+				struct list_head *pagelist)
+{
+	u16 cksum;
+	struct page *cur;
+	struct fb_deferred_io *fbdefio = info->fbdefio;
+	struct metronomefb_par *par = info->par;
+
+	/* walk the written page list and swizzle the data */
+	list_for_each_entry(cur, &fbdefio->pagelist, lru) {
+		metronomefb_dpy_update_page(par, (cur->index << PAGE_SHIFT));
+	}
+
+	cksum = calc_img_cksum((u16 *) par->metromem_img,
+				(epd_frame_table[0].fw * DPY_H)/2);
+	*((u16 *) (par->metromem_img) + (epd_frame_table[0].fw * DPY_H)/2)
+					= cksum;
+
+	metronome_display_cmd(par);
+}
+
+static void metronomefb_fillrect(struct fb_info *info,
+				   const struct fb_fillrect *rect)
+{
+	struct metronomefb_par *par = info->par;
+
+	cfb_fillrect(info, rect);
+	metronomefb_dpy_update(par);
+}
+
+static void metronomefb_copyarea(struct fb_info *info,
+				   const struct fb_copyarea *area)
+{
+	struct metronomefb_par *par = info->par;
+
+	cfb_copyarea(info, area);
+	metronomefb_dpy_update(par);
+}
+
+static void metronomefb_imageblit(struct fb_info *info,
+				const struct fb_image *image)
+{
+	struct metronomefb_par *par = info->par;
+
+	cfb_imageblit(info, image);
+	metronomefb_dpy_update(par);
+}
+
+/*
+ * this is the slow path from userspace. they can seek and write to
+ * the fb.
+ */
+static ssize_t metronomefb_write(struct fb_info *info, const char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	unsigned long p;
+	int err = -EINVAL;
+	struct metronomefb_par *par;
+	unsigned int xres;
+	unsigned int fbmemlength;
+
+	p = *ppos;
+	par = info->par;
+	xres = info->var.xres;
+	fbmemlength = (xres * info->var.yres);
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
+		base_addr = (char __force *)info->screen_base;
+		count -= copy_from_user(base_addr + p, buf, count);
+		*ppos += count;
+		err = -EFAULT;
+	}
+
+	metronomefb_dpy_update(par);
+
+	if (count)
+		return count;
+
+	return err;
+}
+
+static struct fb_ops metronomefb_ops = {
+	.owner		= THIS_MODULE,
+//	.fb_read        = fb_sys_read,
+	.fb_write	= metronomefb_write,
+	.fb_fillrect	= metronomefb_fillrect,
+	.fb_copyarea	= metronomefb_copyarea,
+	.fb_imageblit	= metronomefb_imageblit,
+};
+
+static struct fb_deferred_io metronomefb_defio = {
+	.delay		= HZ,
+	.deferred_io	= metronomefb_dpy_deferred_io,
+};
+
+static int __devinit metronomefb_probe(struct platform_device *dev)
+{
+	struct fb_info *info;
+	int retval = -ENOMEM;
+	int videomemorysize;
+	unsigned char *videomemory;
+	struct metronomefb_par *par;
+	const struct firmware *fw_entry;
+	int cmd_size, wfm_size, img_size, padding_size, totalsize;
+
+	/* we have two blocks of memory.
+	info->screen_base which is vm, and is the fb used by apps.
+	par->metromem which is physically contiguous memory and
+	contains the display controller commands, waveform,
+	processed image data and padding. this is the data pulled
+	by the pxa255's LCD controller and pushed to Metronome */
+
+	videomemorysize = (DPY_W*DPY_H);
+	videomemory = vmalloc(videomemorysize);
+	if (!videomemory)
+		return retval;
+
+	memset(videomemory, 0, videomemorysize);
+
+	info = framebuffer_alloc(sizeof(struct metronomefb_par), &dev->dev);
+	if (!info)
+		goto err;
+
+	info->screen_base = (char __iomem *) videomemory;
+	info->fbops = &metronomefb_ops;
+
+	info->var = metronomefb_var;
+	info->fix = metronomefb_fix;
+	info->fix.smem_len = videomemorysize;
+	par = info->par;
+	par->info = info;
+	init_waitqueue_head(&par->waitq);
+
+	/* the metromem buffer is divided as follows:
+	command | CRC | padding
+	16kb waveform data | CRC | padding
+	image data | CRC
+	and an extra 256 bytes for dma descriptors
+	eg: IW=832 IH=622 WS=128
+	*/
+
+	cmd_size = 1 * epd_frame_table[0].fw;
+	wfm_size = ( (16*1024 + 2 + epd_frame_table[0].fw - 1)
+			/ epd_frame_table[0].fw ) * epd_frame_table[0].fw;
+	img_size = epd_frame_table[0].fh * epd_frame_table[0].fw;
+	padding_size = 4 * epd_frame_table[0].fw;
+	totalsize = cmd_size + wfm_size + img_size + padding_size;
+	par->metromemsize = PAGE_ALIGN(totalsize + 256);
+	DPRINTK("desired memory size = %d\n", par->metromemsize);
+	dev->dev.coherent_dma_mask = 0xffffffffull;
+	par->metromem = dma_alloc_writecombine(&dev->dev, par->metromemsize,
+						&par->metromem_dma, GFP_KERNEL);
+	if (!par->metromem) {
+		goto err;
+	}
+
+	info->fix.smem_start = par->metromem_dma;
+	par->metromem_cmd = (struct metromem_cmd *) par->metromem;
+	par->metromem_wfm = par->metromem + cmd_size;
+	par->metromem_img = par->metromem + cmd_size + wfm_size;
+	DPRINTK("img offset=0x%x\n", cmd_size + wfm_size);
+	par->metromem_desc = (struct metromem_desc *) (par->metromem + cmd_size
+					+ wfm_size + img_size + padding_size);
+	par->metromem_desc_dma = par->metromem_dma + cmd_size + wfm_size
+				 + img_size + padding_size;
+
+	/* load the waveform in. assume mode 3, temp 31 for now */
+	/* 	a) request the waveform file from userspace
+		b) process waveform and decode into metromem */
+
+	retval = request_firmware(&fw_entry, "waveform.wbf", &dev->dev);
+	if (retval < 0) {
+		DPRINTK("couldn't get firmware\n");
+		goto err2;
+	}
+
+	retval = load_waveform((u8 *) fw_entry->data, par->metromem_wfm, 3, 31,
+				&par->frame_count);
+	if (retval < 0) {
+		goto err2;
+	}
+
+	release_firmware(fw_entry);
+
+	retval = metronome_init_regs(par);
+	if (retval < 0)
+		goto err2;
+
+	info->flags = FBINFO_FLAG_DEFAULT;
+
+	info->fbdefio = &metronomefb_defio;
+	fb_deferred_io_init(info);
+
+	if (fb_alloc_cmap(&info->cmap, 16, 0) < 0) {
+		printk(KERN_ERR "Fail to allocate colormap\n");
+		retval = -EFAULT;
+		goto err2;
+	}
+
+	retval = register_framebuffer(info);
+	if (retval < 0)
+		goto err1;
+	platform_set_drvdata(dev, info);
+
+	printk(KERN_INFO
+		"fb%d: Metronome frame buffer device, using %dK of video"
+		" memory\n", info->node, videomemorysize >> 10);
+
+	return 0;
+err1:
+	framebuffer_release(info);
+err2:
+	dma_free_writecombine(&dev->dev, par->metromemsize, par->metromem,
+				par->metromem_dma);
+err:
+	vfree(videomemory);
+	return retval;
+}
+
+static int __devexit metronomefb_remove(struct platform_device *dev)
+{
+	struct fb_info *info = platform_get_drvdata(dev);
+
+	if (info) {
+		struct metronomefb_par *par = info->par;
+		fb_deferred_io_cleanup(info);
+		dma_free_writecombine(&dev->dev, par->metromemsize,
+					par->metromem, par->metromem_dma);
+		fb_dealloc_cmap(&info->cmap);
+		unregister_framebuffer(info);
+		vfree((void __force *)info->screen_base);
+		framebuffer_release(info);
+	}
+	return 0;
+}
+
+static struct platform_driver metronomefb_driver = {
+	.probe	= metronomefb_probe,
+	.remove = metronomefb_remove,
+	.driver	= {
+		.name	= "metronomefb",
+	},
+};
+
+static struct platform_device *metronomefb_device;
+
+static int __init metronomefb_init(void)
+{
+	int ret;
+
+	if (!metronomefb_enable) {
+		printk(KERN_ERR
+			"Use metronomefb_enable to enable the device\n");
+		return -ENXIO;
+	}
+
+	ret = platform_driver_register(&metronomefb_driver);
+	if (!ret) {
+		metronomefb_device = platform_device_alloc("metronomefb", 0);
+		if (metronomefb_device)
+			ret = platform_device_add(metronomefb_device);
+		else
+			ret = -ENOMEM;
+
+		if (ret) {
+			platform_device_put(metronomefb_device);
+			platform_driver_unregister(&metronomefb_driver);
+		}
+	}
+	return ret;
+
+}
+
+static void __exit metronomefb_exit(void)
+{
+	platform_device_unregister(metronomefb_device);
+	platform_driver_unregister(&metronomefb_driver);
+}
+
+module_param(metronomefb_enable, uint, 0);
+MODULE_PARM_DESC(metronomefb_enable, "Enable communication with Metronome");
+
+module_init(metronomefb_init);
+module_exit(metronomefb_exit);
+
+MODULE_DESCRIPTION("fbdev driver for Metronome controller");
+MODULE_AUTHOR("Jaya Kumar");
+MODULE_LICENSE("GPL");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
