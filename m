Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 96D0C6B03B8
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 21:40:37 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id t184so82089982qkd.2
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 18:40:37 -0800 (PST)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.195])
        by mx.google.com with ESMTPS id u2si18790092qtb.147.2016.12.22.18.40.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 18:40:36 -0800 (PST)
From: Dashi DS1 Cao <caods1@lenovo.com>
Subject: RE: A small window for a race condition in
 mm/rmap.c:page_lock_anon_vma_read
Date: Fri, 23 Dec 2016 02:38:32 +0000
Message-ID: <23B7B563BA4E9446B962B142C86EF24ADBF34D@CNMAILEX03.lenovo.com>
References: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com>
 <20161221144343.GD593@dhcp22.suse.cz>
 <20161222135106.GY3124@twins.programming.kicks-ass.net>
 <alpine.LSU.2.11.1612221351340.1744@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1612221351340.1744@eggly.anvils>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

I'd expected that one or more tasks doing the free were the current task of=
 other cpu cores, but only one of the four dumps has two swapd task that ar=
e concurrently at execution on different cpu.
This is the task leading to the crash:
PID: 247    TASK: ffff881fcfad8000  CPU: 14  COMMAND: "kswapd1"
 #0 [ffff881fcfad7978] machine_kexec at ffffffff81051e9b
 #1 [ffff881fcfad79d8] crash_kexec at ffffffff810f27e2
 #2 [ffff881fcfad7aa8] oops_end at ffffffff8163f448
 #3 [ffff881fcfad7ad0] die at ffffffff8101859b
 #4 [ffff881fcfad7b00] do_general_protection at ffffffff8163ed3e
 #5 [ffff881fcfad7b30] general_protection at ffffffff8163e5e8
    [exception RIP: down_read_trylock+9]
    RIP: ffffffff810aa9f9  RSP: ffff881fcfad7be0  RFLAGS: 00010286
    RAX: 0000000000000000  RBX: ffff882b47ddadc0  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: 0000000000000000  RDI: 91550b2b32f5a3e8
    RBP: ffff881fcfad7be0   R8: ffffea00ecc28860   R9: ffff883fcffeae28
    R10: ffffffff81a691a0  R11: 0000000000000001  R12: ffff882b47ddadc1
    R13: ffffea00ecc28840  R14: 91550b2b32f5a3e8  R15: ffffea00ecc28840
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
 #6 [ffff881fcfad7be8] page_lock_anon_vma_read at ffffffff811a3365
 #7 [ffff881fcfad7c18] page_referenced at ffffffff811a35e7
 #8 [ffff881fcfad7c90] shrink_active_list at ffffffff8117e8cc
 #9 [ffff881fcfad7d48] balance_pgdat at ffffffff81180288
#10 [ffff881fcfad7e20] kswapd at ffffffff81180813
#11 [ffff881fcfad7ec8] kthread at ffffffff810a5b8f
#12 [ffff881fcfad7f50] ret_from_fork at ffffffff81646a98

And this is the one at the same time:
PID: 246    TASK: ffff881fd27af300  CPU: 20  COMMAND: "kswapd0"
 #0 [ffff881fffd05e70] crash_nmi_callback at ffffffff81045982
 #1 [ffff881fffd05e80] nmi_handle at ffffffff8163f5d9
 #2 [ffff881fffd05ec8] do_nmi at ffffffff8163f6f0
 #3 [ffff881fffd05ef0] end_repeat_nmi at ffffffff8163ea13
    [exception RIP: free_pcppages_bulk+529]
    RIP: ffffffff81171ae1  RSP: ffff881fcfad38f0  RFLAGS: 00000087
    RAX: 002fffff0000002c  RBX: ffffea007606ae40  RCX: 0000000000000000
    RDX: ffffea007606ae00  RSI: 00000000000002b9  RDI: 0000000000000000
    RBP: ffff881fcfad3978   R8: 0000000000000000   R9: 0000000000000001
    R10: ffff88207ffda000  R11: 0000000000000002  R12: ffffea007606ae40
    R13: 0000000000000002  R14: ffff88207ffda000  R15: 00000000000002b8
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
--- <NMI exception stack> ---
 #4 [ffff881fcfad38f0] free_pcppages_bulk at ffffffff81171ae1
 #5 [ffff881fcfad3980] free_hot_cold_page at ffffffff81171f08
 #6 [ffff881fcfad39b8] free_hot_cold_page_list at ffffffff81171f76
 #7 [ffff881fcfad39f0] shrink_page_list at ffffffff8117d71e
 #8 [ffff881fcfad3b28] shrink_inactive_list at ffffffff8117e37a
 #9 [ffff881fcfad3bf0] shrink_lruvec at ffffffff8117ee45
#10 [ffff881fcfad3cf0] shrink_zone at ffffffff8117f2a6
#11 [ffff881fcfad3d48] balance_pgdat at ffffffff8118054c
#12 [ffff881fcfad3e20] kswapd at ffffffff81180813
#13 [ffff881fcfad3ec8] kthread at ffffffff810a5b8f
#14 [ffff881fcfad3f50] ret_from_fork at ffffffff81646a98

I hope the information would be useful.
Dashi Cao

-----Original Message-----
From: Hugh Dickins [mailto:hughd@google.com]=20
Sent: Friday, December 23, 2016 6:27 AM
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>; Dashi DS1 Cao <caods1@lenovo.com>; li=
nux-mm@kvack.org; linux-kernel@vger.kernel.org; Hugh Dickins <hughd@google.=
com>
Subject: Re: A small window for a race condition in mm/rmap.c:page_lock_ano=
n_vma_read

On Thu, 22 Dec 2016, Peter Zijlstra wrote:
> On Wed, Dec 21, 2016 at 03:43:43PM +0100, Michal Hocko wrote:
> > anon_vma locking is clever^Wsubtle as hell. CC Peter...
> >=20
> > On Tue 20-12-16 09:32:27, Dashi DS1 Cao wrote:
> > > I've collected four crash dumps with similar backtrace.=20
> > >=20
> > > PID: 247    TASK: ffff881fcfad8000  CPU: 14  COMMAND: "kswapd1"
> > >  #0 [ffff881fcfad7978] machine_kexec at ffffffff81051e9b
> > >  #1 [ffff881fcfad79d8] crash_kexec at ffffffff810f27e2
> > >  #2 [ffff881fcfad7aa8] oops_end at ffffffff8163f448
> > >  #3 [ffff881fcfad7ad0] die at ffffffff8101859b
> > >  #4 [ffff881fcfad7b00] do_general_protection at ffffffff8163ed3e
> > >  #5 [ffff881fcfad7b30] general_protection at ffffffff8163e5e8
> > >     [exception RIP: down_read_trylock+9]
> > >     RIP: ffffffff810aa9f9  RSP: ffff881fcfad7be0  RFLAGS: 00010286
> > >     RAX: 0000000000000000  RBX: ffff882b47ddadc0  RCX: 00000000000000=
00
> > >     RDX: 0000000000000000  RSI: 0000000000000000  RDI:=20
> > > 91550b2b32f5a3e8
> >=20
> > rdi is obviously a mess - smells like a string. So either sombody=20
> > has overwritten root_anon_vma or this is really a use after free...
>=20
> e8 - ???
> a3 - ???
> f5 - ???
> 32 - 2
> 2b - +
>  b -
>=20
> 55 - U
> 91 - ???
>=20
> Not a string..
>=20
> > >     RBP: ffff881fcfad7be0   R8: ffffea00ecc28860   R9: ffff883fcffeae=
28
> > >     R10: ffffffff81a691a0  R11: 0000000000000001  R12: ffff882b47ddad=
c1
> > >     R13: ffffea00ecc28840  R14: 91550b2b32f5a3e8  R15: ffffea00ecc288=
40
> > >     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
> > >  #6 [ffff881fcfad7be8] page_lock_anon_vma_read at ffffffff811a3365
> > >  #7 [ffff881fcfad7c18] page_referenced at ffffffff811a35e7
> > >  #8 [ffff881fcfad7c90] shrink_active_list at ffffffff8117e8cc
> > >  #9 [ffff881fcfad7d48] balance_pgdat at ffffffff81180288
> > > #10 [ffff881fcfad7e20] kswapd at ffffffff81180813
> > > #11 [ffff881fcfad7ec8] kthread at ffffffff810a5b8f
> > > #12 [ffff881fcfad7f50] ret_from_fork at ffffffff81646a98
> > >=20
> > > I suspect my customer hits into a small window of a race condition in=
 mm/rmap.c: page_lock_anon_vma_read.
> > > struct anon_vma *page_lock_anon_vma_read(struct page *page) {
> > >         struct anon_vma *anon_vma =3D NULL;
> > >         struct anon_vma *root_anon_vma;
> > >         unsigned long anon_mapping;
> > >=20
> > >         rcu_read_lock();
> > >         anon_mapping =3D (unsigned long)READ_ONCE(page->mapping);
> > >         if ((anon_mapping & PAGE_MAPPING_FLAGS) !=3D PAGE_MAPPING_ANO=
N)
> > >                 goto out;
> > >         if (!page_mapped(page))
> > >                 goto out;
> > >=20
> > >         anon_vma =3D (struct anon_vma *) (anon_mapping - PAGE_MAPPING=
_ANON);
> > >         root_anon_vma =3D READ_ONCE(anon_vma->root);
> >=20
> > Could you dump the anon_vma and struct page as well?
> >=20
> > >         if (down_read_trylock(&root_anon_vma->rwsem)) {
> > >                 /*
> > >                  * If the page is still mapped, then this anon_vma is=
 still
> > >                  * its anon_vma, and holding the mutex ensures that i=
t will
> > >                  * not go away, see anon_vma_free().
> > >                  */
> > >                 if (!page_mapped(page)) {
> > >                         up_read(&root_anon_vma->rwsem);
> > >                         anon_vma =3D NULL;
> > >                 }
> > >                 goto out;
> > >         }
> > > ...
> > > }
> > >=20
> > > Between the time the two "page_mapped(page)" are checked, the=20
> > > address (anon_mapping - PAGE_MAPPING_ANON) is unmapped! However it=20
> > > seems that anon_vma->root could still be read in but the value is=20
> > > wild. So the kernel crashes in down_read_trylock. But it's weird=20
> > > that all the "struct page" has its member "_mapcount" still with=20
> > > value 0, not -1, in the four crashes.
>=20
> So the point is that while we hold rcu_read_lock() the actual memory=20
> backing the anon_vmas cannot be freed. It can be reused, but only for=20
> another anon_vma.
>=20
> Now, anon_vma_alloc() sets ->root to self, while anon_vma_free()=20
> leaves
> ->root set to whatever. And any other ->root assignment is to a valid
> anon_vma.
>=20
> Therefore, the same rules that ensure anon_vma stays valid, should=20
> also ensure anon_vma->root stays valid.
>=20
> Now, one thing that might go wobbly is that ->root assignments are not=20
> done using WRITE_ONCE(), this means a naughty compiler can miscompile=20
> those stores and introduce store-tearing, if our READ_ONCE() would=20
> observe such a tear, we'd be up some creek without a paddle.

We would indeed.  And this being the season of goodwill, I'm biting my tong=
ue not to say what I think of the prospect of store tearing.
But that zeroed anon_vma implies tearing not the problem here anyway.

>=20
> Now, its been a long time since I looked at any of this code, and I=20
> see that Hugh has fixed at least two wobblies in my original code.

Nothing much, and this (admittedly subtle) technique has been working well =
for years, so I'm sceptical about "a small window for a race condition".

But Dashi's right to point out that the struct page has _mapcount 0 (not -1=
 for logical 0) in these cases: it looks as if something is freeing (or cor=
rupting) the anon_vma despite it still having pages mapped, or something is=
 misaccounting (or corrupting) the _mapcount.

But I've no idea what, and we have not heard such reports elsewhere.
We don't even know what kernel this is - something special, perhaps?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
