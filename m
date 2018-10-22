Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1477F6B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 11:13:03 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id e136-v6so28419352oib.11
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 08:13:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l69si15754167otc.63.2018.10.22.08.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 08:13:01 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <f9a8079f-55b0-301e-9b3d-a5250bd7d277@i-love.sakura.ne.jp>
 <20181022120308.GB18839@dhcp22.suse.cz>
 <0a84d3de-f342-c183-579b-d672c116ba25@i-love.sakura.ne.jp>
 <20181022134315.GF18839@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <2deec266-2eaf-f754-ae94-d290f10c79ec@i-love.sakura.ne.jp>
Date: Tue, 23 Oct 2018 00:12:48 +0900
MIME-Version: 1.0
In-Reply-To: <20181022134315.GF18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/10/22 22:43, Michal Hocko wrote:
> On Mon 22-10-18 22:20:36, Tetsuo Handa wrote:
>> I mean:
>>
>>  mm/memcontrol.c |   3 +-
>>  mm/oom_kill.c   | 111 +++++---------------------------------------------------
>>  2 files changed, 12 insertions(+), 102 deletions(-)
> 
> This is much larger change than I feel comfortable with to plug this
> specific issue. A simple and easy to understand fix which doesn't add
> maintenance burden should be preferred in general.
> 
> The code reduction looks attractive but considering it is based on
> removing one of the heuristics to prevent OOM reports in some case it
> should be done on its own with a careful and throughout justification.
> E.g. how often is the heuristic really helpful.

I think the heuristic is hardly helpful.


Regarding task_will_free_mem(current) condition in out_of_memory(),
this served for two purposes. One is that mark_oom_victim() is not yet
called on current thread group when mark_oom_victim() was already called
on other thread groups. But such situation disappears by removing
task_will_free_mem() shortcuts and forcing for_each_process(p) loop
in __oom_kill_process().

The other is that mark_oom_victim() is not yet called on any thread groups when
all thread groups are exiting. In that case, we will fail to wait for current
thread group to release its mm... But it is unlikely that only threads which
task_will_free_mem(current) returns true can call out_of_memory() (note that
task_will_free_mem(p) returns false if p->mm == NULL).


I think it is highly unlikely to hit task_will_free_mem(p) condition
in oom_kill_process(). To hit it, the candidate who was chosen due to
the largest memory user has to be already exiting. However, if already
exiting, it is likely the candidate already released its mm (and hence
no longer the largest memory user). I can't say such race never happens,
but I think it is unlikely. Also, since task_will_free_mem(p) returns false
if thread group leader's mm is NULL whereas oom_badness() from
select_bad_process() evaluates any mm in that thread group and returns
a thread group leader, this heuristic is incomplete after all.

> 
> In principle I do not oppose to remove the shortcut after all due
> diligence is done because this particular one had given us quite a lot
> headaches in the past.
> 
