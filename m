Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F982C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 23:29:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3F3520B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 23:29:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3F3520B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76E406B0008; Wed, 12 Jun 2019 19:29:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71EAA6B000E; Wed, 12 Jun 2019 19:29:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60DAC6B0010; Wed, 12 Jun 2019 19:29:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD566B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 19:29:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z10so12411277pgf.15
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 16:29:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=V6zGvrMDnzilhUeIz1VJFNtcRt5mHGENylPYXUDNJmc=;
        b=CA2DcX9cRsoJ/Mf/k8W2R6AP9trKo5ViyjAPsEmKz+RJkg7cTVWaf7ja98C5SwrDkj
         zoIo1s4tDqvDR1J/mqaebGyP7p66ML8RC2fbzO3/imlpLwMA/NXGuQAV3UWi0zolnDrl
         4mMGohPycsfLDhl8w1hXenqHTi7jdxgSZSe3G5g9TMHJOLshPjR+/v+cXl67YIp1bba8
         xIFGTJaBZ8geevoLyq0IkZtJ/yV6df/2uDygsrEq6vzlO4cNtLvS1vvpu7XXbaWZ0bEv
         zV4bZcBR60mYjEP8t9GKkmILZGMSedbqDeIWc5PEw0eScdOh4Q3Vet5rJbZHjX1kM0/8
         Je8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU+jWxmZzF6nDHoJ1fk5YMy+VKzd/YEhUwydKaNwaf9cF5LTSBt
	+oJK9tW0k4VoOzvndFyDDHytqs7v96KqleVIh97aZ2oPVCUiUvLJ0WQkTdW9Sdc5ukcY5nn9f+d
	E6ofOxlWfk3U12oq3mNQqh3R7aAvLyX2IzQQVgVblF3ZYHfz6RFLmKZ6VBD8nIu1+mQ==
X-Received: by 2002:a17:90a:a00d:: with SMTP id q13mr1662563pjp.80.1560382145806;
        Wed, 12 Jun 2019 16:29:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyim7tFqouiNTrHAUt914Pe84FhbuOXs9pTQ/UHAvMcohMwPKFt1dmPGeAERBCkA4TZOG5K
X-Received: by 2002:a17:90a:a00d:: with SMTP id q13mr1662510pjp.80.1560382144927;
        Wed, 12 Jun 2019 16:29:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560382144; cv=none;
        d=google.com; s=arc-20160816;
        b=I2KNPwny15y2YF5qclsQZ7Y545WcKbNZJ3W0gOo99SYIIFPQq8iiHPcZSSv8zf480t
         ukkcjg6akhdJgljln1I2JnUOCXCCfvXsh2VWm8glFAP0kROKAAmXcSenYzQ3RLdAbtnk
         BBxVMkKP/dSJwonBULCj4hqz14H6eGy95iH0YNxGZJOL5yRAwSwEK52/3ExaQWUBfITp
         RvIle5VDVVtYMhxRcN7DhASAxAA6LXYJPzjvoDmiXzDT3OQ0nB16XrEwG33cJB4pKue3
         iSFxCsl4esZ2Ft/YpX4RFqxUR2Il3XWcBnVF8C2ZmTgkeVwU6HdB2R1VC5cVgNRjZUuU
         AOng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=V6zGvrMDnzilhUeIz1VJFNtcRt5mHGENylPYXUDNJmc=;
        b=N5mZnIBF3/22ja37W9mv081WnCliCmcUqKRxqP+c/yVlN07nA5gLJFsDyZlJMCiENt
         xOKMqv0fRNPNoJu/AYDEuRFPApCuzRNPzsEU9dAnhAnr9MMEfQOR/8LbemMWlzaWbsGS
         xAQEOgj+c/6Xc5h0H4O5ts67MK934H3jsvHmxtqoh9NREkCEXLnFeP+zN7z/NMJEV+sw
         uvSW65G4gjbYKbAsX3XvUwU4mN3gYvLJH3jOCrGtfNdsQPYSDPY/IJlAIAVB58rg7CnC
         4osizwKTCPh/zmQF9Ug7f0UzQ3HKLCHKwtdqSzsFgroGAsfGUHYMhiZVVBkHUwr/e3zp
         SP6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 11si1008453pgk.422.2019.06.12.16.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 16:29:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jun 2019 16:29:04 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 12 Jun 2019 16:29:03 -0700
Date: Wed, 12 Jun 2019 16:30:24 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190612233024.GD14336@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612123751.GD32656@bombadil.infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> On Sat, Jun 08, 2019 at 10:10:36AM +1000, Dave Chinner wrote:
> > On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> > > Are you suggesting that we have something like this from user space?
> > > 
> > > 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);
> > 
> > Rather than "unbreakable", perhaps a clearer description of the
> > policy it entails is "exclusive"?
> > 
> > i.e. what we are talking about here is an exclusive lease that
> > prevents other processes from changing the layout. i.e. the
> > mechanism used to guarantee a lease is exclusive is that the layout
> > becomes "unbreakable" at the filesystem level, but the policy we are
> > actually presenting to uses is "exclusive access"...
> 
> That's rather different from the normal meaning of 'exclusive' in the
> context of locks, which is "only one user can have access to this at
> a time".  As I understand it, this is rather more like a 'shared' or
> 'read' lock.  The filesystem would be the one which wants an exclusive
> lock, so it can modify the mapping of logical to physical blocks.
> 
> The complication being that by default the filesystem has an exclusive
> lock on the mapping, and what we're trying to add is the ability for
> readers to ask the filesystem to give up its exclusive lock.

This is an interesting view...

And after some more thought, exclusive does not seem like a good name for this
because technically F_WRLCK _is_ an exclusive lease...

In addition, the user does not need to take the "exclusive" write lease to be
notified of (broken by) an unexpected truncate.  A "read" lease is broken by
truncate.  (And "write" leases really don't do anything different WRT the
interaction of the FS and the user app.  Write leases control "exclusive"
access between other file descriptors.)

Another thing to consider is that this patch set _allows_ a truncate/hole punch
to proceed _if_ the pages being affected are not actually pinned.  So the
unbreakable/exclusive nature of the lease is not absolute.

Personally I like this functionality.  I'm not quite sure I can make it work
with what Jan is suggesting.  But I like it.

Given the muddied water of "exclusive" and "write" lease I'm now feeling like
Jeff has a point WRT the conflation of F_RDLCK/F_WRLCK/F_UNLCK and this new
functionality.

Should we use his suggested F_SETLAYOUT/F_GETLAYOUT cmd type?[1]

Ira

[1] https://lkml.org/lkml/2019/6/9/117

