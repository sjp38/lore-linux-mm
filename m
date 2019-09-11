Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C95A5C49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 19:57:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C47C206A5
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 19:57:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YuuZ1SR9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C47C206A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F3986B0275; Wed, 11 Sep 2019 15:57:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A4036B0276; Wed, 11 Sep 2019 15:57:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BA756B0277; Wed, 11 Sep 2019 15:57:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0202.hostedemail.com [216.40.44.202])
	by kanga.kvack.org (Postfix) with ESMTP id D8D1E6B0275
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:57:55 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7312C1F23E
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 19:57:55 +0000 (UTC)
X-FDA: 75923700510.14.back96_7f55ed1a2bf62
X-HE-Tag: back96_7f55ed1a2bf62
X-Filterd-Recvd-Size: 2842
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 19:57:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=9jE3mtkHHko+7r8PMAvmKkCu21SGOTAKiQ2sFX5q1e8=; b=YuuZ1SR9/A3UTMvsgjSd5CDmd
	Bht4qf7T7gzPP6ceP3qR0rUCabFLX3Ofmr1X48wwNvc7OioQfaRQY15yoV7wM8Md+Lttifi18jP4N
	2zoqeakteIneE6RomJ18Svhc3HMcSNpA9808NWbTJed7wGaWgOW4NIpEuLgedepcI9h5LOFReSKD8
	3JDMy6OdPsmFtRfTBIR+HfAyJMgJ+Jnj8cBaaEyynEzWbevqJ6Z1x/AzF0dzQP9Uw1L3uZzKSJVM/
	TwSAA+eEApViP9KU8PZo0eQ0O/NEK3imDNt2fcN+0/CxKA18HaTn+i8NqOpUxE/Zb8FY+MwvYdPuH
	GiGSo8+Vg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1i88kL-0007F3-I8; Wed, 11 Sep 2019 19:57:45 +0000
Date: Wed, 11 Sep 2019 12:57:45 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
	Will Deacon <will.deacon@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
Message-ID: <20190911195745.GI29434@bombadil.infradead.org>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190911150537.19527-6-longman@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 04:05:37PM +0100, Waiman Long wrote:
> To remove the unacceptable delays, we have to limit the amount of wait
> time on the mmap_sem. So the new down_write_timedlock() function is
> used to acquire the write lock on the mmap_sem with a timeout value of
> 10ms which should not cause a perceivable delay. If timeout happens,
> the task will abandon its effort to share the PMD and allocate its own
> copy instead.

If you do a v2, this is *NOT* the mmap_sem.  It's the i_mmap_rwsem
which protects a very different data structure from the mmap_sem.

> +static inline bool i_mmap_timedlock_write(struct address_space *mapping,
> +					 ktime_t timeout)
> +{
> +	return down_write_timedlock(&mapping->i_mmap_rwsem, timeout);
> +}

