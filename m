Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0D20B6B0278
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 17:20:00 -0500 (EST)
Received: by obciw8 with SMTP id iw8so962946obc.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 14:19:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o9si98223oek.20.2015.12.07.14.19.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Dec 2015 14:19:59 -0800 (PST)
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
	<201511290110.FJB87096.OHJLVQOSFFtMFO@I-love.SAKURA.ne.jp>
	<20151201132927.GG4567@dhcp22.suse.cz>
	<201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp>
	<20151207160718.GA20774@dhcp22.suse.cz>
In-Reply-To: <20151207160718.GA20774@dhcp22.suse.cz>
Message-Id: <201512080719.EHD73429.JQHFtMOFLOFSVO@I-love.SAKURA.ne.jp>
Date: Tue, 8 Dec 2015 07:19:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Yes you are right! The reference count should be incremented before
> publishing the new mm_to_reap. I thought that an elevated ref. count by
> the caller would be enough but this was clearly wrong. Does the update
> below looks better?

I think that moving mmdrop() from oom_kill_process() to
oom_reap_vmas() xor wake_oom_reaper() makes the patch simpler.

 	rcu_read_unlock();
 
+	if (can_oom_reap)
+		wake_oom_reaper(mm); /* will call mmdrop() */
+	else
+		mmdrop(mm);
-	mmdrop(mm);
 	put_task_struct(victim);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
