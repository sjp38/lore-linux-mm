Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A110DC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DB5821901
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:03:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="O6JUVwIu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DB5821901
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D43356B0003; Fri, 26 Jul 2019 11:03:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF4236B0005; Fri, 26 Jul 2019 11:03:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBB908E0002; Fri, 26 Jul 2019 11:03:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0FD6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 11:03:26 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s22so47556860qtb.22
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:03:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=GJNtLWUjNKGuqf/4gWb/0hY3o63IJN+bigrvbnAEvoQ=;
        b=nnWV/cv6OrJplhKrkfyMVM+HIRaV53MuVtTp4lq8rVlPLUm3SUBR+wsVrgErm0t1vA
         WO3eldbTDZusfN9Wi3cXWG1MPRK33yxlI+FXGjh0g9MBAdLqBI4QGYjUtMAZsmhvIrFE
         JR50eUqYpq0ap1QRTXCnBMg33Pv7vTTk6vTQY0lmD/03I94VeZmg997kwEmyUs8oeelb
         3SjgEruaKcR0sE2wAaujxMCQgvkhyXhvmmhb2NRVQTCnwl1gDozIuguH8NfmYalnFeIB
         jlr1xkbPzXsncsaFDJSMUU0kWTUpicfqRYSdzpTaQYWZGgZMGlXDvADuK6mmKeY2rj0N
         1soQ==
X-Gm-Message-State: APjAAAVCXLAwETPU5nBq4qAFtXKU4/iC9ClBtCIdH3td/9stOxHY+jtp
	ZhftebXMRQblUfhjKFzUaO1p5tedN9ZGxyQmfyzypyZfZP8iFuRq982TmmlUCPsyGosFNISe/s+
	Kt6uefgpQgVQeYebIRJhxKhhbB2rM8vgWR03WOOj+17qpULHPNFmz74rdaSKb3sMZNw==
X-Received: by 2002:a37:6ac3:: with SMTP id f186mr61469393qkc.281.1564153406335;
        Fri, 26 Jul 2019 08:03:26 -0700 (PDT)
X-Received: by 2002:a37:6ac3:: with SMTP id f186mr61469343qkc.281.1564153405664;
        Fri, 26 Jul 2019 08:03:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564153405; cv=none;
        d=google.com; s=arc-20160816;
        b=LSKMtNvRrMHkFcmrqUdo6xLcG3RhjrVgJwnvAf9e3sjjFNiJB0Cuo8qrOCcTY7AuP5
         SzTR4XgICMxfBoeiRDRwi4I79XVRVArzxN3uRk0ihjMfZXrM3MiBapT6LBavMM0ceCTr
         3o8MAZ9ibs0ombm7BEgnkXbBN1RcFEEVjPBe2gzrpemJpp1DVJCG7jmUr1bhez+jRxn/
         tkcp5Do2E+Wo/LYCMV5sB6k5FlB258iNn/iysDVqIUyqaD5n7GLrAp/0FF2UDtr8szIR
         F1/xEb5CDYXnzzOgeczs0UPKR5RrNMio92UrCyErMTUN8caYc9dDOS+9xBGzp+QWfCX+
         zPLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=GJNtLWUjNKGuqf/4gWb/0hY3o63IJN+bigrvbnAEvoQ=;
        b=IoUIGVHWE0rZp+h2TTJqxPwyrmMmwlA4AADELE4rHKYAmqVv8K0cbL/ZYv0MRcWRf7
         ZAh1ySmw2EfY1WjoaPwmNRWYkVsnrl1gfR39r6TuTyP2FYo8uY+T+hEwgx8fWm8aOTO1
         zH5//OrGIehXV9bgV4b6cVpyCgtU0mP7JcThPgQ8f6jGzWQ/EcyXhbrn8ILeLIweuw+e
         zNbKJQ5yKGrLkEKVaD9Qbjd6t6gqIi07hkc/Tj4zXhwJlsMmYTEXYu1/L1TKBQgk3GRX
         tAudVhp0EE8l0Ne7Rc/oG0shUEiC2pzuD9tayZNP5gmh5efxnC6GpqYR3v9VzKJJ01Zn
         FyzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=O6JUVwIu;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l8sor28481164qvh.25.2019.07.26.08.03.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 08:03:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=O6JUVwIu;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=GJNtLWUjNKGuqf/4gWb/0hY3o63IJN+bigrvbnAEvoQ=;
        b=O6JUVwIuDaoRGTyw9VDj8CvDSgLGWaKe8W4Wqb4w+dbn+4ZFH7a+6nHcjk/wUFFm6c
         0OYFTUoD9kHzSda3BQ8LyYRfdBubXwXZJVnNplw+uVLkHyKDz4X4NKH3Iz+7fyGTXvHZ
         SAmJImRDUCcOoWsYveIBTPNVruXFj0AXDPvuupRJe2nNzzPjk3KJWpIwPdb/PyZI5Fwj
         1x+AzU4fu6Hr7MypuEf996Ujkld5D3SALeRfN0ESQsNEl+iLcmRk7VOM3gFucanIizsp
         TEtB+vFjXNcz2vsGefQVJGHCZUG+6dpBQ5WpVqBd3HCf7f1KtoQETLm3B6MhLgC1B2Ry
         ndDA==
X-Google-Smtp-Source: APXvYqw5bM9aE7bDAsR6CkrbhbbwLJ5RGlTlhcmaAHdDamcGQSO6zz4CR/XGVWg0EnLb37ZxhxrkYw==
X-Received: by 2002:a0c:d14e:: with SMTP id c14mr68086462qvh.206.1564153405057;
        Fri, 26 Jul 2019 08:03:25 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id u71sm25391649qka.21.2019.07.26.08.03.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Jul 2019 08:03:24 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hr1kg-0000d9-RM; Fri, 26 Jul 2019 12:03:22 -0300
Date: Fri, 26 Jul 2019 12:03:22 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190726150322.GB8695@ziepe.ca>
References: <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <20190726094353-mutt-send-email-mst@kernel.org>
 <63754251-a39a-1e0e-952d-658102682094@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <63754251-a39a-1e0e-952d-658102682094@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 10:00:20PM +0800, Jason Wang wrote:
> The question is, MMU notifier are allowed to be blocked on
> invalidate_range_start() which could be much slower than synchronize_rcu()
> to finish.
> 
> Looking at amdgpu_mn_invalidate_range_start_gfx() which calls
> amdgpu_mn_invalidate_node() which did:
> 
>                 r = reservation_object_wait_timeout_rcu(bo->tbo.resv,
>                         true, false, MAX_SCHEDULE_TIMEOUT);
> 
> ...

The general guidance has been that invalidate_start should block
minimally, if at all.

I would say synchronize_rcu is outside that guidance.

BTW, always returning EAGAIN for mmu_notifier_range_blockable() is not
good either, it should instead only return EAGAIN if any
vhost_map_range_overlap() is true.

Jason

