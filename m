Date: Thu, 4 Sep 2003 12:21:02 -0700
From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ikconfig cleanup
Message-Id: <20030904122102.7ff66f44.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, "Randy.Dunlap" <rddunlap@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This applies after the ikconfig patch to gzip the config.

Simplify and cleanup the code:
	- use single interface to seq_file where possible
	- don't need to do as much of the /proc interface, only read
	- use copy_to_user to avoid char at a time copy
	- remove unneccesary globals
	- use const char[] rather than const char * where possible.

Didn't change the version since interface doesn't change.

diff -Nru a/kernel/configs.c b/kernel/configs.c
--- a/kernel/configs.c	Thu Sep  4 11:59:39 2003
+++ b/kernel/configs.c	Thu Sep  4 11:59:39 2003
@@ -27,6 +27,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/init.h>
 #include <linux/compile.h>
 #include <linux/version.h>
@@ -46,112 +47,91 @@
 /**************************************************/
 /* globals and useful constants                   */
 
-static char *IKCONFIG_VERSION = "0.6";
-
-static struct proc_dir_entry *current_config, *build_info;
-
-static int
-ikconfig_permission_current(struct inode *inode, int op, struct nameidata *nd)
-{
-	/* anyone can read the device, no one can write to it */
-	return (op == MAY_READ) ? 0 : -EACCES;
-}
+static const char IKCONFIG_VERSION[] = "0.6";
 
 static ssize_t
-ikconfig_read_current(struct file *file, char *buf,
-			 size_t len, loff_t * offset)
-{
-	int i, limit;
-	int cnt;
-
-	limit = (kernel_config_data_size > len) ? len : kernel_config_data_size;
-	for (i = file->f_pos, cnt = 0;
-	     i < kernel_config_data_size && cnt < limit; i++, cnt++) {
-		if (put_user(kernel_config_data[i], buf + cnt))
-			return -EFAULT;
-	}
-	file->f_pos = i;
-	return cnt;
-}
-
-static int
-ikconfig_open_current(struct inode *inode, struct file *file)
+ikconfig_read_current(struct file *file, char __user *buf,
+		      size_t len, loff_t * offset)
 {
-	if (file->f_mode & FMODE_READ) {
-		inode->i_size = kernel_config_data_size;
-		file->f_pos = 0;
-	}
-	return 0;
-}
+	loff_t pos = *offset;
+	ssize_t count;
+	
+	if (pos >= kernel_config_data_size)
+		return 0;
+
+	count = min(len, (size_t)(kernel_config_data_size - pos));
+	if(copy_to_user(buf, kernel_config_data + pos, count))
+		return -EFAULT;
 
-static int
-ikconfig_close_current(struct inode *inode, struct file *file)
-{
-	return 0;
+	*offset += count;
+	return count;
 }
 
 static struct file_operations ikconfig_file_ops = {
+	.owner = THIS_MODULE,
 	.read = ikconfig_read_current,
-	.open = ikconfig_open_current,
-	.release = ikconfig_close_current,
 };
 
-static struct inode_operations ikconfig_inode_ops = {
-	.permission = ikconfig_permission_current,
-};
 
 /***************************************************/
-/* proc_read_build_info: let people read the info  */
+/* build_info_show: let people read the info       */
 /* we have on the tools used to build this kernel  */
 
-static int
-proc_read_build_info(char *page, char **start,
-		     off_t off, int count, int *eof, void *data)
+static int build_info_show(struct seq_file *seq, void *v)
+{
+	seq_printf(seq, 
+		   "Kernel:    %s\nCompiler:  %s\nVersion_in_Makefile: %s\n",
+		   ikconfig_build_info, LINUX_COMPILER, UTS_RELEASE);
+	return 0;
+}
+
+static int build_info_open(struct inode *inode, struct file *file)
 {
-	*eof = 1;
-	return sprintf(page,
-			"Kernel:    %s\nCompiler:  %s\nVersion_in_Makefile: %s\n",
-			ikconfig_build_info, LINUX_COMPILER, UTS_RELEASE);
+	return single_open(file, build_info_show, PDE(inode)->data);
 }
+	
+static struct file_operations build_info_file_ops = {
+	.owner = THIS_MODULE,
+	.open  = build_info_open,
+	.read  = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};	
 
 /***************************************************/
 /* ikconfig_init: start up everything we need to */
 
 static int __init ikconfig_init(void)
 {
-	int result = 0;
+	struct proc_dir_entry *entry;
 
 	printk(KERN_INFO "ikconfig %s with /proc/config*\n",
 	       IKCONFIG_VERSION);
 
 	/* create the current config file */
-	current_config = create_proc_entry("config.gz", S_IFREG | S_IRUGO,
-					   &proc_root);
-	if (current_config == NULL) {
-		result = -ENOMEM;
+	entry = create_proc_entry("config.gz", S_IFREG | S_IRUGO,
+				  &proc_root);
+	if (!entry)
 		goto leave;
-	}
-	current_config->proc_iops = &ikconfig_inode_ops;
-	current_config->proc_fops = &ikconfig_file_ops;
-	current_config->owner = THIS_MODULE;
-	current_config->size = kernel_config_data_size;
+
+	entry->proc_fops = &ikconfig_file_ops;
+	entry->size = kernel_config_data_size;
 
 	/* create the "build_info" file */
-	build_info = create_proc_read_entry("config_build_info", 0444, &proc_root,
-					    proc_read_build_info, NULL);
-	if (build_info == NULL) {
-		result = -ENOMEM;
+	entry = create_proc_entry("config_build_info", 
+				  S_IFREG | S_IRUGO, &proc_root);
+	if (!entry)
 		goto leave_gz;
-	}
-	build_info->owner = THIS_MODULE;
-	goto leave;
+	entry->proc_fops = &build_info_file_ops;
+
+	return 0;
 
 leave_gz:
 	/* remove the file from proc */
 	remove_proc_entry("config.gz", &proc_root);
 
 leave:
-	return result;
+	return -ENOMEM;
 }
 
 /***************************************************/
diff -Nru a/scripts/bin2c.c b/scripts/bin2c.c
--- a/scripts/bin2c.c	Thu Sep  4 11:59:39 2003
+++ b/scripts/bin2c.c	Thu Sep  4 11:59:39 2003
@@ -5,7 +5,7 @@
 	int ch, total=0;
 
 	if (argc > 1)
-		printf("const char *%s %s=\n",
+		printf("const char %s[] %s=\n",
 			argv[1], argc > 2 ? argv[2] : "");
 
 	do {
diff -Nru a/scripts/mkconfigs b/scripts/mkconfigs
--- a/scripts/mkconfigs	Thu Sep  4 11:59:39 2003
+++ b/scripts/mkconfigs	Thu Sep  4 11:59:39 2003
@@ -67,12 +67,12 @@
  */"
 
 echo "#ifdef CONFIG_IKCONFIG_PROC"
-echo "static char *ikconfig_build_info ="
+echo "static char const ikconfig_build_info[] ="
 echo "    \"`uname -s` `uname -r` `uname -v` `uname -m`\";"
 echo "#endif"
 echo
 kernel_version $makefile
-echo "static char *ikconfig_config __initdata __attribute__((unused)) = "
+echo "static char const ikconfig_config[] __attribute__((unused)) = "
 echo "\"CONFIG_BEGIN=n\\n\\"
 echo "`cat $config | sed 's/\"/\\\\\"/g' | grep "^#\? \?CONFIG_" | awk '{ print $0 "\\\\n\\\\" }' `"
 echo "CONFIG_END=n\\n\";"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
