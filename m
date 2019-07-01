Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A590C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 12:47:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 269F22053B
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 12:47:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 269F22053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA3B36B0005; Mon,  1 Jul 2019 08:47:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A54398E0003; Mon,  1 Jul 2019 08:47:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96A138E0002; Mon,  1 Jul 2019 08:47:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6AE6B0005
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 08:47:19 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id s7so16706978edb.19
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 05:47:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=d5pLMdETv6HIPOwvN7upABLr86gmjbj8sBZkVkvkY1k=;
        b=N2qzJ4HkgouVk0KsKbMQxr4TTJJi9Jk1XkPZ4gzwPwpnKdR9Z67PBDEZOCYxaVbs0O
         zZXL1pKc+wYeBjSh4cHT6rppvL/Plq3q4DO5OzBmbEclM38tjJQX/ts3zhqYI/AJUX/8
         pw5b+rT7DKSmcdUaYhqwPdz3PR+/iR/6RnCj/yWKkpHKsDQODGq5XPZb+rWvqIom1IXt
         1YD6CofSt88JQLf8JCefCr0QYMTdwC4N6gXgI3x1c+3fZyYrL67bwo19oQWTk7WohIDW
         OxvjKYmV+KCpp072gfYb3uDQcF7vJCUWh0qG6qS6/5/CyPLIQwY3yQ3l9eKAW+LYljh5
         g6fg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW8FZ3dB8h5+oVIDUR2uggpw8tpPlly1ZvvJmXtryWfIz0mDQXr
	05y1Fvc6KaqWb+2udO7AXbTUYT9+cU9HV3UWIRUyQ3oiABeN2C30EjlapZhdhn79ET9DdBPhdks
	xTQY8aer/tEdjo1Ah5AYJKsb/xAIOXprlhCElmliUyJFE40wYhzsRiscnlwElVX4=
X-Received: by 2002:a50:91e5:: with SMTP id h34mr28260331eda.72.1561985238854;
        Mon, 01 Jul 2019 05:47:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRIa4t2HBtwbREGvU/3xqpOk/ZLwx+rf1crix75DBXQ5SrkDUiT+eGF5gv7WuqBB2oVW3i
X-Received: by 2002:a50:91e5:: with SMTP id h34mr28260271eda.72.1561985238119;
        Mon, 01 Jul 2019 05:47:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561985238; cv=none;
        d=google.com; s=arc-20160816;
        b=STS2rxGLPLEhT/EXCSeYwZI8T2CsBdkGiBim6zJMF2dHUpB1QC5XyrReKO0Lsbk3ia
         /sCGUHAFOMdEcoJWMN6k9zA4hk5aLdwkkVR0n+Aktp977MSZR4mJ4BmEri+fUythCbVJ
         m41CzMYLEUJdB9ckAJ8tYfEGZAsYDJNT9zwxrpRFK7c8lmBbUdQRetk4266hINIrq0Kj
         SsKO8P2mGVqc/nDm3FgYZghyOnwQIaP/WbF5VXNt4cw1POOuiAFZlyr0KX49oWn0hNob
         2ZjblwGGJJNUQIV1Du5roBrzOXppGOCJSzSKzBbsli6FObur9eIFtx4D/0hnQuauJUJJ
         sFhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=d5pLMdETv6HIPOwvN7upABLr86gmjbj8sBZkVkvkY1k=;
        b=HuChFCw/JXrQY4HDr2JuVZJ4H2sook8wEGU63HxRfp3pijGVfCe5t1nj5DWkFny6hr
         Ut6gaidUKMAqoJ4bdnJ+/6Bt/jyb9mNKnIk1/BQn/4L/QyVOOzhdd1Rp7HOXOhR8OnOz
         vcKiPe8Q6VminPo+pJDkZrHPzgqvqQQh3ZiVRygExGA3CKK7LfI1SSmnGSEIpPABQzLL
         hGWDCZL0q0hbN7rOnWbChrnTsYfSbcbKEM3iKI2Mxdik6mHPmDNFMaWG8v47kyBwFWBn
         l/wgPWVMleonHNcCFnUQUAXDT3ntxjATDHdj7M6qHJ4+Tl9U+TYUzY3ZPq5zyZYadsiR
         /e9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a45si9205842edc.332.2019.07.01.05.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 05:47:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8ACFAEF5;
	Mon,  1 Jul 2019 12:47:17 +0000 (UTC)
Date: Mon, 1 Jul 2019 14:47:17 +0200
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
Subject: Re: [PATCH v3 03/11] s390x/mm: Implement arch_remove_memory()
Message-ID: <20190701124717.GU6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-4-david@redhat.com>
 <20190701074503.GD6376@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701074503.GD6376@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 09:45:03, Michal Hocko wrote:
> On Mon 27-05-19 13:11:44, David Hildenbrand wrote:
> > Will come in handy when wanting to handle errors after
> > arch_add_memory().
> 
> I do not understand this. Why do you add a code for something that is
> not possible on this HW (based on the comment - is it still valid btw?)

Same as the previous patch (drop it).

> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Cc: David Hildenbrand <david@redhat.com>
> > Cc: Vasily Gorbik <gor@linux.ibm.com>
> > Cc: Oscar Salvador <osalvador@suse.com>
> > Signed-off-by: David Hildenbrand <david@redhat.com>
> > ---
> >  arch/s390/mm/init.c | 13 +++++++------
> >  1 file changed, 7 insertions(+), 6 deletions(-)
> > 
> > diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> > index d552e330fbcc..14955e0a9fcf 100644
> > --- a/arch/s390/mm/init.c
> > +++ b/arch/s390/mm/init.c
> > @@ -243,12 +243,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
> >  void arch_remove_memory(int nid, u64 start, u64 size,
> >  			struct vmem_altmap *altmap)
> >  {
> > -	/*
> > -	 * There is no hardware or firmware interface which could trigger a
> > -	 * hot memory remove on s390. So there is nothing that needs to be
> > -	 * implemented.
> > -	 */
> > -	BUG();
> > +	unsigned long start_pfn = start >> PAGE_SHIFT;
> > +	unsigned long nr_pages = size >> PAGE_SHIFT;
> > +	struct zone *zone;
> > +
> > +	zone = page_zone(pfn_to_page(start_pfn));
> > +	__remove_pages(zone, start_pfn, nr_pages, altmap);
> > +	vmem_remove_mapping(start, size);
> >  }
> >  #endif
> >  #endif /* CONFIG_MEMORY_HOTPLUG */
> > -- 
> > 2.20.1
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

