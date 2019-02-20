Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9ACBC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 04:10:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BBB12147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 04:10:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jCwJk08m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BBB12147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B179F8E0003; Tue, 19 Feb 2019 23:10:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC68D8E0002; Tue, 19 Feb 2019 23:10:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98F888E0003; Tue, 19 Feb 2019 23:10:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC6C8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 23:10:11 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id x9so8611347ite.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 20:10:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=N4Q850yr+fMsHUcKZ6Tgg22CC3geAzeDe/zGcgAV7yU=;
        b=Pukn3d+OgWA/mztBYD593psyT3c4ubFrzny+K8nlncX4F9ZTNxXDSDspFtZX7CL9MX
         rgkTVzEQ88cmqdLYvzpVRlUmIruMryD+py+DmZznidFlSfg/39n4XQAbeactJ31Hmogg
         tof0s3qFIlGNXUzvDXaI0sSgyMjv8XhSQiHy8t1jJmdNPqBLea6lzr1tGuAqpml50ICF
         eO9zuMEdZhKVFLBRDCVJhbolrR8y8RCvTMR+1tACMjKoEC3IDs8vUENAOOd3ysMfUmvR
         GcJMIX7VTyuBhpMrBZzbJrUjOMnQWjOrMwMbrefEvSYjFt3RmU6X05R8ZpAcZ3aAHByq
         hTyQ==
X-Gm-Message-State: AHQUAuZSXwRV3waMX/iEd9DUh272VHniCvcTn2QjR1pPoclldGGUMNOk
	ae+LdwtYMjh/eSdzWAh5I9vq4sVptTkN82EXWgNzg4Ec55/amUVA/nLdOcMguXUL5aeODQkYeoH
	Xnklr81jLObrM+iKKsuEj4cdMK3Gbsy+SfA13OIG4HkpTk5PZSkJwM5byz/oT34nJpQ==
X-Received: by 2002:a24:7a85:: with SMTP id a127mr716868itc.46.1550635811157;
        Tue, 19 Feb 2019 20:10:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbGyfMCTykUtVu3zlzGkglm8AtwSj3p1MEgtUP/xOpkd1s9vOLbXTVV4b+LWMtXEFM8PoiZ
X-Received: by 2002:a24:7a85:: with SMTP id a127mr716842itc.46.1550635810221;
        Tue, 19 Feb 2019 20:10:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550635810; cv=none;
        d=google.com; s=arc-20160816;
        b=kVJ23z42biW8UYQy6jyQ086JE8xoUxFvaSLIrZd5qve1M87cdGVqvkXblrDw252eqq
         Miitn8R44vAV2CFJ0QykxC2tZ5L5rnNSMSiyHhP4W/NiohctLQvZxZOplNl0NypZJv1e
         dY9JnN11K/EfPKA/ZYkU0C0KnWuGTH5fEypI9d2RWtCZ+uRbbMkwuzONf8OBDSGURsuI
         NC+To+AGy6ZbZTni994IszbVqAoFk2NiVrngUTCLxy7+WmjlNWdwmsysgcnrSt5t62+7
         AvIrTCcNTm147C6TLVFsn5hWXCM5rP98GgVaIPZnjssqrjPYLL6ABwJdR8c6x9nGcO8p
         zBMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=N4Q850yr+fMsHUcKZ6Tgg22CC3geAzeDe/zGcgAV7yU=;
        b=WRp5+B6j+BKwn6iOZQGresWaqJHXHN7GvV+GcRnU90Rn9OrnoHfMdtIR2+G3dklCKU
         v7Fqm/zwU1UmvxfqLxfPPuW9vwoApU59rQ7QSp7VtdH++xPsscRGZA2PmSRvovxxadgT
         IuGNmT4MMJaYOHYk/AUGObl6Kq7WYO5DS5HcHovC4gUxH3alvccrPHgFeqkXcXTYL3F1
         P9fEf0TSE9B8UG4RMuz2UdwkgkwUOiNgPgRLYZ5snAz6M7wWH3jnLkXTYrN8PjCEinAJ
         ycKBMvyLaZbaHVq9iid+Za3p+G4gKrag27nfskaWTJpAKC4TMR6KuUFbQ4UHbi3E4bjA
         Nhew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=jCwJk08m;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 2si81168itl.50.2019.02.19.20.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 20:10:09 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=jCwJk08m;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=N4Q850yr+fMsHUcKZ6Tgg22CC3geAzeDe/zGcgAV7yU=; b=jCwJk08mlYKvMZOCcnwADJMAnr
	hf392LgiT2W9zeU53/PHpp39kqBGn6zF065fTBDSz1hc/XHNOvCCbDSIVcIExSUQJyPJK8AWGCFYH
	j9vxsrDIqkcSXBGS3xM5Zo5bhsUScflBqABiTDIVpDH8/TTtTK2FJjB7CtijwueouNS69Y/FB/1lk
	VdTR4hNCju46/kZ91mOE08DoTwVm3BQssdFo1cYUPLC/Up8uzuNn9nu52VBuJuJIuBjkyAi5zNdTE
	RCn8gSi0FSx+HpRb2+h2sZEe0OxOMvBtrMI4kdAHMQT71d1dcSA8g+3nEtM4M/4/sBIIq9v5OtDkr
	tZPKUU2w==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwJCk-0001XM-L3; Wed, 20 Feb 2019 04:09:54 +0000
Subject: Re: [PATCH] mm/oom: added option 'oom_dump_task_cmdline'
To: Stepan Bujnak <stepan@pex.com>, linux-mm@kvack.org
Cc: corbet@lwn.net, mcgrof@kernel.org, hannes@cmpxchg.org
References: <20190220032245.2413-1-stepan@pex.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <bc5d4f0f-8cbb-581a-5af3-2f178d6396fb@infradead.org>
Date: Tue, 19 Feb 2019 20:09:52 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190220032245.2413-1-stepan@pex.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Spell it out correctly (2 places):


On 2/19/19 7:22 PM, Stepan Bujnak wrote:
> When oom_dump_tasks is enabled, this option will try to display task

  When oom_dump_task_cmdline is enabled,

> cmdline instead of the command name in the system-wide task dump.
> 
> This is useful in some cases e.g. on postgres server. If OOM killer is
> invoked it will show a bunch of tasks called 'postgres'. With this
> option enabled it will show additional information like the database
> user, database name and what it is currently doing.
> 
> Other example is python. Instead of just 'python' it will also show the
> script name currently being executed.
> 
> Signed-off-by: Stepan Bujnak <stepan@pex.com>
> ---
>  Documentation/sysctl/vm.txt | 10 ++++++++++
>  include/linux/oom.h         |  1 +
>  kernel/sysctl.c             |  7 +++++++
>  mm/oom_kill.c               | 20 ++++++++++++++++++--
>  4 files changed, 36 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 187ce4f599a2..74278c8c30d2 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -50,6 +50,7 @@ Currently, these files are in /proc/sys/vm:
>  - nr_trim_pages         (only if CONFIG_MMU=n)
>  - numa_zonelist_order
>  - oom_dump_tasks
> +- oom_dump_task_cmdline
>  - oom_kill_allocating_task
>  - overcommit_kbytes
>  - overcommit_memory
> @@ -639,6 +640,15 @@ The default value is 1 (enabled).
>  
>  ==============================================================
>  
> +oom_dump_task_cmdline
> +
> +When oom_dump_tasks is enabled, this option will try to display task cmdline

   When oom_dump_task_cmdline is enabled,

> +instead of the command name in the system-wide task dump.
> +
> +The default value is 0 (disabled).
> +
> +==============================================================
> +
>  oom_kill_allocating_task
>  
>  This enables or disables killing the OOM-triggering task in
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index d07992009265..461b15b3b695 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -125,6 +125,7 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>  
>  /* sysctls */
>  extern int sysctl_oom_dump_tasks;
> +extern int sysctl_oom_dump_task_cmdline;
>  extern int sysctl_oom_kill_allocating_task;
>  extern int sysctl_panic_on_oom;
>  #endif /* _INCLUDE_LINUX_OOM_H */
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index ba4d9e85feb8..4edc5f8e6cf9 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1288,6 +1288,13 @@ static struct ctl_table vm_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec,
>  	},
> +	{
> +		.procname	= "oom_dump_task_cmdline",
> +		.data		= &sysctl_oom_dump_task_cmdline,
> +		.maxlen		= sizeof(sysctl_oom_dump_task_cmdline),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
>  	{
>  		.procname	= "overcommit_ratio",
>  		.data		= &sysctl_overcommit_ratio,


thanks.
-- 
~Randy

