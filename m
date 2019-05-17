Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02533C04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 18:10:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0BCC217D8
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 18:10:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OuQa8+mP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0BCC217D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1533F6B0005; Fri, 17 May 2019 14:10:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 105896B0006; Fri, 17 May 2019 14:10:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F35636B0008; Fri, 17 May 2019 14:10:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9D2D6B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 14:10:53 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 5so5014823pff.11
        for <linux-mm@kvack.org>; Fri, 17 May 2019 11:10:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=I7mir6Oo0VWPipV1x5E9gtBqcBvBCeNl5LPCUsHl/l4=;
        b=YW2GpCxKMmW2Xy9ECYGO8DQTwDbPBmEsH2z1Hl2OIMBHe98GG1Y6K2aRYJ5HikAudD
         1Q+74gdof2r5FXd8rJHUAhx/sJH08OFwqAQTTYteoXjFYI+aPqPZFFojHdSSgZSqHjXV
         W9dfJwXl8Y40hqMG+oMo77JKzu+tZLSjWPOI12GKXSyY+/n2J4q5LTliitejW6llWbI/
         e47n9Xn7Whx1oX9zjXwCyql0yIbRSH6E7sA6QsmFEmbxM42ZbWJzoEJrITixwOaL8UHd
         2NZBPpRDGfvNm6usVWeNFnzp5Yp4d0VIMmVggPImEaQYdEQcXLStMy0EAJt2qPnBMSpA
         v7yw==
X-Gm-Message-State: APjAAAW9/gbw97KmRZY3dIa04QN3pkPMk6wZZoMsH1Ki+KgcsVIXJPik
	zgls9O2ZGxcNofPMIliNLZdEvs+UJNNHg/K+wLXlqh95u9TXVHqyFIG65Py3sJWQTXuqovH0h2R
	7IXT60DSpQ0hP88Y2C/1Ys+BGXSgExsPMGtNZTtHeeERdihZhyEL66qznHlqCZn2bXw==
X-Received: by 2002:a63:f54c:: with SMTP id e12mr58424474pgk.62.1558116653275;
        Fri, 17 May 2019 11:10:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCvMvGDT3DK9kGCxt0RHq0P37C/97+f4np5mIehTBuobToJJ3In2MphzYIzhD7buvmm1HG
X-Received: by 2002:a63:f54c:: with SMTP id e12mr58424411pgk.62.1558116652534;
        Fri, 17 May 2019 11:10:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558116652; cv=none;
        d=google.com; s=arc-20160816;
        b=pRjwNPWryrcFXz7LJ+Cwiohhg8LQnYx6lcb5+5uLugO4peISnNpOr0SWegMWcNwN0P
         /InN+Kclf0BCXq+6JfJQjEWi0QcPFZNZTfo37pR5vv5MKlsf3CXo+A4O/Q+hTt3hJu3r
         Xj9v+VA3uEbIXZ+64jQRSTIrMdQIWuGccERDMZiILY+FSZwhtP4iNtn/MdSjn06cl4Fe
         oqrdq0+YNfJF+0L40EaqwKbE5648iv4UXe1KB9wN5NcSLgOvBwiSBW9L9486dLfaTf1J
         GZYvaimj6SnqRHVTGcUz/b7i1VddmOUgboO9chV8SyMuXeJKyjfdexagAU4hnRuWF8/E
         1TKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=I7mir6Oo0VWPipV1x5E9gtBqcBvBCeNl5LPCUsHl/l4=;
        b=XMBqz7/VKoIX0UsZ3qtXX7yBGNbvIThoEqF8ok33xvfW0wdYn1F9uQf5aHNu518+TR
         7qIcok11akXCny1pZ2+7gHlvO+snUieQRBe1PsZ9wfxqUVmL9aEEqUxMWYXY52dEUo/B
         Z0VDj1gvQbNK/C0nGeGwBPMM1VuKDZ0oB+9KeO+nXlI5z2GnX4wIPAjwHRF1SUYA5UdD
         e6/thk8HAR+0U+GckyevSzooaetO+bzZj/RQyJALMrus3nDJ1Zb7/NLDLAhBT5kqYEfq
         l99f1C+c/PfbDVQKvVOHZW0KeXO6l5EHSeKNUer6e/gdKAmX3uSzqFc0yP9UdrIhPEbg
         1nSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OuQa8+mP;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u67si10061973pfu.154.2019.05.17.11.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 11:10:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OuQa8+mP;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ABAFB21734;
	Fri, 17 May 2019 18:10:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558116652;
	bh=J5RwK2qHQIcT3y2vsCaqdKAjdj5CtRHH5T01yuTQkwE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=OuQa8+mP4xStuzMr/lOK9TAzQHfWXrGffvPdqBMCFCDh4iAVHZ1OzKMrvMv9WjsUE
	 5TJy5vkIMufLFFbCBLkhcavKX+h6NWGS+oJMMWDvloQGxTxS2B94BWkO9IzVwNMBCM
	 PBAq5LiLQ2fYPaWgZxYIIlmP7XPOZPWHsHgYsUho=
Date: Fri, 17 May 2019 20:10:49 +0200
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
Message-ID: <20190517181049.GA25765@kroah.com>
References: <20190425115445.20815-1-namit@vmware.com>
 <8A2D1D43-759A-4B09-B781-31E9002AE3DA@vmware.com>
 <9AD9FE33-1825-4D1A-914F-9C29DF93DC8D@vmware.com>
 <20190517172429.GA21509@kroah.com>
 <26FEBE86-AF49-428F-9C9F-1FA435ADCB54@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <26FEBE86-AF49-428F-9C9F-1FA435ADCB54@vmware.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 05:57:22PM +0000, Nadav Amit wrote:
> > On May 17, 2019, at 10:24 AM, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> > 
> > On Fri, May 17, 2019 at 05:10:23PM +0000, Nadav Amit wrote:
> >>> On May 3, 2019, at 6:25 PM, Nadav Amit <namit@vmware.com> wrote:
> >>> 
> >>>> On Apr 25, 2019, at 4:54 AM, Nadav Amit <namit@vmware.com> wrote:
> >>>> 
> >>>> VMware balloon enhancements: adding support for memory compaction,
> >>>> memory shrinker (to prevent OOM) and splitting of refused pages to
> >>>> prevent recurring inflations.
> >>>> 
> >>>> Patches 1-2: Support for compaction
> >>>> Patch 3: Support for memory shrinker - disabled by default
> >>>> Patch 4: Split refused pages to improve performance
> >>>> 
> >>>> v3->v4:
> >>>> * "get around to" comment [Michael]
> >>>> * Put list_add under page lock [Michael]
> >>>> 
> >>>> v2->v3:
> >>>> * Fixing wrong argument type (int->size_t) [Michael]
> >>>> * Fixing a comment (it) [Michael]
> >>>> * Reinstating the BUG_ON() when page is locked [Michael] 
> >>>> 
> >>>> v1->v2:
> >>>> * Return number of pages in list enqueue/dequeue interfaces [Michael]
> >>>> * Removed first two patches which were already merged
> >>>> 
> >>>> Nadav Amit (4):
> >>>> mm/balloon_compaction: List interfaces
> >>>> vmw_balloon: Compaction support
> >>>> vmw_balloon: Add memory shrinker
> >>>> vmw_balloon: Split refused pages
> >>>> 
> >>>> drivers/misc/Kconfig               |   1 +
> >>>> drivers/misc/vmw_balloon.c         | 489 ++++++++++++++++++++++++++---
> >>>> include/linux/balloon_compaction.h |   4 +
> >>>> mm/balloon_compaction.c            | 144 ++++++---
> >>>> 4 files changed, 553 insertions(+), 85 deletions(-)
> >>>> 
> >>>> -- 
> >>>> 2.19.1
> >>> 
> >>> Ping.
> >> 
> >> Ping.
> >> 
> >> Greg, did it got lost again?
> > 
> > 
> > I thought you needed the mm developers to ack the first patch, did that
> > ever happen?
> 
> Yes. You will see Michael Tsirkin’s “Acked-by" on it.

Ah, missed that, thanks.  Will queue this up after the -rc1 release is
out, can't do anything until then.

greg k-h

