Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB5B8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:56:17 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id w5so1878912iom.3
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 09:56:17 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740138.outbound.protection.outlook.com. [40.107.74.138])
        by mx.google.com with ESMTPS id i8si309605iom.54.2018.12.20.09.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Dec 2018 09:56:16 -0800 (PST)
From: Paul Burton <paul.burton@mips.com>
Subject: Re: Fixing MIPS delay slot emulation weakness?
Date: Thu, 20 Dec 2018 17:56:12 +0000
Message-ID: <20181220175605.t6oogok42f62th2w@pburton-laptop>
References: 
 <CALCETrWaWTupSp6V=XXhvExtFdS6ewx_0A7hiGfStqpeuqZn8g@mail.gmail.com>
 <20181219043155.nkaofln64lbp2gfz@pburton-laptop>
 <alpine.LSU.2.11.1812191249560.24428@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1812191249560.24428@eggly.anvils>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <29BE76999D94964782932B09CAD869F4@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux MIPS Mailing List <linux-mips@linux-mips.org>, LKML <linux-kernel@vger.kernel.org>, David Daney <david.daney@cavium.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Rich Felker <dalias@libc.org>

Hi Hugh,

On Wed, Dec 19, 2018 at 01:12:58PM -0800, Hugh Dickins wrote:
> > is_cow_mapping() returns true if the VM_MAYWRITE flag is set and
> > VM_SHARED is not set - this suggests a private & potentially-writable
> > area, right? That fits in nicely with an area we'd want to COW. Why the=
n
> > does check_vma_flags() use the inverse of this to indicate a shared
> > area? This fails if we have a private mapping where VM_MAYWRITE is not
> > set, but where FOLL_FORCE would otherwise provide a means of writing to
> > the memory.
> >=20
> > If I remove this check in check_vma_flags() then I have a nice simple
> > patch which seems to work well, leaving the user mapping of the delay
> > slot emulation page non-writeable. I'm not sure I'm following the mm
> > innards here though - is there something I should change about the dela=
y
> > slot page instead? Should I be marking it shared, even though it isn't
> > really? Or perhaps I'm misunderstanding what VM_MAYWRITE does & I shoul=
d
> > set that - would that allow a user to use mprotect() to make the region
> > writeable..?
>=20
> Exactly, in that last sentence above you come to the right understanding
> of VM_MAYWRITE: it allows mprotect to add VM_WRITE whenever.  So I think
> your issue in setting up the mmap, is that you're (rightly) doing it with
> VM_flags to mmap_region(), but giving it a combination of flags that an
> mmap() syscall from userspace would never arrive at, so does not match
> expectations in is_cow_mapping().  Look for VM_MAYWRITE in mm/mmap.c:
> you'll find do_mmap() first adding VM_MAYWRITE unconditionally, then
> removing it just from the case of a MAP_SHARED without FMODE_WRITE.
>=20
> > diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
> > index 48a9c6b90e07..9476efb54d18 100644
> > --- a/arch/mips/kernel/vdso.c
> > +++ b/arch/mips/kernel/vdso.c
> > @@ -126,8 +126,7 @@ int arch_setup_additional_pages(struct linux_binprm=
 *bprm, int uses_interp)
> > =20
> >  	/* Map delay slot emulation page */
> >  	base =3D mmap_region(NULL, STACK_TOP, PAGE_SIZE,
> > -			   VM_READ|VM_WRITE|VM_EXEC|
> > -			   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
> > +			   VM_READ | VM_EXEC | VM_MAYREAD | VM_MAYEXEC,
>=20
> So, remove the VM_WRITE by all means, but leave in the VM_MAYWRITE.

Thanks Hugh - it works fine when I leave in VM_MAYWRITE.

My 4am self had become convinced that it would be problematic if a user
program could mprotect() the memory & make it writable... But in reality
if a user program wants to do that then by all means, the kernel isn't
going to be able to prevent it doing silly things.

For anyone looking for the outcome, the patch I wound up with is here:

https://lore.kernel.org/linux-mips/20181220174514.24953-1-paul.burton@mips.=
com/

Thanks,
    Paul
