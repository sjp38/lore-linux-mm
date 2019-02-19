Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B78F5C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:58:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 794FB2086D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:58:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 794FB2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04F308E0003; Tue, 19 Feb 2019 15:58:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3F738E0002; Tue, 19 Feb 2019 15:58:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0A6A8E0003; Tue, 19 Feb 2019 15:58:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B618C8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:58:00 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id j22so4299913qtq.21
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:58:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=IJS20RcF9ThTHiw+kc8l0082AqJwibOkpiCpzXgkhn4=;
        b=LjZmhJt1TPweZTXj1++3tYV12sH2LgpBcC/r87ffDpHXutfenUvGu9uD5RR+2NBgRI
         AcHAXEvJVRkSn62FmwVjqg2ZhwKD+JmZ7qbVxUxNVpIDD9p8mJn9yUktx2fa7+hETXS4
         SegXTj8N7A+Kqbb7VuYh8d14DYxFMNEBRDO4/xpx5m11mBn+VWp2POhMPtdKFZR/a1SZ
         mPqVYHJcMwpph8DkGp8cKUIytYNTe3roXiTU5T5BeW83BnMNTQ/VKStxSZCCYthMatH3
         4lFgHUkK8RVkmcK/RloHXjvwH0sJAeyqHKOkw0H53KWta3bGsb6J1HnghZ1SvHajKg6A
         cXog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYWQZQrSKgOmBkzV8GBrgGQ6MN+nS8wK+ep0RUB47r2uec1X4oG
	+rfn8w6Rn4Ob00f6UAM80FexenLZuE/9xDHSU3MUi8ooEEVa6IUC3qfXqIRq0hMeBrJbdpME1B1
	nlNPbeLheCxz8B1iXCr8T9UDfJRWETT/981o9Jg0+Nk2UL+3V26TAZ4195K5VRjf0iw==
X-Received: by 2002:a0c:b301:: with SMTP id s1mr22796524qve.132.1550609880528;
        Tue, 19 Feb 2019 12:58:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ0WubT+u+YYAkgRotEnUw4MxiwR2DinWZ+lCe1zt4IwlsaC1hTK1jnndub48mTS27valLe
X-Received: by 2002:a0c:b301:: with SMTP id s1mr22796494qve.132.1550609879981;
        Tue, 19 Feb 2019 12:57:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550609879; cv=none;
        d=google.com; s=arc-20160816;
        b=FUtuEQgC7G03Co8NEnG+5zhxDRUBBpntfvOuj19/8l/HQWUNzIxnJZz/W1h1PWX+rI
         pJ3h+rdx1AUOv+bQsH6Em6gdakjucB+QK926+dj030YBnPH1EtmGo5iUul8GeRZsZH6z
         1c8zxmWgKx5FsCFN3bmte6FSF7EB3mOw8UjeEnyGlxMD6LRsfJs+3nkjIBkJthDtKf1x
         nU6a/iIlFalx8nmOVPQNOIHwV/M9fuvyTNEnmSbY4vldkYmFHduSuLik21TJXCQCojMB
         M72mt5f05/BIKZQsdFQA6x+1ptJfgGQxHJU0tj4GGnrjX+/vZmnBZt8Oi1Zc4fcbyga6
         iyKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=IJS20RcF9ThTHiw+kc8l0082AqJwibOkpiCpzXgkhn4=;
        b=bhfpg5G3u+t1HQylV52yJUyZgrQYth2EQUPileQVvlUmggeVss3EdKrq/4vo5cJtVE
         qt9whdhnWf9Pd4MMUY/PB14bbmpH4jAHBkclCnEw6wYNSMmMiFWarinWcheHI9dmsYQC
         y0j5nLMB6AkIVf22JovTrfxGhTSbtsfbnAQfVmvreJ20MtE6XVo8VwhVQiRovcJB3Qqw
         CBGlSkPwtuCz5a/sJ3q1OGJBoNydQlXmkccKVOzGAo/MYZwWHj0VErI70xuuFuYPVBmx
         1qFWPGJ0C0YKRl7qwwlDSxDs6pmnKnyt+aWKj0UWHBsoRyomYY9eCcqw7NKS85e4gAN/
         xy4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 23si218222qto.180.2019.02.19.12.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:57:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BF9C981DF5;
	Tue, 19 Feb 2019 20:57:58 +0000 (UTC)
Received: from redhat.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D1766600C8;
	Tue, 19 Feb 2019 20:57:54 +0000 (UTC)
Date: Tue, 19 Feb 2019 15:57:52 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, KVM list <kvm@vger.kernel.org>,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v5 0/9] mmu notifier provide context informations
Message-ID: <20190219205751.GD3959@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <CAPcyv4gq23RXk3BTqP2O+gi3FGE85NSGXD8bdLk+_cgtZrn+Kg@mail.gmail.com>
 <20190219203032.GC3959@redhat.com>
 <CAPcyv4gUFSA6u77dGA6XxO41217zQ27DNteiHRG515Gtm_uGgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gUFSA6u77dGA6XxO41217zQ27DNteiHRG515Gtm_uGgg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 19 Feb 2019 20:57:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 12:40:37PM -0800, Dan Williams wrote:
> On Tue, Feb 19, 2019 at 12:30 PM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Feb 19, 2019 at 12:15:55PM -0800, Dan Williams wrote:
> > > On Tue, Feb 19, 2019 at 12:04 PM <jglisse@redhat.com> wrote:
> > > >
> > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > >
> > > > Since last version [4] i added the extra bits needed for the change_pte
> > > > optimization (which is a KSM thing). Here i am not posting users of
> > > > this, they will be posted to the appropriate sub-systems (KVM, GPU,
> > > > RDMA, ...) once this serie get upstream. If you want to look at users
> > > > of this see [5] [6]. If this gets in 5.1 then i will be submitting
> > > > those users for 5.2 (including KVM if KVM folks feel comfortable with
> > > > it).
> > >
> > > The users look small and straightforward. Why not await acks and
> > > reviewed-by's for the users like a typical upstream submission and
> > > merge them together? Is all of the functionality of this
> > > infrastructure consumed by the proposed users? Last time I checked it
> > > was only a subset.
> >
> > Yes pretty much all is use, the unuse case is SOFT_DIRTY and CLEAR
> > vs UNMAP. Both of which i intend to use. The RDMA folks already ack
> > the patches IIRC, so did radeon and amdgpu. I believe the i915 folks
> > were ok with it too. I do not want to merge things through Andrew
> > for all of this we discussed that in the past, merge mm bits through
> > Andrew in one release and bits that use things in the next release.
> 
> Ok, I was trying to find the links to the acks on the mailing list,
> those references would address my concerns. I see no reason to rush
> SOFT_DIRTY and CLEAR ahead of the upstream user.

I intend to post user for those in next couple weeks for 5.2 HMM bits.
So user for this (CLEAR/UNMAP/SOFTDIRTY) will definitly materialize in
time for 5.2.

ACKS AMD/RADEON https://lkml.org/lkml/2019/2/1/395
ACKS RDMA https://lkml.org/lkml/2018/12/6/1473

For KVM Andrea Arcangeli seems to like the whole idea to restore the
change_pte optimization but i have not got ACK from Radim or Paolo,
however given the small performance improvement figure i get with it
i do not see while they would not ACK.

https://lkml.org/lkml/2019/2/18/1530

Cheers,
Jérôme

