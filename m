Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F13AC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:47:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42B8C218D2
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:47:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42B8C218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFE8F8E0002; Wed, 30 Jan 2019 17:47:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAE958E0001; Wed, 30 Jan 2019 17:47:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C78D18E0002; Wed, 30 Jan 2019 17:47:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C01E8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:47:11 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 41so1377020qto.17
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:47:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=k+Qnx2ZvqDg9wHVoQeNUVmxMd3pEPZoaaPmoYTVvJGU=;
        b=fyicN3xP2s3Vor4WqtVvy4K1SMRT4Yz3dmY8UoFYJgs1dlJZzLkGU+Q4Z2k/G0weXC
         ZmG1U8qlo0KuV9tIsbbUYjStyTaFd/+iHVaI561M0b1jlsKVpcHoQZkup56CjfMHQe5N
         Qz012SjyNFN6MgoNSmAJZ7YnrJJiyWZrjCiRlJeY18J4+ZfncZGOkIxSU4SOe0NmCluv
         Yd7Kq5+A8J9pH4sIBJIzlRltaagZXXntVS/h5xvnFyLOtOGor07BuVqwEnx78CF7b1ii
         LaLxNbEeJXHEA+JYdTpNiYgB1Fg6rs20Hrw3BOerFs4nhjnm+ZTV/5B47iI7vLziaQPx
         WQUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUuke6EBb/3Wu42x7pHYczUoF4UblySEGUUXn5TLPNyV7O4XbS+OLk
	YTYEXytKCEZDCxMgURezTcANljzwAtMucKhXY0bJ3iT/l5gVeFOAKhOfEnPELzziNy6gPD3s8x+
	frChP4FxuSV9ryHuXcdLBJQp1K/pCZtIeaeBjeGAEuYnqcK+ufguosheipC+e3zAeNw==
X-Received: by 2002:a37:6982:: with SMTP id e124mr29804910qkc.50.1548888431428;
        Wed, 30 Jan 2019 14:47:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4ZdUeoRgmF311TZ5hPATfuEVPTLHiR6YDgqemp2N+5BhExJn47wktANIHELTwVpXgViF2o
X-Received: by 2002:a37:6982:: with SMTP id e124mr29804885qkc.50.1548888430835;
        Wed, 30 Jan 2019 14:47:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548888430; cv=none;
        d=google.com; s=arc-20160816;
        b=YuipzDwoxYwAgQ80rqYqT7v8p1TjpwLiQR9/YxbwuDcPOQJ2cykeqqbofPr9uW1UGI
         XwxU2kaltUn8icG7Xe+HYdnDwxZu5kNfTuHlVqEdDiIY2aYOC1KGjMoOWr8SLBebzghZ
         /uoET47jpoE8tSY0CWzJ6NriIVxNJxaxwcrFr6+713kpjWS5aTzK2UNf0GX+vkF6y1hD
         DNFwjAsnVuAUSg/8kpwoKLs9ik7nRx2R94k20wEs7aWKyhCZNsGLE4HK27gNtZ+LxHJa
         EwS6ktWUBkr1Kt//hOm/k/fiJJmkou+h5U4q6xsax9VCkEhW4IgGC0cYFnBeixMOnbT3
         zMXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=k+Qnx2ZvqDg9wHVoQeNUVmxMd3pEPZoaaPmoYTVvJGU=;
        b=mbDZ64E63UmAD3pRivR22mqvZeQqKLTkwhj8wHo39CbXwojfv4kbj7hu8QNjRj50Bg
         pwHvINNFanGxkRQKRAmDov9E7+bgrGO9gbRcOt44HRQp2bp1+gLh8nshSvzsI20RtajG
         TLQL/if03Pq6rjwV6wZvvwoN7dEbUo8AJXmrQjq1TDYCzaTE9EAnWrkV36Wlk5nmROmO
         cKMlJfH4TkCopespXsNcF6Q5hGtOnIKcrs0GnnHQEcK5Ljq774ytbAu3vItwrjZXHWrY
         TzpkyJ0lPRHNv9Q6ejG3KW32QPE2dz0jvT4NMtd6UH5WLU4WjB5KFJWC8FoOgYBXf7ir
         BO7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 53si1933630qtq.250.2019.01.30.14.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 14:47:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C7A8EDF87A;
	Wed, 30 Jan 2019 22:47:09 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7CE701001F3D;
	Wed, 30 Jan 2019 22:47:07 +0000 (UTC)
Date: Wed, 30 Jan 2019 17:47:05 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Logan Gunthorpe <logang@deltatee.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190130224705.GI5061@redhat.com>
References: <20190130192234.GD5061@redhat.com>
 <20190130193759.GE17080@mellanox.com>
 <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
 <20190130201114.GB17915@mellanox.com>
 <20190130204332.GF5061@redhat.com>
 <20190130204954.GI17080@mellanox.com>
 <20190130214525.GG5061@redhat.com>
 <20190130215600.GM17080@mellanox.com>
 <20190130223027.GH5061@redhat.com>
 <20190130223258.GB25486@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130223258.GB25486@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 30 Jan 2019 22:47:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:33:04PM +0000, Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 05:30:27PM -0500, Jerome Glisse wrote:
> 
> > > What is the problem in the HMM mirror that it needs this restriction?
> > 
> > No restriction at all here. I think i just wasn't understood.
> 
> Are you are talking about from the exporting side - where the thing
> creating the VMA can really only put one distinct object into it?

The message i was trying to get accross is that HMM mirror will
always succeed for everything* except for special vma ie mmap of
device file. For those it can only succeed if a p2p_map() call
succeed.

So any user of HMM mirror might to know why the mirroring fail ie
was it because something exceptional is happening ? Or is it because
i was trying to map a special vma which can be forbiden.

Hence why i assume that you might want to know about such p2p_map
failure at the time you create the umem odp object as it might be
some failure you might want to report differently and handle
differently. If you do not care about differentiating OOM or
exceptional failure from p2p_map failure than you have nothing to
worry about you will get the same error from HMM for both.

Cheers,
Jérôme

* Everything except when they are exceptional condition like OOM or
  poisonous memory.

