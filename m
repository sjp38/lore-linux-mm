Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D5BDC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:23:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C693E218AF
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:23:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Vvy/No3s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C693E218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 676428E0002; Wed, 30 Jan 2019 16:23:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 626558E0001; Wed, 30 Jan 2019 16:23:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C6EB8E0002; Wed, 30 Jan 2019 16:23:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0973A8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 16:23:50 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 75so716955pfq.8
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:23:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tM1a7yhYhXG8s2eHu7gjDoFR8t2UkuoCVZDqriCJf6c=;
        b=CzQZ+8HxhKJ4eUali6xlKOHos+fgusXt9iqt80MLukv+479nOum/hphX6jr4WaMi5i
         e5cb0XmeIYmmo2leo3J88LfM/IPFHwKpGC+Q1h5eiRu5K21hRriUrJau80mfO8NXT4DQ
         0RRVfzksPqRmiLKor5/pFcHYSTqFNFPQC3/qD7eb0FJq3VwOwFJB8EhoOYepYgNC3DOx
         EjVRGjiN3ySc9cYe4wVx/i1EShipG/HhO+1SCznoyZQatr3ABovQf/tMCCkzvYEsNoEr
         60BQxlHr+WsQWMK/7G5x5W/flqik3hO9hoMcEacyJFNLk5DPfFo+r2MMqJRD7P2WzS8a
         hWHg==
X-Gm-Message-State: AJcUukfjL+3kiKV4kJ7iOKieCKbgYJ5R/YWXXkhCVXwwijHMgcQB5T9R
	vEkR2kLwExGC2gve97tqJmXpWO59qjtdT84cjcukZime3kdDJOWyrf68ZRi7UTK3ctyg5mseGc0
	HeQSRkKTxI3/obyV8/rTBUWjhUPxrl0DLN1Pxpn9Af+JuSFSu/7nqFUQYRkIbbvVIGHSPkidbUX
	J/RQ7F0LRpFhxKL1CfLY80ljpkTRCVnAT8FkEi6ERAVPcys7IhdiXU0bt04rE1OvkGctOgr39Z/
	Jmlb3YASlgEKlUfpJDdBQHSmiKN+pobynZ0yPH7iT7NbqIZT2+vBChOG3M5/p6HgnL5tGJH+oAS
	5XQ9Zpuqj2VbF1jJw0QVX3kjKrbgQQbTbeR0ENjISuFKtdpHrw6ES/UxGcIKAXmHVOfcZk2GDKK
	F
X-Received: by 2002:a62:c101:: with SMTP id i1mr32097851pfg.80.1548883429598;
        Wed, 30 Jan 2019 13:23:49 -0800 (PST)
X-Received: by 2002:a62:c101:: with SMTP id i1mr32097825pfg.80.1548883428804;
        Wed, 30 Jan 2019 13:23:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548883428; cv=none;
        d=google.com; s=arc-20160816;
        b=OsAVZn3Z8XOZM0fGR8aBGcDP8U0Rhj9ZbGkbxaXfrSlM3GTDtIwhVnc6ATDKHak+/q
         oVrFBffiS/TVWCAUEIeAj1QcoBR77WsOfcAtJ6EhjoqT/myRM6mpK9eunA9Uap6kVv7s
         IJiDodk4p+wW+DaMmPDQj9mIZmg2TdOhTAz6Q8vV9VF1S4syEMqfuSql4guSziW9N0fU
         cl2efHohCPv3VIgOYeOK3T20VKu8DnbRfNpiLPqCXKCFV9JkvHdY4QZFUNVruLSVfXqv
         f81mxeyF32j8o73C3JW3YYvfRNSsrrarAKbMpG9pq71LciFnT3bEhuKvP0K3927oLLZf
         8Q9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tM1a7yhYhXG8s2eHu7gjDoFR8t2UkuoCVZDqriCJf6c=;
        b=CvDL+FELJemOtw0Nk+HojPuKMzQxY+6LtiHfDc7MMLbOckZ/jOe0ASfIzCoEaIc0YP
         aulrRUuvIE/OeIgFwTJr+vxjSYxeQLIV3+SuSxUd38q6wB58MtnYNVTywTesMCXqyfLb
         CIwem+M9Vp2LHKjJddKhDTQk98twHpOoBv6PV7vKgPgwwrFyvT84SEZwTVOueLPwPMMg
         brbKdLL9+be3WowohqWhEchzjr2zIjGMxVmES5s03kogBDSvz6Ai/XyA4bFFPA+CPETH
         S5p+glYsiCQyle00Rz2z3/cE/c0yFg58cTkNsIcrBw974xSGU6RvFzb0Z3S8l5u4H6x/
         zTEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="Vvy/No3s";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m5sor4050643pls.2.2019.01.30.13.23.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 13:23:48 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="Vvy/No3s";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=tM1a7yhYhXG8s2eHu7gjDoFR8t2UkuoCVZDqriCJf6c=;
        b=Vvy/No3sw31vQD3I9jcNt9+VntbVJxy8nxBhPB1q9IsDkCHkoGmYXYA1wxh64pInyO
         okonii/1K5yqLrKgPWv8ovfByVep2L3MUNXKTaY18gsq1js0OHUwjg6ZjHqUozMbBzxy
         bhbZZKIEn2j9IVC7SL07rEnfkUpgRJ2c9f3o3PKBm7ys30OF2mr51PuxZtRMwhWOQSnn
         30iYtAVyQhnHtbI2/dPvI4Z/nledSZ5nC5Vm3YVa/mfMXnyWorxM+zy0WWN/V7cClM5O
         WGeTv6pmzwxFCixMewEqWVnZSHb5jBeSGv6MwCszVnGtgP663PXHvQlR6FNmmxzOSnjp
         iz4A==
X-Google-Smtp-Source: ALg8bN5au/zaPAMq+H2kGMZ8j5Im9MWm614jRrv2lw9bwcqCVnORAOcUmJlEaPmIwlRVFJVF0PhAYg==
X-Received: by 2002:a17:902:8d95:: with SMTP id v21mr32029794plo.162.1548883428287;
        Wed, 30 Jan 2019 13:23:48 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id z9sm8093420pfd.99.2019.01.30.13.23.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 13:23:47 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1goxKk-0006QL-O8; Wed, 30 Jan 2019 14:23:46 -0700
Date: Wed, 30 Jan 2019 14:23:46 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Joel Nider <JOELN@il.ibm.com>
Cc: Doug Ledford <dledford@redhat.com>, Leon Romanovsky <leon@kernel.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, linux-rdma-owner@vger.kernel.org,
	Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 5/5] RDMA/uverbs: add UVERBS_METHOD_REG_REMOTE_MR
Message-ID: <20190130212346.GD17066@ziepe.ca>
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
 <1548768386-28289-6-git-send-email-joeln@il.ibm.com>
 <20190129170406.GD10094@ziepe.ca>
 <OF8090F111.AEB0B591-ONC2258392.002E4215-C2258392.002F0FDE@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF8090F111.AEB0B591-ONC2258392.002E4215-C2258392.002F0FDE@notes.na.collabserv.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:34:02AM +0200, Joel Nider wrote:
> linux-rdma-owner@vger.kernel.org wrote on 01/29/2019 07:04:06 PM:
> 
> > On Tue, Jan 29, 2019 at 03:26:26PM +0200, Joel Nider wrote:
> > > Add a new handler for new uverb reg_remote_mr. The purpose is to 
> register
> > > a memory region in a different address space (i.e. process) than the
> > > caller.
> > > 
> > > The main use case which motivated this change is post-copy container
> > > migration. When a migration manager (i.e. CRIU) starts a migration, it
> > > must have an open connection for handling any page faults that occur
> > > in the container after restoration on the target machine. Even though
> > > CRIU establishes and maintains the connection, ultimately the memory
> > > is copied from the container being migrated (i.e. a remote address
> > > space). This container must remain passive -- meaning it cannot have
> > > any knowledge of the RDMA connection; therefore the migration manager
> > > must have the ability to register a remote memory region. This remote
> > > memory region will serve as the source for any memory pages that must
> > > be copied (on-demand or otherwise) during the migration.
> > > 
> > > Signed-off-by: Joel Nider <joeln@il.ibm.com>
> > >  drivers/infiniband/core/uverbs_std_types_mr.c | 129 
> +++++++++++++++++++++++++-
> > >  include/rdma/ib_verbs.h                       |   8 ++
> > >  include/uapi/rdma/ib_user_ioctl_cmds.h        |  13 +++
> > >  3 files changed, 149 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/drivers/infiniband/core/uverbs_std_types_mr.c b/drivers/
> > infiniband/core/uverbs_std_types_mr.c
> > > index 4d4be0c..bf7b4b2 100644
> > > +++ b/drivers/infiniband/core/uverbs_std_types_mr.c
> > > @@ -150,6 +150,99 @@ static int 
> UVERBS_HANDLER(UVERBS_METHOD_DM_MR_REG)(
> > >     return ret;
> > >  }
> > > 
> > > +static int UVERBS_HANDLER(UVERBS_METHOD_REG_REMOTE_MR)(
> > > +   struct uverbs_attr_bundle *attrs)
> > > +{
> > 
> > I think this should just be REG_MR with an optional remote PID
> > argument
> 
> Maybe I missed something.  Isn't REG_MR only implemented as a write() 
> command? In our earlier conversation you told me all new commands must be 
> implemented as ioctl() commands.

Yes - but we are also converting old write() commands into ioctl()
when they need new functionality. So in this case it should convert
reg_mr to ioctl() then add an optional report PID argument
> 
> > >  DECLARE_UVERBS_NAMED_OBJECT(
> > >     UVERBS_OBJECT_MR,
> > >     UVERBS_TYPE_ALLOC_IDR(uverbs_free_mr),
> > >     &UVERBS_METHOD(UVERBS_METHOD_DM_MR_REG),
> > >     &UVERBS_METHOD(UVERBS_METHOD_MR_DESTROY),
> > > -   &UVERBS_METHOD(UVERBS_METHOD_ADVISE_MR));
> > > +   &UVERBS_METHOD(UVERBS_METHOD_ADVISE_MR),
> > > +   &UVERBS_METHOD(UVERBS_METHOD_REG_REMOTE_MR),
> > > +);
> > 
> > I'm kind of surprised this compiles with the trailing comma?
> Personally, I think it is nicer with the trailing comma. Of course 
> syntactically it makes no sense, but when adding a new entry, you don't 
> have to touch the previous line, which makes the diff cleaner. If this is 
> against standard practices I will remove the comma.

Well, it is just that this is a macro call, and you usually can't have
a trailing comma in a function-macro call, at least I thought this was
the case.. Without some study I'm not sure what it expands to, or if
that expansion is even OK..

Jason

