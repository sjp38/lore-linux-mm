Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55AF2C282C7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:10:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EA69218D2
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:10:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EA69218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63D3E8E0002; Thu, 31 Jan 2019 04:10:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C2DF8E0001; Thu, 31 Jan 2019 04:10:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48D328E0002; Thu, 31 Jan 2019 04:10:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E225E8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:10:14 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b7so1027492eda.10
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:10:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UcrV2h866LCLm4yBcReSvczmMBZpti1V9x0ARMtWU2k=;
        b=KAJszb+sgS5KgNMwib9hU95DdoyYlWiyq+FwOshNU7ObB99mcANxgWdBdmewu7Djgl
         K4lrdNnhCu0XX03ROz1J8KBMCm1tjA2DNECpafdIqrZCtCi8jRT/K/tdSMZoEmlmcwDi
         WMFxXoYx1TgJVrk9XRC2F1yZZFzN3B3gsTnVwDSxttrKp74AS//J9N6WBtLNJ+jvWvr1
         8PYy3/tgVYV1RIRROMvAGGWepmnswWR3e2TaZgKHcYUsJB6eKFIaqWVPsfdsbZs7527n
         cgI6nwoLtBppqxCa3dcgLu/NCYhc3aD3gcUXfn4OmNWFDv73XIBMXV+3uQ9txiYJLx1M
         A0vw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdT5NU1rpCSAs8yuOSjWRPu1WqD2TGqSVfOnFFjJ3sEAc9z5Lt6
	wpjcrCw350yCuNAKmiaYa3vLTD5GZUL1oSQMZqEcAn0JnLeJUi1B6MEy/Df3MMZ0z6x0ScdHqLj
	2z57fetbRLsr+BFUEuVa4PPcg7F5vHFFCwzAbosVCWS9nfPiGy5Rat8IM0u2DWzk=
X-Received: by 2002:a50:d94a:: with SMTP id u10mr33123633edj.214.1548925814354;
        Thu, 31 Jan 2019 01:10:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN79UlIcFm/7O/7sBYKH5nKUVABOtflw5nAZ1UE5HXcJARd15wAumJdABNatwKvkKTeOg5LA
X-Received: by 2002:a50:d94a:: with SMTP id u10mr33123577edj.214.1548925813371;
        Thu, 31 Jan 2019 01:10:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548925813; cv=none;
        d=google.com; s=arc-20160816;
        b=harBP5KhPY644/2pFFYqLxCXtXojIrXj0DlMzO5CPXndqOxraEO2ObO3BdJ6+r3GlC
         FEuc4fZhnyU51ZgikIz6eR6bQ08WX1Z3tfh1JL3gRVSapxtYe7fk88Ua3DzZcij/S7EQ
         kQKhLONb3A5T40w5dn+w7SbB3pU5BXNWzcbH9Hj6snosxJy+IuIu1JfK4ZBG1Eod1YfX
         4vYF+h5elhwyRWWdumxBuQqN1+P4OzjcXERTOsTJhIqzqdqmaZ/XpApW0C8Wir581ygJ
         SQOUu20vQM6UfOTUJTcY8zCKmNBMcrJNQvzweJHaP45b5Mum3N0Xm80lmgBjODxzxzJi
         Bd4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UcrV2h866LCLm4yBcReSvczmMBZpti1V9x0ARMtWU2k=;
        b=BX8lJ3vAGWcX5+e7nI/Sr+/gR7b+Zpjc7HbqOI+9yxDP5AyHfjpgXaabe1erik6BhC
         gCzs90TnuoLWE7XImU4HVA+Nhl5B4J2U+PvQRpPmV9NmJWsc44c0rNG+RpUPlMMB6zJ8
         WXTKbcl5RazeYdnpDJ5R1Wcc3zk9fDkFoMgmmN0VYnocwckZnXEsey8dlsxS57Cy+EcI
         EHadZsCkXttIAGq7QjNmIu1H2SNsRLLhRbmO0JY4tNNspoK+VCWUMHVUoJ35pfj2ayTP
         bF5CMYtB0ovX0qZIMq9dUKb6GxybQEHXjaExkpJds3/As0xVAn+dQE4CKMsjh8WYp7Az
         CSWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l13si2117069edw.439.2019.01.31.01.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 01:10:13 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8B6EFAE77;
	Thu, 31 Jan 2019 09:10:12 +0000 (UTC)
Date: Thu, 31 Jan 2019 10:10:11 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Chris Mason <clm@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Message-ID: <20190131091011.GP18811@dhcp22.suse.cz>
References: <20190130041707.27750-1-david@fromorbit.com>
 <20190130041707.27750-2-david@fromorbit.com>
 <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
 <20190131013403.GI4205@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131013403.GI4205@dastard>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 12:34:03, Dave Chinner wrote:
> On Wed, Jan 30, 2019 at 12:21:07PM +0000, Chris Mason wrote:
> > 
> > 
> > On 29 Jan 2019, at 23:17, Dave Chinner wrote:
> > 
> > > From: Dave Chinner <dchinner@redhat.com>
> > >
> > > This reverts commit a76cf1a474d7dbcd9336b5f5afb0162baa142cf0.
> > >
> > > This change causes serious changes to page cache and inode cache
> > > behaviour and balance, resulting in major performance regressions
> > > when combining worklaods such as large file copies and kernel
> > > compiles.
> > >
> > > https://bugzilla.kernel.org/show_bug.cgi?id=202441
> > 
> > I'm a little confused by the latest comment in the bz:
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=202441#c24
> 
> Which says the first patch that changed the shrinker behaviour is
> the underlying cause of the regression.
> 
> > Are these reverts sufficient?
> 
> I think so.
> 
> > Roman beat me to suggesting Rik's followup.  We hit a different problem 
> > in prod with small slabs, and have a lot of instrumentation on Rik's 
> > code helping.
> 
> I think that's just another nasty, expedient hack that doesn't solve
> the underlying problem. Solving the underlying problem does not
> require changing core reclaim algorithms and upsetting a page
> reclaim/shrinker balance that has been stable and worked well for
> just about everyone for years.

I tend to agree with Dave here. Slab pressure balancing is quite subtle
and easy to get wrong. If we want to plug the problem with offline
memcgs then the fix should be targeted at that problem. So maybe we want
to emulate high pressure on offline memcgs only. There might be other
issues to resolve for small caches but let's start with something more
targeted first please.
-- 
Michal Hocko
SUSE Labs

