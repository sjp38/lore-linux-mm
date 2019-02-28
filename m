Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20C09C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:55:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA05721850
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:55:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA05721850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C8628E0005; Thu, 28 Feb 2019 04:55:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74E8F8E0001; Thu, 28 Feb 2019 04:55:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6195D8E0005; Thu, 28 Feb 2019 04:55:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 051D38E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:55:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id h37so6580249eda.7
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:55:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I9favefAitUIyi+UDCXYHOrKCWG5l/TRB8AWbPxufD0=;
        b=lgT4rQB66FmR/Jg92OfvOftu6+zXn2CbhbXCQ563EXF0Ynfwp1A4jQQUO1Opym5Xc/
         AV5nQNAyLW0Gqjlq+4s7JBLUfvDkLp1lDadbZHj5SQM/wN74ZJOB52WiAcIKapxRrHZe
         7JBt+GmPZyxQ2UV7cZCs3qxFI+zqHuc1dUNu+X/FFG3dWOKA3ttNBnzeqNB54DfgDGBj
         CcAAf6Mxfepj+wOe0vgUbVr+NnGi32oHoBkR72njDDZ68fOC7n6y0BdoaqNhYUQTrzfc
         eNk41+1iv0OgxXx+DfwTVhwF3nx34/iHsAPyGSNg6/dE7ZfUAgXZFNJnE1SVTFcqvHE/
         B2ow==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuY40im7/fEXzSp1iYszHMdvgP2d6G3Tey9eIRnAWootdiZK7VBg
	qOHd1RwOpVR4pRBKXwFzM9eEmAVFGoHcqpJYQJ80LKZwKBoT8HQKj5NcCUazkj64fsywRRHZaJX
	fxvYrk26DLt22JNfncRg1MzsYpcuq8qmiFgXoAtucwFhDyZ+NMZa4Vyew9R4/X24=
X-Received: by 2002:a17:906:e56:: with SMTP id q22mr4821834eji.132.1551347738574;
        Thu, 28 Feb 2019 01:55:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY2A/+w19WinNaVmiIAj3Pg71KnE3qZdBD+4BeybgE0y5/xRFaa9avfKnW/U6RZceWjqC9D
X-Received: by 2002:a17:906:e56:: with SMTP id q22mr4821798eji.132.1551347737785;
        Thu, 28 Feb 2019 01:55:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551347737; cv=none;
        d=google.com; s=arc-20160816;
        b=v/126YrqtQA9JwfqHQ9qOl/pYNMX5uU3A2nJJxPZogffCEFIiwPWmwiIoJN/frZlpu
         ScIw5KY8z9RWk9JBkcr2+Eq2ZNBux3rRBNyRecXjdpvZ/841VkTrkhZ+y/N2JamOcgjw
         7D2KNbysnE7k9lXz3Ak4HiJzaWMtE/YL6cYhnwGcbzQNkcaqVsYcNq0kP8nyzVq8MTur
         c3ruJZPYhk2OxH2NSatCb0SR/cv2aVcWKCKqgc3z56P54bSpTRPQgPHdqERQ880/ZMeP
         +rS1cKe8AVJ9WPkVQmTUFRMqR8z0tmQtLm5LSphfLFef6QRO16Jlkw2CUpYYh+WcHg10
         bfHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I9favefAitUIyi+UDCXYHOrKCWG5l/TRB8AWbPxufD0=;
        b=OQHhtXsjcgLH/XUoddwLr6z4B7MUsM4yr+O8SlHP+BkrkPlkd55uvvZqOUYvORXxX4
         mF8WSCk7yOxoJGHYcG6m8+3XBJ3WcLSeG23BfWDVvEBp2c6sAXgCfKtOsQcGd4BQf65t
         5RN5pvpoUGWmFUHN7s2yuhVb1+UrDDWYDJNwJeerCH/MGhXcB9Fw7p54ap14daqckaWx
         efXNguVsQnrBW20ZsifnPJQ0o2b3hxUx6PhQg97aF2gLBpDTAbXLHQEbZJUGfR8O7eYC
         1xIOdMLG6Xrnq8xsMlx2tNKJv1DVaYLhg3wKYl8oKZU1BzlRayEysOQTLAxGaqK0zg5e
         rYcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d23si18286eda.353.2019.02.28.01.55.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 01:55:37 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6A0F5AB4C;
	Thu, 28 Feb 2019 09:55:37 +0000 (UTC)
Date: Thu, 28 Feb 2019 10:55:35 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, david@redhat.com,
	mike.kravetz@oracle.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190228095535.GX10588@dhcp22.suse.cz>
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190228092154.GV10588@dhcp22.suse.cz>
 <20190228094104.wbeaowsx25ckpcc7@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228094104.wbeaowsx25ckpcc7@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-02-19 10:41:08, Oscar Salvador wrote:
> On Thu, Feb 28, 2019 at 10:21:54AM +0100, Michal Hocko wrote:
> > On Thu 21-02-19 10:42:12, Oscar Salvador wrote:
> > [...]
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > index d5f7afda67db..04f6695b648c 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > > @@ -1337,8 +1337,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
> > >  		if (!PageHuge(page))
> > >  			continue;
> > >  		head = compound_head(page);
> > > -		if (hugepage_migration_supported(page_hstate(head)) &&
> > > -		    page_huge_active(head))
> > > +		if (page_huge_active(head))
> > >  			return pfn;
> > >  		skip = (1 << compound_order(head)) - (page - head);
> > >  		pfn += skip - 1;
> > 
> > Is this part correct? Say we have a gigantic page which is migrateable.
> > Now scan_movable_pages would skip it and we will not migrate it, no?
> 
> All non-migrateable hugepages should have been caught in has_unmovable_pages:
> 
> <--
>                 if (PageHuge(page)) {
>                         struct page *head = compound_head(page);
>                         unsigned int skip_pages;
> 
>                         if (!hugepage_migration_supported(page_hstate(head)))
>                                 goto unmovable;
> -->
> 
> So, there is no need to check again for migrateability here, as it is something
> that does not change.
> To put it in another way, all huge pages found in scan_movable_pages() should be
> migrateable.
> In scan_movable_pages() we just need to check whether the hugepage, gigantic or not, is
> in use (aka active) to migrate it.

You seemed to miss my point or I am wrong here. If scan_movable_pages
skips over a hugetlb page then there is nothing to migrate it and it
will stay in the pfn range and the range will not become idle.

-- 
Michal Hocko
SUSE Labs

