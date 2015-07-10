Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 573C06B025D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 15:19:23 -0400 (EDT)
Received: by igrv9 with SMTP id v9so19948374igr.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 12:19:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f100si1243341ioi.34.2015.07.10.12.19.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 12:19:22 -0700 (PDT)
Date: Fri, 10 Jul 2015 12:19:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] selinux: fix mprotect PROT_EXEC regression caused by mm
 change
Message-Id: <20150710121921.e02eb9f1041432ff2dca4667@linux-foundation.org>
In-Reply-To: <1436535659-13124-1-git-send-email-sds@tycho.nsa.gov>
References: <1436535659-13124-1-git-send-email-sds@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: paul@paul-moore.com, hughd@google.com, prarit@redhat.com, mstevens@fedoraproject.org, esandeen@redhat.com, david@fromorbit.com, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-mm@kvack.org, wagi@monom.org, selinux@tycho.nsa.gov, torvalds@linux-foundation.org, stable@vger.kernel.org

On Fri, 10 Jul 2015 09:40:59 -0400 Stephen Smalley <sds@tycho.nsa.gov> wrote:

> commit 66fc13039422ba7df2d01a8ee0873e4ef965b50b ("mm: shmem_zero_setup skip
> security check and lockdep conflict with XFS") caused a regression for
> SELinux by disabling any SELinux checking of mprotect PROT_EXEC on
> shared anonymous mappings.  However, even before that regression, the
> checking on such mprotect PROT_EXEC calls was inconsistent with the
> checking on a mmap PROT_EXEC call for a shared anonymous mapping.  On a
> mmap, the security hook is passed a NULL file and knows it is dealing with
> an anonymous mapping and therefore applies an execmem check and no file
> checks.  On a mprotect, the security hook is passed a vma with a
> non-NULL vm_file (as this was set from the internally-created shmem
> file during mmap) and therefore applies the file-based execute check and
> no execmem check.  Since the aforementioned commit now marks the shmem
> zero inode with the S_PRIVATE flag, the file checks are disabled and
> we have no checking at all on mprotect PROT_EXEC.  Add a test to
> the mprotect hook logic for such private inodes, and apply an execmem
> check in that case.  This makes the mmap and mprotect checking consistent
> for shared anonymous mappings, as well as for /dev/zero and ashmem.
> 
> Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>

Cc: <stable@vger.kernel.org>	[4.1.x]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
