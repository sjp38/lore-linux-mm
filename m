Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A938382907
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 21:35:39 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so159178562pdb.1
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 18:35:39 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id dr4si12575782pdb.162.2015.03.29.18.35.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Mar 2015 18:35:38 -0700 (PDT)
Received: by pacwe9 with SMTP id we9so151648317pac.1
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 18:35:38 -0700 (PDT)
Date: Sun, 29 Mar 2015 18:35:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 1/2] mm, doc: cleanup and clarify munmap behavior for
 hugetlb memory
In-Reply-To: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.11.1503291801400.1052@eggly.anvils>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org

On Thu, 26 Mar 2015, David Rientjes wrote:

> munmap(2) of hugetlb memory requires a length that is hugepage aligned,
> otherwise it may fail.  Add this to the documentation.

Thanks for taking this on, David.  But although munmap(2) is the one
Davide called out, it goes beyond that, doesn't it?  To mprotect and
madvise and ...

I don't want to work out the list myself: is_vm_hugetlb_page() is
special-cased all over, and different syscalls react differently.

Which is another reason why, like you, I much prefer not to interfere
with the long established behavior: it would be very easy to introduce
bugs and worse inconsistencies.

And mprotect(2) is a good example of why we should not mess around
with the long established API here: changing an mprotect from failing
on a particular size to acting on a larger size is not a safe change.

Eric, I apologize for bringing you in to the discussion, and then
ignoring your input.  I understand that you would like MAP_HUGETLB
to behave more understandably.  We can all agree that the existing
behavior is unsatisfying.  But it's many years too late now to 
change it around - and I suspect that a full exercise to do so would
actually discover some good reasons why the original choices were made.

> 
> This also cleans up the documentation and separates it into logical
> units: one part refers to MAP_HUGETLB and another part refers to
> requirements for shared memory segments.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Documentation/vm/hugetlbpage.txt | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -289,15 +289,20 @@ file systems, write system calls are not.
>  Regular chown, chgrp, and chmod commands (with right permissions) could be
>  used to change the file attributes on hugetlbfs.
>  
> -Also, it is important to note that no such mount command is required if the
> +Also, it is important to note that no such mount command is required if
>  applications are going to use only shmat/shmget system calls or mmap with
> -MAP_HUGETLB.  Users who wish to use hugetlb page via shared memory segment
> -should be a member of a supplementary group and system admin needs to
> -configure that gid into /proc/sys/vm/hugetlb_shm_group.  It is possible for
> -same or different applications to use any combination of mmaps and shm*
> -calls, though the mount of filesystem will be required for using mmap calls
> -without MAP_HUGETLB.  For an example of how to use mmap with MAP_HUGETLB see
> -map_hugetlb.c.
> +MAP_HUGETLB.  For an example of how to use mmap with MAP_HUGETLB see map_hugetlb
> +below.
> +
> +Users who wish to use hugetlb memory via shared memory segment should be a
> +member of a supplementary group and system admin needs to configure that gid
> +into /proc/sys/vm/hugetlb_shm_group.  It is possible for same or different
> +applications to use any combination of mmaps and shm* calls, though the mount of
> +filesystem will be required for using mmap calls without MAP_HUGETLB.
> +
> +When using munmap(2) to unmap hugetlb memory, the length specified must be
> +hugepage aligned, otherwise it will fail with errno set to EINVAL.

Perhaps just adding something like "The same is true for mprotect(2)
and other such memory system calls." is good enough for here.

> +
>  
>  Examples
>  ========

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
