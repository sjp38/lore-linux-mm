Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63537C06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:39:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34C102146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:39:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34C102146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA30E6B0006; Mon,  1 Jul 2019 09:39:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A54F08E0003; Mon,  1 Jul 2019 09:39:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91C2F8E0002; Mon,  1 Jul 2019 09:39:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f207.google.com (mail-pf1-f207.google.com [209.85.210.207])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA0E6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 09:39:11 -0400 (EDT)
Received: by mail-pf1-f207.google.com with SMTP id d190so8825852pfa.0
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 06:39:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=mAA39mzQ/VqHIDK5eC8lPHsSJ2x1X94vqodzI+8gpIY=;
        b=gufpl093JoDcxE7X/xpfK1jaz0/UtAOvNGSeplC4rqMc8NKEhrhY+VpVL0tXLPGQp6
         fcDnBZV7diOA9tEpspOfMr9UoGKkQgJ6b/KIFfgCMFwQBDmuI/pAUav2gxupwY2ViYV7
         9PYm1gIjk7Hof44eIq1htLl+i9qUHAI+0tvBlYjLXvag45ZSnVysTRaFvI+6H1N3/oJU
         FepouWMtAN+Xj3PMATdLko9HG8a4YKAtYpAe9jgK1PuTJ4ld8PJvBuaxkhOgOCJzrSdg
         3FFK9Gl6ChfeTgxHsTgY861yWrDcGkFMt5qgT5E40TW0RUUXuSf5gMAs0SeCcL1fvgW3
         238A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAVVfrt641vP0dcqoU3d3vhwP0u5sAaw9R7YtcD/G706BV5bTZnU
	E1NCxj7B+rvnr5LUUHlLS6+meOMvsjOyRj7ghDIDgWhu48o/Eb59qZ0tevhpPDaaZZWgvaSDwf8
	AvcH2pNXuhQyhrkn7tKe8HMntVmzhszJUkCr5x1snA94aAgO0kLWi5PdYBkHdUqtPtw==
X-Received: by 2002:a17:902:a5c7:: with SMTP id t7mr25504517plq.288.1561988351033;
        Mon, 01 Jul 2019 06:39:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylVq0SY/lipHXLflcS9EsMxCGfi/6bbRRG+M6O3mUJv4WBbdKURdT4KLWVZNKotPfcIOyb
X-Received: by 2002:a17:902:a5c7:: with SMTP id t7mr25504451plq.288.1561988350348;
        Mon, 01 Jul 2019 06:39:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561988350; cv=none;
        d=google.com; s=arc-20160816;
        b=RUkR88yqOn+RvpjGsI1jH9jABsuwpru2WfaL8MzrXF2Z/3WPsh49lRqkCJeUQCGM5l
         ra2W4Ae4FIBwAIvTCH3cbLhSiEXn3uqo5hX9n75TpyYNuS53TpjSfdMFUn0OcK8YfTvy
         2ZdmChix/TcLVeN4eGWs29iNwIXtcSlluAsWG1J4+0KRKfXxWOcY/SKgUlQdqOVN+pvv
         CFqc50QyiCRNdCbKhjs4YMYfKp/pK3XF4kRE1IKZAdxR8Z6lD18tIo8LzJHdgy9DQafg
         7fjdwyXRA5rVdqf3krPLKDqToz0E5FSUPvNUB6kppabOfRzlgG0gJL/NIkHBdB9yySLw
         cIpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=mAA39mzQ/VqHIDK5eC8lPHsSJ2x1X94vqodzI+8gpIY=;
        b=TfgLBaxAAvi5OdcYW4xLQo0fEKp1aD4jGGoumlUZlUVjkXRKaRfcFBkbL4EQ/opxSj
         LlWFedKtxgGI0Icytlcz+65VI9wtDamK7KLOROHEj8/GXvum0PjdUwaI9wGI7yzgI+wl
         89zrIJmM+2dyD/HzzDO8o3ZymQyJvq9A2HL7+6wtAlLSSCvSv0c2Bw15DE0Z+VIgwgD9
         Yu6MWMKiPRGgnbSWectiOsaPZ3ppdTnXNYbMeZlmwNN2LcL0e6bcTbEVOpppZiDVgnHs
         dJJ/KcJ7V38Fcb6TmTaY8gz5wJPmnHkHE6Uq6JNg0/JYYOGZNCCO1lDxJW+4wsbPkKkX
         xwwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d24si10142577pgg.147.2019.07.01.06.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 06:39:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav305.sakura.ne.jp (fsav305.sakura.ne.jp [153.120.85.136])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x61Dd3Bh068986;
	Mon, 1 Jul 2019 22:39:03 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav305.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav305.sakura.ne.jp);
 Mon, 01 Jul 2019 22:39:03 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav305.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x61Dd1Bx068912
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Mon, 1 Jul 2019 22:39:03 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
 <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
 <20190701131736.GX6376@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
Date: Mon, 1 Jul 2019 22:38:58 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701131736.GX6376@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/01 22:17, Michal Hocko wrote:
> On Mon 01-07-19 22:04:22, Tetsuo Handa wrote:
>> But I realized that this patch was too optimistic. We need to wait for mm-less
>> threads until MMF_OOM_SKIP is set if the process was already an OOM victim.
> 
> If the process is an oom victim then _all_ threads are so as well
> because that is the address space property. And we already do check that
> before reaching oom_badness IIRC. So what is the actual problem you are
> trying to solve here?

I'm talking about behavioral change after tsk became an OOM victim.

If tsk->signal->oom_mm != NULL, we have to wait for MMF_OOM_SKIP even if
tsk->mm == NULL. Otherwise, the OOM killer selects next OOM victim as soon as
oom_unkillable_task() returned true because has_intersects_mems_allowed() returned
false because mempolicy_nodemask_intersects() returned false because all thread's
mm became NULL (despite tsk->signal->oom_mm != NULL).

static int oom_evaluate_task(struct task_struct *task, void *arg)
{
  if (oom_unkillable_task(task, NULL, oc->nodemask))
    goto next;
  if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
    if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
      goto next;
    goto abort;
  }
}

