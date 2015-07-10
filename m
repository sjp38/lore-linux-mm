Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2B06B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 03:48:27 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so91033655pac.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 00:48:27 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id pi7si13234018pac.229.2015.07.10.00.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 00:48:26 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so179994404pdb.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 00:48:26 -0700 (PDT)
Date: Fri, 10 Jul 2015 00:48:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
In-Reply-To: <559E7023.8040203@tycho.nsa.gov>
Message-ID: <alpine.LSU.2.11.1507100013270.5082@eggly.anvils>
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils> <CAB9W1A2ekXaqHfcUxpmx_5rwxfP+wMHA17BdrA7f=Ey-rp0Lvw@mail.gmail.com> <559D51C2.7060603@tycho.nsa.gov> <alpine.LSU.2.11.1507090112430.2698@eggly.anvils> <559E7023.8040203@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Hugh Dickins <hughd@google.com>, Stephen Smalley <stephen.smalley@gmail.com>, Prarit Bhargava <prarit@redhat.com>, Morten Stevens <mstevens@fedoraproject.org>, Eric Sandeen <esandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Daniel Wagner <wagi@monom.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, linux-mm@kvack.org, selinux <selinux@tycho.nsa.gov>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Thu, 9 Jul 2015, Stephen Smalley wrote:
> On 07/09/2015 04:23 AM, Hugh Dickins wrote:
> > On Wed, 8 Jul 2015, Stephen Smalley wrote:
> >> On 07/08/2015 09:13 AM, Stephen Smalley wrote:
> >>> On Sun, Jun 14, 2015 at 12:48 PM, Hugh Dickins <hughd@google.com> wrote:
> >>>> It appears that, at some point last year, XFS made directory handling
> >>>> changes which bring it into lockdep conflict with shmem_zero_setup():
> >>>> it is surprising that mmap() can clone an inode while holding mmap_sem,
> >>>> but that has been so for many years.
> >>>>
> >>>> Since those few lockdep traces that I've seen all implicated selinux,
> >>>> I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
> >>>> v3.13's commit c7277090927a ("security: shmem: implement kernel private
> >>>> shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
> >>>> the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
> >>>>
> >>>> This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
> >>>> (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
> >>>> which cloned inode in mmap(), but if so, I cannot locate them now.
> >>>
> >>> This causes a regression for SELinux (please, in the future, cc
> >>> selinux list and Paul Moore on SELinux-related changes).  In
> > 
> > Surprised and sorry about that, yes, I should have Cc'ed.
> > 
> >>> particular, this change disables SELinux checking of mprotect
> >>> PROT_EXEC on shared anonymous mappings, so we lose the ability to
> >>> control executable mappings.  That said, we are only getting that
> >>> check today as a side effect of our file execute check on the tmpfs
> >>> inode, whereas it would be better (and more consistent with the
> >>> mmap-time checks) to apply an execmem check in that case, in which
> >>> case we wouldn't care about the inode-based check.  However, I am
> >>> unclear on how to correctly detect that situation from
> >>> selinux_file_mprotect() -> file_map_prot_check(), because we do have a
> >>> non-NULL vma->vm_file so we treat it as a file execute check.  In
> >>> contrast, if directly creating an anonymous shared mapping with
> >>> PROT_EXEC via mmap(...PROT_EXEC...),  selinux_mmap_file is called with
> >>> a NULL file and therefore we end up applying an execmem check.
> > 
> > If you're willing to go forward with the change, rather than just call
> > for an immediate revert of it, then I think the right way to detect
> > the situation would be to check IS_PRIVATE(file_inode(vma->vm_file)),
> > wouldn't it?
> 
> That seems misleading and might trigger execmem checks on non-shmem
> inodes.  S_PRIVATE was originally introduced for fs-internal inodes that
> are never directly exposed to userspace, originally for reiserfs xattr
> inodes (reiserfs xattrs are internally implemented as their own files
> that are hidden from userspace) and later also applied to anon inodes.
> It would be better if we had an explicit way of testing that we are
> dealing with an anonymous shared mapping in selinux_file_mprotect() ->
> file_map_prot_check().

But how would any of those original S_PRIVATE inodes arrive at
selinux_file_mprotect()?  Now we have added the anon shared mmap case
which can arrive there, but the S_PRIVATE check seems just the right
tool for the job of distinguishing those from the user-visible inodes.

I don't see how adding some other flag for this case would be better
- though certainly I can see that adding an "anon shared shmem"
comment on its use in that check would be helpful.

Or is there some further difficulty in this use of S_PRIVATE, beyond
the mprotect case that you've mentioned?  Unless there is some further
difficulty, duplicating all the code relating to S_PRIVATE for a
differently named flag seems counter-productive to me.

(There is a bool shmem_mapping(mapping) that could be used to confirm
that the inode you're looking at indeed belongs to shmem; but of
course that would say yes on all the user-visible shmem inodes too,
so it wouldn't be a useful test on its own, and I don't see that
adding it to an S_PRIVATE test would add any real value.)

Probably you were hoping that there's already some distinguishing
feature of anon shared shmem inodes that you could check: I can't
think of one offhand, beyond S_PRIVATE: if there is another,
it would be accidental.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
