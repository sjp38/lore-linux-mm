Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5E5DC04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:10:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58DCE26435
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 06:10:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58DCE26435
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A975C6B0278; Fri, 31 May 2019 02:10:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A48396B027A; Fri, 31 May 2019 02:10:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 937DF6B027C; Fri, 31 May 2019 02:10:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 417136B0278
	for <linux-mm@kvack.org>; Fri, 31 May 2019 02:10:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t58so12278888edb.22
        for <linux-mm@kvack.org>; Thu, 30 May 2019 23:10:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mECIkjweKVe9lRfO37XWt/iCFvyVYheVWVZfVUAJkuA=;
        b=NsOhgIZKROmvxdhLJCeGXw6pPk7Pa5d2qKXyMBDW5CJx2PC6NPAUsQbnGvqElIqz56
         MBRzOB73HjOeH2IGc2ZztL3AX33uL9tp2Y34ClANUwip4a6q2yaZD6vNGnBDRRU8EKL5
         Pg9BJhGs/+u6wyj4yb3cTtkTpGP4BDB5HcogUEb7S9UUAss8Eg2GXos9bDWQ798rJabE
         Vkr/ud371zT5aU6RMn6WXbka/GyAHt/g9z+8CGlMf8SAEh47qAmGFQQQABgPNpFjcoao
         Fz3rpV3YCN1uqUV580vG+GfJZWP7vEEQXUYwveTOf2QL3fLQQuaKdZ+3l/l+4Poa4ZD8
         gILA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUjksloDFju/KjzSzIdgXWO81ooDldZEXZRYI5xyxpRB73GHeQT
	1lMhfupSVaRJ2eROebBdduIBPL9Xt9Id0vYun0VaNmhxfdB3k8/OriMMAql+kUXv5UpAbolbn3V
	ysrzVR8MAiqWZIUPITkW8Gykyb2OIAW5fI6E1ow4MxXfgy4z7vlGIeD4Z7ljhYyA=
X-Received: by 2002:a17:906:3911:: with SMTP id f17mr7558414eje.178.1559283050837;
        Thu, 30 May 2019 23:10:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwP8JOqrLF8lPXTFty1hOP0nBflNDM9xIXMbhdWzKop+JPwvHk9aBJtYssHMNzJEjMEp2hJ
X-Received: by 2002:a17:906:3911:: with SMTP id f17mr7558355eje.178.1559283049932;
        Thu, 30 May 2019 23:10:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559283049; cv=none;
        d=google.com; s=arc-20160816;
        b=FNyYnYqR0wHdKBVFe90M2GsoscGmBEfxifqc1D/0RcleMqiPJFOD2J0Z8QoQjgbU9S
         iYgNvoGy6QjXKMQlj8QvjVwI05Ylf9QSk9IjOEj3AZSuRnWiOOhXjWN42rHnrrdXJ6vy
         rDoTlmL9Ym8V8RyQxoMIqCUISB6IyKyzxKzq+YcJK5T3pv6HpCOm1X7+DrvlTdx+EUKd
         JNB1IPNZ04YQLLlucaGjek98fcWNAznwah+jUu8TdHLGG8R328zfhYZdqglh7xPFHfKx
         jCzCarzPlexZ/nDelkH81qgWNh+AhXQvSUEUnfc/EAeSw3ZO6DyMHzPPIuAcrQRNrig4
         tkDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mECIkjweKVe9lRfO37XWt/iCFvyVYheVWVZfVUAJkuA=;
        b=kePM0Fnnxc0+SnhLs14UzOatFkTbanT/bKQhZkyhsY+VOHzHlRTd82DNJXhhbI55cQ
         o8CiRfDS6/L81eA0ALXV2mdRSwzSoxxGij239SGSEsloKanE1RSyjM1ametfJDbCJB5k
         nwRl+PTAH9Fs7FrqIzGDUn7Wa+bLrbLT63U+8Y735ZfHDBQSbJqE4O8OUdrqmRfWCofM
         s7BJGxDkdIW1yEdir9N+VEzdY/ksacMU7c8xNkwvy1QItLIxlDbXky6Lbs/EUZgNn2XL
         Sdxbw0n+w5jsICALauEgYbDiMyW4e/eLAU8ARMRF2WOOljYsovdK7edd6DeOEsOAFH/x
         +4Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id se27si3131905ejb.2.2019.05.30.23.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 23:10:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 44BBFAF8E;
	Fri, 31 May 2019 06:10:49 +0000 (UTC)
Date: Fri, 31 May 2019 08:10:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH -mm] mm, swap: Fix bad swap file entry warning
Message-ID: <20190531061047.GB6896@dhcp22.suse.cz>
References: <20190531024102.21723-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531024102.21723-1-ying.huang@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 10:41:02, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Mike reported the following warning messages
> 
>   get_swap_device: Bad swap file entry 1400000000000001
> 
> This is produced by
> 
> - total_swapcache_pages()
>   - get_swap_device()
> 
> Where get_swap_device() is used to check whether the swap device is
> valid and prevent it from being swapoff if so.  But get_swap_device()
> may produce warning message as above for some invalid swap devices.
> This is fixed via calling swp_swap_info() before get_swap_device() to
> filter out the swap devices that may cause warning messages.
> 
> Fixes: 6a946753dbe6 ("mm/swap_state.c: simplify total_swapcache_pages() with get_swap_device()")

I suspect this is referring to a mmotm patch right? There doesn't seem
to be any sha like this in Linus' tree AFAICS. If that is the case then
please note that mmotm patch showing up in linux-next do not have a
stable sha1 and therefore you shouldn't reference them in the commit
message. Instead please refer to the specific mmotm patch file so that
Andrew knows it should be folded in to it.

Thanks!
-- 
Michal Hocko
SUSE Labs

