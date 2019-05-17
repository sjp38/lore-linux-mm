Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55325C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:46:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 200BA2087B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:46:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 200BA2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C0EA6B026D; Fri, 17 May 2019 08:46:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96FC26B026E; Fri, 17 May 2019 08:46:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8394F6B026F; Fri, 17 May 2019 08:46:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B62E6B026D
	for <linux-mm@kvack.org>; Fri, 17 May 2019 08:46:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so10569392edm.7
        for <linux-mm@kvack.org>; Fri, 17 May 2019 05:46:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KprizxL+EWg1Z7ibek0Wiksg0pES5jJsoHlr86+ClWE=;
        b=rMArqk0CN4WdAT9T0b7bb0qVT/4Yvi0iSjqcVYPUJySP5x5lMQQUvjUMFerBbnS0rt
         M1GFgWojUxTQbFJGtsLCaFTI6sl9x5aVuIlXQLJlWcjeB3jzXQvWWKg8CQv0AQquAVWk
         HbcWHH4GtWTWh7zQX71qq4wfHBIm+HXqOth+vUkzOZ9CtPKqmROVveVBzqfKlqDEyOxG
         xjdMqPWWuM/1mWEfuyczB3ZsMbm83BaloCVBWHJ1bgvCuCJEF0J+cYQN2Ik8o9VXPif8
         9zSe1PacMrL3XEo4sEkFm97D6XFxfeW46I1pwsQ79iuM7JbMgS0N6oOPoeK/+aLzeMMb
         7VLw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXe0JM5+TRIITR5L9kBl/L1Mu+5ZU1D4RDElQHXTUn7J5ciJyjf
	Z8iPEAzV/I2O7cwquM1HQkYKVbe1U0QMFSEZx4HrmKEddq2UnDkp8aqdFAydjf1IhYJi4s1kAET
	HXHDu+LY+VhvSFEmMBZ/ckSFb05SwGEARSh+1K9inJq2N2Q4UDbqV2gaoNabcXGM=
X-Received: by 2002:a17:906:619:: with SMTP id s25mr17642758ejb.274.1558097209906;
        Fri, 17 May 2019 05:46:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRZzN6KfAue6Xt8AWCYS3v5b/KsFkejGTfqw+mYYZFmGxZFVkK/5ZR71mALelGUHirHjVc
X-Received: by 2002:a17:906:619:: with SMTP id s25mr17642708ejb.274.1558097209263;
        Fri, 17 May 2019 05:46:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558097209; cv=none;
        d=google.com; s=arc-20160816;
        b=NBonIzn1qqYV9Gn31G1zDvRI37VY9gG3q1fmBPoN96/jHC8vSp7eFioCbV++2PYEp9
         rW/MB8NlBaosCFngUFq77Uax+AA6S8REiIjLaYEuXsmCmnSQ0YlrcG0EKW4jPoazCby9
         +iJPsImH1uHHIcMIrqN9UlJzClOsKhHKGGcI9fC+WhGmr5KpyK2WLTMyQrsHzjFhM9Cy
         F6vQmVVVzYkjRj7eDCLboJqv5JDxp3mjNYrRi4n8iNBpspaCaPyW+L/lkIEYRudxscqR
         njukDf0Ys4A0Vqg0nJS1bhnBJxYIU69rU7U7RTDsVmhx3nd/PcKtHyiqDri8Xde/tpeB
         yVeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KprizxL+EWg1Z7ibek0Wiksg0pES5jJsoHlr86+ClWE=;
        b=F2CpZdY8BctLo/gbbXspONERrGI8qVU3ST0meLm++YHoOUV5ikAE16Zsk8E/CsnmSa
         5boD3NRq+M5yw4zUEJzWF4VoirWV9Pkg/08BM2+U9VYJwXURxr1Q4W9DGIuqIk/1ucr6
         UFmamULqDJPwgWmLbw496O9vbHVPoAOS+XQ4itV5frlj7RTQYmRA+6iJ22RIj15nJWo3
         izXfzmkOWl3vv4lLg6KHN7tQYcsRSakoBifeVJ35TXoxkB6xbtysSZELCCkICz6iSu2k
         bJv3MAJ8qaZ1Wv7aCzqfMJ+zn8ZNGgmAFhO9Fl6icJPmtOBZq/XqUfr0I3KZxJV5eAqr
         LXhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c16si5676883ejb.245.2019.05.17.05.46.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 05:46:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D83B1AF68;
	Fri, 17 May 2019 12:46:48 +0000 (UTC)
Date: Fri, 17 May 2019 14:46:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 3/5] proc: use down_read_killable for /proc/pid/pagemap
Message-ID: <20190517124648.GC1825@dhcp22.suse.cz>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
 <155790967960.1319.6040190052682812218.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155790967960.1319.6040190052682812218.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 15-05-19 11:41:19, Konstantin Khlebnikov wrote:
> Ditto.

ditto to the previous patch, including -EINTR.

> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  fs/proc/task_mmu.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 781879a91e3b..78bed6adc62d 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1547,7 +1547,9 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>  		/* overflow ? */
>  		if (end < start_vaddr || end > end_vaddr)
>  			end = end_vaddr;
> -		down_read(&mm->mmap_sem);
> +		ret = down_read_killable(&mm->mmap_sem);
> +		if (ret)
> +			goto out_free;
>  		ret = walk_page_range(start_vaddr, end, &pagemap_walk);
>  		up_read(&mm->mmap_sem);
>  		start_vaddr = end;

-- 
Michal Hocko
SUSE Labs

