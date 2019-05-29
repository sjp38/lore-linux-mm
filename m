Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A9ADC04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 03:55:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2786421019
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 03:55:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2786421019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A1B56B0271; Tue, 28 May 2019 23:55:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 952F56B0272; Tue, 28 May 2019 23:55:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81A2F6B0273; Tue, 28 May 2019 23:55:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 497866B0271
	for <linux-mm@kvack.org>; Tue, 28 May 2019 23:55:20 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d7so777682pgc.8
        for <linux-mm@kvack.org>; Tue, 28 May 2019 20:55:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=KNtOxn49uj/4mQWINXWt7gvrmDenpcIgdufmBaNgqXQ=;
        b=P1fyOQpDlah8QjGrmc/G3IquurP6A2WcOsY0ymLAADxd7R+Upnq9zKj0MsU4ff54Ul
         nT++jHSo2oE4EAM97YzcY9axAiX5tTbFh6WSRxtejhgvp0YH3plLde42agkdztgjzDNX
         ndAv0ILD/6mIqTU4o4UCUH24oj69ME7Wj4A5qiHEonDrRuOfGIsGzCGg1CxkdxgIlNZm
         4QLPxHfSAgxR7tU8QcZHZlPmj7fwM5DMfjHtU0DZku63XU0geVEw4DoaCdtRNdYnDYkO
         aTCEpSBLSD3oDqSP+OWQoRMvYFhT0j0V4ZD+mLrsboGoqHvEQiLbiRNcY93Sk+xxWdzf
         AU8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWyyWMMtkwtz7De0Gw8DxT4yWv7jPdUR9hdILKF86sww5w+a8zg
	XMuuqJDpgD4PzPV5gdeDi2RW87lDmobJtr315BkMZKI7UTPClMdmHmWYNF/nDKHMtSCl6oZYssf
	16ixA2v57Z9l5qZhvdgszioFaXX1ggYP1amfe2eEc84HbLNCY3+eGSI+Ubl+DvGk1LQ==
X-Received: by 2002:a17:90a:f48f:: with SMTP id bx15mr9742487pjb.85.1559102119921;
        Tue, 28 May 2019 20:55:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVdSClYeECwCeGJZh//bpPE0xk8yyPpLGpUxD/DfqyTD9y9UyywlM9xhL4L5k2qSWQS6/M
X-Received: by 2002:a17:90a:f48f:: with SMTP id bx15mr9742445pjb.85.1559102119090;
        Tue, 28 May 2019 20:55:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559102119; cv=none;
        d=google.com; s=arc-20160816;
        b=voDahIWw8pU4ILsJ/SZ55+3Hueft5hDVszZPlo0/sI7B8nJxFZgAXbmwg9nevz+w4f
         x/EDe+8WBx3ywdWMud4Xw0Cxo/mimARXUuxlF/GJSURsD1Q50asNR9W/UKoqbIG6z/H3
         HHl+T0bsjVO3pvfjlK9hLXmMX2v6b9KbGN/nMY6TeODTGd4LsuBWBrTWpoCZfFqB0151
         Fz94iTT4q4Q5BuM1k3I8ZZBYjgQ4NbwJ82C92gvzkPyi18AW+ExXSyoUHzoZJ4XH3ncy
         E8xIul6KQnI3J0K8HKk89f2wNkFnKoSt04WMO27apI84+r2Kgn5dVlx/lktWePWdufRx
         gtig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=KNtOxn49uj/4mQWINXWt7gvrmDenpcIgdufmBaNgqXQ=;
        b=szYQkGFbp7OOj12Qes1o99h8QllBvMiuw+iRHqrZN3Vem5YoFR8f1GuiJxyuBhvQV0
         1kTNyNVGmMkl1ivFyHR6cVwFGwF6bQC4t0qHU3Gn+Gd23dYpC3HKyraIw+/3e4daUME8
         Hc4JlcL7WQG8nLszT1AAMuf4TMCPRhkag4iMY8u5JeH+ADc1HdSiEEmY4+G/HdyXEs2f
         C20l7NdeUT4ToG/CawfErj5GITSlC+brXz1fcf99g8UnCtNlFkIwFBMKIFx1fUoKTHOI
         Giw5vKim8L07NKgWwG7GVEcc2ZRa59C4LCwI62JLp1N33Uw1adgikEvOwIfok3cWhyHL
         eYQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f8si25738008pfh.200.2019.05.28.20.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 20:55:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 May 2019 20:55:18 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 28 May 2019 20:55:18 -0700
Date: Tue, 28 May 2019 20:56:19 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2] mm/swap: Fix release_pages() when releasing devmap
 pages
Message-ID: <20190529035618.GA21745@iweiny-DESK2.sc.intel.com>
References: <20190524173656.8339-1-ira.weiny@intel.com>
 <20190527150107.GG1658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190527150107.GG1658@dhcp22.suse.cz>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 05:01:07PM +0200, Michal Hocko wrote:
> On Fri 24-05-19 10:36:56, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > Device pages can be more than type MEMORY_DEVICE_PUBLIC.
> > 
> > Handle all device pages within release_pages()
> > 
> > This was found via code inspection while determining if release_pages()
> > and the new put_user_pages() could be interchangeable.
> 
> Please expand more about who is such a user and why does it use
> release_pages rather than put_*page API.

Sorry for not being more clear.   The error was discovered while discussing a
proposal to change a use of release_pages() to put_user_pages()[1]

[1] https://lore.kernel.org/lkml/20190523172852.GA27175@iweiny-DESK2.sc.intel.com/

In that thread John was saying that release_pages() was functionally equivalent
to a loop around put_page().  He also suggested implementing put_user_pages()
by using release_pages().  On the surface they did not seem the same to me so I
did a deep dive to make sure they were and found this error.

>
> The above changelog doesn't
> really help understanding what is the actual problem. I also do not
> understand the fix and a failure mode from release_pages is just scary.

This is not failing release_pages().  The fix is that not all devmap pages are
"public" type.  So previous to this change devmap pages of other types would
not correctly be accounted for.

The discussion about put_devmap_managed_page() "failing" is not about it
failing directly but rather in how these pages should be accounted for.  Only
devmap pages which require pagemap ops (specifically page_free()) require
put_devmap_managed_page() processing.   Because of the optimized locking in
release_pages() the zone device check is required to release the lock even if
put_devmap_managed_page() does not handle the put.

> It is basically impossible to handle the error case. So what is going on
> here?

I think what has happened is the code in release_pages() and put_page()
diverged at some point.  I think it is worth a clean up in this area but I
don't see way to do it at the moment which would be any cleaner than what is
there.  So I've refrained from doing so.

Does this help?  Would you like to roll a V3 with some of this in the commit
message?

Ira

>
>
>
> 
> > Cc: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > 
> > ---
> > Changes from V1:
> > 	Add comment clarifying that put_devmap_managed_page() can still
> > 	fail.
> > 	Add Reviewed-by tags.
> > 
> >  mm/swap.c | 11 +++++++----
> >  1 file changed, 7 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 9d0432baddb0..f03b7b4bfb4f 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -740,15 +740,18 @@ void release_pages(struct page **pages, int nr)
> >  		if (is_huge_zero_page(page))
> >  			continue;
> >  
> > -		/* Device public page can not be huge page */
> > -		if (is_device_public_page(page)) {
> > +		if (is_zone_device_page(page)) {
> >  			if (locked_pgdat) {
> >  				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
> >  						       flags);
> >  				locked_pgdat = NULL;
> >  			}
> > -			put_devmap_managed_page(page);
> > -			continue;
> > +			/*
> > +			 * zone-device-pages can still fail here and will
> > +			 * therefore need put_page_testzero()
> > +			 */
> > +			if (put_devmap_managed_page(page))
> > +				continue;
> >  		}
> >  
> >  		page = compound_head(page);
> > -- 
> > 2.20.1
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

