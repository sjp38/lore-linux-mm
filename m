Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 198746B0254
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 04:24:09 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so146656084pab.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:24:08 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id g14si8074286pdf.174.2015.07.09.01.24.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 01:24:08 -0700 (PDT)
Received: by pacgz10 with SMTP id gz10so73387326pac.3
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:24:07 -0700 (PDT)
Date: Thu, 9 Jul 2015 01:23:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
In-Reply-To: <559D51C2.7060603@tycho.nsa.gov>
Message-ID: <alpine.LSU.2.11.1507090112430.2698@eggly.anvils>
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils> <CAB9W1A2ekXaqHfcUxpmx_5rwxfP+wMHA17BdrA7f=Ey-rp0Lvw@mail.gmail.com> <559D51C2.7060603@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Stephen Smalley <stephen.smalley@gmail.com>, Hugh Dickins <hughd@google.com>, Prarit Bhargava <prarit@redhat.com>, Morten Stevens <mstevens@fedoraproject.org>, Eric Sandeen <esandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Daniel Wagner <wagi@monom.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, linux-mm@kvack.org, selinux <selinux@tycho.nsa.gov>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 8 Jul 2015, Stephen Smalley wrote:
> On 07/08/2015 09:13 AM, Stephen Smalley wrote:
> > On Sun, Jun 14, 2015 at 12:48 PM, Hugh Dickins <hughd@google.com> wrote:
> >> It appears that, at some point last year, XFS made directory handling
> >> changes which bring it into lockdep conflict with shmem_zero_setup():
> >> it is surprising that mmap() can clone an inode while holding mmap_sem,
> >> but that has been so for many years.
> >>
> >> Since those few lockdep traces that I've seen all implicated selinux,
> >> I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
> >> v3.13's commit c7277090927a ("security: shmem: implement kernel private
> >> shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
> >> the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
> >>
> >> This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
> >> (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
> >> which cloned inode in mmap(), but if so, I cannot locate them now.
> > 
> > This causes a regression for SELinux (please, in the future, cc
> > selinux list and Paul Moore on SELinux-related changes).  In

Surprised and sorry about that, yes, I should have Cc'ed.

> > particular, this change disables SELinux checking of mprotect
> > PROT_EXEC on shared anonymous mappings, so we lose the ability to
> > control executable mappings.  That said, we are only getting that
> > check today as a side effect of our file execute check on the tmpfs
> > inode, whereas it would be better (and more consistent with the
> > mmap-time checks) to apply an execmem check in that case, in which
> > case we wouldn't care about the inode-based check.  However, I am
> > unclear on how to correctly detect that situation from
> > selinux_file_mprotect() -> file_map_prot_check(), because we do have a
> > non-NULL vma->vm_file so we treat it as a file execute check.  In
> > contrast, if directly creating an anonymous shared mapping with
> > PROT_EXEC via mmap(...PROT_EXEC...),  selinux_mmap_file is called with
> > a NULL file and therefore we end up applying an execmem check.

If you're willing to go forward with the change, rather than just call
for an immediate revert of it, then I think the right way to detect
the situation would be to check IS_PRIVATE(file_inode(vma->vm_file)),
wouldn't it?

> 
> Also, can you provide the lockdep traces that motivated this change?

Thank you for supplying that, Morten.

> 
> > 
> >>
> >> Reported-and-tested-by: Prarit Bhargava <prarit@redhat.com>
> >> Reported-by: Daniel Wagner <wagi@monom.org>
> >> Reported-by: Morten Stevens <mstevens@fedoraproject.org>
> >> Signed-off-by: Hugh Dickins <hughd@google.com>
> >> ---
> >>
> >>  mm/shmem.c |    8 +++++++-
> >>  1 file changed, 7 insertions(+), 1 deletion(-)
> >>
> >> --- 4.1-rc7/mm/shmem.c  2015-04-26 19:16:31.352191298 -0700
> >> +++ linux/mm/shmem.c    2015-06-14 09:26:49.461120166 -0700
> >> @@ -3401,7 +3401,13 @@ int shmem_zero_setup(struct vm_area_stru
> >>         struct file *file;
> >>         loff_t size = vma->vm_end - vma->vm_start;
> >>
> >> -       file = shmem_file_setup("dev/zero", size, vma->vm_flags);
> >> +       /*
> >> +        * Cloning a new file under mmap_sem leads to a lock ordering conflict
> >> +        * between XFS directory reading and selinux: since this file is only
> >> +        * accessible to the user through its mapping, use S_PRIVATE flag to
> >> +        * bypass file security, in the same way as shmem_kernel_file_setup().
> >> +        */
> >> +       file = __shmem_file_setup("dev/zero", size, vma->vm_flags, S_PRIVATE);
> >>         if (IS_ERR(file))
> >>                 return PTR_ERR(file);
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> Please read the FAQ at  http://www.tux.org/lkml/
> > _______________________________________________
> > Selinux mailing list
> > Selinux@tycho.nsa.gov
> > To unsubscribe, send email to Selinux-leave@tycho.nsa.gov.
> > To get help, send an email containing "help" to Selinux-request@tycho.nsa.gov.
> > 
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
