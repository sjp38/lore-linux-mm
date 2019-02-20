Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77796C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 06:49:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C3572147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 06:49:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C3572147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9EFB8E0003; Wed, 20 Feb 2019 01:49:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4B9A8E0002; Wed, 20 Feb 2019 01:49:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3BAA8E0003; Wed, 20 Feb 2019 01:49:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 584068E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 01:49:43 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d31so5436792eda.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 22:49:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wXyBJqHcDFk0xkJ3TWSt09RQsSKfDF/AeBBhv8WwpjE=;
        b=DV5euPiPgUn2IkXkXRchWtJ5SJcbRolYKr2DkNLwDwZp/qERxQ0WN6tEo5krkR8xzk
         P2SPc9GbbfBnBpIsBsx7WpTVA+0wrv9HV3viSzVz5yxCQIdImKqjHCwDM4f+Eo0gm7vr
         ahWPy3XGa7G5UiCkL90+P8KhkstphJ0ldmeZk1nqMFy9PiNtXyPgitAcuAZQm09CpKAv
         6Jmk1OVyWjm0jLG58erFjzNDXLgegb3n9ztzx0CcVPTpmV2lpiXBotSDHba+jA23pT5l
         ZKMI2XxEFU8gs3k4+PztFRcamT9cquHwC34IYkP9VDpcWAQ6pm2lxOT8Tj+qLTjFj1o+
         neVg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZqPCsQxEcKmu2LXO40gllOxRakxgM2FJXnADOTNcZF8ysOIB2t
	kwv+YKUplHDHyHGfD8nUqsyTXHoHjWg2Y/ABAt2Ms4L3FJ5KW5azb8b6HqC6YOdN1YzwLvMNpu+
	HV0HWFG0VIG/N4SoJ4KLHVEeuddIeb2NKuTlebnzl0IAizfA2lifG1j7uH6i7ukE=
X-Received: by 2002:a17:906:b350:: with SMTP id cd16mr5994165ejb.203.1550645382870;
        Tue, 19 Feb 2019 22:49:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJqTY8HCxd+BjFlf4yYSTnkkQCYzscqB1cFpKgKTql9oQvQ2TBpYWh1HIcHQPGPjIZpHQt
X-Received: by 2002:a17:906:b350:: with SMTP id cd16mr5994123ejb.203.1550645381967;
        Tue, 19 Feb 2019 22:49:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550645381; cv=none;
        d=google.com; s=arc-20160816;
        b=UJDSoP+IIl5vj0TH8e4qggKKH2dGBxJOu1vmJiPwAelv9S0IdI8BKEVtfijUF0xjb0
         nAR1CUfgDsUZaBR7EpURpYPiECLIATWy/f6l+/icOKDGEDTj9t1V8id2GF/NIzXQLV/O
         dxi3gkILinOk511jTyejD0nHmWWT0r2ONLQE5yA9t84dMlWEVQK6BmH+6c+sXMbsFBsj
         FaVyU5LKqTaEy8w6zMCyzEa7P2ZEeZ27oPsrd5V1CUOK9T0UodlrEgQEjdg66OxU4749
         rTSd1bzIVhb1GyrekWDIZGtzfQSPBBqAhh1APLVYMP/NXIOF7R1gzIDw/4O8OAK8lBem
         NHMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wXyBJqHcDFk0xkJ3TWSt09RQsSKfDF/AeBBhv8WwpjE=;
        b=yrpusOPHd3SVqfMGf9ETMMNf0Xdr3E/+CkFx3tEK1GDqVgOVwdfjjxbrR4r3euRP/L
         3yt5uo/gTKg2+bcZnkoFbV5Yr0FxHsLkzSWL+blX0tTcWAUUAdO6vWo1e5ARGegePPQ3
         XIS4WC/ur7AUhUVKMSRokDQtrAW7pCzDyX2JPZHUyxU/SQ8XGSyjCNgnTAe5EEvmRPNj
         gJprqQrRkWjGSQ6cXifx/mmlKHYoXRWSW0uHpKN5Q9Xq6oRSkkdC7eLMck71JRw+pRNI
         QDLQKV9CsvZa68G+r8NXTp9nWdXnFtdowiuQQVnf/MFgj/C6iAJmZbg3MlGyCqE0WT9t
         GArA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a48si2645455edd.336.2019.02.19.22.49.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 22:49:41 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83AA9AF9B;
	Wed, 20 Feb 2019 06:49:41 +0000 (UTC)
Date: Wed, 20 Feb 2019 07:49:39 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Stepan Bujnak <stepan@pex.com>
Cc: linux-mm@kvack.org, corbet@lwn.net, mcgrof@kernel.org,
	hannes@cmpxchg.org
Subject: Re: [PATCH] mm/oom: added option 'oom_dump_task_cmdline'
Message-ID: <20190220064939.GT4525@dhcp22.suse.cz>
References: <20190220032245.2413-1-stepan@pex.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220032245.2413-1-stepan@pex.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-02-19 04:22:45, Stepan Bujnak wrote:
> When oom_dump_tasks is enabled, this option will try to display task
> cmdline instead of the command name in the system-wide task dump.
> 
> This is useful in some cases e.g. on postgres server. If OOM killer is
> invoked it will show a bunch of tasks called 'postgres'. With this
> option enabled it will show additional information like the database
> user, database name and what it is currently doing.
> 
> Other example is python. Instead of just 'python' it will also show the
> script name currently being executed.

The size of OOM report output is quite large already and this will just
add much more for some workloads and printing from this context is quite
a problem already.
 
> Signed-off-by: Stepan Bujnak <stepan@pex.com>
> ---
>  Documentation/sysctl/vm.txt | 10 ++++++++++
>  include/linux/oom.h         |  1 +
>  kernel/sysctl.c             |  7 +++++++
>  mm/oom_kill.c               | 20 ++++++++++++++++++--
>  4 files changed, 36 insertions(+), 2 deletions(-)
> 
[...]
> @@ -404,9 +406,18 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
>  	rcu_read_lock();
>  	for_each_process(p) {
> +		char *name, *cmd = NULL;
> +
>  		if (oom_unkillable_task(p, memcg, nodemask))
>  			continue;
>  
> +		/*
> +		 * This needs to be done before calling find_lock_task_mm()
> +		 * since both grab a task lock which would result in deadlock.
> +		 */
> +		if (sysctl_oom_dump_task_cmdline)
> +			cmd = kstrdup_quotable_cmdline(p, GFP_KERNEL);
> +
>  		task = find_lock_task_mm(p);
>  		if (!task) {
>  			/*
You are trying to allocate from the OOM context. That is a big no no.
Not to mention that this is deadlock prone because get_cmdline needs
mmap_sem and the allocating context migh hold the lock already. So the
patch is simply wrong.

-- 
Michal Hocko
SUSE Labs

