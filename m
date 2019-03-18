Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3D1FC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:04:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CF51205F4
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:04:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CF51205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 001F96B0003; Mon, 18 Mar 2019 13:04:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF5476B0006; Mon, 18 Mar 2019 13:04:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE3C66B0007; Mon, 18 Mar 2019 13:04:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B38586B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:04:08 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id d49so17029509qtd.15
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:04:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=mRU1xsuFHZ/TTNoLeT+Qd8QSRZBFMjrhDXhPjC0vj8Y=;
        b=OymWE3BzERq2TuWhUsdp3BuGwXzfO3jj2BSLfqrkScK8osVPAeSuC0CQ6MryW56CfQ
         CgsHpASwac7uhhxpxgIKWo43ZIeEWX197/VJ3LaTGcnaX8lL/8cInMUBGV9GgvFmN3fl
         qgQQTjjJlXsFvZNJZ+XrMLPTf/oQL5rvgieqv1SA+t74t/I7eHn1CkrkAgbGm+M/g3nu
         4qm9l7r3CgVy5EbnfPiSjp17ST1AOcuv32QqS7SEUS/eK5cZrrCEDuzjiM1BGM0jWN4M
         dL8aGNFy4w2LQdLstoOuLj5uTxUwjLddUI4V0QTOcVuBg0Zg+cobMkOqQHfwh4IZpifr
         oh7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWJ5Bpr6A9AqtKubOhmv9JfHKRlhCTaQJhfGicF43biDywRLTSn
	dXy+XPyg/AdP/WAPn73hO+5Mm699o7L2OxnpSUpWJNWGKpMRH9msFmfFn8iPK/xazzwxTwbflZx
	Fq7dCLyZVT1qzn2lDn2ww4BgjS0KDmOP7sBPY1PaSu7OApRt39g+/LBFLqx7/C3fSzw==
X-Received: by 2002:a0c:c689:: with SMTP id d9mr13341355qvj.20.1552928648490;
        Mon, 18 Mar 2019 10:04:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzo3Iwbv35Rgycuiysa6VBscF2gB7N9zAt8wA0ab7qy0YEUBhGR5p8GQ61vm89zKVB+aNdx
X-Received: by 2002:a0c:c689:: with SMTP id d9mr13341297qvj.20.1552928647719;
        Mon, 18 Mar 2019 10:04:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552928647; cv=none;
        d=google.com; s=arc-20160816;
        b=wM+efWiNJnJp6a4FUhpTX2yxTw5gZ4JmF+f6hVYRc2DZu01hRs/NJyXAc4/SPiVVdJ
         UjpQQL0YVq4KPpa4Oxwmek1j2AVrAPQ3X7nLklNVTpEpj5ya0R1B/xWy6BG510jwitHw
         RhHU1g0vwgTbQXi0nQ+q7noDRBhrFvgClP9tAHNK2N5bLblzFaoqgUI9AR4qUBwSjLDA
         IIq+ejemO060E/GGB/0aN2p8gEORKaeo5rGDIlK3A1GHG5QHrRG5QFrKcJp+2sHwVO5D
         XF6Kf8MV1aLreQ1+HJe+6xfLZJWVnMK5I9zrmR/NZexb7GRLa4GKiLFDhJU+CPomVsi+
         mUhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=mRU1xsuFHZ/TTNoLeT+Qd8QSRZBFMjrhDXhPjC0vj8Y=;
        b=kgmFkhnal1Ni9bzIh/eesCQvij9xO3523+Hvl53p4xZ1w1x+MERkGreYjAA8tC5hFt
         A1r+XXRoNTY9wyEadGg+LkAVK7e3JWCNwrLTeUE0CZuSQsRPQogTaIfu2GQTg8MWNAD2
         R8+FxKeo+nv/+qrtTEgTAyeReBpWa7Y662RW/HHEH3Zty4s/OJlJYplTxXZ3+kCqgRko
         BenG4HmGy0nawvaofwZF2Sw6BXkfA9pf1eQknHxzC9S4v+eqvzyKBHzQDuTmJSZ655/n
         rQFgQe5mAnWg0fg8R1fUPpM0l43wVJZ7X6qLpyPjWnp9eXPEX2tidCZhIx/mM3qPRiL6
         lttQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c52si2211885qte.169.2019.03.18.10.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 10:04:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E2B07308219E;
	Mon, 18 Mar 2019 17:04:06 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 03CDB5D705;
	Mon, 18 Mar 2019 17:04:05 +0000 (UTC)
Date: Mon, 18 Mar 2019 13:04:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190318170404.GA6786@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 18 Mar 2019 17:04:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 09:10:04AM -0700, Andrew Morton wrote:
> On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > Andrew you will not be pushing this patchset in 5.1 ?
> 
> I'd like to.  It sounds like we're converging on a plan.
> 
> It would be good to hear more from the driver developers who will be
> consuming these new features - links to patchsets, review feedback,
> etc.  Which individuals should we be asking?  Felix, Christian and
> Jason, perhaps?
> 

So i am guessing you will not send this to Linus ? Should i repost ?
This patchset has 2 sides, first side is just reworking the HMM API
to make something better in respect to process lifetime. AMD folks
did find that helpful [1]. This rework is also necessary to ease up
the convertion of ODP to HMM [2] and Jason already said that he is
interested in seing that happening [3]. By missing 5.1 it means now
that i can not push ODP to HMM in 5.2 and it will be postpone to 5.3
which is also postoning other work ...

The second side is it adds 2 new helper dma map and dma unmap both
are gonna be use by ODP and latter by nouveau (after some other
nouveau changes are done). This new functions just do dma_map ie:
    hmm_dma_map() {
        existing_hmm_api()
        for_each_page() {
            dma_map_page()
        }
    }

Do you want to see anymore justification than that ?

[1] https://www.spinics.net/lists/amd-gfx/msg31048.html
[2] https://patchwork.kernel.org/patch/10786625/
[3] https://lkml.org/lkml/2019/3/13/591

Cheers,
Jérôme

