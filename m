Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23550C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:56:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E829220859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:56:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E829220859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7614F6B026E; Mon, 10 Jun 2019 12:56:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F1C56B026F; Mon, 10 Jun 2019 12:56:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BAA76B0270; Mon, 10 Jun 2019 12:56:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB816B026E
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:56:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b21so14068957edt.18
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:56:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=27DyH3572KYaCQjl7H5c30a3hzo1PYGb+N/uPJdnDqU=;
        b=qhvdQ7A2H4TBh97uHfxAu8ckzGjjaW0/E+4MEbZA+sNq2yiOtR1D2K84Wxdefy04xB
         rX4FG2uEpQJURqBj5to1FD+cG43FDvJDJ4oEYLmRBvEVBhAkb0W4dsNbb/Cz7jHdYcuA
         mh18xPCDjRUTKK9eQ6IlB+nNS5IPWagVjWQ5xc/r1zmPNy+wJsekfg0JEoEOndFbIIdd
         g19bhn9iOpy81f8eu2ohga3qfKqmK+C3cKXFV8XvCjYzc/mhmyveMMnLr35pSk8ui32X
         Ylg1wS8/+Xa0N+X1Hgj5DtOHWyRjEDv73yglODDKW8M0gw8d2sYC2/SLEvWFU4PmLacU
         eVhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXmm4ssCRY+8AbJp/lH+QHUxOC47aea8HiW88UwSnBrz/GPd/HG
	/r31LTfOBBxywgVyaLK5o5tsTvlmBeantCLqPnvNaCHfEGYjFH+9LMB1CNiOcLLWwnp/uMLkiQ8
	CuXxmNA917u5xtAUKprJVsxS5Y44Fj3au2LQ5eaOglyi7dY/y/rt3nh20LjjIVTY3aA==
X-Received: by 2002:a50:ade3:: with SMTP id b32mr75610733edd.297.1560185808635;
        Mon, 10 Jun 2019 09:56:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBGNHt1r9rDTw3jGbQTw4sN2w1gasND7eTS7Qd+cDVyMyJFQ9RPz3+PtSdJ4kW61PZdWvN
X-Received: by 2002:a50:ade3:: with SMTP id b32mr75610684edd.297.1560185807949;
        Mon, 10 Jun 2019 09:56:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560185807; cv=none;
        d=google.com; s=arc-20160816;
        b=gcQiKMDRXHhJcyg1FmgPtdISlMRPraixbxiMm2hHzRy/MHy2RbrrHXJwQkZl69vM2k
         YRB7hwbzP8rkP2+H5zHu38FnVuXtRux59p0OW6GuSPApcifecNUo4XwO+e6XhJiZIx9d
         KIQyivnC5YvO3oNirOTEMAYuYmyZmr/RtbKwRMSdABmt9k1nglsTIQ6xIWpU/v0MSK/7
         tAAeVNsatHm9K8YAKK5eijU0dmkM2qMPEZ+JAFZ2BDt8hrJCcV1vS7GjABrvjw8OGJx9
         MHPpCzoTccYEGVFNUSAAonbNhW3bMuLoSKMkS3Q7Hqf8rdgiFXFYgzsGudD9bHGyfKgU
         biPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=27DyH3572KYaCQjl7H5c30a3hzo1PYGb+N/uPJdnDqU=;
        b=a4ls+apQGzRXEt31gKB2jmOdpkxcUX2Zqmcw8hUNXjElPBVLRwLWa6R8YtrSQb0Og/
         +MG8yF0f8dUWw1zeaKXTGmdEXMHG3ObcZGcr1CgD1j6vXHHn3DrR5Xr+JHG9LNN/yyzG
         B2eqQYLl6RIECDSjZmFi+z2Au6JqQjFSJ8Ok30nn/qtGa1uIIWleUowKqUP5WaZLipmF
         +2nxLtv+jRT3uXFpfgLlyRHg98D3dYBF4RMVhzM/+Wtn4kXBDcTtqMcsINvnXpp+QOfs
         fq4WD/iBm7EbSqxNkDnVr6q0H2vWWn2qg7SJ9MLHY94mhuz3J1OQ8pgoYTVm3QZQwBpZ
         UDVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r41si8011915edd.328.2019.06.10.09.56.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 09:56:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C303FAC3A;
	Mon, 10 Jun 2019 16:56:46 +0000 (UTC)
Date: Mon, 10 Jun 2019 18:56:43 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: Re: [PATCH v3 10/11] mm/memory_hotplug: Make
 unregister_memory_block_under_nodes() never fail
Message-ID: <20190610165642.GB5643@linux>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-11-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-11-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:51PM +0200, David Hildenbrand wrote:
> We really don't want anything during memory hotunplug to fail.
> We always pass a valid memory block device, that check can go. Avoid
> allocating memory and eventually failing. As we are always called under
> lock, we can use a static piece of memory. This avoids having to put
> the structure onto the stack, having to guess about the stack size
> of callers.
> 
> Patch inspired by a patch from Oscar Salvador.
> 
> In the future, there might be no need to iterate over nodes at all.
> mem->nid should tell us exactly what to remove. Memory block devices
> with mixed nodes (added during boot) should properly fenced off and never
> removed.
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

