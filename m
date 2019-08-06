Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9598C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:44:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B58920C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:44:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B58920C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18A446B026D; Tue,  6 Aug 2019 04:44:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13AFD6B026E; Tue,  6 Aug 2019 04:44:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 028826B026F; Tue,  6 Aug 2019 04:44:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A45DC6B026D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:44:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n3so53335270edr.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:44:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0inXmfqIH0ti+18qEKndWcJf66x8UBbUJ5ojeLuaRww=;
        b=I6BMDI2Xple4093EkNdICQkzWcur6yIuK8Ql/849t2buU3SozeLMGVOkc+oB8WTdza
         qKmJz6I2afQHLTSRrOh1AN0g97OHzGseOZY8NWLhEYX4Y2KVc7D2F28bjSmaLAqMt2Pw
         T4Kk9ARPHNT490J+MgZVOMtbSBDOikj2lsXtIGb+xBqDGlxL4BSc0ChgwfaSsxLug6f/
         MtlTt9ZG/9tqHePhawDRTN1wa7KciQqK51MJ4RLV36E0HvVy179q8krKDSELHA4nnKdM
         lhTOEMMJZDen5/PUQ7dg4IDJl0qWyw54/eQQyn+72YwDOfqFRpMl9CNxW1QEu02jil7g
         E6kg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVXMIPbwdWl9AaDamdssIw5pDody/CQTC1BI3VOOuslBOmQ5ClO
	WIygJ/zeHAPO1BA6YPK9g+tDYX5N1yItdzEz64IUV+Ii5qKMkFqnmFcpMk82Ifq/n4q1e48/L55
	R29K0bHjcl2K+UTRIsCDLK104nw6i0gSGJR/VBf3T9iUAuZoP7YT3Dc34z7jdc7k=
X-Received: by 2002:a17:906:e0cd:: with SMTP id gl13mr2028838ejb.52.1565081046216;
        Tue, 06 Aug 2019 01:44:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyRnctsWqqWOCLRkVc3E7DV7T2YqN2iUi5xc/AGfIVuVcgxq/B99HgP5Imzvyc2L+eH5wN
X-Received: by 2002:a17:906:e0cd:: with SMTP id gl13mr2028812ejb.52.1565081045498;
        Tue, 06 Aug 2019 01:44:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565081045; cv=none;
        d=google.com; s=arc-20160816;
        b=UHtgfiNszADdtCTcR24OHz4h8VmRSOA+k5LpFqsQzwIQJYWbk1bB0hRrdv0GLhOJt6
         N68Y8NvkdGXQKP007n5JThtWa1DUrDYtwjrCKkS7rqeXzr+8BKUTuQhdCYOHLMl5iPBj
         avsdOa1ISoKv5/ARBIB7le8pPuIpSfFANwqf4mUSvttUWPno+SFr81xCLoYvMzCvRWnL
         XenjehKhdeElvmOCiw87CpHc9N/gEWc8mmKn7wjRJpNrMuEYicUHVI1BLhDNEDZki7Wu
         IsUq+Lg7mLbevFiKtAcRfP+PtaBlvGI9Lq2VQMg5pnzIA+EjfjZYv1nMhagmMcxyLGDC
         zTHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0inXmfqIH0ti+18qEKndWcJf66x8UBbUJ5ojeLuaRww=;
        b=iWXA7hCH6A6jukhoJmKRVX/TtdAAZZz25/3j9sbGIbyLZL2Eq9SRFm2hgoezg8C9wW
         Oe3iZu3ucXdL0luT0ydaw+OHC9D7c5Mg52W1sTa4QEYoHyhhwCGo5OTjpW8xfuwTs+U9
         pfQowOtNe0q8rq7LxOW8+EF1IwNnbdRHJJG86yiAht+vyXdaj2Qg0AQJ6lESyhw58wqN
         1aNOoj1bN+RjSNsNJessl0oIQ54sQmhl3hUOZolw5AlIL7Aa8CVN5Vv8UKE/LYf2ym4P
         wBQrfPZr1/l2mLVUO+E5kJai0wG0eq6fPNUUJxeGkAA1pX+INm0qL75/sOj1K7expbao
         XrSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si27767515ejb.103.2019.08.06.01.44.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:44:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C4ACEAC97;
	Tue,  6 Aug 2019 08:44:04 +0000 (UTC)
Date: Tue, 6 Aug 2019 10:43:57 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	kernel-team@android.com, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org, namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 4/5] page_idle: Drain all LRU pagevec before idle
 tracking
Message-ID: <20190806084357.GK11812@dhcp22.suse.cz>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-4-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805170451.26009-4-joel@joelfernandes.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 13:04:50, Joel Fernandes (Google) wrote:
> During idle tracking, we see that sometimes faulted anon pages are in
> pagevec but are not drained to LRU. Idle tracking considers pages only
> on LRU. Drain all CPU's LRU before starting idle tracking.

Please expand on why does this matter enough to introduce a potentially
expensinve draining which has to schedule a work on each CPU and wait
for them to finish.

> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> ---
>  mm/page_idle.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/page_idle.c b/mm/page_idle.c
> index a5b00d63216c..2972367a599f 100644
> --- a/mm/page_idle.c
> +++ b/mm/page_idle.c
> @@ -180,6 +180,8 @@ static ssize_t page_idle_bitmap_read(struct file *file, struct kobject *kobj,
>  	unsigned long pfn, end_pfn;
>  	int bit, ret;
>  
> +	lru_add_drain_all();
> +
>  	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
>  	if (ret == -ENXIO)
>  		return 0;  /* Reads beyond max_pfn do nothing */
> @@ -211,6 +213,8 @@ static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
>  	unsigned long pfn, end_pfn;
>  	int bit, ret;
>  
> +	lru_add_drain_all();
> +
>  	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
>  	if (ret)
>  		return ret;
> @@ -428,6 +432,8 @@ ssize_t page_idle_proc_generic(struct file *file, char __user *ubuff,
>  	walk.private = &priv;
>  	walk.mm = mm;
>  
> +	lru_add_drain_all();
> +
>  	down_read(&mm->mmap_sem);
>  
>  	/*
> -- 
> 2.22.0.770.g0f2c4a37fd-goog

-- 
Michal Hocko
SUSE Labs

