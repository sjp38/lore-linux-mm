Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 500CBC73C7C
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 10:58:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 100B12064B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 10:58:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gO7Fk8sL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 100B12064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9767B8E0070; Wed, 10 Jul 2019 06:58:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FF118E0032; Wed, 10 Jul 2019 06:58:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79F928E0070; Wed, 10 Jul 2019 06:58:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7E18E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 06:58:47 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 21so610439wmj.4
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 03:58:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2sT+oGvC0W6TXp3DJLMLSUCPXzdSnjaT6jI9OQ5BPH4=;
        b=mD5Tscf2QkWE438W1igBM337iYviH5UfWV78PxVrY8i9S80LlsEbtygIYTtUuTKmRp
         LoolOlhiKMoSVSmb9aomIR5BRlufswtp61cfuweP++KAswNjmgUNrv6aIUWFrht/GDZY
         9++NESt8uw8t13R1A46wvbpGrFq0fG/iU4KVI7E9L2T4OriX+sj0okMRQNY46WjBpa2D
         jddKYh44vb+BXRDHb3I7FET4ctdxqhD2sW+W8qyk1u5alh8+wFFY++elm0oGbSKcBa3p
         uuQCISaUmVPUvaZJvT7GJJQZCvo/m8/V1GoX2afRilXDFZj5yf6djDzt0bPpYSxs7bf2
         ztog==
X-Gm-Message-State: APjAAAUWmLG2Ky68N5gQdluqtb+tRkcmoTEkIYdNX49/CNIB6QN12VB8
	Ky1WxT4sUb4ODStQjXSp/V0xbdiGo17O2dNx5NEf+D/g7EtbMus007rKCBHPl0UrfmqCLlr3Njv
	3KLoPqKC72dqJm+3FFOQsL7rRm9ufscd8Jw6UElP5pWuHpVWI+ev24bXuP/TZQw1TOw==
X-Received: by 2002:a1c:7a15:: with SMTP id v21mr4978173wmc.82.1562756326669;
        Wed, 10 Jul 2019 03:58:46 -0700 (PDT)
X-Received: by 2002:a1c:7a15:: with SMTP id v21mr4978118wmc.82.1562756325923;
        Wed, 10 Jul 2019 03:58:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562756325; cv=none;
        d=google.com; s=arc-20160816;
        b=0yDJ5wmxsVofibpdrKbdCFz1EnvIrzSUsVk8PLAs37AsKvuVcy7r2OdeEAFLnHp5ri
         +QNtdCGSk5XfPgOF3IMziAl8PJRcqYCDRqvBhwdf/DaPgX4LLbo812hRK6iDaotXUIZm
         zhcwZZu5yADA97KAj/nUqlV+ttA2ZnYaFW1o32skdCmTeAZWKID1amvysbjc8TEPewha
         jyw8koPT9P2AxxBLlNBUW+N4BExODiMeYwSTddMcNm8KJcHNxPeSmDzgJfpPM25oIiqG
         Hmi3nPfTu427PKF66AMviwhln9rysdjJ8KqWhKrRoKNfXGaoAzF0VbFIdkHi7RJcc0ib
         UvBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=2sT+oGvC0W6TXp3DJLMLSUCPXzdSnjaT6jI9OQ5BPH4=;
        b=khI5PUnIKDmZTq3uh5MA6y6YiUlNObXTL52y2lZvwEEW3mRggm1bQGn/AvcDQuASB2
         Xz/rCfWdxV9jQv76J6DSxSLLAS7idq1HtHktlo28QPP8655g9cho91SmHni5P1ALLs20
         bmknoO/XmFFj2Xi3L0ehnv+guZM8xIEVKuLfjgw4wQHNeIqoLQCBLOBLUmQ1CzU8xuOR
         kCk5MAmdfpbDjubRXvaDu9wUuW5cmbFkcWlvI6Rh3n+nYqVyAbsss+eQzhVCi8Lmm6FM
         XN8QX8BOYUaI/rMLWr+yyA6ZmVdvGdOSOeqpUrUoFSsRY5pPoSadJIoF3rT4b+QW9kwj
         /CYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gO7Fk8sL;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z18sor1453925wrr.6.2019.07.10.03.58.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 03:58:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gO7Fk8sL;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=2sT+oGvC0W6TXp3DJLMLSUCPXzdSnjaT6jI9OQ5BPH4=;
        b=gO7Fk8sLsyUWXz44hx5WnF9wFLqzfaSjOcDy15DI2kpmYpjR9c0Nmbcmy6HEKP7SZy
         pIbKRt03eJNCGslrDwoGRfWRqkqh/e82F+kiqtPAZ2hnU4jY+5zRmUnPEU0BExOzFecb
         TW6nURXyFIKv7kM5jzh8fvf3Kb2O2d6m9dX3R0qnXri9LPR2AcYXgIpC/2fvAmjdQR+4
         WCreZwsx8AARBm2GbJac2+Vd3sor7Exu6fOclQ9KV4S2TJAFRPHeKfydhQZOMbbaGFEG
         9YCFeMNwOinlwxcahrrTOHfXTJNNrM9u10uqu6PGB2ZzgvQqy1BqTxMXUfkcaa4HxHCS
         WPjg==
X-Google-Smtp-Source: APXvYqw8KUi86oRLtvVJh6b2yivIxG8Q6GKE2mrwk4yEnFE6iV6Lycols/Yc7V6/xDCjTS26tmYmUg==
X-Received: by 2002:a5d:56c7:: with SMTP id m7mr31232112wrw.64.1562756325658;
        Wed, 10 Jul 2019 03:58:45 -0700 (PDT)
Received: from [192.168.8.147] (31.172.185.81.rev.sfr.net. [81.185.172.31])
        by smtp.gmail.com with ESMTPSA id e3sm1788460wrt.93.2019.07.10.03.58.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 03:58:45 -0700 (PDT)
Subject: Re: [PATCH] fs/seq_file.c: Fix a UAF vulnerability in seq_release()
To: bsauce <bsauce00@gmail.com>, alexander.h.duyck@intel.com
Cc: vbabka@suse.cz, mgorman@suse.de, l.stach@pengutronix.de,
 vdavydov.dev@gmail.com, akpm@linux-foundation.org, alex@ghiti.fr,
 adobriyan@gmail.com, mike.kravetz@oracle.com, rientjes@google.com,
 rppt@linux.vnet.ibm.com, mhocko@suse.com, ksspiers@google.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1562754389-29217-1-git-send-email-bsauce00@gmail.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <32e544a6-575e-a47e-fd8a-647145ac1972@gmail.com>
Date: Wed, 10 Jul 2019 12:58:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <1562754389-29217-1-git-send-email-bsauce00@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/10/19 12:26 PM, bsauce wrote:
> In seq_release(), 'm->buf' points to a chunk. It is freed but not cleared to null right away. It can be reused by seq_read() or srm_env_proc_write().
> For example, /arch/alpha/kernel/srm_env.c provide several interfaces to userspace, like 'single_release', 'seq_read' and 'srm_env_proc_write'.
> Thus in userspace, one can exploit this UAF vulnerability to escape privilege.
> Even if 'm->buf' is cleared by kmem_cache_free(), one can still create several threads to exploit this vulnerability.
> And 'm->buf' should be cleared right after being freed.
> 
> Signed-off-by: bsauce <bsauce00@gmail.com>
> ---
>  fs/seq_file.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/seq_file.c b/fs/seq_file.c
> index abe27ec..de5e266 100644
> --- a/fs/seq_file.c
> +++ b/fs/seq_file.c
> @@ -358,6 +358,7 @@ int seq_release(struct inode *inode, struct file *file)
>  {
>  	struct seq_file *m = file->private_data;
>  	kvfree(m->buf);
> +	m->buf = NULL;
>  	kmem_cache_free(seq_file_cache, m);
>  	return 0;
>  }
> 

This makes no sense, since m is freed right away anyway.

So whatever is trying to 'reuse' m is in big trouble.

