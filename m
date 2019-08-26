Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8952FC3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:41:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F4FB217F5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:41:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="It43Y4jh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F4FB217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE0E46B055C; Mon, 26 Aug 2019 06:41:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6B026B055D; Mon, 26 Aug 2019 06:41:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7FD56B055E; Mon, 26 Aug 2019 06:41:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0126.hostedemail.com [216.40.44.126])
	by kanga.kvack.org (Postfix) with ESMTP id 827D76B055C
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 06:41:12 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 293DC3A92
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:41:12 +0000 (UTC)
X-FDA: 75864236784.28.coach41_a6cddb475826
X-HE-Tag: coach41_a6cddb475826
X-Filterd-Recvd-Size: 4933
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:41:11 +0000 (UTC)
Received: from tleilax.poochiereds.net (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1E32920828;
	Mon, 26 Aug 2019 10:41:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566816070;
	bh=8ziD+meEXqXL5pLNd7FdOcpozYaNgK5kwHaeo4uhx28=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=It43Y4jhI4WRMT7EOX/lr7UQrAHGcp7abrKi/dW/O0Kd9egEDPpQrb9qKy1oWb9pe
	 lnOftVy2OCBwYNxuaPQUMNRvYTlPGOmE5p+KJsXKHIySHdTnGKve5YDOmGidGBo/29
	 cnTh0m+X3A/MuYbOjoz90Mp0uG6r73lbyIxhL/QI=
Message-ID: <e6f4f619967f4551adb5003d0364770fde2b8110.camel@kernel.org>
Subject: Re: [RFC PATCH v2 02/19] fs/locks: Add Exclusive flag to user
 Layout lease
From: Jeff Layton <jlayton@kernel.org>
To: Dave Chinner <david@fromorbit.com>
Cc: ira.weiny@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jason
 Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Matthew
 Wilcox <willy@infradead.org>,  Jan Kara <jack@suse.cz>, Theodore Ts'o
 <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko
 <mhocko@suse.com>, linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org
Date: Mon, 26 Aug 2019 06:41:07 -0400
In-Reply-To: <20190814215630.GQ6129@dread.disaster.area>
References: <20190809225833.6657-1-ira.weiny@intel.com>
	 <20190809225833.6657-3-ira.weiny@intel.com>
	 <fde2959db776616008fc5d31df700f5d7d899433.camel@kernel.org>
	 <20190814215630.GQ6129@dread.disaster.area>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 (3.32.4-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-08-15 at 07:56 +1000, Dave Chinner wrote:
> On Wed, Aug 14, 2019 at 10:15:06AM -0400, Jeff Layton wrote:
> > On Fri, 2019-08-09 at 15:58 -0700, ira.weiny@intel.com wrote:
> > > From: Ira Weiny <ira.weiny@intel.com>
> > > 
> > > Add an exclusive lease flag which indicates that the layout mechanism
> > > can not be broken.
> > > 
> > > Exclusive layout leases allow the file system to know that pages may be
> > > GUP pined and that attempts to change the layout, ie truncate, should be
> > > failed.
> > > 
> > > A process which attempts to break it's own exclusive lease gets an
> > > EDEADLOCK return to help determine that this is likely a programming bug
> > > vs someone else holding a resource.
> .....
> > > diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
> > > index baddd54f3031..88b175ceccbc 100644
> > > --- a/include/uapi/asm-generic/fcntl.h
> > > +++ b/include/uapi/asm-generic/fcntl.h
> > > @@ -176,6 +176,8 @@ struct f_owner_ex {
> > >  
> > >  #define F_LAYOUT	16      /* layout lease to allow longterm pins such as
> > >  				   RDMA */
> > > +#define F_EXCLUSIVE	32      /* layout lease is exclusive */
> > > +				/* FIXME or shoudl this be F_EXLCK??? */
> > >  
> > >  /* operations for bsd flock(), also used by the kernel implementation */
> > >  #define LOCK_SH		1	/* shared lock */
> > 
> > This interface just seems weird to me. The existing F_*LCK values aren't
> > really set up to be flags, but are enumerated values (even if there are
> > some gaps on some arches). For instance, on parisc and sparc:
> 
> I don't think we need to worry about this - the F_WRLCK version of
> the layout lease should have these exclusive access semantics (i.e
> other ops fail rather than block waiting for lease recall) and hence
> the API shouldn't need a new flag to specify them.
> 
> i.e. the primary difference between F_RDLCK and F_WRLCK layout
> leases is that the F_RDLCK is a shared, co-operative lease model
> where only delays in operations will be seen, while F_WRLCK is a
> "guarantee exclusive access and I don't care what it breaks"
> model... :)
> 

Not exactly...

F_WRLCK and F_RDLCK leases can both be broken, and will eventually time
out if there is conflicting access. The F_EXCLUSIVE flag on the other
hand is there to prevent any sort of lease break from 

I'm guessing what Ira really wants with the F_EXCLUSIVE flag is
something akin to what happens when we set fl_break_time to 0 in the
nfsd code. nfsd never wants the locks code to time out a lease of any
sort, since it handles that timeout itself.

If you're going to add this functionality, it'd be good to also convert
knfsd to use it as well, so we don't end up with multiple ways to deal
with that situation.
-- 
Jeff Layton <jlayton@kernel.org>


