Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BFA86B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:34:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a140so51582962wma.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 05:34:51 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id mb1si45078515wjb.176.2016.04.14.05.34.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 05:34:50 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id l6so22463781wml.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 05:34:50 -0700 (PDT)
Date: Thu, 14 Apr 2016 14:34:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom_reaper: Use try_oom_reaper() for reapability test.
Message-ID: <20160414123448.GG2850@dhcp22.suse.cz>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160414112146.GD2850@dhcp22.suse.cz>
 <201604142034.BIF60426.FLFMVOHOJQStOF@I-love.SAKURA.ne.jp>
 <20160414120106.GF2850@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160414120106.GF2850@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

On Thu 14-04-16 14:01:06, Michal Hocko wrote:
[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 716759e3eaab..d5a4d08f2031 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -286,6 +286,13 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  		return OOM_SCAN_CONTINUE;
>  
>  	/*
> +	 * mm of this task has already been reaped so it doesn't make any
> +	 * sense to select it as a new oom victim.
> +	 */
> +	if (test_bit(MMF_OOM_REAPED, &task->mm->flags))
> +		return OOM_SCAN_CONTINUE;

This will have to move to oom_badness to where we check for
OOM_SCORE_ADJ_MIN to catch the case where we try to sacrifice a child...

In the meantime I have generated a full patch and will repost it with
other oom reaper follow ups sometimes next week.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
