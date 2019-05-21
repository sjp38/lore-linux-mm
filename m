Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3820DC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:33:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEF8E2173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:33:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="rnqXgMMh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEF8E2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B6406B0007; Tue, 21 May 2019 11:33:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 868866B000A; Tue, 21 May 2019 11:33:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72E3E6B000C; Tue, 21 May 2019 11:33:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9186B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:33:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d9so12591301pfo.13
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:33:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8JdJVvAGyNC8PSXsjfUN8u+zmKF1hLoAAqIvD329Mjs=;
        b=K7tXHduALMNEL0VWLwuFEileAOXkWSF6CNqDDnRFMrrj4ds4pXgwSEkgrvDhpuJmKE
         yekt3/4Z4DRxEu7+J/7iS0YYK0MzBizZXQnpTo4V18GBMONw+uzWac+YWtgxThfCmDoO
         d+tIRUULmn9LLcq7ofL/zDTusC08Ze/LAzuVm9p9hRc9ICE0afm8N/T0jNKA1bM3dyeb
         KlutZNLE12aVvCUaY9VRf3AUdNs7Uf3wtOMh76jI76+ydOzoH6ym+stVLXAqW5wzWkHK
         ils6RUlmcOmsawQUCQfwIZj+d7X/abYpSd713l0aTIYhbEnsUdycWZOkTvoixAtZZ+tg
         8IvA==
X-Gm-Message-State: APjAAAV78NIW6IqeYUWK1Ut9oRM0lqUNAH1nnjHLkLU7yMZUNG+imB2N
	iCQUf1CoZPfA8iYnmhR9T6f5ax+3OOErPcRU2vsW6j13rAN8bGd0r0YPg/vnlF+pzoUeCO1mcws
	uf0T31Lx2agYyOZG286kTzhgXjGV0Vi5xFHdwBz7IVD4GNUMLOPa9q1t/dnNQJglrzA==
X-Received: by 2002:a62:4c5:: with SMTP id 188mr28010844pfe.19.1558452795816;
        Tue, 21 May 2019 08:33:15 -0700 (PDT)
X-Received: by 2002:a62:4c5:: with SMTP id 188mr28010744pfe.19.1558452795133;
        Tue, 21 May 2019 08:33:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558452795; cv=none;
        d=google.com; s=arc-20160816;
        b=ZS/rfdkgo6LETyXIncCdZEoRN9k1+YZs6cESxWNftDdfCYxfCymFDeaft6EEJNhy5L
         OcZoEaf+nD9NDP5IPJX50ntlu9KdYd3Zo5Sis3/+T68NiqVAs+Gd7i7jymF5pmkcHQ5+
         PSiqkfOY67T93vtRzwxB5Gbyc8cobmQxl7T0/BWT32PVQlpB2//RSiEDUMYG+qy8aY9y
         q9csGT1OVXgU7OxVJlhOfacODI2VXOSdRZr6oYo9jxE49MCtcTQ4jWuPqLN12gjMAKwj
         cSIwZuEMVGlZsBRZBVSOoj9YVfUMrs28LZlO3V+WdOIACBOqzcNJhrl5PZKDStw6WWZH
         IK7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8JdJVvAGyNC8PSXsjfUN8u+zmKF1hLoAAqIvD329Mjs=;
        b=jrWbqGMDsJyf/lyrVlOmPsi6R48uoZpmxlsqNYYP9hyxlzeAzEeicfoni01/AGMLEq
         PNGm5AUmNAOht5tJ4STfDNt+XWjpGmBgI5QIptlg3ExSdUapxgSwKZrDYO3zUKWLKh8w
         ce6vHoiidR6+qT/vtICvNoC10a95GMmK+1/VqyJmgrL0WjmYQ6IR2wJ4HDVP54NoAuKF
         kcEn6uzbr/DSqBhnqX4gUl1Um10K31/AMs2QhI0TXJN8BxT7ZCwvtS3D3xhTnrYKnGU4
         z2R7S7VC5vgG20XBNu2u8h1MXppg7VtGkX0yXgrtNGiWT+wi0Z7mbIa6BL6BXbgrB7FE
         BRHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rnqXgMMh;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1sor21550816pgr.2.2019.05.21.08.33.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 08:33:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rnqXgMMh;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=8JdJVvAGyNC8PSXsjfUN8u+zmKF1hLoAAqIvD329Mjs=;
        b=rnqXgMMhyVETxYuovuKic/EJW9jX8R4OBSqbR8Ns4TCHRCgBy8Sb1k0zAYZ59/J94S
         6Iy/Sm1itRyXny9cYzoIGNEtsR/bRvQoGUIh852eQWPsq5aGavHDwD0W6w2MpswU3Coc
         y5ymxRJjWQkhYAf0ob40InCjHd1X+a9yIvvmOF7KY43VbWNgKA5IAyDiqwOLKg6lUoqL
         77/P03tIKEXYXyvDAoD5fDljlvUS67qiJRndivR1QEvDomd3Shrbs0vyHhTytRp2wLB5
         JUozEO+U/NShOuhdDwTC0JpBQoX+2f8Vk6Ht9mI5S7oyQrykqElGO8iOhesf6Ir1faQS
         V5OQ==
X-Google-Smtp-Source: APXvYqwlng0s4LJPDKCEGz+dJqb/FMYHQKwaVN6ia1yxZapGNrVbL/8WU/wAPFu2zQ4PE5OMy57Bpw==
X-Received: by 2002:a63:d901:: with SMTP id r1mr45310557pgg.271.1558452793234;
        Tue, 21 May 2019 08:33:13 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5a76])
        by smtp.gmail.com with ESMTPSA id 135sm38967196pfb.97.2019.05.21.08.33.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 08:33:12 -0700 (PDT)
Date: Tue, 21 May 2019 11:33:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190521153310.GA3218@cmpxchg.org>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-8-minchan@kernel.org>
 <20190520092801.GA6836@dhcp22.suse.cz>
 <20190521025533.GH10039@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521025533.GH10039@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 11:55:33AM +0900, Minchan Kim wrote:
> On Mon, May 20, 2019 at 11:28:01AM +0200, Michal Hocko wrote:
> > [cc linux-api]
> > 
> > On Mon 20-05-19 12:52:54, Minchan Kim wrote:
> > > System could have much faster swap device like zRAM. In that case, swapping
> > > is extremely cheaper than file-IO on the low-end storage.
> > > In this configuration, userspace could handle different strategy for each
> > > kinds of vma. IOW, they want to reclaim anonymous pages by MADV_COLD
> > > while it keeps file-backed pages in inactive LRU by MADV_COOL because
> > > file IO is more expensive in this case so want to keep them in memory
> > > until memory pressure happens.
> > > 
> > > To support such strategy easier, this patch introduces
> > > MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER options in madvise(2) like
> > > that /proc/<pid>/clear_refs already has supported same filters.
> > > They are filters could be Ored with other existing hints using top two bits
> > > of (int behavior).
> > 
> > madvise operates on top of ranges and it is quite trivial to do the
> > filtering from the userspace so why do we need any additional filtering?
> > 
> > > Once either of them is set, the hint could affect only the interested vma
> > > either anonymous or file-backed.
> > > 
> > > With that, user could call a process_madvise syscall simply with a entire
> > > range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
> > > MADV_FILE_FILTER so there is no need to call the syscall range by range.
> > 
> > OK, so here is the reason you want that. The immediate question is why
> > cannot the monitor do the filtering from the userspace. Slightly more
> > work, all right, but less of an API to expose and that itself is a
> > strong argument against.
> 
> What I should do if we don't have such filter option is to enumerate all of
> vma via /proc/<pid>/maps and then parse every ranges and inode from string,
> which would be painful for 2000+ vmas.

Just out of curiosity, how do you get to 2000+ distinct memory regions
in the address space of a mobile app? I'm assuming these aren't files,
but rather anon objects with poor grouping. Is that from guard pages
between individual heap allocations or something?

