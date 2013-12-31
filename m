Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A70CC6B0031
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 04:14:46 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so12205985pdj.39
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 01:14:46 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id dv5si36168002pbb.103.2013.12.31.01.14.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Dec 2013 01:14:45 -0800 (PST)
Message-ID: <52C28AAA.5060707@huawei.com>
Date: Tue, 31 Dec 2013 17:13:14 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: add ulimit API for user
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, walken@google.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, wangnan0@huawei.com

Add ulimit API for users. When memory is not enough, 
user's app will receive a signal, and it can do something
in the handler.

e.g.
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
void handler(int sig)
{
char *b = malloc(1000000000);
memset(b, '\0', 1000000000);
printf("catch the signal by wwy\n");
exit(1);
}
int main ( int argc, char *argv[] )
{
struct rlimit r1 = { 3600000000, 3600000000};
setrlimit(RLIMIT_AS, &r1);
signal(47, &handler);
char * a = malloc(3600000000);
int fd=open("/home/wayne/qemu.tar.bz2", O_RDONLY);
char abc[2000000] = {'\0'};
mmap(NULL, 10000000, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd , 0);
sleep(100);
free(a);
while(1){
}
}

RTOS-x86_64 /tmp # ./a.out
catch the signal by wwy


Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
diff --git a/mm/Makefile b/mm/Makefile
index 9c60f76..a5dec90 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -18,6 +18,7 @@ obj-y += init-mm.o
 ifdef CONFIG_OOM_EXTEND
 obj-y += oom_extend.o pagecache_info.o
 endif
+obj-y += ulimit-init.o
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o

diff --git a/mm/mmap.c b/mm/mmap.c
index 4ff7f52..a10155f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2402,6 +2402,11 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
  * Return true if the calling process may expand its vm space by the passed
  * number of pages
  */
+
+#ifdef CONFIG_ULIMIT_VM_SIG
+unsigned long vm_expand_signal_enable = 0;
+EXPORT_SYMBOL(vm_expand_signal_enable);
+#endif
+
 int may_expand_vm(struct mm_struct *mm, unsigned long npages)
 {
 	unsigned long cur = mm->total_vm;	/* pages */
@@ -2410,7 +2415,9 @@ int may_expand_vm(struct mm_struct *mm, unsigned long npages)
 	lim = rlimit(RLIMIT_AS) >> PAGE_SHIFT;
 
 	if (cur + npages > lim){
-		send_sig(SIGRTMIN+15, current, 1);
+#ifdef	CONFIG_ULIMIT_VM_SIG
+		if (vm_expand_signal_enable){
+			send_sig(SIGRTMIN+15, current, 1);
+		}
+#endif
 		return 0;
 	}
 	return 1;

diff --git a/mm/ulimit-init.c b/mm/ulimit-init.c
new file mode 100644
index 0000000..d3b3a76
--- /dev/null
+++ b/mm/ulimit-init.c
@@ -0,0 +1,65 @@
+#include <linux/kobject.h>
+#include <linux/sysfs.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+
+static struct kobject *ulimit_kobj;
+extern unsigned long vm_expand_signal_enable;
+
+static ssize_t show(struct kobject *kobj, struct kobj_attribut *attr, char* buf)
+{
+	return snprintf(buf, 10, "%lu\n", vm_expand_signal_enable);
+}
+
+static ssize_t store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	unsigned long enable;
+	if (0 != strict_strtoul(buf, 10, &enable))
+		return -EINVAL;
+	if (0 != enable && 1 != enable){
+		return -EINVAL;
+	}
+
+	vm_expand_signal_enable = enable;
+	return count;
+}
+
+static struct kobj_attribute ulimit_vm_attribute =
+__ATTR(vm_expand_signal_enable, 0644, show, store);
+
+static struct attribute *attrs[] = {
+        &ulimit_vm_attribute.attr,
+        NULL,   /* need to NULL terminate the list of attributes */
+};
+
+static struct attribute_group attr_group = {
+        .attrs = attrs,
+};
+
+
+static int ulimit_obj_init(void)
+{
+	int retval;
+
+	ulimit_kobj = kobject_create_and_add("ulimit", mm_kobj);
+
+	if (!ulimit_kobj)
+                return -ENOMEM;
+
+	retval = sysfs_create_group(ulimit_kobj, &attr_group);
+
+	return retval;
+}
+
+static int ulimit_obj_exit(void)
+{
+	sysfs_remove_group(ulimit_kobj, &attr_group);
+	kobject_put(ulimit_kobj);
+	return 0;
+}
+
+module_init(ulimit_obj_init);
+module_exit(ulimit_obj_exit);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Wayne");

diff --git a/mm/Kconfig b/mm/Kconfig
index ef891af..dc9c881 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -295,3 +295,6 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+config ULIMIT_VM_SIG
+	bool "vm expand send SIG 47"

diff --git a/mm/Makefile b/mm/Makefile
index a5dec90..5c4d70f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -18,8 +18,9 @@ obj-y += init-mm.o
 ifdef CONFIG_OOM_EXTEND
 obj-y += oom_extend.o pagecache_info.o
 endif
+ifdef CONFIG_ULIMIT_VM_SIG
 obj-y += ulimit-init.o
-
+endif
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
