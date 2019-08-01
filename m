Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D20CC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:48:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65A342087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:48:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65A342087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 036A38E0003; Thu,  1 Aug 2019 03:48:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F296D8E0001; Thu,  1 Aug 2019 03:48:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF1BF8E0003; Thu,  1 Aug 2019 03:48:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 942818E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:48:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so44258141edb.1
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:48:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m6Azbqt89CCmqlrQpC1klXZQbXgM04hgbBEPb1oESOk=;
        b=EYsYtw/pK0M+++qlh+4w1kugc7mIB99l2ju/RrNE6jlOZZNUN1Io+XNK1b5Wg0AyAs
         rQcvQNxg01S2acPz/85l/CLx6ePEMlqTwG0JgCrjz5FwcMz1xvBone1wrFAyPZX1Ynsj
         ODoaPKx0ExMMTArFr04L8nRNegyu+8pbUepM7PMs1UwxYwgo5oOo0zR0C4/HNXaIraEr
         ZzHCQF2tPuKIeGysinUGNIT2iArbQPxBtmCgA9MIK6BZON/f69UbcQbK7C7gKtCZc/pN
         0moPYHcLFRjII3aTRhSvZyav+3L4S4ry3fTP3cs68bNYqSqqhsanykM7JOuT+rw5yJAX
         w1hQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUXn+60T7lXD4DyLQF3t6v7tPshJ9hhpOBzWaRVMw4bOORKvKKg
	jKoItnVKAoLpoo5/Jlqm5skmlns5qoMUbrZFdzOKzKBtgAQyLepk447HMUMp/KA8WQnqE80qlra
	SDqysfmIoHeFYzhCAkngthi9PQ7zopgFn9DpnKd3eoY61SypRA3vUE1YRRW7mIdU=
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr96600543ejo.24.1564645720185;
        Thu, 01 Aug 2019 00:48:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtPBiwvxh9/F+Jpa/wpVkmrkX+vdovGhTr9tDn9Xqoc6tQGyT10jSfD7hYTMHjmrkgkQWF
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr96600506ejo.24.1564645719539;
        Thu, 01 Aug 2019 00:48:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564645719; cv=none;
        d=google.com; s=arc-20160816;
        b=oPNGNAYUR0xZ7dYZj9mCJDMHzCKLkfZ5pIiGEvqav7MlTtKlG0YABKT+mSDbnGyDDm
         IX2pokvt/bSkjlyayJFgaMn6ajEs/gwMEBGPXP9ma63xGKHe2+gD/b5s2NzkI+2FH5xH
         XxEqRbZWDmO2dc5x5tJQr/hP+/kc7x1ezsFB9Drr5r0iIXtUgrITaCEEL/0q9nZxRx93
         X6mskaDDi7aMx2v0NhhD+jFAuMKM0eZmXOyHYuLFpd2nxBFJaWwhOR0eCbASMwpISxmy
         0tSpP5oL+L83Kx/uIyDp373AJEsLmkJ41sC7FTUHIFI9oxPJGLsggY1kccmkLk+leYmH
         0gwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m6Azbqt89CCmqlrQpC1klXZQbXgM04hgbBEPb1oESOk=;
        b=q/MazZjVko2n1jaX5honMB5TxPEFEil3k+435eI29A5TInkHYnsqVDhdE/WAkCzeP4
         pJkB0u3PFoCG7p6i+UdBZZRBUmMv9TF4dxJCYJzTSfyIBykknlfXmmVlTBqq4BstNiqg
         wURLiobDlb9zlHQWcGRktr9fU87z9ry9oYjibamfb62uCk8g1tMEUgwo4SbLBJt7KX25
         uAx7MTl6+eK8kycR3js9G2H/I+gRt0E9PFEV5g08GD13wdCjLxvI2S2VyeZX8m+lcT1N
         qS1vKmjj8MnWgbEuEsWFqQ8fTbr8PTWx7E2iRJk/XQYK1/af9yncoZHpcSg0b7vu3MfA
         HvTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf22si19786309ejb.367.2019.08.01.00.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:48:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1AEECB613;
	Thu,  1 Aug 2019 07:48:39 +0000 (UTC)
Date: Thu, 1 Aug 2019 09:48:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Rashmica Gupta <rashmica.g@gmail.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
Message-ID: <20190801074836.GI11627@dhcp22.suse.cz>
References: <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
 <20190731120859.GJ9330@dhcp22.suse.cz>
 <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
 <20190801071709.GE11627@dhcp22.suse.cz>
 <9bcbd574-7e23-5cfe-f633-646a085f935a@redhat.com>
 <20190801072430.GF11627@dhcp22.suse.cz>
 <e654aa97-6ab1-4069-60e6-fc099539729e@redhat.com>
 <5e6137c9-5269-5756-beaa-d116652be8b9@redhat.com>
 <20190801073957.GH11627@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801073957.GH11627@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 09:39:57, Michal Hocko wrote:
> On Thu 01-08-19 09:31:09, David Hildenbrand wrote:
> > On 01.08.19 09:26, David Hildenbrand wrote:
> [...]
> > > I am not sure about the implications of having
> > > pfn_valid()/pfn_present()/pfn_online() return true but accessing it
> > > results in crashes. (suspend, kdump, whatever other technology touches
> > > online memory)
> > 
> > (oneidea: we could of course go ahead and mark the pages PG_offline
> > before unmapping the pfn range to work around these issues)
> 
> PG_reserved and an elevated reference count should be enough to drive
> any pfn walker out. Pfn walkers shouldn't touch any page unless they
> know and recognize their type.

Btw. this shouldn't be much different from DEBUG_PAGE_ALLOC in
principle. The memory is valid, but not mapped to the kernel virtual
space. Nobody should be really touching it anyway.
-- 
Michal Hocko
SUSE Labs

