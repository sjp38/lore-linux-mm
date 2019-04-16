Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17F79C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:57:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D884A2073F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:57:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D884A2073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DD956B0003; Tue, 16 Apr 2019 15:57:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 463A46B0006; Tue, 16 Apr 2019 15:57:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DEAF6B0007; Tue, 16 Apr 2019 15:57:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4EA6B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 15:57:52 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n1so20335762qte.12
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:57:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=4YC/SWjxlOdzRIslZGV/FKUSalJ5ZPrGgKiaRY/Pnlo=;
        b=N2Hex1hVnpFXGrJQGp8jJ35iyTjxiiavMUwoM+1jwyPxJNKujxPLPKPEjQVTD+KMmJ
         FlrY7KRNNrrEqkaFuDRGu/T0oHy0Z/kjbf8l7ZlikiAUhx67w2DWx8wWLOcqbTjCRUby
         v80T7Jdvxt2yYzpPZGG8eQkp0uRyIF4Dds2nunPLCLntV26RlnLSb/fK71jqTX8oc+aG
         lwNgx3RCrUUjqNuWbrWBQwVbA1hyruc3kzeahHeJ03/qg+1sl92PfJ5WI8XencCJpF5N
         p1NyrxKbFj4HeiUSK8wIMOJFBHsfj8Tb/QRy+ea+ecV3J07BWKmRqUWvjaHF3RAmIAWR
         PjDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWIEd1KDg/jFChzQdSo35snLpCt0BRH+crkhxXluZ2Q4XoZK19w
	DsPIJR9gD9uIR2+1Ec2d5cldDwH1pNC/RbYxycpcB0eRGRneQxXIXZuIq7ajAhRAAP8AOg5nxHF
	D6eAQougkunz8DXfNFKRHejHhnYnQRVl6zTXYGiHtVnnUbqkAgDXWFkbpD5qx1Q1X1g==
X-Received: by 2002:a0c:bd89:: with SMTP id n9mr67891944qvg.200.1555444671813;
        Tue, 16 Apr 2019 12:57:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzIRjnpMT5OV0R3J9WeCJvbq/+NjTzl3wH0RVxom6EXddITtO4LT1kKZEaQgooNGw5KZXx
X-Received: by 2002:a0c:bd89:: with SMTP id n9mr67891893qvg.200.1555444671122;
        Tue, 16 Apr 2019 12:57:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555444671; cv=none;
        d=google.com; s=arc-20160816;
        b=F6+YAh4HqSgwrwXHXn0B0r8cheBf+mcyxmywJMtFfmBYDwzEI1eqOsbYOlv9kZ44eI
         Ug0OVrVY6LsjzV6J9qK8J1JRZvNHRAS6i14kQ/lIMUA/G1wLpzUkeVz/vusu149OT0UU
         yaGdQ3PHQ7et+RY4cHQWn7BNE6vHIcoNs5i47VzREerIv14gDkMDDfh6laJ0LLtGN+4m
         er6eoKqlgYaFbnkTSOX5OGrinF7nvwvuEuJPqfIOZNB/oPWUeEFc+6vCXC5/nAX7ir3F
         hG82TMM2XTvJaByWQhfrw2YS9kTqtMWNOR2w3OEAJaUNDrubGQ/W2nbfq38TIYPDNsf+
         pQ7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=4YC/SWjxlOdzRIslZGV/FKUSalJ5ZPrGgKiaRY/Pnlo=;
        b=KzyxnLCUhnLT908EO2fCasa4m/DUzoPR0dLgqkQNqQ5SqjpDxF4laCB17R0IQLc8DA
         7ycSus3JGlsoNvaduMTiHG0Ls5rocwduoqA7tSU/Pifkyek7kCxdfiPHHuJXEcmUaG/P
         FccEdz2WAw5Chf3FOBEhWrZsZUZ3ZV04CZjLgaqYCCqIjgXt26v6yNrgdAzcfxjIAy6R
         mS/G6hx2W8yHkTQCAFvaMnCdR4mZf4Bt0SUKRsPn8gzb6z3NRgLiSSl96Y+dgd7BG6T1
         N960aJ8q+3Gj9h/d1Y2f/dV6Tjf7nM1TH03wpKn9VdFGFR6x6XIpKOOMkNlbxG9rp1uh
         oH+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t33si355983qtt.399.2019.04.16.12.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 12:57:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D6EA7F74CE;
	Tue, 16 Apr 2019 19:57:49 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 883AF608C7;
	Tue, 16 Apr 2019 19:57:38 +0000 (UTC)
Date: Tue, 16 Apr 2019 15:57:35 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
	Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@kernel.org>,
	ceph-devel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org,
	Dominique Martinet <asmadeus@codewreck.org>,
	v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org,
	Ernesto =?iso-8859-1?Q?A=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
Message-ID: <20190416195735.GE21526@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 16 Apr 2019 19:57:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 10:28:40PM +0300, Boaz Harrosh wrote:
> On 16/04/19 22:12, Dan Williams wrote:
> > On Tue, Apr 16, 2019 at 11:59 AM Kent Overstreet
> > <kent.overstreet@gmail.com> wrote:
> <>
> > This all reminds of the failed attempt to teach the block layer to
> > operate without pages:
> > 
> > https://lore.kernel.org/lkml/20150316201640.33102.33761.stgit@dwillia2-desk3.amr.corp.intel.com/
> > 
> 
> Exactly why I want to make sure it is just a [pointer | flag] and not any kind of pfn
> type. Let us please not go there again?
> 
> >>
> >> Question though - why do we need a flag for whether a page is a GUP page or not?
> >> Couldn't the needed information just be determined by what range the pfn is not
> >> (i.e. whether or not it has a struct page associated with it)?
> > 
> > That amounts to a pfn_valid() check which is a bit heavier than if we
> > can store a flag in the bv_pfn entry directly.
> > 
> > I'd say create a new PFN_* flag, and make bv_pfn a 'pfn_t' rather than
> > an 'unsigned long'.
> > 
> 
> No, please please not. This is not a pfn and not a pfn_t. It is a page-ptr
> and a flag that says where/how to put_page it. IE I did a GUP on this page
> please do a PUP on this page instead of regular put_page. So no where do I mean
> pfn or pfn_t in this code. Then why?
> 
> > That said, I'm still in favor of Jan's proposal to just make the
> > bv_page semantics uniform. Otherwise we're complicating this core
> > infrastructure for some yet to be implemented GPU memory management
> > capabilities with yet to be determined value. Circle back when that
> > value is clear, but in the meantime fix the GUP bug.
> > 
> 
> I agree there are simpler ways to solve the bugs at hand then
> to system wide separate get_user_page from get_page and force all put_user
> callers to remember what to do. Is there some Document explaining the
> all design of where this is going?
> 

A very long thread on this:

https://lkml.org/lkml/2018/12/3/1128

especialy all the reply to this first one

There is also:

https://lkml.org/lkml/2019/3/26/1395
https://lwn.net/Articles/753027/

Cheers,
Jérôme

