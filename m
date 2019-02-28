Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA8DAC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:41:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A316B218B0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:41:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A316B218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EED48E0005; Thu, 28 Feb 2019 04:41:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29EF78E0001; Thu, 28 Feb 2019 04:41:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B58E8E0005; Thu, 28 Feb 2019 04:41:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B3F358E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:41:10 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id 29so8115712eds.12
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:41:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zUTwPpnew74p2CNEcvJ3SVgTn0k2SWNg1YzSt2pXtVY=;
        b=OsqHRtgJSDE8S8vRrW7ejgye9cqQ7aKEFqC3xJ6rsR/sW+HmIa9RjlBaQcWqlpVQz+
         3p7iQnyfGTtIZsGxbH1++32I6D1GRoMN4H7YLPxTm9I8ZUflT+wnC/HaXCrszq11WsvQ
         zaEBAmkk6QSMCDxg3xEqVmdgLnxc7ODOUlhOxJIdp2P4F4Ucnn/Lqkp0oS7cNuk5Kv6J
         6//u2pCTfBOUeuajwDx8b3bma9OaCONjJkZ0EUP6u879MFfINmWgCC9PAv2epjecaoeB
         YLqGbynEPX9sKgTP3v/86/bCRQWT6nuFruEmgeMqtQyftz4sjV5qSckSsQDYWAtnCHuA
         +rKQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuZLciqNrMQB8zMrMjHljUdW6sTjeQCRmM+2utJqiz/3GehrDauB
	cGP7mEeatv9UW0Gmu5upskZGuDw2cwZFY0GfCIV/Yglf1FI5jxaY3z8oXhY+HMDBgpObGw1te5p
	T6bHQmOF2M46lqkANMz82JdIw3kiMOX+vHFvjgJrb6puQDwEEliD9z4ech0CrmKo=
X-Received: by 2002:a50:add2:: with SMTP id b18mr6111991edd.43.1551346870290;
        Thu, 28 Feb 2019 01:41:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQqo7sRAqe5FTQRb60yN/qJPIXyiI6J+g+Qp9nZFp4Q0JDU9tGAc1ZCLTAAiHpcvzGnjwW
X-Received: by 2002:a50:add2:: with SMTP id b18mr6111940edd.43.1551346869447;
        Thu, 28 Feb 2019 01:41:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551346869; cv=none;
        d=google.com; s=arc-20160816;
        b=ZphSuka19oI0Q7jSkJGhx8lt/zUSnD7RGYXOVAoVCm9bqUiUhlinw4QzWV87FW6lwo
         VCw4xQSdfEBM98KULo4msqqvmStRS9rD3hXTRKsM9uShLexP60U8atSwU++GNdJWBQRS
         30BxmGw/yw/o3W88uUeJdNC+pkGtKEKMq7yMwdCS9Ppve8kfhGGFWf2F84jXkHKzEK+2
         BKxyFrySkeaO3gh2T3hyKuWv7sLVff5J0oa9vwt05y35gcad+qAI9keKu49hfhznvts/
         NAVUT3i8uiX9XMLGaiFc7+74WIPvSoUPwNTZPmaubLRvWgcXOdM8CWcPBS1v9EH7YSN6
         YBMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zUTwPpnew74p2CNEcvJ3SVgTn0k2SWNg1YzSt2pXtVY=;
        b=bYwqAKwgV5Ct0/4wXmSGLTP2O5YnVONZs/DU/Xzo1pSYrolg4Ape5IeBvXR/fqc5zC
         OwtbrgalytllBGNWpp4nC2Ld81CaLqAL3rf5im/3MM/wTzfdUIrW/DyYawM9d+NV4HA4
         9VBUqe6xQHRKQE8fuFnAO+RRKMPQNXQjqIsa77n+hKkwJ5042q4l+pezwMR4/n8qYiBq
         HC1Nqm2IZ+tGzpHdsIVfXwM/bPKKEJmmfNzgHuih2Z+L9gP0acLj/wZv+c+iUCzHz+Ia
         OKaAXPDXMcinThs594HGLJ7DanPdXzPBpajk4WJJrNPsv+/vgCz2SWDMt3LmxSQ0jPuF
         1vnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id e43si1077032eda.396.2019.02.28.01.41.09
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 01:41:09 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 8B8E943FF; Thu, 28 Feb 2019 10:41:08 +0100 (CET)
Date: Thu, 28 Feb 2019 10:41:08 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, david@redhat.com,
	mike.kravetz@oracle.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190228094104.wbeaowsx25ckpcc7@d104.suse.de>
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190228092154.GV10588@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228092154.GV10588@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 10:21:54AM +0100, Michal Hocko wrote:
> On Thu 21-02-19 10:42:12, Oscar Salvador wrote:
> [...]
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index d5f7afda67db..04f6695b648c 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1337,8 +1337,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
> >  		if (!PageHuge(page))
> >  			continue;
> >  		head = compound_head(page);
> > -		if (hugepage_migration_supported(page_hstate(head)) &&
> > -		    page_huge_active(head))
> > +		if (page_huge_active(head))
> >  			return pfn;
> >  		skip = (1 << compound_order(head)) - (page - head);
> >  		pfn += skip - 1;
> 
> Is this part correct? Say we have a gigantic page which is migrateable.
> Now scan_movable_pages would skip it and we will not migrate it, no?

All non-migrateable hugepages should have been caught in has_unmovable_pages:

<--
                if (PageHuge(page)) {
                        struct page *head = compound_head(page);
                        unsigned int skip_pages;

                        if (!hugepage_migration_supported(page_hstate(head)))
                                goto unmovable;
-->

So, there is no need to check again for migrateability here, as it is something
that does not change.
To put it in another way, all huge pages found in scan_movable_pages() should be
migrateable.
In scan_movable_pages() we just need to check whether the hugepage, gigantic or not, is
in use (aka active) to migrate it.

> 
> > @@ -1378,10 +1377,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >  
> >  		if (PageHuge(page)) {
> >  			struct page *head = compound_head(page);
> > -			if (compound_order(head) > PFN_SECTION_SHIFT) {
> > -				ret = -EBUSY;
> > -				break;
> > -			}
> >  			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
> >  			isolate_huge_page(head, &source);
> >  			continue;
> 
> I think it would be much easier to have only this check removed in this
> patch. Because it is obviously bogus and wrong as well. The other check
> might be considered in a separate patch.

I do not have an issue sending both changes separedtly.
I mean, this check is the one we need to remove in order to make 1Gb-hugetlb
offlining to proceed.
The removed check from scan_movable_pages() is only removed because it is redundant
as we already checked for that condition in has_unmovable_pages()
(when isolating the range).

-- 
Oscar Salvador
SUSE L3

