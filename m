Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 206E1C10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:26:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4EBE2192B
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:26:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4EBE2192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 725D88E0002; Thu, 14 Feb 2019 15:26:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AE0B8E0001; Thu, 14 Feb 2019 15:26:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 577C08E0002; Thu, 14 Feb 2019 15:26:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28F4F8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:26:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 207so6251154qkl.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:26:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=6V7GZEgaLdb3AGufdYxhSq8i0B6K6prabOK9Vgibzjs=;
        b=JzyoNgwNKjwTsPhGrtLTQIwN2uR55HGTYBtuFS3NCsCdUZQy7d0G2ylyvSIJPtUULv
         +s3y3EWvCg5X7A8lBHeY/doUw/B3hn51OSSlC17u1mEtURUOljZd6Rldg0/oaqBSktPn
         z1I9LfjVNM0Y1YxdfdTEgusrikGyEdnDFQXOh3s76yvnVMJ2Q2GvCnBk5WTHbCYj7HwI
         rriyIOOpPeHniZMKqWS7iHjyQHaZ8fHuFaT7Mrd6Li3uau87eyFXy5qHKNP0rs/rp1cN
         +AOwEQs1W3dmjrN146HUiUhQv1kdSqdT/fEvez4MgQvnFvjCVEc2AnmU0lnpGhgjsYul
         hAeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYmwlxDyYa8Fg36GyjefTtVbxyef3Q1XrK0JvcgZ/Xor9yMobTn
	ao/QkplIRAUzh4derqkv6tUzOtAKcfWY6UPPRhnam3bfUThG3nmc9EqcI7oh7rRChhvkCMLdnUp
	MEbT+dwvqFf4y1NkZ5Aan0WG3oaqzkZk5kFhaOPwuqE0LS7Jg4n37cFuiFi38gDRpAg==
X-Received: by 2002:a37:7cf:: with SMTP id 198mr4368228qkh.173.1550175987830;
        Thu, 14 Feb 2019 12:26:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ4JuDv6FdivdJksPHsgTw2czF1f4BbNj0SUmVJYA9IFHvVFROXOe89lcKbVnJgwTtC4zpN
X-Received: by 2002:a37:7cf:: with SMTP id 198mr4368191qkh.173.1550175987058;
        Thu, 14 Feb 2019 12:26:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550175987; cv=none;
        d=google.com; s=arc-20160816;
        b=f7GUkpQ3SijlT9DcAu6AV4DyHp1XhiJqylNRPlK2gezU18dbSu7bMFdF4Wl+ABuKGo
         GdWiJFWteFbaFsi61SO07vOHqHbH4KNuAV8fi4rMtL1r4/zkiwOZdPx1AmYJBLW/4o0k
         oelwtZR/Xoo31LF8Kv4Z0akf3DyagFIXz8aETgXln+P7Z4MCaoQOw4XBL5Ik9nVConUI
         wbIp4VC4N6kM5nUtJBp5Ur1hYb3kQJW92m3rk3u+92jUSvDh3cXfu0hN+3lgO1h2iWXB
         oFPl4N4MsPGMowikYH3eBjw3aBaTL6VNHu1YOJ9LLwyExac12I32/BeV6gWP0Fj3L7AP
         3Ydg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=6V7GZEgaLdb3AGufdYxhSq8i0B6K6prabOK9Vgibzjs=;
        b=irTx9zmuPAS4dvOQA88lhd+7b8/sB+z7Ym/xd5x+60hkj5g2Qfl5wj7ipdIVE7u0su
         xAwF74or5qJyJcbI2Nr2bCQSQz61IAFCY44+zU+iJBlBw096/vJxcETg3JkS69Oe1Zl9
         EIQq95pUlwRUdGkAjz+eiNCpuwX/0tkjCF9BA5GGuybVX0BGK+Yx3gyiEoQU2k8cBIJI
         6INSsK3gnr/qPYWPDHoLFMPoTtiSEM2tPn+aTtuKPDaTg1PBI0dvbEZk72UXGEQZ9eqD
         ZxNqn1km/s9HxM9vsUDTSCC0HLzn81TtCIKI/kRHTPxGFewSL9r9GD3oI/lLTGBOCOxn
         qCxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w193si2243461qkw.37.2019.02.14.12.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 12:26:27 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 22DF332FBC;
	Thu, 14 Feb 2019 20:26:26 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A588B600C1;
	Thu, 14 Feb 2019 20:26:24 +0000 (UTC)
Date: Thu, 14 Feb 2019 15:26:22 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190214202622.GB3420@redhat.com>
References: <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190211180654.GB24692@ziepe.ca>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 14 Feb 2019 20:26:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:06:54AM -0700, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 09:22:58AM -0800, Dan Williams wrote:
> 
> > I honestly don't like the idea that random subsystems can pin down
> > file blocks as a side effect of gup on the result of mmap. Recall that
> > it's not just RDMA that wants this guarantee. It seems safer to have
> > the file be in an explicit block-allocation-immutable-mode so that the
> > fallocate man page can describe this error case. Otherwise how would
> > you describe the scenarios under which FALLOC_FL_PUNCH_HOLE fails?
> 
> I rather liked CL's version of this - ftruncate/etc is simply racing
> with a parallel pwrite - and it doesn't fail.
> 
> But it also doesnt' trucate/create a hole. Another thread wrote to it
> right away and the 'hole' was essentially instantly reallocated. This
> is an inherent, pre-existing, race in the ftrucate/etc APIs.

So it is kind of a // point to this, but direct I/O do "truncate" pages
or more exactly after a write direct I/O invalidate_inode_pages2_range()
is call and it will try to unmap and remove from page cache all pages
that have been written too.

So we probably want to think about what we want to do here if a device
like RDMA has also pin those pages. Do we want to abort the invalidate ?
Which would mean that then the direct I/O write was just a pointless
exercise. Do we want to not direct I/O but instead memcpy into page
cache memory ? Then you are just ignoring the direct I/O property of
the write. Or do we want to both direct I/O to the block and also
do a memcopy to the page so that we preserve the direct I/O semantics ?

I would probably go with the last one. In any cases we will need to
update the direct I/O code to handle GUPed page cache page.

Cheers,
Jérôme

