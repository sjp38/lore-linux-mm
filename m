Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 006FAC32754
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:44:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B95B2214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:44:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B95B2214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 006658E0003; Wed, 31 Jul 2019 09:44:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF85F8E0001; Wed, 31 Jul 2019 09:44:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC2018E0003; Wed, 31 Jul 2019 09:44:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A68E58E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:44:24 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so42471260edr.15
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:44:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0d8tWhq/mfkJ30s7UZNNWMJuhXrfP7P1n1uUM7YlYkw=;
        b=KSYVXl5jjQfWnkGhb8ULPZXGgpQmBj0+J+qUtmg1XalXnLmVRCT5cRJBw2zB5/ENQX
         dSFe+z8PCFLOHrHkJp+mBRjdDwYOfTaLh4RBryiOpMlJwqM+hMadZ+DhMsCnL6DeVrX3
         2ClXl0RKOgYvtvsf+ypnL4LfJHhMdLBoOxnULFVoIEM1udRl8FS8Z6oGLbBEw7/w5gPE
         zpsjqE7d0DPeFi2om+wo2Ze7RgHRUiGQaR5lU3NWjwQxhJrtYWWnPyywa+TjogJIx0rA
         E8hohXMb4SbZu8J0GXbUzwGGQsY3lYzADTYXKUo0PQ0imKZbriYmRSnx2EFnNJN1P7fo
         ZiuQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWIbVOy7jbRplqS4Mmo92QqkRRdlw2odHliw1L8pdRyHExAvYzs
	mmnQKkhq964dxjsoOrrdi7gQuJIycorn6Un0vffk6ogmZKCLcTXvicgELYzxIigGmvL7VyeAZp7
	b2CiUGdFD+SqNE2obCfK/z89yG7MTXMEEh2g/7dvLRn5u77JWtkdKc3HBaS3L3wo=
X-Received: by 2002:a17:906:3419:: with SMTP id c25mr92779095ejb.305.1564580664246;
        Wed, 31 Jul 2019 06:44:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyB9lzL5Irg2gs/w8f2UMQn6F9gBpAAiMJ1wn2l/SAX+zU+J3UM1QC0jtZeWiiU4DMh8H0
X-Received: by 2002:a17:906:3419:: with SMTP id c25mr92779049ejb.305.1564580663634;
        Wed, 31 Jul 2019 06:44:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564580663; cv=none;
        d=google.com; s=arc-20160816;
        b=QRhwJKqQmXDTlAKbl3Z3jKrZmwLKwkSs5ShoNAnCVeEYF5V6atcLshUFLChz2yw6KQ
         t8f45CoGxQXqox2Jk3v8vtQzRX1dfbGOzYr+jMicSX4PVOJ82rU6F7w39D564TasXRHn
         yDqCUvwExgRZsSlXca1ohpDJLUREAI0qiIyGFtiSqvwIKKmHNHr0/SN/0azdTKhTlJr8
         2ZP/CduMLySI9IbItrQmAsoM3eKb7I8RLuIh5Fj8omJ8Qc3DBMEt7LowhSLgkcQ+TiZo
         FFdviquuq7DoJsv6EnlA7r1bBMRO2H2sRjXAs46ZSMW2klSz1w0BpEivRCddN4sqWdFI
         kJrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0d8tWhq/mfkJ30s7UZNNWMJuhXrfP7P1n1uUM7YlYkw=;
        b=hOPSUI8xdaTUh1+3Xdzc60mCqQL4a7mVkB7C9dgDhhNEVcSlNTevHAiCcyZYQzey1a
         q4M1k3q1VjSTRXc3WENKuGt2V6NboSNItxEUFAnlg/te0I6xAaC3/Ipo9jvqC5+zBhpF
         wByIjJfScB//iP1FqXMorHsoDeAWrKkQYPn1B70OdlvDJuy0JBHYcYjJcggFROj5SCQE
         YSUaD0UsjNr4YYdTHIGB+xfNwj+fbXRHVAwbXcx/RUM6LK4kuz5RhDhqrM3LkvW42IG+
         1EifghKn2YZz1OOHW1wNzTWc5MxM8kVGf19UZy0QYjgS6HYD561PQzI00DHLtUN+DUHE
         LHdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g37si20128016edb.268.2019.07.31.06.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:44:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8AA4ABD0;
	Wed, 31 Jul 2019 13:44:22 +0000 (UTC)
Date: Wed, 31 Jul 2019 15:44:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] drivers/acpi/scan.c: Fixup "acquire
 device_hotplug_lock in acpi_scan_init()"
Message-ID: <20190731134422.GS9330@dhcp22.suse.cz>
References: <20190731123201.13893-1-david@redhat.com>
 <20190731125334.GM9330@dhcp22.suse.cz>
 <d3cc595d-7e6f-ef6f-044c-b20bd1de3fb0@redhat.com>
 <20190731131408.GP9330@dhcp22.suse.cz>
 <23f28590-7765-bcd9-15f2-94e985b64218@redhat.com>
 <20190731133344.GR9330@dhcp22.suse.cz>
 <b135e167-a0e1-0772-559b-6375ea40c9c4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b135e167-a0e1-0772-559b-6375ea40c9c4@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 15:37:56, David Hildenbrand wrote:
[...]
> The other extreme I saw: People dropping locks because they think they
> can be smart but end up making developers debug crashes for months (I am
> not lying).

Any lock removal should be accompanied with an explanation that is to be
a subject of the review. Sure people can make mistakes but there is no
way to around it I can see.
 
> As I want to move on with this patch and have other stuff to work on, I
> will adjust the comment you gave and add that instead of the lock.

Thanks!

-- 
Michal Hocko
SUSE Labs

