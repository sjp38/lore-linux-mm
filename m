Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 757906B006C
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 16:27:21 -0400 (EDT)
Received: by lbbwc1 with SMTP id wc1so18463899lbb.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 13:27:20 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id 20si3676966wjq.25.2015.06.16.13.27.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 13:27:19 -0700 (PDT)
Received: by wgzl5 with SMTP id l5so20581739wgz.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 13:27:19 -0700 (PDT)
Date: Tue, 16 Jun 2015 13:27:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
In-Reply-To: <557E6C0C.3050802@monom.org>
Message-ID: <alpine.LSU.2.11.1506161317530.1840@eggly.anvils>
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils> <557E6C0C.3050802@monom.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wagner <wagi@monom.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Prarit Bhargava <prarit@redhat.com>, Morten Stevens <mstevens@fedoraproject.org>, Dave Chinner <david@fromorbit.com>, Eric Paris <eparis@redhat.com>, Eric Sandeen <esandeen@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 15 Jun 2015, Daniel Wagner wrote:
> On 06/14/2015 06:48 PM, Hugh Dickins wrote:
> > It appears that, at some point last year, XFS made directory handling
> > changes which bring it into lockdep conflict with shmem_zero_setup():
> > it is surprising that mmap() can clone an inode while holding mmap_sem,
> > but that has been so for many years.
> > 
> > Since those few lockdep traces that I've seen all implicated selinux,
> > I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
> > v3.13's commit c7277090927a ("security: shmem: implement kernel private
> > shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
> > the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
> > 
> > This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
> > (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
> > which cloned inode in mmap(), but if so, I cannot locate them now.
> > 
> > Reported-and-tested-by: Prarit Bhargava <prarit@redhat.com>
> > Reported-by: Daniel Wagner <wagi@monom.org>
> 
> Reported-and-tested-by: Daniel Wagner <wagi@monom.org>

Great, thank you Daniel: we look more convincing now :)

> 
> Sorry for the long delay. It took me a while to figure out my original
> setup. I could verify that this patch made the lockdep message go away
> on 4.0-rc6 and also on 4.1-rc8.

Thank you for taking the trouble.

> 
> For the record: SELinux needs to be enabled triggering it.

Right, selinux was in all the stacktraces we saw, and I was banking
on that security "recursion" being what actually upset lockdep; but
couldn't be sure until you tried it out.

We didn't make -rc8, and I won't be at all surprised if Linus feels
that a year(?)-old lockdep warning is not worth disturbing v4.1
final for, but it should get into v4.2 (thank you, Andrew).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
