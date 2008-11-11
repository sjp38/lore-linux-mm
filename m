From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 0/4] ksm - dynamic page sharing driver for linux
Date: Tue, 11 Nov 2008 15:21:37 +0200
Message-Id: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

KSM is a linux driver that allows dynamicly sharing identical memory pages
between one or more processes.

unlike tradtional page sharing that is made at the allocation of the
memory, ksm do it dynamicly after the memory was created.
Memory is periodically scanned; identical pages are identified and merged.
the sharing is unnoticeable by the process that use this memory.
(the shared pages are marked as readonly, and in case of write
do_wp_page() take care to create new copy of the page)

this driver is very useful for KVM as in cases of runing multiple guests
operation system of the same type, many pages are sharable.
this driver can be useful by OpenVZ as well.

KSM right now scan just memory that was registered to used by it, it
does not
scan the whole system memory (this can be changed, but the changes to
find
identical pages in normal linux system that doesnt run multiple guests)

KSM can run as kernel thread or as userspace application (or both (it is
allowed to run more than one scanner in a time)).

example for how to control the kernel thread:


ksmctl.c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include "ksm.h"

int main(int argc, char *argv[])
{
	int fd;
	int used = 0;
	int fd_start;
	struct ksm_kthread_info info;
	

	if (argc < 2) {
		fprintf(stderr, "usage: %s {start npages sleep | stop |
			info}\n", argv[0]);
		exit(1);
	}

	fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
	if (fd == -1) {
		fprintf(stderr, "could not open /dev/ksm\n");
		exit(1);
	}

	if (!strncmp(argv[1], "start", strlen(argv[1]))) {
		used = 1;
		if (argc < 5) {
			fprintf(stderr, "usage: %s start npages_to_scan",
				argv[0]);
			fprintf(stderr, "npages_max_merge sleep\n");
			exit(1);
		}
		info.pages_to_scan = atoi(argv[2]);
		info.max_pages_to_merge = atoi(argv[3]);
		info.sleep = atoi(argv[4]);
		info.running = 1;

		fd_start = ioctl(fd, KSM_START_STOP_KTHREAD, &info);
		if (fd_start == -1) {
			fprintf(stderr, "KSM_START_KTHREAD failed\n");
			exit(1);
		}
		printf("created scanner\n");
	}

	if (!strncmp(argv[1], "stop", strlen(argv[1]))) {
		used = 1;
		info.running = 0;
		fd_start = ioctl(fd, KSM_START_STOP_KTHREAD, &info);
		if (fd_start == -1) {
			fprintf(stderr, "KSM_START_STOP_KTHREAD failed\n");
			exit(1);
		}
		printf("stopped scanner\n");
	}

	if (!strncmp(argv[1], "info", strlen(argv[1]))) {
		used = 1;
		fd_start = ioctl(fd, KSM_GET_INFO_KTHREAD, &info);
		if (fd_start == -1) {
			fprintf(stderr, "KSM_GET_INFO_KTHREAD failed\n");
			exit(1);
		}
		printf("running %d, pages_to_scan %d pages_max_merge %d",
			info.running, info.pages_to_scan,
			info.max_pages_to_merge);
		printf("sleep_time %d\n", info.sleep);
	}

	if (!used)
		fprintf(stderr, "unknown command %s\n", argv[1]);

	return 0;
}


example of how to register qemu to ksm (or any userspace application)

diff --git a/qemu/vl.c b/qemu/vl.c
index 4721fdd..7785bf9 100644
--- a/qemu/vl.c
+++ b/qemu/vl.c
@@ -21,6 +21,7 @@
  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  * DEALINGS IN
  * THE SOFTWARE.
  */
+#include "ksm.h"
 #include "hw/hw.h"
 #include "hw/boards.h"
 #include "hw/usb.h"
@@ -5799,6 +5800,37 @@ static void termsig_setup(void)
 
 #endif
 
+int ksm_register_memory(void)
+{
+    int fd;
+    int ksm_fd;
+    int r = 1;
+    struct ksm_memory_region ksm_region;
+
+    fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
+    if (fd == -1)
+        goto out;
+
+    ksm_fd = ioctl(fd, KSM_CREATE_SHARED_MEMORY_AREA);
+    if (ksm_fd == -1)
+        goto out_free;
+
+    ksm_region.npages = phys_ram_size / TARGET_PAGE_SIZE;
+    ksm_region.addr = phys_ram_base;
+    r = ioctl(ksm_fd, KSM_REGISTER_MEMORY_REGION, &ksm_region);
+    if (r)
+        goto out_free1;
+
+    return r;
+
+out_free1:
+    close(ksm_fd);
+out_free:
+    close(fd);
+out:
+    return r;
+}
+
 int main(int argc, char **argv)
 {
 #ifdef CONFIG_GDBSTUB
@@ -6735,6 +6767,8 @@ int main(int argc, char **argv)
     /* init the dynamic translator */
     cpu_exec_init_all(tb_size * 1024 * 1024);
 
+    ksm_register_memory();
+
     bdrv_init();
 
     /* we always create the cdrom drive, even if no disk is there */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
