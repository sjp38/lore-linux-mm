Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF4D86B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 17:44:43 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id v72so17149129ywa.1
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 14:44:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e184si1332596ybb.109.2017.09.25.14.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 14:44:43 -0700 (PDT)
Date: Mon, 25 Sep 2017 23:44:38 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Questions about commit "ipc/shm: Fix shmat mmap nil-page
 protection"
Message-ID: <20170925214438.GU31084@redhat.com>
References: <472dbcaa-47b5-7a1b-7c4a-49373db784d3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <472dbcaa-47b5-7a1b-7c4a-49373db784d3@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Lawrence <joe.lawrence@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org

Hello,

On Mon, Sep 25, 2017 at 03:38:07PM -0400, Joe Lawrence wrote:
> Hi Davidlohr,
> 
> I was looking into backporting commit 95e91b831f87 ("ipc/shm: Fix shmat
> mmap nil-page protection") to a distro kernel and Andrea brought up some
> interesting questions about that change.
> 
> We saw that a LTP test [1] was added some time ago to reproduce behavior
> matching that of the original report [2].  However, Andrea and I are a
> little confused about that original report and what the upstream commit
> was intended to fix.  A quick summary of our offlist discussion:
> 
> - This is only about privileged users (and no SELinux).
> 
> - We modified the 20170119_shmat_nullpage_poc.c reproducer from [2] to
>   include MAP_FIXED to prove (as root, no SELinux):
> 
>     It is possible to mmap 0
>     It is NOT possible to mmap 1
> 
> - Andrea points out that mmap(1, ...) fails not because of any
>   mmap_min_addr checks, but for alignment reasons.
> 
> - He also wonders about other bogus addr values above 4k, but below
>   mmap_min_addr and whether this change misses those values

Yes, thanks for the accurate summary Joe.

> Is it possible that the original report noticed that shmat allowed
> attach to an address of 1, and it was assumed that somehow mmap_min_addr
> protections were circumvented?  Then commit 95e91b831f87 modified the
> rounding in do_shmat() so that shmat would fail on similar input (but
> for apparently different reasons)?
> 
> I didn't see any discussion when looking up the original commit in the
> list archives, so any explanations or pointers would be very helpful.

We identified only one positive side effect to such change, it is
about the semantics of SHM_REMAP when addr < shmlba (and != 0). Before
the patch SHM_REMAP was erroneously implicit for that virtual
range. However that's not security related either, and there's no
mention of SHM_REMAP in the commit message.

So then we wondered what this CVE is about in the first place, it
looks a invalid CVE for a not existent security issue. The testcase at
least shows no malfunction, mapping addr 0 is fine to succeed with
CAP_SYS_RAWIO.

>From the commit message, testcase and CVE I couldn't get what this
commit is about.

Last but not the least, if there was a security problem in calling
do_mmap_pgoff with addr=0, flags=MAP_FIXED|MAP_SHARED the fix would
better be moved to do_mmap_pgoff, not in ipc/shm.c.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
