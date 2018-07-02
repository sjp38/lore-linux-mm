Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B01596B0010
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 06:17:37 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x2-v6so6251917pgv.7
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 03:17:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u195-v6si13878940pgb.443.2018.07.02.03.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 03:17:36 -0700 (PDT)
Date: Mon, 2 Jul 2018 12:17:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v11 1/2] Refactor part of the oom report in dump_header
Message-ID: <20180702101732.GD19043@dhcp22.suse.cz>
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Sun 01-07-18 00:38:58, ufo19890607@gmail.com wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The current system wide oom report prints information about the victim
> and the allocation context and restrictions. It, however, doesn't
> provide any information about memory cgroup the victim belongs to. This
> information can be interesting for container users because they can find
> the victim's container much more easily.
> 
> I follow the advices of David Rientjes and Michal Hocko, and refactor
> part of the oom report. After this patch, users can get the memcg's
> path from the oom report and check the certain container more quickly.
> 
> The oom print info after this patch:
> oom-kill:constraint=<constraint>,nodemask=<nodemask>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>

This changelog doesn't correspond to the patch. Also while we were
discussing this off-list, I have suggested to pull the cpuset info into
the single line output.

What about the following?
"
OOM report contains several sections. The first one is the allocation
context that has triggered the OOM. Then we have cpuset context
followed by the stack trace of the OOM path. Followed by the oom
eligible tasks and the information about the chosen oom victim.

One thing that makes parsing more awkward than necessary is that we do
not have a single and easily parsable line about the oom context. This
patch is reorganizing the oom report to
1) who invoked oom and what was the allocation request
	[  126.168182] panic invoked oom-killer: gfp_mask=0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0, oom_score_adj=0

2) OOM stack trace
	[  126.169806] CPU: 23 PID: 8668 Comm: panic Not tainted 4.18.0-rc2+ #36
	[  126.170494] Hardware name: Inspur SA5212M4/YZMB-00370-107, BIOS 4.1.10 11/14/2016
	[  126.171197] Call Trace:
	[  126.171901]  dump_stack+0x5a/0x73
	[  126.172593]  dump_header+0x58/0x2dc
	[  126.173294]  oom_kill_process+0x228/0x420
	[  126.173999]  ? oom_badness+0x2a/0x130
	[  126.174705]  out_of_memory+0x11a/0x4a0
	[  126.175415]  __alloc_pages_slowpath+0x7cc/0xa1e
	[  126.176128]  ? __alloc_pages_slowpath+0x194/0xa1e
	[  126.176853]  ? page_counter_try_charge+0x54/0xc0
	[  126.177580]  __alloc_pages_nodemask+0x277/0x290
	[  126.178319]  alloc_pages_vma+0x73/0x180
	[  126.179058]  do_anonymous_page+0xed/0x5a0
	[  126.179825]  __handle_mm_fault+0xbb3/0xe70
	[  126.180566]  handle_mm_fault+0xfa/0x210
	[  126.181313]  __do_page_fault+0x233/0x4c0
	[  126.182063]  do_page_fault+0x32/0x140
	[  126.182812]  ? page_fault+0x8/0x30
	[  126.183560]  page_fault+0x1e/0x30

3) oom context (contrains and the chosen victim)
	[  126.190619] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0-1,task=panic,pid= 8673,uid=    0

An admin can easily get the full oom context at a single line which
makes parsing much easier.
"
-- 
Michal Hocko
SUSE Labs
