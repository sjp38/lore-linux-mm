Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42736C46460
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:51:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10A7220881
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:51:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10A7220881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0ABA6B0271; Fri, 17 May 2019 08:51:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 994396B0272; Fri, 17 May 2019 08:51:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AA7D6B0273; Fri, 17 May 2019 08:51:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 414DF6B0271
	for <linux-mm@kvack.org>; Fri, 17 May 2019 08:51:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r5so10496796edd.21
        for <linux-mm@kvack.org>; Fri, 17 May 2019 05:51:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M2HTy9xOQmyliFETPI0RaP5AuTsQ1dyO524mMwUa/L4=;
        b=ZUw1D84eYI7HQTMVx8gbOfU0JqNrKQBPPxaFLg97PnLYiWQhSZGxCM3wA852Z46NQi
         Zx7h1KFAixUm7FU8Yip+3CzIHXiSWxN2b22Jj/wnsFnR3McN3In6ZO/1d4CLfAaIFO0z
         4CRy240CEmbZtvyV1UG6nZGQpQkvdjy4oZ4vqGGpnY9yrM5+YYbqklB9HOd3ACLKMJAB
         LtZP7eyvs/1aVzGUHPUSkh7sWtuoOLN/HVVeTRgRfUqxmXAhl2uOmTyqtYnZLmV8JULX
         JFm8EUchoe5QenhgEHTHJyzN+JbFNfUKx518OlUlXuiXHOIj5cIDN79GlS7QNHV2bkzA
         cIuA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUfUlgA4/0roh4+x5+h9ivAHjLfvWldWwx+FdQOy3zYi4/3l0p3
	rLCYHTFoPg9rWEW+iBu8lGTKTALGocTcUexMkXbHm+pbmu6viZ9oiqcQnQFdG/eiY/ZvQ6Qpdrs
	oj0lVFLxKPSuLUrez5D0g7whmAUDdwaaGgFa2ESUoX89A6/Hfg0/dtiiPq0BSsK0=
X-Received: by 2002:a17:906:d1d9:: with SMTP id bs25mr43681818ejb.213.1558097496846;
        Fri, 17 May 2019 05:51:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrygAE9bMceiUxlNTiTuORzdtIWoAlOvhUJRtnXjUzT5kBEXjBGavCeYxaia/fA4y03fwM
X-Received: by 2002:a17:906:d1d9:: with SMTP id bs25mr43681757ejb.213.1558097495909;
        Fri, 17 May 2019 05:51:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558097495; cv=none;
        d=google.com; s=arc-20160816;
        b=mGVz4GUlXlX5LcQEFlcTxorksQ5JagvE5QHxxKhb56KYXNE6Jw5XNNXpCZHpkqr+fK
         Tw/ecqg+dUV9r5ku9iXlikfjMF0MmwyGVenp++fC/5LsjTCJTFm1kzF3sizI6AA89Coo
         IdOEEEsE6EyX42puscxmS7K+EGQxliRW1DiP3Pe5fob3nt12a3bkOkjAAqeSl7cyIORO
         LlILdx2yMH22Wrq9UVly0Zc4/oUaihxq9+pgZMgM7jZ3gKAuf8uhb5Rn5VzuT4jJLQax
         GLA0d26Pf4xdKx5HaaTAO9wUt7t/XC9wfYhHgWeBJlVyhxDYZF3IiHOzGRPasuxmOQDG
         iaLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M2HTy9xOQmyliFETPI0RaP5AuTsQ1dyO524mMwUa/L4=;
        b=Mgf2ciw6Y0yq4f7PbaAmdYPu2+6SFmxkf9Z6hXzuho5FtQIgn8ruqX/ezx9YDLqnrL
         Ji/kgwBe1tRXi2KCCaqa/0KUekOMbU9cZozLUHcc8tIKQGlWKlmGe1WjTA/4af7MFpzW
         pT+Mtz6+UkAGRBERV+rDGWqyW5PHoynFRgui7KpozjvxTDKF//SBhwqantkXwPr/fawl
         TSeAGPOaXLPFJjK862raifkkdNt4L8X4AVqlyH1MeRPc8DSImT5QDJNCpaHuyZNVnDwA
         jHBFci6slJ4gJOtg+mQDbTDf64yIHRTK2RecnkrLW1fcT3lYreWv+rz5lFdJKEZbVgG3
         J0Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h46si3447527edb.49.2019.05.17.05.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 05:51:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5E16BAF59;
	Fri, 17 May 2019 12:51:35 +0000 (UTC)
Date: Fri, 17 May 2019 14:51:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: use down_read_killable for locking mmap_sem in
 access_remote_vm
Message-ID: <20190517125134.GE1825@dhcp22.suse.cz>
References: <155790847881.2798.7160461383704600177.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155790847881.2798.7160461383704600177.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 15-05-19 11:21:18, Konstantin Khlebnikov wrote:
> This function is used by ptrace and proc files like /proc/pid/cmdline and
> /proc/pid/environ. Return 0 (bytes read) if current task is killed.

Please add an explanation about why this is OK (as explained in the
follow up email).

> Mmap_sem could be locked for a long time or forever if something wrong.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory.c |    4 +++-
>  mm/nommu.c  |    3 ++-
>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 96f1d473c89a..2e6846d09023 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4348,7 +4348,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>  	void *old_buf = buf;
>  	int write = gup_flags & FOLL_WRITE;
>  
> -	down_read(&mm->mmap_sem);
> +	if (down_read_killable(&mm->mmap_sem))
> +		return 0;
> +
>  	/* ignore errors, just check how much was successfully transferred */
>  	while (len) {
>  		int bytes, ret, offset;
> diff --git a/mm/nommu.c b/mm/nommu.c
> index b492fd1fcf9f..cad8fb34088f 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1791,7 +1791,8 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
>  	struct vm_area_struct *vma;
>  	int write = gup_flags & FOLL_WRITE;
>  
> -	down_read(&mm->mmap_sem);
> +	if (down_read_killable(&mm->mmap_sem))
> +		return 0;
>  
>  	/* the access must start within one of the target process's mappings */
>  	vma = find_vma(mm, addr);

-- 
Michal Hocko
SUSE Labs

