Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39C5CC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 10:31:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB54C20820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 10:31:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB54C20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89AA96B0269; Thu,  4 Apr 2019 06:31:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84AA46B026A; Thu,  4 Apr 2019 06:31:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 739A76B026B; Thu,  4 Apr 2019 06:31:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 253A56B0269
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 06:31:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 41so1162755edq.0
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 03:31:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZCujiDXmTbyssRowfOdFl8GW9qOPoHy39g2hsH3zbvQ=;
        b=tQvkquYMvBRhkZNru1jUQS/ix7gWsqOfpgbWD0mBI+0YjsvvGEmumksZXqfDcWmDM+
         Wl/7XBkiELOXJ/C+NIdz80rx08PTkaoUS9n559RKg+4vJm2Ace2ba+2tOgpfDT8QIrlU
         7/j691d/qIzF+ha11UUdd1bs0gNIStmXy40huaOFX0Nj5Xxr/7ujkJg/D/w8Fpb6sQ+F
         Ktn7SHM2YbggwYTPl+nPyStv9W7TZpuFyrewrC17tspFN5eqwoZeWbAZ3oByMp8ndsqF
         3uFvefL0OmbvZ1vYKSA+zhRsWBAa/zrL9LJN1qSPxd4xwWDGQ/EzKvk1rIVy+55nlSLc
         /8tQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX0twqzHzvfjBktVCDT4hrcW3nUOAy+NNvE/L6taoxp5SrynQTR
	WlnFn2Oj7xHaVlw05VVcV8Ekvs+ozGkZdHbnwHxOobvKz1luWeOi7y7w3ixeih8R0iZruSGg9Gv
	t+h6xNzCLyz9OYxAlJ/02M/pOjwE08rVR2SNu3We1g8S5v/Qc7zU2Ato4ZPWj+8E=
X-Received: by 2002:a50:90b3:: with SMTP id c48mr3249757eda.8.1554373877665;
        Thu, 04 Apr 2019 03:31:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7bEx78c1d1VIExbCg5Xg2BA26Gu8R/cImCKS8u6f3fdr4r6V39xUMH8LDWnXwtvnNX6JM
X-Received: by 2002:a50:90b3:: with SMTP id c48mr3249714eda.8.1554373876819;
        Thu, 04 Apr 2019 03:31:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554373876; cv=none;
        d=google.com; s=arc-20160816;
        b=s90snnSs8QAad/YhPJvd4CleBAoacLpegFDwV4FpzOkoi8zrMXVpIvlFv6WoLLZKPz
         86xE1XFwjRDg5UVlXCot8MKYQfhYJucuWME2l9+lwTe2aN2xaILKev3T6lwgk81Y3yi4
         UUrs0rQp8MsXu2GjNdKHL51tEdQ9hEvrFSzesl5MeEun22OqaDEUMc05QsJm3Z3GbtM0
         XT7xH3aMLxVuks+qUO3r1nD0XdizhtUb+ec4uv6qy8cssVANSzQ6bTSgnNDCsnenGQCs
         2UAjh7p9qGdwTKozx4mrQBk1Oy1TDp1TBRMgglnF6vTfg7WA+oOeAH5iP/t4SIHC2D+B
         Ga/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZCujiDXmTbyssRowfOdFl8GW9qOPoHy39g2hsH3zbvQ=;
        b=tDeEPH9o+hvWbqj4710pmIkb/AIQe8sdpU2BiCUIp/pYctyd24ZjjffezqHfRA85MT
         1gedgTR2rypmitbbbZfQ2P0U+dbg0Qz5xoLSoJ0PW4avdfz4XwQ5tLhjxIIsXTbuuVRL
         MQ3avdwY2dfnmYmASmk//gij1GFLKiecMh9Fk0A4i5HAW1aODeInnhTUBoouzpeSsWcL
         +K5blnsh3q48BCcyo2o5zvOfPvqs5x+oQOTMGC9/i91WolStujgNtrGYORAUlH+/QTbX
         bcD7SfiAm0zUr5KQ6Dis5kRe2OfomIE8v7N87a07oTD8WH1HC7N4n05nvHNdrCIUv1WI
         sKbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i36si1134504eda.358.2019.04.04.03.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 03:31:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4C3D4AF00;
	Thu,  4 Apr 2019 10:31:16 +0000 (UTC)
Date: Thu, 4 Apr 2019 12:31:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, david@redhat.com, dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/4] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20190404103115.GF12864@dhcp22.suse.cz>
References: <20190328134320.13232-1-osalvador@suse.de>
 <20190328134320.13232-3-osalvador@suse.de>
 <20190403084603.GE15605@dhcp22.suse.cz>
 <20190404100403.6lci2e55egrjfwig@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404100403.6lci2e55egrjfwig@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 04-04-19 12:04:05, Oscar Salvador wrote:
> On Wed, Apr 03, 2019 at 10:46:03AM +0200, Michal Hocko wrote:
> > On Thu 28-03-19 14:43:18, Oscar Salvador wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > arch_add_memory, __add_pages take a want_memblock which controls whether
> > > the newly added memory should get the sysfs memblock user API (e.g.
> > > ZONE_DEVICE users do not want/need this interface). Some callers even
> > > want to control where do we allocate the memmap from by configuring
> > > altmap.
> > > 
> > > Add a more generic hotplug context for arch_add_memory and __add_pages.
> > > struct mhp_restrictions contains flags which contains additional
> > > features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
> > > currently) and altmap for alternative memmap allocator.
> > > 
> > > Please note that the complete altmap propagation down to vmemmap code
> > > is still not done in this patch. It will be done in the follow up to
> > > reduce the churn here.
> > > 
> > > This patch shouldn't introduce any functional change.
> > 
> > Is there an agreement on the interface here? Or do we want to hide almap
> > behind some more general looking interface? If the former is true, can
> > we merge it as it touches a code that might cause merge conflicts later on
> > as multiple people are working on this area.
> 
> Uhm, I think that the interface is fine for now.
> I thought about providing some callbacks to build the altmap layout, but I
> realized that it was overcomplicated and I would rather start easy.
> Maybe the naming could be changed to what David suggested, something like
> "mhp_options", which actually looks more generic and allows us to stuff more
> things into it should the need arise in the future.
> But that is something that can come afterwards I guess.
> 
> But merging this now is not a bad idea taking into account that some people
> is working on the same area and merge conflicts arise easily.
> Otherwise re-working it every version is going to be a pita.

I do not get wee bit about naming TBH. Do as you like. But please repost
just these two patches and we can discuss the rest of this feature in a
separate discussion.

Thanks!
-- 
Michal Hocko
SUSE Labs

