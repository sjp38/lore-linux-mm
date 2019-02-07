Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D74E1C282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:48:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 995DE21904
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:48:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 995DE21904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E6E58E004A; Thu,  7 Feb 2019 11:48:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 396CC8E0002; Thu,  7 Feb 2019 11:48:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 286F68E004A; Thu,  7 Feb 2019 11:48:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD36A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:48:42 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w17so260568plp.23
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:48:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cNwE52CAtIF+radn0yGPCF9d34z+lppjpIAOK4UeaOE=;
        b=oVI7C8RXUP27al+JwVggTcazsIfNXmOgBD7LKBna+aJ2Sup9cXIrPpSR1VYhiNe/DK
         1KGuMN21iw02A5V8iCX35e3m6tK3g838o0z9f7sQNnHRnruYDNFH2Mm+h/fjO5GhgtNl
         5pJpox76FhxcwyFA2/EUfvQttjf81lDiSwkVxHF1J+I+SIejfPOiOnHtEkq3xJ4tm/Sx
         OtUh1mc2hhvSQX+4ldzyEAsJqYiHbZxxv7Hx2TKzue8PSkRCFIee5FGeJZAFNfG2Tuy+
         N/keSYNV8LmdlowBIuqiaFMwob5vRdF0wy4aWKgICzeRyd28oOfmqrgRldCGDLDdBTDW
         Tw9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuYU829iz1A5iGdA7wxkyhVMv7MBUYNIJlEqjlc5lAf4voeSopzw
	niVp/U9z/vnRga1GcH/AxzI5Ka0eXZJgJ2Mo3oocvm4GMQqsIsH8RO8L11WctldQswyeTXLD0U6
	U9Lkqy3aM+Na2tBir1UCB8MQWCfZTp5StTC/v1/UcRcUxdBqHXc/zgMvNcm1Dc0NCSg==
X-Received: by 2002:a17:902:848d:: with SMTP id c13mr17490092plo.257.1549558122530;
        Thu, 07 Feb 2019 08:48:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZTBkeFDbVLn1iaBd9ZPfe6ZGsgyEc3bt0appcaww2biZKcx090t3RYEOpk6vG0Bs6Bp2Sn
X-Received: by 2002:a17:902:848d:: with SMTP id c13mr17490043plo.257.1549558121853;
        Thu, 07 Feb 2019 08:48:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549558121; cv=none;
        d=google.com; s=arc-20160816;
        b=KDV3QvWcuKmcgKsd4drKvIvHKRjminCpSz/MAzX/rZo+HprM7frhTetsl0xuSEY/I5
         prOME/JeaUsRuBERq0Q2qGoB1ULnxHlivRr/SZZzKutFZWRGoC0TDLXICrYfQZa6lsGu
         /3LjFNaKMbRjiYMotAcZvz3GGTkvMYOfIJ4NZsnss5JY2ntZ3ileN22+kFTGMlbv6DqF
         bDMyFp1Mji3DF2gnBFMlJDVGdi8wXCnfyxOxt2qFC7vZunDNZufeJgGfLN1CnTmVu+gM
         Sn2Yy0orEG0GPhA5DY+FV/SyZhkS7jALEQ6xgwdNstVyRQQ7n9q8TOpQTF+Q12hLdgli
         UeUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cNwE52CAtIF+radn0yGPCF9d34z+lppjpIAOK4UeaOE=;
        b=TNOzvsVTUomCB9ObhoKpYScBp5TSzhh4RTugOXlxExp0fLNjyfyDH7YsO9ad5zv1dS
         50ZayJJRogH4TMSgKi4SmhAmYchBivzlJabofMD6hs6l4V1uIrX0dq1rs3cZTPyFvBp/
         xDMdvsYLvWnwabbV3ePnlzfhPb6gWXEqgEkHUQAAWMGX+nGuOtK6hVcflgFlzXN6UyXQ
         OEAQIh7Ae3REYLV0peXrlNW9lebIcqY3G0DYupwRNJF3rCuH+7k5O+WWX4D62sPvoMvi
         /YErIe+ZRMTrrHW+sKvusj7a9vVMUXoc3g9cKXwYIQSpxT8rNHPVNNQZ+ZAQBBqXIUZQ
         ZySw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cp14si10674722plb.170.2019.02.07.08.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 08:48:41 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 73FC8B017;
	Thu,  7 Feb 2019 16:48:38 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id CFDD71E3DB5; Thu,  7 Feb 2019 17:48:36 +0100 (CET)
Date: Thu, 7 Feb 2019 17:48:36 +0100
From: Jan Kara <jack@suse.cz>
To: Doug Ledford <dledford@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190207164836.GL3597@quack2.suse.cz>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206194055.GP21860@bombadil.infradead.org>
 <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
 <20190206202021.GQ21860@bombadil.infradead.org>
 <a5b976cad6a578f0a6e6573acbf547ceb9dad6c7.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a5b976cad6a578f0a6e6573acbf547ceb9dad6c7.camel@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 06-02-19 15:54:01, Doug Ledford wrote:
> On Wed, 2019-02-06 at 12:20 -0800, Matthew Wilcox wrote:
> > On Wed, Feb 06, 2019 at 03:16:02PM -0500, Doug Ledford wrote:
> > > On Wed, 2019-02-06 at 11:40 -0800, Matthew Wilcox wrote:
> > > > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > > > > though? If we only allow this use case then we may not have to worry about
> > > > > long term GUP because DAX mapped files will stay in the physical location
> > > > > regardless.
> > > > 
> > > > ... except for truncate.  And now that I think about it, there was a
> > > > desire to support hot-unplug which also needed revoke.
> > > 
> > > We already support hot unplug of RDMA devices.  But it is extreme.  How
> > > does hot unplug deal with a program running from the device (something
> > > that would have returned ETXTBSY)?
> > 
> > Not hot-unplugging the RDMA device but hot-unplugging an NV-DIMM.
> 
> Is an NV-DIMM the only thing we use DAX on?

Currently yes. However KVM people are soon going to use it for their
purposes as well (essentially directly sharing host page cache between
guests).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

