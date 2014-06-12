Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id BF86E900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 01:49:06 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so2264528wiw.5
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 22:49:06 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id fq10si1358323wib.45.2014.06.11.22.49.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 22:49:05 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so914185wiv.10
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 22:49:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1399552888-11024-2-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1399552888-11024-2-git-send-email-kirill.shutemov@linux.intel.com>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Thu, 12 Jun 2014 07:48:44 +0200
Message-ID: <CAHO5Pa31WVrtG+2hU1grbLHiEPjkM_eB4JgSStskX8AvDjQRKA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: mark remap_file_pages() syscall as deprecated
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Linux API <linux-api@vger.kernel.org>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>

Hi Kirill,

On Thu, May 8, 2014 at 2:41 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> The remap_file_pages() system call is used to create a nonlinear mapping,
> that is, a mapping in which the pages of the file are mapped into a
> nonsequential order in memory. The advantage of using remap_file_pages()
> over using repeated calls to mmap(2) is that the former approach does not
> require the kernel to create additional VMA (Virtual Memory Area) data
> structures.
>
> Supporting of nonlinear mapping requires significant amount of non-trivia=
l
> code in kernel virtual memory subsystem including hot paths. Also to get
> nonlinear mapping work kernel need a way to distinguish normal page table
> entries from entries with file offset (pte_file). Kernel reserves flag in
> PTE for this purpose. PTE flags are scarce resource especially on some CP=
U
> architectures. It would be nice to free up the flag for other usage.
>
> Fortunately, there are not many users of remap_file_pages() in the wild.
> It's only known that one enterprise RDBMS implementation uses the syscall
> on 32-bit systems to map files bigger than can linearly fit into 32-bit
> virtual address space. This use-case is not critical anymore since 64-bit
> systems are widely available.
>
> The plan is to deprecate the syscall and replace it with an emulation.
> The emulation will create new VMAs instead of nonlinear mappings. It's
> going to work slower for rare users of remap_file_pages() but ABI is
> preserved.
>
> One side effect of emulation (apart from performance) is that user can hi=
t
> vm.max_map_count limit more easily due to additional VMAs. See comment fo=
r
> DEFAULT_MAX_MAP_COUNT for more details on the limit.

Best to CC linux-api@
(https://www.kernel.org/doc/man-pages/linux-api-ml.html) on patches
like this, as well as the man-pages maintainer, so that something goes
into the man page. I added the following into the man page:

       Note:  this  system  call  is (since Linux 3.16) deprecated and
       will eventually be replaced by a  slower  in-kernel  emulation.
       Those  few  applications  that use this system call should con=E2=80=
=90
       sider migrating to alternatives.

Okay?

Cheers,

Michael


> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  Documentation/vm/remap_file_pages.txt | 28 ++++++++++++++++++++++++++++
>  mm/fremap.c                           |  4 ++++
>  2 files changed, 32 insertions(+)
>  create mode 100644 Documentation/vm/remap_file_pages.txt
>
> diff --git a/Documentation/vm/remap_file_pages.txt b/Documentation/vm/rem=
ap_file_pages.txt
> new file mode 100644
> index 000000000000..560e4363a55d
> --- /dev/null
> +++ b/Documentation/vm/remap_file_pages.txt
> @@ -0,0 +1,28 @@
> +The remap_file_pages() system call is used to create a nonlinear mapping=
,
> +that is, a mapping in which the pages of the file are mapped into a
> +nonsequential order in memory. The advantage of using remap_file_pages()
> +over using repeated calls to mmap(2) is that the former approach does no=
t
> +require the kernel to create additional VMA (Virtual Memory Area) data
> +structures.
> +
> +Supporting of nonlinear mapping requires significant amount of non-trivi=
al
> +code in kernel virtual memory subsystem including hot paths. Also to get
> +nonlinear mapping work kernel need a way to distinguish normal page tabl=
e
> +entries from entries with file offset (pte_file). Kernel reserves flag i=
n
> +PTE for this purpose. PTE flags are scarce resource especially on some C=
PU
> +architectures. It would be nice to free up the flag for other usage.
> +
> +Fortunately, there are not many users of remap_file_pages() in the wild.
> +It's only known that one enterprise RDBMS implementation uses the syscal=
l
> +on 32-bit systems to map files bigger than can linearly fit into 32-bit
> +virtual address space. This use-case is not critical anymore since 64-bi=
t
> +systems are widely available.
> +
> +The plan is to deprecate the syscall and replace it with an emulation.
> +The emulation will create new VMAs instead of nonlinear mappings. It's
> +going to work slower for rare users of remap_file_pages() but ABI is
> +preserved.
> +
> +One side effect of emulation (apart from performance) is that user can h=
it
> +vm.max_map_count limit more easily due to additional VMAs. See comment f=
or
> +DEFAULT_MAX_MAP_COUNT for more details on the limit.
> diff --git a/mm/fremap.c b/mm/fremap.c
> index 34feba60a17e..12c3bb63b7f9 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -152,6 +152,10 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, sta=
rt, unsigned long, size,
>         int has_write_lock =3D 0;
>         vm_flags_t vm_flags =3D 0;
>
> +       pr_warn_once("%s (%d) uses depricated remap_file_pages() syscall.=
 "
> +                       "See Documentation/vm/remap_file_pages.txt.\n",
> +                       current->comm, current->pid);
> +
>         if (prot)
>                 return err;
>         /*
> --
> 2.0.0.rc2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>



--=20
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
