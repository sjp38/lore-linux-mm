Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FE3DC28CC5
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 01:28:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D49092166E
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 01:28:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D49092166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BF816B0006; Sat,  8 Jun 2019 21:28:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 248FA6B0007; Sat,  8 Jun 2019 21:28:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C3C26B0008; Sat,  8 Jun 2019 21:28:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C54446B0006
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 21:28:19 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id c3so3596581plr.16
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 18:28:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fgUGWL6gPuR5qoG1fTbkNeKvO2wHby0y2k8K674mQOc=;
        b=GmY1uYSfBNvLD7cbJGZr7zZ+DbwXwp/tyOytHHoiqRWacV76AiXc5UBGliv0VOg+SD
         k5+fcJSzeIzS6E6Qz3q2rzZ00yR+hphyV1O4d1g6a3flCj6ZnBx1s0VlP/MB1pRwuMvL
         A4p66TyTK1U+SNJtF/HWPFf2INuC9TjVuFv+D8zuh6pti7GKGpyleGglW1BLoSs4cq+e
         uVCIQd/D5InnWOh//ITQP1nJh4EDmyqoiySqb48eOEDAQU9dzmvynJVZleTxBth93+FN
         JfYPUET4xTt5cjobVeY6uWy6UASGB5+1Ulv8QBZ6wKGXmWjFQl2PAKq9kaL771vTgKCr
         Wt9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUWlS4MnoPUg498io5tPS7JlH5RmIvCdn/T1fZW7YsWIg3FFSp5
	XcieAXXVXCHgTHyvqNBBJ080UjeYzXrx8KJevz9Pj/UujGmnzdAPxMKFEL6O6um16g+XN7vIcD6
	AY7lhJrDUxHGeSPwCV2/6ErVQanBLZ3nUleV+Qi9rSgqdwZJgCTCWcow0T8knPJnMfw==
X-Received: by 2002:a17:902:b495:: with SMTP id y21mr62705743plr.243.1560043699341;
        Sat, 08 Jun 2019 18:28:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoCAUQZIYJNxC6KmZ96h4PijwVK8J52Vt5NC5uaufgriVI5za8x6JDIIi9yFOza1Db0cNW
X-Received: by 2002:a17:902:b495:: with SMTP id y21mr62705690plr.243.1560043698154;
        Sat, 08 Jun 2019 18:28:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560043698; cv=none;
        d=google.com; s=arc-20160816;
        b=I45yPkNucRIDjexgvROez8HjgQsEOTf714ZqF1Ojim8S0I55Wq7XE+tKbnUhOkmE+x
         H6cfWZYh/TABe3rg8veMqXE8yARBHzjYQc9cCBtL+yrR8Yz0969H7esej6ExxuZsW8Bb
         0VWNwG9BqJGXBNfAG0Nxws7j38/Jm/am6vVF/xF2n9sgbb4Xhgl6T0x8829hri1qbDPi
         E1jWS9iDFGZPdSR6anJzjZ9GnNzA9drz/2ACcuHTUPuLlaCZZvvnkbzZ88XhgmKNtlUq
         OUZ3h3WW2XAbul3pFnRaJP7QCUwcOFccrRHkMREFQkFC3L4bhboM1+LulFoxXSDuofhG
         r6gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fgUGWL6gPuR5qoG1fTbkNeKvO2wHby0y2k8K674mQOc=;
        b=xZqv3o8fsU7AN8pycCYlq3ysgea2rt7seTtYZP7rT77reyaWjHbpooPtTsQ33uH2IN
         S9CUtvHzl6Vqj8BsmO68z8fsyaJZSuio6khRmEaEDJzwbHtPcI6tEvObopgL+v3ORB6H
         Env+4+SL9GmKLvNvHtTe/3tOSFt83QUWqeAyItU1RggK8tlxHQ/tr8o3/xqngXtDO9AG
         dC+fVoWUG4W11T4eMpCpHTSvAfOQqvOuRiIRrLRp8eari+BnKJudyxTMmGnvBhJKAKA2
         viFk1Wtvq1/NWQJ8WmqMGaPWQ2T4W0mcyj9ShS9aJaCmJI1K66Iwk3xZm3vXi8ZmqvwC
         8Ugg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t15si5728344pjw.97.2019.06.08.18.28.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Jun 2019 18:28:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Jun 2019 18:28:16 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 08 Jun 2019 18:28:16 -0700
Date: Sat, 8 Jun 2019 18:29:32 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190609012931.GA19825@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190608001036.GF14308@dread.disaster.area>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 08, 2019 at 10:10:36AM +1000, Dave Chinner wrote:
> On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> > On Fri, Jun 07, 2019 at 01:04:26PM +0200, Jan Kara wrote:
> > > On Thu 06-06-19 15:03:30, Ira Weiny wrote:
> > > > On Thu, Jun 06, 2019 at 12:42:03PM +0200, Jan Kara wrote:
> > > > > On Wed 05-06-19 18:45:33, ira.weiny@intel.com wrote:
> > > > > > From: Ira Weiny <ira.weiny@intel.com>
> > > > > 
> > > > > So I'd like to actually mandate that you *must* hold the file lease until
> > > > > you unpin all pages in the given range (not just that you have an option to
> > > > > hold a lease). And I believe the kernel should actually enforce this. That
> > > > > way we maintain a sane state that if someone uses a physical location of
> > > > > logical file offset on disk, he has a layout lease. Also once this is done,
> > > > > sysadmin has a reasonably easy way to discover run-away RDMA application
> > > > > and kill it if he wishes so.
> > > > 
> > > > Fair enough.
> > > > 
> > > > I was kind of heading that direction but had not thought this far forward.  I
> > > > was exploring how to have a lease remain on the file even after a "lease
> > > > break".  But that is incompatible with the current semantics of a "layout"
> > > > lease (as currently defined in the kernel).  [In the end I wanted to get an RFC
> > > > out to see what people think of this idea so I did not look at keeping the
> > > > lease.]
> > > > 
> > > > Also hitch is that currently a lease is forcefully broken after
> > > > <sysfs>/lease-break-time.  To do what you suggest I think we would need a new
> > > > lease type with the semantics you describe.
> > > 
> > > I'd do what Dave suggested - add flag to mark lease as unbreakable by
> > > truncate and teach file locking core to handle that. There actually is
> > > support for locks that are not broken after given timeout so there
> > > shouldn't be too many changes need.
> > >  
> > > > Previously I had thought this would be a good idea (for other reasons).  But
> > > > what does everyone think about using a "longterm lease" similar to [1] which
> > > > has the semantics you proppose?  In [1] I was not sure "longterm" was a good
> > > > name but with your proposal I think it makes more sense.
> > > 
> > > As I wrote elsewhere in this thread I think FL_LAYOUT name still makes
> > > sense and I'd add there FL_UNBREAKABLE to mark unusal behavior with
> > > truncate.
> > 
> > Ok I want to make sure I understand what you and Dave are suggesting.
> > 
> > Are you suggesting that we have something like this from user space?
> > 
> > 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);
> 
> Rather than "unbreakable", perhaps a clearer description of the
> policy it entails is "exclusive"?
> 
> i.e. what we are talking about here is an exclusive lease that
> prevents other processes from changing the layout. i.e. the
> mechanism used to guarantee a lease is exclusive is that the layout
> becomes "unbreakable" at the filesystem level, but the policy we are
> actually presenting to uses is "exclusive access"...

That sounds good.

Ira

> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

