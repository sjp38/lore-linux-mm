Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E54EFC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:22:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 955B120663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:22:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Wqulxs/I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 955B120663
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BF836B0005; Tue, 13 Aug 2019 13:22:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 371526B0006; Tue, 13 Aug 2019 13:22:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25F3B6B0007; Tue, 13 Aug 2019 13:22:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id 058EC6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:22:44 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id BB596180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:22:44 +0000 (UTC)
X-FDA: 75818074248.10.show88_8c5187bb6e206
X-HE-Tag: show88_8c5187bb6e206
X-Filterd-Recvd-Size: 7413
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:22:44 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id v12so4190853pfn.10
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:22:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=k8N1+CVxt+RJj8Si9vYbnsuXtAKEpExU7o2UK2KgdhA=;
        b=Wqulxs/IqBFJerqJEhOtZ6R8tJJJ4oo6uKVQRnyyCSK6crKU0MUkbeWvT+IutOzfK7
         I6KpqsK28kEq5P5h/CNsz/7Iic03Pu3YnV5l6xv2IOPAEguLIuXxPrp5KtIf3T+Wxkbo
         HFMJFR8kaC9/kGtWe+PQe3dnMf92OxiYZWZYY0Mqc21LETZr9UX9BYAoeyWOMef9x1+U
         yl4E6RhhBtjYdDN8tZc6cSaW3viAsk2jgUnmZK1zmbgIGHEQHhED5T4ahqKVm3AI/YEo
         QJkMfqqGEox5DER+eJJl3xVcge13QA9IJZkoaLR7BhJ2CBT3yH/w0l5fIjhd+6eYkhqA
         F76Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=k8N1+CVxt+RJj8Si9vYbnsuXtAKEpExU7o2UK2KgdhA=;
        b=CuDA2lSvcrVlaIiwKXIJDP/rx+JtfnMzXMTuSGHm8guHxzVWnO+aV0gLW43Ds8QtYO
         kaOh4DJBbcd+JVFHx3LI8U7pC5jYJVQmMTDXahbpOVpi7U8ZpItkIrx3K9wmZzuzCcmV
         AcUkrywdL9WG5LjoVNtDycjbbbWtPF+q6x378EZP5pRLCLMkRZGGvWjNdpouWOrFuMH7
         FU1sz6rqWYIP+hmNkpovnjACOJVn+fESq/RH7f8c++rfWJnx+U6w2WGZMN3slqSmEg6o
         vDVJZl3jOocgf9unZZ53gNnokPjiYZZfWKlR2MubAXpHAVBxSLoI98VkU6DK8kzVJ5y4
         seQw==
X-Gm-Message-State: APjAAAXol4LzB8ctuWjoi5G2nQ8eLhF0bnBSZjkhc73aFvMSsvVPW0/d
	VQW2JOXQypwUj5+LzR7UYoOQ5A==
X-Google-Smtp-Source: APXvYqzgpMvNagdXqj1a0ANkB3Dtmxg8Umv6rI8BDjlaJFsyT8mZstls16B/grRHwkMkJtMnZcrlsA==
X-Received: by 2002:a17:90a:bb0c:: with SMTP id u12mr3272874pjr.132.1565716962792;
        Tue, 13 Aug 2019 10:22:42 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id z4sm166362957pfg.166.2019.08.13.10.22.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 13 Aug 2019 10:22:41 -0700 (PDT)
Date: Tue, 13 Aug 2019 10:22:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Vlastimil Babka <vbabka@suse.cz>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, 
    Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [patch] mm, page_alloc: move_freepages should not examine struct
 page of reserved memory
In-Reply-To: <3aadeed1-3f38-267d-8dae-839e10a2f9d2@suse.cz>
Message-ID: <alpine.DEB.2.21.1908131018450.230426@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1908122036560.10779@chino.kir.corp.google.com> <3aadeed1-3f38-267d-8dae-839e10a2f9d2@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019, Vlastimil Babka wrote:

> > After commit 907ec5fca3dc ("mm: zero remaining unavailable struct pages"),
> > struct page of reserved memory is zeroed.  This causes page->flags to be 0
> > and fixes issues related to reading /proc/kpageflags, for example, of
> > reserved memory.
> > 
> > The VM_BUG_ON() in move_freepages_block(), however, assumes that
> > page_zone() is meaningful even for reserved memory.  That assumption is no
> > longer true after the aforementioned commit.
> 
> How comes that move_freepages_block() gets called on reserved memory in
> the first place?
> 

It's simply math after finding a valid free page from the per-zone free 
area to use as fallback.  We find the beginning and end of the pageblock 
of the valid page and that can bring us into memory that was reserved per 
the e820.  pfn_valid() is still true (it's backed by a struct page), but 
since it's zero'd we shouldn't make any inferences here about comparing 
its node or zone.  The current node check just happens to succeed most of 
the time by luck because reserved memory typically appears on node 0.

The fix here is to validate that we actually have buddy pages before 
testing if there's any type of zone or node strangeness going on.

> > There's no reason why move_freepages_block() should be testing the
> > legitimacy of page_zone() for reserved memory; its scope is limited only
> > to pages on the zone's freelist.
> > 
> > Note that pfn_valid() can be true for reserved memory: there is a backing
> > struct page.  The check for page_to_nid(page) is also buggy but reserved
> > memory normally only appears on node 0 so the zeroing doesn't affect this.
> > 
> > Move the debug checks to after verifying PageBuddy is true.  This isolates
> > the scope of the checks to only be for buddy pages which are on the zone's
> > freelist which move_freepages_block() is operating on.  In this case, an
> > incorrect node or zone is a bug worthy of being warned about (and the
> > examination of struct page is acceptable bcause this memory is not
> > reserved).
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/page_alloc.c | 19 ++++---------------
> >  1 file changed, 4 insertions(+), 15 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2238,27 +2238,12 @@ static int move_freepages(struct zone *zone,
> >  	unsigned int order;
> >  	int pages_moved = 0;
> >  
> > -#ifndef CONFIG_HOLES_IN_ZONE
> > -	/*
> > -	 * page_zone is not safe to call in this context when
> > -	 * CONFIG_HOLES_IN_ZONE is set. This bug check is probably redundant
> > -	 * anyway as we check zone boundaries in move_freepages_block().
> > -	 * Remove at a later date when no bug reports exist related to
> > -	 * grouping pages by mobility
> > -	 */
> > -	VM_BUG_ON(pfn_valid(page_to_pfn(start_page)) &&
> > -	          pfn_valid(page_to_pfn(end_page)) &&
> > -	          page_zone(start_page) != page_zone(end_page));
> > -#endif
> >  	for (page = start_page; page <= end_page;) {
> >  		if (!pfn_valid_within(page_to_pfn(page))) {
> >  			page++;
> >  			continue;
> >  		}
> >  
> > -		/* Make sure we are not inadvertently changing nodes */
> > -		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
> > -
> >  		if (!PageBuddy(page)) {
> >  			/*
> >  			 * We assume that pages that could be isolated for
> > @@ -2273,6 +2258,10 @@ static int move_freepages(struct zone *zone,
> >  			continue;
> >  		}
> >  
> > +		/* Make sure we are not inadvertently changing nodes */
> > +		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
> > +		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
> 
> The later check implies the former check, so if it's to stay, the first
> one could be removed and comment adjusted s/nodes/zones/
> 

Does it?  The first is checking for a corrupted page_to_nid the second is 
checking for a corrupted or unexpected page_zone.  What's being tested 
here is the state of struct page, as it was previous to this patch, not 
the state of struct zone.

