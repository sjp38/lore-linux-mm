Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2EEDC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:10:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60ABB214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:10:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UP6aQIvZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60ABB214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 133598E0164; Mon, 11 Feb 2019 16:10:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E3E28E0163; Mon, 11 Feb 2019 16:10:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3B8A8E0164; Mon, 11 Feb 2019 16:09:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B52DE8E0163
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:09:59 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q21so280176pfi.17
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:09:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jaq4bJN1qOEXyuMZs7wye4duFdAYcvHrSM8nzJ3aR2Y=;
        b=J7/yM2XV/0Jtx9R81N8YfQazEpG0irUXEGyEftpLNaHf6ZfPzlioSNXri/pJnww7Dr
         m/dMF1Ay5Z7/EfdjzcQKgvaoyeflGADs3dwTYHXP8iHCwIYKBmRYJ7esd6e7fH6dzWdy
         UXkgzi+RKxs3r+60hhY4vtzY4cN84hPcEtLvCsDqX53oaYIrBU3KUsKaCtvBd7nifVHr
         zCNgCXH0xTzxEmqEnezjWlMBLQCP2WbOA34V/GBJnp170It4ZatWX8LQXHi5LOhWgIt8
         J6Da+uHoBzhHlEzlfRXGkqXmqhbru3ekQAGzOhqMfyNVST5ZXsaR3niisousN62mqiuk
         q2YA==
X-Gm-Message-State: AHQUAuaRVqdnlCqMoUJkrJisgoU6tvO/LScTnXzggWFDd4IAUxTbZjGl
	Wb6ExapDN8NQunE+hJO3D80GXpIG2lnTT/mYQJtrCORyf63RvRkA+kFmWhq/DVppqpEb5zlzpxA
	3tAM+US+izW9L/sW/pisZ7c6lctPxwT/A1Mw4dxi2Uot/fpp5xRr0wrDKwubTQA0lBp59h2lFKF
	SInyyKs+K+VciNYrEMyRjZ95KbzKbWorxzDNSVK+ThMit3y4Lf3o80RoMdiwAtRFOQzYqq0+8nh
	nyz0l7tlXWJZMS6R+GtoogRrqM6OkiT/Dboc4YEu2E8fKJRUbd+z6JmW/xdjXwCVwXQ1C1E9Uh4
	DBJ9QcLSYfyLPesoo/OeyY1Q309Eu0YFRjnVfsZ8RRnTym5mahxkaxnU5uGpeIMZS9kRwYxEcBk
	U
X-Received: by 2002:a62:3603:: with SMTP id d3mr266016pfa.146.1549919399362;
        Mon, 11 Feb 2019 13:09:59 -0800 (PST)
X-Received: by 2002:a62:3603:: with SMTP id d3mr265955pfa.146.1549919398630;
        Mon, 11 Feb 2019 13:09:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549919398; cv=none;
        d=google.com; s=arc-20160816;
        b=RoUv+MjLeI71SULenmIiY1lE5/0/QlYfkeAuLw8+58NwSZJGb6yxsjNOWvEiNccwDd
         DQypnqHVqCGRtUHnsl0ptfQnLlpUkX14AZ5XoPO3Vjm10OEQFA3K7eWPEENfbLFOR/aP
         zZM6i2RIwjmRj2vl2olGTazJknh4XdNi345qHLBHlLQ8YOraKCoYpQl510+y7k/35jBq
         cmDn2H8cCGbtFgvIu9YzqgUDI3rT5uRdzOHX+GmRBEktgX9bRNRRGCWaA3dW+J9R54Er
         Z6pzYidBSjewZlyVul1Fk7FR3AuR8Zw9aUe8dtjiHUG8yqAH3m/gcNXwOdOP5VPVqsST
         sWSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jaq4bJN1qOEXyuMZs7wye4duFdAYcvHrSM8nzJ3aR2Y=;
        b=maB0oconS6abJe/GLnXT3sWDMbAlqrEgmzXLz1XV624vO0PoNrzNIdgF6rTQwhU5sk
         xjJlSi8Ue0Sl/ptWX3jDCAFYjjzu1ijmfoysZmS+LvuTsWmQ2IIFmY0Z9zPlhlR/eeGz
         r3kyNh77zXjqIDtuZ1x+tb2LZoTGqLxGEDU3kIQSAWfHeanvGK1G32nD80hYCpLHgebF
         AQce0qaaj1eiqn7ZmCnrY1/382IsGF+9RPQSaaxv1JkQgrdfSTFT7kVl4QsyrYN/o8tV
         AUsM/IzX/Pk2akNoipg6xb10YOHtvSpduiNbBYhpj2bluAfWkrmXE7SjZxrRhleBShxx
         qAlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UP6aQIvZ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor15697664pgv.77.2019.02.11.13.09.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 13:09:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UP6aQIvZ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jaq4bJN1qOEXyuMZs7wye4duFdAYcvHrSM8nzJ3aR2Y=;
        b=UP6aQIvZmYiway7xzIgJzuIWXK4W48+TLF0JTke857tZ/pIM7SmP1S60I4O5T7XUQs
         sDVaxnZPHxkGwRokhN95UYV7DGKXLE2zZ2ir7Iy1I5HLwleo9q8B9a60DSARBC8sYAn0
         G45Rte8IxbVnsIsRmsxaB318I9Nfo+0ZKLtbweHoP5iev3mbg0SKHmUix5PSP6jdFB/k
         p9XST+tFajeg3fnQJdzheDATzcj+db/tTvXCyS25fR0oQYq4A17FFHN9ZICkZeGndgmP
         L2NkVYdD1vGBSwdon1iPwrccgVXz5EEQw/9EdbaVQKjc1oyQdQLKQJPsnqLvnzeHX3bd
         GcZQ==
X-Google-Smtp-Source: AHgI3IZKm0M/wcRUHr9Xw8s/w6oT/zo2vcfzmLBQDdDtuXEOedsgFDBvgoX7Gkg+Ip8nE+Sz4JWwqA==
X-Received: by 2002:a63:5861:: with SMTP id i33mr257286pgm.60.1549919398236;
        Mon, 11 Feb 2019 13:09:58 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id u66sm26188695pfi.115.2019.02.11.13.09.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 13:09:57 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtIpw-00011F-TG; Mon, 11 Feb 2019 14:09:56 -0700
Date: Mon, 11 Feb 2019 14:09:56 -0700
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
Message-ID: <20190211210956.GG24692@ziepe.ca>
References: <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <20190211182649.GD24692@ziepe.ca>
 <20190211184040.GF12668@bombadil.infradead.org>
 <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com>
 <20190211204945.GF24692@ziepe.ca>
 <CAPcyv4jHjeJxmHMyrbRhg9oeaLK5WbZm-qu1HywjY7bF2DwiDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jHjeJxmHMyrbRhg9oeaLK5WbZm-qu1HywjY7bF2DwiDg@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 01:02:37PM -0800, Dan Williams wrote:
> On Mon, Feb 11, 2019 at 12:49 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Mon, Feb 11, 2019 at 11:58:47AM -0800, Dan Williams wrote:
> > > On Mon, Feb 11, 2019 at 10:40 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > >
> > > > On Mon, Feb 11, 2019 at 11:26:49AM -0700, Jason Gunthorpe wrote:
> > > > > On Mon, Feb 11, 2019 at 10:19:22AM -0800, Ira Weiny wrote:
> > > > > > What if user space then writes to the end of the file with a regular write?
> > > > > > Does that write end up at the point they truncated to or off the end of the
> > > > > > mmaped area (old length)?
> > > > >
> > > > > IIRC it depends how the user does the write..
> > > > >
> > > > > pwrite() with a given offset will write to that offset, re-extending
> > > > > the file if needed
> > > > >
> > > > > A file opened with O_APPEND and a write done with write() should
> > > > > append to the new end
> > > > >
> > > > > A normal file with a normal write should write to the FD's current
> > > > > seek pointer.
> > > > >
> > > > > I'm not sure what happens if you write via mmap/msync.
> > > > >
> > > > > RDMA is similar to pwrite() and mmap.
> > > >
> > > > A pertinent point that you didn't mention is that ftruncate() does not change
> > > > the file offset.  So there's no user-visible change in behaviour.
> > >
> > > ...but there is. The blocks you thought you freed, especially if the
> > > system was under -ENOSPC pressure, won't actually be free after the
> > > successful ftruncate().
> >
> > They won't be free after something dirties the existing mmap either.
> >
> > Blocks also won't be free if you unlink a file that is currently still
> > open.
> >
> > This isn't really new behavior for a FS.
> 
> An mmap write after a fault due to a hole punch is free to trigger
> SIGBUS if the subsequent page allocation fails.

Isn't that already racy? If the mmap user is fast enough can't it
prevent the page from becoming freed in the first place today?

Jason

