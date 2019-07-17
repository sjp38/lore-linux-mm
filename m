Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52803C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:39:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2B9C21743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:39:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2B9C21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 514D56B0005; Wed, 17 Jul 2019 03:39:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C5026B0008; Wed, 17 Jul 2019 03:39:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B4368E0001; Wed, 17 Jul 2019 03:39:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD8926B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 03:39:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so17463741eds.14
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:39:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6QszZE0XvjntTJ134Z4d4YLDD1JPaC0EPAQ3GCn2UaM=;
        b=LGhnZCjaZjPNXffcbr76dSKBuGSKyXD0sYX0fbS19jHfHmOv+/TtpCcVEkvEPgEzuK
         WeBjAR8W13QIwz8CgVX3d/PETyUJdSjIHBnp0G+75wPi8wk4VrrNP/Nuh7IDQAryNuSX
         s/Kc9EVhsR9gQzRnF03yIUlY6/Yvn68bgxL8v7daxjvIP+GQtrUYEdEdjbPaEpzS8E/u
         VwAIz9oPZisfFvFTF9kPXhQkxZyAefOnsB16DYZzePrwoNVXF1+1KIRVwWTwV7bO4vwk
         wlxPNj9m9TKTWj8PSVbNPJ2MwaqyVDjn0/l9bhske4WXVDTFvBzJEHWkz/MSjHH9AQui
         nTTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVVnkXwWKLOGurPVXrtYDqpoa4J+6shkMl2UShGt/X5CsNyvuXr
	fPD8P0LCtvzopognyaOHJWKhsESQWu688vTwMILc7goJRavAWNAuM65hkyfuXVBBVVhP7yDgmSv
	wdFDsk3s4P+jx+GfDiE1H5dZxqCvQB6CVATNDh4NxrEdMabHApjoqmt/b6IPJe+9/3Q==
X-Received: by 2002:a17:907:20db:: with SMTP id qq27mr29459928ejb.30.1563349142474;
        Wed, 17 Jul 2019 00:39:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCbQwYDbNmVjwyWC+ib5+HNOxjmOOk9O/U4MDEm0ua0kmRKq1qxhYlAhR4SyJRqfekArzG
X-Received: by 2002:a17:907:20db:: with SMTP id qq27mr29459870ejb.30.1563349141511;
        Wed, 17 Jul 2019 00:39:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563349141; cv=none;
        d=google.com; s=arc-20160816;
        b=ymg7VH7sgnoD4xzurpWn7v/WfEdORjGEytO9iuuI97XOd2dgEoTjmYwDYxajJpW3a0
         FZ/t4lsu+8HBZxogkexEa8Bw+CxRJfV2Q+Vp2+71Vr5ThYbB0T5FtOKYoJQVMNl6gT7O
         Z7k7FfehLRMIuVS7Pqcyjj5+zp+ZVz7sPxurjFh1jED2OY18wG8HSZ51Nr32JxjuIDiw
         xQjHxXnQd7EFmX0HV88vySRAZvw0PAyAwAyE5sZ9rErkAAuH9io3A45uIMDGr7sKwD3q
         CBtjXNPB4pDISxW+Jq+PH2I53azt6loyJ+ixs583k+tiDxy+RLG+VAQfSghv/i8q+QR7
         8PwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6QszZE0XvjntTJ134Z4d4YLDD1JPaC0EPAQ3GCn2UaM=;
        b=hFPXI8iwZKQZIbSrrEyb6n6hZRs/WfwKnq73jkSziKhvYS7mX1zyztJt9nf5d1e3qY
         ztKIW05B8QfZwQcpYVnxQPxYUVsTSX47WEGNco14LtF9b5AjmIQo+/VsHv6ZMnBZXPwq
         wzshwEVkCoQSD+PJJTgb6PPiQGbpD4XHWwoOv18wc3WqlC09Vjp5IN73s8h405/9C0tx
         dwTpDoh4wxuSQX2aPwYoH0H+6sN+bu36obNRUGFrAIsPBahU4rvPHClwMS17KUGBcToZ
         u9rsuFXlHWQ3o7BwCVUGV+x3+yupa5jBKn9teVNcf3iniRR99tXoZ8DkkxKMcZysddd5
         yaXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si14255368ede.18.2019.07.17.00.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 00:39:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D197EADBF;
	Wed, 17 Jul 2019 07:39:00 +0000 (UTC)
Date: Wed, 17 Jul 2019 09:38:58 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Hildenbrand <david@redhat.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
Message-ID: <20190717073853.GA22253@linux>
References: <20190715081549.32577-1-osalvador@suse.de>
 <20190715081549.32577-3-osalvador@suse.de>
 <87tvbne0rd.fsf@linux.ibm.com>
 <1563225851.3143.24.camel@suse.de>
 <CAPcyv4gp18-CRADqrqAbR0SnjKBoPaTyL_oaEyyNPJOeLybayg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gp18-CRADqrqAbR0SnjKBoPaTyL_oaEyyNPJOeLybayg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 07:28:54PM -0700, Dan Williams wrote:
> This makes it more clear that the problem is with the "start_pfn ==
> pfn" check relative to subsections, but it does not clarify why it
> needs to clear pfn_valid() before calling shrink_zone_span().
> Sections were not invalidated prior to shrink_zone_span() in the
> pre-subsection implementation and it seems all we need is to keep the
> same semantic. I.e. skip the range that is currently being removed:

Yes, as I said in my reply to Aneesh, that is the other way I thought
when fixing it.
The reason I went this way is because it seemed more reasonable and
natural to me that pfn_valid() would just return the next active
sub-section.

I just though that we could leverage the fact that we can deactivate
a sub-section before scanning for the next one.

On a second thought, the changes do not outweight the case, being the first
fix enough and less intrusive, so I will send a v2 with that instead.


-- 
Oscar Salvador
SUSE L3

