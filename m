Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 215576B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 15:51:49 -0500 (EST)
Received: by labgf13 with SMTP id gf13so13484364lab.9
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 12:51:48 -0800 (PST)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com. [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id wu9si1436379lbc.116.2015.02.26.12.51.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 12:51:47 -0800 (PST)
Received: by labgq15 with SMTP id gq15so13560011lab.6
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 12:51:46 -0800 (PST)
Date: Thu, 26 Feb 2015 23:51:45 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: replace mmap_sem for mm->exe_file serialization
Message-ID: <20150226205145.GH3041@moon>
References: <1424979417.10344.14.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424979417.10344.14.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave.bueso@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, Oleg Nesterov <oleg@redhat.com>

On Thu, Feb 26, 2015 at 11:36:57AM -0800, Davidlohr Bueso wrote:
> We currently use the mmap_sem to serialize the mm exe_file.
> This is atrocious and a clear example of the misuses this
> lock has all over the place, making any significant changes
> to the address space locking that much more complex and tedious.
> This also has to do of how we used to check for the vma's vm_file
> being VM_EXECUTABLE (much of which was replaced by 2dd8ad81e31).
> 
> This patch, therefore, removes the mmap_sem dependency and
> introduces a specific lock for the exe_file (rwlock_t, as it is
> read mostly and protects a trivial critical region). As mentioned,
> the motivation is to cleanup mmap_sem (as opposed to exe_file
> performance). A nice side effect of this is that we avoid taking
> the mmap_sem (shared) in fork paths for the exe_file handling
> (note that readers block when the rwsem is taken exclusively by
> another thread).
> 
> Now that callers have been updated and standardized[1, 2] around
> the get_mm_set_exe_file() interface, changing the locking scheme
> is quite straightforward. The exception being the prctl calls
> (ie PR_SET_MM_EXE_FILE). Because this caller actually _updates_
> the mm->exe_file, we need to handle it in the same patch that changes
> the locking rules. For this we need to reorganize prctl_set_mm_exe_file,
> such that:
> 
> o mmap_sem is taken when actually needed.
> 
> o a new set_mm_exe_file_locked() function is introduced to be used by
>   prctl. We now need to explicitly acquire the exe_file_lock as before
>   it was implicit in holding the mmap_sem for write.
> 
> o a new __prctl_set_mm_exe_file() helper is created, which actually
>   does the exe_file handling for the mm side -- needing the write
>   lock for updating the mm->flags (*sigh*). In the future we could
>   have a unique mm::exe_file_struct and keep track of MMF_EXE_FILE_CHANGED
>   on our own.
> 
> mm: improve handling of mm->exe_file
> [1] Part 1: https://lkml.org/lkml/2015/2/18/721
> [2] Part 2: https://lkml.org/lkml/2015/2/25/679
> 
> Applies on top of linux-next (20150225).
> 
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

Hi Davidlohr, it would be interesting to know if the cleanup
bring some performance benefit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
