Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32F01C004C9
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 23:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2A41215EA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 23:54:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="XVAnUdT6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2A41215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C0F36B0003; Mon, 29 Apr 2019 19:54:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 770086B0005; Mon, 29 Apr 2019 19:54:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65E516B0007; Mon, 29 Apr 2019 19:54:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E06A6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 19:54:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s26so8156727pfm.18
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 16:54:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=I94i2XopXQ46FN2+ICJ8tUvwfkgSChVjAq2FWTJ7nOE=;
        b=rcNG4dHnAzH4lX4BQ9ynIzDnA88L8jLKA8W6pT8QgOIAy5Ko703vMn/am+u0GvERyW
         x+lval4HsdRQSysmSIZT96Wy7MHfA7rgj9izb0zF8SXlJfd8Y4VU3gA5bbwqCktNVCC3
         t3brPZrlxripb665PZ/RcIBD8cTEmvZaQI5oVnOWZVKpNnPQfduIBI4rupwIU0XRaIyS
         7u/t8lBtRnuJVf2LKSGU9CjTxgSrh0yTQHp52hGDiyWCCZv6co56ZVuJ2fBFSfEAUjWx
         pQd8koKp6TlIZawBPNi25z+X0CdPB62e44IyMcIKa7BTIYxWdkL6IidlYC+oYh8KEy2Z
         HZKg==
X-Gm-Message-State: APjAAAV96qgSJURmL/EK+Dz/5qXzrCBe84pDfvp0+feVO6fI/EGsZIp6
	IvwomFGXwbSf41bC3ZMXhaWPmcTNFzZgQHsXfSZl22gVK5doKcTlJqr22Fz8/XzaYHsJ+c3H3f4
	/tr9oUlcXmcu2h3Lw95U+MDTOduowtz5zLtXCys0GRydM4vLkYClcgSxE3pjUEVx8yA==
X-Received: by 2002:a17:902:758b:: with SMTP id j11mr28915429pll.87.1556582083715;
        Mon, 29 Apr 2019 16:54:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1c4fWbsbhDDN/Wfgylw1mtPZ4K6oSYxD+qTCVdYBTXEYiNgbNjfZmMxQLW6AnvwpteUS6
X-Received: by 2002:a17:902:758b:: with SMTP id j11mr28915341pll.87.1556582082790;
        Mon, 29 Apr 2019 16:54:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556582082; cv=none;
        d=google.com; s=arc-20160816;
        b=qzdq7ApQNep5BoDEsizYB4LaN90m68IYHfDLpsWt8Iz4/+FrGMfbXjHJES1vSbKUPT
         XsrIh5eG1o3++8SCjVykqOE7F/o5GgeNpn7FDCFQzDzYbbToIfs36Ib6DdDyITklV6h5
         MbksIrUE24HAa1nCjMpmuEsq+uPpHSGRL0Qu/WVEjPSIwev68+SKgXSlyFBe/0+majWz
         iGtg2exi7AlcW7annqTG2DONrrkfeRrgs1RCsjvk8gfjr1SAvUhnyGuklYZTb0eovlWn
         APZjFDDsTyH9dY3eaCHxGV4yGzaBaogQpdReOn6bHoMgVIrGqTWQluy4p64d2g6jwi9E
         FRMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=I94i2XopXQ46FN2+ICJ8tUvwfkgSChVjAq2FWTJ7nOE=;
        b=oJLTgmTS5XOCFwodNgp4rjcWkRaxIYMk5iYg+1MhpIBahg3YbJ8ybhSa1X5oG1oHuj
         rkmvqP1lw6luJeccmVjYmHY55e7fdsBbq0O08rLFl63F2iiYsCZlKkiQzTHYJvrcuB6f
         j2uUOkxS4Lpgw+4fukwmdE7qnfIOAUoRDXUkeg3Hg4KIzRKw3g51vpO4PqVTDGqpJpVh
         CHjHBMMV4LWLkE0KzfS/itRoeC45d2YB1N8TpQFFuIBjwyohmJSLcsOUv9jtW6Hz0wW+
         s+JIqHwn9w63ff9fdh+0RNFnp9Q8Uvt4XDPxcetQ6qkHxU+AXT9e5MflyOpaV7EPzp7p
         Q44A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=XVAnUdT6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id c16si13054539pgm.430.2019.04.29.16.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Apr 2019 16:54:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=XVAnUdT6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=I94i2XopXQ46FN2+ICJ8tUvwfkgSChVjAq2FWTJ7nOE=; b=XVAnUdT6fvHvWcWmZqhFeJISJ
	MXT4h3EJtPImMuTLE+kaEEPyTB/Hi3wGtAUsFL7uO3ixt1bUt6dZ9FV9OCVXkxA/FxcoN926tiz5p
	fhKiGBkojfqxYwvMQ+oYiTZtqEBtfO3QdZ41dqYfI2Ys9mt/FjQ+MtHD8yctwnEb5ex2wuzBOfrhx
	RaDXgl1DKXZw+i1wTb/puevOm3kKihxGgoW7HRt8oTPpV7H4y8+a9I4FQdD8eLb7BhH+e1p9zazs2
	DrSi5VNb+7bCqMzjG2VuPcLBF9D/iggrvSpLrwpY1CgzKDfLstdbGmPxUxJtvDNx3zqoD6Rb5lB2g
	hNf150imw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLG6b-0004Wt-6L; Mon, 29 Apr 2019 23:54:41 +0000
Date: Mon, 29 Apr 2019 16:54:41 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Scheduling conflicts
Message-ID: <20190429235440.GA13796@bombadil.infradead.org>
References: <20190425200012.GA6391@redhat.com>
 <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 02:03:34PM -0600, Jens Axboe wrote:
> On 4/25/19 2:00 PM, Jerome Glisse wrote:
> > Did i miss preliminary agenda somewhere ? In previous year i think
> > there use to be one by now :)
> 
> You should have received an email from LF this morning with a subject
> of:
> 
> LSFMM 2019: 8 Things to Know Before You Arrive!
> 
> which also includes a link to the schedule. Here it is:
> 
> https://docs.google.com/spreadsheets/d/1Z1pDL-XeUT1ZwMWrBL8T8q3vtSqZpLPgF3Bzu_jejfk

The schedule continues to evolve ... I would very much like to have
Christoph Hellwig in the room for the Eliminating Tail Pages discussion,
but he's now scheduled to speak in a session at the same time (16:00
Tuesday).  I assume there'll be time for agenda-bashing at 9am tomorrow?

