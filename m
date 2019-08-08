Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64388C32756
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3230C21882
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:22:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3230C21882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5EA56B000C; Thu,  8 Aug 2019 02:21:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE7D06B000D; Thu,  8 Aug 2019 02:21:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B0CB6B000E; Thu,  8 Aug 2019 02:21:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF856B000C
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:21:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so57572344edx.12
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:21:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yYtKGAMPjoXjqo32/hmcOOi7aPq8QaatA1uJ9Rtg46M=;
        b=Jtzsi05OKCLXH4rkOEp/KI0TyDQrbCtO9ToKRHFBirw5j6AJVxRuyGRd5LTwsBtpn+
         VyowcQJGTNhC+ofsLEwrEYGVVsV13HP4otc0eJSxyWILqMc5AGmHy7frFYLCiKptgc7I
         74DDun+GwwI70QDj7LiOAWZSBy3pWNjtBPvy7omQORQg4DfBa1cfPzXNOB7DVEvpHc/O
         nI2v+f8b+NAzivrQv8mZV5WFOrZ+upEoJmHF9IbIxI1aY8JO9Jl2bu6PujUxn+1ho5xV
         8jji8yHcXtTkxy5UrYYVt6vHj6IFxvvnW7ODzl/LeeIjNWczON64GLsKLhAraaqFLjyX
         m+1w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUZMPcassFwb6WzKtgmGdMDrZ9+JB/tboVRdCVRnVjPgpHwhdFp
	O/hkIbRgeVrvDq2/HzlZtE70nAsIK01D6HE64aV3jOhMjUHfoXxlLH67xA8e2tzTBs2CkrfLHe6
	xxg5wl0PdZ1uwZdiV/axTLk2xPK6IuRBTwrLobK+fDeIPE13t7gUEcZ7Vt5hIzPA=
X-Received: by 2002:a17:907:217c:: with SMTP id rl28mr11693884ejb.131.1565245318896;
        Wed, 07 Aug 2019 23:21:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzw8WwLwzEEte9/Csass1rAR5hZRulPrwHGQola7X9tW4wmsDgfXtozy+idxEQ6vpJMtFcY
X-Received: by 2002:a17:907:217c:: with SMTP id rl28mr11693839ejb.131.1565245318237;
        Wed, 07 Aug 2019 23:21:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245318; cv=none;
        d=google.com; s=arc-20160816;
        b=DvewD/098+NjbUm426F3aBV5SS5Ky2Gg0yWtubpJbscD6oSxppJbz07/pSyyvggcLN
         Tm4VlR9GHcV6AwK8c369rayA5/CcVqaCNE3zXM+/iFS6gaNWgzteJK1rBmmGEpOoAvhS
         QJ/OZ8Ffmo/oQKUxT6LC2XcUDSJ/NnIpE0htFcsmkc1AqcS3gWSoH641aA5QR5RH9eu2
         6Jg0Ao0kqDi8lL1iFU5j3+PNnZbSV1aRQEMigVeU6jIBlGxOUef7WGnxGSqqwtZVByvA
         s3+7T1DjNk32Aj+tsQ9qy1Kdzf5Sm7ifvv7NBPobjNEWIgWTR0uCMfM0QnEq7+WCvRup
         tVGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yYtKGAMPjoXjqo32/hmcOOi7aPq8QaatA1uJ9Rtg46M=;
        b=syGFjdaTf8AVhPO3K+3y0oXl9fLJQ9MelHIlNWZNPL3fqKFQ5gkg1L+NaG6YYwmijY
         9lXnj1jHGHV/qeNTQ5fqioKlF7WUrfaB69KlfIROVMeeDUscupKaC2nAJ9UXqc1Nmstg
         HQTz4+6z5DHPTU6aMVJbuKTSppFSJmaaDiVRbnKpXPI53puFll1rrkd3E8rhCKHtaaEB
         m19hwnZpUKkS1+h6OoX7U9ruD9X4hkgTPNauyeHaNDw/p70f1tMWy+n4/TjfiMwBLirU
         Ioz5Pas9OoVSQZUdN3QRw0JUTU8Yhq4m309usi7CoCDxAIY9UufWvNmcIRCx7khVaNWG
         Pqfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si36695315eda.437.2019.08.07.23.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 23:21:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4FE4DAF37;
	Thu,  8 Aug 2019 06:21:57 +0000 (UTC)
Date: Thu, 8 Aug 2019 08:21:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Message-ID: <20190808062155.GF11812@dhcp22.suse.cz>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 07-08-19 16:32:08, John Hubbard wrote:
> On 8/7/19 4:01 AM, Michal Hocko wrote:
> > On Mon 05-08-19 15:20:17, john.hubbard@gmail.com wrote:
> >> From: John Hubbard <jhubbard@nvidia.com>
> >>
> >> For pages that were retained via get_user_pages*(), release those pages
> >> via the new put_user_page*() routines, instead of via put_page() or
> >> release_pages().
> > 
> > Hmm, this is an interesting code path. There seems to be a mix of pages
> > in the game. We get one page via follow_page_mask but then other pages
> > in the range are filled by __munlock_pagevec_fill and that does a direct
> > pte walk. Is using put_user_page correct in this case? Could you explain
> > why in the changelog?
> > 
> 
> Actually, I think follow_page_mask() gets all the pages, right? And the
> get_page() in __munlock_pagevec_fill() is there to allow a pagevec_release() 
> later.

Maybe I am misreading the code (looking at Linus tree) but munlock_vma_pages_range
calls follow_page for the start address and then if not THP tries to
fill up the pagevec with few more pages (up to end), do the shortcut
via manual pte walk as an optimization and use generic get_page there.
-- 
Michal Hocko
SUSE Labs

