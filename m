Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6848C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:05:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A39F2082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:05:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A39F2082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B3136B0005; Thu,  4 Apr 2019 08:05:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 061686B0006; Thu,  4 Apr 2019 08:04:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E946F6B0007; Thu,  4 Apr 2019 08:04:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A57C6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 08:04:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m32so1293742edd.9
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 05:04:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XR2B/chloHiq/qru7Oa83LKLBsVzX+PkM+70Jovxs7o=;
        b=PlzEt2ByL7+NftSQNdG7NNoTbNDyJT+Gw61Dg2JIWQmV8kaofELHa2YTMqRgABRZjO
         upNXMmToIhabLuLppAYzBvNyaDBgDXkupKm6GEb89Eod8hn0DTDLwfTwAmO36YYwYFta
         IZCipcm55El4H5YjlGECzkwmQREnri4roNAfmqLiYIGh++G89MhRkGOf3C0+BMIq0km3
         oEzRqO7eqOcQGSx+xqaq3kFCrhmnCOR2rSb89zbWPXXx96PFxFKQM/77/2XjiREowYQ/
         Vo+295/Rqt6MgAZk/ZXuFjtLOhvjr7XdH9SKnkKDPDfwJSgoAkY9r4Wj9AJTiwvlDk+M
         mcqA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWfcAx/EECI74aXXPQLuYkMOb/5aXAAibhdZFLYGXF8Q0f8SS43
	sDJw2cfjSzd5MfWLkxEaZA81ljVnttEpIA7b7mpuO1Ff2UhfLhTo7B6YTXF14sZb+6n1NxOSEwD
	YU/2zf0mSoWTOd7uAsJrSkd8zzASZpW6T9Jp5DZTzII2WGhEFjg8sk4cdTmtWsaw=
X-Received: by 2002:a17:906:a445:: with SMTP id cb5mr3491439ejb.196.1554379499185;
        Thu, 04 Apr 2019 05:04:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwn+V9JX236qjr9FUebkZlJBVW6/CvqTBkC5Ei20/EkJmAupYYaj2uUp+fbsvT2TuaGHVKF
X-Received: by 2002:a17:906:a445:: with SMTP id cb5mr3491377ejb.196.1554379497922;
        Thu, 04 Apr 2019 05:04:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554379497; cv=none;
        d=google.com; s=arc-20160816;
        b=WDPXPa+92SpIRwjG9ZQZ1xj86aU/HPJyYH9SIZDfxMfb7QhzMK3SIvSHK7Ng+XG9fw
         nxHX5FSkB1xS5O//q7aTjt8SXsz1l0FyXPsbxhIPzySJmb+m2DAJAvAlMAl3EM9seaJP
         yRbvIH1IH397wdaCqTLacu7f11oPsnyfPT0TQ8exsBtygD/r5pV8j+fxq1XTxFJYKU6b
         Lzgq3fDPf8A2eN98kqPPZUkz2lgV6rfk+T7pEiUxjQqoSZLFyQDv56x78dPcIts+wg8U
         mIKil/d4wEHLEL4A3V6ub2WaSBViuEHjSCdAs4RA6DHCrb0oLh7NVXSYfKWzBFt6fyl7
         AzIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XR2B/chloHiq/qru7Oa83LKLBsVzX+PkM+70Jovxs7o=;
        b=Pt3UbPHnF5s510rBIHCRuA+6mL8/KLQUxtpyTxf1/SrOe6oqcH/8GFVieOWWvVz9E/
         gdPTtA4IbYzrTnmFHXJ6TQU8LiDFWCdlGk9t/5w1rJpte3c9RROB/TLsSh1rHmGRG1uf
         UrkmuqUuOsgnjTPjvzp6lQmEelvvPFoWEQ1ajj9j78twsbN6Xja00FrOHk2ThqXURSmJ
         k6otca7wc3OQjXz07idkQr4Gvj2wFJM20JMZBLOH6UwWlwXWCbbukE00xWCt4GDRebqU
         nyNptdAChmvVy6FWp1AcZOQ4kANaxqqDURZbb54B6QwCATtzxUctSPLDD9SIZE/3/96Z
         yKzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id j11si4169743ejm.39.2019.04.04.05.04.57
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 05:04:57 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 1676C4817; Thu,  4 Apr 2019 14:04:56 +0200 (CEST)
Date: Thu, 4 Apr 2019 14:04:56 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, david@redhat.com, dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/4] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20190404120456.htogl7lck6v4rj37@d104.suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
 <20190328134320.13232-3-osalvador@suse.de>
 <20190403084603.GE15605@dhcp22.suse.cz>
 <20190404100403.6lci2e55egrjfwig@d104.suse.de>
 <20190404103115.GF12864@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404103115.GF12864@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 12:31:15PM +0200, Michal Hocko wrote:
> On Thu 04-04-19 12:04:05, Oscar Salvador wrote:
> > On Wed, Apr 03, 2019 at 10:46:03AM +0200, Michal Hocko wrote:
> > > On Thu 28-03-19 14:43:18, Oscar Salvador wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > arch_add_memory, __add_pages take a want_memblock which controls whether
> > > > the newly added memory should get the sysfs memblock user API (e.g.
> > > > ZONE_DEVICE users do not want/need this interface). Some callers even
> > > > want to control where do we allocate the memmap from by configuring
> > > > altmap.
> > > > 
> > > > Add a more generic hotplug context for arch_add_memory and __add_pages.
> > > > struct mhp_restrictions contains flags which contains additional
> > > > features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
> > > > currently) and altmap for alternative memmap allocator.
> > > > 
> > > > Please note that the complete altmap propagation down to vmemmap code
> > > > is still not done in this patch. It will be done in the follow up to
> > > > reduce the churn here.
> > > > 
> > > > This patch shouldn't introduce any functional change.
> > > 
> > > Is there an agreement on the interface here? Or do we want to hide almap
> > > behind some more general looking interface? If the former is true, can
> > > we merge it as it touches a code that might cause merge conflicts later on
> > > as multiple people are working on this area.
> > 
> > Uhm, I think that the interface is fine for now.
> > I thought about providing some callbacks to build the altmap layout, but I
> > realized that it was overcomplicated and I would rather start easy.
> > Maybe the naming could be changed to what David suggested, something like
> > "mhp_options", which actually looks more generic and allows us to stuff more
> > things into it should the need arise in the future.
> > But that is something that can come afterwards I guess.
> > 
> > But merging this now is not a bad idea taking into account that some people
> > is working on the same area and merge conflicts arise easily.
> > Otherwise re-working it every version is going to be a pita.
> 
> I do not get wee bit about naming TBH. Do as you like. But please repost
> just these two patches and we can discuss the rest of this feature in a
> separate discussion.

Sure, I will repost them in the next hour (just want to check that everything
is alright).

-- 
Oscar Salvador
SUSE L3

