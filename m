Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 159826B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 09:10:58 -0400 (EDT)
Received: by qkcl188 with SMTP id l188so22888788qkc.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 06:10:57 -0700 (PDT)
Received: from emvm-gh1-uea08.nsa.gov (emvm-gh1-uea08.nsa.gov. [63.239.67.9])
        by mx.google.com with ESMTP id 53si10721412qgb.16.2015.07.10.06.10.57
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 06:10:57 -0700 (PDT)
Message-ID: <559FC421.3000109@tycho.nsa.gov>
Date: Fri, 10 Jul 2015 09:09:53 -0400
From: Stephen Smalley <sds@tycho.nsa.gov>
MIME-Version: 1.0
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils> <CAB9W1A2ekXaqHfcUxpmx_5rwxfP+wMHA17BdrA7f=Ey-rp0Lvw@mail.gmail.com> <559D51C2.7060603@tycho.nsa.gov> <alpine.LSU.2.11.1507090112430.2698@eggly.anvils> <559E7023.8040203@tycho.nsa.gov> <alpine.LSU.2.11.1507100013270.5082@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1507100013270.5082@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Stephen Smalley <stephen.smalley@gmail.com>, Prarit Bhargava <prarit@redhat.com>, Morten Stevens <mstevens@fedoraproject.org>, Eric Sandeen <esandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Daniel Wagner <wagi@monom.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, linux-mm@kvack.org, selinux <selinux@tycho.nsa.gov>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On 07/10/2015 03:48 AM, Hugh Dickins wrote:
> On Thu, 9 Jul 2015, Stephen Smalley wrote:
>> On 07/09/2015 04:23 AM, Hugh Dickins wrote:
>>> On Wed, 8 Jul 2015, Stephen Smalley wrote:
>>>> On 07/08/2015 09:13 AM, Stephen Smalley wrote:
>>>>> On Sun, Jun 14, 2015 at 12:48 PM, Hugh Dickins <hughd@google.com> wrote:
>>>>>> It appears that, at some point last year, XFS made directory handling
>>>>>> changes which bring it into lockdep conflict with shmem_zero_setup():
>>>>>> it is surprising that mmap() can clone an inode while holding mmap_sem,
>>>>>> but that has been so for many years.
>>>>>>
>>>>>> Since those few lockdep traces that I've seen all implicated selinux,
>>>>>> I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
>>>>>> v3.13's commit c7277090927a ("security: shmem: implement kernel private
>>>>>> shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
>>>>>> the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
>>>>>>
>>>>>> This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
>>>>>> (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
>>>>>> which cloned inode in mmap(), but if so, I cannot locate them now.
>>>>>
>>>>> This causes a regression for SELinux (please, in the future, cc
>>>>> selinux list and Paul Moore on SELinux-related changes).  In
>>>
>>> Surprised and sorry about that, yes, I should have Cc'ed.
>>>
>>>>> particular, this change disables SELinux checking of mprotect
>>>>> PROT_EXEC on shared anonymous mappings, so we lose the ability to
>>>>> control executable mappings.  That said, we are only getting that
>>>>> check today as a side effect of our file execute check on the tmpfs
>>>>> inode, whereas it would be better (and more consistent with the
>>>>> mmap-time checks) to apply an execmem check in that case, in which
>>>>> case we wouldn't care about the inode-based check.  However, I am
>>>>> unclear on how to correctly detect that situation from
>>>>> selinux_file_mprotect() -> file_map_prot_check(), because we do have a
>>>>> non-NULL vma->vm_file so we treat it as a file execute check.  In
>>>>> contrast, if directly creating an anonymous shared mapping with
>>>>> PROT_EXEC via mmap(...PROT_EXEC...),  selinux_mmap_file is called with
>>>>> a NULL file and therefore we end up applying an execmem check.
>>>
>>> If you're willing to go forward with the change, rather than just call
>>> for an immediate revert of it, then I think the right way to detect
>>> the situation would be to check IS_PRIVATE(file_inode(vma->vm_file)),
>>> wouldn't it?
>>
>> That seems misleading and might trigger execmem checks on non-shmem
>> inodes.  S_PRIVATE was originally introduced for fs-internal inodes that
>> are never directly exposed to userspace, originally for reiserfs xattr
>> inodes (reiserfs xattrs are internally implemented as their own files
>> that are hidden from userspace) and later also applied to anon inodes.
>> It would be better if we had an explicit way of testing that we are
>> dealing with an anonymous shared mapping in selinux_file_mprotect() ->
>> file_map_prot_check().
> 
> But how would any of those original S_PRIVATE inodes arrive at
> selinux_file_mprotect()?  Now we have added the anon shared mmap case
> which can arrive there, but the S_PRIVATE check seems just the right
> tool for the job of distinguishing those from the user-visible inodes.
> 
> I don't see how adding some other flag for this case would be better
> - though certainly I can see that adding an "anon shared shmem"
> comment on its use in that check would be helpful.
> 
> Or is there some further difficulty in this use of S_PRIVATE, beyond
> the mprotect case that you've mentioned?  Unless there is some further
> difficulty, duplicating all the code relating to S_PRIVATE for a
> differently named flag seems counter-productive to me.

S_PRIVATE is supposed to disable all security processing on the inode,
and often this is checked in the security framework
(security/security.c) even before we reach the SELinux hook and causes
an immediate return there.  In the case of mprotect, we do reach the
SELinux code since the hook is on the vma, not merely the inode, so we
could apply an execmem check in the SELinux code if IS_PRIVATE() instead
of file execute.

However, I was trying to figure out if the fact that S_PRIVATE also
would disable any read/write checking by SELinux on the inode could
potentially open up a bypass of security policy.  That would only be an
issue if the file returned by shmem_zero_setup() was ever linked to an
open file descriptor that could be inherited across a fork+exec or
passed across local socket IPC or binder IPC and thereby shared across
different security contexts. Uses of shmem_zero_setup() include mmap
MAP_ANONYMOUS|MAP_SHARED, drivers/staging/android/ashmem.c (from
ashmem_mmap if VM_SHARED), and drivers/char/mem.c (from mmap_zero if
VM_SHARED).  That all seems fine AFAICS.

> (There is a bool shmem_mapping(mapping) that could be used to confirm
> that the inode you're looking at indeed belongs to shmem; but of
> course that would say yes on all the user-visible shmem inodes too,
> so it wouldn't be a useful test on its own, and I don't see that
> adding it to an S_PRIVATE test would add any real value.)
> 
> Probably you were hoping that there's already some distinguishing
> feature of anon shared shmem inodes that you could check: I can't
> think of one offhand, beyond S_PRIVATE: if there is another,
> it would be accidental.

Yes, I was hoping for that.  Ok, I'll spin up a patch for adding an
IS_PRIVATE() test to SELinux file_map_prot_check() and cc you all on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
