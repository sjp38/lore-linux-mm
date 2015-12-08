Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id CC98C6B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 06:06:56 -0500 (EST)
Received: by wmuu63 with SMTP id u63so176471690wmu.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 03:06:56 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id s4si4320000wmd.38.2015.12.08.03.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 03:06:55 -0800 (PST)
Received: by wmec201 with SMTP id c201so24955245wme.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 03:06:55 -0800 (PST)
Date: Tue, 8 Dec 2015 12:06:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
Message-ID: <20151208110653.GA25800@dhcp22.suse.cz>
References: <201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
 <201511290110.FJB87096.OHJLVQOSFFtMFO@I-love.SAKURA.ne.jp>
 <20151201132927.GG4567@dhcp22.suse.cz>
 <201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp>
 <20151207160718.GA20774@dhcp22.suse.cz>
 <201512080719.EHD73429.JQHFtMOFLOFSVO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512080719.EHD73429.JQHFtMOFLOFSVO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

On Tue 08-12-15 07:19:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Yes you are right! The reference count should be incremented before
> > publishing the new mm_to_reap. I thought that an elevated ref. count by
> > the caller would be enough but this was clearly wrong. Does the update
> > below looks better?
> 
> I think that moving mmdrop() from oom_kill_process() to
> oom_reap_vmas() xor wake_oom_reaper() makes the patch simpler.

It surely is less lines of code but I am not sure it is simpler. I do
not think we should drop the reference in a different path than it is
taken.  Maybe we will grow more users of wake_oom_reaper in the future
and this is quite subtle behavior.

> 
>  	rcu_read_unlock();
>  
> +	if (can_oom_reap)
> +		wake_oom_reaper(mm); /* will call mmdrop() */
> +	else
> +		mmdrop(mm);
> -	mmdrop(mm);
>  	put_task_struct(victim);
>  }

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
