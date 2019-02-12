Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61149C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:25:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 253F221B18
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:25:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 253F221B18
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B40BD8E0014; Tue, 12 Feb 2019 05:25:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC8108E0012; Tue, 12 Feb 2019 05:25:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9904A8E0014; Tue, 12 Feb 2019 05:25:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1988E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:25:58 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q11so2103502otl.23
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:25:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dgfUEk8dmGnokeFHsyOT+o9oihw59qT/Up0XnHiPUr0=;
        b=UROisUgen6/DHXv9T/7hOpjaFPOwtRq3qgDNBsQn78no43l5SxCprtTJxbHcasWZBg
         lmY3Wj6u+QMYZXZiFkg3tmMgpGd02fL+mY2McOyusv84op6VJjrwvJOCQ2kq12PzPWIt
         wOp/AoDKwQrUxw0itT+Da+NrINGu7ec6d1jAPWZlm4uVfqMYnz8aiY5cqf5Tpob+sEr/
         cJ4ls0YL4m0r4lVMpDQ72QdrCL7AzIcm+UcIvYubz1oIt3NhHsasi72wuMXcVoAlGQDK
         lUSVjYSdSe3P1B0fT5cDjPdpZ3Yniyk/JxeP8ekFGV8OqOL4pq7nhNrEtMb3V+Ynz2BE
         SPTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuYTXyFDKnN/0qIA2iq3azHvoW2IcqqGN0B5F+Lp9plQ30RQNXhY
	plZmkoK67dYLcZKYeK0idIZqRTOpvVj+nYiBswdUk+qfPSe6F0TMENRrsuTsBNFt6lI91UY8R58
	cnBeqv/L40Ly0DntL4FWUI/LpzfkTe3kjEo64uvtlYM8mvAa3HtXtfZ1a3MtuUkcpHw==
X-Received: by 2002:a05:6830:2015:: with SMTP id e21mr2787883otp.69.1549967158153;
        Tue, 12 Feb 2019 02:25:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaHLo38IGflbvvguKOp1BsLHNpCayI7OXSvksaMHjjx0ujnyYTjl2k2pzx7cGr3GFrZD9hV
X-Received: by 2002:a05:6830:2015:: with SMTP id e21mr2787848otp.69.1549967157529;
        Tue, 12 Feb 2019 02:25:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549967157; cv=none;
        d=google.com; s=arc-20160816;
        b=z9Q2dcf02xruvOaLJDZg1WOCPPEBbXg5WmBeyMJRQsnJXx1RR6S0hpmXtjvVULPM9Y
         VTv+Xu7IJ3HbIIhwE5pK9J9gzGNobBE+nSrBm+By/qbPxICkffGnBw6zBeqF4l5Jvbi9
         1ldC3GKqOfX6fWak2iiVThGRsBUlTJlfu6z8hMaxnR5wapP6cgNoyMj+1v8dUAn+Z2Ut
         BmhrZqmTVJWuNuVVzZ0TPEqk9OABneSM1sV0GobsOV8w2tqBHMNQDodz79v+ax8kXbG4
         K3wwIqsSjpSEigj95ZvTNPFb7tYHDFriozmnKfX/raX7+XzEYNYD/dVXkKnEBP2u7nTD
         9QVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dgfUEk8dmGnokeFHsyOT+o9oihw59qT/Up0XnHiPUr0=;
        b=cAhA2FsdH288SaCpKzqSMwgo7S7cW8Zr9tMB1WiVoGmaZX55V4tw5egnKWxuPAbMxq
         iiPdqxs+NWPyIDTuS1KtyCVI/Jv/JV3RH2j/oU9NrSvhAV49afqsZTxfpMlqXpWIGx74
         9AzW5DGxBLKgYAebBS+yCzt+8wuxPIkz3xIrud7kkTtlpVVZuTWV/re8bCo9Zsm3QG7i
         cnfFfTkRS4iRzK+ltZrZVB5qGpRblfDnWeGWXMpvtxhX655xHqWZfzC/vuJk8P+ODUHQ
         xtddqVLEHiuwzU25VdUz9wTiXdgnNbgBYin/LgbXPEzUrk1yI7QTkTJs/l60FaDFZGH2
         uiYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m93si5484965otc.101.2019.02.12.02.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 02:25:57 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav108.sakura.ne.jp (fsav108.sakura.ne.jp [27.133.134.235])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1CAPoA5022107;
	Tue, 12 Feb 2019 19:25:50 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav108.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav108.sakura.ne.jp);
 Tue, 12 Feb 2019 19:25:50 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav108.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1CAPjLo022009
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 12 Feb 2019 19:25:50 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Chris Metcalf <chris.d.metcalf@gmail.com>,
        Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org,
        Guenter Roeck <linux@roeck-us.net>
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190212101109.GB7584@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <82168e14-8a89-e6ac-1756-e473e9c21616@i-love.sakura.ne.jp>
Date: Tue, 12 Feb 2019 19:25:46 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190212101109.GB7584@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/12 19:11, Michal Hocko wrote:
> This patch is ugly as hell! I do agree that for_each_cpu not working on
> CONFIG_SMP=n sucks but why do we even care about lru_add_drain_all when
> there is a single cpu? Why don't we simply do
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index aa483719922e..952f24b09070 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -660,6 +660,7 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
>  
>  static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
>  
> +#ifdef CONFIG_SMP
>  /*
>   * Doesn't need any cpu hotplug locking because we do rely on per-cpu
>   * kworkers being shut down before our page_alloc_cpu_dead callback is
> @@ -702,6 +703,10 @@ void lru_add_drain_all(void)
>  
>  	mutex_unlock(&lock);
>  }
> +#else
> +#define lru_add_drain_all() lru_add_drain()
> +
> +#endif

If there is no need to evaluate the "if" conditions, I'm fine with this shortcut.

