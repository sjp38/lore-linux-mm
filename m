Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1599C31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 05:49:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 276D3216C8
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 05:49:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 276D3216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CB7E6B0005; Sun, 16 Jun 2019 01:49:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 455026B0006; Sun, 16 Jun 2019 01:49:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F53C8E0001; Sun, 16 Jun 2019 01:49:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8D3B6B0005
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 01:49:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b10so5150982pgb.22
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 22:49:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-disposition:user-agent:sender:precedence:list-id
         :archived-at:list-archive:list-post:content-transfer-encoding;
        bh=rjh6z4h5mztLn1TiTyDYmIudpuMlJTjkI61g9gpOqm8=;
        b=B8QboeOh+vmpjafhQfiFOQpbE3rU6fmEqGY3WLICNLwjXB5j1O2w1IzMCx7p99nvhY
         P2gcRo+jbC9a+UkJlBcs2eybLZKXxf8vcoxQpRfiE27SovKAAGTrd65mdcZFphMmZlos
         opK9Ia4hZbwf+72tCTFC/7X+TTxLpaNUuKN9nZuOfNYmyNwhEQ1P/xxTVwwkWsKjrj18
         kRViY/ObGhs6UgazXi6QnFOEGXvjCz/QKTDUIZFnliLw9ygyEpe715mCNL2fn6QwLhZE
         Z67y47GwfdG2ckdo2ay/F6g/r4WuipVJpO6aAkdN0NJEN11vun9FewhFWs8T4qbLISD5
         PYaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.215 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAUmU8RZaIFpBklAjm87o0F1m/k5z48IXhFuWNa8mJ/nvX6TexTr
	IUqmq8vvhyhsei5gRhurLY04P602DTRNXSHd5iA0pbKoPWaBsQsuYcypwI6HcHKHN1nf8jOzVXf
	Pmv7LE6UvAhWknpzIyJ+qvTJAQc6rd3BFfYsRZZwoP26Kiwxbkc60oBYlYZEQevL/gg==
X-Received: by 2002:a17:90a:3ae8:: with SMTP id b95mr19190977pjc.68.1560664146509;
        Sat, 15 Jun 2019 22:49:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx//LuM4CAHlocH2BbGe8AFS9g1iewP1wKkr2ZSsJ5Oj5aH6fa0xrR9J+imwtreFMzCFpn6
X-Received: by 2002:a17:90a:3ae8:: with SMTP id b95mr19190935pjc.68.1560664145653;
        Sat, 15 Jun 2019 22:49:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560664145; cv=none;
        d=google.com; s=arc-20160816;
        b=R+zKZTjQGM0u2hFgNHpwpPesBxyvfHJmwBe9rVkF6f+evjrzRPK/ysTu7ZqsizfYtO
         01lrFSVGIsFeOawoG2RDmcedg+CTyk1B92gvEClMommB0c+7V/8xVxN2TgX4MQUBlmbu
         cz2hurD9hfWj2eIGVyvJZNXNFpjQy76hm9YV3/B+3svuk0uc9bIiaOj33gbQuBFcfq2n
         pD0+54gJb1dUEB6bkQmQ/xg7uDY07YVnISm8oaANd6x1yNrNdaK98s7kVST1xzwvQ8CC
         r5+8ofVWDQM6UOctgvdu56emrrXC6KVxb0aghjHV9h5LfgVMQSW9iHoU0TRx0m8PEX+I
         8yTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:user-agent:content-disposition
         :mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=rjh6z4h5mztLn1TiTyDYmIudpuMlJTjkI61g9gpOqm8=;
        b=tfOTGcmmbU7KKpVK8kguzCPa5RO2cr9kdlfA24ClsbwqI5CVHae2hU8M/Fdo2g0kRA
         nseyfCwu+9iVZA5vr6DhlUxQd50A8APHq4u9Pw0oo537NXHQ/TiTjs8j5VOn3PF6cCj3
         biitOXF8zaYKPL9IrjpmQVAD2hQzqHiEnOR+dQG4Zl9EiT9lIBXb7iWxY7YY984QFfqJ
         FNFaO9dp6OgvN9BgdUZrTB1jWUJKGnCGsTFSIEfx5vA+gk5eyC4uIbssWIX5DtOKvN7o
         5gvOW8UXpaQ+be0B9kNz4C/oHssdifOTr72IXx6qkGJpG+AMB57QBPmgd8HHwJOo01D8
         jTdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.215 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-215.sinamail.sina.com.cn (mail7-215.sinamail.sina.com.cn. [202.108.7.215])
        by mx.google.com with SMTP id j14si6899042pfe.183.2019.06.15.22.49.04
        for <linux-mm@kvack.org>;
        Sat, 15 Jun 2019 22:49:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.215 as permitted sender) client-ip=202.108.7.215;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.215 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.116])
	by sina.com with ESMTP
	id 5D05D84B0000018D; Sun, 16 Jun 2019 13:49:03 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 470228395869
From: Hillf Danton <hdanton@sina.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>,
	syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	jglisse@redhat.com,
	LKML <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	yuzhoujian@didichuxing.com
Subject: Re: general protection fault in oom_unkillable_task
Date: Sun, 16 Jun 2019 13:48:51 +0800
Message-Id: <20190615134955.GA28441@dhcp22.suse.cz>
In-Reply-To: <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
References: 
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190615134955.GA28441@dhcp22.suse.cz/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190616054851.XS-MCkU6KtmEMDze8SQKKfnRjNXDGpLc1YJ_xWpWTbI@z>


Hello Michal

On Sat, 15 Jun 2019 13:49:57 +0000 (UTC) Michal Hocko wrote:
> On Fri 14-06-19 20:15:31, Shakeel Butt wrote:
> > On Fri, Jun 14, 2019 at 6:08 PM syzbot
> > <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com> wrote:
> > >
> > > Hello,
> > >
> > > syzbot found the following crash on:
> > >
> > > HEAD commit:    3f310e51 Add linux-next specific files for 20190607
> > > git tree:       linux-next
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=15ab8771a00000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=5d176e1849bbc45
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=d0fc9d3c166bc5e4a94b
> > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > >
> > > Unfortunately, I don't have any reproducer for this crash yet.
> > >
> > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > Reported-by: syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
> > >
> > > kasan: CONFIG_KASAN_INLINE enabled
> > > kasan: GPF could be caused by NULL-ptr deref or user memory access
> > > general protection fault: 0000 [#1] PREEMPT SMP KASAN
> > > CPU: 0 PID: 28426 Comm: syz-executor.5 Not tainted 5.2.0-rc3-next-20190607
> > > #11
> > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > Google 01/01/2011
> > > RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> > > RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> > 
> > It seems like oom_unkillable_task() is broken for memcg OOMs. It
> > should not be calling has_intersects_mems_allowed() for memcg OOMs.
> 
> You are right. It doesn't really make much sense to check for the NUMA
> policy/cpusets when the memcg oom is NUMA agnostic. Now that I am
> looking at the code then I am really wondering why do we even call
> oom_unkillable_task from oom_badness. proc_oom_score shouldn't care
> about NUMA either.
> 
> In other words the following should fix this unless I am missing
> something (task_in_mem_cgroup seems to be a relict from before the group
> oom handling). But please note that I am still not fully operation and
> laying in the bed.
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5a58778c91d4..43eb479a5dc7 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -161,8 +161,8 @@ static bool oom_unkillable_task(struct task_struct *p,
>  		return true;
>  
>  	/* When mem_cgroup_out_of_memory() and p is not member of the group */
> -	if (memcg && !task_in_mem_cgroup(p, memcg))
> -		return true;
> +	if (memcg)
> +		return false;
>
Given the members of the memcg:
1> tasks with flags having PF_EXITING set.
2> tasks without memory footprints on numa node-A-B.
3> tasks with memory footprint on numa node-A-B-C.

We'd try much to avoid killing 1> and 2> tasks imo to meet the current memory
allocation that only wants pages from node-A.

--
Hillf
>  	/* p may not have freeable memory in nodemask */
>  	if (!has_intersects_mems_allowed(p, nodemask))
> @@ -318,7 +318,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  	struct oom_control *oc = arg;
>  	unsigned long points;
>  
> -	if (oom_unkillable_task(task, NULL, oc->nodemask))
> +	if (oom_unkillable_task(task, oc->memcg, oc->nodemask))
>  		goto next;
>  
> -- 
> Michal Hocko
> SUSE Labs
> 

