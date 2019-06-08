Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69DE5C2BCA1
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:32:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2078A208C3
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:32:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="GYKNG1gu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2078A208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EE586B0271; Fri,  7 Jun 2019 21:32:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89F276B0273; Fri,  7 Jun 2019 21:32:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78EA06B0276; Fri,  7 Jun 2019 21:32:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 59B316B0271
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 21:32:44 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id n14so3551001ybm.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 18:32:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=xVgyj/Sltl83MtwATtJ5A8fGsNYheaZeYpyqP7L5KAE=;
        b=YND7LYJKLXBbFYdpFZ+WdMtS0LDjfiYax8GEEzee5xHU4D1gYrTlDhw8Ns17dIS+wu
         yTNJjdbPmkKCSunT4FI+G1f2NqEzNSlCuxQPL4YGmU4WQNVEzRPFW0s1wl8vzeFZN+w6
         28QrxBpUoO2obyol2stqaB/VHeSIE4lXktksSmoxWaWKYwatTrAe8a+9dxIHNUSjIcq9
         pnrRSeIIsPIQWlafVdJmpRN7afdoLx0X+2L81XGHWUg0CuF+9mI6U8JB8NUgqla9LU/i
         YQDplZq1UNNJnaeBukgk/SojuhX8kkxXXO9mUorb7QAC6JCcLBxXNaxStq3bi010pmUg
         L1ew==
X-Gm-Message-State: APjAAAXe314HrSUZ94CadCHyiRMETg9RNUE2KQpHr5Wm5+x6yfItTlhk
	v/hCo//yGpXGIcJAJVgeza/2p0pqr2J1KbfDNmStG5Pbvzx8XQujOSZF/asqlIZrzEB00llw39A
	n5/lAqSRmCU9k+JbD08hd+oLky6yFNBOb2L8a8UGr4/tybd2NAWXekz/hvAz9700Slw==
X-Received: by 2002:a25:fc15:: with SMTP id v21mr19649923ybd.463.1559957564100;
        Fri, 07 Jun 2019 18:32:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmCfjxruR+WfU2591Bx3MW6TFp4F8z0JZ+MMox2511lpTJjKUvptstWsYyjW1PHMIYrfv4
X-Received: by 2002:a25:fc15:: with SMTP id v21mr19649890ybd.463.1559957563471;
        Fri, 07 Jun 2019 18:32:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559957563; cv=none;
        d=google.com; s=arc-20160816;
        b=z6e+qGYZTvfiFcZFbiW7gwZtOYmpXGT/irjeL3hR+7ZY8un4Ode9yH/zj3rRH4QuW4
         Fjedg86ZKrwyYbNTvqnrwQkEkcCijp48P9jm1dWeaErgmp1HKo2eKrbCUHUGQJQ2MmgB
         E40i/8laDM+sELGDTXhoxwMc00XlGGRx5kyaY1inK2aMnyXRs+U248fchR331nJoRdxL
         jRoxtNjup1VmJ0TbLowIJXK7636PrKQTrJxY4YHPFeSaZeueJz1rZ6iuUc0LR2EVAd1+
         CPvZgk4atvdtdsOuhOQ5QfdyvvQJwAoKvF59XZLPlUc04z69v2u0PZvpCxULlA29PFn8
         JA6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=xVgyj/Sltl83MtwATtJ5A8fGsNYheaZeYpyqP7L5KAE=;
        b=BoPIbLpEoEO3ygLdU4gJKTHQXnt6pzTtSkRWrATCDrvWlz1x61nrjsU15zA2u70Mlq
         vZdXMS2Tt1C4ccIxhvAvS5fLyUiNY/SJ9BHjJSi3CgUMbMLrHqkKn0mKOyJD221TCrub
         Co+oQ6CK2whCi1H6E3Ue+mfrvgEDTsV/AgBXykmAOaebOGbgxZGZqgT1CQ+/Ic2rHbKe
         zpTNtyCCN8w9hIBIAOJ29W6haTblIEWj/atma0anDdd9VQo6QIhHI6LAvqUjJaLc9Og2
         yhTB0Bjj6Dh/bjSMaT8gQowuAs5WnEQGnD44yAYV1IoUn4W8GZIhNBpFIWa6dYw2CZZy
         3n/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=GYKNG1gu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id m199si1122776ybm.111.2019.06.07.18.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 18:32:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=GYKNG1gu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfb102a0001>; Fri, 07 Jun 2019 18:32:27 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 18:32:42 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 07 Jun 2019 18:32:42 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 8 Jun
 2019 01:32:39 +0000
Subject: Re: [PATCH v3 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
	<Felix.Kuehling@amd.com>, <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
 <86962e22-88b1-c1bf-d704-d5a5053fa100@nvidia.com>
 <20190607133107.GF14802@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <4c1a18b7-6dcb-7ce3-c178-9efd255e8056@nvidia.com>
Date: Fri, 7 Jun 2019 18:32:38 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190607133107.GF14802@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559957547; bh=xVgyj/Sltl83MtwATtJ5A8fGsNYheaZeYpyqP7L5KAE=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=GYKNG1guS/PHUsAd0J2qN9HUV4d3WKr9M1/GPzqHHGQhrOJ6/d/qZI2z5UvXkDVSn
	 Ng/R0UmHQgBZALpk+QV7PGHkieBLm5sE+nOdT9PnB9vhI0YwIaj7FcafynhrREdkaC
	 LVWTBVe98W53OWJnxbiRTu68ZRBvOMlVxzr34UOPe4fHKZMZJBuyJLUupa6MjR5L+i
	 Vvc7YeCTnOwpFbhUOGQnW0FfnLcky93noaVhM7A3AWMPrAFOWIu7BhzYB1hrF1WCP3
	 WI5gua45CZvoJhs+zWsNFiKgRpZH45b1dnLmOB/r8OgGpM4n9GPBKWbsM20ZhqCDzl
	 tB81whaCw2vig==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/7/19 6:31 AM, Jason Gunthorpe wrote:
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
> ---


    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
-- 
John Hubbard
NVIDIA



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
> 

