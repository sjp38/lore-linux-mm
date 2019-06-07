Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFDD3C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:54:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89399206E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:54:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89399206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF97A6B0276; Fri,  7 Jun 2019 18:54:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAA206B0278; Fri,  7 Jun 2019 18:54:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C999C6B0279; Fri,  7 Jun 2019 18:54:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2486B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 18:54:41 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c17so2453230pfb.21
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 15:54:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=U0JzuCOBmxP2yUWiQp2LFy1v+ogLzNhgXy9IDbP9vLk=;
        b=e2FfhFNGSw8Ap5Ahh4JPcuFl5hBND51LYSxlJglfSLrLtSU3B49uRaIp5fkaQpt/R1
         7+zbgMQ5+6KKfcXm6FmziTCxE8MIMKjsjiAqgcoxgD3asp6uw0giS+HZWM0WeEfUxQFn
         1+lQ+al7084MUydSxMoAJJ2+EwxCobnHq9HfCu9kWrF4xjmg7PU7ZanlpgeD5Ts0gqO5
         V/vPmA8BdWsHljY9Yx53igSWt+jyjU6B/N6B0yucn+tcDNGbAuIUGj2zYDq1e2AgHPRe
         aNnyl5qOankb7N4HBiYyGvYFOboMOaJu5sScyo4SiXRsmYdlo005TR+fwl2Gs5ciz0yG
         W82w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWJHjfgSU4W73S0q9WgYk3PSe407Oy742UVuboaV6JUdmi8wkWa
	DPxM3tOmDifbLA8BjYSiVANB60Eklyv7PkNPlQy3CoEOimR5Cw4lurtKCcHIsMOFslbw/X+psac
	bl52QW7Lk3DmY/SWir3tNVNTAJdkFP1uAn8Hg0euVdMUxzZUEWOMPpkspZ18V74eXJQ==
X-Received: by 2002:a65:624f:: with SMTP id q15mr5092348pgv.436.1559948081089;
        Fri, 07 Jun 2019 15:54:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIdbUH8lKj3RdeyzWzukKibNcDWLJkROHGHeSYljqiB7+5ZnWOPpZVGgF9wk41ykYS+CLd
X-Received: by 2002:a65:624f:: with SMTP id q15mr5092306pgv.436.1559948079874;
        Fri, 07 Jun 2019 15:54:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559948079; cv=none;
        d=google.com; s=arc-20160816;
        b=vWjn9nTQsUnpcaPGL7UZkMe8Dv36cKyivnJl+6yWOic+nbveu37A4rbV4zbwQsV8tU
         0NUrkM5ud9vfyS0n1GCYAgedfbrybbpfp83cSVwXC6wdypYkwjJy2xZ4S/vbzq4SmuRt
         R4PbNju/l0dNVh1MhfViz2cLgMa0wFNxUhPDLMidT6hLXDIyVHFFwSaz7uQhHy7luxDF
         xcUM6uXJVODYkDphvZ6zCwF5GRMdoZe6A+dm1uiqJHxtOkNTc0RNDjlxMKF+rn4A0M3I
         Hu7h+GWLfTvlcuDCHUkn98FK1HW7Mr3t+Q1hHR3S/KcFjpC8bTqDsJyc+SpweuJH9t8I
         zVGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=U0JzuCOBmxP2yUWiQp2LFy1v+ogLzNhgXy9IDbP9vLk=;
        b=Nid2Xxl1kJDI3EsmMkaKG3o1vBtgr6dN/pcLyYqyhAHAahC7+Hn/66eWvCRWDDLOoV
         YwH/UvPzMq61qOKKEzWJvWpiPlZ11uuzEGTqkM4eH+Gst0XEftz9r+KeJbhEN5pINEnz
         Vni7m9Ygdv3KCCfi4Kh+jlNsTDLHLTLkWgUyhLxhbUyO5Tra4DnxjmAYGtu9K3HX6f2n
         x/0Dnt2r7I4eNxs6ni2bOOcdn4LaaQy3HNbLLMZKnIUTgkEnj+dc1T29lps2BuZyimG+
         MBsDbVzxEF4/Y2xXnYfaag3YceqRpQaRMZZsXvOLTZxJ42MJdukQD1ZmwQbWMXoK4D8P
         CpeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b12si3104920pjw.17.2019.06.07.15.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 15:54:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 15:54:39 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 07 Jun 2019 15:54:38 -0700
Date: Fri, 7 Jun 2019 15:55:53 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v3 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
Message-ID: <20190607225552.GG14559@iweiny-DESK2.sc.intel.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
 <86962e22-88b1-c1bf-d704-d5a5053fa100@nvidia.com>
 <20190607133107.GF14802@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607133107.GF14802@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 10:31:07AM -0300, Jason Gunthorpe wrote:
> The wait_event_timeout macro already tests the condition as its first
> action, so there is no reason to open code another version of this, all
> that does is skip the might_sleep() debugging in common cases, which is
> not helpful.
> 
> Further, based on prior patches, we can now simplify the required condition
> test:
>  - If range is valid memory then so is range->hmm
>  - If hmm_release() has run then range->valid is set to false
>    at the same time as dead, so no reason to check both.
>  - A valid hmm has a valid hmm->mm.
> 
> Allowing the return value of wait_event_timeout() (along with its internal
> barriers) to compute the result of the function.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
> v3
> - Simplify the wait_event_timeout to not check valid
> ---
>  include/linux/hmm.h | 13 ++-----------
>  1 file changed, 2 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 1d97b6d62c5bcf..26e7c477490c4e 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -209,17 +209,8 @@ static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
>  static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
>  					      unsigned long timeout)
>  {
> -	/* Check if mm is dead ? */
> -	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
> -		range->valid = false;
> -		return false;
> -	}
> -	if (range->valid)
> -		return true;
> -	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
> -			   msecs_to_jiffies(timeout));
> -	/* Return current valid status just in case we get lucky */
> -	return range->valid;
> +	return wait_event_timeout(range->hmm->wq, range->valid,
> +				  msecs_to_jiffies(timeout)) != 0;
>  }
>  
>  /*
> -- 
> 2.21.0
> 

