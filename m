Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D055DC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:47:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B39F21995
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:47:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B39F21995
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40E5C8E0004; Mon, 17 Jun 2019 03:47:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BD8B8E0001; Mon, 17 Jun 2019 03:47:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 286518E0004; Mon, 17 Jun 2019 03:47:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D01518E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:47:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so15210201eda.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:47:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jt10alrLmmlP3c2hb7Di1CuGuH+MqUyA8r5czp39g6E=;
        b=kHvNENbVyfG245jK8rWj4bcAXyFJ/Mp9+LDnUFG7nXcKhNgpfzNDmZfOj3yhOEsWqz
         xv+2QaBTN1jWn5hlHwNp3ZmTdP/Q0ZaVyIEwRvjq/zYsvYX90uh61JxQdQtmcOl0vda9
         eIgHceAyhw8sbOjcNtdznKvJHu/sSo4qlnlZKJURC5olEButw5FOLEZ/nL5vqwMifTNB
         YXK0QjZBgUiwBz8qxgtIsA3zmK7XwLxsDGTVBp9RMa/V61KMGk81yeCy7jlQLb3clj8G
         xsbiixlBGbpgTO/KtxZNum4JA/RZ1RoID8/19sGxpSjrQ+E2W7l99UTgPj4TiduZU/ri
         EzFA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXxO9KVQUrkroTbNr4gvbgDLW+Y1U/xJXy7bl74MzgcYI4Q3gIQ
	22spNP0tPdGWs1uthvJQJtUbewBsBA/rwrvUqoFwg9+j17syyIqpMm+fjTjh6UzznIAokd/cQVc
	seWROB4g8l5/Wa6X4ME8Kn32hivqSMHbUlx2KW9rljEjRO24twWFBxKcedJoJVl0=
X-Received: by 2002:a17:906:5384:: with SMTP id g4mr23247245ejo.241.1560757638164;
        Mon, 17 Jun 2019 00:47:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd0s3NxKRcWzD7z218h1iaQa3rzEbcc3pPc6WE1Nmtg9g/8HusWSIkiZx0yifqHt2EaUXz
X-Received: by 2002:a17:906:5384:: with SMTP id g4mr23247207ejo.241.1560757637521;
        Mon, 17 Jun 2019 00:47:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560757637; cv=none;
        d=google.com; s=arc-20160816;
        b=SgUIxOecf7iVyVhXxkFO8s2PbiRSlcVw5z0i3QKC+9oprz5rRp2Z4AHZApp+FZ5tdM
         YeTz2r2VzGxIXyRWxj2aWvfgJ2L/9QS74pN87pgBbrNywc7DsRgFHWMhJh4V4+/eUhPT
         cXE4ftjNBmfmykZUVM9peNe17HtPzJkhX6ADdLDADBJoq3a5pDjBPdA0p5GdUyvOe1Mr
         tewvx0Oaibjekpl2dC8LOu8dQDA/SkIVwNiEEsue3YusFAnRkbUwOS3OEDScVc0oEZXl
         sodEmOHmYeicvaZi0GYHjxn5gMFR+MI9bosaiYl+A2DYuLE4CIu2Dpif1CUE/lrl1ax+
         bKfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jt10alrLmmlP3c2hb7Di1CuGuH+MqUyA8r5czp39g6E=;
        b=OU88D2CKo5gyQsl0341yiT8mPn09L60H6RRcbviax4xl3Y8f+dhXR4/Okys0h0Am5j
         XQYq/Pt4+mZiybBDFbw2MXgbBIVPATmAjLCQYtDe9oGsB9kZiY6REpTFynJu/5Yqh/GC
         w8ftcQYPthGzIe5Sr0YtmJ+bCBur3VwT1nAt88O0iMsrIn3ZCCLZn0OzSoEhok3DZhRe
         QcHobHyrLLQAm8arH/ciBCDD5m2ex8FN5onpEXowSSEIWvGEfpaqNuin2REQ4pkoB0NA
         eIjiehhZ3OuLbOmYPiiMVTGw/gHbq4nRQflNPIxBq++tizhKSnhB6+/QE8mVZ4ltFY5k
         0Hyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18si6436527eji.362.2019.06.17.00.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 00:47:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EEB10AFC3;
	Mon, 17 Jun 2019 07:47:16 +0000 (UTC)
Date: Mon, 17 Jun 2019 09:47:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Arun KS <arunks@codeaurora.org>,
	Mukesh Ojha <mojha@codeaurora.org>,
	Logan Gunthorpe <logang@deltatee.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org,
	Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Baoquan He <bhe@redhat.com>, David Hildenbrand <david@redhat.com>,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Juergen Gross <jgross@suse.com>,
	Oscar Salvador <osalvador@suse.com>, Jiri Kosina <jkosina@suse.cz>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/5] mm/hotplug: Avoid RCU stalls when removing large
 amounts of memory
Message-ID: <20190617074715.GE30420@dhcp22.suse.cz>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-5-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617043635.13201-5-alastair@au1.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 17-06-19 14:36:30,  Alastair D'Silva  wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> When removing sufficiently large amounts of memory, we trigger RCU stall
> detection. By periodically calling cond_resched(), we avoid bogus stall
> warnings.
> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> ---
>  mm/memory_hotplug.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e096c987d261..382b3a0c9333 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -578,6 +578,9 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  		__remove_section(zone, __pfn_to_section(pfn), map_offset,
>  				 altmap);
>  		map_offset = 0;
> +
> +		if (!(i & 0x0FFF))
> +			cond_resched();

We already do have cond_resched before __remove_section. Why is an
additional needed?

>  	}
>  
>  	set_zone_contiguous(zone);
> -- 
> 2.21.0
> 

-- 
Michal Hocko
SUSE Labs

