Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E736A6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 20:21:01 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 83so161945861pgb.14
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 17:21:01 -0700 (PDT)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id 65si4811554pfw.406.2017.08.14.17.21.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 17:21:00 -0700 (PDT)
Received: by mail-pg0-x22f.google.com with SMTP id v189so56980786pgd.2
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 17:21:00 -0700 (PDT)
Date: Mon, 14 Aug 2017 17:20:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
In-Reply-To: <20170726162912.GA29716@redhat.com>
Message-ID: <alpine.DEB.2.10.1708141719090.50317@chino.kir.corp.google.com>
References: <20170724141526.GM25221@dhcp22.suse.cz> <20170724145142.i5xqpie3joyxbnck@node.shutemov.name> <20170724161146.GQ25221@dhcp22.suse.cz> <20170725142626.GJ26723@dhcp22.suse.cz> <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
 <20170725152300.GM26723@dhcp22.suse.cz> <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name> <20170725160359.GO26723@dhcp22.suse.cz> <20170725191952.GR29716@redhat.com> <20170726054557.GB960@dhcp22.suse.cz> <20170726162912.GA29716@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 26 Jul 2017, Andrea Arcangeli wrote:

> From 3d9001490ee1a71f39c7bfaf19e96821f9d3ff16 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Tue, 25 Jul 2017 20:02:27 +0200
> Subject: [PATCH 1/1] mm: oom: let oom_reap_task and exit_mmap to run
>  concurrently
> 
> This is purely required because exit_aio() may block and exit_mmap() may
> never start, if the oom_reap_task cannot start running on a mm with
> mm_users == 0.
> 
> At the same time if the OOM reaper doesn't wait at all for the memory
> of the current OOM candidate to be freed by exit_mmap->unmap_vmas, it
> would generate a spurious OOM kill.
> 
> If it wasn't because of the exit_aio or similar blocking functions in
> the last mmput, it would be enough to change the oom_reap_task() in
> the case it finds mm_users == 0, to wait for a timeout or to wait for
> __mmput to set MMF_OOM_SKIP itself, but it's not just exit_mmap the
> problem here so the concurrency of exit_mmap and oom_reap_task is
> apparently warranted.
> 
> It's a non standard runtime, exit_mmap() runs without mmap_sem, and
> oom_reap_task runs with the mmap_sem for reading as usual (kind of
> MADV_DONTNEED).
> 
> The race between the two is solved with a combination of
> tsk_is_oom_victim() (serialized by task_lock) and MMF_OOM_SKIP
> (serialized by a dummy down_write/up_write cycle on the same lines of
> the ksm_exit method).
> 
> If the oom_reap_task() may be running concurrently during exit_mmap,
> exit_mmap will wait it to finish in down_write (before taking down mm
> structures that would make the oom_reap_task fail with use after
> free).
> 
> If exit_mmap comes first, oom_reap_task() will skip the mm if
> MMF_OOM_SKIP is already set and in turn all memory is already freed
> and furthermore the mm data structures may already have been taken
> down by free_pgtables.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

With your follow-up one liner to include linux/oom.h folded in:

Tested-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
