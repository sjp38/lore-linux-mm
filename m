Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA30BC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:23:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EBE420818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:23:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EBE420818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00A478E0060; Thu, 21 Feb 2019 03:23:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFAE48E0002; Thu, 21 Feb 2019 03:23:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEB3B8E0060; Thu, 21 Feb 2019 03:23:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8539C8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:23:12 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o27so715034edc.14
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 00:23:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=st4gb9mZxA8JokMcKSfT/J5HqFZrYwqe3Lx5kgtfqAI=;
        b=mrBLBR4jtG5XaRia28cysuBZ591neTsP+D4uP234x8JQCXTJFJoPRVgARTERSNUKaf
         YVoAUeIy39aI9J4PDyUlnTLndNO8iMZ9s/n3Y8vmJdqds/Znm412HzDyh8wb0qDje4TS
         zPblsIFGLCak4WX02ppkFKWcDT2noQSPF15uxf9tPm+hnLZkPvcfmE0pBI/IEikvUDDB
         hqj4Avup7xqINA7CW+n08xTDyYJWN6KX1ZUtYVFNg7xax144jqqoMLPcb1/9CchCEGZP
         YVTK2a8p6c/fmtoXGlBcRJWQTJrYwx5I4/VtTy4W4l94UAg1ykbqtsHOW2kOTPoXw5oi
         Eyqg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuabrmNKntb7l85JS+1mpDvR30uVfz+dhXp8wBQ1G9PNz16CKEou
	gVo4MbZUFxGVVFhZMxaOlvp0BX4sB8HfWMWxWiiESCQScJbw68E5RpguMgMHGTajj0y9tYKcrlN
	oF76igSSE9Rwc+Og14DtNo2bylGhkfauY3VQKA/bGikLXXfthIlJK4RQnIGMhpDM=
X-Received: by 2002:a17:906:1a4c:: with SMTP id j12mr26860896ejf.134.1550737392084;
        Thu, 21 Feb 2019 00:23:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZuYY0dFnAQ7NDsPcuLvIbefzh6OCT1tvxPkogkgWdcyOFU/BzXhEdTtcnTjE1OJGQVVOTd
X-Received: by 2002:a17:906:1a4c:: with SMTP id j12mr26860851ejf.134.1550737391157;
        Thu, 21 Feb 2019 00:23:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550737391; cv=none;
        d=google.com; s=arc-20160816;
        b=ZsXFKCcV/acIIIJ6EnBNhT7ReTyMpZm76apcf3yrH9T5X0TRoqOZJWZJQaHu/V5r1X
         iBS5LVmya8GTkwi6oceIElEL49lhevSI4ppWSsbvxl1xIkznqp3BGkfHqZfIyJ78+3eh
         /bDLCET3PcRy+mu5sdbY8Y4/PuteiPps8GptWHIjbKtfuYBZvzfufIsgzLNQsJxxZDDh
         tXCsSACqP7N5FzWLhJxjPkwNeaJu8y/our8hrGJTqsy4AU8nrynQDahYAsyefWsc+FDe
         cc/vpWeW7bKd6h3aGbWYUsjFvjnSfGnnNB7rMuMFUoGpo0l4ROHFUi37juZjmJ6tU/8X
         cOrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=st4gb9mZxA8JokMcKSfT/J5HqFZrYwqe3Lx5kgtfqAI=;
        b=OrZIHjbE7sg3RT1j3HN1L5Ztayr/h/2jTQq7Bb6riKQipb67hFZIMjkf/n85YQYeot
         R2uSFfVpSd4Qcd+OeQBOoLQQA1lZNxOIUSUtoRzIqF9KNGf0UeDHDM/S+TLJso1azjRi
         wf/hB4dDe0BkefHWWgqh9KYWWn+Mtz8GtuneLwDOoNElIGZSc7XdVcL4LMH9pyAweSbZ
         qPJgH1z2C0OT/OuXMjTy452ByTwF6jmmiWEYBbyA5+jWCWqlQujKVs/tq8e3bOOerhZR
         NfjIsvd5UmAUGnp+sHMJd1nqdd1ZEc551txHusHA7xXLPlgzv9Rh3ZYiE8BRysnJvT76
         EBrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g12si1748882eda.198.2019.02.21.00.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 00:23:11 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 49AE2AD95;
	Thu, 21 Feb 2019 08:23:10 +0000 (UTC)
Date: Thu, 21 Feb 2019 09:23:09 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yue Hu <zbestahu@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, joe@perches.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, huyue2@yulong.com,
	Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm/cma_debug: Check for null tmp in cma_debugfs_add_one()
Message-ID: <20190221082309.GG4525@dhcp22.suse.cz>
References: <20190221040130.8940-1-zbestahu@gmail.com>
 <20190221040130.8940-2-zbestahu@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221040130.8940-2-zbestahu@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-02-19 12:01:30, Yue Hu wrote:
> From: Yue Hu <huyue2@yulong.com>
> 
> If debugfs_create_dir() failed, the following debugfs_create_file()
> will be meanless since it depends on non-NULL tmp dentry and it will
> only waste CPU resource.

The file will be created in the debugfs root. But, more importantly.
Greg (CCed now) is working on removing the failure paths because he
believes they do not really matter for debugfs and they make code more
ugly. More importantly a check for NULL is not correct because you
get ERR_PTR after recent changes IIRC.

> 
> Signed-off-by: Yue Hu <huyue2@yulong.com>
> ---
>  mm/cma_debug.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index 2c2c869..3e9d984 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -169,6 +169,8 @@ static void cma_debugfs_add_one(struct cma *cma, struct dentry *root_dentry)
>  	scnprintf(name, sizeof(name), "cma-%s", cma->name);
>  
>  	tmp = debugfs_create_dir(name, root_dentry);
> +	if (!tmp)
> +		return;
>  
>  	debugfs_create_file("alloc", 0200, tmp, cma, &cma_alloc_fops);
>  	debugfs_create_file("free", 0200, tmp, cma, &cma_free_fops);
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

