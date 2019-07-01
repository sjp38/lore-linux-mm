Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 628D2C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:43:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29FF0208E4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:43:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29FF0208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFC9C8E0007; Mon,  1 Jul 2019 03:43:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BACF58E0002; Mon,  1 Jul 2019 03:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A756F8E0007; Mon,  1 Jul 2019 03:43:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id 5923D8E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 03:43:08 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id c27so16296319edn.8
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 00:43:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sEPibAbwlLc3yO8RNzYTWtjvFwxmlHUubQz7M+/MJNY=;
        b=axWOt4mu7oa37nSIWNjNsaVgjobWuLyXaBn+qMcdOxtMQNiBGLMspsB46Isl1rFzyM
         LOTa98K9ZuZWqdUASLIa0EWbPdn0tvvLoRqWWNNqwIgVezzipAAXM3uDlf6bqdrbN0h2
         1dj2tW8BAHgXkx9yLNyxqv/xGsFAASo6/arzEYhmBHxp6VCjGl1H9d9OgGdv/Y6RVjhL
         4SvCUHiliYDisGvkUVhNYlU594AeDYHt7tOoDCy8RPZIokq1huW2mKGyGUED3tFnHr97
         yb8w7CQdpohRI0/6yggxEZWFn09oK5Q+szkfzcjHXQJFzrzMe3iAHEiqE+CCRWjX5jyp
         I6wA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXywkljWfq+1pxSfVoNAa/cO6sKP6xfAGiF+vm/hQb1WhQclK+8
	BzAGyBz/PV8K6S5+O4F0ZDKDNb36PEU+6AOGIfMVTeezAbL7s3ZpIgpOSmNo9vRMq+ihsGc7wE6
	bIhmKkkFpo2qlz7Mx2TrStFsuSRzet9+/nPFq76gwJsNTWtwlXU5wABzed9M4mbM=
X-Received: by 2002:a05:6402:64a:: with SMTP id u10mr27433817edx.35.1561966987947;
        Mon, 01 Jul 2019 00:43:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwt99dEm2UMTZzdGWkLGyMi3t1jO06SLWjd0BmjxLBbdAFIFal59yxsGYVm3SSiZqCuUfO6
X-Received: by 2002:a05:6402:64a:: with SMTP id u10mr27433770edx.35.1561966987335;
        Mon, 01 Jul 2019 00:43:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561966987; cv=none;
        d=google.com; s=arc-20160816;
        b=lllJ3b+pjCe09wkewzMqBhkATEh5uC/joVmmOjNE/KH4ON/0pRGjt7OJFGiEOVR65d
         jolTo2u6D8mb2P+9RJBsCiEEZsrotzD7jxqk9apSdPppwe3KBxUm61CqyoeWlIZmsJ8i
         h3LOWsnTEe4vyHbZMtvNiJlJ3d4ovFGM4KIauknuvAmtwlhoTZ2pYlMjBj82jLOGrbVp
         WojEtYg0+Au727jlWVhD6TrXyTDSti7ToT6NszB0e08lY4i9wcOyso7Z5V8SVrNOffaL
         Q8OzJfcBLgJFgxSKy7OM4wIK4jTmdKaRFaSTBhCXKXe0GCiVysQMqSiCN5HkBMR3SiQs
         qfBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sEPibAbwlLc3yO8RNzYTWtjvFwxmlHUubQz7M+/MJNY=;
        b=YCLc9onVPH3E0SFX0XJYc5CRYvSKbNKwmrtwc2qe/vuxmor0T86Ae68WnTLK5fJmhB
         Xc4csNHIQwsLbby9JPAP3C53dGt63SLo1LbVJn5nL99uWyIxHtj9C6QeeT46hepHtiw+
         vetu7W0ht7wB2az+qDszqF/FasP3DkHvHnFB+ka/OdaHaqKEFu/r4MYEFvHPmJCNACEA
         PPIu3BaAgweZB6mi5U2oanPsMc4/jeACDfEVaKe7IYFVYetJmT2reowjKM2eloqrG0rG
         burVgjKma38B8za+9wgiRddTsUvIkoEokcLt4Z7ZtjlmxK1gNCciYOkCZhxsoIetlp5H
         ANqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n55si7968374edd.231.2019.07.01.00.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 00:43:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C7434AFFA;
	Mon,  1 Jul 2019 07:43:06 +0000 (UTC)
Date: Mon, 1 Jul 2019 09:43:06 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>
Subject: Re: [PATCH v3 02/11] s390x/mm: Fail when an altmap is used for
 arch_add_memory()
Message-ID: <20190701074306.GC6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-3-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:43, David Hildenbrand wrote:
> ZONE_DEVICE is not yet supported, fail if an altmap is passed, so we
> don't forget arch_add_memory()/arch_remove_memory() when unlocking
> support.

Why do we need this? Sure ZONE_DEVICE is not supported for s390 and so
might be the case for other arches which support hotplug. I do not see
much point in adding warning to each of them.

> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Suggested-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/s390/mm/init.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index 14d1eae9fe43..d552e330fbcc 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -226,6 +226,9 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	unsigned long size_pages = PFN_DOWN(size);
>  	int rc;
>  
> +	if (WARN_ON_ONCE(restrictions->altmap))
> +		return -EINVAL;
> +
>  	rc = vmem_add_mapping(start, size);
>  	if (rc)
>  		return rc;
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

