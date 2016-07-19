Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89F5D6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 19:28:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so65986386pfa.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:28:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s4si9591775paw.284.2016.07.19.16.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 16:28:00 -0700 (PDT)
Date: Tue, 19 Jul 2016 16:27:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/10] mm, oom: hide mm which is shared with kthread or
 global init
Message-Id: <20160719162759.e391c685db7a8de30b79320c@linux-foundation.org>
In-Reply-To: <20160719120538.GE9490@dhcp22.suse.cz>
References: <1466426628-15074-1-git-send-email-mhocko@kernel.org>
	<1466426628-15074-11-git-send-email-mhocko@kernel.org>
	<20160719120538.GE9490@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 19 Jul 2016 14:05:39 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > After this patch we should guarantee a forward progress for the OOM
> > killer even when the selected victim is sharing memory with a kernel
> > thread or global init.
> 
> Could you replace the last two paragraphs with the following. Tetsuo
> didn't like the guarantee mentioned there because that is a too strong
> statement as find_lock_task_mm might not find any mm and so we still
> could end up looping on the oom victim if it gets stuck somewhere in
> __mmput. This particular patch didn't aim at closing that case. Plugging
> that hole is planned later after the next upcoming merge window closes.
> 
> "
> In order to help a forward progress for the OOM killer, make sure
> that this really rare cases will not get into the way and hide
> the mm from the oom killer by setting MMF_OOM_REAPED flag for it.
> oom_scan_process_thread will ignore any TIF_MEMDIE task if it has
> MMF_OOM_REAPED flag set to catch these oom victims.
> 		        
> After this patch we should guarantee a forward progress for the OOM
> killer even when the selected victim is sharing memory with a kernel
> thread or global init as long as the victims mm is still alive.
> "

I tweaked it a bit:

: In order to help forward progress for the OOM killer, make sure that
: this really rare case will not get in the way - we do this by hiding
: the mm from the oom killer by setting MMF_OOM_REAPED flag for it. 
: oom_scan_process_thread will ignore any TIF_MEMDIE task if it has
: MMF_OOM_REAPED flag set to catch these oom victims.
: 
: After this patch we should guarantee forward progress for the OOM
: killer even when the selected victim is sharing memory with a kernel
: thread or global init as long as the victims mm is still alive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
