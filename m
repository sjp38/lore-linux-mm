Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18297C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 22:05:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE9AA2189E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 22:05:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="RyUHGmb+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE9AA2189E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B30F6B0003; Tue,  6 Aug 2019 18:05:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23CDB6B0006; Tue,  6 Aug 2019 18:05:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B6E76B0007; Tue,  6 Aug 2019 18:05:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9C8F6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 18:05:40 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j9so1739466pgk.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 15:05:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=rN4rO17/aT7+L127LeaBuWusoBpU6GuMzRTNeTvQtyA=;
        b=io/h/A1dQ9ZhFHZMTn0Hg2UU6yKBpPYI0Gn3n74SlLuQoHKWHV+OXZOPzGdBtgtqdg
         b78JeOfHzw3tkWM6C0lnvK9ai/fI1A/J1uyjeZ/QR/ovlaAjMYRPGBmNaaGLaLm04uc6
         pbd9NFIqT5PIowijZPPMHe6TUa1qowyKwKDyWNnt/p/B1n9pSjYCEhcsBZ5/BChp7gvA
         OVLfpkimkqfH1oVNN1GX8Qkrjm4hhC4QS2jZfQ3B/WNWn7dp2UT/Xqusbfw/fL6cKKLF
         doF47Km591AMhpZmJ9PleLf9ZdMKa0G0Su3QkxH1QxfH9CxHd1dY0r9qB/WRmGQ7yGv/
         kS7A==
X-Gm-Message-State: APjAAAX28qzsYswCYIvTm36sm0PM6cg532iQqYoY2NFbY7bKZydWsBhi
	XrqasGy1euyUVGBz4YoVG6vUiVwZaMhPpeO8VPet0p0iM73Hm0ZFv4OrGhznKk8GGnX9j76mN7t
	/L/eGk4CX3QC2Iia+nkcR0KzfMlBo6yRbKCYCGBk0flJb8BhhoZlPllf3eBZ2tM2V/w==
X-Received: by 2002:a17:902:9a07:: with SMTP id v7mr5237922plp.245.1565129140449;
        Tue, 06 Aug 2019 15:05:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpuIPv/nHhFqeccntwrW9zFcoRdUDqeD11LPXMvpwcPIZmKQZBa/i0GdwDpye1huKZGa2p
X-Received: by 2002:a17:902:9a07:: with SMTP id v7mr5237882plp.245.1565129139809;
        Tue, 06 Aug 2019 15:05:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565129139; cv=none;
        d=google.com; s=arc-20160816;
        b=W7wcc7DuQIEXQSeOTip7XjYNlFIx76dwluHl23pku5WI3XnBvZkfBqDNdyhgdnI8y9
         0IrjlZPb2q8IxZygiyMvVDgQYilJ2f3ruEPMl2uBuoehWh1MMP7SPrTHvqZzj+Fe6Bfq
         DQcFUcg9IubUrlqYvMWhn7dTrJFsPr0hIFSWZEZt5rOP2gNxjsITRJ+jh63HAP2ohEv8
         LyUjdKZAPCiw4eAjNTjZzzns3OdYukVB2yxppFDitcX1xkuHBYJNvfJK/FuKAxGK+x7s
         uHaWdImdfuv0wrlERn23xKT3B0TDs+vxiiSTBl9huzC7aSF/d5d6In9VU8aE4lbPIQxn
         ZB9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=rN4rO17/aT7+L127LeaBuWusoBpU6GuMzRTNeTvQtyA=;
        b=bggK5a9dkDI7fo9uqvzaKy2nZwoi6atvQi7Z6uGzPQpqA6tF9fP0fVvoFDOWixh5y+
         84mSAhzLira4e0col+JKLXUpwrPGWia2ed5ues2cV9YzGgwBes8SsKlxWU2HuzL6VD7d
         o9vQNSnlqfe6PNN7UnOQ+LZXbXg8OLtBp6xdiDKld7yBLR68Tadhxe2G0NhpvaDM2MU9
         KYvkrH7Vh3QAD5hEw7F6/T1+CckBb1q5rMcqGJB1cpyPYXn145niEUQmAU4Nyyb1jQQK
         asMfmuL0/Vs+id2NQYO4kJ0wHYVR6pDZWK6Gsb7qBgW+LT5KVIM7a5y3nqA8MjTZ26I8
         PDBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RyUHGmb+;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id g11si74276793plm.390.2019.08.06.15.05.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 15:05:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RyUHGmb+;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d49f9b40003>; Tue, 06 Aug 2019 15:05:40 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 06 Aug 2019 15:05:39 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 06 Aug 2019 15:05:39 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 6 Aug
 2019 22:05:38 +0000
Subject: Re: [PATCH 0/3] mm/: 3 more put_user_page() conversions
To: Andrew Morton <akpm@linux-foundation.org>, <john.hubbard@gmail.com>
CC: Christoph Hellwig <hch@infradead.org>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
	<jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190806145938.3c136b6c4eb4f758c1b1a0ae@linux-foundation.org>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d606c822-df9e-965e-38b6-458f6c3dfe14@nvidia.com>
Date: Tue, 6 Aug 2019 15:05:38 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806145938.3c136b6c4eb4f758c1b1a0ae@linux-foundation.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565129140; bh=rN4rO17/aT7+L127LeaBuWusoBpU6GuMzRTNeTvQtyA=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=RyUHGmb+ONciHZR8TDcra6EGCiFc19hpKqbxJhOr5CXgF0u+AJ08BIc8YQ9TMG9TO
	 A9s2SNx+MQOxeMTHn3uY/yVZ5GdJ//1j13FexJcRa0b9agZTk3/VsNKAH6byhf+8uY
	 5C2+0NZac11xcQJNzTAlaXEQrJF+y+w2GMYO4mfiet5sOmrqRPueGIQPRDaGbCCyUm
	 T+fKwawV4VNNTsWpspkvC/lbu2zcbyLpZf2kqrj2Ity9iXJjT6Gv7fZLHNEGEUHcJR
	 HBk/OIw+SgIgy6VNZXjdZlETfaPAxScsnN9sFdRA5kaIWJpurj4C2Oq0zVysHK5aGX
	 iXaXX6n53Ozzg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 2:59 PM, Andrew Morton wrote:
> On Mon,  5 Aug 2019 15:20:16 -0700 john.hubbard@gmail.com wrote:
> 
>> Here are a few more mm/ files that I wasn't ready to send with the
>> larger 34-patch set.
> 
> Seems that a v3 of "put_user_pages(): miscellaneous call sites" is in
> the works, so can we make that a 37 patch series?
> 

Sure, I'll add them to that.

thanks,
-- 
John Hubbard
NVIDIA

