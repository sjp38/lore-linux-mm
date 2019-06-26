Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95356C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 10:19:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D49220656
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 10:19:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D49220656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C54DF6B0003; Wed, 26 Jun 2019 06:19:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C04FF8E0003; Wed, 26 Jun 2019 06:19:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACC098E0002; Wed, 26 Jun 2019 06:19:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7361B6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 06:19:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x9so1459833pfm.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 03:19:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AHTzdc03gk3QfLSVBo1e+tq/sBQmgmil0nN6bCPjqoE=;
        b=Jt+l2OWPUaPrht+UdZtmJd+kRpaB74SN1uABlIEyLjNltUwA1fs+f1MNoHNvUhxEGL
         Gjx1JiUZRjJqLvQtLu4GRgRTtRjH4/WuSjins3RsjPMZAd9h8U5jn8fCtjVSrt/2nBub
         6hdwQWtYnS779uZgkLKxnJ1hxtUDaqh0onNvIeufokBQz5k51Usp1xXsosa6QoHxxLu5
         RLnt/QxWLb6E9jal7i2A2VkVcsPydiN9g4WACMwViKa9X3aC4x0fK3GLCEehQRe3Y320
         UENIve8sN9oGuSc/7yrFQcd50GaUG8y16/hM08irxhRa6NWiUHcHQDgqIxZrF3LJ1XWX
         VnNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAV0L7YFSzc/7HfujQBQ2UErLAqMd+pg7bxNx0KtT8Sp71IHXqtP
	LrCz0O2xEo5PVEImVJrktKpkY5xHrCJVwI/xGAMi3sDs5AuFb6g0Sc8Mw22NhPNsT/PNhT2Px+E
	OmUqchqJdzKgkJa/OC7NiPToodwASwtwByhVKh/XpY5EpY0ScOm2xXJbE1HxmZGWZug==
X-Received: by 2002:a17:90a:d983:: with SMTP id d3mr3778970pjv.88.1561544377066;
        Wed, 26 Jun 2019 03:19:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykmVPsEqvCPZCLOtuhp5sOc91nTFE7pWeCpL2flcBf+shM7GffO2S0dmn8KrlsV3Zia9r5
X-Received: by 2002:a17:90a:d983:: with SMTP id d3mr3778919pjv.88.1561544376325;
        Wed, 26 Jun 2019 03:19:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561544376; cv=none;
        d=google.com; s=arc-20160816;
        b=MgPxNhmbRjf/amfmu27Uz/wCXJTkK5Fd5WXlqrNZMDKKPPR/QTnwTzuwJ/FZw5HmCp
         MBxt06BqH/6BaarWMrpkVc7MFYg03Jm9fOR59cAl4Th4V6QysV3METmGrjG8LNDmsv2M
         m+9tdh7W2y/mlKmvTp2TUg/ZG0E5NVQDeaBS9lHIakJmPNZNwAJx6AJWq+iLFZL55tqb
         pPQmsHTNDo6CkoEDyELI/BuoNMP8ZXUFDkuukXK9c9F+ECadj27gTJf9e19DCvMoNloL
         OhrpWJuvIsEK3Q/XwAVVm0Dyf4yHbMp5VlIKC8qrr26Cl3RVrfwGqMzWWcxPjmfhFqN1
         PJRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AHTzdc03gk3QfLSVBo1e+tq/sBQmgmil0nN6bCPjqoE=;
        b=AJuskpJkHQeQ3KC4uKbAyKwb7dQifu7WNmvujyLNMTsc5W/JcpYJEwynG4HIYyldLV
         gJgyO1EjkYZtgkcfnk5EMGA+LGfewtW9wQEAKJxgUoyCDVHS+TgbsM1cF9YffB16zaDg
         1Z5HZUx6thKQSuf+IKBfVfqYm4uILdhDijJYHxlPwwrtHrVRnR+T4SQ3d4usUi3641Av
         cbePZC332rJp9/u2k2hmBeIqLdzmTnxJThHDk75WhHWlvDBG7zhPzf3FZ2dmmpRCqOj2
         On56gV/k/K14+qx1DbHUgZ2xgHWvWmhk7t0JTWRw/x/xMftneVAL6RFTyPiMXEdfH7b+
         mBqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l21si15398841pgb.409.2019.06.26.03.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 03:19:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav403.sakura.ne.jp (fsav403.sakura.ne.jp [133.242.250.102])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5QAJSRF018462;
	Wed, 26 Jun 2019 19:19:28 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav403.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp);
 Wed, 26 Jun 2019 19:19:28 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav403.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5QAJOje018412
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 26 Jun 2019 19:19:28 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from
 oom_unkillable_task
To: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>
Cc: linux-mm@kvack.org
References: <20190624212631.87212-1-shakeelb@google.com>
 <20190624212631.87212-3-shakeelb@google.com>
 <20190626065118.GJ17798@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <a94acd91-2bae-0634-b8a4-d5c8674b54f2@i-love.sakura.ne.jp>
Date: Wed, 26 Jun 2019 19:19:20 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190626065118.GJ17798@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/06/26 15:55, Michal Hocko wrote:
> I think that VM_BUG_ON in has_intersects_mems_allowed is over protective
> and it makes the rest of the code a bit more convoluted than necessary.
> Is there any reason we just do the check and return true there? Btw.
> has_intersects_mems_allowed sounds like a misnomer to me. It suggests
> to be a more generic function while it has some memcg implications which
> are not trivial to spot without digging deeper. I would go with
> oom_cpuset_eligible or something along those lines.

Is "mempolicy_nodemask_intersects(tsk) returning true when tsk already
passed mpol_put_task_policy(tsk) in do_exit()" what we want?

If tsk is an already exit()ed thread group leader, that thread group is
needlessly selected by the OOM killer because mpol_put_task_policy()
returns true?

