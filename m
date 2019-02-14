Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 068D8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 13:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE58B222B6
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 13:51:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE58B222B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42EA78E0003; Thu, 14 Feb 2019 08:51:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DD558E0001; Thu, 14 Feb 2019 08:51:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CC488E0003; Thu, 14 Feb 2019 08:51:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C71E28E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:51:57 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f17so2521351edt.20
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:51:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ukJ0RVTLC0smaHMOvnwBpLn4TfSwJqmjhLvyDjoNEys=;
        b=HKeLOAOITnu6GhYEp+oOrdvI5R/fi1eRuq23Vm96BLn2s/0gvWS9gPAy0WVsWTy+06
         uzhvYcH3zTCIhekqcfMJlUN1h8yf7hs4fJSKDvPd2XZzFyq1/juPNXPEpy56gzW5utyx
         8chtzhzfG7lVvvxMotENhVrhJRJZ4ejsv95S+ahPVSP5LGdyKBRbC+j5q7Ix5NT5ANqZ
         hhZnP9g1L5O6YbBXgS6du6C1djwn+ms3tDcfGYk9el026dJ6KoJ1DjVazn9uxRRoGbPj
         3n91O0a4rWz4xQmROfpfp+rcM0t+L6kQVSNPDmDr4wk8to8N8ErxqmHK9xzQqf057OX8
         /VoQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZgZzWK18zXyzX8E967dRlMbOTe4M5ewxZVb018M/gEGCKUOUmM
	ETrbwhJ7xtOY4XIfuOD2LKL3TSZE6fPfmWrsEIrskysC8dsAwe9eN5eAJTnS22bi2t09wJLbUHT
	z3X3xOgsTu8LiBnTXjoPF1+zHFSdE1vBPpPE1XvOmQh+rO5df7ZBYVx0+V//UnDoYgQ==
X-Received: by 2002:a17:906:ca1a:: with SMTP id jt26mr2942537ejb.56.1550152317333;
        Thu, 14 Feb 2019 05:51:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBx6LFVSFKRS/oJNPJKAy+lZkF2wEFE2U+lafiObqc4SyeRX/rhpQwY6WoNfNc+DY04R69
X-Received: by 2002:a17:906:ca1a:: with SMTP id jt26mr2942478ejb.56.1550152316286;
        Thu, 14 Feb 2019 05:51:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550152316; cv=none;
        d=google.com; s=arc-20160816;
        b=FtpD1h7dja9uixzI/iBG74GkoOLWwUravBRyoRlb6EOgsMFwLH/AkboxaA5KNJ1BPJ
         PZ6mHa2ej6nWuoi4DDZBXDeTWm9khmTqVcCdZxeJ6GqphRsbVvSQL4DDCuRKzB9rcEwJ
         yOVCEIKDGnB3xksjHT4qscvuNMhIFi5DqabVnE9u3SlK35wIJH4gItWhVRmjhkT2OQsW
         Bykfyu8tqV6aWcp5gjvOK8rtXrrWnnOPIcu1IYrJOQqLpJZGHv6g5P+r3CtIT3MoYHFJ
         hzzzhtf1WPGAXZejlfXj1BE+hpePXfIClfekCRA/lczYAtAtPCfiM0c7ppULd9KqLJDP
         asKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ukJ0RVTLC0smaHMOvnwBpLn4TfSwJqmjhLvyDjoNEys=;
        b=nCgTx2cogWjktWiQNd+J4gnaN2dhlUJkUZ0Mv8mqbb3QF3A/Ve8XqdUYyy0On9zvfx
         pAw8l1qbqH61Vy7QTtmHl/Itb6VYbx7pita+zG4JhSpq/ipwK9xAmAh6aPUCIi8aaoh1
         BkJkLgpsWnYxkukmnOqMAKvqvRlRyxfU5sfjSS51S00uQeA57Hed2XdYSzvg5InjDEj3
         IwrN49pAZm/FtTQaWxuJbJCfOIU5NOT9bLDzEG9SbPMneuErpUxbveSAmnWzo8cMUUtJ
         8Ksdcc5HpbVgie/Y161l7+ceKnI+ay/zQPUNovfPf0rXgd0fDQ4LGSEe9dYjNOslDg14
         WJXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id hk18si1056931ejb.308.2019.02.14.05.51.55
        for <linux-mm@kvack.org>;
        Thu, 14 Feb 2019 05:51:56 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0181F80D;
	Thu, 14 Feb 2019 05:51:55 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2A0943F675;
	Thu, 14 Feb 2019 05:51:53 -0800 (PST)
Subject: Re: [PATCH 2/8] initramfs: free initrd memory if opening
 /initrd.image fails
To: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Russell King <linux@armlinux.org.uk>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, Guan Xuetao <gxt@pku.edu.cn>,
 linux-arm-kernel@lists.infradead.org
References: <20190213174621.29297-1-hch@lst.de>
 <20190213174621.29297-3-hch@lst.de>
From: Steven Price <steven.price@arm.com>
Message-ID: <e4246b25-628e-de5e-56ba-8d45ad9c9fa6@arm.com>
Date: Thu, 14 Feb 2019 13:51:51 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190213174621.29297-3-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13/02/2019 17:46, Christoph Hellwig wrote:
> We free the initrd memory for all successful or error cases except
> for the case where opening /initrd.image fails, which looks like an
> oversight.

This also changes the behaviour when CONFIG_INITRAMFS_FORCE is enabled -
specifically it means that the initrd is freed (previously it was
ignored and never freed). But that seems like reasonable behaviour and
the previous behaviour looks like another oversight. FWIW:

Reviewed-by: Steven Price <steven.price@arm.com>

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  init/initramfs.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/init/initramfs.c b/init/initramfs.c
> index 7cea802d00ef..1cba6bbeeb75 100644
> --- a/init/initramfs.c
> +++ b/init/initramfs.c
> @@ -610,13 +610,12 @@ static int __init populate_rootfs(void)
>  		printk(KERN_INFO "Trying to unpack rootfs image as initramfs...\n");
>  		err = unpack_to_rootfs((char *)initrd_start,
>  			initrd_end - initrd_start);
> -		if (!err) {
> -			free_initrd();
> +		if (!err)
>  			goto done;
> -		} else {
> -			clean_rootfs();
> -			unpack_to_rootfs(__initramfs_start, __initramfs_size);
> -		}
> +
> +		clean_rootfs();
> +		unpack_to_rootfs(__initramfs_start, __initramfs_size);
> +
>  		printk(KERN_INFO "rootfs image is not initramfs (%s)"
>  				"; looks like an initrd\n", err);
>  		fd = ksys_open("/initrd.image",
> @@ -630,7 +629,6 @@ static int __init populate_rootfs(void)
>  				       written, initrd_end - initrd_start);
>  
>  			ksys_close(fd);
> -			free_initrd();
>  		}
>  	done:
>  		/* empty statement */;
> @@ -642,9 +640,9 @@ static int __init populate_rootfs(void)
>  			printk(KERN_EMERG "Initramfs unpacking failed: %s\n", err);
>  			clean_rootfs();
>  		}
> -		free_initrd();
>  #endif
>  	}
> +	free_initrd();
>  	flush_delayed_fput();
>  	return 0;
>  }
> 

