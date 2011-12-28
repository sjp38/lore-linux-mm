Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 37FE26B004D
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 21:04:35 -0500 (EST)
Received: by ghrr18 with SMTP id r18so8365642ghr.14
        for <linux-mm@kvack.org>; Tue, 27 Dec 2011 18:04:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EF96406.6080102@jp.fujitsu.com>
References: <4EF2F9EB.7000006@jp.fujitsu.com> <4EF36BDA.5080105@gmail.com> <4EF96406.6080102@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 27 Dec 2011 21:04:13 -0500
Message-ID: <CAHGf_=rW6_94NbxB1cUbrXo+YntDy7RM26XMcqk_SHXVESaSzg@mail.gmail.com>
Subject: Re: [PATCH] mm: mmap system call does not return EOVERFLOW
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naotaka Hamaguchi <n.hamaguchi@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

> ----------------------------------------------------------------------
> arch/x86/kernel/syscall_table_32.S:
> ...
> =A0194 =A0 =A0 =A0 =A0 .long sys_mmap_pgoff
> ...
>
> mm/mmap.c:
> 1080 SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
> 1081 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long, prot, unsigned long, =
flags,
> 1082 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long, fd, unsigned long, pg=
off)
> ...
> 1111 =A0 =A0 =A0 =A0 down_write(&current->mm->mmap_sem);
> 1112 =A0 =A0 =A0 =A0 retval =3D do_mmap_pgoff(file, addr, len, prot, flag=
s, pgoff);
> 1113 =A0 =A0 =A0 =A0 up_write(&current->mm->mmap_sem);
> ----------------------------------------------------------------------
>
>> value. We have
>> no reason to make artificial limit. Why don't you meke a overflow
>> check in sys_mmap()?
>
> I consider it is better to make an overflow check in do_mmap_pgoff.
> There are two reasons:
>
> 1. If we make an overflow check in the entrance of system call, we
> =A0 have to check in sys_mmap for x86_64 and in sys_mmap_pgoff for
> =A0 x86. It means that we have to check for each architecture
> =A0 individually. Therefore, it is more effective to make an
> =A0 overflow check in do_mmap_pgoff because both sys_mmap and
> =A0 sys_mmap_pgoff call do_mmap_pgoff.

arch/x86/include/asm/posix_types_32.h
---------------------------------------------
typedef long            __kernel_off_t;


So, your patch introduce 2GB limitation to 32bit arch. It makes no sense.



> 2. Because the argument "offset" of sys_mmap is a multiple
> =A0 of the page size(otherwise, EINVAL is returned.), no information
> =A0 is lost after shifting right by PAGE_SHIFT bits. Therefore
> =A0 to make an overflow check in do_mmap_pgoff is equivalent
> =A0 to check in sys_mmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
