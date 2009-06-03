Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8E1F46B005A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 16:16:04 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so59273rvb.6
        for <linux-mm@kvack.org>; Wed, 03 Jun 2009 13:16:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0906031602250.20254@gentwo.org>
References: <20090530230022.GO6535@oblivion.subreption.com>
	 <alpine.LFD.2.01.0906031109150.4880@localhost.localdomain>
	 <20090603183939.GC18561@oblivion.subreption.com>
	 <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain>
	 <alpine.LFD.2.01.0906031145460.4880@localhost.localdomain>
	 <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
	 <7e0fb38c0906031214lf4a2ed2x688da299e8cb1034@mail.gmail.com>
	 <alpine.DEB.1.10.0906031537110.20254@gentwo.org>
	 <7e0fb38c0906031251h6844ea08y2dbfa09a7f46eb5f@mail.gmail.com>
	 <alpine.DEB.1.10.0906031602250.20254@gentwo.org>
Date: Wed, 3 Jun 2009 16:16:02 -0400
Message-ID: <7e0fb38c0906031316n7aeed974xf15f8af5a3b04f63@mail.gmail.com>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
	ZERO_SIZE_PTR to point at unmapped space)
From: Eric Paris <eparis@parisplace.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu, jmorris@namei.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 3, 2009 at 4:04 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Wed, 3 Jun 2009, Eric Paris wrote:
>
>> The 'right'est fix is as Alan suggested, duplicate the code
>>
>> from security/capability.c::cap_file_mmap()
>> to include/linux/security.h::securitry_file_mmap()
>
> Thats easy to do but isnt it a bit weird now to configure mmap_min_addr?

??

> A security model may give it a different interpretation?

Not sure what you mean.  Yes, each security model is allowed to decide
what permissions are needed to pass a given security check.  SELinux
decided that CAP_SYS_RAWIO was not needed, but the selinux permission
mmap_zero was.  Had there been a more specific capability to use
SELinux might have been happy using a capability...

> What about round_hint_to_min()?

not sure what you mean....

>
> Use mmap_min_addr indepedently of security models
>
> This patch removes the dependency of mmap_min_addr on CONFIG_SECURITY.
> It also sets a default mmap_min_addr of 4096.
>
> mmapping of addresses below 4096 will only be possible for processes
> with CAP_SYS_RAWIO.

<pedantic nit> "or the appropriate permission for the given LSM </pedantic =
nit>

> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Clearly lots more cleanup can be done between CONFIG_SECURITY and
!CONFIG_SECURITY like Linus suggested, but

Acked-by: Eric Paris <eparis@redhat.com>

> ---
> =A0include/linux/mm.h =A0 =A0 =A0 | =A0 =A02 --
> =A0include/linux/security.h | =A0 =A02 ++
> =A0kernel/sysctl.c =A0 =A0 =A0 =A0 =A0| =A0 =A02 --
> =A0mm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 19 +++++++++++++++++++
> =A0mm/mmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +++
> =A0security/Kconfig =A0 =A0 =A0 =A0 | =A0 20 --------------------
> =A0security/security.c =A0 =A0 =A0| =A0 =A03 ---
> =A07 files changed, 24 insertions(+), 27 deletions(-)
>
> Index: linux-2.6/include/linux/mm.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/include/linux/mm.h =A0 2009-06-03 15:00:54.000000000 -=
0500
> +++ linux-2.6/include/linux/mm.h =A0 =A0 =A0 =A02009-06-03 15:00:56.00000=
0000 -0500
> @@ -580,12 +580,10 @@ static inline void set_page_links(struct
> =A0*/
> =A0static inline unsigned long round_hint_to_min(unsigned long hint)
> =A0{
> -#ifdef CONFIG_SECURITY
> =A0 =A0 =A0 =A0hint &=3D PAGE_MASK;
> =A0 =A0 =A0 =A0if (((void *)hint !=3D NULL) &&
> =A0 =A0 =A0 =A0 =A0 =A0(hint < mmap_min_addr))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return PAGE_ALIGN(mmap_min_addr);
> -#endif
> =A0 =A0 =A0 =A0return hint;
> =A0}
>
> Index: linux-2.6/kernel/sysctl.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/kernel/sysctl.c =A0 =A0 =A02009-06-03 15:00:54.0000000=
00 -0500
> +++ linux-2.6/kernel/sysctl.c =A0 2009-06-03 15:00:56.000000000 -0500
> @@ -1225,7 +1225,6 @@ static struct ctl_table vm_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.strategy =A0 =A0 =A0 =3D &sysctl_jiffies,
> =A0 =A0 =A0 =A0},
> =A0#endif
> -#ifdef CONFIG_SECURITY
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.ctl_name =A0 =A0 =A0 =3D CTL_UNNUMBERED,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "mmap_min_addr",
> @@ -1234,7 +1233,6 @@ static struct ctl_table vm_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.proc_handler =A0 =3D &proc_doulongvec_min=
max,
> =A0 =A0 =A0 =A0},
> -#endif
> =A0#ifdef CONFIG_NUMA
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.ctl_name =A0 =A0 =A0 =3D CTL_UNNUMBERED,
> Index: linux-2.6/mm/mmap.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/mmap.c =A0 =A02009-06-03 15:00:54.000000000 -0500
> +++ linux-2.6/mm/mmap.c 2009-06-03 15:01:18.000000000 -0500
> @@ -87,6 +87,9 @@ int sysctl_overcommit_ratio =3D 50; =A0 =A0 /* def
> =A0int sysctl_max_map_count __read_mostly =3D DEFAULT_MAX_MAP_COUNT;
> =A0struct percpu_counter vm_committed_as;
>
> +/* amount of vm to protect from userspace access */
> +unsigned long mmap_min_addr =3D CONFIG_DEFAULT_MMAP_MIN_ADDR;
> +
> =A0/*
> =A0* Check that a process has enough memory to allocate a new virtual
> =A0* mapping. 0 means there is enough memory for the allocation to
> Index: linux-2.6/security/security.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/security/security.c =A02009-06-03 15:00:54.000000000 -=
0500
> +++ linux-2.6/security/security.c =A0 =A0 =A0 2009-06-03 15:00:56.0000000=
00 -0500
> @@ -26,9 +26,6 @@ extern void security_fixup_ops(struct se
>
> =A0struct security_operations *security_ops; =A0 =A0 =A0/* Initialized to=
 NULL */
>
> -/* amount of vm to protect from userspace access */
> -unsigned long mmap_min_addr =3D CONFIG_SECURITY_DEFAULT_MMAP_MIN_ADDR;
> -
> =A0static inline int verify(struct security_operations *ops)
> =A0{
> =A0 =A0 =A0 =A0/* verify the security_operations structure exists */
> Index: linux-2.6/mm/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/Kconfig =A0 2009-06-03 15:00:54.000000000 -0500
> +++ linux-2.6/mm/Kconfig =A0 =A0 =A0 =A02009-06-03 15:00:56.000000000 -05=
00
> @@ -226,6 +226,25 @@ config HAVE_MLOCKED_PAGE_BIT
> =A0config MMU_NOTIFIER
> =A0 =A0 =A0 =A0bool
>
> +config DEFAULT_MMAP_MIN_ADDR
> + =A0 =A0 =A0 =A0int "Low address space to protect from user allocation"
> + =A0 =A0 =A0 =A0default 4096
> + =A0 =A0 =A0 =A0help
> + =A0 =A0 =A0 =A0 This is the portion of low virtual memory which should =
be protected
> + =A0 =A0 =A0 =A0 from userspace allocation. =A0Keeping a user from writi=
ng to low pages
> + =A0 =A0 =A0 =A0 can help reduce the impact of kernel NULL pointer bugs.
> +
> + =A0 =A0 =A0 =A0 For most ia64, ppc64 and x86 users with lots of address=
 space
> + =A0 =A0 =A0 =A0 a value of 65536 is reasonable and should cause no prob=
lems.
> + =A0 =A0 =A0 =A0 On arm and other archs it should not be higher than 327=
68.
> + =A0 =A0 =A0 =A0 Programs which use vm86 functionality would either need=
 additional
> + =A0 =A0 =A0 =A0 permissions from either the LSM or the capabilities mod=
ule or have
> + =A0 =A0 =A0 =A0 this protection disabled.
> +
> + =A0 =A0 =A0 =A0 This value can be changed after boot using the
> + =A0 =A0 =A0 =A0 /proc/sys/vm/mmap_min_addr tunable.
> +
> +
> =A0config NOMMU_INITIAL_TRIM_EXCESS
> =A0 =A0 =A0 =A0int "Turn on mmap() excess space trimming before booting"
> =A0 =A0 =A0 =A0depends on !MMU
> Index: linux-2.6/security/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/security/Kconfig =A0 =A0 2009-06-03 15:00:54.000000000=
 -0500
> +++ linux-2.6/security/Kconfig =A02009-06-03 15:00:56.000000000 -0500
> @@ -113,26 +113,6 @@ config SECURITY_ROOTPLUG
>
> =A0 =A0 =A0 =A0 =A0If you are unsure how to answer this question, answer =
N.
>
> -config SECURITY_DEFAULT_MMAP_MIN_ADDR
> - =A0 =A0 =A0 =A0int "Low address space to protect from user allocation"
> - =A0 =A0 =A0 =A0depends on SECURITY
> - =A0 =A0 =A0 =A0default 0
> - =A0 =A0 =A0 =A0help
> - =A0 =A0 =A0 =A0 This is the portion of low virtual memory which should =
be protected
> - =A0 =A0 =A0 =A0 from userspace allocation. =A0Keeping a user from writi=
ng to low pages
> - =A0 =A0 =A0 =A0 can help reduce the impact of kernel NULL pointer bugs.
> -
> - =A0 =A0 =A0 =A0 For most ia64, ppc64 and x86 users with lots of address=
 space
> - =A0 =A0 =A0 =A0 a value of 65536 is reasonable and should cause no prob=
lems.
> - =A0 =A0 =A0 =A0 On arm and other archs it should not be higher than 327=
68.
> - =A0 =A0 =A0 =A0 Programs which use vm86 functionality would either need=
 additional
> - =A0 =A0 =A0 =A0 permissions from either the LSM or the capabilities mod=
ule or have
> - =A0 =A0 =A0 =A0 this protection disabled.
> -
> - =A0 =A0 =A0 =A0 This value can be changed after boot using the
> - =A0 =A0 =A0 =A0 /proc/sys/vm/mmap_min_addr tunable.
> -
> -
> =A0source security/selinux/Kconfig
> =A0source security/smack/Kconfig
> =A0source security/tomoyo/Kconfig
> Index: linux-2.6/include/linux/security.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/include/linux/security.h =A0 =A0 2009-06-03 15:01:28.0=
00000000 -0500
> +++ linux-2.6/include/linux/security.h =A02009-06-03 15:01:42.000000000 -=
0500
> @@ -2197,6 +2197,8 @@ static inline int security_file_mmap(str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u=
nsigned long addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u=
nsigned long addr_only)
> =A0{
> + =A0 =A0 =A0 if ((addr < mmap_min_addr) && !capable(CAP_SYS_RAWIO))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EACCES;
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
