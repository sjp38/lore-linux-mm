Date: Fri, 28 Oct 2005 14:42:35 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028184235.GC8514@ccure.user-mode-linux.org>
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org> <43624F82.6080003@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="WIyZ46R2i8wDzkSu"
Content-Disposition: inline
In-Reply-To: <43624F82.6080003@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Oct 28, 2005 at 09:19:14AM -0700, Badari Pulavarty wrote:
> My touch tests so far, doesn't really verify data after freeing. I was
> thinking about writing cases. If I can use UML to do it, please send it
> to me. I would rather test with real world case :)

Grab and unpack http://www.user-mode-linux.org/~jdike/truncate.tar.bz2

That will give you a "linux" directory.

Make sure that your /tmp is tmpfs with > 192M of space.

Run UML - from above the linux directory, this would be something like
	linux/2.6/linux-2.6.14-rc5/obj/linux con0=fd:0,fd:1 con1=none con=pts ssl=pts umid=debian mem=192M ubda=linux/debian_22 devfs=nomount

Log in, the root password is "root".

Unplug some memory -
	linux/uml_mconsole debian config mem=-10M

Go back to the UML and try do to something - ps, ls, anything.

It will be hung on handling an infinite page fault loop due to a whole lot
of pages having been zeroed all of a sudden.

This will happen even when you unplug 2 pages (mem=-8K).  Only one of them
will be madvised because the other is used to keep track of the madvised
pages.

I also included my patchset in there (linux/2.6/linux-2.6.14-rc5/patches) if
you want to build UML from source.  Due to my not refreshing the hotplug 
patch before making the tarball, it's not there.  So, I've attached it.

				Jeff

--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=hotplug-mem

Index: linux-2.6.14-rc5/arch/um/drivers/mconsole_kern.c
===================================================================
--- linux-2.6.14-rc5.orig/arch/um/drivers/mconsole_kern.c	2005-10-27 17:56:17.000000000 -0400
+++ linux-2.6.14-rc5/arch/um/drivers/mconsole_kern.c	2005-10-27 23:43:04.000000000 -0400
@@ -20,6 +20,8 @@
 #include "linux/namei.h"
 #include "linux/proc_fs.h"
 #include "linux/syscalls.h"
+#include "linux/list.h"
+#include "linux/mm.h"
 #include "asm/irq.h"
 #include "asm/uaccess.h"
 #include "user_util.h"
@@ -345,6 +347,140 @@ static struct mc_device *mconsole_find_d
 	return(NULL);
 }
 
+#define UNPLUGGED_PER_PAGE \
+	((PAGE_SIZE - sizeof(struct list_head)) / sizeof(unsigned long))
+
+struct unplugged_pages {
+	struct list_head list;
+	void *pages[UNPLUGGED_PER_PAGE];
+};
+
+static unsigned long long unplugged_pages_count = 0;
+static struct list_head unplugged_pages = LIST_HEAD_INIT(unplugged_pages);
+static int unplug_index = UNPLUGGED_PER_PAGE;
+
+#define MADV_TRUNCATE	0x5		/* truncate range of pages */
+
+static int mem_config(char *str)
+{
+	unsigned long long diff;
+	int err = -EINVAL, i, add;
+	char *ret;
+
+	if(str[0] != '=')
+		goto out;
+
+	str++;
+	if(str[0] == '-')
+		add = 0;
+	else if(str[0] == '+'){
+		add = 1;
+	}
+	else goto out;
+	
+	str++;
+	diff = memparse(str, &ret);
+	if(*ret != '\0')
+		goto out;
+
+	diff /= PAGE_SIZE;
+
+	for(i = 0; i < diff; i++){
+		struct unplugged_pages *unplugged;
+		void *addr;
+
+		if(add){
+			if(list_empty(&unplugged_pages))
+				break;
+
+			unplugged = list_entry(unplugged_pages.next,
+					       struct unplugged_pages, list);
+			if(unplug_index > 0)
+				addr = unplugged->pages[--unplug_index];
+			else {
+				list_del(&unplugged->list);
+				addr = unplugged;
+				unplug_index = UNPLUGGED_PER_PAGE;
+			}
+				
+			free_page((unsigned long) addr);
+			unplugged_pages_count--;
+		}
+		else {
+			struct page *page;
+			
+			page = alloc_page(GFP_ATOMIC);
+			if(page == NULL)
+				break;
+
+			unplugged = page_address(page);
+			if(unplug_index == UNPLUGGED_PER_PAGE){
+				INIT_LIST_HEAD(&unplugged->list);
+				list_add(&unplugged->list, &unplugged_pages);
+				unplug_index = 0;
+			}
+			else {
+				struct list_head *entry = unplugged_pages.next;
+				addr = unplugged;
+
+				unplugged = list_entry(entry, 
+						       struct unplugged_pages,
+						       list);
+				unplugged->pages[unplug_index++] = addr;
+				err = madvise(addr, PAGE_SIZE, MADV_TRUNCATE);
+				if(err)
+					printk("MADV_TRUNCATE failed\n");
+			}
+
+			unplugged_pages_count++;
+		}
+	}
+
+	err = 0;
+out:
+	return err;
+}
+
+static int mem_get_config(char *name, char *str, int size, char **error_out)
+{
+	char buf[sizeof("18446744073709551615\0")];
+	int len = 0;
+
+	sprintf(buf, "%ld", uml_physmem);
+	CONFIG_CHUNK(str, size, len, buf, 1);
+
+	return len;
+}
+
+static int mem_id(char **str, int *start_out, int *end_out)
+{
+	*start_out = 0;
+	*end_out = 0;
+
+	return 0;
+}
+
+static int mem_remove(int n)
+{
+	return -EBUSY;
+}
+
+static struct mc_device mem_mc = {
+	.name		= "mem",
+	.config		= mem_config,
+	.get_config	= mem_get_config,
+	.id		= mem_id,
+	.remove		= mem_remove,
+};
+
+static int mem_mc_init(void)
+{
+	mconsole_register_dev(&mem_mc);
+	return 0;
+}
+
+__initcall(mem_mc_init);
+
 #define CONFIG_BUF_SIZE 64
 
 static void mconsole_get_config(int (*get_config)(char *, char *, int, 

--WIyZ46R2i8wDzkSu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
