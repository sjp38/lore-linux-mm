Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 796AFC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:18:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDF2C21873
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:18:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDF2C21873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B84C6B0003; Wed, 24 Jul 2019 04:18:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6427D6B0005; Wed, 24 Jul 2019 04:18:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BAC18E0002; Wed, 24 Jul 2019 04:18:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10ABF6B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:18:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h27so28000935pfq.17
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:18:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=S07Nz1r4hzK7/gtSB3x+WXE+sNEYGaGmU9AJ/epG1qk=;
        b=uA4EuK8NrPTVekITyaNlRQH9un8jepmIyPhRLdVZ4v2GY+m6byMs3P4Ty7yUVUDSuF
         192m1BYRhIX9LrU1P3vgcxo66+oa3TobAjC48woAH5tMrQcvhJ1RsdovKcdKmFwb7mLE
         xFi22IVgRvmdjPJdu1knWE8P0zCOve/jUGBNEXGcH+dlrWfrbZ073x23n8DizGIsiWRR
         JVaZ53vYqKDfWROJlZM3i4Au7Zh4vr8s4OBYhHUAhZChglaMqGiNSCF5MatVX3j3CHUk
         neNa4hGLWAg4jZwd52AyzOyXNtkptoLrFDUvZ+RqNhD04VZiP8SLqTPpSxehxDM1ck5h
         oqGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAVDgLbA+O6xV0/J5bgOgHd4KDswTzPhVtBRpcu1KjPBQWEicARj
	ybyNDACmg5vQZLzr/58fs6oAXfJi4BkUcJEfrz+4x0rEkN+oFkXQf4mpcgJ1/TwPm171XdnY0wN
	E9mKzpiLBQASIdqysmQBxRzsC0Z2dnR1VqxNEO7f4Va5NQXLlJ2jJbQNQc5kALr3PMw==
X-Received: by 2002:a63:3c5:: with SMTP id 188mr78903135pgd.394.1563956281508;
        Wed, 24 Jul 2019 01:18:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztWhvS3NC1FyvlECBjbVkkumaI0rDed0Xqk+ee+L/os3TfQY7BMedQe2R6u3cv+ZqmWd2K
X-Received: by 2002:a63:3c5:: with SMTP id 188mr78903086pgd.394.1563956280789;
        Wed, 24 Jul 2019 01:18:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563956280; cv=none;
        d=google.com; s=arc-20160816;
        b=fjPu1mlsCaCFonDI1qz9jL3nkK3ODmq/LFzGQ6Skrn8JpE70QFh5QBQdvE3otUpZeN
         rqg66laSV1qFSwtbFYxpvFvfDntTOR9PrUz/8UcbU9r2HExZPh4mIKfH9yg4Ukbcj/na
         alw6FZNRcl4cwMWbl434fsaHQbAN7g7Y4Svf32Cb+bzL5t7+oR2zF+KIzSsx1MXmyy2t
         GhHS4QN+Fp2gSzTiLDgYy0VXexQyQFyZA4IKoLFEWBZtsNIHLIjTORStmrP8hktejUcT
         97LMEMMI1RXCZN+gXgJJrXUhOhLVpDZCOHhP0/B8UIZSPsRc//2KJXwp7EYfe1Gbbr4s
         fbFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=S07Nz1r4hzK7/gtSB3x+WXE+sNEYGaGmU9AJ/epG1qk=;
        b=XiWNgqILTugPQQxGc3EY+uY2mmIjwGIj/6hq+DCSNMJcPFdv4Xu3BkhvHcVw+xBHOO
         D5RSG/cDQ+6QttYPTF5qorU1u9sUffMkawwEtJqfHruI3aHEzDKWfARH4WJaYeux1s+O
         OEjz+vcJfnrJX986wghrQOSxKPrU3KURaN45HzkbugDUZ+ZLGNT7Zw4CUZ0HusLTVuM2
         rBfly1GyIfBcj5bV3XF7ioEbiSXncCM6hD7BJdvXvIV+9T/2I2tBGwbwHNFspwElMXmC
         CzlHgvC+0hU5zaf6dVcJwoRnCtI3Ezo91T2lANPatiShZCFK018P+92km1ExmYoAPx4r
         XN6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 19si16271717pfc.239.2019.07.24.01.18.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:18:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav105.sakura.ne.jp (fsav105.sakura.ne.jp [27.133.134.232])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x6O7blOH086195;
	Wed, 24 Jul 2019 16:37:47 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav105.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav105.sakura.ne.jp);
 Wed, 24 Jul 2019 16:37:47 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav105.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x6O7bV9E086030
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 24 Jul 2019 16:37:47 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm, oom: simplify task's refcount handling
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
        David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>,
        Shakeel Butt <shakeelb@google.com>
References: <1563940476-6162-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190724064110.GC10882@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <d6aebef5-60f8-a61c-0564-5bb4595e8e2c@i-love.sakura.ne.jp>
Date: Wed, 24 Jul 2019 16:37:35 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724064110.GC10882@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/24 15:41, Michal Hocko wrote:
> On Wed 24-07-19 12:54:36, Tetsuo Handa wrote:
>> Currently out_of_memory() is full of get_task_struct()/put_task_struct()
>> calls. Since "mm, oom: avoid printk() iteration under RCU" introduced
>> a list for holding a snapshot of all OOM victim candidates, let's share
>> that list for select_bad_process() and oom_kill_process() in order to
>> simplify task's refcount handling.
>>
>> As a result of this patch, get_task_struct()/put_task_struct() calls
>> in out_of_memory() are reduced to only 2 times respectively.
> 
> This is probably a matter of taste but the diffstat suggests to me that the
> simplification is not all that great. On the other hand this makes the
> oom handling even more tricky and harder for potential further
> development - e.g. if we ever need to break the global lock down in the
> future this would be another obstacle on the way.

If we want to remove oom_lock serialization, we can implement it by doing
INIT_LIST_HEAD(&p->oom_candidate) upon creating a thread and checking
list_empty(&p->oom_candidate) under p->task_lock (or something) held
when adding to local on-stack "oom_candidate_list" list stored in "oc".

But we do not want to jumble concurrent OOM killer messages. Since it is
dump_header() which takes majority of time, synchronous printk() will be
the real obstacle on the way. I've tried removing oom_lock serialization,
and got commit cbae05d32ff68233 ("printk: Pass caller information to log_store().").
The OOM killer is calling printk() in a manner that will jumble concurrent
OOM killer messages...

>                                                   While potential
> development might be too theoretical the benefit of the patch is not
> really clear to me. The task_struct reference counting is not really
> unusual operations and there is nothing really scary that we do with it
> here. We already have to to extra mile wrt. task_lock so careful
> reference count doesn't really jump out.
> 
> That being said, I do not think this patch gives any improvement.
> 

This patch avoids RCU during select_bad_process(). This patch allows
possibility of doing reschedulable things there; e.g. directly reaping
only a portion of OOM victim's memory rather than wasting CPU resource
by spinning until MMF_OOM_SKIP is set by the OOM reaper.

