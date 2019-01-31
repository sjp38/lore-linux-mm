Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CDA1C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:32:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 447D2218AF
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:32:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 447D2218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D24ED8E0002; Thu, 31 Jan 2019 06:32:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD2968E0001; Thu, 31 Jan 2019 06:32:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC3A18E0002; Thu, 31 Jan 2019 06:32:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 61E548E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:32:30 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e29so1206360ede.19
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:32:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OddDy3peBL+A4RHx1CvooQ+NJa1G93UNwUWbdWsLGX0=;
        b=jQjMU0Y8Eow1kdZCZhOeIAxrQWsY6FFq1mGFzMq+/RNE2PRc1JVpIshO1jGUV328JZ
         lnyOCiehqo+ZviBpEbzJVl8uDBoeg4hys/i+BSnZ/hq78gAh/zvpUDfDshb4OXVgOhRr
         TKXgHxpvhGTyWXlPpDjSEkMyfZ2mQO90ZupqtF3soXIzQYHkMFoWt5zbAugo2fK/uaz5
         B2fi7Zyz/Z1+eB2rE2AHiEhCKOg3G6XOwUgtQMeIeJNXqYyHPT5PtXJ6Uid/o52Dhhbw
         R3S6A0gDdOGOtqvwmhRbCcCJrn9FeEBgGAwyfCrz121sVsj2evB7jf+AM8LwMUecal8w
         Hpvg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaYZjcxVXI9J83BTZA8f+hPu7n2YgDZvgzeeNZpTccIBFDT6YBV
	rrTgmJ+1yQ3EaHegj354d7R2Is1urVa3USbrK5cukwzKB5gIqRUlOZ3qhm1voFvJdTqXhy2/LN+
	Si46Be12h1nYG+8RbDu2AY4Er6QoUuHO3u9Hr1uSmtCV7naAENS1QKWag9PS7mLY=
X-Received: by 2002:a17:906:4007:: with SMTP id v7mr2811552ejj.128.1548934349953;
        Thu, 31 Jan 2019 03:32:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iaf6x7s22bZhPjzZJ3sAUI+3HOifQw0V312hSatDwHLZNubr0IbaVzchhYy3hV37gf29A4Y
X-Received: by 2002:a17:906:4007:: with SMTP id v7mr2811512ejj.128.1548934349086;
        Thu, 31 Jan 2019 03:32:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548934349; cv=none;
        d=google.com; s=arc-20160816;
        b=0e6Ki4l4h5eQt19v2CbocV2WMobXkvmwkwAiVca/AtLde0IIcagXVh6SiQkbCTZtVI
         +IC9iZzrdUT4NnTrld7ZS5ZNsaR9chqoiJLeZQYWwsuSjt1FUfwhkPyY1J2683F3Lp/r
         gPfEEOPMJHb1avkCLTY+ZUyHq1OymuaZ1Iqly6a9NpdCAK3WEfyNtjgCOuMrWAYtdGhH
         CnHWrh5jSA4CdvmPx55M/x8uvkpuRLwxgsUujSX2dfqVsW5wx+SfR9p2R362hGTHvBwt
         3tMCVMlTmsNPLmFVGsOELfa2Tda6+bLct3xXNM2bMKGReLPSdIX4MgLWO+KM5Y15+qEA
         zCtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OddDy3peBL+A4RHx1CvooQ+NJa1G93UNwUWbdWsLGX0=;
        b=hjMFyQTJ+mh9bdNEYZJ82H8OWzLUH+Xo+8f/2P12hu3XtwyEkd0kk+duuqFDD8QwAN
         qxTIQfydAy5091Ux6VqPYy5PnPINiMu+t+5uFTJpNBTYi1Z1Ra5L1udNP23Wu0DybK2P
         oUuga/ffWhC619WwHbWh/9b8nTbdDGNunrloqkyjhpO2Z5X82wBF7yOuE8x5WMxibD+b
         mvOdCseBx64RfYq525xqI3/aQyvr+dBIfHW63ty+5tT1vkOtart/AQ5q3XVMZZr6F2Q1
         HPYkPvB4mXqEOf/HtQorH6prZbvWoW8hHWp2u+8YYBz8dIhgBdYa+KBf4Mz9iYkv5R+i
         ongA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si2341680eds.229.2019.01.31.03.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 03:32:29 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6F021B0B9;
	Thu, 31 Jan 2019 11:32:28 +0000 (UTC)
Date: Thu, 31 Jan 2019 12:32:23 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
Message-ID: <20190131113223.GU18811@dhcp22.suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-3-vbabka@suse.cz>
 <20190131095644.GR18811@dhcp22.suse.cz>
 <nycvar.YFH.7.76.1901311114260.6626@cbobk.fhfr.pm>
 <20190131102348.GT18811@dhcp22.suse.cz>
 <nycvar.YFH.7.76.1901311129420.3281@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1901311129420.3281@cbobk.fhfr.pm>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 11:30:24, Jiri Kosina wrote:
> On Thu, 31 Jan 2019, Michal Hocko wrote:
> 
> > > > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > > > index 9f5e323e883e..7bcdd36e629d 100644
> > > > > --- a/mm/filemap.c
> > > > > +++ b/mm/filemap.c
> > > > > @@ -2075,8 +2075,6 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
> > > > >  
> > > > >  		page = find_get_page(mapping, index);
> > > > >  		if (!page) {
> > > > > -			if (iocb->ki_flags & IOCB_NOWAIT)
> > > > > -				goto would_block;
> > > > >  			page_cache_sync_readahead(mapping,
> > > > >  					ra, filp,
> > > > >  					index, last_index - index);
> > > > 
> > > > Maybe a stupid question but I am not really familiar with this path but
> > > > what exactly does prevent a sync read down page_cache_sync_readahead
> > > > path?
> > > 
> > > page_cache_sync_readahead() only submits the read ahead request(s), it 
> > > doesn't wait for it to finish.
> > 
> > OK, I guess my question was not precise. What does prevent taking fs
> > locks down the path?
> 
> Well, RWF_NOWAIT doesn't mean the kernel can't reschedule while executing 
> preadv2(), right? It just means it will not wait for the arrival of the 
> whole data blob into pagecache in case it's not there.

No, it can reschedule for sure but the man page says: 
: If this flag is specified, the preadv2() system call will return
: instantly if it would have to read data from the backing storage or wait
: for a lock.

I assume that the lock is meant to be a filesystem lock here.
-- 
Michal Hocko
SUSE Labs

