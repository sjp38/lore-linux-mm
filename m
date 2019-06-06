Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2468EC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:51:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5844208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:51:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JK8En4/C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5844208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80E6E6B0279; Thu,  6 Jun 2019 15:51:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BFBB6B027A; Thu,  6 Jun 2019 15:51:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AEF66B0281; Thu,  6 Jun 2019 15:51:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC9C6B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 15:51:17 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r58so3056281qtb.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 12:51:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fVbv7ZkCU0XRJ9jD+fxd4ieH6waXD3NIwch6tKZrfLk=;
        b=Yvd5wv2ae30T+A9ssdeTk3kOVq4ywNAcWbaTikbh+AfT3EaXNieJXxz9CWT5w1yLv7
         tIxCab1Y3ucctChVR83x2BAkGQmiZ7Xf+QWhcVRnSI+X1n9H1WnVR0SUkHrqRBC/K5CL
         e6L8UU63IlnxJsYqLKWFsTw6FJB3xPUBCuObMtbuOQUJGI6Z6pozpscTNl3wwcmxzxfc
         BHqfQEISh40FGtpDKh9TqS2nSUvGA/HYuik0XDNY4HEc7Iof5fgk3N2KNmaWMlxYv11D
         ZBNVwfJ30nHhj+TzTSmCrn69mjrwtm9io1LcCy3RfyNtVz+np+1cUlosIAYVPIvjCLv7
         4M7Q==
X-Gm-Message-State: APjAAAXpc+V6ZN05dbPGhRKxc0LmyWUwb9Vqd7bStDXbinM3t/J82+mT
	1DlKoxED9c/HBhvkHbTgkzNuDiJ1S8zXBpeuSbHC2BWe5ZKAYYwKX1EU7SbRHNl/Cfnw7Cf+gO2
	rSakrKmVPU3xEfgY0BYamL0FSyIxuHPTDjrcNdmlupQZiF9uGiqrJjNkVbU0QxPiKSA==
X-Received: by 2002:ac8:1a8d:: with SMTP id x13mr42798498qtj.114.1559850677023;
        Thu, 06 Jun 2019 12:51:17 -0700 (PDT)
X-Received: by 2002:ac8:1a8d:: with SMTP id x13mr42798456qtj.114.1559850676406;
        Thu, 06 Jun 2019 12:51:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559850676; cv=none;
        d=google.com; s=arc-20160816;
        b=T6GWZ4imDNYxX+Hg2tMIY61+3DN6btxPxek71hFyrhaiFkh2zvLZOqdPZlSDiNs9XA
         ozWHa9HeyjnVapNd//w0rvTAvGAUTlhT3yhnL2yFB0rM5IEhz2bXfe+nHOBC1Apo7twi
         FTls+y77By8ULSwDXRYdcxiqhU18J8H0/3l3VBrM1du1fQjtawAl84Rujjmy3pExI1A4
         dC7IGGhuKm/+OF0FSyLy2u3LQU6GeVv0ANApSkAtO0GHRSuxFunSwc9Y5hKf/PW4dAvk
         tV+BdB5i2YBSbF1EjIzkhlRjjWr9QjvV2AWkObK/AD5Pzj3T5RIsUaqMJfqChyepz1hu
         dNPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fVbv7ZkCU0XRJ9jD+fxd4ieH6waXD3NIwch6tKZrfLk=;
        b=xrVZM8MT/AVDbygH07ftE3afqVejjUyWxJSSC39jxYifPQvm0aH09d+3JIJr6tPeMy
         eZ/HPROpt0fZg/z8sQ8eBlNXe2qAVJvG4w9r4Tif6rOyHTlXZMz8nG3pELtqN3LeUfoq
         X4z+8vyPg7nX9dbA0jjsEI1azvH0C4bOQJdx+AEOFV+P3aFdFMNtMwoDt7RICXAZO+GF
         WWgqc/9Ctlmx0ouDztOW3q8OoRQqqIyRNDd3TGV7m76RipEWyLJJ09gs+7A1BJc8ctrX
         4tL9x4fcsC6+5bQn+UWQ6raC0FwiUvUgPFyl/ir/aJrRWHriYaFtygiysiBTH4QV89Wu
         /Cxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="JK8En4/C";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor1553626qkc.47.2019.06.06.12.51.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 12:51:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="JK8En4/C";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fVbv7ZkCU0XRJ9jD+fxd4ieH6waXD3NIwch6tKZrfLk=;
        b=JK8En4/CLh0QaNpMzjO2iMeOMpfrAAx/gr5SgNV/sb4SY2gHe/v8MOPkfC/9wPWIZ9
         ZL8QsvlzUZu3/QV2sR8DriCxzBeBuTLKUUPKPgdfpcAKVXgCaQb7rGQ3TRW8g1PxMby9
         +wxeHaZK6IN3egjgnP9IJZ+w011avGG0F3y8TTnoGrINoPzy0TddWA78C+1Q+KMGIdzz
         92AxUAVNZWhAkEVYstL8INWhYQ829J/YpWO2ZbVyA8ZS8ksWZ7LFyB1R04yWWmr5UAZu
         N8V2QVFH6XXSPdpk/99Edhk0JJ7bEpSx2FL6IQyeiD+YQVzMZEgvotOVmE8xHx4nh57Z
         Aq3A==
X-Google-Smtp-Source: APXvYqzyssiuyqvk956epvDv1OTyC6TvGNp+K2MqufTjNzhdzVN0pIMcZor/PXhzGoG5BWQnFWZbfw==
X-Received: by 2002:a37:a9c3:: with SMTP id s186mr41012233qke.190.1559850676118;
        Thu, 06 Jun 2019 12:51:16 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id t197sm1415555qke.2.2019.06.06.12.51.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 12:51:15 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYyPr-00081O-0q; Thu, 06 Jun 2019 16:51:15 -0300
Date: Thu, 6 Jun 2019 16:51:15 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jan Kara <jack@suse.cz>
Cc: ira.weiny@intel.com, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190606195114.GA30714@ziepe.ca>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606104203.GF7433@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 12:42:03PM +0200, Jan Kara wrote:

> So I'd like to actually mandate that you *must* hold the file lease until
> you unpin all pages in the given range (not just that you have an option to
> hold a lease). And I believe the kernel should actually enforce this. That
> way we maintain a sane state that if someone uses a physical location of
> logical file offset on disk, he has a layout lease. Also once this is done,
> sysadmin has a reasonably easy way to discover run-away RDMA application
> and kill it if he wishes so.
> 
> The question is on how to exactly enforce that lease is taken until all
> pages are unpinned. I belive it could be done by tracking number of
> long-term pinned pages within a lease. Gup_longterm could easily increment
> the count when verifying the lease exists, gup_longterm users will somehow
> need to propagate corresponding 'filp' (struct file pointer) to
> put_user_pages_longterm() callsites so that they can look up appropriate
> lease to drop reference - probably I'd just transition all gup_longterm()
> users to a saner API similar to the one we have in mm/frame_vector.c where
> we don't hand out page pointers but an encapsulating structure that does
> all the necessary tracking. Removing a lease would need to block until all
> pins are released - this is probably the most hairy part since we need to
> handle a case if application just closes the file descriptor which
> would

I think if you are going to do this then the 'struct filp' that
represents the lease should be held in the kernel (ie inside the RDMA
umem) until the kernel is done with it.

Actually does someone have a pointer to this userspace lease API, I'm
not at all familiar with it, thanks

And yes, a better output format from GUP would be great..

> Maybe we could block only on explicit lease unlock and just drop the layout
> lease on file close and if there are still pinned pages, send SIGKILL to an
> application as a reminder it did something stupid...

Which process would you SIGKILL? At least for the rdma case a FD is
holding the GUP, so to do the put_user_pages() the kernel needs to
close the FD. I guess it would have to kill every process that has the
FD open? Seems complicated...

Regards,
Jason

