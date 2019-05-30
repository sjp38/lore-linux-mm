Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB165C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:07:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CD22204FD
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 12:07:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="GGWtO+am"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CD22204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07DFB6B0010; Thu, 30 May 2019 08:07:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 006FB6B026B; Thu, 30 May 2019 08:07:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE9526B026C; Thu, 30 May 2019 08:07:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1E56B0010
	for <linux-mm@kvack.org>; Thu, 30 May 2019 08:07:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y22so8345664eds.14
        for <linux-mm@kvack.org>; Thu, 30 May 2019 05:07:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3JV/VQkyO6ESrIi+x0cheGcU2SxYAPhzRd/KHj8yO4s=;
        b=A8I/yjm9Dk6CW9KNImtn0o5krRhYPPWcWJt78EakgUxsSBMMFtv+WniiNb2DITAJ6r
         nhrNUroKBDWHZF//UeVFLyWqN8XD63REV0N5aamf58ojf5Y7KncBn2zxTDHHaz/nYa9S
         /q53v/GdlVXB7lCncwWx9zy3CHgEDNEaIjW/4XF52dahnoRW1Um5LIcNb8FcvGEs3cee
         dcogFTjD15MgceeYopNXmkLVyeaw8dKk/IOdHRC4/1H/1FVztNz9PAj9i8X8OVjPh6Ge
         9DhWHvQt9tCktPtAQYeN+Ph09IEYAaQU013b2e/+G15/7409GoAoqcTYsCVKPnIWCzb7
         EmZQ==
X-Gm-Message-State: APjAAAV0LTyBNJtchfKYq5GXwFmasngwMuK1VIZu2I73Sl7FdtTLYUF5
	beK+Hqia5oaLr8lGz+ZlzeuL4mjut8RFtm10oBF5D5l2GXRoHU47dqySyKkFg3JxcsZF+qB47hD
	2SqwHIdugFOut5SyfeRWQqBBO8ertikr7s85rP4Su2wkB5YbESF8/wubfLHnAaIKTvA==
X-Received: by 2002:a05:6402:550:: with SMTP id i16mr4201388edx.212.1559218041175;
        Thu, 30 May 2019 05:07:21 -0700 (PDT)
X-Received: by 2002:a05:6402:550:: with SMTP id i16mr4201290edx.212.1559218040413;
        Thu, 30 May 2019 05:07:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559218040; cv=none;
        d=google.com; s=arc-20160816;
        b=PHbQXcmFmdErcRjCKIj5IYoUXPxVhV7UbDdD1IxWiaHF+AOkjko4K0F2E/d3rjMqoL
         uiEj6XHR1VNe877vXUifWr+zydGWINoDEhdwd3+FixYvX87sjpMd82pXJ5OR5CUJZTKg
         xoQMs8qTFlvCL4ob+1BIAKGU5aLRHr3IW0we5+wtfum1AtYhuxdnOs9Ya9az9eG+YXyR
         WCmvGSEY+uSBEbY/i5PeXLVqU5C+MekMJ8QnqmZS3fUBJpCiH4htzbT50foYEaWTmWDL
         SsChMhy1RDILN9LCEKGRHJzNjO/oFV8sc7Ulz7gw1xrvM0Ozy7ck81QpF0Az6kojig/f
         Zrgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3JV/VQkyO6ESrIi+x0cheGcU2SxYAPhzRd/KHj8yO4s=;
        b=vjR7KCkjVzmSwJV+czl3ixC5PUgyvDg3pjiFkK/yK/2Jtis6anVd3ZBgaxA6OLTpwj
         JhJ4qiJyM2JoBFHFJtf7CvwTFRG1SkOOFRrurIETIfpKRkkOfqCR5PmIJf1r+XMrgFHc
         qFH3GHjAeBYFL0zxA7Dn1m6Omd4rRhEZCsXJsx71uqhp77uD6HtC3YAbjDc8JMYSvhdR
         EgLnhDYsfNyRAO4hCy0T610osCxY5hqt7UtkiwdTF4RJ/qiC6WAyZzbX4b9glYHVwW7T
         h5iuhCx58DEKDJGyv5i4JSFWFjytlOcRgpeZ6vy1d9OU7ytHE478s4D6fz3sHC4w9RHt
         +PjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GGWtO+am;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gk17sor539218ejb.17.2019.05.30.05.07.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 05:07:20 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GGWtO+am;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3JV/VQkyO6ESrIi+x0cheGcU2SxYAPhzRd/KHj8yO4s=;
        b=GGWtO+amrl1+ByU0pLLXPn/FxONeBh3xk65sx+eVgGXegyl/y1LDn8hY8HfW0lN0HI
         F6tOFyn8FyW0H+lgDjB1GvK4rCsAYArwu2PsNX4X+RCzMi+WeWEUMIsPxShAEdwtNAjS
         oC6vb9ozpg+eemJSTav8I0lovUy2ngMBcVIVJW7UR7QKCmnA5o3CcG1SD+meazD7SJSW
         ub6snA54JUX9HeqXA1X1GZDLnAaYNIWoW5DKNnWfHHM0qZz+qfZ7ID/FEvEThOzus/ei
         dPQdj2OvjOWJZclDuUpyYCBuvuV/WXHgW3jdCY8WkJ1VFr/RDUCRCKEe4XmbReGAeniR
         wKOw==
X-Google-Smtp-Source: APXvYqzboVQ4IYoNX3TXCypP75fPfr4CCzJ6DUX3ZRs+3ZHWE6njrMWRYnkMJveH6jDCZ34/kA6D1A==
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr3253914ejb.38.1559218040079;
        Thu, 30 May 2019 05:07:20 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c12sm392594edt.38.2019.05.30.05.07.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 05:07:19 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 185351041ED; Thu, 30 May 2019 15:07:18 +0300 (+03)
Date: Thu, 30 May 2019 15:07:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, hannes@cmpxchg.org, mhocko@suse.com,
	kirill.shutemov@linux.intel.com, hughd@google.com,
	shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/3] mm: thp: make deferred split shrinker memcg aware
Message-ID: <20190530120718.52xuxgezkzsmaxqi@box>
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559047464-59838-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559047464-59838-2-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 08:44:22PM +0800, Yang Shi wrote:
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index bc74d6a..9ff5fab 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -316,6 +316,12 @@ struct mem_cgroup {
>  	struct list_head event_list;
>  	spinlock_t event_list_lock;
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	struct list_head split_queue;
> +	unsigned long split_queue_len;
> +	spinlock_t split_queue_lock;

Maybe we should wrap there into a struct and have helper that would return
pointer to the struct which is right for the page: from pgdat or from
memcg, depending on the situation?

This way we will be able to kill most of code duplication, right?

-- 
 Kirill A. Shutemov

