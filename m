Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CFB1C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:29:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D06CC20673
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:29:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D06CC20673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D3F66B02FA; Thu,  6 Jun 2019 18:29:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 683EF6B02FC; Thu,  6 Jun 2019 18:29:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5742E6B02FD; Thu,  6 Jun 2019 18:29:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0D06B02FA
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 18:29:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f8so5275pgp.9
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 15:29:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EKF3cH2R6zucIsmZACfatbZP8jLIeENi91OyvJpLtNQ=;
        b=dqmzdBC/5gJAaK/BHB3FGrvKe3/wsF0BfurcHi8hwLJP+An1eXv7O4NgO/ZrcU0iUW
         /Ay1nSAddKV1zheFOyZrQXReR1yddQhubpwqq4Vu8froDib60WgN42QTtREpfGDnKoZ8
         3I6RnLCI8JTZnx+Nk7M21HYq9GbAOukPaO66FRar466slSuIqVpuIwbLBju2C2zqDunO
         wJHLtWYzAtQDRElQVY9J0kyfmw/2/OkjX6yVE/gOHEkm+7+O95bEF6YuTDYugliQVUuF
         z+UFEgclbuOwf+/YCE7YcoT8PwUe5NyRjtWzV1l0qlWjnO2xOZPBAvNotI3Lt0I17DGb
         tODg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWK52Nwm5GTCpRJR/tU2X59KdOC3Rb14ogsZH3894j7NpXql+se
	ZaG9SIcBXCO5TFssMAPkKHBN4Wif01pnm7RhP5Stzifno9WLuA+hl0pzIDmCQHYWyR5g01SdsFB
	TzTlLmj1K0A/nhU21g3iYTfTx40V7r5CyhSIN/G7vULqj9Eb7W7pDSarWRHNx2UM=
X-Received: by 2002:a63:445b:: with SMTP id t27mr120029pgk.56.1559860196679;
        Thu, 06 Jun 2019 15:29:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMwyYd5Nl2u5Rldil4eWVKNhRcndt+2yp8UencAwi5JRinHLkRjeKByKYX6YR0KauzHTMP
X-Received: by 2002:a63:445b:: with SMTP id t27mr119986pgk.56.1559860195787;
        Thu, 06 Jun 2019 15:29:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559860195; cv=none;
        d=google.com; s=arc-20160816;
        b=J+RkuMwJsvYV8fKrx/c+ORnuC5CbzNGEwc9EWCH6vu2doh/mvXrF1S2yZIEDHJeNn4
         bu0mdrPFf5hh8ESOvoSy2pyVt9EdVGTWj+QWBT4ugYQvmkhSedTHMBlgy8/SnLxjGM40
         TQvhGgwmiaOfEsP1sSsXUC1jtZHyoMkNi9o5w3Vie0fveZvov/x3Ksb40W81IktmqROe
         R3ekkQWJ1UrsGRH/51TUMvippZrflJmafCU0Fnv+AKgO/PsL2blDi/VJ+eTkJ5REQi95
         WjaqPhqdhUlUwq3o7SqX8XPRXmzSNcWeKD1p6yzEKkhVFORSPaarg5CbHd8Vqz741otd
         qHbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EKF3cH2R6zucIsmZACfatbZP8jLIeENi91OyvJpLtNQ=;
        b=QqTpTH5LNNXR5cQMhlZKiNdEf1uj9B5xa2IoMejCyyRtZUgv2QKT/sj71CSTem6ZDh
         AEnFuvuNme/lfXkvFLFiyxIzK5s1nmTf4YXmuGFtz1PvZky6ldfKojuz/xvc2Q3ZJAdd
         zFL1lyku43IXIbFCt1C5FMgimSC3F4BJpvAX8c97OXeH2Qi3jCYbSk9YoeZJlLdiNW/6
         mCUxwCzWiNq1Q2UGDeVuK54dz7MVTrqv4BnMkIJZxMBw5upH/j6KeNlShMpu+VpMcgyy
         /Oe4TXazEGmm8+mWEPuhxD+MmGAXzFBSrzKbdUjOKy0qc3DOB349QKkHhKW98dIPDs+e
         LKEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail106.syd.optusnet.com.au (mail106.syd.optusnet.com.au. [211.29.132.42])
        by mx.google.com with ESMTP id i12si260289plt.287.2019.06.06.15.29.55
        for <linux-mm@kvack.org>;
        Thu, 06 Jun 2019 15:29:55 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.42;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-189-25.pa.nsw.optusnet.com.au [49.195.189.25])
	by mail106.syd.optusnet.com.au (Postfix) with ESMTPS id 868484EA85D;
	Fri,  7 Jun 2019 08:29:50 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hZ0sP-0000g2-35; Fri, 07 Jun 2019 08:28:53 +1000
Date: Fri, 7 Jun 2019 08:28:53 +1000
From: Dave Chinner <david@fromorbit.com>
To: Ira Weiny <ira.weiny@intel.com>
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
Message-ID: <20190606222853.GD14308@dread.disaster.area>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=K5LJ/TdJMXINHCwnwvH1bQ==:117 a=K5LJ/TdJMXINHCwnwvH1bQ==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=dq6fvYVFJ5YA:10
	a=QyXUC8HyAAAA:8 a=7-415B0cAAAA:8 a=-fIxr7oOWDDygYgkAT8A:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 03:03:30PM -0700, Ira Weiny wrote:
> On Thu, Jun 06, 2019 at 12:42:03PM +0200, Jan Kara wrote:
> > On Wed 05-06-19 18:45:33, ira.weiny@intel.com wrote:
> > So I'd like to actually mandate that you *must* hold the file lease until
> > you unpin all pages in the given range (not just that you have an option to
> > hold a lease). And I believe the kernel should actually enforce this. That
> > way we maintain a sane state that if someone uses a physical location of
> > logical file offset on disk, he has a layout lease. Also once this is done,
> > sysadmin has a reasonably easy way to discover run-away RDMA application
> > and kill it if he wishes so.
> 
> Fair enough.
> 
> I was kind of heading that direction but had not thought this far forward.  I
> was exploring how to have a lease remain on the file even after a "lease
> break".  But that is incompatible with the current semantics of a "layout"
> lease (as currently defined in the kernel).  [In the end I wanted to get an RFC
> out to see what people think of this idea so I did not look at keeping the
> lease.]
> 
> Also hitch is that currently a lease is forcefully broken after
> <sysfs>/lease-break-time.  To do what you suggest I think we would need a new
> lease type with the semantics you describe.

That just requires a flag when gaining the layout lease to say it is
an "unbreakable layout lease". That gives the kernel the information
needed to determine whether it should attempt to break the lease on
truncate or just return ETXTBSY....

i.e. it allows gup-pinning applications that want to behave nicely
with other users to drop their gup pins and release the lease when
something else wants to truncate/hole punch the file rather than
have truncate return an error. e.g. to allow apps to cleanly interop
with other breakable layout leases (e.g. pNFS) on the same
filesystem.

FWIW, I'd also like to see the "truncate fails when unbreakable
layout lease is held" behaviour to be common across all
filesystem/storage types, not be confined to DAX only. i.e. truncate
should return ETXTBSY when an unbreakable layout lease is held
by an application, not just when "DAX+gup-pinned" is triggered....

Whatever we decide, the behaviour of truncate et al needs to be
predictable, consistent and easily discoverable...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

