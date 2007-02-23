Date: Fri, 23 Feb 2007 18:22:37 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC 2.6.20 1/1] fbdev,mm: Deferred IO and hecubafb driver
Message-ID: <20070223092237.GA16889@linux-sh.org>
References: <20070223063228.GA9906@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070223063228.GA9906@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 23, 2007 at 07:32:28AM +0100, Jaya Kumar wrote:
> This is a first pass at abstracting deferred IO out from hecubafb and
> into fbdev as was discussed before: 
> http://marc.theaimsgroup.com/?l=linux-fbdev-devel&m=117187443327466&w=2
> 
> Please let me know your feedback and if it looks okay so far.
> 
How about this for an fsync()? I wonder if this will be sufficient for
msync() based flushing, or whether the ->sync VMA op is needed again..

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 drivers/video/fb_defio.c |   12 ++++++++++++
 drivers/video/fbmem.c    |    3 +++
 include/linux/fb.h       |    2 ++
 3 files changed, 17 insertions(+)

diff --git a/drivers/video/fb_defio.c b/drivers/video/fb_defio.c
index c3e57cc..8a66dc8 100644
--- a/drivers/video/fb_defio.c
+++ b/drivers/video/fb_defio.c
@@ -52,6 +52,18 @@ static void fb_deferred_io_work(struct work_struct *work)
 	mutex_unlock(&fbdefio->lock);
 }
 
+int fb_deferred_io_fsync(struct file *file, struct dentry *dentry, int datasync)
+{
+	struct fb_info *info = file->private_data;
+
+	/* Kill off the delayed work */
+	cancel_rearming_delayed_work(&info->deferred_work);
+
+	/* Run it immediately */
+	return schedule_delayed_work(&info->deferred_work, 0);
+}
+EXPORT_SYMBOL_GPL(fb_deferred_io_fsync);
+
 /* vm_ops->page_mkwrite handler */
 int fb_deferred_io_mkwrite(struct vm_area_struct *vma, 
 					struct page *page)
diff --git a/drivers/video/fbmem.c b/drivers/video/fbmem.c
index 863126a..69bbbe2 100644
--- a/drivers/video/fbmem.c
+++ b/drivers/video/fbmem.c
@@ -1266,6 +1266,9 @@ static const struct file_operations fb_fops = {
 #ifdef HAVE_ARCH_FB_UNMAPPED_AREA
 	.get_unmapped_area = get_fb_unmapped_area,
 #endif
+#ifdef CONFIG_FB_DEFERRED_IO
+	.fsync =	fb_deferred_io_fsync,
+#endif
 };
 
 struct class *fb_class;
diff --git a/include/linux/fb.h b/include/linux/fb.h
index af217dd..3f62652 100644
--- a/include/linux/fb.h
+++ b/include/linux/fb.h
@@ -933,6 +933,8 @@ extern void fb_deferred_io_init(struct fb_info *info);
 extern void fb_deferred_io_cleanup(struct fb_info *info);
 extern int fb_deferred_io_mkwrite(struct vm_area_struct *vma, 
 					struct page *page);
+extern int fb_deferred_io_fsync(struct file *file, struct dentry *dentry,
+				int datasync);
 #else
 #define fb_deferred_io_init(fb_info)	do { } while (0)
 #define fb_deferred_io_cleanup(fb_info)	do { } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
