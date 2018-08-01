Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4D96B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 12:37:44 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id 133-v6so11976567ywq.4
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 09:37:44 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 62-v6si4425492ybw.621.2018.08.01.09.37.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 09:37:42 -0700 (PDT)
Date: Wed, 1 Aug 2018 09:37:23 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
Message-ID: <20180801163718.GA23539@castle>
References: <0d018c7e-a3de-a23a-3996-bed8b28b1e4a@i-love.sakura.ne.jp>
 <20180716220918.GA3898@castle.DHCP.thefacebook.com>
 <201807170055.w6H0tHn5075670@www262.sakura.ne.jp>
 <ede70c6a-620b-f835-d66c-b4608fe0ef54@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <ede70c6a-620b-f835-d66c-b4608fe0ef54@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jul 31, 2018 at 11:14:01PM +0900, Tetsuo Handa wrote:
> On 2018/07/17 9:55, Tetsuo Handa wrote:
> >> I don't get, why it's necessary to drop the cgroup oom killer to merge your fix?
> >> I'm happy to help with rebasing and everything else.
> > 
> > Yes, I wish you rebase your series on top of OOM lockup (CVE-2016-10723) mitigation
> > patch ( https://marc.info/?l=linux-mm&m=153112243424285&w=4 ). It is a trivial change
> > and easy to cleanly backport (if applied before your series).
> > 
> > Also, I expect you to check whether my cleanup patch which removes "abort" path
> > ( [PATCH 1/2] at https://marc.info/?l=linux-mm&m=153119509215026&w=4 ) helps
> > simplifying your series. I don't know detailed behavior of your series, but I
> > assume that your series do not kill threads which current thread should not wait
> > for MMF_OOM_SKIP.
> 
> syzbot is hitting WARN(1) due to mem_cgroup_out_of_memory() == false.
> https://urldefense.proofpoint.com/v2/url?u=https-3A__syzkaller.appspot.com_bug-3Fid-3Dea8c7912757d253537375e981b61749b2da69258&d=DwICJg&c=5VD0RTtNlTh3ycd41b3MUw&r=i6WobKxbeG3slzHSIOxTVtYIJw7qjCE6S0spDTKL-J4&m=h9FJRAWtCmDLT-cVwvXKCYIUVRSrD--0XFJE-OnNY64&s=If6eFu6MlYjnfLXeg5_S-3tuhCZhSMv8_qfSrMfwOQ0&e=
> 
> I can't tell what change is triggering this race. Maybe removal of oom_lock from
> the oom reaper made more likely to hit. But anyway I suspect that
> 
> static bool oom_kill_memcg_victim(struct oom_control *oc)
> {
>         if (oc->chosen_memcg == NULL || oc->chosen_memcg == INFLIGHT_VICTIM)
>                 return oc->chosen_memcg; // <= This line is still broken
> 
> because
> 
>                 /* We have one or more terminating processes at this point. */
>                 oc->chosen_task = INFLIGHT_VICTIM;
> 
> is not called.
> 
> Also, that patch is causing confusion by reviving schedule_timeout_killable(1)
> with oom_lock held.
> 
> Can we temporarily drop cgroup-aware OOM killer from linux-next.git and
> apply my cleanup patch? Since the merge window is approaching, I really want to
> see how next -rc1 would look like...

Hi Tetsuo!

Has this cleanup patch been acked by somebody?
Which problem does it solve?
Dropping patches for making a cleanup (if it's a cleanup) sounds a bit strange.

Anyway, there is a good chance that current cgroup-aware OOM killer
implementation will be replaced by a lightweight version (memory.oom.group).
Please, take a look at it, probably your cleanup will not conflict with it
at all.

Thanks!
