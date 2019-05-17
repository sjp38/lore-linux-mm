Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30B8CC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:41:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBFC820848
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:41:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBFC820848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88C8A6B0269; Fri, 17 May 2019 08:41:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83B506B026A; Fri, 17 May 2019 08:41:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7040B6B026B; Fri, 17 May 2019 08:41:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 236536B0269
	for <linux-mm@kvack.org>; Fri, 17 May 2019 08:41:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5so10565186edz.3
        for <linux-mm@kvack.org>; Fri, 17 May 2019 05:41:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mM6yT3BS+8apYwtHv/mI5JR5AECNvli1Huh00Iahml4=;
        b=RBgoaMC8f9LZRrxmEwyGAGQCQpAx+PEY7f4WuXU2hhm4tK5QyAAFXmVxce1Q94etMK
         pd1nU7QiB1LNtG8I1ziyCDXquFB+Dt9/s1rGgu2OmVUz4OOQS83ZZYjAGT0TwHNRJ5Ae
         CD6eG9s9+ZFNT4gkX2SBiwEcFH0MqPP157+ccanBWmk8l39Cgbr4pjCG5CM2JfmVLRqb
         cpoCNn4gIm0H0OdzaOpMh0ui1nNg053gutnbaegGYUzQMD/8qpjw6/A38SLWx6iUN7WQ
         qyAkXrtLFJD3y7BIJE2jHbd0xvrqjWZSR+xA3tYe+mvzFI6dzmOSLfDcbK89pEsBgWvi
         3W+A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUPNzIWnpIimmkETUoCv7erRoZXt7M/xnKd+7tFBw/brCVIgiJA
	hEnnhJMAHcmwJN8dOji2BVI0AV+A42c53z+lBi1wtlbeqV8nqGF4uHAJco32rBLwtm4nw9BBwu8
	WmYhewvPGVyRgqRLWdEENo/OVvwp9by+J0+DL/yh5Oc+ZPR+1WqRmAgbDUk41DRE=
X-Received: by 2002:a50:fd0a:: with SMTP id i10mr56409113eds.117.1558096881731;
        Fri, 17 May 2019 05:41:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPdqiZzgFZ9EQeBHRuQ9nE3jGFl6Gd0PRL8g4e3Py6FkOGsbE6GF1I989+MQfTa9IGFC/p
X-Received: by 2002:a50:fd0a:: with SMTP id i10mr56409036eds.117.1558096881060;
        Fri, 17 May 2019 05:41:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558096881; cv=none;
        d=google.com; s=arc-20160816;
        b=RHaiFFQce6TO2edG00vihQ/efdd7yleh1vdqmBp5A6OOdrFvCrNq3x8U8sJypKytEq
         ar/sP33IbilDJq89xwH4bGPys1u1/TC102BM4B3U6Sti0xAPZsVG3zxEgYjKlNfXjcT+
         U/+EmfQF34eAbAKC/ySs2rCl5K0zlYavkKEMYP7ennTnJWHSCUBzIPBeLea3NHIDn2Mx
         aNk6XQRGOsf9lHPZfncazFeflmlotMAFU18j0S5gj5dWm7dq9znX9e3InYgBA0G651DZ
         qhE+gZWrZgYaFZvzwt3pMlMgAHeb2Yy7GmftnGM7etqEMEGBbtf2loOeZKvsZvHCMpgS
         A8aA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mM6yT3BS+8apYwtHv/mI5JR5AECNvli1Huh00Iahml4=;
        b=IlndRkrFcHb0YBAAOIByVWtDkp5keRotvhpNls7qr78IAWtLaX0sFBksaim3AxKwpY
         nJiqecxBNUgoOVHo9QWql1w/vlKxutUmAyYN/+yc6oqYDQEuNoSaNxFA0vxiq3bSKp30
         e+USyaQbrmoZJW/XgRlqeLZTwqpRLJjTJDGCGMzbqCu/l62PSvfaURXDQssbwqmW56iO
         FYYIasK4sAif78cNrS01UbBOYNqmFJAzruvH5srJX/nOycPQH4UyWPie6wadG9yzAYNm
         qQfXW2itBv51mg2aCic4sF5prm1tSOzecWFpDidF68bIuJwmsUXHgCBMRxRVEepV88gS
         Ws4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si2416188ejm.69.2019.05.17.05.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 05:41:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 410FBAF3A;
	Fri, 17 May 2019 12:41:20 +0000 (UTC)
Date: Fri, 17 May 2019 14:41:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 1/5] proc: use down_read_killable for /proc/pid/maps
Message-ID: <20190517124119.GA1825@dhcp22.suse.cz>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155790967258.1319.11531787078240675602.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 15-05-19 11:41:12, Konstantin Khlebnikov wrote:
> Do not stuck forever if something wrong.
> This function also used for /proc/pid/smaps.

I do agree that the killable variant is better but I do not understand
the changelog. What would keep the lock blocked for ever? I do not think
we have writer lock held for unbound amount of time anywhere, do we?

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Other than that
Acked-by: Michal Hocko <mhocko@suse.com>

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

-- 
Michal Hocko
SUSE Labs

