Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 018DDC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:13:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03213206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:13:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03213206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58FF76B0003; Thu, 25 Apr 2019 17:13:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53F856B0005; Thu, 25 Apr 2019 17:13:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42EC76B0006; Thu, 25 Apr 2019 17:13:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 260626B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:13:41 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id s21so901740ite.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:13:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=sgWKsjsYrpKtKe767qgokEq8OVajFnZ4OEzAdmnqA6w=;
        b=t019MvGwbUGMhPdePMbSz0stZozgRO0IT6LqCP8NzA/yK7z1R6VotXC3sVLNDT055R
         g6AuO7Z/cICV6Nl12QZ/g3xT85se8xMYCzuQwy1F/aaEOYpdInowl0Kr4agk3nGhvjHI
         5FAgVAHMXs5MX6TE3P74KU40YKcUMFeQSlNHuVAd/UDYjXC36vxsdEyZ41/uNSC1cZ0z
         ahLRdHWTJ+A6O/m91+zEbomPAikyZMu1M+lr9NEBcM7ZcUt3WfraH7fuDvkGeXOmstYi
         ILAj6VGb+TowNxJKqeMoVhW3jkQ93UcYBMSXA2w/0kwLtJTWiKyYp4iL+f4ijm7hf9/D
         f41w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUZzw38q+4ENuIkdI1Ec8miW/ZFAXcGGssjpNqS3YHWS4UB04kh
	n6pdankELmAafzPU+RXiBnTK+B2BQRKyFR7vaqf3CH3t9m2LnmxLgMWmCMhwWR7jRVDhDZxcHax
	mH0tjGgxrXWKJbffQAX9VMkQhnpeF5cqp6pb+9eRtecBk1VGN7CK7CgYI2wx52da4eA==
X-Received: by 2002:a6b:6b11:: with SMTP id g17mr24826957ioc.285.1556226820911;
        Thu, 25 Apr 2019 14:13:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYOcNbAs7j9W3DBoH4WxPyl5IiE4Bsg8KcaHYYhTZdj8QgHsUPIqc9mMt6LWE1cbgRIBLk
X-Received: by 2002:a6b:6b11:: with SMTP id g17mr24826907ioc.285.1556226819933;
        Thu, 25 Apr 2019 14:13:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556226819; cv=none;
        d=google.com; s=arc-20160816;
        b=ikVLdtfSnhVA+9Pu7Y1VPs+C2Mh9Vf+WN7qLx6xYo69pS8XNMa39mhYikdpiDJPZ90
         9N+NhlmoYqvUtorEiaJ3OZDVR3Y+BoYYq8ANmgZD3Toh92Hf90MLTEReRuoaGjsNlJt7
         2woOFbzbyWdaiOHqvg1B0re/1ee/2L2UZ4IDHfjV0NWOEHLGqfzU3BCHd7CFgjrQ6FQa
         A5JTO6gqnw4QUWoLDt0lkLh9I/SiWnsKQlcQcRP1rImATqN7sijP6tUHHYcI6/ZzTSVH
         OFiZi6U6F3xGudXFfCNHde3aNu2vk30Dtg8sShepJsXMnzIKA9BDEulCCfws8OHYg5Qw
         /t9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=sgWKsjsYrpKtKe767qgokEq8OVajFnZ4OEzAdmnqA6w=;
        b=AdAJvCxteLY0FGE13y6ft2/GppmXC6VueoXyGtv+7jfj51OL8n8dgV+CpgWd+94/h8
         e1adThQYSH/TuY+Hvw+vJhTPTtLadfG8B+scThYz0YIadOGr5rANBfv4zdu2wVahGRdq
         3t3Bfsz9efyBNdCuhbzR5ddvVvUGrNVxfS2GVbPzipBSptpk12rvGv9ucDZWsvI1hd8R
         MVf2ajOQpEwP7vC4OtquSyMRIGFcNu0jORPEhI3FOENBurFgiNmj1Ln9+ywV51hA4EqR
         zlVVcfxbrdDwNzb014Oqd4MrxBRT3IHeyGkBOmppjMhUZsilw0UvItLHLIMe/E9fhKRf
         RfnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h12si14801680itl.4.2019.04.25.14.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:13:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav104.sakura.ne.jp (fsav104.sakura.ne.jp [27.133.134.231])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x3PLCZWF022768;
	Fri, 26 Apr 2019 06:12:35 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav104.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav104.sakura.ne.jp);
 Fri, 26 Apr 2019 06:12:35 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav104.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x3PLCTI4022751
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Fri, 26 Apr 2019 06:12:34 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [RFC 1/2] mm: oom: expose expedite_reclaim to use oom_reaper
 outside of oom_kill.c
To: Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com,
        willy@infradead.org, yuzhoujian@didichuxing.com, jrdr.linux@gmail.com,
        guro@fb.com, hannes@cmpxchg.org, ebiederm@xmission.com,
        shakeelb@google.com, christian@brauner.io, minchan@kernel.org,
        timmurray@google.com, dancol@google.com, joel@joelfernandes.org,
        jannh@google.com, linux-mm@kvack.org,
        lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kernel-team@android.com
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-2-surenb@google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <c745df86-b95c-e82b-42ba-519da4f448ab@i-love.sakura.ne.jp>
Date: Fri, 26 Apr 2019 06:12:27 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190411014353.113252-2-surenb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/04/11 10:43, Suren Baghdasaryan wrote:
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3a2484884cfd..6449710c8a06 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1102,6 +1102,21 @@ bool out_of_memory(struct oom_control *oc)
>  	return !!oc->chosen;
>  }
>  
> +bool expedite_reclaim(struct task_struct *task)
> +{
> +	bool res = false;
> +
> +	task_lock(task);
> +	if (task_will_free_mem(task)) {

mark_oom_victim() needs to be called under oom_lock mutex after
checking that oom_killer_disabled == false. Since you are trying
to trigger this function from signal handler, you might want to
defer until e.g. WQ context.

> +		mark_oom_victim(task);
> +		wake_oom_reaper(task);
> +		res = true;
> +	}
> +	task_unlock(task);
> +
> +	return res;
> +}
> +
>  /*
>   * The pagefault handler calls here because it is out of memory, so kill a
>   * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
> 

