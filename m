Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65FB1C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 10:56:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AC52217D4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 10:56:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AC52217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78BF36B0273; Thu, 11 Apr 2019 06:56:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 738DA6B0274; Thu, 11 Apr 2019 06:56:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64ED66B0275; Thu, 11 Apr 2019 06:56:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18DEE6B0273
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 06:56:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h22so1553789edh.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 03:56:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q9l4I5pQ1tPLFiOxAuLKL3TeAsjjhqRb4S0f7sdrzoo=;
        b=pWFSR4H4BBH8AoDtzPJjD6qAmavu+1cYRp1+oGdAzhUfHbOs2Z3uOOmSHvVx2RTK3B
         VDh72B1Kd7aVRj/j7xxwU2i/gTTCmw3t8xsoEGd0RcRW55bDqDAnzEEiMFBKPwT7jnIl
         54mGzgyGIjxKgQVNbMIF0bIsVKu5M+IKl4/180RWa0AMYTHTy7PJkyUNdXsdN80DsVac
         CiCaWLr+gN3taVwehUov43ZaGCFy/RnyLLIzfo6AeZyMoeZKiqhjGDx6soI9+98eMNgp
         /C/AjVoV2SkZX9SvSm96SA+Ws13kB3whGZUDLz/jufwwqzDMmN/UYrZSINFFJxbjr1dp
         qdKg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXL/tGdB/NaXVeEl4rkuH0e0/qt2GouVaXKIZY3f4SaJLuda7Nz
	rrYLgBGGUueuieCrI8nsQkObmaY6+7mQ2xbRLOia9kaoOyfov4oZ9+B3lEINTK/BzmEhrmeMcWs
	S9KpSfJj6XF/gE72x29scoErrEXZ5pSs6Xk6ly5syONitfvfDQlvN54Ozo/daydY=
X-Received: by 2002:a05:6402:3d4:: with SMTP id t20mr21604829edw.104.1554980181646;
        Thu, 11 Apr 2019 03:56:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyC6N7Xk34M1vIWHDmSdTjC75l9Vdfcb+gzV583RkuGPQywIkZP0nPtePNhMQtFjHJbfwtz
X-Received: by 2002:a05:6402:3d4:: with SMTP id t20mr21604792edw.104.1554980180859;
        Thu, 11 Apr 2019 03:56:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554980180; cv=none;
        d=google.com; s=arc-20160816;
        b=A03FAYW2pRhPzL7A7YJQtpftpvnfH5qyG7RKArQYDwdo9kfkR4B23veRn51DNlv9++
         cKG3XmdaLLG9bCclPxAf2jVtapNQCDvg8mDabDrO0d6euwDkRxFma0+ARIQIgKeRNizO
         g94uXGfYUdF1XH1h+9wb+vY3i1wiOb/DpjXla6vU3KweBp1mOD5XBqMfb5FwZ2L+DANo
         XOc20lbU8qFG3nMRiYN0chKKGiNqwJB+DHcbM/Mjfthr0eX/TZPbduAA5MQtlOzcoJG3
         741LzXodWA5MLllwk07mvQoQpk0aOxtH8Gza2K4Fbikhqre5h1Ml2SxXoT8IXJUFEO2s
         V5fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q9l4I5pQ1tPLFiOxAuLKL3TeAsjjhqRb4S0f7sdrzoo=;
        b=wLMRnKE8F7KZgKiwR7oqAi+jASEfTAh/0R4Vkxuqn6KvhDzjLQtpoITTNRXFPK9Y0Y
         x7HWER4xe3BhXyo5Po+Hfg1e4aDuix5uZJdSGGfgzTcADJRfrY3Yahqc7wNbQxR42Jwo
         4ehPdxYrSAe+BLoEZGE9D2ovO6DpppfOK224AvoEWvaw/Bx+e/gRtTaNVlMwigOUshOS
         uE0Gd6rSabCCTI+keBWf5QwWchAKfSqZRp0oARDf4GLzO0HFETJghpJNpwxe9S4Aq6HC
         QUwa0dTHBOxQVNv0rOIv3+M18dJYuocJUFyW2EZ262lz33wMx99kUC80dxSjNOMwn8n4
         Q+iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si466624edd.76.2019.04.11.03.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 03:56:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2CF44ABAC;
	Thu, 11 Apr 2019 10:56:20 +0000 (UTC)
Date: Thu, 11 Apr 2019 12:56:17 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH] mm/memory_hotplug: Drop memory device reference after
 find_memory_block()
Message-ID: <20190411105617.GS10383@dhcp22.suse.cz>
References: <20190410101455.17338-1-david@redhat.com>
 <20190411084141.GQ10383@dhcp22.suse.cz>
 <0bbe632f-cb85-4a98-0c79-ded11cf39081@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0bbe632f-cb85-4a98-0c79-ded11cf39081@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 11:11:05, David Hildenbrand wrote:
> On 11.04.19 10:41, Michal Hocko wrote:
> > On Wed 10-04-19 12:14:55, David Hildenbrand wrote:
> >> While current node handling is probably terribly broken for memory block
> >> devices that span several nodes (only possible when added during boot,
> >> and something like that should be blocked completely), properly put the
> >> device reference we obtained via find_memory_block() to get the nid.
> > 
> > The changelog could see some improvements I believe. (Half) stating
> > broken status of multinode memblock is not really useful without a wider
> > context so I would simply remove it. More to the point, it would be much
> > better to actually describe the actual problem and the user visible
> > effect.
> > 
> > "
> > d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug") has started
> > using find_memory_block to get a nodeid for the beginnig of the onlined
> > pfn range. The commit has missed that the memblock contains a reference
> > counted object and a missing put_device will leak the kobject behind
> > which ADD THE USER VISIBLE EFFECT HERE.
> > "
> 
> I don't think mentioning the commit a second time is really needed.
> 
> "
> Right now we are using find_memory_block() to get the node id for the
> pfn range to online. We are missing to drop a reference to the memory
> block device. While the device still gets unregistered via
> device_unregister(), resulting in no user visible problem, the device is
> never released via device_release(), resulting in a memory leak. Fix
> that by properly using a put_device().
> "

OK, sounds good to me. I was not sure about all the sysfs machinery
and the kobj dependencies but if there are no sysfs files leaking and
crashing upon a later access then a leak of a small amount of memory
that is not user controlable then this is not super urgent.

Thanks!

-- 
Michal Hocko
SUSE Labs

