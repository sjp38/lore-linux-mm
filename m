Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F9B8C433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 19:12:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8CD1208C3
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 19:12:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8CD1208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B48C6B0003; Sat, 10 Aug 2019 15:12:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5661C6B0005; Sat, 10 Aug 2019 15:12:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 453746B0006; Sat, 10 Aug 2019 15:12:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 250E66B0003
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 15:12:19 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n190so89418335qkd.5
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 12:12:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=tOm/MfXC722ZZDGZkYyy/bxra5b24Gt/HS1+G7EfviI=;
        b=h43bUqDF0LmoIBpT2hj5O9RsWVw3JtgHdQReef+ahjWJeEpBGN8KFU36/9mKhjYBGs
         3dQ7bPFCXImcCP2VuR3O0aSdtZsQ0yKmml561vT80GZSkJY6vy4QaLlW7r3lYZKaiEld
         sKEWzmdKqlNI1MHuMWcvv1xU/l/bjzLbM5duK80ymvv8wMpD24zDJ+niZFW0kI2qv6Vr
         Qpey8UNtIm2ioTAgGIJCkbPUdGW3pUHK08DcSs9HSvld00dF8vQ9AclYr2149CrxjPLn
         9aAu8KdxcG1u7wVIEwTMmdy+xwca7zgmBzRRXKZtVVke/1c9KlHonslL5vAm3cxINTkf
         g1Ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXLGO2wjeYXIPux7z1wKxCTFopAsWYET3VSSs9+HTh6Fsus8lTV
	y/MuJfkwrqEWYm0wg0w+kuthkf5ZKKbey+eRjooCncFhBTKks5JENMYOYAWGpKcJi3mcBPpS1p0
	0rjcZ/gjFBvhDhw92K96lamKiC14BXMCwVaEpXVXKKBGCae8ex2bPz6GdUzDW37JISw==
X-Received: by 2002:a37:48c7:: with SMTP id v190mr24452638qka.350.1565464338936;
        Sat, 10 Aug 2019 12:12:18 -0700 (PDT)
X-Received: by 2002:a37:48c7:: with SMTP id v190mr24452596qka.350.1565464338408;
        Sat, 10 Aug 2019 12:12:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565464338; cv=none;
        d=google.com; s=arc-20160816;
        b=CL0W8HBofe75qQu6om/Ymz3ixc2EPEdmPy6QGYvHCctPWBvS06+JRXd/QTLEaCCodL
         ZH9zDA+AQk/viZmL1oRwO1zZxDFBBbyGRybso84TxAb5d8xggwf1Z6/NGjlwZ454pfJE
         W2msb1S4CM9OdJPR22Np/sW9PR/bx8VrF/HlEbdnwR7eHR6YoaS5cqgYPRgEWGyuKDJH
         oY1Pug4N6ngcKfZdP52E7X+sc6RFoHR47styMrpegfmaH2R4KabXM/rBSuBfc4L6DAB5
         Ab+uN14yex17jZD+JGpQEztudHwYaApvJWp28/bBIws4XQTzKDzKBpt58aekom5Hkof/
         0Ocg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=tOm/MfXC722ZZDGZkYyy/bxra5b24Gt/HS1+G7EfviI=;
        b=K832eNgF+4IafnWGi5Pe+fbHNc4BtBxsmw75anppme389P6hYCTd7xJejdDrFaEwOA
         SI94O9cxwJzvLcYmZQbfiVuHPGAGd625Ez5oMsfRH6mch3tYrl0lch3eeLLc8ahBbG3P
         Y28bBkttDBuTe/IXIpal6gf0h2RymMtL5f0/uKtq1VSGJ4wI/B96w1Oa73DDqDtsZzfo
         sFR7b/sx6RaOUURJduxN/r0sMtDU5zr7VJBQ9rs5+TYx5CyTsGluJQWIXkYSJtqyMgzy
         8JR9ittlFWV7y39Ytbb9Uf43BqKBC2ONwOkXA/XNWVUr5teXgfCP3yPWuGW4vfjvwqqL
         bQKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c5sor3711472qkg.108.2019.08.10.12.12.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Aug 2019 12:12:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy9zmxhh9QafC0RnwL+m0pBIJpGi6lXzl9adS3Ij5sGenWXNRYs/XzZWBUSfehxs1JFSId7lA==
X-Received: by 2002:a37:516:: with SMTP id 22mr23794866qkf.308.1565464338086;
        Sat, 10 Aug 2019 12:12:18 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id q17sm40074395qtl.13.2019.08.10.12.12.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 10 Aug 2019 12:12:16 -0700 (PDT)
Date: Sat, 10 Aug 2019 15:12:11 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Message-ID: <20190810150611-mutt-send-email-mst@kernel.org>
References: <20190807070617.23716-1-jasowang@redhat.com>
 <20190807070617.23716-8-jasowang@redhat.com>
 <20190807120738.GB1557@ziepe.ca>
 <ba5f375f-435a-91fd-7fca-bfab0915594b@redhat.com>
 <1000f8a3-19a9-0383-61e5-ba08ddc9fcba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1000f8a3-19a9-0383-61e5-ba08ddc9fcba@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 08:54:54PM +0800, Jason Wang wrote:
> I don't have any objection to convert  to spinlock() but just want to
> know if any case that the above smp_mb() + counter looks good to you?

So how about we try this:
- revert the original patch for this release
- new safe patch with a spinlock for the next release
- whatever improvements we can come up with on top

Thoughts?

Because I think this needs much more scrutiny than we can
give an incremental patch.

-- 
MST

