Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4299C04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:26:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73D6121019
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:26:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73D6121019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 082DB6B026E; Wed, 29 May 2019 03:26:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 033EE6B0270; Wed, 29 May 2019 03:26:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8B316B0271; Wed, 29 May 2019 03:26:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B526E6B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:26:53 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id o17so551785wrm.10
        for <linux-mm@kvack.org>; Wed, 29 May 2019 00:26:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qh/qSPQWjgTJpode52UkaU8Ej8u/Nsp0ZG/MDjTRj7Q=;
        b=BVhMjF+c5/Nz0nuuGsmCL2XHqZdGB5u0bkWciJ4C4dDeB/9AXKR4WIAE17DXgN25YY
         rvSM7L20j1CepmCYBoT4+3LhXRAPlHzrBVaaXgZwesNT7Af1z7MemxRgALFj3qCbwmeY
         +GVd//owJn65QaIkqc3HAfuVTa3w9SONOTwwpe10WSTyySEaXXy3agkOfkm5zl45rIcL
         NfrHqCpUBKicwBlGukHfE5Gsy5YUEhs1m98jh+bMzEtBM9cl4U+cwnAj8R2GdsrIDU32
         pBKyqrTA45WfSau4pW8dIsfAXWGlIzrbsrb0cjMO2vXwf8CpgK8uiONTl+bAmCNCJ0sZ
         F1og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXDy80HKTXISW7nKaqoqfyBZ7XEErIJ06DtMXI233fz+hOHccms
	V6HVJbW6oXtukJxgyElyVgl87m2Fqkk0haNuOkerZKCiujaw5CPqCB2RyYh6e9lPYQ7cWNA9JxU
	wqqwey1s/cxF8Tt142MutOOtRZ737qiLXmALccNdOLUXBbLC+SaYCK5zQajQgrUfuHg==
X-Received: by 2002:a1c:7e8d:: with SMTP id z135mr5606572wmc.72.1559114813292;
        Wed, 29 May 2019 00:26:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTdd9yr3+ycuFQQjUXW9/16AkvUgmYxer5G7Jpo7IYmcymfLZ1LVzmAWnrg5AIU2QEDqYf
X-Received: by 2002:a1c:7e8d:: with SMTP id z135mr5606536wmc.72.1559114812602;
        Wed, 29 May 2019 00:26:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559114812; cv=none;
        d=google.com; s=arc-20160816;
        b=HdJWRYIMnq4nVFg71wS2yKH+ZPSixDYRtzQHGGZrbChGHVvVIj93F7irJ8FcmiR/PN
         FVuCOt7WqzOA7guOKWBAZC3XXoNnfq7+TgcvsVbuYLLpSaLmEld8eHm0U3n57OpOsALq
         c0D3F4XAC+X1alMvF1lJouTQQ/HOtpyMtdKBkcUHYAq+6z2Ea1kjCdopuSsacWLTxIxD
         +/vVZb+E2FYAJKHaNV+HnZLOisjp8SL2Wfdp8KVPkDUDKSyrzQpBeLOBTk/bLev1jKSl
         ffMNPXe/kyNgdFg8NYQZd+/MPaE0g69XmGUbSXw0DDjz1kcfpgoonOoC07Qjz20Dx3hb
         U9fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qh/qSPQWjgTJpode52UkaU8Ej8u/Nsp0ZG/MDjTRj7Q=;
        b=CBPAOlJTB6vOdESKUFr/wlZ3ceYsc6NxAsuUZHcyt+EvWKqFHwoxKGWD05KqgSqK8t
         uwxrzHT+qZt8EA4/3cXReVMq+ebFinAxVe56SK+RDPmlpiuSY81CJS+H/AL/0pyB1yNE
         A8fsr+L3Bf4jofvYwK37GQEvu+cuyqx08E8f+CeGyQTF6SCxnCySVdl34QEipIcor4Cx
         uaAzGpN2MsowQsrhthRiRcgnljyBMQVDlcf5aLOS31Bl9avdFag6tlTwUWD/iz7YEBgR
         5jGvrDQJEqC413yKONUMQBjKyu1xymbg0LGRBOLhqPJZAHNMSXDoCDPI88rQU28CNCqX
         QqtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c6si3697918wmb.103.2019.05.29.00.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 00:26:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 6E18068AFE; Wed, 29 May 2019 09:26:28 +0200 (CEST)
Date: Wed, 29 May 2019 09:26:28 +0200
From: Christoph Hellwig <hch@lst.de>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>, Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>, linux-mips@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	sparclinux@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 4/6] mm: add a gup_fixup_start_addr hook
Message-ID: <20190529072628.GA4149@lst.de>
References: <20190525133203.25853-1-hch@lst.de> <20190525133203.25853-5-hch@lst.de> <CAHk-=wg-KDU9Gp8NGTAffEO2Vh6F_xA4SE9=PCOMYamnEj0D4w@mail.gmail.com> <2eecb673-cb18-990e-0a61-900ecd056152@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2eecb673-cb18-990e-0a61-900ecd056152@oracle.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 09:57:25AM -0600, Khalid Aziz wrote:
> Since untagging addresses is a generic need required for far more than
> gup, I prefer the way Andrey wrote it -
> <https://patchwork.kernel.org/patch/10923637/>

Linus, what do you think of picking up that trivial prep patch for
5.2?  That way the arm64 and get_user_pages series can progress
independently for 5.3.

