Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2786B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 10:29:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id k184so28260015wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:29:44 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id kz10si5210360wjb.243.2016.06.16.07.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 07:29:42 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id m124so11881777wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:29:42 -0700 (PDT)
Date: Thu, 16 Jun 2016 16:29:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
Message-ID: <20160616142940.GK6836@dhcp22.suse.cz>
References: <1465473137-22531-8-git-send-email-mhocko@kernel.org>
 <201606092218.FCC48987.MFQLVtSHJFOOFO@I-love.SAKURA.ne.jp>
 <20160609142026.GF24777@dhcp22.suse.cz>
 <201606111710.IGF51027.OJLSOQtHVOFFFM@I-love.SAKURA.ne.jp>
 <20160613112746.GD6518@dhcp22.suse.cz>
 <201606162154.CGE05294.HJQOSMFFVFtOOL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606162154.CGE05294.HJQOSMFFVFtOOL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu 16-06-16 21:54:27, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 11-06-16 17:10:03, Tetsuo Handa wrote:
[...]
> I still don't like it. current->mm == NULL in
> 
> -	if (current->mm &&
> -	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> +	if (task_will_free_mem(current)) {
> 
> is not highly unlikely. You obviously break commit d7a94e7e11badf84
> ("oom: don't count on mm-less current process") on CONFIG_MMU=n kernels.

I still fail to see why you care about that case so much. The heuristic
was broken for other reasons before this patch. The patch fixes a class
of issues for both mmu and nommu. I can restore the current->mm check
for now but the more I am thinking about it the less I am sure the
commit you are referring to is evem correct/necessary.

It claims that the OOM killer would be stuck because the child would be
sitting in the final schedule() until the parent reaps it. That is not
true, though, because victim would be unhashed down in release_task()
path so it is not visible by the oom killer when it is waiting for the
parent.  I have completely missed that part when reviewing the patch. Or
am I missing something...

Anyway, would you be OK with the patch if I added the current->mm check
and resolve its necessity in a separate patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
