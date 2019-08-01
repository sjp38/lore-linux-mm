Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E474C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:27:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B4542087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:27:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B4542087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D865F8E0005; Thu,  1 Aug 2019 04:27:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D36DB8E0001; Thu,  1 Aug 2019 04:27:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFFF48E0005; Thu,  1 Aug 2019 04:27:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 719B08E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:27:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so44243239edd.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:27:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=urimzy0FUvCX2sZ5avv9c+GeUlY1+VGt57NmImw/S9k=;
        b=M0IHAgBadH7yAeKvx6mm+F3i6MdDPimotRtLUK70UGFNDCR69Up70V05rkIkficb/q
         l34LUN1R6QehFxqOTS7hO4uSHBT1GEfV2Jt1BjOnvSt4ABWr93BpZU1aU5sh1eJ9VtrS
         OrTXQkasXMK4NTC/rbCiQLQp2DvDkiJ0keijPMr4vVAaQhAzvESuNwmOdpstvMMFrFyY
         8d0IpE7RlyKE+t6/glnGnaLKnq+s37NirJezl1jBeo1bYq4W9rpaFCsoEXt2HCep0W52
         R9Jic2nxO0segdrYwfSwCg8AOOFbMmSGhsTM2OFVizfM9hdW1CiVUCfBoe3R+YY82CY/
         lbdw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWpwD/EDDcoZY12ois9TUA+LEDV0oWxCrwWPX++ZWdvnNJNRNtv
	oJWgOIYDcG8bBpsrcMwg6jSqwJD9V3j6nFaLSsgwPcfKL8LJlr6kmp6zNkAb9vXNzm6D9vuW7Za
	MD7tOoXEx2YhIUG7SEZNImUxjw0xK2RdqRbZnHqjz4FtbyFKYxm3U5lQ+ZPUqDow=
X-Received: by 2002:a17:906:b243:: with SMTP id ce3mr97069663ejb.176.1564648065009;
        Thu, 01 Aug 2019 01:27:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPww9CLs42Amiz5I6PgCuGYxowM1nzHt7+YHEhYjurrQd5wq14gyxAgOObGIGC194tfyrm
X-Received: by 2002:a17:906:b243:: with SMTP id ce3mr97069630ejb.176.1564648064211;
        Thu, 01 Aug 2019 01:27:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564648064; cv=none;
        d=google.com; s=arc-20160816;
        b=CYY1JzFMtf/nexmvoHjOg12CY8RIslBZhQVnYYpIMyMJ/rNTjfcGqj5tehyr6bwONJ
         V8SwmTVME4QzLPNm0nW2sUZXN/Bvg0X6vLd+Wk7jQNqgFZhoDPxK5ecAYdHAyJtQBzzl
         Q6YnvFZY1fUN+mfTwAteFBhnNVZU0UhcoWHpB5nY09PYDA+tsYutmKTfvC5mA2co9BXW
         W4HdeHH6qJqiDckauxCojwImPY5k4hhbYrTRD6at6eVy/6YMM45kGZKK2b0Fwf4lD1hY
         QYXdqrwC65PqyZgRr1TXnVPY8cnCE6p/IKJ5moD71gMUNyAlwvmsYTOivVUekk/9JnNm
         y3xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=urimzy0FUvCX2sZ5avv9c+GeUlY1+VGt57NmImw/S9k=;
        b=GCyeXrrpenxk8kD1aFk+gVdkpeWkLzY5aFeectBPctFdScJTZiAb9pC4BtgiyjZHS9
         KdfZyPhFn6A11MXvnOB+0xIudah8aGZIUjgDmydqrHOiW3mtbSmzBOl1rbKywCLbMnr6
         ro+f52oxXzg/eTBTv8AMSNpsFtbjSqQfSOIJ9Nsziioe/U2P6vY6RR0Rw6NGNjKMaZlK
         R6LWLb33+P0YIRJQUvrFqyjbnSyo4U5WC6xdaWJlzpuFsf6JghKMwYF1DII+bK8ur3wl
         hh7S5w8Kl1eQ7PguHT6PXf96JwxtBSJt1QktYzTSMqly3AKFnZ/BKhVbtcYH2TufLVXt
         khUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si19041020eja.245.2019.08.01.01.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 01:27:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B402AB63C;
	Thu,  1 Aug 2019 08:27:43 +0000 (UTC)
Date: Thu, 1 Aug 2019 10:27:41 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in
 memory blocks
Message-ID: <20190801082741.GK11627@dhcp22.suse.cz>
References: <20190731124356.GL9330@dhcp22.suse.cz>
 <f0894c30-105a-2241-a505-7436bc15b864@redhat.com>
 <20190731132534.GQ9330@dhcp22.suse.cz>
 <58bd9479-051b-a13b-b6d0-c93aac2ed1b3@redhat.com>
 <20190731141411.GU9330@dhcp22.suse.cz>
 <c92a4d6f-b0f2-e080-5157-b90ab61a8c49@redhat.com>
 <20190731143714.GX9330@dhcp22.suse.cz>
 <d9db33a5-ca83-13bd-5fcb-5f7d5b3c1bfb@redhat.com>
 <20190801061344.GA11627@dhcp22.suse.cz>
 <f8767e9a-034d-dca6-05e6-dc6bbcb4d005@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f8767e9a-034d-dca6-05e6-dc6bbcb4d005@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 09:00:45, David Hildenbrand wrote:
> On 01.08.19 08:13, Michal Hocko wrote:
> > On Wed 31-07-19 16:43:58, David Hildenbrand wrote:
> >> On 31.07.19 16:37, Michal Hocko wrote:
> >>> On Wed 31-07-19 16:21:46, David Hildenbrand wrote:
> >>> [...]
> >>>>> Thinking about it some more, I believe that we can reasonably provide
> >>>>> both APIs controlable by a command line parameter for backwards
> >>>>> compatibility. It is the hotplug code to control sysfs APIs.  E.g.
> >>>>> create one sysfs entry per add_memory_resource for the new semantic.
> >>>>
> >>>> Yeah, but the real question is: who needs it. I can only think about
> >>>> some DIMM scenarios (some, not all). I would be interested in more use
> >>>> cases. Of course, to provide and maintain two APIs we need a good reason.
> >>>
> >>> Well, my 3TB machine that has 7 movable nodes could really go with less
> >>> than
> >>> $ find /sys/devices/system/memory -name "memory*" | wc -l
> >>> 1729>
> >>
> >> The question is if it would be sufficient to increase the memory block
> >> size even further for these kinds of systems (e.g., via a boot parameter
> >> - I think we have that on uv systems) instead of having blocks of
> >> different sizes. Say, 128GB blocks because you're not going to hotplug
> >> 128MB DIMMs into such a system - at least that's my guess ;)
> > 
> > The system has
> > [    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x10000000000-0x17fffffffff]
> > [    0.000000] ACPI: SRAT: Node 2 PXM 2 [mem 0x80000000000-0x87fffffffff]
> > [    0.000000] ACPI: SRAT: Node 3 PXM 3 [mem 0x90000000000-0x97fffffffff]
> > [    0.000000] ACPI: SRAT: Node 4 PXM 4 [mem 0x100000000000-0x107fffffffff]
> > [    0.000000] ACPI: SRAT: Node 5 PXM 5 [mem 0x110000000000-0x117fffffffff]
> > [    0.000000] ACPI: SRAT: Node 6 PXM 6 [mem 0x180000000000-0x183fffffffff]
> > [    0.000000] ACPI: SRAT: Node 7 PXM 7 [mem 0x190000000000-0x191fffffffff]
> > 
> > hotplugable memory. I would love to have those 7 memory blocks to work
> > with. Any smaller grained split is just not helping as the platform will
> > not be able to hotremove it anyway.
> > 
> 
> So the smallest granularity in your system is indeed 128GB (btw, nice
> system, I wish I had something like that), the biggest one 512GB.
> 
> Using a memory block size of 128GB would imply on a 3TB system 24 memory
> blocks - which is tolerable IMHO. Especially, performance-wise there
> shouldn't be a real difference to 7 blocks. Hotunplug triggered via ACPI
> will take care of offlining the right DIMMs.

The problem with a fixed size memblock is that you might not know how
much memory you will have until much later after the boot. For example,
it should be quite reasonable to expect that this particular machine
would boot with node 0 only and have additional boards with memory added
during runtime. How big the memblock should be then? And I believe that
the virtualization usecase is similar in that regards. You get memory on
demand.
 
> Of course, 7 blocks would be nicer, but as discussed, not possible with
> the current ABI.

As I've said, if we want to move forward we have to change the API we
have right now. With backward compatible option of course.

-- 
Michal Hocko
SUSE Labs

