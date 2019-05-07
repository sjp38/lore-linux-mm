Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D284FC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:42:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F5E020675
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:42:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F5E020675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C4B96B0005; Tue,  7 May 2019 13:42:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34E666B0006; Tue,  7 May 2019 13:42:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EF476B0007; Tue,  7 May 2019 13:42:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C1E206B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:42:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f41so15066868ede.1
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:42:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=88A++NSeI6VyirYMBAZymUOFP1m0ARAO99labma7qJE=;
        b=UA/ndKoIehihfHd0QvVWN5cLmdjFYBAZ3UgUUxI4pBg89Z3fw/MgdDxYtRRHSer290
         qlPTBWNxQ+1rzR19eRTopfLPRzn1elIFBRPw6K2glUonneQJZluOxGmVNyrgFDeBBKjg
         QGGf5+e93T/mbAkdrH/ix9/4avIxvF236JQysc0mwdXsz62LAT+e79cwFmvvKLvj9ZT/
         CpzukmZ37mXljI0dl/Rdn7jpCNWD17bbUhg8ACsUjrTwjCDtTuSAPyxxML9cKfpwR+kU
         kDVhJiXcZKzmLoWpJG4m6zeMHjgBn75iuhYsOEibkb28FHhzn5usfGZCC/dmEFj8dRFO
         gkAg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVUS7j/hzRtpwFA6cDi2W3u3WYc80Nw1v/g4QG6Av2UgdgMkbyF
	GBxa98hljP8hQpZywj35Vn6KWw0cCZNhb6YcHMWwggpaS/d7jwtiT7vXrRI/CE8hOBIUgk6v560
	9zM+TynkIz0fTMmUR4uBeV5OYOwbIXn3v5yEmldbNj0AjvduW3tQTgL2A2hg7/l0=
X-Received: by 2002:a50:8927:: with SMTP id e36mr34788318ede.54.1557250939165;
        Tue, 07 May 2019 10:42:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3ahz4MKfouNGqp7LgtcTR563tmHS0go425i2FHd2D0Seucyceg1BcMfF1HT+j1MB8ra+D
X-Received: by 2002:a50:8927:: with SMTP id e36mr34788218ede.54.1557250938009;
        Tue, 07 May 2019 10:42:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557250938; cv=none;
        d=google.com; s=arc-20160816;
        b=ohMDB8vE4FpPKeWePYrwjvw7Gmd91D2aLPzrNRb8+LEzwmSl7gjJ3z7J8Jz1mdze12
         LQLIbQSD8rriaqtdE+p92d26JA15TyaJ9S9GfHCTVxYav78s+p+fiZteN6mjLZSjYO6B
         bkzimsWFGfSOJmMnl0AyfOGWNpSXtevF7XqG1qAA1aMiE348WTkU0Ia6wilzG4+UJ5Df
         2gkFEZFTK1pF02YlL7yxwdshDHNFocmGYHgXD9XHOnuOhiXHc1PYsEGy4fQ8mVLXLU2s
         ptAxB2/wOUNT76X1NTgn+UCiJuMyF8mN41P0fWYznv/V2lpkVhCssvvyuWTpUqiug46c
         STNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=88A++NSeI6VyirYMBAZymUOFP1m0ARAO99labma7qJE=;
        b=UL2mfhwwSuuU/a2T39A9XLtw09TYIjlSaDF24NDEYW958BTB+6FhC/omtOHhabQue6
         yKaozbXliwDKb3rCnnfaWWvMusUz2MSLsklNFVy8SI/6XGMSDbVdfxJc2sO8eNTkO/kl
         VcckM+neI0fgQVFzXLLimNiQxiurLGRBP3vclPBLX7gIlqv7cUyaYF8qw/aVKnLD6LGZ
         h9bi0brNi629GAi1ab2kan2JjDe5mhZpxZgDjZJVVtCK+nJsc6KRDXv74GQ/XG+VXW78
         Vya/pR+/77ti/X1VKB4QCJgwUcUwl8hsFY4WDDf2la/0zDVm3OflWVoHfKOSA8y8d9If
         zyMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q7si2954876ejt.24.2019.05.07.10.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:42:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 14066AF7C;
	Tue,  7 May 2019 17:42:17 +0000 (UTC)
Date: Tue, 7 May 2019 19:42:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: gorcunov@gmail.com, akpm@linux-foundation.org, arunks@codeaurora.org,
	brgl@bgdev.pl, geert+renesas@glider.be, ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
	rppt@linux.ibm.com, vbabka@suse.cz, ktkhai@virtuozzo.com
Subject: Re: [PATCH v3 2/2] prctl_set_mm: downgrade mmap_sem to read lock
Message-ID: <20190507174215.GT31017@dhcp22.suse.cz>
References: <0a48e0a2-a282-159e-a56e-201fbc0faa91@virtuozzo.com>
 <20190502125203.24014-1-mkoutny@suse.com>
 <20190502125203.24014-3-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190502125203.24014-3-mkoutny@suse.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 02-05-19 14:52:03, Michal Koutny wrote:
> The commit a3b609ef9f8b ("proc read mm's {arg,env}_{start,end} with mmap
> semaphore taken.") added synchronization of reading argument/environment
> boundaries under mmap_sem. Later commit 88aa7cc688d4 ("mm: introduce
> arg_lock to protect arg_start|end and env_start|end in mm_struct")
> avoided the coarse use of mmap_sem in similar situations. But there
> still remained two places that (mis)use mmap_sem.
> 
> get_cmdline should also use arg_lock instead of mmap_sem when it reads the
> boundaries.
> 
> The second place that should use arg_lock is in prctl_set_mm. By
> protecting the boundaries fields with the arg_lock, we can downgrade
> mmap_sem to reader lock (analogous to what we already do in
> prctl_set_mm_map).
> 
> v2: call find_vma without arg_lock held
> v3: squashed get_cmdline arg_lock patch
> 
> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Mateusz Guzik <mguzik@redhat.com>
> CC: Cyrill Gorcunov <gorcunov@gmail.com>
> Co-developed-by: Laurent Dufour <ldufour@linux.ibm.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> Signed-off-by: Michal Koutný <mkoutny@suse.com>

Just a nit. S-o-b chain is not correct here. The first s-o-b should
match the author (From) of the patch.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  kernel/sys.c | 10 ++++++++--
>  mm/util.c    |  4 ++--
>  2 files changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 5e0a5edf47f8..14be57840511 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2122,9 +2122,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  
>  	error = -EINVAL;
>  
> -	down_write(&mm->mmap_sem);
> +	/*
> +	 * arg_lock protects concurent updates of arg boundaries, we need mmap_sem for
> +	 * a) concurrent sys_brk, b) finding VMA for addr validation.
> +	 */
> +	down_read(&mm->mmap_sem);
>  	vma = find_vma(mm, addr);
>  
> +	spin_lock(&mm->arg_lock);
>  	prctl_map.start_code	= mm->start_code;
>  	prctl_map.end_code	= mm->end_code;
>  	prctl_map.start_data	= mm->start_data;
> @@ -2212,7 +2217,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  
>  	error = 0;
>  out:
> -	up_write(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
> +	up_read(&mm->mmap_sem);
>  	return error;
>  }
>  
> diff --git a/mm/util.c b/mm/util.c
> index 43a2984bccaa..5cf0e84a0823 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
>  	if (!mm->arg_end)
>  		goto out_mm;	/* Shh! No looking before we're done */
>  
> -	down_read(&mm->mmap_sem);
> +	spin_lock(&mm->arg_lock);
>  	arg_start = mm->arg_start;
>  	arg_end = mm->arg_end;
>  	env_start = mm->env_start;
>  	env_end = mm->env_end;
> -	up_read(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
>  
>  	len = arg_end - arg_start;
>  
> -- 
> 2.16.4

-- 
Michal Hocko
SUSE Labs

