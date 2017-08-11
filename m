Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDE36B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 06:42:56 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id s26so15833779qts.8
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 03:42:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n188si483100qkb.440.2017.08.11.03.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 03:42:55 -0700 (PDT)
Date: Fri, 11 Aug 2017 12:42:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170811104250.GV25347@redhat.com>
References: <20170807113839.16695-1-mhocko@kernel.org>
 <20170807113839.16695-3-mhocko@kernel.org>
 <201708111128.FEE39036.HFVSQFOtOMLFJO@I-love.SAKURA.ne.jp>
 <20170811070938.GA30811@dhcp22.suse.cz>
 <201708111654.JCH34360.OMOLVFQJOStHFF@I-love.SAKURA.ne.jp>
 <20170811102256.GU25347@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170811102256.GU25347@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 11, 2017 at 12:22:56PM +0200, Andrea Arcangeli wrote:
> disk block? This would happen on ext4 as well if mounted with -o
> journal=data instead of -o journal=ordered in fact, perhaps you simply

Oops above I meant journal=writeback, journal=data is even stronger
than journal=ordered of course.

And I shall clarify further that old disk content can only showup
legitimately on journal=writeback after a hard reboot or crash or in
general an unclean unmount. Even if there's no journaling at all
(i.e. ext2/vfat) old disk content cannot be shown at any given time no
matter what if there's no unclean unmount that requires a journal
reply.

This theory of a completely unrelated fs bug showing you disk content
as result of the OOM reaper induced SIGBUS interrupting a
copy_from_user at its very start, is purely motivated by the fact like
Michal I didn't see much explanation on the VM side that could cause
those not-zero not-0xff values showing up in the buffer of the write
syscall. You can try to change fs and see if it happens again to rule
it out. If it always happens regardless of the filesystem used, then
it's likely not a fs bug of course. You've got an entire and aligned
4k fs block showing up that data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
