Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41659C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:32:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04ADF2053B
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:32:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Cj6EGJBe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04ADF2053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 584206B027B; Thu,  6 Jun 2019 15:32:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 534986B027C; Thu,  6 Jun 2019 15:32:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 422426B027D; Thu,  6 Jun 2019 15:32:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 214476B027B
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 15:32:34 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n190so2910379qkd.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 12:32:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ReUr/Ku4fFDe5ZS2T9E9QBdlSpBszMAhDsjnGAK3/wQ=;
        b=R5sqAEKdemUWYmHBQjsnfoj12nKo2pnZFg5HkDiN3MkDy9Mpk20zHuF6ByF4r9DRob
         KBVZhu9t1KmRRmfFcV+N7nxh9tNLFpNqxQq5KfFgbBUpZ5Q5N2dEF2h7PLr/cSh0VN/b
         Pkrn4jNWA68VpVKfP/6wbLo61ltYhxbTW03ag56DXHBckIbJ86xrNLF3JFWRAZL/v/pE
         Y5I7U1H2/FE/ZxyVNOS9tnsagJawM7DvVh2nZY/EsfPKkMIkh6VouE2qKppLMk2hDcYL
         CqJYGJSaa0A5Xc7sQN5k0aZTZeURII+svuWQQB5tCcGvPKknD2vlTdWsRZXRwVXFpW2T
         0G5w==
X-Gm-Message-State: APjAAAWI/iOrtQy0MUsOcBSo/N/Ci67mSem5HJRVs79dMqtGxTcl48Sq
	mU8+D9cCfMmzmVyH3UR8lKxdAHGHkuTxblpDJwz3/8NNykEdBuJQiatUQcMUTk7K/w3jveBvBGe
	2L/sHr3M8nOt8zK1XALD0V22s6cApdGtsjv/o6i7prIEBx3jbUvuxYXwJvNaMCinGig==
X-Received: by 2002:a37:4bc9:: with SMTP id y192mr40599591qka.178.1559849553894;
        Thu, 06 Jun 2019 12:32:33 -0700 (PDT)
X-Received: by 2002:a37:4bc9:: with SMTP id y192mr40599555qka.178.1559849553448;
        Thu, 06 Jun 2019 12:32:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559849553; cv=none;
        d=google.com; s=arc-20160816;
        b=MEErZAxr7/apcbSaM0qFQJyb7xG9a6nLvzBZoxIYFtlK+ThlDNHa254GXBfFdDRD9b
         xJ+IEgFlNj3MmQWVRs1nCI9VXFF6x0Dw7JlROJhalUZujvO7ltTUdfIi0/vAvnxnIDYc
         gpEWQScCKx0/lPtv9E1cD2ckSX+IOYkmJOPyZGylgOrm2448e+rMyDR7D+Dg5zAE414A
         NvTUFY4iPaLRr14oD/e73/UHfMx1lQcpqlluQGgKLdx1u4igo/HOZd3EXiHgdpjZzpyW
         +8zaAqItTjUftOsdaGgS06tdm8JUfSfDn4J35LcH9ejVijVDti7P2L/Fz6Z+uRfU8FrR
         uesQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ReUr/Ku4fFDe5ZS2T9E9QBdlSpBszMAhDsjnGAK3/wQ=;
        b=uWPl26JAiXYpYgrDqJabu0E0zX+2bEUTp537pKQSGJ2k6T9lpzs5jX4B5oHrNpNdoc
         9aVW+ESOsdAYXYOG7gYqQnVCJA8IheNBaNIz+adZ5uZT7+qiflt3OOndXqpxYjYXeBcp
         5srIrmCAAikwT+WaQZeaaJF84wxNQpdRngc8f7tGLqzTkARW2w19uUR/Fd09BqSYHKEY
         MZLH5F38h25ObMh4S9E+mB0Xdn3/60YNIqeE2iA45KD+qKGd1XiSUEUWluvURkM3wjMM
         E5YkLe92/fwHZfzUBVaqfVMFJVcKFuPhNUPzRoad4IxFgUe7gEdC/cYy9oDd4LnQvW7P
         /Abg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Cj6EGJBe;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x14sor1516368qkf.137.2019.06.06.12.32.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 12:32:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Cj6EGJBe;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ReUr/Ku4fFDe5ZS2T9E9QBdlSpBszMAhDsjnGAK3/wQ=;
        b=Cj6EGJBe/zmvkukObl2zSGVLq3S3tTaTPWaZ+Sywbvhq92MZz4ML0y38mXzUeTR23/
         t4yPrDLmNbgUewFAGXp6T5P0woF0ZWn9fOSzbizSJOMGmE+qUeXcmRiqM+z2lb4ZCkCi
         31Hiwd8nVObYBpqL1W/0OyvbXZyiVllJFQpXzQ7dnCL4plxyaAq59zyWrvkSTtBqagwO
         WXCbtaEQikmMDKheY3qe8epJmKwbKYjKbjQbBgT5gmfffhj2ooME6lxTLPOsC/RUtQUf
         ZAT0Tf6srv9sdqsxoZmtaxk6jl1ORa+N5QMua3t6i7cD2ev8cPC/Cpmil+zbuW2AM/mI
         HjYA==
X-Google-Smtp-Source: APXvYqxslyBL8NRCNrjjqXklGNp+xKIpW25Hd3ru2Bjoc/pn1jUdGOEWQpM2BD662L/L4lP51oy5EA==
X-Received: by 2002:ae9:d601:: with SMTP id r1mr40812490qkk.231.1559849553201;
        Thu, 06 Jun 2019 12:32:33 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f6sm1381433qkk.79.2019.06.06.12.32.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 12:32:32 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYy7k-0000Ve-9j; Thu, 06 Jun 2019 16:32:32 -0300
Date: Thu, 6 Jun 2019 16:32:32 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/5] mm/hmm: Update HMM documentation
Message-ID: <20190606193232.GH17373@ziepe.ca>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-2-rcampbell@nvidia.com>
 <20190606140239.GA21778@ziepe.ca>
 <e1fad454-ac9b-4069-1bc8-8149c72655ca@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e1fad454-ac9b-4069-1bc8-8149c72655ca@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 11:50:15AM -0700, Ralph Campbell wrote:
> Yes, I agree this is better.
> 
> Also, I noticed the sample code for hmm_range_register() is wrong.
> If you could merge this minor change into this patch, that
> would be appreciated.

Sure, done thanks

Jason

