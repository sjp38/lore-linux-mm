Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B79B6C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:05:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FFC220659
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:05:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FFC220659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 315B98E0013; Wed,  3 Jul 2019 14:05:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C5C78E0001; Wed,  3 Jul 2019 14:05:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18EA38E0013; Wed,  3 Jul 2019 14:05:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D7D618E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:05:27 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id y2so996468wrh.3
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:05:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uZ5oBeSwqaumWmNN7miuUpJqKGfdgeUUQ76zptibU1E=;
        b=pS9GI9DEVd90LqWjfFCnCpCE0aDAn0n064h2j9wBS7ZZwJ6WynbAL81dFTvPz8rjd2
         akOJfUYlevf4ob1xO18mm/0m38I6XkcwEEIZjcg0ay9AahSvaRVgG/kgFa9iJL4LMlwa
         kbfnJMZxfqdnFDqI/6D++bAQbp7JujyktGdCD8BWe6zFif7EC7plcX/ZI9orLqj3C33+
         /2txxqbbVe4Q1IA4VxariFTCkzpLUrS6RXKuGu139l17Gaz8P4SLTzFZavDwStjuy5rR
         fGSRTLVJQVs8/t46k3EmfoJBXq4Ve8SSdbuA2teCuTex6HNUUuKGwCqGy1zdPlF+C6AK
         1ufA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAX80bWskheR25AtV5m+tpL9T2OocsOf6FLGXq6ayMExwTyo2Jmm
	pnKAAXV6mYCQSECflZS6LyrQaF3m5Z5A8OeXB89/+717+7SIpJthmFIlxkhYv+Ug2qgMdK+MQpV
	tKij8nhMXi2u+li1B9gbmP5rACiPZ06xnH+DJaWl51YaFg1xhNvZpYnRl1Y0BeB8AZA==
X-Received: by 2002:a1c:e28b:: with SMTP id z133mr8196201wmg.136.1562177127438;
        Wed, 03 Jul 2019 11:05:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzz8S+nvCD6EIZJShLryNKc4JPhzp1UD1SN4xTZJcKPHW1Am8rzAtyNe9lTYAVgoU0JBxLj
X-Received: by 2002:a1c:e28b:: with SMTP id z133mr8196172wmg.136.1562177126747;
        Wed, 03 Jul 2019 11:05:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562177126; cv=none;
        d=google.com; s=arc-20160816;
        b=l7rvIV/HMzs0F4FwbYpHU+VV1DPcNikeTPYbjSW+D0sBPMjl8xleORp0GYwLD6pgn2
         w6z9X07+lOAlhPC5KApAbHSOAhoMGHJymWkds8IXAG7oPdAfNh3O4cfcY98FVEJAgMfn
         AOop7zEoAvkHFneqa6Kck1Zp6RERySRFBhENduKXK+CUtAuTsDQ+sXgemhpBS+6d5BU2
         4grw0KQXDQOMurxgn4+itTtCYyTVwFJIc/w47QkQ/TTj0C2jBa6+BDT1N71U/nqvfhzP
         62VsWvWxTjlppqOWzHKmTLGSIMn0fM5oZXJhCmi436CZ/n0q9ZZJXv/2nQIzDjV0Bw4M
         uh8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uZ5oBeSwqaumWmNN7miuUpJqKGfdgeUUQ76zptibU1E=;
        b=J+SPnEqzuf1zMOqHQ4A+USAkrNVxkYIpAT/OlkiYROdPJg/cqgbSIqIPF4HPqHaE6Z
         4URj0Z7hVtIyzTk0hRKUOsGVnUPRGhYvSekxzX7IOlBYPu9WHMWdEnThnqC+h8W6gqdU
         Nxj3pj0v0CN6JWG8iqG/8+6ErlBgmnTZ4BE+lSq4N5TcVQFsQ6EhL1iWubz4NIIY97tW
         nNekJHWHGFAf6ty+VLeIJTj+5rBKTLp8sjNnifZzNJcK7uz3sxLXdVf9oY2nYcW3Oi/z
         gCBUmOQ3qyrW3rKRvOm4zZSKNLqfYupr4+r+vWYNN5Cg9/CY8cVyLcnAPd1PIJlcWyEx
         F+sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s2si2431059wru.119.2019.07.03.11.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 11:05:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9950C68B05; Wed,  3 Jul 2019 20:05:25 +0200 (CEST)
Date: Wed, 3 Jul 2019 20:05:25 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>, AlexDeucher <alexander.deucher@amd.com>,
	Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 20/22] mm: move hmm_vma_fault to nouveau
Message-ID: <20190703180525.GA13703@lst.de>
References: <20190701062020.19239-21-hch@lst.de> <20190703180356.GB18673@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190703180356.GB18673@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 03:03:56PM -0300, Jason Gunthorpe wrote:
> I was thinking about doing exactly this too, but amdgpu started using
> this already obsolete API in their latest driver :(
> 
> So, we now need to get both drivers to move to the modern API.

Actually the AMD folks fixed this up after we pointed it out to them,
so even in linux-next it just is nouveau that needs fixing.

