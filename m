Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEFBBC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:29:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BF1F2085A
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:29:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BF1F2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28E866B0003; Tue, 25 Jun 2019 03:29:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23E038E0003; Tue, 25 Jun 2019 03:29:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 153CB8E0002; Tue, 25 Jun 2019 03:29:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8BA16B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:29:47 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id q2so7504284wrr.18
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:29:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fiDfl6thwhLhapszwH9MhDWa2YeJyq81IolM/b0PlzA=;
        b=rjPSPXL4tk9MJu3XLJuW8vzaA9xMFRjHk32Th6IxK7MByLVr1wsloESXxsVbbCoZnR
         75Y4XYzsFeXXQPzAq9xpKsRbCekqOMMbvW/QPDRQD3ep+xT4hGsIfAdugLlUBFei5LJd
         qTeP+vdkesQeKjCkSSl1meB6tX8DJGCo+yMl78/UY+i/QUS74/W4HDPkhKKhTBvxK7bm
         71F6YqQIQhwz4kFz4g14MR/PwRHgA6mAfkYFzXyweL3OKISDKkl/0y4IqAAIKNb7qTY1
         +tvmO0rbjOqa1BF5UePDN/byb4KUgGxaFxAD3Lt01gvFN/lPbVz0DBoOIww8tJMoEoym
         u0aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAX406tyI7gqh7elnVNPNgdFWg1C949k8gdtIRjtAgkt9Ylvs0Qh
	iNKYhxM5szMKZczZsThq1zE6ogjQcKiQ6uQ86TPj3tXIj/P7XE1BBHRujqJq99La0eBL1gNWmDw
	mO1Shh2NkiucJiMjHFmEt6h9VqWImWGTVBHEtGwzPBqBgP3Jv+ycn5jdxOPpAjZEmbA==
X-Received: by 2002:adf:f246:: with SMTP id b6mr54879367wrp.92.1561447787411;
        Tue, 25 Jun 2019 00:29:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZJzF3vcMNasw+eMrIxdfBR+ltFofLAhYG4DFeg+vHm+7AdxegThXqqvCTUA54de0wAKuI
X-Received: by 2002:adf:f246:: with SMTP id b6mr54879319wrp.92.1561447786744;
        Tue, 25 Jun 2019 00:29:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561447786; cv=none;
        d=google.com; s=arc-20160816;
        b=HiaZ8dYqzeMqHx21GPAmwfAJ+F4prM8YLyT4Ap3T5uIL6iwiAfJfIRBlw13GwaeF3H
         ak+nIrVyAFJipLolW67e0Sahe7dP0nxRkvhvOk3TzqKYrptZBGEmS0Yc1/hqxCxjhkxt
         /D4svAf+C5bzqoq7dj03MczD4gYt7HZu5WfdA665K3qNySFz6KP5bWbmOTq/vB1knJHd
         bPYbaLmb01ii9lo/lXNomO1LbbJFi7g1pX64Bea/PmvxqMY3d2UdcUn46/aZgCdYdK+B
         O94Soq8wEr8LNSbmvE0mXXFY1VCVifb5Mybcjy5BXHSGz3Co0pARlCau6LApjdJMQZRr
         w2mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fiDfl6thwhLhapszwH9MhDWa2YeJyq81IolM/b0PlzA=;
        b=JTbxpl8SJ5WkfP9ykqhQhz88rsWCnnBjG0NgS3PsEehq30g5FzAqaAgs7bFCLXra8g
         fWZdXgpQ38rGWK6TbpHabYXywI7etDHY6PhQVQ1z3D1jTwRxpF8Dgfy5lcxSj3zuLHLX
         tpl6kOxuG6poEz5kBwlGB9lUzD6S5Z1zi2Ywe17sO4V8QjcjOktgZhwzXq4UiJaFAwEc
         U8oRp8HtxwqwpVOf21CCTKN/49C/gYCZZNI9XIb7BTd4NrbN6S4bjcNqa9YBAHVNV2KV
         Mp+wp2NQY6KXCqL1hOQa3at2iiK5BgfU189/6w8WXpFf7N0jS7eH6vJAeRo71802mllz
         rBEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r5si11255492wrq.102.2019.06.25.00.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:29:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 0839568B02; Tue, 25 Jun 2019 09:29:16 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:29:15 +0200
From: Christoph Hellwig <hch@lst.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Message-ID: <20190625072915.GD30350@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-19-hch@lst.de> <20190620192648.GI12083@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620192648.GI12083@dhcp22.suse.cz>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 09:26:48PM +0200, Michal Hocko wrote:
> On Thu 13-06-19 11:43:21, Christoph Hellwig wrote:
> > The code hasn't been used since it was added to the tree, and doesn't
> > appear to actually be usable.  Mark it as BROKEN until either a user
> > comes along or we finally give up on it.
> 
> I would go even further and simply remove all the DEVICE_PUBLIC code.

I looked into that as I now got the feedback twice.  It would
create a conflict with another tree cleaning things up around the
is_device_private defintion, but otherwise I'd be glad to just remove
it.

Jason, as this goes through your tree, do you mind the additional
conflict?

