Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3A27C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:26:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A982621B24
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:26:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Mj3mTK3f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A982621B24
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44FBC8E0127; Mon, 11 Feb 2019 13:26:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FF408E0126; Mon, 11 Feb 2019 13:26:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27A5B8E0127; Mon, 11 Feb 2019 13:26:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D53F28E0126
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:26:51 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so8985157pgm.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:26:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=55A1Tzpnb38ALuz/hEWQoAObFDG1vIZPV+qQfCUbDis=;
        b=CsUA6MgzFPADKagiLeauZrjRjXW6dJzPpNF0XaoAqwAeUtdtUEW0RY27J5IzoXEkYF
         GPC/uTfEBDZHSzM5wV9HlX9Dll7Hx9hgCd2JPBGIdTcRyPxvh4i9mw7QTE7OEQCdo+Nb
         U8cFd/aIRNn+b3mU8uyXKrv+NoalQp0veBwLyQVcXqOZMMENIhBOO76klPjWkZXY9S/b
         /2izYke0UYTAK9R0BEKN8FPoHCe333RQ5gRkVTH+v38+U026fWl5i8bNRJ6bSf6Yko3V
         vr/D3llYeMHRsiiFjYLNhgS/0bzmAG6Eif/8tlQ7AtmPODPImikJQdOqSWV9+Q3TgY4f
         9w9A==
X-Gm-Message-State: AHQUAuZq2mbiatZzwPQJB0FCSAZfEymgz/g1pNsT80Bm8karinBJjTdR
	5AwkLUgEGlGkWm3Nz5qRjayRy2sUB72Dj0jWZH123/UoTXj/aD4firOUSYAthYchQiM091y1isp
	I9Lh45KNKxPsyXp4U2KXkcSAeLLh7P8mlzhdIMqEapTiel/Zic/phatk8hi5QmL6LjCo0VFu4mR
	M8g8hDGrJ4G3Fb7b1ZV1VjeL9THDwyvbyIhacIkNfktkJu8V/HaNs2VjZnBmYdmb+arpyzrsmtp
	qPYVIw08R/cvgawQmjx4cTWrG9AI0vD+DcB+fkcHU37cgE9JK1SS60ndxdhwaaPAsC+WLVls282
	vsOUGsXjJiHalvvP9oAYdmsoBdhxv7/9gygK0BKeJty3g4pyIo+A57NAm/6JZQLUqQplzJ+5mzf
	n
X-Received: by 2002:a17:902:2ac3:: with SMTP id j61mr38840941plb.185.1549909611517;
        Mon, 11 Feb 2019 10:26:51 -0800 (PST)
X-Received: by 2002:a17:902:2ac3:: with SMTP id j61mr38840871plb.185.1549909610743;
        Mon, 11 Feb 2019 10:26:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549909610; cv=none;
        d=google.com; s=arc-20160816;
        b=IwGZF0M7bjC6XFfojtP6aXspVUlrTqnkWuiP/MZ6Trrlo9AeqkX8QGjsrbkU8+uyRw
         Tu6G3gaoSaXC/BhNiC2tt7z4h/pH3/wJ4Aot+5js6usGwaph06wv1y/c1cQADHgYCygR
         bIZCvmDSNc/q620pJH+qDO8v8rHpvNeJzEZoYrfO+1OxewG7W7IB/Q2jYQicc5BCoGZq
         rCaZ8ghtSaCkLXDvTk98DGAGalW9PhUgcNhyJ/KtwqU4ulw+o3gYJt9Ry4izQo2abWye
         6QXnmx4vTtsQa7+G384xhjQUge9BVDjmTwsJAcSZzP4QOfZjBDgmDTERHc1ogIKTfbjn
         nNYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=55A1Tzpnb38ALuz/hEWQoAObFDG1vIZPV+qQfCUbDis=;
        b=Ig2Il7q0+A2/RhitZx2JdOdYQNQUzDkwVegH16Dck7cBE3x6yPazciCzpzSCUl4k+N
         HHYUZ5NHl0gN4S8maitCk0ookVeuV4nUdBIklnceKndoQ759TNoeifv4oa/gFcgaXRWa
         8ctXv/papmmQQc+rWkWU2nRVpWjn47h5kG7Y6gD7YREx6nWMpKYGsqID+Iz+kjY0k6Oh
         lPsAoBORNeUl585pHOtmnJTLAOMoeUpvjQ55EoGPyuMgAW8J49uMvvhUNAT1iilrwqT6
         QpHqIxXkPHSw7pYg7b8aNhvfOKme9VT6gBJuxn/I3VSCvQEItzSeb0gBE50bTeHJsMjO
         SKeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Mj3mTK3f;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20sor15122439plr.50.2019.02.11.10.26.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 10:26:50 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Mj3mTK3f;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=55A1Tzpnb38ALuz/hEWQoAObFDG1vIZPV+qQfCUbDis=;
        b=Mj3mTK3ftEU3DUrMgeUXpNIZqsHZgLk5/z288iOCtUt/F37QuZN7yX8AqdjQK/3+z6
         Ll/qXwx7iEUTnKtO2m9WEumUT0VYhr8QJfACPOWTXfFCaOJ1FWILDFAVt3CqC5OLAWhF
         Q2oTfHeJb+5KZSHe3FyMzx+89xJnHsnw8AfBu5mGJ1hBXAs/qB4HNZley96iVaaClz3h
         CwREUkexHL8CbdtIVODUeW6IBnN96qJJb1yCpxj5IXKiqQCJBeAzyawqpRAmFTJsyqno
         ed0GlD/AO0zTzPMd4n/+n5LlOWCbB8qShv8Q66fAVkidPBmSYDkEq4HsTsIrZnoxY895
         zl7Q==
X-Google-Smtp-Source: AHgI3Ib7kX/6bDFMQPp7bF5muCAYEfNne0VIKtJCAfQT8s825HlnDnZfwmnsWqCX2++DlDx6SGgdfg==
X-Received: by 2002:a17:902:346:: with SMTP id 64mr39532911pld.337.1549909610274;
        Mon, 11 Feb 2019 10:26:50 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id q21sm23886969pfq.138.2019.02.11.10.26.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 10:26:49 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtGI5-0007nw-0s; Mon, 11 Feb 2019 11:26:49 -0700
Date: Mon, 11 Feb 2019 11:26:49 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190211182649.GD24692@ziepe.ca>
References: <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:19:22AM -0800, Ira Weiny wrote:
> On Mon, Feb 11, 2019 at 11:06:54AM -0700, Jason Gunthorpe wrote:
> > On Mon, Feb 11, 2019 at 09:22:58AM -0800, Dan Williams wrote:
> > 
> > > I honestly don't like the idea that random subsystems can pin down
> > > file blocks as a side effect of gup on the result of mmap. Recall that
> > > it's not just RDMA that wants this guarantee. It seems safer to have
> > > the file be in an explicit block-allocation-immutable-mode so that the
> > > fallocate man page can describe this error case. Otherwise how would
> > > you describe the scenarios under which FALLOC_FL_PUNCH_HOLE fails?
> > 
> > I rather liked CL's version of this - ftruncate/etc is simply racing
> > with a parallel pwrite - and it doesn't fail.
> > 
> > But it also doesnt' trucate/create a hole. Another thread wrote to it
> > right away and the 'hole' was essentially instantly reallocated. This
> > is an inherent, pre-existing, race in the ftrucate/etc APIs.
> 
> I kind of like it as well, except Christopher did not answer my question:
> 
> What if user space then writes to the end of the file with a regular write?
> Does that write end up at the point they truncated to or off the end of the
> mmaped area (old length)?

IIRC it depends how the user does the write..

pwrite() with a given offset will write to that offset, re-extending
the file if needed

A file opened with O_APPEND and a write done with write() should
append to the new end

A normal file with a normal write should write to the FD's current
seek pointer.

I'm not sure what happens if you write via mmap/msync.

RDMA is similar to pwrite() and mmap.

> Or is it safe to consider all gup pinned pages this way?

O_DIRECT still has to work sensibly, and if you ftruncate something
that is currently being written with O_DIRECT it should behave the
same as if the CPU touched the mmap'd memory, IMHO.

The only real change here is that if there is a GUP then ftruncate/etc
races are always resolved as 'GUP user goes last' instead of randomly.

ftrunacte/etc already only work as you'd expect if the operator has
excluded writes. Otherwise blocks are instantly reallocated by another
racing thread. 

I'm not sure why RDMA should be so special to earn an error code ..

Jason

