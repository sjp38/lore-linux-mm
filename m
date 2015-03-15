Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id BDB30900017
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 10:23:37 -0400 (EDT)
Received: by wgra20 with SMTP id a20so21208786wgr.3
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 07:23:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t8si12503764wiz.124.2015.03.15.07.23.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Mar 2015 07:23:35 -0700 (PDT)
Date: Sun, 15 Mar 2015 15:21:37 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH -next v2 0/4] mm: replace mmap_sem for mm->exe_file
	serialization
Message-ID: <20150315142137.GA21741@redhat.com>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, gorcunov@openvz.org, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I didn't even read this version, but honestly I don't like it anyway.

I leave the review to Cyrill and Konstantin though, If they like these
changes I won't argue.

But I simply can't understand why are you doing this.



Yes, this code needs cleanups, I agree. Does this series makes it better?
To me it doesn't, and the diffstat below shows that it blows the code.

In fact, to me it complicates this code. For example. Personally I think
that MMF_EXE_FILE_CHANGED should die. And currently we can just remove it.
Not after your patch which adds another dependency.



Or do you think this is performance improvement? I don't think so. Yes,
prctl() abuses mmap_sem, but this not a hot path and the task can only
abuse its own ->mm.

OK, I agree, dup_mm_exe_file() is horrible. But as I already said it can
simply die. We can move this code into dup_mmap() and avoid another
down_read/up_read.


Hmm. And this series is simply wrong without more changes in audit paths.
Unfortunately this is fixable, but let me NACK at least this version ;)


Speaking of cleanups... IIRC Konstantin suggested to rcuify this pointer
and I agree, this looks better than the new lock. But in fact I think
that the cleanups should start with s/get_mm_exe_file//get_mm_exe_path/.
Note that nobody actually needs "file *", every caller needs "struct path".
Plus kill dup_mm_exe_file().

Oleg.


On 03/14, Davidlohr Bueso wrote:
>
> This is a set I created on top of patch 1/4 which also includes mm_struct cleanups
> and dealing with prctl exe_file functionality. Specific details are in each patch.
> Patch 4 is an extra trivial one I found while going through the code.
>
> Applies on top of next-20150313.
>
> Thanks!
>
> Davidlohr Bueso (4):
>   mm: replace mmap_sem for mm->exe_file serialization
>   mm: introduce struct exe_file
>   prctl: move MMF_EXE_FILE_CHANGED into exe_file struct
>   kernel/fork: use pr_alert() for rss counter bugs
>
>  fs/exec.c                |   6 +++
>  include/linux/mm.h       |   4 ++
>  include/linux/mm_types.h |   8 +++-
>  include/linux/sched.h    |   5 +--
>  kernel/fork.c            |  72 ++++++++++++++++++++++++++------
>  kernel/sys.c             | 106 +++++++++++++++++++++++++++--------------------
>  6 files changed, 141 insertions(+), 60 deletions(-)
>
> --
> 2.1.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
