Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB4E4C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 19:19:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72DD8214AE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 19:19:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72DD8214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B64586B0003; Thu, 25 Jul 2019 15:19:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AED4B6B0005; Thu, 25 Jul 2019 15:19:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2A018E0002; Thu, 25 Jul 2019 15:19:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5544C6B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 15:19:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so32703208edx.12
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:19:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lmB5gyk5z7+8DzdQOzakINtq7cj53zRkfHEJTTO5Msw=;
        b=WaewSuPbJl4vlb+Vqepr7WA2J4EkRz5SRAdZrVkSxipuUBpA+6qmIxTZmz1qGGiokP
         X+aSD7E/QT2h57/l7eT0VZ/jE95Q4jD5GKE7mBN+XO5E+3fPZslw8u3rPduHWtyP4IzF
         mSr89ng1RZExfya7k3RCblxk0wX0U65f7JCGIYVivr1qmi4XcbpiJRochPjIHv1J53aS
         eTp1bVSW565lrm0SJTsichkHfgizs0nILIIUGt3l/Vkb8+teq1OwuOrlggbDge6qxv0g
         qcX1JS1kXZmtmYcOXB5tyCaPmqYl0RTAJq7yzAN8QkE4sthciwkhWUVBYVf3c9rXAZnK
         ieNw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWl/gLgVBqitbRz0uP2GPi0jwT6gni5B0vTTwHCKPREOCl77w5p
	gvF4iR/z0Esef17Qfh5BWqFkS4bAGsYWNEnb14Noq+wVPEhQUsYma4vGxZXCIva0PMgvQozx4Yp
	VtQ1l+60lPHHM6VWZHB6CvIbmLijcFQR77fVGlgFXW3gkBGkgnXh38PoVlk9WVUs=
X-Received: by 2002:a50:8ba6:: with SMTP id m35mr78641075edm.199.1564082386812;
        Thu, 25 Jul 2019 12:19:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZHUH/Xd+4b7qxtVo2Sw9DxR+h299H6r6GbYv2sEKKsHUynbguLit+vMhGiiQ9JmguW807
X-Received: by 2002:a50:8ba6:: with SMTP id m35mr78641007edm.199.1564082385910;
        Thu, 25 Jul 2019 12:19:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564082385; cv=none;
        d=google.com; s=arc-20160816;
        b=G0N76Ski7zi0TOggO7qFgjGXfMvHt0ry5+ffHKd8jP0DIxTTWBo49SYUbTI7tLZOyu
         9DKVrdKsIx/bcBnarBvsk2jXtZMW4J6KKGIdoeOvbpJcqKsgvTQNGrr9ieYwcmHnMIL4
         UURtE+VTxJ2AOWjY114fMhrGLsnquthOjF9qM/OrjoM0Ij3x56cecVOANUfuD5rGZ4ht
         ApJNFaoljo6HImgcX9tdvm+THUGQXcR2q0ifeYbwUmPCLHa4tQiQFkSnI6zy85CZBv6n
         s6Oh8nU1245KInEg2qqyx+oMw/GRkHalhq2fi/yFyy6hxgompZzKYLm5KrQD6uuiPegM
         Gyrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lmB5gyk5z7+8DzdQOzakINtq7cj53zRkfHEJTTO5Msw=;
        b=din5LfS47OUsxLBJhun6MB06ZvXzpIOHmcegWnuR1vM3UxMDEbxqcHZYoOgB2eDY6F
         hEUetS5WyeCMf848hhhfYNHN4T63iBItYgBGP6sa50sGDNiSQWJIfVCs1LwaKvM/9t1Q
         08Z1NSPk7xtGGNUT8wznsyeDdOnP5YW12aSg3GxQ9O1ggYfJfgpxjA9CHguWKHG/zjQY
         JGPZW0Ige5aML5+D4szaPcC/VNNxiMbtGXUNYx0G3iX53AgE98GdH8yCDm6Gdnnra658
         VrbCg7oRKGtg537AUf3QIpCdvEX1nWH5DtSnoCVVLFnJE3DjEJWJl78F9Z6Xsn5z3hT2
         xT5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga14si9875279ejb.297.2019.07.25.12.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 12:19:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EFC79ADD9;
	Thu, 25 Jul 2019 19:19:44 +0000 (UTC)
Date: Thu, 25 Jul 2019 21:19:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
Message-ID: <20190725191943.GA6142@dhcp22.suse.cz>
References: <20190724143017.12841-1-david@redhat.com>
 <20190725125636.GA3582@dhcp22.suse.cz>
 <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com>
 <20190725135747.GB3582@dhcp22.suse.cz>
 <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-07-19 16:35:07, David Hildenbrand wrote:
> On 25.07.19 15:57, Michal Hocko wrote:
> > On Thu 25-07-19 15:05:02, David Hildenbrand wrote:
> >> On 25.07.19 14:56, Michal Hocko wrote:
> >>> On Wed 24-07-19 16:30:17, David Hildenbrand wrote:
> >>>> We end up calling __add_memory() without the device hotplug lock held.
> >>>> (I used a local patch to assert in __add_memory() that the
> >>>>  device_hotplug_lock is held - I might upstream that as well soon)
> >>>>
> >>>> [   26.771684]        create_memory_block_devices+0xa4/0x140
> >>>> [   26.772952]        add_memory_resource+0xde/0x200
> >>>> [   26.773987]        __add_memory+0x6e/0xa0
> >>>> [   26.775161]        acpi_memory_device_add+0x149/0x2b0
> >>>> [   26.776263]        acpi_bus_attach+0xf1/0x1f0
> >>>> [   26.777247]        acpi_bus_attach+0x66/0x1f0
> >>>> [   26.778268]        acpi_bus_attach+0x66/0x1f0
> >>>> [   26.779073]        acpi_bus_attach+0x66/0x1f0
> >>>> [   26.780143]        acpi_bus_scan+0x3e/0x90
> >>>> [   26.780844]        acpi_scan_init+0x109/0x257
> >>>> [   26.781638]        acpi_init+0x2ab/0x30d
> >>>> [   26.782248]        do_one_initcall+0x58/0x2cf
> >>>> [   26.783181]        kernel_init_freeable+0x1bd/0x247
> >>>> [   26.784345]        kernel_init+0x5/0xf1
> >>>> [   26.785314]        ret_from_fork+0x3a/0x50
> >>>>
> >>>> So perform the locking just like in acpi_device_hotplug().
> >>>
> >>> While playing with the device_hotplug_lock, can we actually document
> >>> what it is protecting please? I have a bad feeling that we are adding
> >>> this lock just because some other code path does rather than with a good
> >>> idea why it is needed. This patch just confirms that. What exactly does
> >>> the lock protect from here in an early boot stage.
> >>
> >> We have plenty of documentation already
> >>
> >> mm/memory_hotplug.c
> >>
> >> git grep -C5 device_hotplug mm/memory_hotplug.c
> >>
> >> Also see
> >>
> >> Documentation/core-api/memory-hotplug.rst
> > 
> > OK, fair enough. I was more pointing to a documentation right there
> > where the lock is declared because that is the place where people
> > usually check for documentation. The core-api documentation looks quite
> > nice. And based on that doc it seems that this patch is actually not
> > needed because neither the online/offline or cpu hotplug should be
> > possible that early unless I am missing something.
> 
> I really prefer to stick to locking rules as outlined on the
> interfaces if it doesn't hurt. Why it is not needed is not clear.
> 
> > 
> >> Regarding the early stage: primarily lockdep as I mentioned.
> > 
> > Could you add a lockdep splat that would be fixed by this patch to the
> > changelog for reference?
> > 
> 
> I have one where I enforce what's documented (but that's of course not
> upstream and therefore not "real" yet)

Then I suppose to not add locking for something that is not a problem.
Really, think about it. People will look at this code and follow the
lead without really knowing why the locking is needed.
device_hotplug_lock has its purpose and if the code in question doesn't
need synchronization for the documented scenarios then the locking
simply shouldn't be there. Adding the lock just because of a
non-existing, and IMHO dubious, lockdep splats is just wrong.

We need to rationalize the locking here, not to add more hacks.

-- 
Michal Hocko
SUSE Labs

