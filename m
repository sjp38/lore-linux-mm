Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9DD4C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:45:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C0292173C
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:45:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C0292173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE3E26B026B; Fri, 17 May 2019 08:45:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B94766B026C; Fri, 17 May 2019 08:45:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A836A6B026D; Fri, 17 May 2019 08:45:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 590096B026B
	for <linux-mm@kvack.org>; Fri, 17 May 2019 08:45:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r5so10478332edd.21
        for <linux-mm@kvack.org>; Fri, 17 May 2019 05:45:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=w3orLxAiVlLhkI1QU8ebwF1UsyzvRSt1yqaaxnHspJY=;
        b=qkW4pwXYE3K6A94SSNmlEei8NWzbDREW4/M68vi6JVZdV0/UgHibYcb0S+nG9h/bhC
         /BtEoHabLgeJBc/nmDGG87KqNqDTqJElN1sgE8s2NkzWZhD6BuJkU2xBTwB85ymMW34m
         TR1+Jeti6Zbkm32UkOnwQtECPZVz6I3W/rO26FSvLhZ7eNiygCtgS8XA5x0baoXmKlxw
         P9Mg1tpgYwr42RWiwPijDuJ3IdgmjnlZDQ1Xe9Fdys4zXqal7UfezHRAI2aFZzkb6GdY
         JavfMmWGD0F0DCvjw7uen20rzgwNVGpP4/NS4qOO+0fMJHuhGtyyNFHk3cLpPhBuiAt9
         GFZQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV6id+DI1XYnKObnQ33SmeKUDB5LGAXplBB0Azi+PSgTSkV1Z+A
	QBCc0C1FHwCkR5vwsEkDR5Ah4w6Mm/X9su8NNdmUa0kIvKggYOobLuqjQU2vuYyxZWuV8qgLVzm
	s/8RKnF3wq7dwtoqicVHdp/mKimIOS6sO0LaqYNPstdvB0To9fSNTcArSIAEnkGQ=
X-Received: by 2002:a17:906:6a1a:: with SMTP id o26mr3034585ejr.265.1558097157940;
        Fri, 17 May 2019 05:45:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn7KvLeVon4reFcDlqAYYWQGzyqplbxcbLhfaVwi82QklbQTx9/0QXsIx8TBReVB96rWvB
X-Received: by 2002:a17:906:6a1a:: with SMTP id o26mr3034529ejr.265.1558097157135;
        Fri, 17 May 2019 05:45:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558097157; cv=none;
        d=google.com; s=arc-20160816;
        b=HgfL5pJXtdw3oYu9zrcnOxO4s29ea69RD2bXH4XPYanW5x9k38NxJ7Fovly2wK4CEw
         3MEwaNxs58uUltlP5GfaM/HQg4ncu1dJzWEK1/8ZLzuON4pvLAQS2r0HfcYCFCy+8Q6Y
         zAQpQlMvUXDFizv/f6BP8/Y3/t0M0IxzP/0LKy9ILEsKhOydjHRVI0OU2pDcCZsh7vYd
         dV8o7K6rQpkdzXW5ABpS5sYhPXOG3Y2egSZPwIDdRToZym2JCAoqE1iZ0S6CETPBxpjT
         K2OOoJwQDR75ejglxb4MlnAq2Gdc1rWmIeiQNhrET5Sfb7K+Uiq0+VUlBA8MtHRJlpEI
         Tuew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=w3orLxAiVlLhkI1QU8ebwF1UsyzvRSt1yqaaxnHspJY=;
        b=xhTEnijQEzitc9VXy4c74mxKe/U6DD9G0ZZRJUd6No9Y8qZC4BdTqegOgaoNUQMLda
         Cr1/mBlHrF73XtlR859pUsWraI0CcUqA3/gCp+wRZBPgMOy+IAbDmrG8aXo5RbMRRbTG
         6DcHBAW/0lUtfxANzDFs3Yk+Pv0+xUwimFRdmmIe3iOSkcIZNFpcu1k3fXSONvczqBsj
         jVBpFlk+NiKGMBGuCOUXl0x1+Ke3+U2J9UXK/H0/HTMwCNvryxJdTKPxJDv23+VQ8u41
         PtVLF+miRrMu5msV9ZdUb6mlGSMKxAhLiiuMQxgDZYlEugxgj1vyet9pP8YwgNnOlUGz
         sJOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dt2si5251479ejb.3.2019.05.17.05.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 05:45:57 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 48ECDAF59;
	Fri, 17 May 2019 12:45:56 +0000 (UTC)
Date: Fri, 17 May 2019 14:45:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 2/5] proc: use down_read_killable for
 /proc/pid/smaps_rollup
Message-ID: <20190517124555.GB1825@dhcp22.suse.cz>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
 <155790967469.1319.14744588086607025680.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155790967469.1319.14744588086607025680.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 15-05-19 11:41:14, Konstantin Khlebnikov wrote:
> Ditto.

Proper changelog or simply squash those patches into a single patch if
you do not feel like copy&paste is fun

> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  fs/proc/task_mmu.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 2bf210229daf..781879a91e3b 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -832,7 +832,10 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
>  
>  	memset(&mss, 0, sizeof(mss));
>  
> -	down_read(&mm->mmap_sem);
> +	ret = down_read_killable(&mm->mmap_sem);
> +	if (ret)
> +		goto out_put_mm;

Why not ret = -EINTR. The seq_file code seems to be handling all errors
AFAICS.

> +
>  	hold_task_mempolicy(priv);
>  
>  	for (vma = priv->mm->mmap; vma; vma = vma->vm_next) {
> @@ -849,8 +852,9 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
>  
>  	release_task_mempolicy(priv);
>  	up_read(&mm->mmap_sem);
> -	mmput(mm);
>  
> +out_put_mm:
> +	mmput(mm);
>  out_put_task:
>  	put_task_struct(priv->task);
>  	priv->task = NULL;

-- 
Michal Hocko
SUSE Labs

