Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A38BC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 05:39:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 220C12189F
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 05:39:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs.org header.i=@ozlabs.org header.b="eD7AWdyT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 220C12189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ozlabs.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99EA38E0004; Mon, 17 Jun 2019 01:39:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 928F38E0003; Mon, 17 Jun 2019 01:39:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A38D8E0004; Mon, 17 Jun 2019 01:39:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5B68E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:39:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so6378226pfb.20
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 22:39:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MEuTygCJ6Xax58DR+UcV5guqG2CkKwNktr/dWSO/m8U=;
        b=DLCtB24kiIEXCKPKd/qmJC+OEmaQMggeJXNFd/Reh3KL/SZErfEU1K5F8EcSrYIx+1
         xF71yEyxHkALPbpG4/8BNCZD5I1mPWT/wzt/Idwt1g+KfHqQpzDeukWZyVT9z/uHHeAK
         jU98l9F8gatgqRSjKfem73PraZqciI+jlk1Hvp+oj3UmTWTS6CN9obpOw+k1dtmQycm4
         8Vt73AJmLYOA0azaTeuX5XW7T4jVbVlxqGlz5Wzxl7f0f/shGGj3AYRYNib4f9w7+4Vk
         VTfD4PmVs2X6fha9wpps6yTQgoiyC6rD62Zvf0kmtjeiOrKgJVdNfmOLRzRDoQi2X7AV
         wRcw==
X-Gm-Message-State: APjAAAVF5WRG8nH93aWIzKzl5b5LpKpxQAbBNWuYQChMUZQCmRI8YjY8
	VEGrJhven6V1Pplwk7VCXPwCWgsUNsIXMkSlUtqCjtuivRY4XAQ7iQfVNUFX33t+q+D/9OjmtWC
	iAEFCZgIi0h3gysf+EWVzfIQrvnWiQvnXWWTyY8m+/4Sp3eM1rXdoiCef7VpZ3XgOuw==
X-Received: by 2002:a17:902:bb90:: with SMTP id m16mr37754647pls.54.1560749942811;
        Sun, 16 Jun 2019 22:39:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2v2nY4uY2T/SRyK0emXSvuq2dn+Z3re550UaYa/+4bb5/K2NIBqbwhuFihzLsFZnsb9Le
X-Received: by 2002:a17:902:bb90:: with SMTP id m16mr37754605pls.54.1560749942026;
        Sun, 16 Jun 2019 22:39:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560749942; cv=none;
        d=google.com; s=arc-20160816;
        b=IlK93qaDSaQspkFu52c+uxB8HjDowoM3znoFHijIYrIdT5RT6aTdcgQcRKYwe0Iou/
         lTyMuqacUlVLPiX+aRPcxrlCHroQnic641OtmxbR8g+6UGcJ6pf6JltmbZCIY1WxJZ5d
         w/F7TMtMuEVN0q8m2AQIrxlolOs1yKkOJVZf4xHM9xK/JW4RbhZsDIATZJR1cG2VAg2b
         8oLY/uHTPOB0lZNnqPGq3SJv/9K4DuzTdLvGRKh18+XiAOIfiZwsF4hC8qNpLc2j86kq
         WkQDnTrZ9ggYGIRb/u8aUuMGMeUChit9UKvKGie19ckBa2GJtwgPhHSJ4SI4cwaxgZO9
         6h5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MEuTygCJ6Xax58DR+UcV5guqG2CkKwNktr/dWSO/m8U=;
        b=pBC6+kxghE4xcDeOpj+j3QdTBeujXjv6hboau/xLIRIi+7cYMlCNOhLV+s6fgmC7A4
         6HBq84Ht2dsrP1Cx6fraeDdaOphQAXYo9TMgocPv266Y4o053sjJz2UOiZMm6HSY6mA2
         vvjQAW6fL1ctRFQO3pTXS88pXnETyRkrM2KNe8FmD4hC2Lm2M7oka/TIEsWzYfEHuTRP
         tCX2YsJT+j9FSVnpBtmC+iaidrhMxa0nEXWihkcCk64wBGzF5QzPwcR/LKCEZOjmIMbx
         Yoe/88Mpyc0HIIANZsArT70iY9O26uQI9sfsmPKHCXoBvxJ1zBBuiBPjv99ccshVpEVK
         qYkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=eD7AWdyT;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 203.11.71.1 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id s11si9549061pgp.326.2019.06.16.22.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 22:39:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of paulus@ozlabs.org designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=eD7AWdyT;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 203.11.71.1 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1003)
	id 45S0Ps3h6Wz9sBr; Mon, 17 Jun 2019 15:38:57 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ozlabs.org; s=201707;
	t=1560749937; bh=dZLUB0K5zrKTMsdEtdgkBMLfWZFYjrdP1VEZ//9dUfM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=eD7AWdyTBgymNpigRRjlwERLwtz6+5IChPlo6tHPrxOURmrv98db8J5lCApb6YzII
	 UYl3AnywVl7MTAtOij4HF01ADdMY35yKXfvU6/8pMBTb8gXHGOf2mYLRm8HegSgQck
	 qMHlW+/lnMQZCsSG75fQDuNcf17Izc3mLHUjShvRcjQ2B2GPTvPP19iznAPVzabihg
	 /hQ1PUtN7jZqTYHlqJD5VQPAMRnZfXx0s4pAnM1c7kYei4KBoafU7PPaQGCcAiPqj/
	 4CS602Ceg11qIljPAT9rsVnOXFdPBHH+ViwSOKfXAKsCJo0vHeZSFT89Vt2BkuW+p2
	 fg4dE4xYnjfyg==
Date: Mon, 17 Jun 2019 15:37:56 +1000
From: Paul Mackerras <paulus@ozlabs.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org,
	linux-mm@kvack.org, paulus@au1.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
	cclaudio@linux.ibm.com
Subject: Re: [PATCH v4 3/6] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Message-ID: <20190617053756.z4disbs5vncxneqj@oak.ozlabs.ibm.com>
References: <20190528064933.23119-1-bharata@linux.ibm.com>
 <20190528064933.23119-4-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528064933.23119-4-bharata@linux.ibm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 12:19:30PM +0530, Bharata B Rao wrote:
> H_SVM_INIT_START: Initiate securing a VM
> H_SVM_INIT_DONE: Conclude securing a VM
> 
> As part of H_SVM_INIT_START register all existing memslots with the UV.
> H_SVM_INIT_DONE call by UV informs HV that transition of the guest
> to secure mode is complete.

It is worth mentioning here that setting any of the flag bits in
kvm->arch.secure_guest will cause the assembly code that enters the
guest to call the UV_RETURN ucall instead of trying to enter the guest
directly.  That's not necessarily obvious to the reader as this patch
doesn't touch that assembly code.

Apart from that this patch looks fine.

> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>

Acked-by: Paul Mackerras <paulus@ozlabs.org>

