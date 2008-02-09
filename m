References: <2f11576a0802090755n123c9b7dh26e0af6a2fef28af@mail.gmail.com>
Message-Id: <CE520A17-98F2-4A08-82AB-C3D5061616A1@jonmasters.org>
From: Jon Masters <jonathan@jonmasters.org>
In-Reply-To: <2f11576a0802090755n123c9b7dh26e0af6a2fef28af@mail.gmail.com>
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Mime-Version: 1.0 (iPhone Mail 4A93)
Subject: Re: [sample] mem_notify v6: usage example
Content-Transfer-Encoding: 7bit
Date: Sat, 9 Feb 2008 11:07:09 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

This really needs to be triggered via a generic kernel event in the  
final version - I picture glibc having a reservation API and having  
generic support for freeing such reservations.

Jon



On Feb 9, 2008, at 10:55, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com 
 > wrote:

> this is usage example of /dev/mem_notify.
>
> Daniel Spang create original version.
> kosaki add fasync related code.
>
>
> Signed-off-by: Daniel Spang <daniel.spang@gmail.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> ---
> Documentation/mem_notify.c |  120 +++++++++++++++++++++++++++++++++++ 
> ++++++++++
> 1 file changed, 120 insertions(+)
>
> Index: b/Documentation/mem_notify.c
> ===================================================================
> --- /dev/null    1970-01-01 00:00:00.000000000 +0000
> +++ b/Documentation/mem_notify.c    2008-02-10 00:44:00.000000000  
> +0900
> @@ -0,0 +1,120 @@
> +/*
> + * Allocate 10 MB each second. Exit on notification.
> + */
> +
> +#define _GNU_SOURCE
> +
> +#include <sys/mman.h>
> +#include <fcntl.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <string.h>
> +#include <poll.h>
> +#include <pthread.h>
> +#include <errno.h>
> +#include <signal.h>
> +
> +int count = 0;
> +int size = 10;
> +
> +void *do_alloc()
> +{
> +        for(;;) {
> +                int *buffer;
> +                buffer = mmap(NULL,  size*1024*1024,
> +                              PROT_READ | PROT_WRITE,
> +                              MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
> +                if (buffer == MAP_FAILED) {
> +                        perror("mmap");
> +                        exit(EXIT_FAILURE);
> +                }
> +                memset(buffer, 1 , size*1024*1024);
> +
> +                printf("-");
> +                fflush(stdout);
> +
> +                count++;
> +                sleep(1);
> +        }
> +}
> +
> +int wait_for_notification(struct pollfd *pfd)
> +{
> +        int ret;
> +        read(pfd->fd, 0, 0);
> +        ret = poll(pfd, 1, -1);              /* wake up when low  
> memory */
> +        if (ret == -1 && errno != EINTR) {
> +                perror("poll");
> +                exit(EXIT_FAILURE);
> +        }
> +        return ret;
> +}
> +
> +void do_free()
> +{
> +    int fd;
> +    struct pollfd pfd;
> +
> +        fd = open("/dev/mem_notify", O_RDONLY);
> +        if (fd == -1) {
> +                perror("open");
> +                exit(EXIT_FAILURE);
> +        }
> +
> +    pfd.fd = fd;
> +        pfd.events = POLLIN;
> +        for(;;)
> +                if (wait_for_notification(&pfd) > 0) {
> +                        printf("\nGot notification, allocated %d MB 
> \n",
> +                               size * count);
> +                        exit(EXIT_SUCCESS);
> +                }
> +}
> +
> +void do_free_signal()
> +{
> +    int fd;
> +    int flags;
> +
> +        fd = open("/dev/mem_notify", O_RDONLY);
> +        if (fd == -1) {
> +                perror("open");
> +                exit(EXIT_FAILURE);
> +        }
> +
> +    fcntl(fd, F_SETOWN, getpid());
> +    fcntl(fd, F_SETSIG, SIGUSR1);
> +
> +    flags = fcntl(fd, F_GETFL);
> +    fcntl(fd, F_SETFL, flags|FASYNC); /* when low memory, receive  
> SIGUSR1 */
> +
> +    for(;;)
> +        sleep(1);
> +}
> +
> +
> +void daniel_exit(int signo)
> +{
> +    printf("\nGot notification %d, allocated %d MB\n",
> +           signo, size * count);
> +    exit(EXIT_SUCCESS);
> +
> +}
> +
> +int main(int argc, char *argv[])
> +{
> +        pthread_t allocator;
> +
> +    if(argc == 2 && (strcmp(argv[1], "-sig") == 0)) {
> +        printf("run signal mode\n");
> +        signal(SIGUSR1, daniel_exit);
> +        pthread_create(&allocator, NULL, do_alloc, NULL);
> +        do_free_signal();
> +    } else {
> +        printf("run poll mode\n");
> +        pthread_create(&allocator, NULL, do_alloc, NULL);
> +        do_free();
> +    }
> +    return 0;
> +}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
