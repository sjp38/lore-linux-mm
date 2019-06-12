Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,FSL_HELO_FAKE,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CC82C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 23:14:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 041F3208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 23:14:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EswV1nGC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 041F3208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C7146B000A; Wed, 12 Jun 2019 19:14:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 778976B000D; Wed, 12 Jun 2019 19:14:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6689E6B000E; Wed, 12 Jun 2019 19:14:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30C636B000A
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 19:14:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i123so13055909pfb.19
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 16:14:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zENyOoOSgI8QfaggquPMfPbLKw7a6eUv2Qjm9NWJtcQ=;
        b=E/sMEI7Qf9GMUjrz0FJvxZiBwyKbB5vRlOum+2ADEi6I0GzWrDfkCNJW14gc118j/b
         Aa9Nh5i6gWKkiODj1AkBy0rI8ojnWwd2N82cZ8VgI6r2XELDrM/PFmerkFftMgRHxeRt
         RCXt6tc8nbjlHCC+GkXsSkvvrTLcj3QyakhlYvk7uHRzpDWCwNxJu5iTqegQYur/9z8S
         idEWtymubjrmJpF9Ti8wWZRPq1m8YSxCh0G6j6EfWw7guGVprf4aCukvZNbt+hfktOt8
         XUVj8CxbeIp7Wgb3GfZ6kr9vqL07D5POb8mNxjTtZD23AmkRAIoe+j8gC4JrL3tXQqRF
         qd9Q==
X-Gm-Message-State: APjAAAXrL5KzeEiMzcQ/aR5USwu/EdztO9+FNZ3jiyTjCj0PX3oJfZ+w
	/lrtgDR+/0OdMbugfGZuL5zF8fyx8mZyF5Z/bw//2RLzLKvZ2A3TgA1G/DolrDgQz0DDbtO69zI
	96lVDl8DwKLAqil8zcx63IihFgaE4rR+tu2qztb8Vdhw2Klm+N7fVCQ5p/EemoDsdmA==
X-Received: by 2002:a17:90a:de08:: with SMTP id m8mr1622895pjv.50.1560381271661;
        Wed, 12 Jun 2019 16:14:31 -0700 (PDT)
X-Received: by 2002:a17:90a:de08:: with SMTP id m8mr1622846pjv.50.1560381270909;
        Wed, 12 Jun 2019 16:14:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560381270; cv=none;
        d=google.com; s=arc-20160816;
        b=HRVjQdZqHx81moLHudynYqFEXsS2LgLVa5kpXZgF/nqNPeCxYFXv9RnA8j7eD34TPp
         9q+uq5MPrEeWQC5A+JZY9dBYnobukCD9OK6KNFZptV9fBO5e3QSJecqQPI5o5OSR79Nw
         lmu/LLQu07SFUZtLuWQ1dOPRZvsYltETbN3tRBpvqdFt3UP0+r2onwy7AdjTJC2P5ByF
         8KAZoF+VuHrcclIWvI0SbuTTOfz1xJk4izaFRm6XVhghtYfpaugQNr5dG9CnMgnv2S1T
         fYfxpTDKCVlOn9sJmaNrxSOW9vFjkoC7q8UAo5h7wwhYLI2lJ6g9XqeCTj6Pi5HJSS7x
         uVEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zENyOoOSgI8QfaggquPMfPbLKw7a6eUv2Qjm9NWJtcQ=;
        b=OsY1jb0rsabhWLfDTExDoYvnHMUy/mut8K+wQ3copMTha8VtQuUD8adxa3OV6ju1M4
         lr75Y8c43yIzKki2Yc/t6dXfFfAQn2KLE9LogqPXgWZwE3CpntdqXiw7ahnmr126mW7a
         1J4hmPq5o7SMKhdSydZAnVhUnmg9+TmpsrZJLP2AvxiE1/AiB5GBY8rVO1/itdvcKjoL
         darjWcvFbNdNG1vm5H4lVxqDYKDmvwqN89pBTHSxVCPhTOMUOoObzJl1Sb/WTDRKcTXY
         PqpGNSDVz8CEGf1AxcWtUlQWGobtIaK1sCGwXT6LQltBg2GA01t2hxXrCG0VkHzpLgu0
         ntdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EswV1nGC;
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j39sor1121600plb.22.2019.06.12.16.14.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 16:14:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EswV1nGC;
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zENyOoOSgI8QfaggquPMfPbLKw7a6eUv2Qjm9NWJtcQ=;
        b=EswV1nGCdvSMNN+Ssd1h7rS3RXzjTfEdTIdOLjAh5nTRd36k1bdXI6zWruRLqObK0d
         gsC+6WcEPSp6FesMM+ciJCWrwUt+f3/TlPdj8OHr1gJIlaqypHatFu/fEtZyZqtTgxf/
         7MmVJ24TsNjxF3L2qzae4mJRJIWKsdAgvTDM41obh31wU5DHCFOSTfiDeRVan1EyTWT2
         FA4K03WJSZqhv2G4TPC4wR1Lyw2YYsUsmJ5/O926cAuclRrP4DGVaFyTWu7dvlXrp9UC
         rWkAggs99lIDtQwUic825l/5MOVIb6hlsoo+MGQWZsaaKUU00iAbkzb0AD/J2zMhHB2K
         je/Q==
X-Google-Smtp-Source: APXvYqynFN1ludII3XFLYMfIONiHIRT3DEjMebyu/w5SXt66rSlQbatTCpNAcnVu5y6nlAVVC7h8BQ==
X-Received: by 2002:a17:902:b70f:: with SMTP id d15mr3048117pls.318.1560381270418;
        Wed, 12 Jun 2019 16:14:30 -0700 (PDT)
Received: from gmail.com ([2a00:79e1:abc:1e04:de9a:68c:c1e8:7e8f])
        by smtp.gmail.com with ESMTPSA id o26sm491338pgv.47.2019.06.12.16.14.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 16:14:29 -0700 (PDT)
Date: Wed, 12 Jun 2019 16:14:28 -0700
From: Andrei Vagin <avagin@gmail.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Michal =?utf-8?Q?Koutn=C3=BD?= <mkoutny@suse.com>,
	Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>,
	Dmitry Safonov <dima@arista.com>
Subject: Re: [PATCH v2 5/6] proc: use down_read_killable mmap_sem for
 /proc/pid/map_files
Message-ID: <20190612231426.GA3639@gmail.com>
References: <156007465229.3335.10259979070641486905.stgit@buzz>
 <156007493995.3335.9595044802115356911.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <156007493995.3335.9595044802115356911.stgit@buzz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 09, 2019 at 01:09:00PM +0300, Konstantin Khlebnikov wrote:
> Do not stuck forever if something wrong.
> Killable lock allows to cleanup stuck tasks and simplifies investigation.

This patch breaks the CRIU project, because stat() returns EINTR instead
of ENOENT:

[root@fc24 criu]# stat /proc/self/map_files/0-0
stat: cannot stat '/proc/self/map_files/0-0': Interrupted system call

Here is one inline comment with the fix for this issue.

> 
> It seems ->d_revalidate() could return any error (except ECHILD) to
> abort validation and pass error as result of lookup sequence.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Reviewed-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

It was nice to see all four of you in one place :).

> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/proc/base.c |   27 +++++++++++++++++++++------
>  1 file changed, 21 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 9c8ca6cd3ce4..515ab29c2adf 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1962,9 +1962,12 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
>  		goto out;
>  
>  	if (!dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
> -		down_read(&mm->mmap_sem);
> -		exact_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
> -		up_read(&mm->mmap_sem);
> +		status = down_read_killable(&mm->mmap_sem);
> +		if (!status) {
> +			exact_vma_exists = !!find_exact_vma(mm, vm_start,
> +							    vm_end);
> +			up_read(&mm->mmap_sem);
> +		}
>  	}
>  
>  	mmput(mm);
> @@ -2010,8 +2013,11 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
>  	if (rc)
>  		goto out_mmput;
>  
> +	rc = down_read_killable(&mm->mmap_sem);
> +	if (rc)
> +		goto out_mmput;
> +
>  	rc = -ENOENT;
> -	down_read(&mm->mmap_sem);
>  	vma = find_exact_vma(mm, vm_start, vm_end);
>  	if (vma && vma->vm_file) {
>  		*path = vma->vm_file->f_path;
> @@ -2107,7 +2113,10 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
>  	if (!mm)
>  		goto out_put_task;
>  
> -	down_read(&mm->mmap_sem);
> +	result = ERR_PTR(-EINTR);
> +	if (down_read_killable(&mm->mmap_sem))
> +		goto out_put_mm;
> +

	result = ERR_PTR(-ENOENT);

>  	vma = find_exact_vma(mm, vm_start, vm_end);
>  	if (!vma)
>  		goto out_no_vma;
> @@ -2118,6 +2127,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
>  
>  out_no_vma:
>  	up_read(&mm->mmap_sem);
> +out_put_mm:
>  	mmput(mm);
>  out_put_task:
>  	put_task_struct(task);
> @@ -2160,7 +2170,12 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
>  	mm = get_task_mm(task);
>  	if (!mm)
>  		goto out_put_task;
> -	down_read(&mm->mmap_sem);
> +
> +	ret = down_read_killable(&mm->mmap_sem);
> +	if (ret) {
> +		mmput(mm);
> +		goto out_put_task;
> +	}
>  
>  	nr_files = 0;
>  

