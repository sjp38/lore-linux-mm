Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55980C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 21:30:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C87921479
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 21:30:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C87921479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D2ED8E0004; Tue, 19 Feb 2019 16:30:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98F1E8E0002; Tue, 19 Feb 2019 16:30:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84A3D8E0004; Tue, 19 Feb 2019 16:30:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC2D8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 16:30:48 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id b6so821612qkg.4
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 13:30:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=fo6JVnvUDOer6RG7RmKUqWZEBs/Ae/uZfSRiwK8Zn2w=;
        b=h0hbIFAPxTVNB7tx4KpRFhIRy/+C3IElDoloEYeBsjYMTWpg2V8ldCfM6DV7mRNLuP
         3ddXYOciLq1+fj9mnR9NDZA1oOKY+tm0JG3QqtnJiKckHOm5W2EBlQXY1UZRmRojAvJ+
         qHcoRfXEu+cQW/RMu3urMHRunVL4ioXCZz5hPifyluLJ6cf9fRklwIi2KtGTCp9EB14v
         fp0oqQQtDw030QL3bqVvLY8wcyY3xzIS2QS9tXvIF+K0Jg5tDQZHVWgs1sWPqqo7awwu
         UZPgbDaBOR8XkVYvJ11sFa/WCjH+YRdabmifoYUIIdJ5llud6Sk1emw624WmAvO2fj+3
         BrxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZIMAorKS4tMZTo0EOT2i/lQK8ukwqVMXtvSabfIEcEzRZiNDER
	dytAiVLSeVainLBzvQeCkIhiygZ++ytaCoRqYnFSUOkfntIqLqRKyyselKeVroNGWoAQ5twSgqN
	xIBTCiWKZGbdcCZCl9wO6hBv1KDNkWKz2vlYkBlNDqbnXtUOnv07n3i0MLsjerz+3+A==
X-Received: by 2002:a37:7847:: with SMTP id t68mr21668670qkc.254.1550611848110;
        Tue, 19 Feb 2019 13:30:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia2D3NFaAlIMQP2GOfAzju/jLyt8kOGDdy7oEGx43dsidNfbvi/o4OpmV1swoLBqOmG2/v4
X-Received: by 2002:a37:7847:: with SMTP id t68mr21668630qkc.254.1550611847530;
        Tue, 19 Feb 2019 13:30:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550611847; cv=none;
        d=google.com; s=arc-20160816;
        b=PdFOdSzByTA8QC53I0v/B7TpKWM5TbS96hdBq/9morHAwRufrBbCv+AowI1/dbzxoh
         b2TnvptvUTydPUyArHO7h1yVW8ZZnnAeShd3Zv8rRlGdMm7S7SxZM5SaHA1MDKdN9YK1
         NMXZSZwV8XJPaLBNAKKhWnNV08Xo/BxOQgqbj5iMg+6rnrbtM8ni2Rx5msxK35yRKGaI
         AL/5YxPyAyG0gB5QUqIEg65vptCtkAh/PUEMf1Qf9xiv1uMEulZ20Q12mTXL+ZfKjfzu
         xKmtKWRpsLVWesXDJE2s6TeOXAp2X9I0dp3f54RM3rSolIvMu1OdXAOJC+v+CI6dYePg
         tIXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=fo6JVnvUDOer6RG7RmKUqWZEBs/Ae/uZfSRiwK8Zn2w=;
        b=amobAc+TKoEs3dnDPrj/k22HsnKLIlvMS3iXjqZzQyzT7FIfaIBKsKLcoxruEHy0ry
         pFiiLT2cMm6NECD+QFlQ3S89wKMJ2uUuSCDgPN46zWKYtHgim70BNqHHMR3tuyX9QYgy
         Jk6yhxM9bPFG7sb7wL85p2+aDpR2a7kfp4S6+bARgAxOllI9/44OBIqAC3/QMCQBonD7
         MCp3xM+r0a5MNH5oJ3PT3SWCHDfvCpQBtwXOQWicds8VTuQuD9wxpz9uprFQOpY/lBz8
         QVOYFwq2O/3OBjplpSXGunNhHKLvPMyofvmdNmW7OsjncryJATUVr8mo1RSlBPgjm1q3
         LHaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p40si5236681qtj.154.2019.02.19.13.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 13:30:47 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 332EDC007325;
	Tue, 19 Feb 2019 21:30:46 +0000 (UTC)
Received: from redhat.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C5FB060BE8;
	Tue, 19 Feb 2019 21:30:35 +0000 (UTC)
Date: Tue, 19 Feb 2019 16:30:33 -0500
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
Message-ID: <20190219213032.GE3959@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <CAPcyv4gq23RXk3BTqP2O+gi3FGE85NSGXD8bdLk+_cgtZrn+Kg@mail.gmail.com>
 <20190219203032.GC3959@redhat.com>
 <CAPcyv4gUFSA6u77dGA6XxO41217zQ27DNteiHRG515Gtm_uGgg@mail.gmail.com>
 <20190219205751.GD3959@redhat.com>
 <CAPcyv4hCNSsk5EP7+BcnVp-zJjQyQ701U3QXkQyUteQZr-ZumA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4hCNSsk5EP7+BcnVp-zJjQyQ701U3QXkQyUteQZr-ZumA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 19 Feb 2019 21:30:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 01:19:09PM -0800, Dan Williams wrote:
> On Tue, Feb 19, 2019 at 12:58 PM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Feb 19, 2019 at 12:40:37PM -0800, Dan Williams wrote:
> > > On Tue, Feb 19, 2019 at 12:30 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > >
> > > > On Tue, Feb 19, 2019 at 12:15:55PM -0800, Dan Williams wrote:
> > > > > On Tue, Feb 19, 2019 at 12:04 PM <jglisse@redhat.com> wrote:
> > > > > >
> > > > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > > >
> > > > > > Since last version [4] i added the extra bits needed for the change_pte
> > > > > > optimization (which is a KSM thing). Here i am not posting users of
> > > > > > this, they will be posted to the appropriate sub-systems (KVM, GPU,
> > > > > > RDMA, ...) once this serie get upstream. If you want to look at users
> > > > > > of this see [5] [6]. If this gets in 5.1 then i will be submitting
> > > > > > those users for 5.2 (including KVM if KVM folks feel comfortable with
> > > > > > it).
> > > > >
> > > > > The users look small and straightforward. Why not await acks and
> > > > > reviewed-by's for the users like a typical upstream submission and
> > > > > merge them together? Is all of the functionality of this
> > > > > infrastructure consumed by the proposed users? Last time I checked it
> > > > > was only a subset.
> > > >
> > > > Yes pretty much all is use, the unuse case is SOFT_DIRTY and CLEAR
> > > > vs UNMAP. Both of which i intend to use. The RDMA folks already ack
> > > > the patches IIRC, so did radeon and amdgpu. I believe the i915 folks
> > > > were ok with it too. I do not want to merge things through Andrew
> > > > for all of this we discussed that in the past, merge mm bits through
> > > > Andrew in one release and bits that use things in the next release.
> > >
> > > Ok, I was trying to find the links to the acks on the mailing list,
> > > those references would address my concerns. I see no reason to rush
> > > SOFT_DIRTY and CLEAR ahead of the upstream user.
> >
> > I intend to post user for those in next couple weeks for 5.2 HMM bits.
> > So user for this (CLEAR/UNMAP/SOFTDIRTY) will definitly materialize in
> > time for 5.2.
> >
> > ACKS AMD/RADEON https://lkml.org/lkml/2019/2/1/395
> > ACKS RDMA https://lkml.org/lkml/2018/12/6/1473
> 
> Nice, thanks!
> 
> > For KVM Andrea Arcangeli seems to like the whole idea to restore the
> > change_pte optimization but i have not got ACK from Radim or Paolo,
> > however given the small performance improvement figure i get with it
> > i do not see while they would not ACK.
> 
> Sure, but no need to push ahead without that confirmation, right? At
> least for the piece that KVM cares about, maybe that's already covered
> in the infrastructure RDMA and RADEON are using?

The change_pte() for KVM is just one bit flag on top of the rest. So
i don't see much value in saving this last patch. I will be working
with KVM folks to merge KVM bits in 5.2. If they do not want that then
removing that extra flags is not much work.

But if you prefer than Andrew can drop the last patch in the serie.

Cheers,
Jérôme

