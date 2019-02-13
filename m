Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80955C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:56:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4309E222CF
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:56:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4309E222CF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C99298E0002; Wed, 13 Feb 2019 11:56:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C470D8E0001; Wed, 13 Feb 2019 11:56:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B35D38E0002; Wed, 13 Feb 2019 11:56:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 769CD8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:56:45 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i3so2333052pfj.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:56:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=On/U0iOi/cUCxk4EHTWWwGA9cgiPP1ioDf10gBZVdtw=;
        b=oK00GTF56t/1DEiDuurk98an5SZ+FZIDxntuQzLZbY7mxu/LdC+Mo9+gC99hWoBz16
         I7IRQeWPmRrHufMlZEybPgt3z3tVozv18/77G+QkjrHg15durhvTv82PXQbIPNhwDVTZ
         RUstFj7nTDk5LOPJDIhuRxzXuaBNSAtBfZgxMflVpP8RoiMNA411p8Bpqw1qrSA5+2li
         spLg6k/ny0Nit9Ck6IjsZdWr8c2oysKC+DW5fsH+SmQdaoR3JmAhyge+6S/DR8C+ByW/
         /oh04HeyG+We6j2KJX2D4oBxMJFSafzFzuY9yOqf11/B5Bv6d5jNnDJJ46E7mG8QbOhW
         8cSQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYwxsYai/YZEuIobB98xIQ44YMMMYWyrn4gtNrE+m0eVYbTVWIk
	+jsHrC6Qid1HR35xhqny40pOyZSPBhOIHvGxB8bIKEXUYpG5jzY3KXWGqQJZoPXvcIxuL2J+Jml
	NRNdDcVjJqibacv48me+0heDXTx5T4qInJ4TfbpWPbXDv7hKaEJeAzH+2zDLAD54=
X-Received: by 2002:a63:2882:: with SMTP id o124mr1311210pgo.446.1550077005144;
        Wed, 13 Feb 2019 08:56:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZY0nITpjtMqW2L2L54lg+fZcKbShEQuhyb5xZWsNU5cRVI2HXLTZnWFlbbiwn7WOdOa/NM
X-Received: by 2002:a63:2882:: with SMTP id o124mr1311178pgo.446.1550077004469;
        Wed, 13 Feb 2019 08:56:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550077004; cv=none;
        d=google.com; s=arc-20160816;
        b=OAHliAJ1v27IQX/ChpaJzZA7QXonVxYlvfaAXMXr7B0huE3DKrV7XDi9nT+r60WLjk
         3JIHHMaN7Q/mtc8Zc7fOSyRV7jjSyUxQU0FDgY6/8v5mZGLLxE3N0RTY0/dF1SFkJv/u
         s/WVI4fSmyS2HEGY+FMpawPKDAc+LJlImESh1CgBJ1gUw18uAVQEpP+9S9rxr5Cu9oLz
         d32Svdpyp1ufoAX0FcM6Mz1uDU7YLC9AnidlWaxaOfoWx0hmIofWEK39VwVMkoGFWjpM
         O+fXdwx5t/n5EgJC5+tdAwSSDECh4bVsx1NX4tBf+wLfKmC6xHY7JUbZ3h0SerXchY9N
         ho6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=On/U0iOi/cUCxk4EHTWWwGA9cgiPP1ioDf10gBZVdtw=;
        b=nvkJQZs475iWAgnr7sI1V8zVBN3XH5Rvie/GHp7cRngtg76m4Glha+ot1wfoYMUtFr
         ZuypiJ10nrFH+RS12pTgNcZKVbyq6oBeFWd3Y0N1kOI21ipregtdABHX37PM0X+y3flN
         3aX9/PDXE9QgO0Qv7rgFsHitWY29jYZmNw1d0zVsSvwfw1Mgw5H8crCUr4jaUyl4JxZF
         yJeMYhi+a7uhen4j84uYyPW+OoTyJekL51uHFkkQ21A+lwtI52KEGNdaW/ngvxV+pTI1
         imV36zyUY4psG8TWVwcFWXb5SHINpF8q2Jnzw5hSX2MVVgtGFH67dqdv/52mSzu/zIOk
         EqUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e29si9041961pfb.125.2019.02.13.08.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 08:56:44 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5104FAEC6;
	Wed, 13 Feb 2019 16:56:41 +0000 (UTC)
Date: Wed, 13 Feb 2019 17:56:40 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH v3] mm,page_alloc: wait for oom_lock before retrying.
Message-ID: <20190213165640.GV4525@dhcp22.suse.cz>
References: <20900d89-b06d-2ec6-0ae0-beffc5874f26@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20900d89-b06d-2ec6-0ae0-beffc5874f26@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-02-19 01:30:28, Tetsuo Handa wrote:
[...]
> >From 63c5c8ee7910fa9ef1c4067f1cb35a779e9d582c Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 12 Feb 2019 20:12:35 +0900
> Subject: [PATCH v3] mm,page_alloc: wait for oom_lock before retrying.
> 
> When many hundreds of threads concurrently triggered a page fault, and
> one of them invoked the global OOM killer, the owner of oom_lock is
> preempted for minutes because they are rather depriving the owner of
> oom_lock of CPU time rather than waiting for the owner of oom_lock to
> make progress. We don't want to disable preemption while holding oom_lock
> but we want the owner of oom_lock to complete as soon as possible.
> 
> Thus, this patch kills the dangerous assumption that sleeping for one
> jiffy is sufficient for allowing the owner of oom_lock to make progress.

What does this prevent any _other_ kernel path or even high priority
userspace to preempt the oom killer path? This was the essential
question the last time around and I do not see it covered here. I
strongly suspect that all these games with the locking is just a
pointless tunning for an insane workload without fixing the underlying
issue.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/page_alloc.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 35fdde0..c867513 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3618,7 +3618,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	 */
>  	if (!mutex_trylock(&oom_lock)) {
>  		*did_some_progress = 1;
> -		schedule_timeout_uninterruptible(1);
> +		if (mutex_lock_killable(&oom_lock) == 0)
> +			mutex_unlock(&oom_lock);
> +		else if (!tsk_is_oom_victim(current))
> +			schedule_timeout_uninterruptible(1);
>  		return NULL;
>  	}
>  
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

