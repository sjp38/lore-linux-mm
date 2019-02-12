Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACE8FC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:11:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 741A92186A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:11:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 741A92186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EC028E0014; Tue, 12 Feb 2019 05:11:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09BA28E0012; Tue, 12 Feb 2019 05:11:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA68D8E0014; Tue, 12 Feb 2019 05:11:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE518E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:11:12 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w51so1973907edw.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:11:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nvEti5FG2smiIlnhwGRqK4//x6gtDsO83up5B2XfB1g=;
        b=MktQCzV71l9umdGZ2RG3UgLgXLEyf7/tVujWnotCmC4xo9d+FI7RTmYBWWSDL2jYWC
         55rwL5O1UVg2jjy2Di2cweIz3Q9mwENePxhOanMrCk2c0JuFSHKCxxs3u+4w3AjNiAc4
         uoA/L1s4jNeKEmr4M9GFZBg9WoKLCyHuj/sO6pRmzWczt3lRotY2WgkY+FmURyRB+Pab
         opulyxn/BaNl0zRQ2B8AjQG9bNtkUSFprWngTZih1kC9CthYP5x/wjeTT4EyvCuD3kjW
         wowMAWai0c8ZJkBeGvz7j+g54RXumLtwv9mk9l9dwyTjo1rIZT4/0AwvXu6vmVBok/Mq
         M94g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAua00aoy1CkleYHuEtZP4Neio3ZMfpDX1XRNlaPvAvIM2UK2qLQ2
	eYvmZjK+J3W3jlf5F2V/e2KLcwXeT145nhkvphOQtSg9x+x9INBkwLzEGyHsCQwywhFiJOnm2mT
	hNdvRnhkHcRPYeVw3G4Z+5sVSiPjbrKmxDjY3qoQzCRZ01/tghby/P393JlibjmY=
X-Received: by 2002:a50:b5c6:: with SMTP id a64mr2470328ede.112.1549966272113;
        Tue, 12 Feb 2019 02:11:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYzMWnFvZ71ru4tW/FWiRz5SVmrVInFC821y52axklg3k6ggTczpx7On4TSJMYAzO20TS6U
X-Received: by 2002:a50:b5c6:: with SMTP id a64mr2470285ede.112.1549966271316;
        Tue, 12 Feb 2019 02:11:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549966271; cv=none;
        d=google.com; s=arc-20160816;
        b=pay4OAO5OEmBBbx4whkFjaR0fnb0mS8B7x8Iw5toVkxTMAkbPUqNahM3xC9qyCJmDt
         GXHualFBn7F/58dBxs5bpLIehRWOIAI7MvyzirPtOs3TOwcWwDfcYH+iXK5/judE8vdj
         4Ign6GZ5wEcLBlu5Qr0a0Ha7S2/XpBLde190ZEQHnr12HI4szQUqfA9ZwWo2zu+vvwz5
         3/uamjTzjNkPAz+d2lzu4dWozfJ10lDAwkmjTI82RxGs6b9iynSwF05xwqzvNie7TM2N
         zvfb+ojejJ5Hxz7q/rbK8C91Kg8s779VrEN2biLcC+tSRqMZ5nclJJFcu2oRjkZi/FHZ
         w68g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nvEti5FG2smiIlnhwGRqK4//x6gtDsO83up5B2XfB1g=;
        b=rCmkWrO0Kmc+Zp1QfCtOrnqy+rytQBMpmIBKZWisahpIqFGo66L1Ip0dAknbUHc4j/
         WrmZflXfz1929vleJIGSdIm+6t1nkEsM/Bu3MgNx1twfqFIn2v1omPYzM0uzvea3O1yB
         ZnQsC/QY9Lf9hn/GqvA7uTZhvBOlY721VxWjXouGl83Ok798yUeNbjmQgc7RGKy7E9HG
         DU+Kb6LuMANDV8FZDBPIL7cbPLyMICxa8XyKFgm+5SqBcT4h++PiSXqHgoPHoHNodO4z
         kAmGHaYwF/bgh51HLhybMTZ2gycbIqUGDaxrRTstrQ6/pwgDPkyda81y1gDP1ir+qQSt
         hQjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dv23si3589002ejb.4.2019.02.12.02.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 02:11:11 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CDA6DB25D;
	Tue, 12 Feb 2019 10:11:10 +0000 (UTC)
Date: Tue, 12 Feb 2019 11:11:09 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Chris Metcalf <chris.d.metcalf@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org,
	Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
Message-ID: <20190212101109.GB7584@dhcp22.suse.cz>
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 07-02-19 18:53:09, Tetsuo Handa wrote:
> Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a ("cpumask:
> introduce new API, without changing anything") did not evaluate the mask
> argument if NR_CPUS == 1 due to CONFIG_SMP=n, lru_add_drain_all() is
> hitting WARN_ON() at __flush_work() added by commit 4d43d395fed12463
> ("workqueue: Try to catch flush_work() without INIT_WORK().")
> by unconditionally calling flush_work() [1].
> 
> We should fix for_each_cpu() etc. but we need enough grace period for
> allowing people to test and fix unexpected behaviors including build
> failures. Therefore, this patch temporarily duplicates flush_work() for
> NR_CPUS == 1 case. This patch will be reverted after for_each_cpu() etc.
> are fixed.
> 
> [1] https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net
> 
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

This patch is ugly as hell! I do agree that for_each_cpu not working on
CONFIG_SMP=n sucks but why do we even care about lru_add_drain_all when
there is a single cpu? Why don't we simply do

diff --git a/mm/swap.c b/mm/swap.c
index aa483719922e..952f24b09070 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
 
 static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
+#ifdef CONFIG_SMP
 /*
  * Doesn't need any cpu hotplug locking because we do rely on per-cpu
  * kworkers being shut down before our page_alloc_cpu_dead callback is
@@ -702,6 +703,10 @@ void lru_add_drain_all(void)
 
 	mutex_unlock(&lock);
 }
+#else
+#define lru_add_drain_all() lru_add_drain()
+
+#endif
 
 /**
  * release_pages - batched put_page()
-- 
Michal Hocko
SUSE Labs

