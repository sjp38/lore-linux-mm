Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACBF3C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:26:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 750FF21850
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:26:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 750FF21850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 135928E0025; Wed, 27 Feb 2019 12:26:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E4428E0001; Wed, 27 Feb 2019 12:26:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 022218E0025; Wed, 27 Feb 2019 12:26:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B33F18E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:26:50 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e46so7339368ede.9
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:26:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mpF2EXx3ZQbB4dBL50O1iDIl/4NubgNBiRT8H8SM5Bk=;
        b=St/mp3paEM7FB/0GY6d40DEIBNeoGPbXR/bHWQ+AEziZmby5KqizZGZVkCw3g0YsZL
         mHQ8HTRc7eJFx86RIfklVXg55PbBzshgJzAQkVuVPI8ktEGFTVH2g12Niqdbt0RaRgsT
         TFZN4TxGNk1Qgz9d4W6Q7RFAoGhqeR7WPdp62TPx8nZ8bGWPAYCmxHmHIfnOEoPXRW/U
         Bx4b/3TSaz5dKLnWALzYXRQJzSgWAY37gzYcFqBKYobkqAQPcjSWgU4hpU1yt+DFyaU8
         x5ui8N5swGtZ9Jnwu9e3eSd724Y9cImk6VflwVc4owoZsdRS2k+cJbOjnjqsY5Wl/q20
         kj9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAub3MreEbdr5z8SI5hqZMDTt3+7rkbXkKDr3iLaNhZYIfGQkuMtD
	8rz56PrLdRk2uLMlDK/Brp5C466/tNKZp6AD9SB/gl6AsKYmDdrnNfSvRIJQr+Om2PH7GFZBDxW
	vthcYjqS1sn7LraKNXiIZiNoSfcWS7lJ3U3GFDDY8nGifMgsyCf/FAOHRuhWaXXJQOw==
X-Received: by 2002:a17:906:482:: with SMTP id f2mr2363054eja.68.1551288410277;
        Wed, 27 Feb 2019 09:26:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia16tptn9OWJV3760inGbcsLeMUbrNwqlPEVxOMv1khpywP/jooQgmpq0BPIrAw+814J0TI
X-Received: by 2002:a17:906:482:: with SMTP id f2mr2363016eja.68.1551288409467;
        Wed, 27 Feb 2019 09:26:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551288409; cv=none;
        d=google.com; s=arc-20160816;
        b=MdO7CzSzH1TvRXfWtP3k18JIPTQWQyfW6b49HKd75LQ+/jxwRhk99Snm/7PACks+gD
         vebT6m//yVdvVKuzPcrJvtcBJcwo7RiHL08MU+F7wMMQLkMRUE8Dsz+MQ6Bc1QlNE02o
         sv+du+MuFmNsekeZVfYNoa0SFsodz/J78mQFvjMvBW61OkQTFV7slhK3cPPFDwzGgVU3
         mJr37YSk0omWX4AqB7ADdRJ7Hb9wDj8rAnyC+MqJ4VgNPvObrM26S+Lu0EOTWwlSgveO
         bebVarSj/jYpdK8rk+u5zW7qYXVQGI8V66fF+iX86TLxLHK22bM+v4Bx5kaaiUoLJCYc
         bluQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mpF2EXx3ZQbB4dBL50O1iDIl/4NubgNBiRT8H8SM5Bk=;
        b=SlcSM2zQJKNXigqp6g3TC/ciycRVoIxM3IK5+GVaGCTWl078GUz/CIO5oZT4p8Fcr1
         TtBaIMQvnBMLRUNRB9VBXyJ7KMBgEx54a8IWaL6C1jbPYbkKVvtXiSNGRLAnu0yGnbp+
         2V5ZiklCSeXeO30d87vXEG8X224yKOiN+0RwuqVbJqF3WhGNXGERWZo/7N5wKICgBg9I
         k7vtLftg929ZRttE2L9y6ofFbejyTMBs4ZqtewKFG3QfSiRpIgijKqSweUw42Eu0Vp1B
         Z0Pg+rihFwAg2NKlBkX0KSK1NalXBCPwJgrhdAkth/UaDrlBDwSyJUgdWEoxZmsKgtwo
         dubw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f7si6099593edm.167.2019.02.27.09.26.49
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:26:49 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6A6981688;
	Wed, 27 Feb 2019 09:26:48 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7EC223F703;
	Wed, 27 Feb 2019 09:26:47 -0800 (PST)
Date: Wed, 27 Feb 2019 17:26:45 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/page_ext: fix an imbalance with kmemleak
Message-ID: <20190227172644.GF125513@arrakis.emea.arm.com>
References: <20190227172445.75553-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227172445.75553-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 12:24:45PM -0500, Qian Cai wrote:
> After offlined a memory block, kmemleak scan will trigger a crash, as it
> encounters a page ext address that has already been freed during memory
> offlining. At the beginning in alloc_page_ext(), it calls
> kmemleak_alloc(), but it does not call kmemleak_free() in
> free_page_ext().
[...]
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index 8c78b8d45117..0b6637d7bae9 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -274,6 +274,7 @@ static void free_page_ext(void *addr)
>  
>  		BUG_ON(PageReserved(page));
>  		free_pages_exact(addr, table_size);
> +		kmemleak_free(addr);

Same comment as for v1, call kmemleak_free() before free_pages_exact().
With that:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

