Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 632D6C28EB7
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:21:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32B212083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:21:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32B212083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C09FD6B02F6; Thu,  6 Jun 2019 18:21:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBC3D6B02F8; Thu,  6 Jun 2019 18:21:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA9036B02F9; Thu,  6 Jun 2019 18:21:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 745236B02F6
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 18:21:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d125so12324pfd.3
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 15:21:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+pK7fGhrD1AruNZFiTjkgjjNqn2cpwdAwygAzVGmzHc=;
        b=CoF45zPeC8KiNZPl3TJon6DESi3oGw13YYdvgyYEKK/OSHrHIh7/Dr7LJNB3N12f/g
         pwfH6Kq/VvCfSLA0PC3KSpeRnEhVznhmF9QE8qH/lGkhuchhPDdE+ApixBXeIT+1P1J8
         Jh87EjdW77bM14UuIJnk9F9wIBrJNPh59y/YTk5D2EwjHdytvl/Llo3e4QB8rIPi6IZ2
         dvgShxhOZxJiuyX8iR/OMHzF7sRhTkiBRHC3rq/RA7o9V7TvmEwZOraZNL11bcEM6Is3
         gn/8NGBt949pW9NeYe16QXcfiSrUVnOZyDMFZFKadBNY1xhWqOU4hXlrLmTxX8ZamG+z
         t1Yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXA4kw2RC4nNPNg8yYkb+eyaFGLFU0QrrTuIdPx7pMMReakKdMH
	y806ybhQH9++bj+HPMGF4y+0iVf3l3O/HF3tKJcUVFO0VgOgjYWtDziADaR02t8pDMU+sMmt0qt
	aGYkJELk1rh2E964BiN3mcQ/ybCKoHomrhCZJ82JcyAZE5S7CpF83lQIMilg+lE9gdQ==
X-Received: by 2002:a63:5457:: with SMTP id e23mr53350pgm.307.1559859678059;
        Thu, 06 Jun 2019 15:21:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2ZYhpL6hHoREU5Lo6xUmvRZ86FaqbdK0XvecDOFg1pSXecAQLYRcuIBPT8vIgLOP/L48s
X-Received: by 2002:a63:5457:: with SMTP id e23mr53296pgm.307.1559859677079;
        Thu, 06 Jun 2019 15:21:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559859677; cv=none;
        d=google.com; s=arc-20160816;
        b=PyzsWPksBOmMTYUVaSSnb5vpKZ0OymQRJnb6mMo6Ng0WxzWSSyKblduRnycjxE3t7T
         jFm5GjrQiilh9POqy8oMzSIlrJdUJUcPWeKbs2BucwrX4kNRzuk4j5q+ZvK1leM1gzYy
         0kTGZY83+AmREo0iOXEses0yUq7GyubhlIVViMMQC1EE2MDDV/QQHJWDHfC+4TgbZQ5b
         c+1G2poKWANh8m1RMNK/O0ka4/MiA1zD8/aiVZIr0D4bsqzlJUr1CfQUMMhQkYl/g+Pt
         zZRKlx6IYQB+5ot9D5Tjb2irpJgiWNHnmHHbVLitt5+sCDqIeiv7Tx7tLR54MLnBdjp3
         oNfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+pK7fGhrD1AruNZFiTjkgjjNqn2cpwdAwygAzVGmzHc=;
        b=odOjK4a4Q9d2hl5L9+PNGsy2R7jeNHvncUQqdTnwHznN+eqIPCrBMoA7urL6y3YOol
         sBE+GmidfY3s9chhdrhfwfkdd1q2qg1mUazwhKym97mfLgZj+51M1vqJlSgXJgkVEnXw
         MODnOm678GhUVD7lHOjT03WwKPMljDgLk4YfPZLz/JRd84CMjH6e35DP06De4mztYQA7
         pz7LH80LkuobZTW7KB2TEkt08UyBysw4Ks/Mrit9SdpB5FPbiPkDzmSYlq/QNjQMnKQM
         zkQVrIIAuWadb3lfiSIJRS50DKlIWXAtj3LfGgqVBlvS/kOATQKhoa6U9Bg2kRmNDdhx
         EBXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id u188si149416pfu.228.2019.06.06.15.21.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 15:21:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 15:21:16 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,560,1557212400"; 
   d="scan'208";a="182472132"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga002.fm.intel.com with ESMTP; 06 Jun 2019 15:21:16 -0700
Date: Thu, 6 Jun 2019 15:22:28 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
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
Message-ID: <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606195114.GA30714@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 04:51:15PM -0300, Jason Gunthorpe wrote:
> On Thu, Jun 06, 2019 at 12:42:03PM +0200, Jan Kara wrote:
> 
> > So I'd like to actually mandate that you *must* hold the file lease until
> > you unpin all pages in the given range (not just that you have an option to
> > hold a lease). And I believe the kernel should actually enforce this. That
> > way we maintain a sane state that if someone uses a physical location of
> > logical file offset on disk, he has a layout lease. Also once this is done,
> > sysadmin has a reasonably easy way to discover run-away RDMA application
> > and kill it if he wishes so.
> > 
> > The question is on how to exactly enforce that lease is taken until all
> > pages are unpinned. I belive it could be done by tracking number of
> > long-term pinned pages within a lease. Gup_longterm could easily increment
> > the count when verifying the lease exists, gup_longterm users will somehow
> > need to propagate corresponding 'filp' (struct file pointer) to
> > put_user_pages_longterm() callsites so that they can look up appropriate
> > lease to drop reference - probably I'd just transition all gup_longterm()
> > users to a saner API similar to the one we have in mm/frame_vector.c where
> > we don't hand out page pointers but an encapsulating structure that does
> > all the necessary tracking. Removing a lease would need to block until all
> > pins are released - this is probably the most hairy part since we need to
> > handle a case if application just closes the file descriptor which
> > would
> 
> I think if you are going to do this then the 'struct filp' that
> represents the lease should be held in the kernel (ie inside the RDMA
> umem) until the kernel is done with it.

Yea there seems merit to this.  I'm still not resolving how this helps track
who has the pin across a fork.

> 
> Actually does someone have a pointer to this userspace lease API, I'm
> not at all familiar with it, thanks

man fcntl
	search for SETLEASE

But I had to add the F_LAYOUT lease type.  (Personally I'm for calling it
F_LONGTERM at this point.  I don't think LAYOUT is compatible with what we are
proposing here.)

Anyway, yea would be a libc change at lease for man page etc...  But again I
want to get some buy in before going through all that.

> 
> And yes, a better output format from GUP would be great..
> 
> > Maybe we could block only on explicit lease unlock and just drop the layout
> > lease on file close and if there are still pinned pages, send SIGKILL to an
> > application as a reminder it did something stupid...
> 
> Which process would you SIGKILL? At least for the rdma case a FD is
> holding the GUP, so to do the put_user_pages() the kernel needs to
> close the FD. I guess it would have to kill every process that has the
> FD open? Seems complicated...

Tending to agree...  But I'm still not opposed to killing bad actors...  ;-)

NOTE: Jason I think you need to be more clear about the FD you are speaking of.
I believe you mean the FD which refers to the RMDA context.  That is what I
called it in my other email.

Ira

> 
> Regards,
> Jason

