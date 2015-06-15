Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 164A56B006C
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 02:09:22 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so26785376wgb.2
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 23:09:21 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id f8si16592587wiy.57.2015.06.14.23.09.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 23:09:20 -0700 (PDT)
Received: by wiga1 with SMTP id a1so65946844wig.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 23:09:19 -0700 (PDT)
Message-ID: <557E6C0C.3050802@monom.org>
Date: Mon, 15 Jun 2015 08:09:16 +0200
From: Daniel Wagner <wagi@monom.org>
MIME-Version: 1.0
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Prarit Bhargava <prarit@redhat.com>, Morten Stevens <mstevens@fedoraproject.org>, Dave Chinner <david@fromorbit.com>, Eric Paris <eparis@redhat.com>, Eric Sandeen <esandeen@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/14/2015 06:48 PM, Hugh Dickins wrote:
> It appears that, at some point last year, XFS made directory handling
> changes which bring it into lockdep conflict with shmem_zero_setup():
> it is surprising that mmap() can clone an inode while holding mmap_sem,
> but that has been so for many years.
> 
> Since those few lockdep traces that I've seen all implicated selinux,
> I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
> v3.13's commit c7277090927a ("security: shmem: implement kernel private
> shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
> the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
> 
> This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
> (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
> which cloned inode in mmap(), but if so, I cannot locate them now.
> 
> Reported-and-tested-by: Prarit Bhargava <prarit@redhat.com>
> Reported-by: Daniel Wagner <wagi@monom.org>

Reported-and-tested-by: Daniel Wagner <wagi@monom.org>

Sorry for the long delay. It took me a while to figure out my original
setup. I could verify that this patch made the lockdep message go away
on 4.0-rc6 and also on 4.1-rc8.

For the record: SELinux needs to be enabled triggering it.

cheers,
daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
