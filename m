Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A9DC6B008A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 15:14:54 -0400 (EDT)
Received: by pzk5 with SMTP id 5so245876pzk.12
        for <linux-mm@kvack.org>; Wed, 03 Jun 2009 12:14:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
References: <20090530230022.GO6535@oblivion.subreption.com>
	 <alpine.DEB.1.10.0906031047390.15621@gentwo.org>
	 <20090603182949.5328d411@lxorguk.ukuu.org.uk>
	 <alpine.LFD.2.01.0906031032390.4880@localhost.localdomain>
	 <20090603180037.GB18561@oblivion.subreption.com>
	 <alpine.LFD.2.01.0906031109150.4880@localhost.localdomain>
	 <20090603183939.GC18561@oblivion.subreption.com>
	 <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain>
	 <alpine.LFD.2.01.0906031145460.4880@localhost.localdomain>
	 <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
Date: Wed, 3 Jun 2009 15:14:52 -0400
Message-ID: <7e0fb38c0906031214lf4a2ed2x688da299e8cb1034@mail.gmail.com>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
	ZERO_SIZE_PTR to point at unmapped space)
From: Eric Paris <eparis@parisplace.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, Jun 3, 2009 at 2:59 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> We could just move the check for mmap_min_addr out from
> CONFIG_SECURITY?
>
>
> Use mmap_min_addr indepedently of security models
>
> This patch removes the dependency of mmap_min_addr on CONFIG_SECURITY.
> It also sets a default mmap_min_addr of 4096.
>
> mmapping of addresses below 4096 will only be possible for processes
> with CAP_SYS_RAWIO.
>
>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

NAK  with SELinux on you now need both the SELinux mmap_zero
permission and the CAP_SYS_RAWIO permission.  Previously you only
needed one or the other, depending on which was the predominant
LSM.....

Even if you want to argue that I have to take CAP_SYS_RAWIO in the
SELinux case what about all the other places?  do_mremap?  do_brk?
expand_downwards?

-Eric


> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/mmap.c =A0 =A02009-06-03 13:48:01.000000000 -0500
> +++ linux-2.6/mm/mmap.c 2009-06-03 13:48:10.000000000 -0500
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
> @@ -1043,6 +1046,9 @@ unsigned long do_mmap_pgoff(struct file
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 if ((addr < mmap_min_addr) && !capable(CAP_SYS_RAWIO))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EACCES;
> +
> =A0 =A0 =A0 =A0error =3D security_file_mmap(file, reqprot, prot, flags, a=
ddr, 0);
> =A0 =A0 =A0 =A0if (error)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
