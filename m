Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30DF6C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 13:48:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF95F21019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 13:48:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="c8TzrwqU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF95F21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 649A68E00BD; Thu, 11 Jul 2019 09:48:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F56D8E0032; Thu, 11 Jul 2019 09:48:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E37A8E00BD; Thu, 11 Jul 2019 09:48:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAEE8E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 09:48:01 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id r27so6850779iob.14
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 06:48:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=B8VPRtxAaRavzdJXhPNGPP7MJxy27D2BMEVGhwTkA7Q=;
        b=jkbDoWFIXL6xSY/qv177CyknmixG93sER/E3IyRZZoiSWnJ/e5edqkbywLLtSqGzFP
         xx051+0aH1tAKZ6xMG45dt6KcorSqeiYQq2AZ31RwkY13qa7Z5QjqUNYiyMogxhnn4sI
         vi9VBxcunx2WkxGDzTzBBmWk/10wAmEsKp3De2X5I73QMksMThys+Pms/7w9iOiTJIqM
         qH+F/yeeUyveCdCX9WX7iPfa6AqrFSGyS/uNxWx4s7CWlwXPqajKv3C+oxDH8Hk5mPgM
         ssWWpqjzvXq8Dq2YUPW9O2rOeybG6eCEfxSg5exJI2RsoqkkxxyMAM87XvZJtj7RpkSf
         XwOQ==
X-Gm-Message-State: APjAAAXjwKN4PbWcKWVma+LaYqXEbBo9yCMRspCVJ5GnatxzK9MCtCOR
	G+3RoF6jdAqW9qbiI3ezej5J3bWdiOW8o5aEutSu8qRlEpQSyYbrpVJDleBCD5PCBEoWKgEuO3z
	4O7kamHawPNrUPSsHPghTGiJDr3JThMGQFA2nw9OHNxg927DXI23iXL59MT2nmMEqgQ==
X-Received: by 2002:a5e:c803:: with SMTP id y3mr4373656iol.308.1562852880982;
        Thu, 11 Jul 2019 06:48:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwgNA/1MdKbDA9dhTy/9oNR+XnOB6LVz4ZCcLnJI9a2Kt8qfcHc+OvYbr8Se2pBuotuFXp
X-Received: by 2002:a5e:c803:: with SMTP id y3mr4373603iol.308.1562852880311;
        Thu, 11 Jul 2019 06:48:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562852880; cv=none;
        d=google.com; s=arc-20160816;
        b=AT778p4fj9ND+1QNnPSKT82cqhJGhbeLWKK1rkaxjs4Y4SyVPxFr72Rq74vNPDriFa
         XAVca6ZJpzvzR+2DuUCVxdDymc21U/f0auhy/eph9x0efV/Z8iXm/bkMBCLxzqlmnNbx
         EO7Td9s1Qv+hMbcTe6UoxxgSI+qMDx37KwWu3ZYSnvq+4xJerBGy8ovS34v2SPIGEjEa
         Rv8+620PHO31dwc19Dvs3n/O+OVR+j8l60U9xsS+RKmo3Tv+bsuGHNfuu0rPCU+g6kWI
         JlaaCfMHTRNWkdmgx3tSa4CwI/ZMVhRFbazv1yb1i34OpSTNe8a1gOO/ADzLJA0VLDgU
         wmlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=B8VPRtxAaRavzdJXhPNGPP7MJxy27D2BMEVGhwTkA7Q=;
        b=f2xD+r9fA/z9gGWJWk5HkI4PYhQgrvt+wMyXO3ip2y/X4mQgSp8D5aDEpidKf0Tlwj
         YBNM8bm20h3Vvee+DDRsy76jToZboDM4eTlsu0Xzp86c9nsI75NXMleJx87xamj8zCeb
         EGVi313l+BpXJWbCE5BOzm9m0JEDVKQPcAfEBkdzLHTCYprHYIwB9BFNY+6sfaaqkmoo
         luTOxln4f/hfYqwlppSpSEtAFMv3vOOnL3pV1btS0Ukff0oGbNz/yBjcSumROsasaBBP
         5EjjdDaIEXhJTGYOH3+KmUZG/S3vy4/w4FxM86Kl69e3ISW+R+MmuV0xjPv7pH8IKe1W
         g3kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=c8TzrwqU;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z31si9257905jah.90.2019.07.11.06.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 06:48:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=c8TzrwqU;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=B8VPRtxAaRavzdJXhPNGPP7MJxy27D2BMEVGhwTkA7Q=; b=c8TzrwqUlt9qDq7vFPYtRVBn3H
	DJX6fm8LSxp8r//78fWYTug6IOIH6geBZYWoJ4TYpizO7Auf6N1pg/+wvb4w6DAM26YzLByT0MSgp
	evUPeJbSWAr5lJfEkWgcdX5J6Bhvf07xqbmj4/m9aTNZPLqXkp1S/1U+lAW3vBOvW0lDdC0zCdz/v
	Lye8AT85BM2UXm31VdG3JBET4bqv6lc4kHnFgc3kqhq/OYyHtZiHN8dYc9gaJEqZToVuPqSSgsdnT
	o6zqNnzdwABf4sX+eyYJckTDkvRP0lDq06+zAaJg0KxKy/92maynHWSddc2vAVyq71sQHEn1aeW9y
	ZYlilr1Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlZQS-0003oU-9w; Thu, 11 Jul 2019 13:47:56 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id B749D20B54EA8; Thu, 11 Jul 2019 15:47:54 +0200 (CEST)
Date: Thu, 11 Jul 2019 15:47:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>, riel@surriel.com
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
Message-ID: <20190711134754.GD3402@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 11:28:10AM +0800, 王贇 wrote:

> @@ -3562,10 +3563,53 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
>  		seq_putc(m, '\n');
>  	}
> 
> +#ifdef CONFIG_NUMA_BALANCING
> +	seq_puts(m, "locality");
> +	for (nr = 0; nr < NR_NL_INTERVAL; nr++) {
> +		int cpu;
> +		u64 sum = 0;
> +
> +		for_each_possible_cpu(cpu)
> +			sum += per_cpu(memcg->stat_numa->locality[nr], cpu);
> +
> +		seq_printf(m, " %u", jiffies_to_msecs(sum));
> +	}
> +	seq_putc(m, '\n');
> +#endif
> +
>  	return 0;
>  }
>  #endif /* CONFIG_NUMA */
> 
> +#ifdef CONFIG_NUMA_BALANCING
> +
> +void memcg_stat_numa_update(struct task_struct *p)
> +{
> +	struct mem_cgroup *memcg;
> +	unsigned long remote = p->numa_faults_locality[3];
> +	unsigned long local = p->numa_faults_locality[4];
> +	unsigned long idx = -1;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	if (remote || local) {
> +		idx = ((local * 10) / (remote + local)) - 2;
> +		/* 0~29% in one slot for cache align */
> +		if (idx < PERCENT_0_29)
> +			idx = PERCENT_0_29;
> +		else if (idx >= NR_NL_INTERVAL)
> +			idx = NR_NL_INTERVAL - 1;
> +	}
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(p);
> +	if (idx != -1)
> +		this_cpu_inc(memcg->stat_numa->locality[idx]);

I thought cgroups were supposed to be hierarchical. That is, if we have:

          R
	 / \
	 A
	/\
	  B
	  \
	   t1

Then our task t1 should be accounted to B (as you do), but also to A and
R.

> +	rcu_read_unlock();
> +}
> +#endif

