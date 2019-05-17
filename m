Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29622C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:48:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5E492087E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:48:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5E492087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9700F6B026F; Fri, 17 May 2019 08:48:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 921AF6B0270; Fri, 17 May 2019 08:48:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E9656B0271; Fri, 17 May 2019 08:48:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 32BA16B026F
	for <linux-mm@kvack.org>; Fri, 17 May 2019 08:48:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p14so10610401edc.4
        for <linux-mm@kvack.org>; Fri, 17 May 2019 05:48:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dLDIu02bytIbQRierKUUEBX8ARwFwUvVDPG10Gv8UrY=;
        b=TL6V5tavPbnAvuancsUzpLOQJcG9JpNQ0Gv92IedIMhlMoOYVIzaxjTeogcl3687yt
         jJXN/kQXHdCXahUhW4nN+YfsZFH2XPgUCD1eVS13JQ2GFZrZSbzPlmHbPOUKKVaaEg+g
         uf662MLF2eukOrPZFPfBFKgogwlKiZPorumhJzc+/mHcIbCzRSLsKp+4XaGq6AxqgI2c
         VhyJxIs4w0Qog1wR3Wej5IwQ2xTP91+bkJP2ZKHzTRJZQU5U1I0mKNxXn6A54BwuenTX
         oPhgw4NzY3JUg1k5XGvIS7aESjxZiCJrgCGvkG2AOZlaG4QlssBeM97oJ7YzLbGT5UfE
         rhog==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUldXWqCGaOuS1sPDO7Gsr6GKIm7j07T1EfOhxN9M75PwH737gZ
	FaOqmmWpZAsj/jA05Wym8Zh1nTxeBRSMjtfHJGrdBJJeX1UQK3SZklpk2DvapZdrolLxlfM4j7M
	xYVyH2s7waezQbp+RUqvMOlfxJn83ulfjofr/eEt6UN13zAGRGN0PRDKlQDHwqI8=
X-Received: by 2002:a50:b6cf:: with SMTP id f15mr57270397ede.192.1558097280806;
        Fri, 17 May 2019 05:48:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxv7V6pqkTlP/k1zftz1+vPy9WN7vtPosYC6QXeEv6VCTOgvqdbk3XWtsua0SVxihj7jwiM
X-Received: by 2002:a50:b6cf:: with SMTP id f15mr57270341ede.192.1558097280137;
        Fri, 17 May 2019 05:48:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558097280; cv=none;
        d=google.com; s=arc-20160816;
        b=eYyzy6Zt5lG+o/XkQw2KXJOT7/i3wAaHxpCDn4uiVsmL8tCdE2ZVfKS5xTN74goyQz
         7cdfGBaFbZ5NJKCDTF6vvh8Kb5R9Qgo8uWlx0tOnT+7Ipiyjfkws97xHtaocSaZZSlQJ
         0ZUX88CvZ5uUIJ3ma9dnJJInwzWKw2WOOE6X+DMIRrZ3I5LPCmc4dQ769fATFSJnh/ja
         CeFkZwGL9kC2qep7H1xVna89OAdKOUg8cNH8o2GPq5k5GqmtnbN0NLJEYdiiJJ1aEO/l
         MCa5vS/1uaF/g0MvDiA+QYdwBrGUf/6/4AKgn9xP4O1mCebXX+RZW1aRMYi6IPe6KZ3U
         licw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dLDIu02bytIbQRierKUUEBX8ARwFwUvVDPG10Gv8UrY=;
        b=fzs0FpPwzGucivh+cyx5lJW8Q45YPN4wEIggpaoL+z6OBHCDlebHouAgGe0SBaJxSz
         UbSSWqH9PRF7sJey36ONtV6MmRWk7x2pKyhieoO9ZGeoJWfx8YJZCVG5STZZxq3qUCHr
         Iwl/5y0RmuZlhPxceZHY0POMZz4EZU8XIefymmlCqPx0Gz02Pxn3OZsd4T3LLxuyz0CG
         +n1DxlySup3qTOTxAyrRhUIJmqSFuG3zqVPmQSSGRp9PQaR+BJRv9PCWxWcgWd7MFaIp
         1PWXiMyku/iuf4nuK7VKJV3gJ0Oj186QjSfPDTwHW5dzWxIqLNgro/tClVlG+kbhP6Qx
         vHiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si405552ejj.242.2019.05.17.05.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 05:48:00 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BBF60AF59;
	Fri, 17 May 2019 12:47:59 +0000 (UTC)
Date: Fri, 17 May 2019 14:47:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 4/5] proc: use down_read_killable for /proc/pid/clear_refs
Message-ID: <20190517124759.GD1825@dhcp22.suse.cz>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
 <155790968147.1319.10247444846354273332.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155790968147.1319.10247444846354273332.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 15-05-19 11:41:21, Konstantin Khlebnikov wrote:
> Replace the only unkillable mmap_sem lock in clear_refs_write.

Poor changelog again.

The change itself looks ok to me.

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  fs/proc/task_mmu.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 78bed6adc62d..7f84d1477b5b 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1140,7 +1140,10 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  			goto out_mm;
>  		}
>  
> -		down_read(&mm->mmap_sem);
> +		if (down_read_killable(&mm->mmap_sem)) {
> +			count = -EINTR;
> +			goto out_mm;
> +		}
>  		tlb_gather_mmu(&tlb, mm, 0, -1);
>  		if (type == CLEAR_REFS_SOFT_DIRTY) {
>  			for (vma = mm->mmap; vma; vma = vma->vm_next) {

-- 
Michal Hocko
SUSE Labs

