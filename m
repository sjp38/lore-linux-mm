Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v2
References: <1226888432-3662-1-git-send-email-ieidus@redhat.com>
From: Dmitri Monakhov <dmonakhov@openvz.org>
Date: Fri, 28 Nov 2008 15:57:02 +0300
In-Reply-To: <1226888432-3662-1-git-send-email-ieidus@redhat.com> (Izik Eidus's message of "Mon\, 17 Nov 2008 04\:20\:28 +0200")
Message-ID: <m33ahcc8kh.fsf@dmon-lap.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, dlaor@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, cl@linux-foundation.org, corbet@lwn.net
List-ID: <linux-mm.kvack.org>

Izik Eidus <ieidus@redhat.com> writes:

> (From v1 to v2 the main change is much more documentation)
>
> KSM is a linux driver that allows dynamicly sharing identical memory
> pages between one or more processes.
>
> Unlike tradtional page sharing that is made at the allocation of the
> memory, ksm do it dynamicly after the memory was created.
> Memory is periodically scanned; identical pages are identified and
> merged.
> The sharing is unnoticeable by the process that use this memory.
> (the shared pages are marked as readonly, and in case of write
> do_wp_page() take care to create new copy of the page)
>
> This driver is very useful for KVM as in cases of runing multiple guests
> operation system of the same type.
Hi Izik, approach that was used in the driver commonly known as
content based search. Where are several variants of it
most commons are:
1: with guest TM support
2: w/o guest vm support.
You have implemented second one, but seems it already was patented
http://www.google.com/patents?vid=USPAT6789156
I'm not a lawyer but IMHO we have direct conflict here.
>From other point of view they have patented the WEEL, but at least we
have to know about this.
> (For desktop work loads we have achived more than x2 memory overcommit
> (more like x3))
>
> This driver have found users other than KVM, for example CERN,
> Fons Rademakers:
> "on many-core machines we run one large detector simulation program per core.
> These simulation programs are identical but run each in their own process and
> need about 2 - 2.5 GB RAM.
> We typically buy machines with 2GB RAM per core and so have a problem to run
> one of these programs per core.
> Of the 2 - 2.5 GB about 700MB is identical data in the form of magnetic field
> maps, detector geometry, etc.
> Currently people have been trying to start one program, initialize the geometry
> and field maps and then fork it N times, to have the data shared.
> With KSM this would be done automatically by the system so it sounded extremely
> attractive when Andrea presented it."
>
> (We have are already started to test KSM on their systems...)
>
> KSM can run as kernel thread or as userspace application or both
>
> example for how to control the kernel thread:
>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <sys/ioctl.h>
> #include <fcntl.h>
> #include <sys/mman.h>
> #include <unistd.h>
> #include "ksm.h"
>
> int main(int argc, char *argv[])
> {
> 	int fd;
> 	int used = 0;
> 	int fd_start;
> 	struct ksm_kthread_info info;
> 	
>
> 	if (argc < 2) {
> 		fprintf(stderr,
> 			"usage: %s {start npages sleep | stop | info}\n",
> 			argv[0]);
> 		exit(1);
> 	}
>
> 	fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
> 	if (fd == -1) {
> 		fprintf(stderr, "could not open /dev/ksm\n");
> 		exit(1);
> 	}
>
> 	if (!strncmp(argv[1], "start", strlen(argv[1]))) {
> 		used = 1;
> 		if (argc < 4) {
> 			fprintf(stderr,
> 		    "usage: %s start npages_to_scan max_pages_to_merge sleep\n",
> 		    argv[0]);
> 			exit(1);
> 		}
> 		info.pages_to_scan = atoi(argv[2]);
> 		info.max_pages_to_merge = atoi(argv[3]);
> 		info.sleep = atoi(argv[4]);
> 		info.flags = ksm_control_flags_run;
>
> 		fd_start = ioctl(fd, KSM_START_STOP_KTHREAD, &info);
> 		if (fd_start == -1) {
> 			fprintf(stderr, "KSM_START_KTHREAD failed\n");
> 			exit(1);
> 		}
> 		printf("created scanner\n");
> 	}
>
> 	if (!strncmp(argv[1], "stop", strlen(argv[1]))) {
> 		used = 1;
> 		info.flags = 0;
> 		fd_start = ioctl(fd, KSM_START_STOP_KTHREAD, &info);
> 		printf("stopped scanner\n");
> 	}
>
> 	if (!strncmp(argv[1], "info", strlen(argv[1]))) {
> 		used = 1;
> 		ioctl(fd, KSM_GET_INFO_KTHREAD, &info);
> 	 printf("flags %d, pages_to_scan %d npages_merge %d, sleep_time %d\n",
> 	 info.flags, info.pages_to_scan, info.max_pages_to_merge, info.sleep);
> 	}
>
> 	if (!used)
> 		fprintf(stderr, "unknown command %s\n", argv[1]);
>
> 	return 0;
> }
>
> example of how to register qemu to ksm (or any userspace application)
>
> diff --git a/qemu/vl.c b/qemu/vl.c
> index 4721fdd..7785bf9 100644
> --- a/qemu/vl.c
> +++ b/qemu/vl.c
> @@ -21,6 +21,7 @@
>   * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
>   * DEALINGS IN
>   * THE SOFTWARE.
>   */
> +#include "ksm.h"
>  #include "hw/hw.h"
>  #include "hw/boards.h"
>  #include "hw/usb.h"
> @@ -5799,6 +5800,37 @@ static void termsig_setup(void)
>  
>  #endif
>  
> +int ksm_register_memory(void)
> +{
> +    int fd;
> +    int ksm_fd;
> +    int r = 1;
> +    struct ksm_memory_region ksm_region;
> +
> +    fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
> +    if (fd == -1)
> +        goto out;
> +
> +    ksm_fd = ioctl(fd, KSM_CREATE_SHARED_MEMORY_AREA);
> +    if (ksm_fd == -1)
> +        goto out_free;
> +
> +    ksm_region.npages = phys_ram_size / TARGET_PAGE_SIZE;
> +    ksm_region.addr = phys_ram_base;
> +    r = ioctl(ksm_fd, KSM_REGISTER_MEMORY_REGION, &ksm_region);
> +    if (r)
> +        goto out_free1;
> +
> +    return r;
> +
> +out_free1:
> +    close(ksm_fd);
> +out_free:
> +    close(fd);
> +out:
> +    return r;
> +}
> +
>  int main(int argc, char **argv)
>  {
>  #ifdef CONFIG_GDBSTUB
> @@ -6735,6 +6767,8 @@ int main(int argc, char **argv)
>      /* init the dynamic translator */
>      cpu_exec_init_all(tb_size * 1024 * 1024);
>  
> +    ksm_register_memory();
> +
>      bdrv_init();
>  
>      /* we always create the cdrom drive, even if no disk is there */
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

>  LocalWords:  Izik vm WEEL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
