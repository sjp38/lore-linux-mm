Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E40A8C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF71C206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:44:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF71C206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 369418E000C; Wed, 31 Jul 2019 08:44:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 319678E0001; Wed, 31 Jul 2019 08:44:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22FA48E000C; Wed, 31 Jul 2019 08:44:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CADE68E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:44:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so42294061edr.13
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:44:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FxdoRcmJazCquQoAmMGXusTLTFMDHLUfIQitf8aA/6I=;
        b=p6pJBVMzsC91tINF/YX0GQsC4vr032Hwp1in6NPY9D5lkhEIlc36UNKhAAb1iY4nwa
         e8EUwcfqXYhc+0iEBJ1A3tW3upOHc1zFQ+GLJTv7pHb483PHOg3A7PNVoAs0qB8jngRv
         Ly7GhACcgV/0Z+ATT7BIO0tAejemahciaXapKMWqpEjiNU9mYSdJ78xgq/TbPS2/RMKH
         4QbHxh6f//gHEwiiECuji9Ac8sJT/BUG364FWmD0Df7XYdUjz1VYMrjdNyIekx1wBvHl
         yJFTEDtDOOBB+afE/XdyXhsuZqS/RkLJkPYoRqAYVIg9fxQzpRSjuV8tQI88xNFQ9+S5
         g0TQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWlZXwN6JTCOeOhJRUhjNtDEVpR6CuNV0CMgKWuIillKqfFaTZl
	B4VojHtsVxcMu+Dw8ioJL/cP6DegV8/50b5hiCRKpDzi6gC8sGA+zcsoy9y2R/2WdZGRzrorLbS
	Ky42cL8HsZqF7POLjbt+QeE4FuNHScECCUdSiCt75+g+miQdMZ5HQrmH1z+135iY=
X-Received: by 2002:a50:9422:: with SMTP id p31mr106349190eda.127.1564577043357;
        Wed, 31 Jul 2019 05:44:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp7WxKeREnyDr2605l0YyxtpjupL6PEf7CduP4wODZq7nQPrnPfW1Eb9GJfKnSxrfgAQvZ
X-Received: by 2002:a50:9422:: with SMTP id p31mr106349150eda.127.1564577042748;
        Wed, 31 Jul 2019 05:44:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564577042; cv=none;
        d=google.com; s=arc-20160816;
        b=q2GRra6WiNF88m+WXtoQg+Xgre5VL1VExS8Q1zlKljxAyAJ+zoiOEhcwNA4nm3Hhpj
         ojCdegB9Oz+95A+55jfw/gNDV4JrbFy5tVVsM6TbOENznLHf9uv/JSGWfbYpuAcEV0/f
         rZjT0I+SQT43QcR9IweagopcwGp0gq+T56nWpDWUu36LWP9hCILXysbAUEBAmBJEZ4WE
         tQRxu52RHbAH6c3V05P/f06UFzgqB1fsf1DmpSXt76fTlUgYsvmtCpYihucdqJb6qEdh
         uqBs2sE20rnjzAGMbjt3qZRSb0bjb3CM3VxDq1I8aVvvaDtCjyD15ov3pEN6eSUFMqL1
         gp0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FxdoRcmJazCquQoAmMGXusTLTFMDHLUfIQitf8aA/6I=;
        b=ajSgIbxtwFT8CO9eCBqPq47mQOK499RgwNRdLMxHHdlnbG4lrnQGNGvlPR9vEGq17y
         s27mNtVCo5V4Iz7yU+mRQjxTmvNOgPBem49wQkVJMGQH00PNB7Aj2LWU+DaqD7c8Uvkl
         VvF91K6VBruVongzliIo4SubgAUgLVew38AIhUwrv6kGIUbJ+fdSXhGurTrsbui6RiCl
         gKolTSdtIg3GKXGo1cBzD7IQuSS9RFpgWUE3RH0cFYcnif3tPGST9S462JazhamHJia9
         oCyYrEo3kFS1u4b1scBGaA3vu8Lm/OvcdTvkj5Ig7Se1RJ+Cz1PlCUdIs/K8kchK3ptC
         KdbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g7si19632093eda.302.2019.07.31.05.44.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 05:44:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EC03AAFA4;
	Wed, 31 Jul 2019 12:44:01 +0000 (UTC)
Date: Wed, 31 Jul 2019 14:43:56 +0200
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
Message-ID: <20190731124356.GL9330@dhcp22.suse.cz>
References: <20190731122213.13392-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731122213.13392-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 14:22:13, David Hildenbrand wrote:
> Each memory block spans the same amount of sections/pages/bytes. The size
> is determined before the first memory block is created. No need to store
> what we can easily calculate - and the calculations even look simpler now.

While this cleanup helps a bit, I am not sure this is really worth
bothering. I guess we can agree when I say that the memblock interface
is suboptimal (to put it mildly).  Shouldn't we strive for making it
a real hotplug API in the future? What do I mean by that? Why should
be any memblock fixed in size? Shouldn't we have use hotplugable units
instead (aka pfn range that userspace can work with sensibly)? Do we
know of any existing userspace that would depend on the current single
section res. 2GB sized memblocks?

All that being said, I do not oppose to the patch but can we start
thinking about the underlying memblock limitations rather than micro
cleanups?
-- 
Michal Hocko
SUSE Labs

