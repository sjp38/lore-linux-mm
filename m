Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4058C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61B4D206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:07:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61B4D206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9B4F6B0007; Wed,  3 Apr 2019 12:07:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4A416B0010; Wed,  3 Apr 2019 12:07:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B39D56B0266; Wed,  3 Apr 2019 12:07:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 920776B0007
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 12:07:35 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z24so5488955qto.7
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 09:07:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=+t9zGWo/D9Ij8TkTpZuEmfDN0c4KJqeCxCftzTelGFc=;
        b=Qey8ftlN+PUrX1XqP5l3vF0uKtyeI2igoLeZQyD4MT3e+UkrFlQ4K1CMIjG6CnpkQE
         5IEpd0xuGGXlJnO+qW4e9q8lybH/n5OiMIl2CxLVtAzT6nWvxHHOzeJiLKYH+e/XWJdY
         JScZagShA2BRygUBzKh+FxIpytMiHH/ldqpEiIxAJchHsdC4C3cPRMbrIGiE4/DQgE2l
         7HDFGMCODu6ZkSuCchOJEbEnUvQdUNrlcCq6oifAGhlxvoTRs8gFk0ArZ/rMhGm0/jFd
         D9OMNrMkqM4euIuJUVEnwpW4oiOqrl8u2QfTU9Jbxjt1bdZXQQQKTQ4OcYFSPIeLWNIt
         CMFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUIPEZ0h/ixrmnw5OHY2dSpcOonx+oDkrbqggpAWCGAgzTZ0PRr
	kDT70VMWtB2KkNGXzmaDblaldubYi1eKLxqye+sOlUzWZ/MLPDA9DISXAQlkMzKXboCKJGSdhfx
	UQKxN5l1PX7rQomyQzNWK4Gye19ZuGBF9e/6JUin7swkCpMo4TEbnPxHha28h1hbNcg==
X-Received: by 2002:ac8:2ed4:: with SMTP id i20mr749067qta.52.1554307655161;
        Wed, 03 Apr 2019 09:07:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbWfz7Cf/KcmaoQahOIiJeOr8ls/M5WEo5BLNbpysihKXy5MazHthTacKxCNiBL2/S2gvv
X-Received: by 2002:ac8:2ed4:: with SMTP id i20mr748986qta.52.1554307654334;
        Wed, 03 Apr 2019 09:07:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554307654; cv=none;
        d=google.com; s=arc-20160816;
        b=AqnCgYypBEc+4KS3oaftRf+brLfOtZkrGEYOcAnKKqRF/Txf9BTGavJzmw6QnqbUsk
         ovhArcft6/AB0cLcMUb7vFRns7dbZjY5F9/Wy3r+USyU9ldJ2W3o2x/Z6cfZ4DzZY7PH
         U/SxKlYHGtTU28UDIF9purdP/yN5WBckc2IK8qkdpLyoCFYptZ6z90lW6s6uU11Yewgr
         wHJrpcC4nA8tUNm203ywbtlLHto5e9I8QSlUFIesEJZJRc5rXl7G9S35POWDHoUkXe3T
         mR+WdfiWS8mYCRVV4cRZVLEeoAhM6HmrSHnmEkS/uqMREUTw9r+L5rxdTyqg2Iv8ZSOu
         isCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=+t9zGWo/D9Ij8TkTpZuEmfDN0c4KJqeCxCftzTelGFc=;
        b=Iuf19AKrINsdhubhl8zU0smsKV4zNO7SHnDi7yfZT5LeF3lnMx/JfFMfQ3p76sHGKZ
         NwCIt2wsPD8YimR29qDAzwHekaQ3mkve1DQhzrC6c1C6fZ1w/tnksS5WXPKb4vLv8nqe
         NSRD9/Zi7S81Tc5jECRgWmK6Gi8bMRWkqk39cOnvnQVlPUDQLZOCfPb/JxNf3qr/Jm9Z
         T/AZZg1ZmHkeziUPJetMD6w9kET3SWCgjtSb9GDNVqnEIN+UUL0/v5mPvtKF4KGQp1OT
         WwoEtCPRKDi92//TbRYxqkQrF2pDXyCtnGeCJ1dm2dlvEXnkcSvf8MHnepWp5loSMHHR
         8glg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 8si1109011qtt.203.2019.04.03.09.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 09:07:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 478CB88AAE;
	Wed,  3 Apr 2019 16:07:31 +0000 (UTC)
Received: from redhat.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id AF99B608A5;
	Wed,  3 Apr 2019 16:07:24 +0000 (UTC)
Date: Wed, 3 Apr 2019 12:07:22 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mhocko@suse.com,
	mgorman@techsingularity.net, james.morse@arm.com,
	mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, osalvador@suse.de, logang@deltatee.com,
	david@redhat.com, cai@lca.pw
Subject: Re: [PATCH 6/6] arm64/mm: Enable ZONE_DEVICE
Message-ID: <20190403160722.GB12818@redhat.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-7-git-send-email-anshuman.khandual@arm.com>
 <ea5567c7-caad-8a4e-7c6f-cec4b772a526@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ea5567c7-caad-8a4e-7c6f-cec4b772a526@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 03 Apr 2019 16:07:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 02:58:28PM +0100, Robin Murphy wrote:
> [ +Dan, Jerome ]
> 
> On 03/04/2019 05:30, Anshuman Khandual wrote:
> > Arch implementation for functions which create or destroy vmemmap mapping
> > (vmemmap_populate, vmemmap_free) can comprehend and allocate from inside
> > device memory range through driver provided vmem_altmap structure which
> > fulfils all requirements to enable ZONE_DEVICE on the platform. Hence just
> 
> ZONE_DEVICE is about more than just altmap support, no?
> 
> > enable ZONE_DEVICE by subscribing to ARCH_HAS_ZONE_DEVICE. But this is only
> > applicable for ARM64_4K_PAGES (ARM64_SWAPPER_USES_SECTION_MAPS) only which
> > creates vmemmap section mappings and utilize vmem_altmap structure.
> 
> What prevents it from working with other page sizes? One of the foremost
> use-cases for our 52-bit VA/PA support is to enable mapping large quantities
> of persistent memory, so we really do need this for 64K pages too. FWIW, it
> appears not to be an issue for PowerPC.
> 
> > Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> > ---
> >   arch/arm64/Kconfig | 1 +
> >   1 file changed, 1 insertion(+)
> > 
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index db3e625..b5d8cf5 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -31,6 +31,7 @@ config ARM64
> >   	select ARCH_HAS_SYSCALL_WRAPPER
> >   	select ARCH_HAS_TEARDOWN_DMA_OPS if IOMMU_SUPPORT
> >   	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
> > +	select ARCH_HAS_ZONE_DEVICE if ARM64_4K_PAGES
> 
> IIRC certain configurations (HMM?) don't even build if you just turn this on
> alone (although of course things may have changed elsewhere in the meantime)
> - crucially, though, from previous discussions[1] it seems fundamentally
> unsafe, since I don't think we can guarantee that nobody will touch the
> corners of ZONE_DEVICE that also require pte_devmap in order not to go
> subtly wrong. I did get as far as cooking up some patches to sort that out
> [2][3] which I never got round to posting for their own sake, so please
> consider picking those up as part of this series.

Correct _do not_ enable ZONE_DEVICE without support for pte_devmap detection.
If you want some feature of ZONE_DEVICE. Like HMM as while DAX does require
pte_devmap, HMM device private does not. So you would first have to split
ZONE_DEVICE into more sub-features kconfig option.

What is the end use case you are looking for ? Persistent memory ?

Cheers,
Jérôme

