Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09E6EC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:50:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDAE820657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 17:50:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDAE820657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63F7C8E0002; Mon, 17 Jun 2019 13:50:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F06A8E0001; Mon, 17 Jun 2019 13:50:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 506B88E0002; Mon, 17 Jun 2019 13:50:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 052B38E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:50:29 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id f189so32022wme.5
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:50:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FCZQDrIijS26rr0glJes2gA9h8B8s+jutdZKJmQLjlE=;
        b=CsAAW1jUuARJJJoim2LSs1R0njGd1Q8SWcJ2y4aw1QyMUGxoDTm2hP4B4Ex+qQuN/B
         0Z5xfV5GElfHwGrV293OvntQ5Uc/HeOYZBJQE6TWFEr/T4o0bPnZIIspsCVByA0j74fG
         UwNpFRK4Gmffg0tsWtpk9EirXVq1PJWbAvLuLsYaf7uKL7B+cOs+5PfXfddPPUt4kdby
         IiB74CnNY+r6XCw+HdpiUQBwg8YH3GWWcu1OwgIwLjaFLMoJFHyD3oXiIuqFnQrVWc3t
         3cgqAIG8I+fcjOoG7lZVRwFU/1GPgw6txJghBquOEMJhzyFdLX+CUwluIHVg2I0WCEix
         cBhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXzQL2TqJ6tNaxwyIZ1eaBqkq31JrcFzD2bm0flwJNyiGGyAZuo
	+fd//i1P5jHRPc7MexRWRTQDCbKDeVGyZ7/gapMApIVj5a8XYyh50RVhSSze3ahT9qfGchZeOlO
	UnrvkADOyWETVne05mxsxe1Ce1c0T/k28fzQsAYgmkg3s1dGLwXpMTN19r4d7cARM7w==
X-Received: by 2002:a05:6000:11c2:: with SMTP id i2mr8530299wrx.199.1560793828011;
        Mon, 17 Jun 2019 10:50:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqys30z4yQkaCsrE5Wt5xxOAswjCvjfYN7J+NJOJm55i/nCtedntUl9JyFZ/HjLFba9qi53F
X-Received: by 2002:a05:6000:11c2:: with SMTP id i2mr8504405wrx.199.1560793247588;
        Mon, 17 Jun 2019 10:40:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560793247; cv=none;
        d=google.com; s=arc-20160816;
        b=JmeBoCIGwVDWfnXDLMSXC0m8RYhC31Qn62u1BtJ5mqTl4er5ElXAra3V47N/evzv8r
         ateEMwDEOqcd1EiBoXiSSZHQ2AO0aRMKRuasTylBGi2YKhdmkrIVxEg79BcLgXSz3MJv
         oY94G3xVWThyV9RzrIlHRWkxlBFWHHvA1gGU6RMr/J4Tfo51pyDQBQNTuYI40uhrxurw
         qHu46OMBdppr4fF8SEe4OlIO8i+esJYaoWsQBH1ZaSwFjOJUXl2bvkLGxVp7KYb709LG
         yT0CQR8XnQJJzD4ydxnOj7KZocVt6u9SQFL4QElnNdSu3U+avgkB8zCRRIX22guPJl3K
         /l/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FCZQDrIijS26rr0glJes2gA9h8B8s+jutdZKJmQLjlE=;
        b=MidVDNdLrxd2WG4OpARtGPMoV7bud5ulecB7QqAGF+Xn5W2NbcbrmIoomdPxoGxXvt
         Oky4L5mVPnM8f12+hS45Vw6pp04NIsEvqd6Sytw493/1zFC1Lbw/m8tWlxN+23u+7a4V
         UTWQ1WFxKjK1LaTK23LnvK+rqu5G8lUK5KOW0TX25c8yAL8ME1dDYDYuqJGry9uBnEwy
         kDzbBWPf/1unqvAVXSI3KbD07aWPmlhhFff4sh1NG6wAi50F6iJwbNq8dA5cewS+oGRE
         flzo0LQxoF+FFU7LMEQuTOAXcghklmuJ791dOeyyYxh1Mp8IFV7fVN29F31fHu5fivs9
         6IpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m14si848824wmg.108.2019.06.17.10.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 10:40:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id AA7D667358; Mon, 17 Jun 2019 19:40:18 +0200 (CEST)
Date: Mon, 17 Jun 2019 19:40:18 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 06/25] mm: factor out a devm_request_free_mem_region
 helper
Message-ID: <20190617174018.GA18185@lst.de>
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-7-hch@lst.de> <CAPcyv4hoRR6gzTSkWnwMiUtX6jCKz2NMOhCUfXTji8f2H1v+rg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hoRR6gzTSkWnwMiUtX6jCKz2NMOhCUfXTji8f2H1v+rg@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 10:37:12AM -0700, Dan Williams wrote:
> > +struct resource *devm_request_free_mem_region(struct device *dev,
> > +               struct resource *base, unsigned long size);
> 
> This appears to need a 'static inline' helper stub in the
> CONFIG_DEVICE_PRIVATE=n case, otherwise this compile error triggers:
> 
> ld: mm/hmm.o: in function `hmm_devmem_add':
> /home/dwillia2/git/linux/mm/hmm.c:1427: undefined reference to
> `devm_request_free_mem_region'

*sigh* - hmm_devmem_add already only works for device private memory,
so it shouldn't be built if that option is not enabled, but in the
current code it is.  And a few patches later in the series we just
kill it off entirely, and the only real caller of this function
already depends on CONFIG_DEVICE_PRIVATE.  So I'm tempted to just
ignore the strict bisectability requirement here instead of making
things messy by either adding the proper ifdefs in hmm.c or providing
a stub we don't really need.

