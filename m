Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 43B136B0038
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 03:01:02 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i17so4465890wmb.7
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 00:01:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k7si14828321wrg.112.2017.11.23.00.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 00:01:01 -0800 (PST)
Date: Thu, 23 Nov 2017 09:01:03 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 4/4] test: add a test for the process_vmsplice syscall
Message-ID: <20171123080103.GA490@kroah.com>
References: <1511379391-988-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1511379391-988-5-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511379391-988-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Andrei Vagin <avagin@openvz.org>

On Wed, Nov 22, 2017 at 09:36:31PM +0200, Mike Rapoport wrote:
> From: Andrei Vagin <avagin@openvz.org>
> 
> This test checks that process_vmsplice() can splice pages from a remote
> process and returns EFAULT, if process_vmsplice() tries to splice pages
> by an unaccessiable address.
> 
> Signed-off-by: Andrei Vagin <avagin@openvz.org>
> ---
>  tools/testing/selftests/process_vmsplice/Makefile  |   5 +
>  .../process_vmsplice/process_vmsplice_test.c       | 188 +++++++++++++++++++++
>  2 files changed, 193 insertions(+)
>  create mode 100644 tools/testing/selftests/process_vmsplice/Makefile
>  create mode 100644 tools/testing/selftests/process_vmsplice/process_vmsplice_test.c
> 
> diff --git a/tools/testing/selftests/process_vmsplice/Makefile b/tools/testing/selftests/process_vmsplice/Makefile
> new file mode 100644
> index 0000000..246d5a7
> --- /dev/null
> +++ b/tools/testing/selftests/process_vmsplice/Makefile
> @@ -0,0 +1,5 @@
> +CFLAGS += -I../../../../usr/include/
> +
> +TEST_GEN_PROGS := process_vmsplice_test
> +
> +include ../lib.mk
> diff --git a/tools/testing/selftests/process_vmsplice/process_vmsplice_test.c b/tools/testing/selftests/process_vmsplice/process_vmsplice_test.c
> new file mode 100644
> index 0000000..8abf59b
> --- /dev/null
> +++ b/tools/testing/selftests/process_vmsplice/process_vmsplice_test.c
> @@ -0,0 +1,188 @@
> +#define _GNU_SOURCE
> +#include <stdio.h>
> +#include <unistd.h>
> +#include <sys/mman.h>
> +#include <sys/syscall.h>
> +#include <fcntl.h>
> +#include <sys/uio.h>
> +#include <errno.h>
> +#include <signal.h>
> +#include <sys/prctl.h>
> +#include <sys/wait.h>
> +
> +#include "../kselftest.h"
> +
> +#ifndef __NR_process_vmsplice
> +#define __NR_process_vmsplice 333
> +#endif
> +
> +#define pr_err(fmt, ...) \
> +		({ \
> +			fprintf(stderr, "%s:%d:" fmt, \
> +				__func__, __LINE__, ##__VA_ARGS__); \
> +			KSFT_FAIL; \
> +		})
> +#define pr_perror(fmt, ...) pr_err(fmt ": %m\n", ##__VA_ARGS__)
> +#define fail(fmt, ...) pr_err("FAIL:" fmt, ##__VA_ARGS__)
> +
> +static ssize_t process_vmsplice(pid_t pid, int fd, const struct iovec *iov,
> +			unsigned long nr_segs, unsigned int flags)
> +{
> +	return syscall(__NR_process_vmsplice, pid, fd, iov, nr_segs, flags);
> +
> +}
> +
> +#define MEM_SIZE (4096 * 100)
> +#define MEM_WRONLY_SIZE (4096 * 10)
> +
> +int main(int argc, char **argv)
> +{
> +	char *addr, *addr_wronly;
> +	int p[2];
> +	struct iovec iov[2];
> +	char buf[4096];
> +	int status, ret;
> +	pid_t pid;
> +
> +	ksft_print_header();
> +
> +	addr = mmap(0, MEM_SIZE, PROT_READ | PROT_WRITE,
> +					MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
> +	if (addr == MAP_FAILED)
> +		return pr_perror("Unable to create a mapping");
> +
> +	addr_wronly = mmap(0, MEM_WRONLY_SIZE, PROT_WRITE,
> +				MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
> +	if (addr_wronly == MAP_FAILED)
> +		return pr_perror("Unable to create a write-only mapping");
> +
> +	if (pipe(p))
> +		return pr_perror("Unable to create a pipe");
> +
> +	pid = fork();
> +	if (pid < 0)
> +		return pr_perror("Unable to fork");
> +
> +	if (pid == 0) {
> +		addr[0] = 'C';
> +		addr[4096 + 128] = 'A';
> +		addr[4096 + 128 + 4096 - 1] = 'B';
> +
> +		if (prctl(PR_SET_PDEATHSIG, SIGKILL))
> +			return pr_perror("Unable to set PR_SET_PDEATHSIG");
> +		if (write(p[1], "c", 1) != 1)
> +			return pr_perror("Unable to write data into pipe");
> +
> +		while (1)
> +			sleep(1);
> +		return 1;
> +	}
> +	if (read(p[0], buf, 1) != 1) {
> +		pr_perror("Unable to read data from pipe");
> +		kill(pid, SIGKILL);
> +		wait(&status);
> +		return 1;
> +	}
> +
> +	munmap(addr, MEM_SIZE);
> +	munmap(addr_wronly, MEM_WRONLY_SIZE);
> +
> +	iov[0].iov_base = addr;
> +	iov[0].iov_len = 1;
> +
> +	iov[1].iov_base = addr + 4096 + 128;
> +	iov[1].iov_len = 4096;
> +
> +	/* check one iovec */
> +	if (process_vmsplice(pid, p[1], iov, 1, SPLICE_F_GIFT) != 1)
> +		return pr_perror("Unable to splice pages");

Shouldn't you check to see if the syscall is even present?  You should
not error if it is not, as this test will then "fail" on kernels/arches
without the syscall enabled, which isn't the nicest.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
