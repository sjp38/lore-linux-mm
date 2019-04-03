Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7EA9C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:01:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E4D920830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:01:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E4D920830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15D7E6B000C; Wed,  3 Apr 2019 04:01:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10DCE6B000D; Wed,  3 Apr 2019 04:01:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3EE26B000E; Wed,  3 Apr 2019 04:01:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A90746B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:01:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w3so526992edt.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:01:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PF3P91SeHF5fFIUP7PUJxZ+8K2vcCKbCZKe5tN1PM7s=;
        b=Ggo26s5Ieo/sP2NkNLWXysOAGDdbSo6mMfF/RDVclRLA7dCSNkKZQ2l23VlU2kqBQY
         zah5TeMRCY+28i0zU8kLq6ueqWHd/uGxN6RTHR5XFrN6STgzCW7K9W+Iidwh/TMtzcec
         ybSF3vsUddW1iSD9kgKBd49pUODevXIYzYN0sPuMakDzku8GkbzUS6FJBhrZ50glONGR
         4hs2F+CeypwKLGWfUCy4flMYcoc9KAGhnwrO1FrMttnFqPMvEweElA3ABjunFVT8NcXJ
         F4IwAZvdgb7Siqhec8grXhfT4D7LghFHbHaESXplXLnJi/Y7kgBlFDKy5K2v2jOjbE5y
         db8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUZdod+m0U/7v9H9wBtZu8Hb0groUwsqvJeapD0aM9J8UUN12gl
	+/YV9KavqvbkeC/g59memXTfgAvBQnnhsGP91JLQgnd1GoZu8OhmpqXVKb6sLmeocPdXjozBbkD
	zXmMwKwfxkUhHU18F44FyTZUtr+MUk0NPXrTeh3ZJe32IRE5MJOAgQbQhNIUJMdX1ag==
X-Received: by 2002:a17:906:e202:: with SMTP id gf2mr19826144ejb.55.1554278478244;
        Wed, 03 Apr 2019 01:01:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCCypRUDqVdpv7vJ7RqVI/ONMsQNp6BMzJgygnJxb4vied2NS5OjinE2VtnHZS6yw1i6vl
X-Received: by 2002:a17:906:e202:: with SMTP id gf2mr19826105ejb.55.1554278477468;
        Wed, 03 Apr 2019 01:01:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554278477; cv=none;
        d=google.com; s=arc-20160816;
        b=fcIMwhovQNUxBEf5+7qOoJZVeB29UXDN2fE0AKRqnmEYQE2BwP3iayFb4Rdv7678TV
         l2LQ3tz3e679JWsaKMuIB2f3/EhaEH5ommefmjC9+g9tdW/lPPmQQbR8bfxkdJtNhq/y
         MTVnTCWZzj2xXLX4mlvBW9rJu2qFOcPNRyU0TRddH0l5vZ/qbLh7pEyXPSYtJoU5niyR
         DhGhhvYkqt9qSavlHHOcolQ907ubWifghPM49b8ZgkiTQsrCqB53l3fKwe+JlCCqW6DX
         qjr8JfMSBffLJUrprCNOmxO0qUYtILBIqIIXJeE4ZNKcHFZFVgQSbRd0t38SYz9CI5yI
         wjjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PF3P91SeHF5fFIUP7PUJxZ+8K2vcCKbCZKe5tN1PM7s=;
        b=iUSGB3xR7s3A+DGCx2R1dlJgidxGQecmXxgGv4igBOiZjJ6Ysa1oeQcUKLf0pSPGgJ
         eIu895o156ocvLooa1vZ0ftJe+3InM2/sO8okUEqobD+CX0YQyT11URfAv2jcmzu781P
         2pGnra07E+eWtIDu9ETfac1QQz3QJh0mmxf8AJRXlOysnbpf+lJhr0DTWz5JRLRSds5a
         ls1TaIGoiFPP2sAXzcHawpKNDDh1Lh0p43kXfweQTzbzNovSb8GiZuAmmA9Zzp91yt/D
         scOtDTmDAZJpQzlyGkP0a7VQEswNPnr0n5ZKwLkniT9FK+2QnYixlbBIP5YdLbKr6kTj
         mEuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id b47si124521ede.153.2019.04.03.01.01.17
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 01:01:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id A8CEC47E0; Wed,  3 Apr 2019 10:01:16 +0200 (CEST)
Date: Wed, 3 Apr 2019 10:01:16 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402124845.GD28293@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 02:48:45PM +0200, Michal Hocko wrote:
> So what is going to happen when you hotadd two memblocks. The first one
> holds memmaps and then you want to hotremove (not just offline) it?

If you hot-add two memblocks, this means that either:

a) you hot-add a 256MB-memory-device (128MB per memblock)
b) you hot-add two 128MB-memory-device

Either way, hot-removing only works for memory-device as a whole, so
there is no problem.

Vmemmaps are created per hot-added operations, this means that
vmemmaps will be created for the hot-added range.
And since hot-add/hot-remove operations works with the same granularity,
there is no problem.

E.g:

# (qemu) object_add memory-backend-ram,id=ram0,size=128M
# (qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1

# (qemu) object_add memory-backend-ram,id=ram1,size=512M
# (qemu) device_add pc-dimm,id=dimm1,memdev=ram1,node=1

# (qemu) object_add memory-backend-ram,id=ram2,size=1G
# (qemu) device_add pc-dimm,id=dimm2,memdev=ram2,node=1

These are three hot-add operations.
Each hot-add operation will create use vmemmaps to hold the memmap for
its hot-added sections.

-- 
Oscar Salvador
SUSE L3

