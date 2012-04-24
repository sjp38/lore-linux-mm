Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id DDF536B0083
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 15:40:04 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so969880ghr.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 12:40:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1204241148390.18455@eggly.anvils>
References: <1335289853-2923-1-git-send-email-siddhesh.poyarekar@gmail.com>
	<alpine.LSU.2.00.1204241148390.18455@eggly.anvils>
Date: Wed, 25 Apr 2012 01:10:03 +0530
Message-ID: <CAAHN_R2vwv6ZzZLOhVb3XHcucUE+bF955FuAuxMJrr+QRasfCQ@mail.gmail.com>
Subject: Re: [PATCH] Fix overflow in vma length when copying mmap on clone
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 25 April 2012 00:31, Hugh Dickins <hughd@google.com> wrote:
> But I didn't (try very hard to) work out what your demo program shows
> - though I am amused by your sense of humour in using %d for a pointer
> there! =A0I wonder what setting of /proc/sys/vm/overcommit_memory is
> needed for it to behave as you intend?

That was supposed to be errno, not the pointer. I had added my own
syscall wrappers to eliminate glibc and then reverted it to the
original smaller-to-read reproducer and this got left behind in the
process. The demo program is supposed to show "successed" for
iterations 16383 to 16390 since the overflow happens at 16TB. All
iterations before it (and after) show a fork failure.

/proc/sys/vm/overcommit_memory is 0.

Perhaps a cleaner demo program would have been:

#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <errno.h>

#define GIG 1024 * 1024 * 1024L
#define EXTENT 16393

int main(void)
{
        int i, r;
        void *m;
        char buf[1024];
        int prev_failed =3D 0;

        for (i =3D 0; i < EXTENT; i++) {
                m =3D mmap(NULL, (size_t) 1 * 1024 * 1024 * 1024L,
                         PROT_READ | PROT_WRITE, MAP_PRIVATE |
MAP_ANONYMOUS, 0, 0);

                if (m =3D=3D (void *)-1) {
                        printf("MMAP Failed: %d\n", errno);
                        return 1;
                }

                r =3D fork();

                if (r =3D=3D 0) {
                        return 0;
                } else if (r < 0) {
                        prev_failed =3D 1;
                        /* Fork failed as expected */
                }
                else if (r > 0 && prev_failed) {
                        printf("Unexpected success at %d\n", i);
                        wait(NULL);
                        return 1;
                }
        }
        return 0;
}


--=20
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
