Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73D27C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:42:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C0B020838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:42:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C0B020838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5BF48E0003; Thu,  1 Aug 2019 03:42:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0B418E0001; Thu,  1 Aug 2019 03:42:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD4798E0003; Thu,  1 Aug 2019 03:42:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 819E38E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:42:24 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v14so35023931wrm.23
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:42:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=N81JjqJoxDL6NZ7plmuMGoLQCRMLPCNgHubis+t4h30=;
        b=PHFeFQwSk6u35S+faU7bKmoheUxaFNCgH+iezyGE9NfHiUsYtGKpVM1j88KXQEdqBF
         abzdKaPPQDHF7c97JMnk0IDS3jl1QIQEsJAGfSyOcOXgnbGjIRHQRISOiN5sSbs8jH+Z
         5v9y001omhYEmhshiu2FHpJZXBaoo9Z7s57U1w7CJUuBSLRUUTFO8uOXpiItTMbJauQ7
         FXBO8vYH1RxunQ1feIfylPdWhva2+cQMFIIsCeESP0ku2wxCx89qGDqWuyQjKszn8/8D
         0vE1jx34XPDRVjoAgw97ALK/uPsqGtZH8m9+aKCLFZP39qnVlvtDg6EnhFwtEggdFnmC
         x4bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWx3A07uTCEpP1OkfXb6y1p1WiWyJySBkQpwPXnwkpfqU2pF5RB
	S7VNJHIh/+4bxdKdiDMEkELDct4ETSHGYAS1/Sa0D7WGRXTcQW/eFKMJfaeg5xTE8sL2hsQA/Oc
	ZeFSLTby45xiOkqM1Zw6EN+OpjlLQPxKLAInLRMNYGq4/6k06N6pJsfOnNTAb06b7EA==
X-Received: by 2002:adf:e4c6:: with SMTP id v6mr132233236wrm.315.1564645344114;
        Thu, 01 Aug 2019 00:42:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydzNk4889xIC/vmrXwrnFED/fQ58Mc3dRQHqQ/ae3bZoGB9U4y5/hDzpv7rjm4poZPdknE
X-Received: by 2002:adf:e4c6:: with SMTP id v6mr132233151wrm.315.1564645343376;
        Thu, 01 Aug 2019 00:42:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564645343; cv=none;
        d=google.com; s=arc-20160816;
        b=OkIcKGfgowAiXgY5xlmLfCnb9VBt8kp/Rt5E8CK/nIJTDTeXA2pA0hJjE399uTr2Rd
         AGk1SABFY8U3CxzAknRMt8Ygu9wsmm9evOleXv6qWAPthWl+17+f2LtyBFpaftsVTbZE
         O/8OXP3vpnihZafD8fdWn71ecCKh6T91dmUQHeBMFL5Yt6UD3ULVJ6eLiSxvZVB5YCIE
         PvL6CRNsO+VTY1v+i/Za/0MG1P5GobOv1l//DdDLWhJ+YIoVYeiCvntQjJ0FRQms42W8
         S61l+vmNxMO2c92XQUItyFthvEwiz7WH+zQ8kczmhHflB1bjy7BcPhnNxwyduQ2VZ6tN
         mDpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=N81JjqJoxDL6NZ7plmuMGoLQCRMLPCNgHubis+t4h30=;
        b=IYOmmfo9GnEqXXZZi65koqE/oI6SfY7+SdTYTzTSZyZ6Q0+0xwqckMBI9Z0DOJuQ3j
         Wr6PRNpwhfzNDi2eezF+NvoF/nZUTEEjfaHDFZl0vLDid1ypfwWCycaxuRhPtpqQ8+V7
         sECJnLokfG6HRkWUrO6GslsJ9f5Oir2eH0Xe8cgRoISLK9yYAxHigZ9s1tYnVwaxp0UX
         fs+UsGqHrBxnqnsbWCaGCjFFw//PxlqwTpS+zXaktizZmA4cmddSXf0eQv3bJVrab1H+
         T/VWR+AT0LJfJcm2Fjfh/C1AhzByWHpBsn/j8KgTrMPuz5RjJrfqBgkPd99c6ru4rxeY
         yN2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r17si67649830wro.143.2019.08.01.00.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:42:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id D5C1E227A81; Thu,  1 Aug 2019 09:42:20 +0200 (CEST)
Date: Thu, 1 Aug 2019 09:42:20 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/9] mm: turn migrate_vma upside down
Message-ID: <20190801074220.GB16178@lst.de>
References: <20190729142843.22320-1-hch@lst.de> <20190729142843.22320-2-hch@lst.de> <33b82c28-74be-8767-08fa-e41516d11c7e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33b82c28-74be-8767-08fa-e41516d11c7e@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 06:46:25PM -0700, Ralph Campbell wrote:
>>   	for (i = 0; i < npages; i += c) {
>> -		unsigned long next;
>> -
>>   		c = min(SG_MAX_SINGLE_ALLOC, npages);
>> -		next = start + (c << PAGE_SHIFT);
>> -		ret = migrate_vma(&nouveau_dmem_migrate_ops, vma, start,
>> -				  next, src_pfns, dst_pfns, &migrate);
>> +		args.end = start + (c << PAGE_SHIFT);
>
> Since migrate_vma_setup() is called in a loop, either args.cpages and
> args.npages need to be cleared here or cleared in migrate_vma_setup().

I think clearing everything that is not used for argument passing in
migrate_vma_setup is a good idea.  I'll do that.

Btw, it seems like this was a fullquote just for the little comment
as far as I could tell from wading through it.  It would be very
appreciated to properly quote the replies.

