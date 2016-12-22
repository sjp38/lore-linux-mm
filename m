Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B154D6B0411
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 06:53:33 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id n21so62061682qka.4
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 03:53:33 -0800 (PST)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.206])
        by mx.google.com with ESMTP id t44si17266408qtc.169.2016.12.22.03.53.31
        for <linux-mm@kvack.org>;
        Thu, 22 Dec 2016 03:53:31 -0800 (PST)
From: Dashi DS1 Cao <caods1@lenovo.com>
Subject: RE: A small window for a race condition in
 mm/rmap.c:page_lock_anon_vma_read
Date: Thu, 22 Dec 2016 11:53:26 +0000
Message-ID: <23B7B563BA4E9446B962B142C86EF24ADBEBB6@CNMAILEX03.lenovo.com>
References: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com>
 <20161221144343.GD593@dhcp22.suse.cz>
In-Reply-To: <20161221144343.GD593@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

I've used another dump with similar backtrace.

PID: 246    TASK: ffff881fd27df300  CPU: 0   COMMAND: "kswapd0"
 #0 [ffff881fcfb23748] machine_kexec at ffffffff81051e9b
 #1 [ffff881fcfb237a8] crash_kexec at ffffffff810f27e2
 #2 [ffff881fcfb23878] oops_end at ffffffff8163f448
 #3 [ffff881fcfb238a0] no_context at ffffffff8162f561
 #4 [ffff881fcfb238f0] __bad_area_nosemaphore at ffffffff8162f5f7
 #5 [ffff881fcfb23938] bad_area_nosemaphore at ffffffff8162f761
 #6 [ffff881fcfb23948] __do_page_fault at ffffffff816421ce
 #7 [ffff881fcfb239a8] do_page_fault at ffffffff81642363
 #8 [ffff881fcfb239d0] page_fault at ffffffff8163e648
    [exception RIP: down_read_trylock+9]
    RIP: ffffffff810aa9f9  RSP: ffff881fcfb23a88  RFLAGS: 00010202
    RAX: 0000000000000000  RBX: ffff8820833ed940  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000008
    RBP: ffff881fcfb23a88   R8: ffffea00779b3a60   R9: ffff883fd0d7b070
    R10: 000000000000000e  R11: ffffea00049e9580  R12: ffff8820833ed941
    R13: ffffea00779b3a40  R14: 0000000000000008  R15: ffffea00779b3a40
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #9 [ffff881fcfb23a90] page_lock_anon_vma_read at ffffffff811a3365
#10 [ffff881fcfb23ac0] page_referenced at ffffffff811a35e7
#11 [ffff881fcfb23b38] shrink_active_list at ffffffff8117e8cc
#12 [ffff881fcfb23bf0] shrink_lruvec at ffffffff8117ef8d
#13 [ffff881fcfb23cf0] shrink_zone at ffffffff8117f2a6
#14 [ffff881fcfb23d48] balance_pgdat at ffffffff8118054c
#15 [ffff881fcfb23e20] kswapd at ffffffff81180813
#16 [ffff881fcfb23ec8] kthread at ffffffff810a5b8f
#17 [ffff881fcfb23f50] ret_from_fork at ffffffff81646a98
crash> print *((struct page *)0xffffea00779b3a40j)
$1 =3D {
  flags =3D 13510794587668552,=20
  mapping =3D 0xffff8820833ed941,=20
  {
    {
      index =3D 34194823743,=20
      freelist =3D 0x7f62b9a3f,=20
      pfmemalloc =3D 63,=20
      pmd_huge_pte =3D 0x7f62b9a3f
    },=20
    {
      counters =3D 8589934592,=20
      {
        {
          _mapcount =3D {
            counter =3D 0
          },=20
          {
            inuse =3D 0,=20
            objects =3D 0,=20
            frozen =3D 0
          },=20
          units =3D 0
        },=20
        _count =3D {
          counter =3D 2
         }
      }
    }
  },=20
  {
    lru =3D {
      next =3D 0xdead000000100100,=20
      prev =3D 0xdead000000200200
    },=20
    {
      next =3D 0xdead000000100100,=20
      pages =3D 2097664,=20
      pobjects =3D -559087616
    },=20
    list =3D {
      next =3D 0xdead000000100100,=20
      prev =3D 0xdead000000200200
    },=20
    slab_page =3D 0xdead000000100100
  },=20
  {
    private =3D 0,=20
    ptl =3D {
      {
        rlock =3D {
          raw_lock =3D {
             {
              head_tail =3D 0,=20
              tickets =3D {
                head =3D 0,=20
                tail =3D 0
              }
            }
          }
        }
      }
    },=20
    slab_cache =3D 0x0,=20
    first_page =3D 0x0
  }
}
crash>  disassemble page_lock_anon_vma_read
Dump of assembler code for function page_lock_anon_vma_read:
   0xffffffff811a3310 <+0>:     nopl   0x0(%rax,%rax,1)
   0xffffffff811a3315 <+5>:     push   %rbp
   0xffffffff811a3316 <+6>:     mov    %rsp,%rbp
   0xffffffff811a3319 <+9>:     push   %r14
   0xffffffff811a331b <+11>:    push   %r13
   0xffffffff811a331d <+13>:    mov    %rdi,%r13
   0xffffffff811a3320 <+16>:    push   %r12
   0xffffffff811a3322 <+18>:    push   %rbx
   0xffffffff811a3323 <+19>:    mov    0x8(%rdi),%r12
   0xffffffff811a3327 <+23>:    mov    %r12,%rax
   0xffffffff811a332a <+26>:    and    $0x3,%eax
   0xffffffff811a332d <+29>:    cmp    $0x1,%rax
   0xffffffff811a3331 <+33>:    je     0xffffffff811a3348 <page_lock_anon_v=
ma_read+56>
   0xffffffff811a3333 <+35>:    xor    %ebx,%ebx
   0xffffffff811a3335 <+37>:    mov    %rbx,%rax
   0xffffffff811a3338 <+40>:    pop    %rbx
   0xffffffff811a3339 <+41>:    pop    %r12
   0xffffffff811a333b <+43>:    pop    %r13
   0xffffffff811a333d <+45>:    pop    %r14
   0xffffffff811a333f <+47>:    pop    %rbp
   0xffffffff811a3340 <+48>:    retq  =20
   0xffffffff811a3341 <+49>:    nopl   0x0(%rax)
   0xffffffff811a3348 <+56>:    mov    0x18(%rdi),%eax
   0xffffffff811a334b <+59>:    test   %eax,%eax
   0xffffffff811a334d <+61>:    js     0xffffffff811a3333 <page_lock_anon_v=
ma_read+35>
   0xffffffff811a334f <+63>:    mov    -0x1(%r12),%r14
   0xffffffff811a3354 <+68>:    lea    -0x1(%r12),%rbx
   0xffffffff811a3359 <+73>:    add    $0x8,%r14
   0xffffffff811a335d <+77>:    mov    %r14,%rdi
   0xffffffff811a3360 <+80>:    callq  0xffffffff810aa9f0 <down_read_tryloc=
k>
   0xffffffff811a3365 <+85>:    test   %eax,%eax
   0xffffffff811a3367 <+87>:    je     0xffffffff811a3380 <page_lock_anon_v=
ma_read+112>
   0xffffffff811a3369 <+89>:    mov    0x18(%r13),%eax
   0xffffffff811a336d <+93>:    test   %eax,%eax
   0xffffffff811a336f <+95>:    jns    0xffffffff811a3335 <page_lock_anon_v=
ma_read+37>
   0xffffffff811a3371 <+97>:    mov    %r14,%rdi
   0xffffffff811a3374 <+100>:   xor    %ebx,%ebx
   0xffffffff811a3376 <+102>:   callq  0xffffffff810aaa50 <up_read>
   0xffffffff811a337b <+107>:   jmp    0xffffffff811a3335 <page_lock_anon_v=
ma_read+37>
   0xffffffff811a337d <+109>:   nopl   (%rax)
   0xffffffff811a3380 <+112>:   mov    0x28(%rbx),%edx
   0xffffffff811a3383 <+115>:   test   %edx,%edx
   0xffffffff811a3385 <+117>:   je     0xffffffff811a3333 <page_lock_anon_v=
ma_read+35>
   0xffffffff811a3387 <+119>:   lea    0x1(%rdx),%ecx
   0xffffffff811a338a <+122>:   lea    0x27(%r12),%rsi
   0xffffffff811a338f <+127>:   mov    %edx,%eax
   0xffffffff811a3391 <+129>:   lock cmpxchg %ecx,0x27(%r12)
   0xffffffff811a3398 <+136>:   cmp    %edx,%eax
   0xffffffff811a339a <+138>:   mov    %eax,%ecx
   0xffffffff811a339c <+140>:   jne    0xffffffff811a3402 <page_lock_anon_v=
ma_read+242>
   0xffffffff811a339e <+142>:   mov    0x18(%r13),%eax
   0xffffffff811a33a2 <+146>:   test   %eax,%eax
   0xffffffff811a33a4 <+148>:   js     0xffffffff811a33e2 <page_lock_anon_v=
ma_read+210>
   0xffffffff811a33a6 <+150>:   mov    -0x1(%r12),%rax
   0xffffffff811a33ab <+155>:   lea    0x8(%rax),%rdi
   0xffffffff811a33af <+159>:   callq  0xffffffff8163ad30 <down_read>
   0xffffffff811a33b4 <+164>:   lock decl 0x27(%r12)
   0xffffffff811a33ba <+170>:   sete   %al
   0xffffffff811a33bd <+173>:   test   %al,%al
   0xffffffff811a33bf <+175>:   je     0xffffffff811a3335 <page_lock_anon_v=
ma_read+37>
   0xffffffff811a33c5 <+181>:   mov    -0x1(%r12),%rdi
   0xffffffff811a33ca <+186>:   add    $0x8,%rdi
   0xffffffff811a33ce <+190>:   callq  0xffffffff810aaa50 <up_read>
   0xffffffff811a33d3 <+195>:   mov    %rbx,%rdi
   0xffffffff811a33d6 <+198>:   xor    %ebx,%ebx
   0xffffffff811a33d8 <+200>:   callq  0xffffffff811a2dd0 <__put_anon_vma>
   0xffffffff811a33dd <+205>:   jmpq   0xffffffff811a3335 <page_lock_anon_v=
ma_read+37>
   0xffffffff811a33e2 <+210>:   lock decl 0x27(%r12)
   0xffffffff811a33e8 <+216>:   sete   %al
   0xffffffff811a33eb <+219>:   test   %al,%al
   0xffffffff811a33ed <+221>:   je     0xffffffff811a3333 <page_lock_anon_v=
ma_read+35>
   0xffffffff811a33f3 <+227>:   mov    %rbx,%rdi
   0xffffffff811a33f6 <+230>:   xor    %ebx,%ebx
   0xffffffff811a33f8 <+232>:   callq  0xffffffff811a2dd0 <__put_anon_vma>
   0xffffffff811a33fd <+237>:   jmpq   0xffffffff811a3335 <page_lock_anon_v=
ma_read+37>
   0xffffffff811a3402 <+242>:   test   %ecx,%ecx
   0xffffffff811a3404 <+244>:   je     0xffffffff811a3333 <page_lock_anon_v=
ma_read+35>
   0xffffffff811a340a <+250>:   lea    0x1(%rcx),%edx
   0xffffffff811a340d <+253>:   mov    %ecx,%eax
   0xffffffff811a340f <+255>:   lock cmpxchg %edx,(%rsi)
   0xffffffff811a3413 <+259>:   cmp    %eax,%ecx
   0xffffffff811a3415 <+261>:   je     0xffffffff811a339e <page_lock_anon_v=
ma_read+142>
   0xffffffff811a3417 <+263>:   mov    %eax,%ecx
   0xffffffff811a3419 <+265>:   jmp    0xffffffff811a3402 <page_lock_anon_v=
ma_read+242>
End of assembler dump.
crash> =20

Dashi Cao
-----Original Message-----
From: Michal Hocko [mailto:mhocko@kernel.org]=20
Sent: Wednesday, December 21, 2016 10:44 PM
To: Dashi DS1 Cao <caods1@lenovo.com>
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; Peter Zijlstra <peter=
z@infradead.org>
Subject: Re: A small window for a race condition in mm/rmap.c:page_lock_ano=
n_vma_read

anon_vma locking is clever^Wsubtle as hell. CC Peter...

On Tue 20-12-16 09:32:27, Dashi DS1 Cao wrote:
> I've collected four crash dumps with similar backtrace.=20
>=20
> PID: 247    TASK: ffff881fcfad8000  CPU: 14  COMMAND: "kswapd1"
>  #0 [ffff881fcfad7978] machine_kexec at ffffffff81051e9b
>  #1 [ffff881fcfad79d8] crash_kexec at ffffffff810f27e2
>  #2 [ffff881fcfad7aa8] oops_end at ffffffff8163f448
>  #3 [ffff881fcfad7ad0] die at ffffffff8101859b
>  #4 [ffff881fcfad7b00] do_general_protection at ffffffff8163ed3e
>  #5 [ffff881fcfad7b30] general_protection at ffffffff8163e5e8
>     [exception RIP: down_read_trylock+9]
>     RIP: ffffffff810aa9f9  RSP: ffff881fcfad7be0  RFLAGS: 00010286
>     RAX: 0000000000000000  RBX: ffff882b47ddadc0  RCX: 0000000000000000
>     RDX: 0000000000000000  RSI: 0000000000000000  RDI:=20
> 91550b2b32f5a3e8

rdi is obviously a mess - smells like a string. So either sombody has overw=
ritten root_anon_vma or this is really a use after free...

>     RBP: ffff881fcfad7be0   R8: ffffea00ecc28860   R9: ffff883fcffeae28
>     R10: ffffffff81a691a0  R11: 0000000000000001  R12: ffff882b47ddadc1
>     R13: ffffea00ecc28840  R14: 91550b2b32f5a3e8  R15: ffffea00ecc28840
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
>  #6 [ffff881fcfad7be8] page_lock_anon_vma_read at ffffffff811a3365
>  #7 [ffff881fcfad7c18] page_referenced at ffffffff811a35e7
>  #8 [ffff881fcfad7c90] shrink_active_list at ffffffff8117e8cc
>  #9 [ffff881fcfad7d48] balance_pgdat at ffffffff81180288
> #10 [ffff881fcfad7e20] kswapd at ffffffff81180813
> #11 [ffff881fcfad7ec8] kthread at ffffffff810a5b8f
> #12 [ffff881fcfad7f50] ret_from_fork at ffffffff81646a98
>=20
> I suspect my customer hits into a small window of a race condition in mm/=
rmap.c: page_lock_anon_vma_read.
> struct anon_vma *page_lock_anon_vma_read(struct page *page) {
>         struct anon_vma *anon_vma =3D NULL;
>         struct anon_vma *root_anon_vma;
>         unsigned long anon_mapping;
>=20
>         rcu_read_lock();
>         anon_mapping =3D (unsigned long)READ_ONCE(page->mapping);
>         if ((anon_mapping & PAGE_MAPPING_FLAGS) !=3D PAGE_MAPPING_ANON)
>                 goto out;
>         if (!page_mapped(page))
>                 goto out;
>=20
>         anon_vma =3D (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANO=
N);
>         root_anon_vma =3D READ_ONCE(anon_vma->root);

Could you dump the anon_vma and struct page as well?

>         if (down_read_trylock(&root_anon_vma->rwsem)) {
>                 /*
>                  * If the page is still mapped, then this anon_vma is sti=
ll
>                  * its anon_vma, and holding the mutex ensures that it wi=
ll
>                  * not go away, see anon_vma_free().
>                  */
>                 if (!page_mapped(page)) {
>                         up_read(&root_anon_vma->rwsem);
>                         anon_vma =3D NULL;
>                 }
>                 goto out;
>         }
> ...
> }
>=20
> Between the time the two "page_mapped(page)" are checked, the address=20
> (anon_mapping - PAGE_MAPPING_ANON) is unmapped! However it seems that=20
> anon_vma->root could still be read in but the value is wild. So the=20
> kernel crashes in down_read_trylock. But it's weird that all the=20
> "struct page" has its member "_mapcount" still with value 0, not -1,=20
> in the four crashes.

--
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
