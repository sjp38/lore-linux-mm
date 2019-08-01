Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E78FC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5968216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:13:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5968216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FFDC8E0005; Thu,  1 Aug 2019 02:13:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38A538E0001; Thu,  1 Aug 2019 02:13:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 251888E0005; Thu,  1 Aug 2019 02:13:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC79C8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:13:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so44041137edv.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:13:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nQVQLnFtuhszbst8dCungDh4V9gpb9+crDfPE+xj66o=;
        b=CHKzFwXXHxWw7Pp+7xnSPyhMYDSdf6lC9gj5g8TP81wKtD3wTBrtpQIeKewWF6AHVN
         n2CtCLX6s0DIDgoDYokj5Tv/hT3wr/4oFbA3VwNFick6VX9N0wyYakhcEpTPO5kqGEi3
         +f8ne3qQ3wFUJDNbHpPPzifnZVIPwvR3zgZEkiFkIxTwAD2dojvOSj2aALsyr/UrSALo
         Wp3kU9DLRvcXCLOknsKkPT8nY9x9aXBGIlGR+7h0wr3IaSgWrXxl3mAQyYmzy2r2A+sQ
         ZoyF2/fXUSftAGIdfeTRv39DiDJI3nKisRNXc8pBdvxszJXyBhFN5O8qpldzTSgGUqJs
         y/9w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWhE0Q3R6hAkHeg7Ns5JHcZcScc2GYzTR085GPokStH+ZZZ13iF
	DUt3PGAD8yQjdmZK9UyoaIyRJM9FMsR478xKq/9CC638jC4TKJleAvsWq+7Og9YiVuEYJCSNxzj
	LLPWX0c9rumR3QalU2dgRPZ3IjdPHCBVfSv+Wg4xpz0fD7krGMv2uS0aCz5yWnLM=
X-Received: by 2002:aa7:d845:: with SMTP id f5mr110987479eds.78.1564640028408;
        Wed, 31 Jul 2019 23:13:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyulZT72aYtlaJaIEdZVkka3bamKwTSgCU8CBVh8y3d+rAYOMXkRxNiUfgRA9qRsBJclH9J
X-Received: by 2002:aa7:d845:: with SMTP id f5mr110987436eds.78.1564640027670;
        Wed, 31 Jul 2019 23:13:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564640027; cv=none;
        d=google.com; s=arc-20160816;
        b=Lu9sh3w4kYPIcsAspxKqj3llaX7+IEGxllQ0iTc7a3AaHtVmAuXZ3MTmHslhXSED2Z
         F+ib/mngsdfVu+3I62+Q3T6NkxO3okRWMYu2Q+kPIa0wlivaHKr2cztp5ztCnya4s/To
         Id0I6nF1qGy+JexPc5OTMIhMyNDu9YB1flb6Mi15kaXOQK5DUjMrKjOm/vwnSlG58++F
         aftVh+8QvkOfi2Oib/bjEMb94NqyGWyc0DhgSI4fobZ1e9pe67+xoEXS+zH+M7CuCDC8
         ZJ9w1PTBNV83UguvL+JWfwFjp7+73sg/ZCN68RcXQX+QITQgNO5TqX/CygtfH331DnxD
         MQcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nQVQLnFtuhszbst8dCungDh4V9gpb9+crDfPE+xj66o=;
        b=DO/kyyOtcCIre1zuC2OjALKO+JW4g+YXZzA0NTlZz80a/iCNqijGAtzpXWfRqTVNO8
         UboBQCEO9QsHKvQsILEkcTqRoTNzaNJBpQua1Khq3rf1/wwQmu/NAtVQrW2dRJ7dfTKz
         fIpIYcHWNrZtZYy1SqbPQPqDqcF+8yCa4hVGeWzypcR/GotSI66fvH0aETF8PddS/CUo
         d/dS50ub5dmFMN0NjSep+yTyHjbIceENB12v1DB1NlrPAnUCUIRl2j7rutxOHH3Z+otI
         TgYnAo/3eurUTAJMMixfeffydpYry1+/+k03/YYMwmB0vYGg/KYf6xXWgXVuOm3HRoJi
         8CLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k51si23364534eda.111.2019.07.31.23.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 23:13:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C65CCACEF;
	Thu,  1 Aug 2019 06:13:46 +0000 (UTC)
Date: Thu, 1 Aug 2019 08:13:44 +0200
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
Message-ID: <20190801061344.GA11627@dhcp22.suse.cz>
References: <20190731122213.13392-1-david@redhat.com>
 <20190731124356.GL9330@dhcp22.suse.cz>
 <f0894c30-105a-2241-a505-7436bc15b864@redhat.com>
 <20190731132534.GQ9330@dhcp22.suse.cz>
 <58bd9479-051b-a13b-b6d0-c93aac2ed1b3@redhat.com>
 <20190731141411.GU9330@dhcp22.suse.cz>
 <c92a4d6f-b0f2-e080-5157-b90ab61a8c49@redhat.com>
 <20190731143714.GX9330@dhcp22.suse.cz>
 <d9db33a5-ca83-13bd-5fcb-5f7d5b3c1bfb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9db33a5-ca83-13bd-5fcb-5f7d5b3c1bfb@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 16:43:58, David Hildenbrand wrote:
> On 31.07.19 16:37, Michal Hocko wrote:
> > On Wed 31-07-19 16:21:46, David Hildenbrand wrote:
> > [...]
> >>> Thinking about it some more, I believe that we can reasonably provide
> >>> both APIs controlable by a command line parameter for backwards
> >>> compatibility. It is the hotplug code to control sysfs APIs.  E.g.
> >>> create one sysfs entry per add_memory_resource for the new semantic.
> >>
> >> Yeah, but the real question is: who needs it. I can only think about
> >> some DIMM scenarios (some, not all). I would be interested in more use
> >> cases. Of course, to provide and maintain two APIs we need a good reason.
> > 
> > Well, my 3TB machine that has 7 movable nodes could really go with less
> > than
> > $ find /sys/devices/system/memory -name "memory*" | wc -l
> > 1729>
> 
> The question is if it would be sufficient to increase the memory block
> size even further for these kinds of systems (e.g., via a boot parameter
> - I think we have that on uv systems) instead of having blocks of
> different sizes. Say, 128GB blocks because you're not going to hotplug
> 128MB DIMMs into such a system - at least that's my guess ;)

The system has
[    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x10000000000-0x17fffffffff]
[    0.000000] ACPI: SRAT: Node 2 PXM 2 [mem 0x80000000000-0x87fffffffff]
[    0.000000] ACPI: SRAT: Node 3 PXM 3 [mem 0x90000000000-0x97fffffffff]
[    0.000000] ACPI: SRAT: Node 4 PXM 4 [mem 0x100000000000-0x107fffffffff]
[    0.000000] ACPI: SRAT: Node 5 PXM 5 [mem 0x110000000000-0x117fffffffff]
[    0.000000] ACPI: SRAT: Node 6 PXM 6 [mem 0x180000000000-0x183fffffffff]
[    0.000000] ACPI: SRAT: Node 7 PXM 7 [mem 0x190000000000-0x191fffffffff]

hotplugable memory. I would love to have those 7 memory blocks to work
with. Any smaller grained split is just not helping as the platform will
not be able to hotremove it anyway.
-- 
Michal Hocko
SUSE Labs

