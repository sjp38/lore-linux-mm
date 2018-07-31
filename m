Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D201C6B000A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:14:22 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l5-v6so11500610ioh.4
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:14:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v8-v6si8218516iom.279.2018.07.31.07.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 07:14:21 -0700 (PDT)
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <0d018c7e-a3de-a23a-3996-bed8b28b1e4a@i-love.sakura.ne.jp>
 <20180716220918.GA3898@castle.DHCP.thefacebook.com>
 <201807170055.w6H0tHn5075670@www262.sakura.ne.jp>
Message-ID: <ede70c6a-620b-f835-d66c-b4608fe0ef54@i-love.sakura.ne.jp>
Date: Tue, 31 Jul 2018 23:14:01 +0900
MIME-Version: 1.0
In-Reply-To: <201807170055.w6H0tHn5075670@www262.sakura.ne.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/07/17 9:55, Tetsuo Handa wrote:
>> I don't get, why it's necessary to drop the cgroup oom killer to merge your fix?
>> I'm happy to help with rebasing and everything else.
> 
> Yes, I wish you rebase your series on top of OOM lockup (CVE-2016-10723) mitigation
> patch ( https://marc.info/?l=linux-mm&m=153112243424285&w=4 ). It is a trivial change
> and easy to cleanly backport (if applied before your series).
> 
> Also, I expect you to check whether my cleanup patch which removes "abort" path
> ( [PATCH 1/2] at https://marc.info/?l=linux-mm&m=153119509215026&w=4 ) helps
> simplifying your series. I don't know detailed behavior of your series, but I
> assume that your series do not kill threads which current thread should not wait
> for MMF_OOM_SKIP.

syzbot is hitting WARN(1) due to mem_cgroup_out_of_memory() == false.
https://syzkaller.appspot.com/bug?id=ea8c7912757d253537375e981b61749b2da69258

I can't tell what change is triggering this race. Maybe removal of oom_lock from
the oom reaper made more likely to hit. But anyway I suspect that

static bool oom_kill_memcg_victim(struct oom_control *oc)
{
        if (oc->chosen_memcg == NULL || oc->chosen_memcg == INFLIGHT_VICTIM)
                return oc->chosen_memcg; // <= This line is still broken

because

                /* We have one or more terminating processes at this point. */
                oc->chosen_task = INFLIGHT_VICTIM;

is not called.

Also, that patch is causing confusion by reviving schedule_timeout_killable(1)
with oom_lock held.

Can we temporarily drop cgroup-aware OOM killer from linux-next.git and
apply my cleanup patch? Since the merge window is approaching, I really want to
see how next -rc1 would look like...
