Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99A6C6B038D
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:45:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g8so12977588wmg.7
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 02:45:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s43si23852968wrc.28.2017.03.13.02.45.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 02:45:07 -0700 (PDT)
Date: Mon, 13 Mar 2017 10:45:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
Message-ID: <20170313094504.GH31518@dhcp22.suse.cz>
References: <201703091946.GDC21885.OQFFOtJHSOFVML@I-love.SAKURA.ne.jp>
 <20170309143751.05bddcbad82672384947de5f@linux-foundation.org>
 <20170310104047.GF3753@dhcp22.suse.cz>
 <201703102019.JHJ58283.MQHtVFOOFOLFJS@I-love.SAKURA.ne.jp>
 <20170310152611.GM3753@dhcp22.suse.cz>
 <201703111046.FBB87020.OVOOQFMHFSJLtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201703111046.FBB87020.OVOOQFMHFSJLtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru

On Sat 11-03-17 10:46:58, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > So, we have means to debug these issues. Some of them are rather coarse
> > and your watchdog can collect much more and maybe give us a clue much
> > quicker but we still have to judge whether all this is really needed
> > because it doesn't come for free. Have you considered this aspect?
> 
> Sigh... You are ultimately ignoring the reality. Educating everybody to master
> debugging tools does not come for free. If I liken your argumentation to
> security modules, it looks like the following.
> 
>   "There is already SELinux. SELinux can do everything. Thus, AppArmor is not needed.
>    I don't care about users/customers who cannot administrate SELinux."
> 
> The reality is different. We need tools which users/customers can afford using.
> You had better getting away from existing debug tools which kernel developers
> are using.
> 
> First of all, SysRq is an emergency tool and therefore it requires administrator's
> intervention. Your argumentation sounds to me that "Give up debugging unless you
> can sit on in front of console of Linux systems 24-7" which is already impossible.

My experience also tells me that different soft/hard lockups tend to
generate quite non-trivial number of false positives and those are
reported as bugs. We simply tend to underestimate how easy it is to trigger
paths without scheduling or how easy it is to trigger hardlockups on
large machines just due to lock bouncing etc...

> SysRq-t cannot print seq= and delay= fields because information of in-flight allocation
> request is not accessible from "struct task_struct", making extremely difficult to
> judge whether progress is made when several SysRq-t snapshots are taken.
> 
> Also, year by year it is getting difficult to use vmcore for analysis because vmcore
> might include sensitive data (even after filtering out user pages). I saw cases where
> vmcore cannot be sent to support centers due to e.g. organization's information
> control rules. Sometimes we have to analyze from only kernel messages. Some pieces of
> information extracted by running scripts against /usr/bin/crash on cutomer's side
> might be available, but in general we can't assume that the whole memory image which
> includes whatever information is available.
> 
> In most cases, administrators can't capture even SysRq-t; let alone vmcore.
> Therefore, automatic watchdog is highly appreciated. Have you considered this aspect?

yes I have. I tend to work with our SUSE L3 and enterprise customer a
lot last 10 years. And what I claim is that adding more watchdog doesn't
necessarily mean we will get better bug reports. I do not have any exact
statistics but my perception is that allocation lockups tends to be less
than 1% of reported bugs. You seem to make a huge issue from this
particular class of issues basing your argumentation on "unknown
issues which might have been allocation lockups etc." I am not feeling
comfortable with this kind of arguing and making any decision on them.

So let me repeat (for the last time). I find your watchdog interesting
for stress testing but I am not convinced this is generally useful for
real workloads and the maintenance burden is worth it. I _might_ be
wrong here and that is why this is _no_ a NAK from me but I feel
uncomfortable how hard you are pushing this.

I expect this is my last word on this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
