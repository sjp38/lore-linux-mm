Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 89A706B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 09:00:23 -0400 (EDT)
Received: by qkcl188 with SMTP id l188so1771893qkc.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 06:00:23 -0700 (PDT)
Received: from emvm-gh1-uea09.nsa.gov (emvm-gh1-uea09.nsa.gov. [63.239.67.10])
        by mx.google.com with ESMTP id r82si5946756qkh.74.2015.07.09.06.00.20
        for <linux-mm@kvack.org>;
        Thu, 09 Jul 2015 06:00:21 -0700 (PDT)
Message-ID: <559E7023.8040203@tycho.nsa.gov>
Date: Thu, 09 Jul 2015 08:59:15 -0400
From: Stephen Smalley <sds@tycho.nsa.gov>
MIME-Version: 1.0
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils> <CAB9W1A2ekXaqHfcUxpmx_5rwxfP+wMHA17BdrA7f=Ey-rp0Lvw@mail.gmail.com> <559D51C2.7060603@tycho.nsa.gov> <alpine.LSU.2.11.1507090112430.2698@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1507090112430.2698@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Stephen Smalley <stephen.smalley@gmail.com>, Prarit Bhargava <prarit@redhat.com>, Morten Stevens <mstevens@fedoraproject.org>, Eric Sandeen <esandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Daniel Wagner <wagi@monom.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, linux-mm@kvack.org, selinux <selinux@tycho.nsa.gov>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On 07/09/2015 04:23 AM, Hugh Dickins wrote:
> On Wed, 8 Jul 2015, Stephen Smalley wrote:
>> On 07/08/2015 09:13 AM, Stephen Smalley wrote:
>>> On Sun, Jun 14, 2015 at 12:48 PM, Hugh Dickins <hughd@google.com> wrote:
>>>> It appears that, at some point last year, XFS made directory handling
>>>> changes which bring it into lockdep conflict with shmem_zero_setup():
>>>> it is surprising that mmap() can clone an inode while holding mmap_sem,
>>>> but that has been so for many years.
>>>>
>>>> Since those few lockdep traces that I've seen all implicated selinux,
>>>> I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
>>>> v3.13's commit c7277090927a ("security: shmem: implement kernel private
>>>> shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
>>>> the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
>>>>
>>>> This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
>>>> (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
>>>> which cloned inode in mmap(), but if so, I cannot locate them now.
>>>
>>> This causes a regression for SELinux (please, in the future, cc
>>> selinux list and Paul Moore on SELinux-related changes).  In
> 
> Surprised and sorry about that, yes, I should have Cc'ed.
> 
>>> particular, this change disables SELinux checking of mprotect
>>> PROT_EXEC on shared anonymous mappings, so we lose the ability to
>>> control executable mappings.  That said, we are only getting that
>>> check today as a side effect of our file execute check on the tmpfs
>>> inode, whereas it would be better (and more consistent with the
>>> mmap-time checks) to apply an execmem check in that case, in which
>>> case we wouldn't care about the inode-based check.  However, I am
>>> unclear on how to correctly detect that situation from
>>> selinux_file_mprotect() -> file_map_prot_check(), because we do have a
>>> non-NULL vma->vm_file so we treat it as a file execute check.  In
>>> contrast, if directly creating an anonymous shared mapping with
>>> PROT_EXEC via mmap(...PROT_EXEC...),  selinux_mmap_file is called with
>>> a NULL file and therefore we end up applying an execmem check.
> 
> If you're willing to go forward with the change, rather than just call
> for an immediate revert of it, then I think the right way to detect
> the situation would be to check IS_PRIVATE(file_inode(vma->vm_file)),
> wouldn't it?

That seems misleading and might trigger execmem checks on non-shmem
inodes.  S_PRIVATE was originally introduced for fs-internal inodes that
are never directly exposed to userspace, originally for reiserfs xattr
inodes (reiserfs xattrs are internally implemented as their own files
that are hidden from userspace) and later also applied to anon inodes.
It would be better if we had an explicit way of testing that we are
dealing with an anonymous shared mapping in selinux_file_mprotect() ->
file_map_prot_check().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
