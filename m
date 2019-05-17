Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C5CBC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:24:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E7E32168B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:24:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xjySCgF4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E7E32168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C98A36B0003; Fri, 17 May 2019 13:24:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C48CA6B0005; Fri, 17 May 2019 13:24:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B36BA6B0006; Fri, 17 May 2019 13:24:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75E116B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 13:24:34 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so4550038plt.23
        for <linux-mm@kvack.org>; Fri, 17 May 2019 10:24:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=x7P/brsu8l/+qdzew+JfyAJLRrQXXCFKiXS6vjW6Wvc=;
        b=mLn563DGvfxGZj4b8RXyYeUSMrBLhXYS2WaOuxjAnj1NxxClxCurhV7LOikprY9w3C
         fsZ7CazGf1ySiHm1t4dnQ/mMi8n+8rtWYeKDK5IwAWZzRaD9LxyVeY9Zfzhufq3lKNPv
         oKb1wsILzKveSiqdvguVM0utMoDzGGlyW2jCiHL8j/oxYyoiUzpiieIODRU0s0dUbHyb
         jgUBDusGG6Vg/7l5F1ZqMRMdBntsmwQKCihhOqw5HGRYjcTjkD+kgs3ZbOvdgIubnJCi
         W2M4KfUUd1O51nt/a8uhGaAYu0JMpmxUxJI+RcysXa1yW4bQG4kjR8xfld94ca6ByMq1
         /oMg==
X-Gm-Message-State: APjAAAW8XMyjHmKR7/flPBfqLDyr/oX2WJxMN6xhAf2LGvR9qrvTTuP/
	WYvwJtL2gLReAInOO5pnxsybPr6IzP4fxxaF5d5CKRUwPlQi8uymQ7T8lPEvDJD2/jdNiBiozqC
	vJ0V95c7BVAyWRMPPeEsCI7f+58Q64uxinztljjvdH/lLQe9MbkZGSI5ZVw0dwoZ9NQ==
X-Received: by 2002:a63:d652:: with SMTP id d18mr41733033pgj.112.1558113873992;
        Fri, 17 May 2019 10:24:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQjQVXERCDbAsqmtQrQ1T+VOTavzPhdOInsYOsMzwt0yDHbogdDu9C0QvMH9hd5JJMf6QG
X-Received: by 2002:a63:d652:: with SMTP id d18mr41732875pgj.112.1558113871800;
        Fri, 17 May 2019 10:24:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558113871; cv=none;
        d=google.com; s=arc-20160816;
        b=LGOGMJtPg2SW6wTLIYGReWhZnQ5BcBAdsiMdrq4nUAOjs1l/dpXTWrIcuCCHPCktxV
         Dz69ybkd0WLbDIOFSCYMcZrV3jzrhhVN8T2hiv5hKr9BUD2ymbr3WTQl2xxDOFfRluIE
         23i7XkFcwNBQ4+ThLaO/dBFKuoQhOmVqhumDsHM5SqQyy1fKocOb1/haDnwUX5HJkK/4
         0ZEhkCPLlG3mdfvaN+bVviZNq2NiHZJWggWodPYKa1FbA0W9l98mZr4DZind2+N7gzcx
         cRCS/XKxhg7Hxa8jmP3afDIFLc+oStAsKTp4MCztRpaEDG2nVeKMgx/bcx/7aVuvf5Ad
         ctrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=x7P/brsu8l/+qdzew+JfyAJLRrQXXCFKiXS6vjW6Wvc=;
        b=TbgvIIYi+zv4C2Vhdc3bskgtiJQzbBmBhlpqx3HvC/kWSo0mefo/ZKuJZyOJ33LuU5
         7EcsJG8YjPrclWSbt+mctZTu8LFEH47IGmX9aqVsML3vcCEEwJWi9ZZa8TsFlAoqcpAz
         k1X0HCBEcXpH3nRiLBGMoH44ynx5kJVpIFZNJq0uZMHPqPq8N5e9Zzl1kzFGBAiyTl63
         2R9nSmV4BnyuAIPfU4qC1Lfj6DL+wEKTbbfp+n361Vz981HM/SxiYrPF/gHND22pUvrw
         RecECsHwxCS7e15gJZjMKYcJCt9RcXh1PFoI4D1R7zSC4yQRTZLKbIcGwZ3UWsxol78F
         8wtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xjySCgF4;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c7si10046400pfp.40.2019.05.17.10.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 10:24:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xjySCgF4;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E9E9820848;
	Fri, 17 May 2019 17:24:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558113871;
	bh=WxXSWaL3QpOrEgpKs084IjnKXSpNSZZ904f35QLLVA4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=xjySCgF4FaNrp2+ct/3zpw36OkzervYSiIGfEc3YR7ztGWqF5SEeoFfXndGtiUVJg
	 E2/3NiTghwHTC6PlkuWja+NwFSOvLjeFjsHyPgGMw9ppidBJbhmRsuk41xoJysH+06
	 3jbCOCNfN2SaQdhlSzsRZ4nRXki+IrOTjXTxY5Ts=
Date: Fri, 17 May 2019 19:24:29 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Nadav Amit <namit@vmware.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	Pv-drivers <Pv-drivers@vmware.com>,
	Jason Wang <jasowang@redhat.com>,
	lkml <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 0/4] vmw_balloon: Compaction and shrinker support
Message-ID: <20190517172429.GA21509@kroah.com>
References: <20190425115445.20815-1-namit@vmware.com>
 <8A2D1D43-759A-4B09-B781-31E9002AE3DA@vmware.com>
 <9AD9FE33-1825-4D1A-914F-9C29DF93DC8D@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9AD9FE33-1825-4D1A-914F-9C29DF93DC8D@vmware.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 05:10:23PM +0000, Nadav Amit wrote:
> > On May 3, 2019, at 6:25 PM, Nadav Amit <namit@vmware.com> wrote:
> > 
> >> On Apr 25, 2019, at 4:54 AM, Nadav Amit <namit@vmware.com> wrote:
> >> 
> >> VMware balloon enhancements: adding support for memory compaction,
> >> memory shrinker (to prevent OOM) and splitting of refused pages to
> >> prevent recurring inflations.
> >> 
> >> Patches 1-2: Support for compaction
> >> Patch 3: Support for memory shrinker - disabled by default
> >> Patch 4: Split refused pages to improve performance
> >> 
> >> v3->v4:
> >> * "get around to" comment [Michael]
> >> * Put list_add under page lock [Michael]
> >> 
> >> v2->v3:
> >> * Fixing wrong argument type (int->size_t) [Michael]
> >> * Fixing a comment (it) [Michael]
> >> * Reinstating the BUG_ON() when page is locked [Michael] 
> >> 
> >> v1->v2:
> >> * Return number of pages in list enqueue/dequeue interfaces [Michael]
> >> * Removed first two patches which were already merged
> >> 
> >> Nadav Amit (4):
> >> mm/balloon_compaction: List interfaces
> >> vmw_balloon: Compaction support
> >> vmw_balloon: Add memory shrinker
> >> vmw_balloon: Split refused pages
> >> 
> >> drivers/misc/Kconfig               |   1 +
> >> drivers/misc/vmw_balloon.c         | 489 ++++++++++++++++++++++++++---
> >> include/linux/balloon_compaction.h |   4 +
> >> mm/balloon_compaction.c            | 144 ++++++---
> >> 4 files changed, 553 insertions(+), 85 deletions(-)
> >> 
> >> -- 
> >> 2.19.1
> > 
> > Ping.
> 
> Ping.
> 
> Greg, did it got lost again?


I thought you needed the mm developers to ack the first patch, did that
ever happen?

