Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D999FC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:29:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F041207E0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:29:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F041207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 264FE6B0003; Wed, 12 Jun 2019 06:29:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 215B36B0005; Wed, 12 Jun 2019 06:29:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DE326B0008; Wed, 12 Jun 2019 06:29:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B162C6B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 06:29:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l53so25220513edc.7
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:29:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AjAoi1FVinP3MMsi4fyWg8Tzng4Y4A1sEmlZAtaX5Pw=;
        b=Qn5ouywo27XbpcyIBu2bg7kdZd7e8VVkCs+sg1XTrLSrgyZ4C3dF9i8M604v2BxhEX
         5Zpa43nc5T3XqjNLl161hlzQdMo1XG7mFpIlYSH/THPusARIQJl/J6l/kouBWECTf95P
         Xxcdf/szq9c068NH+OHSg7eI5S4B4yLoTQ0YeYorlhtILc8YmS4+a3UAs7Pg2ktzkryT
         BgOW4i39cTadso9NCbHdY9+IMfLKa8+n8lgKU/vzSbjGQ7AskNvWSOFp6q2f5xGyPqVD
         Ib21AgF06i7IgiQJ3Xjx2H6Es3g6nUsoCoNkgkp+YdtYXN0pZL6IP9oLKAZXXJFgOQ42
         cqfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUkBBWMlY3L8JSlLR0e6AdSXObJfEmRJI00yaT8b+dyi1BhvCgD
	98ogkzA/lrO2dKW1CfGpkUjWP/dOcACllJTKvFK3nyvd3aZvPR++UFp/fVY27SkwkETwyXVr6mE
	lepB+wtRQxZ460yb+eY3dl24bWQAkVKH/hbdGDoJ1V/BOZgL0mmt0t4p4HbOF40hc+A==
X-Received: by 2002:a50:fc18:: with SMTP id i24mr22437121edr.249.1560335361270;
        Wed, 12 Jun 2019 03:29:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzL/tt9+aSWbZTuJl8dkJFzqHq9Y/2/QF5m+xi/CiilvXTMMf16AJLTgW4jDPavvFx08ApY
X-Received: by 2002:a50:fc18:: with SMTP id i24mr22437032edr.249.1560335360112;
        Wed, 12 Jun 2019 03:29:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560335360; cv=none;
        d=google.com; s=arc-20160816;
        b=kCWXVNb6VKrlEj0KXwagIOrCyDi266jQZnBuBrHI4MATSXnja+T08q6LF4tdQ5jgHi
         U1NNjjkyIrJggVI4rjU+/ewhZhs64n14GyDnYlX2pWZ6iRGnchktJP5B3tsXw7a1t9Wy
         RrgwjJdnAyC8qwthTxFbQXlYb5k6k5xSXCYyiCVQj6HnhNCO+PySXLLwv131wTiHDpkp
         aCR4mWG9koSbdXYwY6TUVvnvY6O4nAk3hm6oXfHxxU27uOSp/loqk7yK2dSboi1WFlXk
         9Cd3993LVfr1qqoLa4GnrH5bwDwwLuOlQuG5vo35ttT/AU54Jj7IdoNW32ZDx0L4/mfu
         SQYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AjAoi1FVinP3MMsi4fyWg8Tzng4Y4A1sEmlZAtaX5Pw=;
        b=j+g88D+e8oLeXZwoferWq8AXowgwqYEgwt+ef5azt0WtyVzIU97iYO6NYVZ0C+Hoeh
         Fy3+vJMxUnXnvRlVLBzG0hLWMINBr55XLYFsX6TGYZH5P9qAAa2iDHGTlgYlo2fpBc4Q
         2uGN8ZBNmxQCYAratDbmrykqzGZT6TP9r6ajS0FRe5+NdDEchAnrMBBEByAuy6iyDLf4
         HvnHxBN2p9cugonIlgxo/eNCbj6NOf8Ex+d2iOn5vUUyDafaGDQh4MM7wVtBW1RpgUkx
         W+TW5gg2RIThYBfiLxgHDJC6yOyDvg+medD3FrJksC0iA0IL5oOd230Pjt1QhaG7Yl0I
         Tvmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10si3567764edb.340.2019.06.12.03.29.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 03:29:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 16DA0AE07;
	Wed, 12 Jun 2019 10:29:19 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id BA8661E4328; Wed, 12 Jun 2019 12:29:17 +0200 (CEST)
Date: Wed, 12 Jun 2019 12:29:17 +0200
From: Jan Kara <jack@suse.cz>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190612102917.GB14578@quack2.suse.cz>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 07-06-19 07:52:13, Ira Weiny wrote:
> On Fri, Jun 07, 2019 at 09:17:29AM -0300, Jason Gunthorpe wrote:
> > On Fri, Jun 07, 2019 at 12:36:36PM +0200, Jan Kara wrote:
> > 
> > > Because the pins would be invisible to sysadmin from that point on. 
> > 
> > It is not invisible, it just shows up in a rdma specific kernel
> > interface. You have to use rdma netlink to see the kernel object
> > holding this pin.
> > 
> > If this visibility is the main sticking point I suggest just enhancing
> > the existing MR reporting to include the file info for current GUP
> > pins and teaching lsof to collect information from there as well so it
> > is easy to use.
> > 
> > If the ownership of the lease transfers to the MR, and we report that
> > ownership to userspace in a way lsof can find, then I think all the
> > concerns that have been raised are met, right?
> 
> I was contemplating some new lsof feature yesterday.  But what I don't
> think we want is sysadmins to have multiple tools for multiple
> subsystems.  Or even have to teach lsof something new for every potential
> new subsystem user of GUP pins.

Agreed.

> I was thinking more along the lines of reporting files which have GUP
> pins on them directly somewhere (dare I say procfs?) and teaching lsof to
> report that information.  That would cover any subsystem which does a
> longterm pin.

So lsof already parses /proc/<pid>/maps to learn about files held open by
memory mappings. It could parse some other file as well I guess. The good
thing about that would be that then "longterm pin" structure would just hold
struct file reference. That would avoid any needs of special behavior on
file close (the file reference in the "longterm pin" structure would make
sure struct file and thus the lease stays around, we'd just need to make
explicit lease unlock block until the "longterm pin" structure is freed).
The bad thing is that it requires us to come up with a sane new proc
interface for reporting "longterm pins" and associated struct file. Also we
need to define what this interface shows if the pinned pages are in DRAM
(either page cache or anon) and not on NVDIMM.

> > > ugly to live so we have to come up with something better. The best I can
> > > currently come up with is to have a method associated with the lease that
> > > would invalidate the RDMA context that holds the pins in the same way that
> > > a file close would do it.
> > 
> > This is back to requiring all RDMA HW to have some new behavior they
> > currently don't have..
> > 
> > The main objection to the current ODP & DAX solution is that very
> > little HW can actually implement it, having the alternative still
> > require HW support doesn't seem like progress.
> > 
> > I think we will eventually start seein some HW be able to do this
> > invalidation, but it won't be universal, and I'd rather leave it
> > optional, for recovery from truely catastrophic errors (ie my DAX is
> > on fire, I need to unplug it).
> 
> Agreed.  I think software wise there is not much some of the devices can do
> with such an "invalidate".

So out of curiosity: What does RDMA driver do when userspace just closes
the file pointing to RDMA object? It has to handle that somehow by aborting
everything that's going on... And I wanted similar behavior here.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

