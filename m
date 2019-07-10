Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67913C74A2B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 16:45:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 361B820665
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 16:45:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 361B820665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C412A8E007D; Wed, 10 Jul 2019 12:45:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF0CA8E0032; Wed, 10 Jul 2019 12:45:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2E688E007D; Wed, 10 Jul 2019 12:45:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 802078E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 12:45:25 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id t62so2388115wmt.1
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 09:45:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZMEZ7U513reOnKQqgWE3RVK+7znn8C0ir83EcMV4pn4=;
        b=snGKyh0o6RXFgf/2mJEwfpM4rdQJae3L2XK6M8q+GRSSurVxlcrZhWxHYZVkaQqB5Z
         xBAr8j3Q/ng9qDPXPFHcukYkQUiqn5wOaYLQe4zKlRMKVMuo5PITW64dridmna6cywER
         UAlYGO0SbeP1l47T+s6pN+aeLWN7roNeApNwD7gX7qGdwk73cchzDITTWGEIvwtzvPC3
         s67b1Kiqqr1RUSv4Gqlzs5C5IXPRGkz/e6CDtdeh6Xb2PUxVDLpyF4s3SJ8G0v3Qomz6
         gRnDhpvhXNEl4FAvjt1K20PEQGZd1Yx+1DHEvNk6jo6QiEIwsgRT2yYIWPge2GZ6c34T
         yXfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAV9OViDpE9YSL8FbNH1EhGPVj0QVlx/SNvIftfSNNFDauF5+mPW
	t5VGx7Esr3NadY802HvcHXFYbypYyFx/6/Gv3aUaSVfUo/o66XzpXH1Aq3U0AQ3dpN7y/fOIJcC
	Uv0a09MUQT9e1aVOIQS0cNyqUiIAVyj/3kvEtmgDf6wKLGXLQ5wIOXoZFGNnhDf2NjA==
X-Received: by 2002:adf:ea88:: with SMTP id s8mr30778321wrm.68.1562777125104;
        Wed, 10 Jul 2019 09:45:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/RAdPvopalbAab1Gl1qrEdrTYDUXK0JbvRIEX8H5Ycb753ZNjX7rEa/R1yxD4R63XQFPe
X-Received: by 2002:adf:ea88:: with SMTP id s8mr30778264wrm.68.1562777124199;
        Wed, 10 Jul 2019 09:45:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562777124; cv=none;
        d=google.com; s=arc-20160816;
        b=icnGs+To5fbqMi/lFQykTEU209X3aOlxir7K4Wg1ooxtp3s4UyQ+crUZw2iB8kRy05
         PasjDTzbUkcg2zzZeHcU6Hw58vay6WhkMA77fiMgmUTHRmGxOcHV0m/Q9uAvSLkhQV0x
         O/AHTHkY0/psF5oak8/+VTUNEau3oUDqBuMY62F8zNhl3zOId1GgQhxb8qhI0ZdSKDt7
         PUWPEXQrePIR/imRimdvMJJNmuPzAqsKokIdggS+CoCpltUYkZJ82NRisBdNvjFqCQij
         yBZKTFrYBFiUd1t1pC8c+iR/8f4VYZSjxZCTecmsIl3SsFWb8h/UlLpoQHOglYmXQNzM
         KLGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZMEZ7U513reOnKQqgWE3RVK+7znn8C0ir83EcMV4pn4=;
        b=ky7llrOMNK3Zvk9HXGryn/o7ecU2mmqQnKGwNRzNtEU0e34SaRLWwJvDoKuCotrMJF
         /FShoqyv55yl+X0wDgYF+ndpGCu1G0zvf5Ey+wpHK0QjHuPV/Re8wJ9pvd9T8bPj5tOX
         FIYxP6C72BiFqC+NT0Mu0FzyBZl0cXDNb/Lx/cdm5LBHH1W3aNFJ98u0/VwR2QubOAdE
         zZ9lQtKNYhsxSAMAxYrtERZPPg6ygsHvv69Sh5mDNozayUIXp1Jw867vnf+CRs30dyFx
         j8krRN6usXnYQfDpJ3jopNc9tEO5MPfMN7mBlVAl5G6Fc4ZIoRQGH1/1rmitS37YX4WW
         hENg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id v14si2781866wrw.154.2019.07.10.09.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jul 2019 09:45:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hlFib-0006vw-V3; Wed, 10 Jul 2019 18:45:21 +0200
Date: Wed, 10 Jul 2019 18:45:21 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, tglx@linutronix.de
Subject: Re: Memory compaction and mlockall()
Message-ID: <20190710164521.vlcrrfovphd5fp7f@linutronix.de>
References: <20190710144138.qyn4tuttdq6h7kqx@linutronix.de>
 <66785c4b-b1cc-7b5a-a756-041068e3bec6@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <66785c4b-b1cc-7b5a-a756-041068e3bec6@intel.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-10 09:20:47 [-0700], Dave Hansen wrote:
> On 7/10/19 7:41 AM, Sebastian Andrzej Siewior wrote:
> > I did not expect a pagefault with mlockall(). I assume it has to do with
> > memory compaction.
> 
> mlock() doesn't technically prevent faults.  From the manpage:
> 
> > mlock(),  mlock2(),  and  mlockall()  lock  part  or  all of the
> > calling process's virtual address space into RAM, preventing that
> > memory from being paged to the swap area.
> I read that as basically saying there will be no major faults, but minor
> faults are possible.

It says "lock virtual address space into into RAM". I assumed that there
will be no page faults because everything is locked.

The problem (besides the delay caused by the context switch and fix up)
is that a major fault (with might have happened at the same time in
another thread) will block this minor fault even longer.

Sebastian

