Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7914C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:57:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B8062075E
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:57:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B8062075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 417818E007C; Thu, 25 Jul 2019 09:57:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A0BE8E0059; Thu, 25 Jul 2019 09:57:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 269258E007C; Thu, 25 Jul 2019 09:57:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9F1A8E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:57:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y3so32170541edm.21
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:57:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rbZrFv6TyT1MLJGn14MO+/zIVuWKsEE0a2Ymr+7KULY=;
        b=ehYzRBtgiFPiRk0zpCKCTaLXDA96QrMTpDVYEAXLLs7JwPOece/oMz8+XfwxbyZtFF
         bKXJ2H3eyIXaUf8cV78os7vEZNFJMZqO/+jzyQXHUTQ6NsgO/DQL9JFJ32uIZWv7nMKQ
         QBs+s0wIJ1Pt/erYLw3P8IgPRfNIb1xMByYdJz3L4CQScwoqkOnw+9CgJf8NCva1/KGc
         ynXWMP3ZFZyxt3N2fz6Dh1SAXO5L2SIQUOJvXjH/j2L5Dyu0AmURZ7144LZJDYi7NtbI
         KWkntxvBkgTJhay6wf/MyYfienOKSywu1JrW/emF9zPYRbhHGzytnaPCjXSK4qi3Or49
         gJ5A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUQ3mv0rcL073bZsGEY8luTNllujg4H1CDlcG56WD/AfafALGpt
	kpz8dXAi6ePwY/gQFL8QvaE80qDIL9A8u8KgQ5FaERujPHsS+I6EoxSKk08y8yXHIdhJ+G5/oHL
	jYC8wAdUO39lBieob79/8ERGMtr0cLooLaAZmkGmC6/nq+6MA2FhTQ8QGI9GBiwk=
X-Received: by 2002:a17:906:45ce:: with SMTP id z14mr68153717ejq.144.1564063069377;
        Thu, 25 Jul 2019 06:57:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXM9ecsgU7FzjVsRnwzyW6NVSXQvc6mGFJd2Jto9DMjV7i18Yzy0vdnb6clfTAjWLoxpkg
X-Received: by 2002:a17:906:45ce:: with SMTP id z14mr68153672ejq.144.1564063068529;
        Thu, 25 Jul 2019 06:57:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564063068; cv=none;
        d=google.com; s=arc-20160816;
        b=l5uan7fmHqvcyis9bOzIo0DC+fmNOxu7uMXk5M5VAalpngQ25xAXjcNgq7LKaDCZdx
         058rCNV0OYCcfkUk3NPgG9MrbuIjYD+9G9gxyuHiTQRyrbkNrzunW+QcysWRKcJ8GLp6
         gTZZEqXN+n46P6+HRO3XIIPcbKAnf7z30mC5bj3W6uC1CgcdsCyGfHRw6v329Lh2Dtxu
         0Q3IWwEEgub2AFOQd04H7jT5nP8NIqWN/4T6TnyUplgl5xhyN99EKCfn7cCf6FT0d9A7
         npDLOjbIWm6UXejLkcHRu0UGXISzFVfqillhhQmoujtPbKgkdPMq3u0yaPw1RCkQr8Rr
         kJZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rbZrFv6TyT1MLJGn14MO+/zIVuWKsEE0a2Ymr+7KULY=;
        b=GFrIjQ6e5+28bvt5wllCzmIyULAMa8lFl44rWQEGfC4Ljh6lWHOsbiOSpE4WWC1Hw/
         zxBOIQOJf0+pwETD14dr2WEPP4ah/tk+2Tyh5q4RSae0n4E+9Vw5xs4xFB7x5GV7sj+z
         a+R37d3xYKYIJCk8at3DGgsOHJLTxOEW+CUw5ptIkwYcjnbnlVgTBGhyHMalqrJscZ9r
         De1vGoYHbigNs71Ky6MwLiwq773wsu9dxw9eUlNTyA7fqV8nUt1Mq4jRQKJFFpvl/WGn
         GBzVVVF22XC45N2EpPE5kUYek06lNoeYDvlbaKoaA6t5z9vmLpEcLlwlpt1LNRxfbLNN
         IFIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ot29si9102784ejb.111.2019.07.25.06.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 06:57:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A79ACAFCE;
	Thu, 25 Jul 2019 13:57:47 +0000 (UTC)
Date: Thu, 25 Jul 2019 15:57:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
Message-ID: <20190725135747.GB3582@dhcp22.suse.cz>
References: <20190724143017.12841-1-david@redhat.com>
 <20190725125636.GA3582@dhcp22.suse.cz>
 <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-07-19 15:05:02, David Hildenbrand wrote:
> On 25.07.19 14:56, Michal Hocko wrote:
> > On Wed 24-07-19 16:30:17, David Hildenbrand wrote:
> >> We end up calling __add_memory() without the device hotplug lock held.
> >> (I used a local patch to assert in __add_memory() that the
> >>  device_hotplug_lock is held - I might upstream that as well soon)
> >>
> >> [   26.771684]        create_memory_block_devices+0xa4/0x140
> >> [   26.772952]        add_memory_resource+0xde/0x200
> >> [   26.773987]        __add_memory+0x6e/0xa0
> >> [   26.775161]        acpi_memory_device_add+0x149/0x2b0
> >> [   26.776263]        acpi_bus_attach+0xf1/0x1f0
> >> [   26.777247]        acpi_bus_attach+0x66/0x1f0
> >> [   26.778268]        acpi_bus_attach+0x66/0x1f0
> >> [   26.779073]        acpi_bus_attach+0x66/0x1f0
> >> [   26.780143]        acpi_bus_scan+0x3e/0x90
> >> [   26.780844]        acpi_scan_init+0x109/0x257
> >> [   26.781638]        acpi_init+0x2ab/0x30d
> >> [   26.782248]        do_one_initcall+0x58/0x2cf
> >> [   26.783181]        kernel_init_freeable+0x1bd/0x247
> >> [   26.784345]        kernel_init+0x5/0xf1
> >> [   26.785314]        ret_from_fork+0x3a/0x50
> >>
> >> So perform the locking just like in acpi_device_hotplug().
> > 
> > While playing with the device_hotplug_lock, can we actually document
> > what it is protecting please? I have a bad feeling that we are adding
> > this lock just because some other code path does rather than with a good
> > idea why it is needed. This patch just confirms that. What exactly does
> > the lock protect from here in an early boot stage.
> 
> We have plenty of documentation already
> 
> mm/memory_hotplug.c
> 
> git grep -C5 device_hotplug mm/memory_hotplug.c
> 
> Also see
> 
> Documentation/core-api/memory-hotplug.rst

OK, fair enough. I was more pointing to a documentation right there
where the lock is declared because that is the place where people
usually check for documentation. The core-api documentation looks quite
nice. And based on that doc it seems that this patch is actually not
needed because neither the online/offline or cpu hotplug should be
possible that early unless I am missing something.

> Regarding the early stage: primarily lockdep as I mentioned.

Could you add a lockdep splat that would be fixed by this patch to the
changelog for reference?

-- 
Michal Hocko
SUSE Labs

