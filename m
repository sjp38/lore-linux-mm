Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B31ABC04E87
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 09:16:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E89520881
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 09:16:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E89520881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A5816B0005; Wed, 15 May 2019 05:16:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 057176B0006; Wed, 15 May 2019 05:16:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5FED6B0007; Wed, 15 May 2019 05:16:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7456B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 05:16:21 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id c18so452099lfi.22
        for <linux-mm@kvack.org>; Wed, 15 May 2019 02:16:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xFK3WFDRYBzxrq8yWCIlp7llC9R8MAhIqHXVBtxwgUY=;
        b=Ej48x2ROGBOrndaaApARy7v1345ZoYzxpFmcMaNN6qXtSwrGknUCW0tZeCJ9gsKO5i
         HrjvJbMVE6iXpjsIEhF2WyJo9mJcNYOzzYwvN0ia949eYbOqb5lhmz9QRrFRDJCBU1a0
         7hPJu3D6WSEmNS3Ez6z/jdYcpp3kLt+omXAivaT1zNANvp7Jwgc2zcRnXBxLwtquAOEG
         3n8J3dtxdL+PIHK8qe14kI0ZzQswlcPMnemh3ikPPrbJAoQPcEvOT9c/hf5AuqSsQ+2w
         MqUEQVjhsUSHU5kXPAIMv+iRaQ58feLah82qo8TqCtu+y2/+0EiMVX+757uxx9DAHSxk
         xSVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAW8Hs2Le2PB61noOHC4ZFHYF3pVf3rg16erCBKi5E1AJLCo4O35
	tzHbIkzPlAv9WFHb/kK1yrIO9+VRlhEQEc+Q8yFmVFg9AiXJSrcnWbXUCv6Yh5wC0mBOlPSz+bd
	sIOq6J6rXR1O50EvXNoXUZtwhUn8ZE4yW62dKQo+NQUyVr6nwGZuVaj45p0MNIX6uwA==
X-Received: by 2002:a19:f705:: with SMTP id z5mr19327269lfe.164.1557911780980;
        Wed, 15 May 2019 02:16:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyMa4q3eHTMLKPUAwP+4rHDBBMJHqeKN7d44O0upTyXqXUOwuSy6hUcwF5/N7KXJS3L1Un
X-Received: by 2002:a19:f705:: with SMTP id z5mr19327220lfe.164.1557911780141;
        Wed, 15 May 2019 02:16:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557911780; cv=none;
        d=google.com; s=arc-20160816;
        b=r0qBzltG2/hDnRhp98/3BNqGz9gb79ekXk7Lxiu12FZqAcIW513FGPdIWum11XeLUo
         6T5qwB76e0VnEDxgH+QdwHEiozxxjYR6lp6oL5Wjnz/sOyFhBxQlk7ee9v6KsOCTfZBk
         L/rtKt6TFhHRCWXChR44l5sUYnPTWzZCKh617HKpfOzI0ff8Caezl5LF8gofCIgUAEhy
         ju6HEnis1bXaW68g2xFimtC8VsveHDC78TP/sYzPys/b1A285F+/UXQj4UW+jSV0tFFG
         BAOts3sPPnD9W9tmduMBw6+/K/WA+2fVC3EVSoOwSDWMCsxzV63bKuuhgsUpC4RL18OE
         8A4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xFK3WFDRYBzxrq8yWCIlp7llC9R8MAhIqHXVBtxwgUY=;
        b=q6bJ+L21ODWiQKeHIHbcxKmLGWhiOTpJrKeGEFpOODNuLBRk6c+fq8+4CiX0NKfuiN
         VcjNytNUjKIik25zJZF6VQLTGkrmLPi0MCBXmTTrb4cYSETssuq/ENEz0BqWgNArsb0j
         G0Xk7CiD15jMcOPW9QE3KfwL4NWkzw+zM+yBLDkmhTWSkl5osrHN9cMXwjXhOfubygRc
         BS33yjsIzLMkjhbAiUq97I4yuPHgHuJ1bXVi98PN1lZR1TbC3kdGsY82bYWgQMEUDIeb
         NmQOtitJzgYoc7rkYsaEc3gV1dFi0MSVpcvNj+yV61ikiehw1GsEUy9QS3AkWYRv6ctZ
         0esQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id b10si1126298lfi.79.2019.05.15.02.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 02:16:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQq1H-00071z-GC; Wed, 15 May 2019 12:16:15 +0300
Subject: Re: [PATCH 1/5] proc: use down_read_killable for /proc/pid/maps
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <77650cec-70cc-149a-74e9-2256c6138032@virtuozzo.com>
Date: Wed, 15 May 2019 12:16:14 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155790967258.1319.11531787078240675602.stgit@buzz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 15.05.2019 11:41, Konstantin Khlebnikov wrote:
> Do not stuck forever if something wrong.
> This function also used for /proc/pid/smaps.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

For the series:

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

> ---
>  fs/proc/task_mmu.c   |    6 +++++-
>  fs/proc/task_nommu.c |    6 +++++-
>  2 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 01d4eb0e6bd1..2bf210229daf 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -166,7 +166,11 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
>  	if (!mm || !mmget_not_zero(mm))
>  		return NULL;
>  
> -	down_read(&mm->mmap_sem);
> +	if (down_read_killable(&mm->mmap_sem)) {
> +		mmput(mm);
> +		return ERR_PTR(-EINTR);
> +	}
> +
>  	hold_task_mempolicy(priv);
>  	priv->tail_vma = get_gate_vma(mm);
>  
> diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
> index 36bf0f2e102e..7907e6419e57 100644
> --- a/fs/proc/task_nommu.c
> +++ b/fs/proc/task_nommu.c
> @@ -211,7 +211,11 @@ static void *m_start(struct seq_file *m, loff_t *pos)
>  	if (!mm || !mmget_not_zero(mm))
>  		return NULL;
>  
> -	down_read(&mm->mmap_sem);
> +	if (down_read_killable(&mm->mmap_sem)) {
> +		mmput(mm);
> +		return ERR_PTR(-EINTR);
> +	}
> +
>  	/* start from the Nth VMA */
>  	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p))
>  		if (n-- == 0)

