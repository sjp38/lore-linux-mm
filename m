Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 176C1C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:18:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C709B205ED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:18:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mrQLtjdF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C709B205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 822446B0005; Wed, 24 Apr 2019 15:18:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F9EA6B0006; Wed, 24 Apr 2019 15:18:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 711946B0007; Wed, 24 Apr 2019 15:18:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A91B6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:18:34 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p11so13017239plr.3
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:18:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=P+OfGyLgTHL2L1RnCJWgVoo8gkrh4zgwRL/+i5lcAZE=;
        b=EWc2m2/5CfUmqOXXVZmlVjJM3MXDGcgpQdj8ZSf/FruJbncbdxPNPl9QAMN8B3pH17
         F1JK8+NdAVDxPzdLMSm5da3rGGcHw+kGre3JNAxiv7Lib1F0slEamgOU7FJ71DXUWNGi
         tzXas4wmpkkkNtiIu2Gys6BMIO5PydrX5qtbfWF06SMzaPDK62g6YKuDoWsswoTt0Nu+
         lztPMi4Ex4dCMU7xA9whq02HboBSBCxRFbQKBGjAHt0mgPIqUYXdTZLlgVuGpK83wy4F
         sec6zzX+RxWOKi6qap08OTIOPP+9r4lL94tpp6HBjgdvvxr0YW98vzO3UpFZ8HVhQalm
         GSuw==
X-Gm-Message-State: APjAAAXwyZWeW3RA2Qz9VSi7beWBHLhCFm0PO2g355YiYwfll95XAZ60
	4BkIDR79yOO5mSc8h4boZ94NeVEVsVnvu1YZsOkaMtTauJOmestH34aE3fyL8jUlN5d1bR9fREB
	YOc716rtseJbzSlTfH4klmulh18LXXpLRTGKZBTPWF6BRoAuV4CJN6PcRWgZTehcV3w==
X-Received: by 2002:a62:12c9:: with SMTP id 70mr34577699pfs.156.1556133513811;
        Wed, 24 Apr 2019 12:18:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0gsAkuSiKNdeGjKatJKL0lZKPt7TUboCNEpOLl558ecNox22B5Wkoxr0GPWCIe7fKczNk
X-Received: by 2002:a62:12c9:: with SMTP id 70mr34577628pfs.156.1556133513064;
        Wed, 24 Apr 2019 12:18:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556133513; cv=none;
        d=google.com; s=arc-20160816;
        b=fwbtcBf+MyZVxnE96JXqjlG/RIXv748/M46zhytnk+0iSGbSL46I7ADmEhgSEKweLp
         0R7kXVvP78Qt0Yb8sXkXBWCVKtRA7Umy9PZsuZPMsTLq5UTFqFhuJXydPblB375H+QSj
         cZ66yEKjqCxQbfhonuECL9XYX8eNttLmSAiqL+yZLUZXZ1DBmxbJH8JjEqUsUWyH+u27
         2w9JOJXeXG99Hl4igk9LH49aY3V/013+lCIt08k9DyAZNflkZQGfKll4cCBoKerIupvt
         ziFsXsccKLDq7H5/aYXWIn7xECBLQ5dN19WjNGsKQbqSqBRiMTF/8G8jGoQ4RBF6tyto
         h2zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=P+OfGyLgTHL2L1RnCJWgVoo8gkrh4zgwRL/+i5lcAZE=;
        b=LJINg3ebJeiU22HMQxXY9AcSKtPoipx2S6yAxzKUVG9mNJXbHvJ5y+0+ZlbTC7Z2MB
         xg3riWoq/K9B0jtppWaztRXjNXAPQ3tLIKNOvSJkZy3bFdDOlKCMt/GSTN8HSNmL6yX+
         y/O3Ex05Evj2C2WC1d+0mgrkOcqrzU2JjzCk93wDa+wvUKDFwpLak6l/Hkr8PJCJLUks
         T69YPsB1W9nF6oafJ4QgRGh+L1ZbQD/qWnJtYSkrvP1ebQIU5DuyiPK3HnfDACCMPVS8
         cDjiscAeUE4NVqmc6aBDRtYL4lvXKnvqBN9F9AlQVRKDRdVcAUQAZLMCJ9cK0aBldYuE
         ktAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mrQLtjdF;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33si20629460plt.161.2019.04.24.12.18.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 12:18:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mrQLtjdF;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=P+OfGyLgTHL2L1RnCJWgVoo8gkrh4zgwRL/+i5lcAZE=; b=mrQLtjdFQvWaJbGQaT55TTvth
	NOVOud4leyMRqSMYunVTLEw/Td40gtqCM0TCBkuC5uvAOduxbypNOG3qqbfATcl8n+W7IaH7+XtLK
	+hJ+ZISDncsKBPkEJEDg9XsfxcKM/UXlk3LJ9/KuuDP7RCJrEQPhbmzI7lbkrrX9LaP7T2PPjd8Zz
	MYmOOsXis2V1APWd8wnaYW6rXwKX4qhEuHWxji2rV3R4ZNir78GSm8YMAMvI/k+n7Wg0A9j5OHQ26
	DBgps9O0g04jCIvjxLm6aD4lqh08SDujttlnL9iMztT3xcStfimyJP3KNy5MyH5aC2o/YCxgMicUj
	IrldlGUNg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJNPa-0003Yt-Qz; Wed, 24 Apr 2019 19:18:30 +0000
Date: Wed, 24 Apr 2019 12:18:30 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: linux-mips@vger.kernel.org, linux-mm@kvack.org
Subject: Re: MIPS/CI20: BUG: Bad page state
Message-ID: <20190424191830.GF19031@bombadil.infradead.org>
References: <20190424182012.GA21072@darkstar.musicnaut.iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424182012.GA21072@darkstar.musicnaut.iki.fi>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 09:20:12PM +0300, Aaro Koskinen wrote:
> [33617.740799] BUG: Bad page state in process cc1plus  pfn:3df51
> [33617.746545] page:81023764 count:0 mapcount:-64768 mapping:00000000 index:0x1
> [33617.753577] flags: 0x40000000()
> [33617.756716] raw: 40000000 00000100 00000200 00000000 00000001 00000000 ffff02ff 00000000
> [33617.742940] raw: 00000000
> [33617.745548] page dumped because: nonzero mapcount

When a page is freed, it's not supposed to be mapped to userspace
any more, so mapcount should be 0.  In your case, it's either -64768,
which is a massive underflow, or it's 0xffff02ff which is a nonsensical
combination of flags.  Or a user is putting their own information into
that field (as, eg, slab does).  Or it's become corrupted for some reason
unknown to me.

> [33617.760052] Call Trace:
> [33617.740656] [<80019c7c>] show_stack+0x8c/0x130
> [33617.745092] [<8009cf78>] bad_page+0x138/0x140
> [33617.749437] [<8009d764>] free_pcppages_bulk+0x15c/0x4dc
> [33617.754652] [<8009eca8>] free_unref_page_list+0x130/0x168
> [33617.760041] [<800a7b90>] release_pages+0x98/0x404
> [33617.742894] [<800cea78>] tlb_flush_mmu_free+0x54/0x60
> [33617.747934] [<800c5874>] unmap_page_range+0x574/0x864
> [33617.752972] [<800c5cf8>] unmap_vmas+0x70/0x78
> [33617.757319] [<800cc690>] exit_mmap+0x110/0x1b8

Given this stack trace, the page was mapped into userspace, so something's
gone terribly wrong.  My money is on corruption; I haven't seen anyone
report anything like this before.

