Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id BD1CA6B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 19:50:45 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so106828396ykd.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 16:50:45 -0700 (PDT)
Received: from BLU004-OMC1S7.hotmail.com (blu004-omc1s7.hotmail.com. [65.55.116.18])
        by mx.google.com with ESMTPS id r128si1198467ykb.68.2015.09.11.16.50.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 11 Sep 2015 16:50:44 -0700 (PDT)
Message-ID: <BLU436-SMTP900030005C3628433F546DB9500@phx.gbl>
Date: Sat, 12 Sep 2015 07:52:42 +0800
From: Chen Gang <xili_gchen_5257@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mmap.c: Remove redundent 'get_area' function pointer
 in get_unmapped_area()
References: <1441253691-5798-1-git-send-email-gang.chen.5i5j@gmail.com> <20150910153240.9572375a7a5359a6e2a7ab4a@linux-foundation.org>
In-Reply-To: <20150910153240.9572375a7a5359a6e2a7ab4a@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, gang.chen.5i5j@gmail.com
Cc: mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/11/15 06:32=2C Andrew Morton wrote:
> On Thu=2C  3 Sep 2015 12:14:51 +0800 gang.chen.5i5j@gmail.com wrote:
>=20
> size(1) says this generates more object code.  And that probably means
> slightly worse code.  I didn't investigate=2C but probably the compiler
> is now preparing those five args at two different sites.
>=20
> Which is pretty dumb of it - the compiler could have stacked the args
> first=2C then chosen the appropriate function to call.
>=20

For get_unmapped_area() under x86_64=2C all 5 args are in registers=2C also
file->f_op->get_unmapped_area and current->mm->get_unmapped_area args
are same as get_unmapped_area()=2C which called directly (no new insns).

For me I am not quite sure which performance is better (So originally=2C
I said=2C "if orig code has a bit better performance=2C also if more than
20% taste orig code simple enough=2C we can keep it no touch").

 - New size is a little smaller than orig size.

 - But new insns is a little more than orig insns (x86_64 is not fix
   wide insns).

For me=2C I guess=2C new code is a bit better than orig code: for normal
sequence insns=2C 'size' is more important than insns count (at least=2C it
is more clearer than insns count).

The related dump (build by gcc6):

  [root@localhost mm]# size mmap.new.o
     text	   data	    bss	    dec	    hex	filename
    17597	    266	     40	  17903	   45ef	mmap.new.o
  [root@localhost mm]# size mmap.orig.o
     text	   data	    bss	    dec	    hex	filename
    17613	    266	     40	  17919	   45ff	mmap.orig.o

  objdump for mmap.orig.s:

    00000000000004d0 <get_unmapped_area>:
         4d0:       55                      push   %rbp
         4d1:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         4d8:       00 00=20
         4da:       48 89 e5                mov    %rsp=2C%rbp
         4dd:       41 54                   push   %r12
         4df:       53                      push   %rbx
         4e0:       4c 8b 88 08 c0 ff ff    mov    -0x3ff8(%rax)=2C%r9
         4e7:       48 b8 00 f0 ff ff ff    movabs $0x7ffffffff000=2C%rax
         4ee:       7f 00 00=20
         4f1:       41 f7 c1 00 00 00 20    test   $0x20000000=2C%r9d
         4f8:       74 1f                   je     519 <get_unmapped_area+0=
x49>
         4fa:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         501:       00 00=20
         503:       f6 80 cb 03 00 00 08    testb  $0x8=2C0x3cb(%rax)
         50a:       41 b9 00 e0 ff ff       mov    $0xffffe000=2C%r9d
         510:       b8 00 00 00 c0          mov    $0xc0000000=2C%eax
         515:       49 0f 44 c1             cmove  %r9=2C%rax
         519:       48 39 d0                cmp    %rdx=2C%rax
         51c:       73 0f                   jae    52d <get_unmapped_area+0=
x5d>
         51e:       48 c7 c3 f4 ff ff ff    mov    $0xfffffffffffffff4=2C%r=
bx
         525:       48 89 d8                mov    %rbx=2C%rax
         528:       5b                      pop    %rbx
         529:       41 5c                   pop    %r12
         52b:       5d                      pop    %rbp
         52c:       c3                      retq
   =20
   =20
         52d:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         534:       00 00=20
         536:       48 8b 80 68 03 00 00    mov    0x368(%rax)=2C%rax
         53d:       48 85 ff                test   %rdi=2C%rdi
         540:       4c 8b 48 18             mov    0x18(%rax)=2C%r9
         544:       0f 84 82 00 00 00       je     5cc <get_unmapped_area+0=
xfc>
         54a:       48 8b 47 28             mov    0x28(%rdi)=2C%rax
         54e:       48 8b 80 98 00 00 00    mov    0x98(%rax)=2C%rax
         555:       48 85 c0                test   %rax=2C%rax
         558:       49 0f 44 c1             cmove  %r9=2C%rax
         55c:       49 89 d4                mov    %rdx=2C%r12
         55f:       ff d0                   callq  *%rax
         561:       48 3d 00 f0 ff ff       cmp    $0xfffffffffffff000=2C%r=
ax
         567:       48 89 c3                mov    %rax=2C%rbx
         56a:       77 b9                   ja     525 <get_unmapped_area+0=
x55>
         56c:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         573:       00 00=20
         575:       48 8b 90 08 c0 ff ff    mov    -0x3ff8(%rax)=2C%rdx
         57c:       48 b8 00 f0 ff ff ff    movabs $0x7ffffffff000=2C%rax
         583:       7f 00 00=20
         586:       f7 c2 00 00 00 20       test   $0x20000000=2C%edx
         58c:       74 1e                   je     5ac <get_unmapped_area+0=
xdc>
         58e:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         595:       00 00=20
         597:       f6 80 cb 03 00 00 08    testb  $0x8=2C0x3cb(%rax)
         59e:       ba 00 e0 ff ff          mov    $0xffffe000=2C%edx
         5a3:       b8 00 00 00 c0          mov    $0xc0000000=2C%eax
         5a8:       48 0f 44 c2             cmove  %rdx=2C%rax
         5ac:       4c 29 e0                sub    %r12=2C%rax
         5af:       48 39 c3                cmp    %rax=2C%rbx
         5b2:       0f 87 66 ff ff ff       ja     51e <get_unmapped_area+0=
x4e>
         5b8:       f7 c3 ff 0f 00 00       test   $0xfff=2C%ebx
         5be:       74 11                   je     5d1 <get_unmapped_area+0=
x101>
         5c0:       48 c7 c3 ea ff ff ff    mov    $0xffffffffffffffea=2C%r=
bx
         5c7:       e9 59 ff ff ff          jmpq   525 <get_unmapped_area+0=
x55>
   =20
   =20
         5cc:       4c 89 c8                mov    %r9=2C%rax
         5cf:       eb 8b                   jmp    55c <get_unmapped_area+0=
x8c>
         5d1:       48 89 df                mov    %rbx=2C%rdi
         5d4:       e8 00 00 00 00          callq  5d9 <get_unmapped_area+0=
x109>
         5d9:       48 98                   cltq
         5db:       48 85 c0                test   %rax=2C%rax
         5de:       48 0f 45 d8             cmovne %rax=2C%rbx
         5e2:       e9 3e ff ff ff          jmpq   525 <get_unmapped_area+0=
x55>


         5e7:       66 0f 1f 84 00 00 00    nopw   0x0(%rax=2C%rax=2C1)
         5ee:       00 00                                       =20


  objdump for mmap.new.s

    00000000000004d0 <get_unmapped_area>:
         4d0:       55                      push   %rbp
         4d1:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         4d8:       00 00=20
         4da:       48 89 e5                mov    %rsp=2C%rbp
         4dd:       41 54                   push   %r12
         4df:       53                      push   %rbx
         4e0:       4c 8b 88 08 c0 ff ff    mov    -0x3ff8(%rax)=2C%r9
         4e7:       48 b8 00 f0 ff ff ff    movabs $0x7ffffffff000=2C%rax
         4ee:       7f 00 00=20
         4f1:       41 f7 c1 00 00 00 20    test   $0x20000000=2C%r9d
         4f8:       74 1f                   je     519 <get_unmapped_area+0=
x49>
         4fa:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         501:       00 00=20
         503:       f6 80 cb 03 00 00 08    testb  $0x8=2C0x3cb(%rax)
         50a:       41 b9 00 e0 ff ff       mov    $0xffffe000=2C%r9d
         510:       b8 00 00 00 c0          mov    $0xc0000000=2C%eax
         515:       49 0f 44 c1             cmove  %r9=2C%rax
         519:       48 39 d0                cmp    %rdx=2C%rax
         51c:       73 0f                   jae    52d <get_unmapped_area+0=
x5d>
         51e:       48 c7 c3 f4 ff ff ff    mov    $0xfffffffffffffff4=2C%r=
bx
   =20
         525:       48 89 d8                mov    %rbx=2C%rax
         528:       5b                      pop    %rbx
         529:       41 5c                   pop    %r12
         52b:       5d                      pop    %rbp
         52c:       c3                      retq
   =20
   =20
         52d:       48 85 ff                test   %rdi=2C%rdi
         530:       49 89 d4                mov    %rdx=2C%r12
         533:       74 7a                   je     5af <get_unmapped_area+0=
xdf>
         535:       48 8b 47 28             mov    0x28(%rdi)=2C%rax
         539:       48 8b 80 98 00 00 00    mov    0x98(%rax)=2C%rax
         540:       48 85 c0                test   %rax=2C%rax
         543:       74 6a                   je     5af <get_unmapped_area+0=
xdf>
         545:       ff d0                   callq  *%rax
         547:       48 89 c3                mov    %rax=2C%rbx
         54a:       48 81 fb 00 f0 ff ff    cmp    $0xfffffffffffff000=2C%r=
bx
         551:       77 d2                   ja     525 <get_unmapped_area+0=
x55>
         553:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         55a:       00 00=20
         55c:       48 8b 90 08 c0 ff ff    mov    -0x3ff8(%rax)=2C%rdx
         563:       48 b8 00 f0 ff ff ff    movabs $0x7ffffffff000=2C%rax
         56a:       7f 00 00=20
         56d:       f7 c2 00 00 00 20       test   $0x20000000=2C%edx
         573:       74 1e                   je     593 <get_unmapped_area+0=
xc3>
         575:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         57c:       00 00=20
         57e:       f6 80 cb 03 00 00 08    testb  $0x8=2C0x3cb(%rax)
         585:       ba 00 e0 ff ff          mov    $0xffffe000=2C%edx
         58a:       b8 00 00 00 c0          mov    $0xc0000000=2C%eax
         58f:       48 0f 44 c2             cmove  %rdx=2C%rax
         593:       4c 29 e0                sub    %r12=2C%rax
         596:       48 39 c3                cmp    %rax=2C%rbx
         599:       77 83                   ja     51e <get_unmapped_area+0=
x4e>
         59b:       f7 c3 ff 0f 00 00       test   $0xfff=2C%ebx
         5a1:       74 27                   je     5ca <get_unmapped_area+0=
xfa>
         5a3:       48 c7 c3 ea ff ff ff    mov    $0xffffffffffffffea=2C%r=
bx
         5aa:       e9 76 ff ff ff          jmpq   525 <get_unmapped_area+0=
x55>
         5af:       65 48 8b 04 25 00 00    mov    %gs:0x0=2C%rax
         5b6:       00 00=20
         5b8:       48 8b 80 68 03 00 00    mov    0x368(%rax)=2C%rax
         5bf:       4c 89 e2                mov    %r12=2C%rdx
         5c2:       ff 50 18                callq  *0x18(%rax)
   =20
   =20
         5c5:       48 89 c3                mov    %rax=2C%rbx
         5c8:       eb 80                   jmp    54a <get_unmapped_area+0=
x7a>
         5ca:       48 89 df                mov    %rbx=2C%rdi
         5cd:       e8 00 00 00 00          callq  5d2 <get_unmapped_area+0=
x102>
         5d2:       48 98                   cltq
         5d4:       48 85 c0                test   %rax=2C%rax
         5d7:       48 0f 45 d8             cmovne %rax=2C%rbx
         5db:       e9 45 ff ff ff          jmpq   525 <get_unmapped_area+0=
x55>


Thanks.
--=20
Chen Gang (=E9=99=88=E5=88=9A)

Open=2C share=2C and attitude like air=2C water=2C and life which God bless=
ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
