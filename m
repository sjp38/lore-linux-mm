Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98330C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:55:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C76E2239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:55:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Pjwch1Qk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C76E2239E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE1BE6B0010; Tue, 23 Jul 2019 13:55:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E92986B0266; Tue, 23 Jul 2019 13:55:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA9C18E0002; Tue, 23 Jul 2019 13:55:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A336B6B0010
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:55:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z14so19414470pgr.22
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:55:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bl0M5NSk0nmCZFb/3HXW8+xYe1ZmbQXUvDwYm6YUgfk=;
        b=apd1ximyulbKJqp6X8TUY3XyfoqCbJqD8mYYhA9sUkllwe5ZEAQXxFVCHQ1wpUXhl8
         kXZsO3bLhkPqSDAQ/gS+SZ0a8S7ds5r5JbKeYwLP8jug4FajLkbJxM0uYgzInRUYD0VR
         xRKeULj3lhpxXdQGElKkRNf88Ha/fCLXBjRW8KgEQtsiuTlVYcxkakLnoYTpMq4zJQ8b
         WI1/bsGqk4S8+qJHd0bi6/FuDoFyDE6QZ3XRNj3gpOMG9ZO3pEtM5X5hXIhxUL+RvirU
         6FqE6xaBg4SIztL6B2ruwbKlaRLSATrKKrF4vj4gU3lNzE6MVmA+1NEPvU1EUMgt+P63
         0Hmg==
X-Gm-Message-State: APjAAAWuZjfqyL+5gDE0z4vzzZDZ4WFGwab4YRsTR2RvS6d8XqRbzT2r
	bRuLFRB48GVRshZjP4PwDINOuhzYSRbCvLj8LC5RI0MT+xML7ra9pVMngTnThoH88DzwGt9aHfO
	y7pLfKE46xY2L/cnS3F8v3S9r1dgEU9bg/OSpCch3IooCX0/p+zlmoDwlW37V2CSn2g==
X-Received: by 2002:a17:902:106:: with SMTP id 6mr83339059plb.64.1563904545355;
        Tue, 23 Jul 2019 10:55:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKeX7gF3sn/NOjoQ+eMONTS9YxrekdUsS0+D5DNiX4lgcc371t628YUk33L+T+l9EcxUx7
X-Received: by 2002:a17:902:106:: with SMTP id 6mr83339035plb.64.1563904544770;
        Tue, 23 Jul 2019 10:55:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904544; cv=none;
        d=google.com; s=arc-20160816;
        b=ywiek5ifEvIiw7EOXjNZt5ZYU8dATBE4JoZVEA20oC0G9vEK2Z9rgZvXj93YiskAKv
         IV+HV2fIxel9JwfvQ16qURMJF7pM8yH9Zq5kVlllIcFWBp7600eG8qiNsrhMp1YYf319
         ASuWKtJ2ZNXCmZIIPj+gsz+xhyXEluQX/embieFBsccfVHG2poJzm3RZjSNo/rYkcg6r
         ChhYpASiFf9Hbgwrb/dI/JsAbxyscVw5w2Te7eC/kaKmYabJzAe+5uKEBzZYXrHTif/Q
         UMqwLYSVpvnhT5TUMh8qOc3cCJ6CEdJ8otDnbiG0euk0Ct6TJrNsw9aR0wyhgyLM3iXl
         IRqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bl0M5NSk0nmCZFb/3HXW8+xYe1ZmbQXUvDwYm6YUgfk=;
        b=jQQ5YtoHnPjYAXGKRSSuHKWZzPe9NvmfuvaKbulU4CaSDsgNsFrE3dft8DeJD2ZvtM
         vydayZQhwTxBULaxIUpIpbEJCt+lxP+4Vy8EVe8vgLJLk6rGsV64SeRksgfbih/g5XOU
         ra42uVvB+VBa/34quQQH0OQUlLiRLDsRYGwfn/hTn8Z9nIE3a4yUlkrR0c8ifscYVHRp
         422YbNorIuIZOOfcYUP/PfEnSzy1Z89g2XYFgBThNEDwVYtSbJUp4f+0fxLExMttJ+xY
         vfGm0u+XBNIYsEeS9qJ5JnZHalGmnSuzNGC+qc8FaZwD3bbUqzyXv+uVDNOzNeYyR1fZ
         /rFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Pjwch1Qk;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s23si11302160plq.81.2019.07.23.10.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 10:55:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Pjwch1Qk;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bl0M5NSk0nmCZFb/3HXW8+xYe1ZmbQXUvDwYm6YUgfk=; b=Pjwch1QkqUDzGn63jiv3m7mO8
	eZhAGD1vxQSBR0t+nWjWFBkokMonpycyRfXPkWsfe4FEf9lJAWvfoGb/0yPbVYiH9z3Hhh6xXEDg5
	zr4VUm0R/xlzryCVOr6PmUmENT6zpTuuKdMQwg5/UK7F1kaOI3VpvG89/rWSIF6RwvvpvQ3MpXHWN
	yQ8muS9Odn+YEFoGSCibtUSbyROrieftl5Bnz5BTaI8Trw3xuvq+Cft1SdWFJ7V6Gtt+aMU6hGGal
	5DaKTYERMJC5hF8XIY0NnhcBt26AgMGDV9jAY6zOWTBbVmIBad4tH4OAALgaUWdrWmFpnTCeI5V+N
	5tdpZCS5A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hpz0p-0004AD-Lp; Tue, 23 Jul 2019 17:55:43 +0000
Date: Tue, 23 Jul 2019 10:55:43 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
	lhenriques@suse.com, cmaiolino@redhat.com,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm: check for sleepable context in kvfree
Message-ID: <20190723175543.GL363@bombadil.infradead.org>
References: <20190723131212.445-1-jlayton@kernel.org>
 <3622a5fe9f13ddfd15b262dbeda700a26c395c2a.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3622a5fe9f13ddfd15b262dbeda700a26c395c2a.camel@kernel.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 01:52:36PM -0400, Jeff Layton wrote:
> On Tue, 2019-07-23 at 09:12 -0400, Jeff Layton wrote:
> > A lot of callers of kvfree only go down the vfree path under very rare
> > circumstances, and so may never end up hitting the might_sleep_if in it.
> > Ensure that when kvfree is called, that it is operating in a context
> > where it is allowed to sleep.
> > 
> > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > Cc: Luis Henriques <lhenriques@suse.com>
> > Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > ---
> >  mm/util.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> 
> FWIW, I started looking at this after Luis sent me some ceph patches
> that fixed a few of these problems. I have not done extensive testing
> with this patch, so maybe consider this an RFC for now.
> 
> HCH points out that xfs uses kvfree as a generic "free this no matter
> what it is" sort of wrapper and expects the callers to work out whether
> they might be freeing a vmalloc'ed address. If that sort of usage turns
> out to be prevalent, then we may need another approach to clean this up.

I think it's a bit of a landmine, to be honest.  How about we have kvfree()
call vfree_atomic() instead?

