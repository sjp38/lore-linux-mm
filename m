Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 365B3C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 13:42:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC85A206DD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 13:42:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="nJsQ4APg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC85A206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87AD48E0003; Mon, 29 Jul 2019 09:42:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82A1C8E0002; Mon, 29 Jul 2019 09:42:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CA4E8E0003; Mon, 29 Jul 2019 09:42:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC678E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 09:42:20 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x1so55226538qts.9
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 06:42:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IfCi/dO4p77O3IWTYEfGSy4zB7Nta8rM4/jOE2XnS8Q=;
        b=Ul0S2gdcCNQtlkeV81Jt1XcXekw4HKXM+EeID56REjWXQQHkGpRX5z7OE45ejodSmG
         QR0zbsE8CFMKBP1wFv+bw/BL+Har9JXD3xFw+x92tcLqBqDT8Ph+XgnCKl2RTtfQGya7
         DhYSOqJz9be3htzVlLpO0D/P+/ycmUtbHZRCZ9W05noRMWmmdRWQCwB+3OUk8ibWtd0y
         +LSHmORuiNFNdPhVRhCp9X1LQDsxPJ/vU/bkA1jEZNLg+pKr7IBe3Sr133/rBK++vfK5
         Ww+/7m1K6fltk5UF+uGKwndjoDHw0PgZEOuDVBSU5RUSRC5zE87Xf/WBzo8DGt87iGnk
         iTfQ==
X-Gm-Message-State: APjAAAVsaXuGxgkgVb0iWvl5eg5fw21XwtM12qS7YHtJagYwG0Mw9+tH
	13Z11MWDVtODomIUx0HVdJThqQGophW+5sFQSCL0gFrEOZ9KwsbYaHNtPqbAVvMqFtAZlHK1gTV
	cq/TbE/bnEpEZu5QaKASieNTMTRPYHfUwkDMYZng18EW7zJCT9fXGKQgEhNt4AwOClA==
X-Received: by 2002:a0c:eec2:: with SMTP id h2mr77898988qvs.189.1564407740027;
        Mon, 29 Jul 2019 06:42:20 -0700 (PDT)
X-Received: by 2002:a0c:eec2:: with SMTP id h2mr77898958qvs.189.1564407739467;
        Mon, 29 Jul 2019 06:42:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564407739; cv=none;
        d=google.com; s=arc-20160816;
        b=VKOUtYY3kedqlnFZFO/M1niZUrDMnfUVlo+oDMbFFj2GRKvmkRPd6vjqRARPrxmeeO
         fSJuQg1Jc7p9SJZMPecbxeYCJiZ+KtK7ZnnhoDJY8YjOgh3Bf2z+tYOHIxXfrt9jaO1T
         TcGe2C/397QeTrlbri4KnL4kcM97iK8+QpHJSm8zIAVq3dbGUUQtKHHgTScmxPNqqPGg
         0u+QJsfM5ZiVWz/QKuQbBSs4c0FWs2E3QyScHdL175Z+uk6rC1XSy2A+bIhWUnHeYmM+
         GIvCGIhpBWV4DAn4jyvwbkR3SjLuu3JymyM0DecQLagn9nLgtlSICMF8/99GdORQZhxQ
         0A4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IfCi/dO4p77O3IWTYEfGSy4zB7Nta8rM4/jOE2XnS8Q=;
        b=dBTyf6uPvcW2XYEzWU1R53YnRtzuNdS6v5uzDWF8gOYduz/D6AUAVrSheegEa4MOGN
         P6PEGEBv/26dDgGVdt5oiPUXpbHZ7rjA+bxby9dnvw3ksNpudHEHHDcQnvNfGSvF0SHT
         g2fr+UDiwbwnoRPg/QpeaU51i/jg3xJ36bncHg+TLJporsCSuDDvXNJgBkCg5vaixTbG
         jrWOSZmiv2ROxfCotp/psl1+n+ggCv3VhjbrRZzMc4eOpqbZ5DmteS/rmCzuWNxI06Y7
         7CZ6MWCLVj9okr15SwlzUwnXmw3uj4bYLa+H3ranm103Oel4ynYdsMnJ4JflGV+e0siD
         Uu2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nJsQ4APg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w206sor36047552qka.75.2019.07.29.06.42.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 06:42:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nJsQ4APg;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IfCi/dO4p77O3IWTYEfGSy4zB7Nta8rM4/jOE2XnS8Q=;
        b=nJsQ4APgOoZKWhWllwsjb96+i0qhmQEeAZoJPpvZ7IRi45JcZ4aJ73OIzM/eQyaUnj
         cECyIAjga8y9r0g6jwWXTceVpE8vSjf7ITPRMKxtuSYgsvmU9cmJfFVeuciMyvvrTXV3
         bCDkRsrT1XhW76iE4zhBeSShPMwbofiGuD/7eJFAmpHmfjMq8n6AGD3PrjTD90iT+wlu
         xqG+DNf7NXV58GYrtJFtJcqXG/HG5Kqg+jlZUBKDXR3o4Kcj3NuT6KXMm0z4cSACwjfR
         1qt/RGK+gCv+DJoJGRWPCYWZg/G0eK1ha5P3K2C3vWhevK9hYVjDE5BZM9eQ8PjNINxB
         lcyg==
X-Google-Smtp-Source: APXvYqw5wO1rHdWS2OfTb/oy25JsTnkZ80tIy0+oxpGcEdhSoOTxEjjkfXN855pvFFcNiA5ipseW5w==
X-Received: by 2002:a37:d245:: with SMTP id f66mr73336727qkj.59.1564407739075;
        Mon, 29 Jul 2019 06:42:19 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m4sm24934229qka.70.2019.07.29.06.42.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 06:42:18 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hs5ur-0006fl-RS; Mon, 29 Jul 2019 10:42:17 -0300
Date: Mon, 29 Jul 2019 10:42:17 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Jeff Layton <jlayton@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Henriques <lhenriques@suse.com>,
	Christoph Hellwig <hch@lst.de>,
	Carlos Maiolino <cmaiolino@redhat.com>
Subject: Re: [PATCH] mm: Make kvfree safe to call
Message-ID: <20190729134217.GA17990@ziepe.ca>
References: <20190726210137.23395-1-willy@infradead.org>
 <20190729092830.GB10926@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729092830.GB10926@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 11:28:30AM +0200, Michal Hocko wrote:
> On Fri 26-07-19 14:01:37, Matthew Wilcox wrote:
> > From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> > 
> > Since vfree() can sleep, calling kvfree() from contexts where sleeping
> > is not permitted (eg holding a spinlock) is a bit of a lottery whether
> > it'll work.  Introduce kvfree_safe() for situations where we know we can
> > sleep, but make kvfree() safe by default.
> 
> So now you have converted all kvfree callers to an atomic version. Is
> that really desirable? Aren't we adding way too much work to be done in
> a deferred context? If not then why a regular vfree cannot do this
> already and then we do not need vfree_atomic and kvfree_safe.

I know infiniband has kvfree calls under user control, mayne uses of
kvfree are related to allocating kernel memory for some potentially
large user data on the syscall path.. 

I'm also nervous about making them all queuing.

If we added kvfree_atomic() & a warning how many places would hit the
warning and need conversion?

Jason

