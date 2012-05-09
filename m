Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id BC8066B010C
	for <linux-mm@kvack.org>; Wed,  9 May 2012 05:28:57 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so86604vbb.14
        for <linux-mm@kvack.org>; Wed, 09 May 2012 02:28:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <85e08d38-234a-4bc6-8c4f-6c92b50dc9b1@zmail13.collab.prod.int.phx2.redhat.com>
References: <50e8b720-2459-4cf4-bfbd-fcc4cd408249@zmail13.collab.prod.int.phx2.redhat.com>
	<85e08d38-234a-4bc6-8c4f-6c92b50dc9b1@zmail13.collab.prod.int.phx2.redhat.com>
Date: Wed, 9 May 2012 17:28:56 +0800
Message-ID: <CAJn8CcGGyPNOZH2g+2FaFCtg70P4QOVvzhWYDcGoJta3-ikr8Q@mail.gmail.com>
Subject: Re: mm: move_pages syscall can't return ENOENT when pages are not present
From: Xiaotian Feng <xtfeng@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 9, 2012 at 4:58 PM, Zhouping Liu <zliu@redhat.com> wrote:
> hi, all
>
> Recently, I found an error in move_pages syscall:
>
> depending on move_pages(2), when page is not present,
> it should fail with ENOENT, in fact, it's ok without
> any errno.
>
> the following reproducer can easily reproduce
> the issue, suggest you get more details by strace.
> inside reproducer, I try to move a non-exist page from
> node 1 to node 0.
>
> I have tested it on the latest kernel 3.4-rc5 with 2 and 4 numa nodes.
> [zliu@ZhoupingLiu ~]$ gcc -o reproducer reproducer.c -lnuma
> [zliu@ZhoupingLiu ~]$ ./reproducer
> from_node is 1, to_node is 0
> ERROR: move_pages expected FAIL.
>

" If nodes is not NULL, move_pages returns the number of valid
migration requests which could not currently be performed.  Otherwise
it returns 0."

> I'm not in mail list, please CC me.
>
> /*
> =C2=A0* Copyright (C) 2012 =C2=A0Red Hat, Inc.
> =C2=A0*
> =C2=A0* This work is licensed under the terms of the GNU GPL, version 2. =
See
> =C2=A0* the COPYING file in the top-level directory.
> =C2=A0*
> =C2=A0* Compiled: gcc -o reproducer reproducer.c -lnuma
> =C2=A0* Description:
> =C2=A0* it's designed to check move_pages syscall, when
> =C2=A0* page is not present, it should fail with ENOENT.
> =C2=A0*/
>
> #include <sys/mman.h>
> #include <sys/types.h>
> #include <sys/wait.h>
> #include <stdio.h>
> #include <unistd.h>
> #include <errno.h>
> #include <numa.h>
> #include <numaif.h>
>
> #define TEST_PAGES 4
>
> int main(int argc, char **argv)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0void *pages[TEST_PAGES];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int onepage;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int nodes[TEST_PAGES];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int status, ret;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i, from_node =3D 1, to_node =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0onepage =3D getpagesize();
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < TEST_PAGES - 1; i++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pages[i] =3D numa_=
alloc_onnode(onepage, from_node);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nodes[i] =3D to_no=
de;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nodes[TEST_PAGES - 1] =3D to_node;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * the follow page is not available, also not =
aligned,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * depend on move_pages(2), it can't be moved,=
 and should
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * return ENOENT errno.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pages[TEST_PAGES - 1] =3D pages[TEST_PAGES - 2=
] - onepage * 4 + 1;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("from_node is %u, to_node is %u\n", fro=
m_node, to_node);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D move_pages(0, TEST_PAGES, pages, nodes=
, &status, MPOL_MF_MOVE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret =3D=3D -1) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (errno !=3D ENO=
ENT)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0perror("move_pages expected ENOENT errno, but it's");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0printf("Succeed\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("ERROR: mov=
e_pages expected FAIL.\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < TEST_PAGES; i++)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0numa_free(pages[i]=
, onepage);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> }
>
> --
> Thanks,
> Zhouping
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
