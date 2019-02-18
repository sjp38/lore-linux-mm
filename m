Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98F08C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:04:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F605206B7
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:04:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F605206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F050A8E0004; Mon, 18 Feb 2019 04:04:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBF3A8E0002; Mon, 18 Feb 2019 04:04:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7EFD8E0004; Mon, 18 Feb 2019 04:04:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77C4D8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:04:41 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c53so6928086edc.9
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 01:04:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bVz+ef9BUELcEQozHVwrKrHx7VZ9+CwQCVvpB7f9kpA=;
        b=pdgZTfwMrUIAJNMK3QPYohhQhtn+qrkK/ofeJEzQI0tLBcnfThjp67PE8+PmAz/yhu
         xcCOxpMHU/Rw066+p8g+wxpDySeWcW7xZDAQPvhGLrTQt4LHMFSBZCxQPIRUiKwkalfy
         vaLrUmn3w0MwC8fSLNMkcHTMnOpNlAuCwiP4uai5bZuzZCT2NL/xggABjVKnrcgobZqK
         bNcxDTkutQjrvLMkVqoXcAk6jw8wTbNzKM2MzYS/jY0fnWXmSETQXDEm4lB097l4SsTj
         ixLdgKd48QOCYcnxooDM1H7aXUnyGiTfjMYL9hyZ47SE3iV+HlvA53H8sZa27OhtLjzC
         84dg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAuY8Du1EnX78btlr9FqLNP+uV8eMJHA44t8GHhArY3DmfxoXllV3
	PvtBLaW7vPvlOXQ1I+9mXAFOcfj+ek0U+ljML/DTs20D3k+zLvHSfWGpc8YOt8egk9JHzK3Kid8
	L/Dgy95Q4OkVhz27upvw9wcNKgfb+N3djs5TNHXPHHty2OwK97WasdY0ahxq84QhPHA==
X-Received: by 2002:a17:906:82c2:: with SMTP id a2mr16055195ejy.8.1550480681050;
        Mon, 18 Feb 2019 01:04:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IblBCl9g5jiprfYrNlSwK3SZkg0vl8GBNyoDdor0oNXksJ5majzFiFodLI8BolWKKktogB8
X-Received: by 2002:a17:906:82c2:: with SMTP id a2mr16055148ejy.8.1550480680133;
        Mon, 18 Feb 2019 01:04:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550480680; cv=none;
        d=google.com; s=arc-20160816;
        b=vyfTmy+KS0VcIAwug5gnNfYn1Z/zHrainKWER8Ph/jmYKTnUTPEkKrKp7PmMbVy5Un
         L/5oy4/OmhQ+1DSOqm1gJUGD1G+YZigzKa4/wbbhaOsIr3WWNx+R/VQEsyELW/fhaWbU
         DIwM9jMng2FCbfxIWofS5sj9UKBl1p/IFxxwXdBFLOMHggKiAX3XwCpyGv7W40GeOHom
         OMSt3yKazQkfHDaXwOcKjAmrDwEEPSuuRxeHTnVDYenn1dUUplhK3PpLq2NxAb0fk7bu
         3H7P90yvxrcdl6Zm4tlN6G1lLfw5XzJtNaAqXfIYh7/nXqVfm+2NVpd57hmIF5x40KPu
         U6XQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bVz+ef9BUELcEQozHVwrKrHx7VZ9+CwQCVvpB7f9kpA=;
        b=KWqFHudnQt8cBi+7QZEzeamQVSZ+TMi/r+CKTc1YhOtbmqVq/Wqo792BmiMYLCQdS/
         CKfJfEO2bcdPmtk4kA+LC+DqKhFmasYD/hmUj5VDQ5QNPCeOAiTVX/wu7M6iUylCbXIJ
         TewqL3LR2eLf9EPoDvtOk4WXIxRBJMZeR/xrN9+OU/Di7iPC3BLFHuji/dduG4AsKGZh
         TC88vAS1tiS7A4T75zp4MQ7z8DYKfU7qXXXXVuQkqpOAyxcNv8YwmC65oHH6WgoHVt/H
         RVJ2F0xR7Clonz494/8RZfIsgfuh8x8WryYYNi/rgh/sNQnlclar7+o/MXVkVy8dtKcv
         K/yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b8si4673859ejj.266.2019.02.18.01.04.39
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 01:04:40 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E80FFA78;
	Mon, 18 Feb 2019 01:04:38 -0800 (PST)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0DE0C3F589;
	Mon, 18 Feb 2019 01:04:36 -0800 (PST)
Date: Mon, 18 Feb 2019 09:04:34 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, mhocko@kernel.org, kirill@shutemov.name,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz,
	will.deacon@arm.com
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
Message-ID: <20190218090433.bxtty3rrgo4ln6hp@mbp>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <7f25d3f4-68a1-58de-1a78-1bd942e3ba2f@intel.com>
 <413d74d1-7d74-435c-70c0-91b8a642bf99@arm.com>
 <35b14038-379f-12fb-d943-5a083a2a7056@intel.com>
 <3da12849-bc56-cb9b-f13f-e15d42416223@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3da12849-bc56-cb9b-f13f-e15d42416223@arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 02:01:55PM +0530, Anshuman Khandual wrote:
> On 02/14/2019 10:25 PM, Dave Hansen wrote:
> > On 2/13/19 8:12 PM, Anshuman Khandual wrote:
> >> On 02/13/2019 09:14 PM, Dave Hansen wrote:
> >>> On 2/13/19 12:06 AM, Anshuman Khandual wrote:
> >>>> Setting an exec permission on a page normally triggers I-cache invalidation
> >>>> which might be expensive. I-cache invalidation is not mandatory on a given
> >>>> page if there is no immediate exec access on it. Non-fault modification of
> >>>> user page table from generic memory paths like migration can be improved if
> >>>> setting of the exec permission on the page can be deferred till actual use.
> >>>> There was a performance report [1] which highlighted the problem.
> >>>
> >>> How does this happen?  If the page was not executed, then it'll
> >>> (presumably) be non-present which won't require icache invalidation.
> >>> So, this would only be for pages that have been executed (and won't
> >>> again before the next migration), *or* for pages that were mapped
> >>> executable but never executed.
> >> I-cache invalidation happens while migrating a 'mapped and executable' page
> >> irrespective whether that page was really executed for being mapped there
> >> in the first place.
> > 
> > Ahh, got it.  I also assume that the Accessed bit on these platforms is
> > also managed similar to how we do it on x86 such that it can't be used
> > to drive invalidation decisions?
> 
> Drive I-cache invalidation ? Could you please elaborate on this. Is not that
> the access bit mechanism is to identify dirty pages after write faults when
> it is SW updated or write accesses when HW updated. In SW updated method, given
> PTE goes through pte_young() during page fault. Then how to differentiate exec
> fault/access from an write fault/access and decide to invalidate the I-cache.
> Just being curious.

The access flag is used to identify young/old pages only (the dirty bit
is used to track writes to a page). Depending on the Arm implementation,
the access bit/flag could be managed by hardware transparently, so no
fault taken to the kernel on accessing through an 'old' pte.

-- 
Catalin

