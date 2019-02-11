Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE1F7C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:49:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8B3E218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:49:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Eu9dS9Qi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8B3E218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44F4A8E015E; Mon, 11 Feb 2019 15:49:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FF6D8E0155; Mon, 11 Feb 2019 15:49:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 315F98E015E; Mon, 11 Feb 2019 15:49:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6F958E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:49:48 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b4so219018plb.9
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:49:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PlofGPK1avjEsw/QmRNa8WCLcUE+7hBOnwTBt8jUCMw=;
        b=WlO3SxlQAiy9HptruSs6tGAq3lryD42oQK5Ck/ADBYFNfMI92xBdnCJIOFyDDLZsFy
         hOoHSe2DRKSDqez47Rbh+CPes+lNi3UFFoyL00gY4mKi4uskX2P7rkptP3bTV4T/i3xx
         eDjGu87nGyC8fBT10rFD22sfUpYaXtINO9+WNnc+CywHyV6GHiUlLCrOtjzlOyjblw3d
         hDr2uuXcSQzxasFqmIrsLHxBBp7SSWzyywwQmyTOL3gsqqWB1NF3aQx306a6iS8P8+rq
         IRQjoTM92PttyHYMcoNYxDkGRFyLgGs+z93eBkvMVm1MeNmeqVjM07jvQOMjup1b2Ipj
         xU4g==
X-Gm-Message-State: AHQUAubQzXt6xsalD8WeidNpDkLsTN48D4Ksnmrbw80LWEodkr1pBgPL
	I5OAcOrBuNNSSDRo0l0ww6Aq+p0jqkBlnc+m6fKeV3ydUXUg1h9/3kZ5WYSHIcpos/kZqoOTEj+
	r02FpkpyvCxq97xlqicpN9ezKTL6wx6Pk8YkXEhjH4DaSr3W3G8jPze5Pu2t8CUASFcS6awxLR1
	gyy/wTeX0l5eEDNllvE6g3nVTndg6Yi5GTk2M6k2EFXSxeuQpihVSXI4fE5ztzyMNypzs3+N1iA
	GUKrbhTAHjOndXvlg4wTlUPJIZFDH8rzf2Q5Wa2B2Fn7BZC6nFeL8XWkc8gMw8CWSa53oAjMVP4
	CZVi6kMfobmGbWcB0qlFHs520nZGrGKOe9hGW0v2BGUCgI9FFXrx+Ym8rfZV8LIDqaqDW023x4v
	Z
X-Received: by 2002:a65:484c:: with SMTP id i12mr107742pgs.309.1549918188598;
        Mon, 11 Feb 2019 12:49:48 -0800 (PST)
X-Received: by 2002:a65:484c:: with SMTP id i12mr107693pgs.309.1549918187826;
        Mon, 11 Feb 2019 12:49:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549918187; cv=none;
        d=google.com; s=arc-20160816;
        b=ghplDLhotbHYw+7E1J9BTX4A0Zaaz2zbHhHfo59Xn3FlUtbKx+NU8iyLnZk2O7HDFC
         4xILQ/5+OWV78LBS055AsvIa6dlgQ4pqdYQMAKRYYiEZZFNfR04KziVaM8DtFXz8ojBp
         SDrj51zICsxO765+Tyt6CI8n3EtgCvfjGNDxvL+1GMvG3EKHERD1XZqKkaBe809zxDrV
         gEmgr7pfUzqXQtD7JYru1ykkeyqJ3SEhIrFHxJmVD6VtGCGiM4kCIleFhap3yMmqqcII
         nJ4pAUhjgwZhkNX3aVluzZxu5/Q/bPIJac3dxr9rsKPhe2Ai7/MLRlbzsZswswMjLARw
         Achg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PlofGPK1avjEsw/QmRNa8WCLcUE+7hBOnwTBt8jUCMw=;
        b=fw92aZyKQNqoDXdvdkzxSSH4sDbXo/FZ2HoLo9yRw4Pr+iaYRyd0eKapQrhwj3UeOe
         zPKPKCXGpVEC0CFg9AJvHSy0o6YMag0vDvm2i3hXR0Yj1jJtLkezAQ9adL26YLvlpp39
         T5IkaRf4oQUCGatGSLcSU0oUh4R9kF3+n81Jv2z+/xvEQ5P+IEVXfJSRdDy6R3/lKbLl
         uRqvKpZNLLoxA4mBqv9gDKDvGMWqMShTrMsVKK3mqMRGossrlKDQaTrrRygPss6E+d2D
         ywDaE42BvqpOECQpxgddu1g6oLLE7JkMExNjePuFefCpQMQK4lxnWM7ikm4xhxi1GAXm
         WMiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Eu9dS9Qi;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 27sor16457814pfs.60.2019.02.11.12.49.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 12:49:47 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Eu9dS9Qi;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PlofGPK1avjEsw/QmRNa8WCLcUE+7hBOnwTBt8jUCMw=;
        b=Eu9dS9QiH1mXijZ57nvyRLxXafPNQSUpE7A0KIWhVaD+0nVWDSJ5cRh6pntdBS25Mn
         ncuoRg637h9CDi94ozsiHQTU3r2IVpRskYTkXUtdRRAzvRo9CbKBEFSl5cUQSdM25YMk
         z414PObGbCTzSJ4dSf84jTlmJm1Q/G66C75pVMaYT5vaP+q8dESUpzF61VuzYS6W1df6
         /tyH9w4OTKPOT1k3H1QlCPSY/dqCdhMfM0NAvUEeMiwYiHNOS2fjwRGQKaRYzIm07Jdy
         6TXET+YjOF0a9uCkaWCLEG3rJJjq/W9jlQvqf1HpVn5iToEh+W3Zxwr31YZwiwu2CAnq
         vo7Q==
X-Google-Smtp-Source: AHgI3IYfH06fT0ipXPMLWvSPQM928HXuTRSOXaSVyTRK0UlGdqpTooa3WUDvBDPtleSKIBtF+3HNfA==
X-Received: by 2002:a62:2a4b:: with SMTP id q72mr139735pfq.61.1549918187431;
        Mon, 11 Feb 2019 12:49:47 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id t12sm11124722pgq.68.2019.02.11.12.49.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 12:49:46 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtIWP-0000or-RX; Mon, 11 Feb 2019 13:49:45 -0700
Date: Mon, 11 Feb 2019 13:49:45 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190211204945.GF24692@ziepe.ca>
References: <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <20190211182649.GD24692@ziepe.ca>
 <20190211184040.GF12668@bombadil.infradead.org>
 <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:58:47AM -0800, Dan Williams wrote:
> On Mon, Feb 11, 2019 at 10:40 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Mon, Feb 11, 2019 at 11:26:49AM -0700, Jason Gunthorpe wrote:
> > > On Mon, Feb 11, 2019 at 10:19:22AM -0800, Ira Weiny wrote:
> > > > What if user space then writes to the end of the file with a regular write?
> > > > Does that write end up at the point they truncated to or off the end of the
> > > > mmaped area (old length)?
> > >
> > > IIRC it depends how the user does the write..
> > >
> > > pwrite() with a given offset will write to that offset, re-extending
> > > the file if needed
> > >
> > > A file opened with O_APPEND and a write done with write() should
> > > append to the new end
> > >
> > > A normal file with a normal write should write to the FD's current
> > > seek pointer.
> > >
> > > I'm not sure what happens if you write via mmap/msync.
> > >
> > > RDMA is similar to pwrite() and mmap.
> >
> > A pertinent point that you didn't mention is that ftruncate() does not change
> > the file offset.  So there's no user-visible change in behaviour.
> 
> ...but there is. The blocks you thought you freed, especially if the
> system was under -ENOSPC pressure, won't actually be free after the
> successful ftruncate().

They won't be free after something dirties the existing mmap either.

Blocks also won't be free if you unlink a file that is currently still
open.

This isn't really new behavior for a FS.

Jason

