Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FEEC6B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 06:17:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id d4-v6so9255099wrn.15
        for <linux-mm@kvack.org>; Mon, 14 May 2018 03:17:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f44-v6si716570eda.334.2018.05.14.03.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 03:17:53 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4EAFEYc017999
	for <linux-mm@kvack.org>; Mon, 14 May 2018 06:17:52 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hy5h5039r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 May 2018 06:17:51 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Mon, 14 May 2018 11:17:50 +0100
Date: Mon, 14 May 2018 12:17:46 +0200
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
In-Reply-To: <CAGqmi75jpOq+PufXb+O3pLwm4esgh8OBHRuTegivwpt2La8hoA@mail.gmail.com>
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
	<20180418193220.4603-3-timofey.titovets@synesis.ru>
	<20180508172606.249583c0@p-imbrenda.boeblingen.de.ibm.com>
	<CAGqmi75jpOq+PufXb+O3pLwm4esgh8OBHRuTegivwpt2La8hoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Message-Id: <20180514121746.6455b234@p-imbrenda.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: linux-mm@kvack.org, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

On Sat, 12 May 2018 02:06:20 +0300
Timofey Titovets <nefelim4ag@gmail.com> wrote:

> =D0=B2=D1=82, 8 =D0=BC=D0=B0=D1=8F 2018 =D0=B3. =D0=B2 18:26, Claudio Imb=
renda
> <imbrenda@linux.vnet.ibm.com>:
>=20
> > On Wed, 18 Apr 2018 22:32:20 +0300
> > Timofey Titovets <nefelim4ag@gmail.com> wrote: =20
>=20
> > > From: Timofey Titovets <nefelim4ag@gmail.com>
> > >
> > > 1. Pickup, Sioh Lee crc32 patch, after some long conversation
> > > 2. Merge with my work on xxhash
> > > 3. Add autoselect code to choice fastest hash helper.
> > >
> > > Base idea are same, replace jhash2 with something faster.
> > >
> > > Perf numbers:
> > > Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz
> > > ksm: crc32c   hash() 12081 MB/s
> > > ksm: xxh64    hash()  8770 MB/s
> > > ksm: xxh32    hash()  4529 MB/s
> > > ksm: jhash2   hash()  1569 MB/s
> > >
> > > As jhash2 always will be slower (for data size like PAGE_SIZE),
> > > just drop it from choice.
> > >
> > > Add function to autoselect hash algo on boot,
> > > based on hashing speed, like raid6 code does.
> > >
> > > Move init of zero_checksum from init, to first call of fasthash():
> > >   1. KSM Init run on early kernel init,
> > >      run perf testing stuff on main kernel boot thread looks bad
> > > to =20
>=20
> > This is my personal opinion, but I think it would be better and more
> > uniform to have it during boot like raid6. It doesn't take too much
> > time, and it allows to see immediately in dmesg what is going on. =20
>=20
> I don't like such things at boot, that will slowdown boot and add
> useless work in *MOST* cases.
>=20
> ex. Anyone who use btrfs as rootfs must wait raid6_pq init, for mount.
> Even if they didn't use raid56 functionality.
>=20
> Same for ksm, who use ksm? I think that 90% of users currently
> are servers with KVM's VMs.
>=20
> i.e. i don't think that you use it on your notebook,
> and add 250ms to every bootup, even, if you did not use ksm
> looks as bad idea for me.
>=20
> And as that a mm subsystem, that will lead to *every linux device in
> the world*
> with compiled in ksm, will spend time and energy to ksm init.

fair enough

> > > me. 2. Crypto subsystem not avaliable at that early booting,
> > >      so crc32c even, compiled in, not avaliable
> > >      As crypto and ksm init, run at subsys_initcall() (4) kernel
> > > level of init, all possible consumers will run later at 5+
> > > levels =20
>=20
> > have you tried moving ksm to a later stage? before commit
> > a64fb3cd610c8e680 KSM was in fact initialized at level 6. After
> > all, KSM cannot be triggered until userspace starts. =20
>=20
> Of course and that works,
> but i didn't have sufficient competence,
> to suggest such changes.
>=20
> > > Output after first try of KSM to hash page:
> > > ksm: crc32c hash() 15218 MB/s
> > > ksm: xxhash hash()  8640 MB/s
> > > ksm: choice crc32c as hash function
> > >
> > > Thanks.
> > >
> > > Changes:
> > >   v1 -> v2:
> > >     - Move xxhash() to xxhash.h/c and separate patches
> > >   v2 -> v3:
> > >     - Move xxhash() xxhash.c -> xxhash.h
> > >     - replace xxhash_t with 'unsigned long'
> > >     - update kerneldoc above xxhash()
> > >   v3 -> v4:
> > >     - Merge xxhash/crc32 patches
> > >     - Replace crc32 with crc32c (crc32 have same as jhash2 speed)
> > >     - Add auto speed test and auto choice of fastest hash function
> > >   v4 -> v5:
> > >     - Pickup missed xxhash patch
> > >     - Update code with compile time choicen xxhash
> > >     - Add more macros to make code more readable
> > >     - As now that only possible use xxhash or crc32c,
> > >       on crc32c allocation error, skip speed test and fallback to
> > > xxhash
> > >     - For workaround too early init problem (crc32c not
> > > avaliable), move zero_checksum init to first call of fastcall()
> > >     - Don't alloc page for hash testing, use arch zero pages for
> > > that v5 -> v6:
> > >     - Use libcrc32c instead of CRYPTO API, mainly for
> > >       code/Kconfig deps Simplification
> > >     - Add crc32c_available():
> > >       libcrc32c will BUG_ON on crc32c problems,
> > >       so test crc32c avaliable by crc32c_available()
> > >     - Simplify choice_fastest_hash()
> > >     - Simplify fasthash()
> > >     - struct rmap_item && stable_node have sizeof =3D=3D 64 on x86_64,
> > >       that makes them cache friendly. As we don't suffer from hash
> > > collisions, change hash type from unsigned long back to u32.
> > >     - Fix kbuild robot warning, make all local functions static
> > >
> > > Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
> > > Signed-off-by: leesioh <solee@os.korea.ac.kr>
> > > CC: Andrea Arcangeli <aarcange@redhat.com>
> > > CC: linux-mm@kvack.org
> > > CC: kvm@vger.kernel.org
> > > ---
> > >  mm/Kconfig |  2 ++
> > >  mm/ksm.c   | 93
> > > +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--- 2
> > > files changed, 91 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/mm/Kconfig b/mm/Kconfig
> > > index 03ff7703d322..b60bee4bb07e 100644
> > > --- a/mm/Kconfig
> > > +++ b/mm/Kconfig
> > > @@ -305,6 +305,8 @@ config MMU_NOTIFIER
> > >  config KSM
> > >       bool "Enable KSM for page merging"
> > >       depends on MMU
> > > +     select XXHASH
> > > +     select LIBCRC32C
> > >       help
> > >         Enable Kernel Samepage Merging: KSM periodically scans
> > > those areas of an application's address space that an app has
> > > advised may be diff --git a/mm/ksm.c b/mm/ksm.c
> > > index c406f75957ad..2b84407fb918 100644
> > > --- a/mm/ksm.c
> > > +++ b/mm/ksm.c
> > > @@ -25,7 +25,6 @@
> > >  #include <linux/pagemap.h>
> > >  #include <linux/rmap.h>
> > >  #include <linux/spinlock.h>
> > > -#include <linux/jhash.h>
> > >  #include <linux/delay.h>
> > >  #include <linux/kthread.h>
> > >  #include <linux/wait.h>
> > > @@ -41,6 +40,13 @@
> > >  #include <linux/numa.h>
> > >
> > >  #include <asm/tlbflush.h>
> > > +
> > > +/* Support for xxhash and crc32c */
> > > +#include <crypto/hash.h>
> > > +#include <linux/crc32c.h>
> > > +#include <linux/xxhash.h>
> > > +#include <linux/sizes.h>
> > > +
> > >  #include "internal.h"
> > >
> > >  #ifdef CONFIG_NUMA
> > > @@ -284,6 +290,87 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
> > >               sizeof(struct __struct), __alignof__(struct
> > > __struct),\ (__flags), NULL)
> > >
> > > +#define TIME_125MS  (HZ >> 3)
> > > +#define PERF_TO_MBS(X) (X*PAGE_SIZE*(1 << 3)/(SZ_1M))
> > > +
> > > +#define HASH_NONE   0
> > > +#define HASH_CRC32C 1
> > > +#define HASH_XXHASH 2
> > > +
> > > +static int fastest_hash =3D HASH_NONE;
> > > +
> > > +static bool __init crc32c_available(void)
> > > +{
> > > +     static struct shash_desc desc;
> > > +
> > > +     desc.tfm =3D crypto_alloc_shash("crc32c", 0, 0); =20
>=20
> > will this work without the crypto api? =20
>=20
> I didn't know a way to compile kernel without crypto api,
> To many different sub systems depends on him,
> if i read Kconfig correctly of course.

I'm confused here. Why did you want to drop the dependency on the
crypto API in Kconfig if you are using it anyway? Or did I
misunderstand?

> > > +     desc.flags =3D 0;
> > > +
> > > +     if (IS_ERR(desc.tfm)) {
> > > +             pr_warn("ksm: alloc crc32c shash error %ld\n",
> > > +                     -PTR_ERR(desc.tfm));
> > > +             return false;
> > > +     }
> > > +
> > > +     crypto_free_shash(desc.tfm);
> > > +     return true;
> > > +}
> > > +
> > > +static void __init choice_fastest_hash(void) =20
>=20
> > s/choice/choose/ =20
>=20
> > > +{
> > > +
> > > +     unsigned long je;
> > > +     unsigned long perf_crc32c =3D 0;
> > > +     unsigned long perf_xxhash =3D 0;
> > > +
> > > +     fastest_hash =3D HASH_XXHASH;
> > > +     if (!crc32c_available())
> > > +             goto out;
> > > +
> > > +     preempt_disable();
> > > +     je =3D jiffies + TIME_125MS;
> > > +     while (time_before(jiffies, je)) {
> > > +             crc32c(0, ZERO_PAGE(0), PAGE_SIZE);
> > > +             perf_crc32c++;
> > > +     }
> > > +     preempt_enable();
> > > +
> > > +     preempt_disable();
> > > +     je =3D jiffies + TIME_125MS;
> > > +     while (time_before(jiffies, je)) {
> > > +             xxhash(ZERO_PAGE(0), PAGE_SIZE, 0);
> > > +             perf_xxhash++;
> > > +     }
> > > +     preempt_enable();
> > > +
> > > +     pr_info("ksm: crc32c hash() %5ld MB/s\n",
> > > PERF_TO_MBS(perf_crc32c));
> > > +     pr_info("ksm: xxhash hash() %5ld MB/s\n",
> > > PERF_TO_MBS(perf_xxhash)); +
> > > +     if (perf_crc32c > perf_xxhash)
> > > +             fastest_hash =3D HASH_CRC32C;
> > > +out:
> > > +     if (fastest_hash =3D=3D HASH_CRC32C)
> > > +             pr_info("ksm: choice crc32c as hash function\n");
> > > +     else
> > > +             pr_info("ksm: choice xxhash as hash function\n");
> > > +} =20
>=20
> > I wonder if this can be generalized to have a list of possible hash
> > functions, filtered by availability, and then tested for
> > performance, more like the raid6 functions. =20
>=20
> IIRC:
> We was talk about that on old version of patch set.
> And we decide what:
>   - in ideal situation, ksm must use only one hash function, always.
>     But, we afraid about that crc32c with hardware acceleration, can
> be missed by some way.
>     So, as appropriate fallback, xxhash added, as general proporse,
> which must work
>     good enough for ksm in most cases.
>=20
> So adding more complex logic, like raid6_pq have with all of different
> instruction set are overkill.

fair enough

> > > +
> > > +static u32 fasthash(const void *input, size_t length)
> > > +{
> > > +again:
> > > +     switch (fastest_hash) {
> > > +     case HASH_CRC32C:
> > > +             return crc32c(0, input, length);
> > > +     case HASH_XXHASH:
> > > +             return xxhash(input, length, 0);
> > > +     default:
> > > +             choice_fastest_hash(); =20
>=20
> > same here s/choice/choose/ =20
>=20
> > > +             /* The correct value depends on page size and
> > > endianness */
> > > +             zero_checksum =3D fasthash(ZERO_PAGE(0), PAGE_SIZE);
> > > +             goto again;
> > > +     }
> > > +}
> > > + =20
>=20
> > so if I understand correctly, the benchmark function will be called
> > only when the function is called for the first time? =20
>=20
> yes, that is.
> That a little bit tricky,
> but it's will be called only from KSM thread,
> and only what KSM thread will try do some useful work.
>=20
> So that must not block anything.
>=20
> Thanks.


best regards

Claudio Imbrenda
