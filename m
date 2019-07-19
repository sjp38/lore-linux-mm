Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40A33C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:01:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B47AA2085A
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:01:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B47AA2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 159636B0005; Fri, 19 Jul 2019 02:01:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E9956B0006; Fri, 19 Jul 2019 02:01:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9EB98E0001; Fri, 19 Jul 2019 02:01:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3EC06B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:01:01 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 21so7489789wmj.4
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 23:01:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=E4NOZhc2hlM+rYFUuQgA7cOpDpsOPnWnLITEIegWhEE=;
        b=YSL2DiCPvVyzYhJvWXktppBZUytcwqfu6uWqYhqqXSnH4lKG2CvxHJH+8N9Un3c5Ks
         E9W9enM9Gehyygpt97anIwk+pXZYiq5hfkDshZ37LRatk8svuIgEcxbmVHaU5yjWOeva
         gYkDLVZ9c/aZICLgahO91mnjcJjIhpEHj2Z5QJgrUMPTY8hOSvUFpjThoOBlAzSI62un
         eVtRr3X+qG+xJyoBq40UgXn/hXR6Uz/fyIGZg5IzDOCRZJc5h5qHq/djwe550kLTfLSY
         6HhcGVBqnYqiFZCw49DMkpiaenpWB6hMQR20W0YvSEpwwTe8WX4f2yWkOyI5OpoU8XTv
         TrxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUWIqzml5T2avOu0BHh1pebyaMU2l6ti8++ZqIE27jwutA61LWC
	yHVycVBvhop/qsW01QsHaoqSwvYRwWNGLYBRAYDbyObARQgpzgOuMOlOx7qtn6f4QCgFTJEPUgQ
	NknVW53dcvHf1Ygwhc3iP7Kh8ScQCvMaFFjRWlFN+t92kAMxR+lFrGRxJpbUoYOueQQ==
X-Received: by 2002:a5d:670b:: with SMTP id o11mr54053007wru.311.1563516061176;
        Thu, 18 Jul 2019 23:01:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwL/HYv3I0SmFu8ZWWaq24EBRMIgQ8wFrBIjAnHYTUPWK1Z2gKvCBjP4UR7oU8N77kFVh8H
X-Received: by 2002:a5d:670b:: with SMTP id o11mr54052866wru.311.1563516060060;
        Thu, 18 Jul 2019 23:01:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563516060; cv=none;
        d=google.com; s=arc-20160816;
        b=Sz2cE7GAqddTHSyzouaVkvNYR861+y/SGsoyQtH44Fzp85uNkQUh2/CmtZQ3QC5S/g
         rDPtlmAHPjbfXgPgOYLrdg6nHrPHRIQ0IRo+JwZ/Lax7Nh6O0PXOHrnWBkh9LpV4+Aoy
         /JEcpTJnjO/tYEU49KJs3aJ6NkmGXBHN5xaemCnsnxvENzEvCIPgB1m5A6bVuhnwyHh3
         TATeNEhARKcLzIVfymkj0T5wsKMEL7d2J9fXhnF/bVF6e/t3xfzk4oH18LBjApR7oMsY
         1NV6hO8LueCx9IvOvotoP3mmJT1SK1AsTYS9iVNNenQE5zkzj1KOM2OKU59MW2Ux7SEY
         GWOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=E4NOZhc2hlM+rYFUuQgA7cOpDpsOPnWnLITEIegWhEE=;
        b=yudb5il/evGd400rGxu7+/Wa3v+h9BIGTdX9OZLL/AZele5nNX3z2ZS9DeXQHx2sKd
         6DIvJtWljymZ6URRnW9JdvGARXdZqZQ3ROe1oL7+zXty0YVctpib2/4mX+2HdEtQ8Nwd
         diJB1XMEvWML3XvgIjWQImsAxiimVtS9I5MvaGrLqE5L0Lbvbbegv7BmfGNyzVFqN7ZL
         nSdbDEX5Vnf7VUVuD4F2mULn6JfOHetCc8ZX3gaMdxnfamNFenAB3Dt9+yHYJHONhshY
         osWWcn4HwTxIodm9U4oVwqfd6H8bSawrecbqNRDR2464bSxzpKY+4l3WsPaJ4MmyrzMY
         RP2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r22si24435341wmh.136.2019.07.18.23.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 23:01:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2F96268BFE; Fri, 19 Jul 2019 08:00:55 +0200 (CEST)
Date: Fri, 19 Jul 2019 08:00:53 +0200
From: Christoph Hellwig <hch@lst.de>
To: David Miller <davem@davemloft.net>
Cc: ldv@altlinux.org, hch@lst.de, khalid.aziz@oracle.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	matorola@gmail.com, sparclinux@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
Message-ID: <20190719060053.GA18491@lst.de>
References: <20190625143715.1689-1-hch@lst.de> <20190625143715.1689-10-hch@lst.de> <20190717215956.GA30369@altlinux.org> <20190718.141405.1070121094691581998.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190718.141405.1070121094691581998.davem@davemloft.net>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 02:14:05PM -0700, David Miller wrote:
> From: "Dmitry V. Levin" <ldv@altlinux.org>
> Date: Thu, 18 Jul 2019 00:59:56 +0300
> 
> > So this ended up as commit 7b9afb86b6328f10dc2cad9223d7def12d60e505
> > (thanks to Anatoly for bisecting) and introduced a regression: 
> > futex.test from the strace test suite now causes an Oops on sparc64
> > in futex syscall.
> > 
> > Here is a heavily stripped down reproducer:
> 
> Does not reproduce for me on a T4-2 machine.
> 
> So this problem might depend on the type of system you are on,
> I suspect it's one of those "pre-Niagara vs. Niagara and later"
> situations because that's the dividing line between two set of
> wildly different TLB and cache management methods.
> 
> What kind of machine are you on?

FYI, I'm pretty sure I tested this on Guenthers build test qemu
setup in the end, which further speaks for the different machines
issue.

