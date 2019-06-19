Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0437C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:35:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69D882084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:35:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69D882084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A08E06B0003; Wed, 19 Jun 2019 01:35:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 992048E0002; Wed, 19 Jun 2019 01:35:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CEB88E0001; Wed, 19 Jun 2019 01:35:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4213A6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:35:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c1so24493356edi.20
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:35:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5xFI6CC+SBydA8Y9UU8UZWk761AJ3Twzt9eFzf2XbD0=;
        b=XaoGMBLCUxOhEJxvh8LDIwPE58GmGABYA6kngy/KCoRtKjKYF1WcKIPbhllJbeYEII
         v/plRl/bTnsjpkHDzwBtO6K8L0G9RYWrVnL9xRDJcIDtE637TSEttp1jH3gIM9LEfeDk
         7ZSufzH3iHSO6FpPRNPSNLjje5rMIksgDbZRgAfMGWXTr/JL9Nm6uEZ23/ToMnwY2iUU
         WfXmcUgsjbHm3V0E0nfk1lpkctPUuy+Op3I+JIFev0NUK1kSBM7A/TRoFuJhiVIeM4rm
         BNoCWIfHjwRMDEw08tVWUVQOz2wI/FAgqhkFBYgIIIV6k7QfNXmmzTZx5Z2tApR/YnUO
         ZOig==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXxMRhucPqgSPLe5+5khqOLfooJEWeWM5CD/ySkFuySlLHkGaI3
	O9mNyXNBf+EjZ0ZaEjOMnrRV2nTsZVcuwR7kQyEw3l+ozU+01Dl/8j6fOK07gbJh0gISQ5Z7YQp
	Jj6PfRK/F/TLsuZID9wzVn6TW3oFUb5gapEn4UUxYR7KV4KsElsJ914RadRpe8uc=
X-Received: by 2002:a50:9413:: with SMTP id p19mr107940835eda.224.1560922554850;
        Tue, 18 Jun 2019 22:35:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydcjtqEYtSmOSChZQ/njfaSuA/BRdh83gmJcyoJc3OXb0ya0/z2K/bpF2v237rJ863iVW0
X-Received: by 2002:a50:9413:: with SMTP id p19mr107940800eda.224.1560922554179;
        Tue, 18 Jun 2019 22:35:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560922554; cv=none;
        d=google.com; s=arc-20160816;
        b=deg8vo1KyMrtHJZNC0caGkrw6DfTTVtJE2GEn3s887koyYuJg//bzVpTISebeWjQvd
         Hs4UWnSuGFA4eu0m6ijxw44H50DWCtSN7T58lF3J3ihNe+jO+NcEgJRwkBe5iKLXTiD7
         LC/vPZj3pQ/VG1i64l3E8uXSZP3UvG8BNAZbMxsta4f5NFxwmAb3/jNH3ca0s+H3FD5h
         JC9H8qEpg92/lYcvxPobYT0jR7PWkkel/1OyyRAhbdCRsCAhewfpp2HPd8DIvYn++1SY
         fw+MCbhLgpk6YtcOCorFLYXXLMaOqHqejmPNzD0vxvG7lSOQEzqgmGNdYbL+HVEY99Fx
         Z8iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5xFI6CC+SBydA8Y9UU8UZWk761AJ3Twzt9eFzf2XbD0=;
        b=rIWMBVe8qhxQ1Jeu6tnKQF43cTdesUX8tZiRZLdgI0lDvB1/0s5TZ6I6ca83fDO12D
         S2qjU24wud1+7WLEOaYIk9hCV1ZnB7oPPWifgycjXEG4Etf2OkXI3a7oD/6fjSBvCTjn
         5GlatZHUfiYP5dPNP8UcuT6TXYgxfnc2QlZZqhJ1KjfeChvudrF1uHpj1nIjPLAL1JTR
         NLVFJ58vAiKZFAnUhIdk207d69GyNGG2vpk0NitzIQG6nvgh4MvOHlEmQIcox229fUT2
         M8thgj4qsph/XZkM4vkvNDgy9hhW3Zek6V00nNJY35Ylzz9ALFgwFExBtnnjHQA4N7/G
         BRxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6si13295225eda.228.2019.06.18.22.35.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 22:35:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B82C8ACD8;
	Wed, 19 Jun 2019 05:35:53 +0000 (UTC)
Date: Wed, 19 Jun 2019 07:35:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH] mm, oom: Remove redundant OOM score normalization at
 select_bad_process().
Message-ID: <20190619053552.GC2968@dhcp22.suse.cz>
References: <1560853435-15575-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560853435-15575-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 18-06-19 19:23:55, Tetsuo Handa wrote:
> Since commit bbbe48029720d2c6 ("mm, oom: remove 'prefer children over
> parent' heuristic") removed
> 
>   "%s: Kill process %d (%s) score %u or sacrifice child\n"
> 
> line, oc->chosen_points is no longer used after select_bad_process().

Well spotted. I am still trying to understand how that was supposed to
work before that commit as oom_badness() already provides a normalized
value so we have normalized it for the second time. But that is largely
irrelevant for this patch.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/oom_kill.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 09a5116..789a1bc 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -380,8 +380,6 @@ static void select_bad_process(struct oom_control *oc)
>  				break;
>  		rcu_read_unlock();
>  	}
> -
> -	oc->chosen_points = oc->chosen_points * 1000 / oc->totalpages;
>  }
>  
>  static int dump_task(struct task_struct *p, void *arg)
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

