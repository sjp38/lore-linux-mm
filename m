Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EEBEC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:24:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0634D208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:24:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0634D208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 725096B000A; Fri,  7 Jun 2019 14:24:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D5B16B000C; Fri,  7 Jun 2019 14:24:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59D736B000E; Fri,  7 Jun 2019 14:24:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 223226B000A
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:24:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a125so2056183pfa.13
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:24:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AuU/VNKf1YtvmXoEFYggZ1/lCpWn/lWad8fS25D+J4M=;
        b=rI5/+SvZwK95C4gEv0Hk2t44gJzmnSNRAKraowpbDF10e70IcpTu5PwpYB+V1Zeb9J
         B6TLftVrwFd+4jXqhSCqGqgtqm87ZNZxI2KicA9mBpRmfzgTwIhw1a7G6xucROmzl2nn
         5P4Z4S42EUySTIzvM+ubEXyXT5ffimoAz2qQgrzgKYS7sK/Gl/YRZ/60vpkGlTsZTG03
         MORRHwFcb4Cig/vNCsyZNWmiAP+TW3mga41LNs5KrjbtahE1ARZUeubKP4u/wA3PBXer
         W6D8Epelvqe2EEWGSdzLZq4yoAQCswpoGdKP1VcTssEMNsPUmkFg5VKJQNmYsS/6uIso
         gNbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUNcPp54EkgWIs64Chmj7fsCdgI5At5ZHVFLjM7FinL15C31bmP
	PCDegp2AqM2N4VYFlUbGhL5pTV4+I6PV1/KiY9dsuZlgVUYI+aCf6VF5AWl6SyLv/kDzITuDG/w
	TIXbgvxus4FluIkjnfg0GQjkOBRHkcnvTKcf295EV5voTM0K2vlLYVZ8tm3l0VDOrsQ==
X-Received: by 2002:a63:1642:: with SMTP id 2mr4228819pgw.230.1559931864653;
        Fri, 07 Jun 2019 11:24:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcx9laXtw3pjvICw/hhHD09cxOko+hQtmrioswgQyylopy8NMDQuhwlOAO1lMpjW9YEEgT
X-Received: by 2002:a63:1642:: with SMTP id 2mr4228672pgw.230.1559931862965;
        Fri, 07 Jun 2019 11:24:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559931862; cv=none;
        d=google.com; s=arc-20160816;
        b=gxnCLdxu/jPPybXlrFa8nnc9/hkUHDEovuUvV0YaTAgmgafXUmCguln5qsUwmUwE8F
         xn5uzuMOf8CBc9mjfY2ebQg5bDP+PA3jqWarY8G3BhYpEAO9ygLh2ipBs9syR1pADCKK
         Pt4ROfxBwrRxRx7FUrBFgoUce0TKD0hkoEPFYiCW7Nqdgjn4HLA49kAjAjA/z/3VOwMd
         bwToBjSo/SzWSgU8EOudBOOdS6Nn+PzWntcf5AX2kZj8pb5pN8CHaJOlTOILMXcSPtF6
         00N1SOU2Eje0UrirgrvlvVeBqFUICjszCeDv6qC0uY1GOrUpG26MA1BuBj6BD2HtQQfv
         yBMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AuU/VNKf1YtvmXoEFYggZ1/lCpWn/lWad8fS25D+J4M=;
        b=tixIZ5pGfzD951RvEI5OY4J7+T5v1bkn+3OExZKP0TyKXKue5GXuRo5xTYTamSAeyz
         9SYBj2/bSVXCQpq1YCQZenFQmOI4eOhn9qhi4WhclT8dQ9MRenGADGrAmISVHguL0gVW
         ftlep+BftX+ZIi+FaBv0BxC3mKTUckT2XGVXswpMb1OMq+uRYiCVKTQaSW4nDpaZjFdS
         pNX5om8jc0e4hTFDp/JNIYctQ4A4cUBsqzHFmbrXxe/CNWZovJn5UdOyTM8e1frHbHAV
         AlC8wzNQPJghkHIMzIrmULxfkBT+rdiUoVf1Z5FhlnfSZrty5xuQvDiiH0ZhGvEdIIjT
         fy/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h9si2653999plt.8.2019.06.07.11.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 11:24:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 11:24:21 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 07 Jun 2019 11:24:21 -0700
Date: Fri, 7 Jun 2019 11:25:35 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Theodore Ts'o <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607110426.GB12765@quack2.suse.cz>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 01:04:26PM +0200, Jan Kara wrote:
> On Thu 06-06-19 15:03:30, Ira Weiny wrote:
> > On Thu, Jun 06, 2019 at 12:42:03PM +0200, Jan Kara wrote:
> > > On Wed 05-06-19 18:45:33, ira.weiny@intel.com wrote:
> > > > From: Ira Weiny <ira.weiny@intel.com>
> > > 
> > > So I'd like to actually mandate that you *must* hold the file lease until
> > > you unpin all pages in the given range (not just that you have an option to
> > > hold a lease). And I believe the kernel should actually enforce this. That
> > > way we maintain a sane state that if someone uses a physical location of
> > > logical file offset on disk, he has a layout lease. Also once this is done,
> > > sysadmin has a reasonably easy way to discover run-away RDMA application
> > > and kill it if he wishes so.
> > 
> > Fair enough.
> > 
> > I was kind of heading that direction but had not thought this far forward.  I
> > was exploring how to have a lease remain on the file even after a "lease
> > break".  But that is incompatible with the current semantics of a "layout"
> > lease (as currently defined in the kernel).  [In the end I wanted to get an RFC
> > out to see what people think of this idea so I did not look at keeping the
> > lease.]
> > 
> > Also hitch is that currently a lease is forcefully broken after
> > <sysfs>/lease-break-time.  To do what you suggest I think we would need a new
> > lease type with the semantics you describe.
> 
> I'd do what Dave suggested - add flag to mark lease as unbreakable by
> truncate and teach file locking core to handle that. There actually is
> support for locks that are not broken after given timeout so there
> shouldn't be too many changes need.
>  
> > Previously I had thought this would be a good idea (for other reasons).  But
> > what does everyone think about using a "longterm lease" similar to [1] which
> > has the semantics you proppose?  In [1] I was not sure "longterm" was a good
> > name but with your proposal I think it makes more sense.
> 
> As I wrote elsewhere in this thread I think FL_LAYOUT name still makes
> sense and I'd add there FL_UNBREAKABLE to mark unusal behavior with
> truncate.

Ok I want to make sure I understand what you and Dave are suggesting.

Are you suggesting that we have something like this from user space?

	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);

> 
> > > - probably I'd just transition all gup_longterm()
> > > users to a saner API similar to the one we have in mm/frame_vector.c where
> > > we don't hand out page pointers but an encapsulating structure that does
> > > all the necessary tracking.
> > 
> > I'll take a look at that code.  But that seems like a pretty big change.
> 
> I was looking into that yesterday before proposing this and there aren't
> than many gup_longterm() users and most of them anyway just stick pages
> array into their tracking structure and then release them once done. So it
> shouldn't be that complex to convert to a new convention (and you have to
> touch all gup_longterm() users anyway to teach them track leases etc.).

I think in the direction we are heading this becomes more attractive for sure.
For me though it will take some time.

Should we convert the frame_vector over to this new mechanism?  (Or more
accurately perhaps, add to frame_vector and use it?)  It seems bad to have "yet
another object" returned from the pin pages interface...

And I think this is related to what Christoph Hellwig is doing with bio_vec and
dma.  Really we want drivers out of the page processing business.

So for now I'm going to move forward with the idea of handing "some object" to
the GUP callers and figure out the lsof stuff, and let bigger questions like
this play out a bit more before I try and work with that code.  Fair?

> 
> > > Removing a lease would need to block until all
> > > pins are released - this is probably the most hairy part since we need to
> > > handle a case if application just closes the file descriptor which would
> > > release the lease but OTOH we need to make sure task exit does not deadlock.
> > > Maybe we could block only on explicit lease unlock and just drop the layout
> > > lease on file close and if there are still pinned pages, send SIGKILL to an
> > > application as a reminder it did something stupid...
> > 
> > As presented at LSFmm I'm not opposed to killing a process which does not
> > "follow the rules".  But I'm concerned about how to handle this across a fork.
> > 
> > Limiting the open()/LEASE/GUP/close()/SIGKILL to a specific pid "leak"'s pins
> > to a child through the RDMA context.  This was the major issue Jason had with
> > the SIGBUS proposal.
> > 
> > Always sending a SIGKILL would prevent an RDMA process from doing something
> > like system("ls") (would kill the child unnecessarily).  Are we ok with that?
> 
> I answered this in another email but system("ls") won't kill anybody.
> fork(2) just creates new file descriptor for the same file and possibly
> then closes it but since there is still another file descriptor for the
> same struct file, the "close" code won't trigger.

Agreed.  I was wrong.  Sorry.

But if we can keep track of who has the pins in lsof can we agree no process
needs to be SIGKILL'ed?  Admins can do this on their own "killing" if they
really need to stop the use of these files, right?

Ira

