Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9773C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 11:47:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 847F920854
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 11:47:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 847F920854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18EDF6B0003; Mon, 18 Mar 2019 07:47:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 115526B0006; Mon, 18 Mar 2019 07:47:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1D5C6B0007; Mon, 18 Mar 2019 07:47:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96A0E6B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 07:47:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t13so6888070edw.13
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 04:47:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HetCr8fuQXMNywUFSY0yEq92JOKQSRHRdp7nZi0Qayw=;
        b=NXqEEJRbR5vZCr5i630yppsYkS3DIe3NLgwkVJiZp4HkpNlbwDzZH5T9HxC/bVGkcu
         ifvTKGe/kUTBe8tSYSMW5urt1l8Y3qJNKOVYqQZRGofOoHrNIUzEoG9tF7bOQooiKegK
         em2Dlle6WimtyGc2ITMazzSBXXOgABzwvGidHvNkbYkEGMt7MXCq/lGOZ+UgoI7jGYuk
         AGH6TidvZLn9P9+4YfpRW78ELxnI7LdfqzwsBHv5R+4yl7fmU8JGTDgBJKztPNwSvd0X
         lIm7zoSWz1RgXlfhpsydJY2SAPjiYD+5CPObDfIEbiqqGxUsdgtrq9ds3hrnpHa2/Cqm
         OBpg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWQcYuurFrhWzaB97XzGYoU1SY8x/dQCl4lRo9f+LJuln3aA62v
	SRKoN+2PSryX4I7UVqFYGyHCpS8HgLL9OpYJdHE327pl94fe+ZfgwPagVJQMElnMOMZ3Idp9fM8
	t+hCoGIiE6wyGXzPh5GcyPqoVScQtGx9dqgAbCJ+DDwXtP8IpClfk6p7GX4RUILs=
X-Received: by 2002:a50:b3ad:: with SMTP id s42mr12865237edd.142.1552909626175;
        Mon, 18 Mar 2019 04:47:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJc2CELzNzNXsn/I84PCaIsLhB2TueClxhaTLeDld8uT43WtSjoDEe7puSNghdaVIw4fUi
X-Received: by 2002:a50:b3ad:: with SMTP id s42mr12865188edd.142.1552909625269;
        Mon, 18 Mar 2019 04:47:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552909625; cv=none;
        d=google.com; s=arc-20160816;
        b=C7V+c0VtA3wE2BNapvAYCHI4xiMKpCPO/UCUSYdyzv23B4Xdz4rQ5JFLk9dQu3RETQ
         HZO3OjbPOL+D5EYutE9OgSkhkAM1qg1IiYnWRNnXXUZHUIjw2S21sXsGdb9Vo8fTmfXo
         IRafWDlxeQ6gF1KsQyCxiSoLnEcXkcRtL/sbORQhCecy0xlfafrtHqkt7LYOj2PFLzp/
         kPQYIp1zMkjBO0/7/xD4CDrrOn1O6nGjrugpGmCr13Gq7KLQ3z6q0lvxITIdsvQlKBC4
         5nneVYRHaNifShEpvdJY81p6ob7+/tPPQXG4z/dteEhSzwpHiyznmoicNaEBrRJKsdiv
         aK9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HetCr8fuQXMNywUFSY0yEq92JOKQSRHRdp7nZi0Qayw=;
        b=Nt/3InpmCvmyEj22Uveo7LKXhq7LZCdp9k1B/A90bbSy6rjdaSujrod1XWihbXdD7v
         IDvUE34Hx3ZmtyniX3BkeiKF1kz2EgNjpcrp5I9y/5mhyNVs8VxMNU3AZ1FaP42tQzip
         eTRjRw3+gE8opc7N4U7bYtLI92606DGgsxDW1o3w5dts5/snLT6BtqSK3u3iSxieo/4b
         dN9434JP3RCORf3AtQN+urS/4DJYnOAYKpxRpKDfg14l1OSs2y30ds63D05Q4HIGbWaV
         Em/i9JLfwPQx2xqrAA8M1Dv3c2qSYnGbxQyBlVDIq+Tu+DkGACSx2lruu27MDUBhEMvW
         AeBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h13si1198642eda.215.2019.03.18.04.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 04:47:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 614FCAECD;
	Mon, 18 Mar 2019 11:47:04 +0000 (UTC)
Date: Mon, 18 Mar 2019 12:47:03 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Richard Biener <rguenther@suse.de>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	the arch/x86 maintainers <x86@kernel.org>
Subject: Re: Kernel bug with MPX?
Message-ID: <20190318114703.GE8924@dhcp22.suse.cz>
References: <alpine.LSU.2.20.1903060944550.7898@zhemvz.fhfr.qr>
 <ba1d2d3c-e616-611d-3cff-acf6b8aaeb66@intel.com>
 <20190308071249.GJ30234@dhcp22.suse.cz>
 <20190308073949.GA5232@dhcp22.suse.cz>
 <ec2110b1-abae-4df5-fcd7-244620634a00@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ec2110b1-abae-4df5-fcd7-244620634a00@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-03-19 09:51:42, Dave Hansen wrote:
[...]
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> MPX is being removed from the kernel due to a lack of support
> in the toolchain going forward (gcc).
> 
> The first thing we need to do is remove the userspace-visible
> ABIs so that applications will stop using it.  The most visible
> one are the enable/disable prctl()s.  Remove them first.
> 
> This is the most minimal and least invasive patch needed to
> start removing MPX.

Is this something we _want_ to push to stable trees?
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  b/include/uapi/linux/prctl.h |    2 +-
>  b/kernel/sys.c               |   16 ++--------------
>  2 files changed, 3 insertions(+), 15 deletions(-)
> 
> diff -puN include/uapi/linux/prctl.h~mpx-remove-apis include/uapi/linux/prctl.h
> --- a/include/uapi/linux/prctl.h~mpx-remove-apis	2019-01-04 14:40:06.853514089 -0800
> +++ b/include/uapi/linux/prctl.h	2019-01-04 14:40:06.860514089 -0800
> @@ -181,7 +181,7 @@ struct prctl_mm_map {
>  #define PR_GET_THP_DISABLE	42
>  
>  /*
> - * Tell the kernel to start/stop helping userspace manage bounds tables.
> + * No longer implemented, but left here to ensure the numbers stay reserved:
>   */
>  #define PR_MPX_ENABLE_MANAGEMENT  43
>  #define PR_MPX_DISABLE_MANAGEMENT 44
> diff -puN kernel/sys.c~mpx-remove-apis kernel/sys.c
> --- a/kernel/sys.c~mpx-remove-apis	2019-01-04 14:40:06.857514089 -0800
> +++ b/kernel/sys.c	2019-01-04 14:40:06.860514089 -0800
> @@ -103,12 +103,6 @@
>  #ifndef SET_TSC_CTL
>  # define SET_TSC_CTL(a)		(-EINVAL)
>  #endif
> -#ifndef MPX_ENABLE_MANAGEMENT
> -# define MPX_ENABLE_MANAGEMENT()	(-EINVAL)
> -#endif
> -#ifndef MPX_DISABLE_MANAGEMENT
> -# define MPX_DISABLE_MANAGEMENT()	(-EINVAL)
> -#endif
>  #ifndef GET_FP_MODE
>  # define GET_FP_MODE(a)		(-EINVAL)
>  #endif
> @@ -2448,15 +2442,9 @@ SYSCALL_DEFINE5(prctl, int, option, unsi
>  		up_write(&me->mm->mmap_sem);
>  		break;
>  	case PR_MPX_ENABLE_MANAGEMENT:
> -		if (arg2 || arg3 || arg4 || arg5)
> -			return -EINVAL;
> -		error = MPX_ENABLE_MANAGEMENT();
> -		break;
>  	case PR_MPX_DISABLE_MANAGEMENT:
> -		if (arg2 || arg3 || arg4 || arg5)
> -			return -EINVAL;
> -		error = MPX_DISABLE_MANAGEMENT();
> -		break;
> +		/* No longer implemented: */
> +		return -EINVAL;
>  	case PR_SET_FP_MODE:
>  		error = SET_FP_MODE(me, arg2);
>  		break;
> _


-- 
Michal Hocko
SUSE Labs

