Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 43FE56B0083
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 15:47:43 -0400 (EDT)
Received: by yenm8 with SMTP id m8so968820yen.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 12:47:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAHN_R2vwv6ZzZLOhVb3XHcucUE+bF955FuAuxMJrr+QRasfCQ@mail.gmail.com>
References: <1335289853-2923-1-git-send-email-siddhesh.poyarekar@gmail.com>
	<alpine.LSU.2.00.1204241148390.18455@eggly.anvils>
	<CAAHN_R2vwv6ZzZLOhVb3XHcucUE+bF955FuAuxMJrr+QRasfCQ@mail.gmail.com>
Date: Wed, 25 Apr 2012 01:17:42 +0530
Message-ID: <CAAHN_R2-quCSKKR43BBcT2Hz+fXjWySayA72j_bdQGMDApfmpA@mail.gmail.com>
Subject: Re: [PATCH] Fix overflow in vma length when copying mmap on clone
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 25 April 2012 01:10, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com> w=
rote:
> That was supposed to be errno, not the pointer. I had added my own
> syscall wrappers to eliminate glibc and then reverted it to the
> original smaller-to-read reproducer and this got left behind in the
> process. The demo program is supposed to show "successed" for
> iterations 16383 to 16390 since the overflow happens at 16TB. All
> iterations before it (and after) show a fork failure.
>
> /proc/sys/vm/overcommit_memory is 0.
>
> Perhaps a cleaner demo program would have been:

Ugh, I missed some details once again. The demo below will show
"Unexpected success" without this patch in place. The system I've
tested this patch on is an x86_64 F-16 box with 4GB RAM and 6GB swap.

> #include <stdio.h>
> #include <unistd.h>
> #include <sys/mman.h>
> #include <errno.h>
>
> #define GIG 1024 * 1024 * 1024L
> #define EXTENT 16393
>
> int main(void)
> {
> =A0 =A0 =A0 =A0int i, r;
> =A0 =A0 =A0 =A0void *m;
> =A0 =A0 =A0 =A0char buf[1024];
> =A0 =A0 =A0 =A0int prev_failed =3D 0;
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < EXTENT; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0m =3D mmap(NULL, (size_t) 1 * 1024 * 1024 =
* 1024L,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PROT_READ | PROT_WRITE, M=
AP_PRIVATE |
> MAP_ANONYMOUS, 0, 0);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (m =3D=3D (void *)-1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printf("MMAP Failed: %d\n"=
, errno);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0r =3D fork();
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (r =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (r < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prev_failed =3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Fork failed as expected=
 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else if (r > 0 && prev_failed) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printf("Unexpected success=
 at %d\n", i);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wait(NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return 0;
> }
>



--=20
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
