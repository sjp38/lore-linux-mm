Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CABA2C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 02:16:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7420A2086A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 02:16:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QMvvyOIf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7420A2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C567C6B0003; Mon,  9 Sep 2019 22:16:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C06116B0006; Mon,  9 Sep 2019 22:16:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1C3A6B0007; Mon,  9 Sep 2019 22:16:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFA96B0003
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 22:16:06 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2EEC83A92
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:16:06 +0000 (UTC)
X-FDA: 75917395932.13.crush07_6f6db90081c34
X-HE-Tag: crush07_6f6db90081c34
X-Filterd-Recvd-Size: 4403
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:16:05 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id h144so33850528iof.7
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 19:16:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=s0zjoo9SPbyn3mwdviPBzOKNzAEbtRRkUdJYEIlsrM8=;
        b=QMvvyOIfmJ8b72UgqfZt+USf5rJhMBxGxpXY31hltr/3Z1sUpbI4yCYBzFvxLinfta
         N766ptEWkXUde2Yf4CiM8hW/ksvxTrsaQZk06jljXmIFBS9WiUv6Y8iE7jVzl909rVZh
         EYHuH4oLMBPNgaCalq9NbS5Uxdx1pQi23IOqcqksnRFTcZkYHQHb2TXrnWlwtl4VDXy0
         0jQ50ujM5J1t6jdfqTj4FeJjCFS1fBwc9InXgufcIZ6/dReeNDNy6XZPUfQMU/niYTeR
         6Hrxwf/IRkOlmFPjCP6FwayaYvtZX3Gzm87t13pvPx4tY1mb3wnKa4NWQcvihsrra6J5
         Uyrg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=s0zjoo9SPbyn3mwdviPBzOKNzAEbtRRkUdJYEIlsrM8=;
        b=sKT5iCY4Uop2v5AFnvqNKnmckJbm2gyb85reo5tDik18c6Y93R2XaKNKAQPlO5E5eC
         ofofWMLY34Tq+dproub3G9JjGEClb0su/9qAG4HSSxGXqq0LdSUT1tnk9X5jjfBzX+Hm
         0N5aA/Ehss7y5FntMk/zrE/VB85CpcnBoMYuYG+raQvE0ifPJ2JTI8NDnwkviYSPftuS
         eINzV+vQm3w7hvHF/+rLmXluvtO3rQS78hNbbClRmMlM6WmliMBZ+MAlT3os1wFWKYS0
         kOqi8XCoLSsaZxf0yebmC01NqCATmA2a4yf6EYxFZ4XWPxfd3FeztxBRftes6T+G8xGj
         dlHA==
X-Gm-Message-State: APjAAAVaGCHmD3l2aAQ3OsoQMCrRtOWHyjd74ST4y8MjwH65W+Suxc4J
	OK6QYXuwpvsB7ufSk3BReJbZGA==
X-Google-Smtp-Source: APXvYqy1bTR2h5IQgYy9MmFm5wRWpSShFSHEK6QI4hje5LSBnukLQ2sJCXKpmJnByre9fpYnDPgkzw==
X-Received: by 2002:a02:c546:: with SMTP id g6mr3736142jaj.59.1568081764686;
        Mon, 09 Sep 2019 19:16:04 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:9f3b:444a:4649:ca05])
        by smtp.gmail.com with ESMTPSA id f7sm13892189ioj.66.2019.09.09.19.16.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 19:16:04 -0700 (PDT)
Date: Mon, 9 Sep 2019 20:16:00 -0600
From: Yu Zhao <yuzhao@google.com>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: avoid slub allocation while holding list_lock
Message-ID: <20190910021600.GA28048@google.com>
References: <e5e25aa3-651d-92b4-ac82-c5011c66a7cb@I-love.SAKURA.ne.jp>
 <20190909213938.GA53078@google.com>
 <201909100141.x8A1fVdu048305@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201909100141.x8A1fVdu048305@www262.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 10:41:31AM +0900, Tetsuo Handa wrote:
> Yu Zhao wrote:
> > I think we can safely assume PAGE_SIZE is unsigned long aligned and
> > page->objects is non-zero. But if you don't feel comfortable with these
> > assumptions, I'd be happy to ensure them explicitly.
> 
> I know PAGE_SIZE is unsigned long aligned. If someone by chance happens to
> change from "dynamic allocation" to "on stack", get_order() will no longer
> be called and the bug will show up.
> 
> I don't know whether __get_free_page(GFP_ATOMIC) can temporarily consume more
> than 4096 bytes, but if it can, we might want to avoid "dynamic allocation".

With GFP_ATOMIC and ~~__GFP_HIGHMEM, it shouldn't.

> By the way, if "struct kmem_cache_node" is object which won't have many thousands
> of instances, can't we embed that buffer into "struct kmem_cache_node" because
> max size of that buffer is only 4096 bytes?

It seems to me allocation in error path is better than always keeping
a page around. But the latter may still be acceptable given it's done
only when debug is on and, of course, on a per-node scale.

