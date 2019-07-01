Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24839C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:36:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5B26206E0
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:36:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5B26206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89CAF6B0003; Mon,  1 Jul 2019 05:36:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8741E8E0003; Mon,  1 Jul 2019 05:36:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73CA48E0002; Mon,  1 Jul 2019 05:36:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8536B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 05:36:50 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id f19so16410952edv.16
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 02:36:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=12nYwyiXilJzBxToKzNLEmj5rK6MLil18sZLss9HaFQ=;
        b=aOdoq/GaCjNnLgdMXODNI+94TALLS7QHYv4FPnJOfhQBcGaBPOwHNd3xXTo3GBQULp
         ouDuq/ix/ubY30bClVcArQJx0JBPLP0rGPjAYpjP04SN72WALx7TWdWBt0JaTSONzk7h
         +N0CUEA1xOlCRFqC8esRfEZ4budeCEsO1f1fAh7m+nK2Y096f2e70pX12WI1RZm0HfuT
         h1qjPV7hNyuxe47zecvcUP1vVRnxDKxgtgjUC5JaVZhr4+mbD2v0hM+VzJFFafIVuDWz
         C0ngOAp8Vs4V3EGleAKE04q/GuLI3U7vLz2Bzuqd14p6P45rfllz1WcamBagbMc+eRVX
         VCng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUi29ZCCshSL2dtcAYv8exDOIuvJRBiW3pSHOL13gPocl021ngN
	x+eArf+UHLhJcbHNv1K8nu54AU3PMfqhHL2/W5Mr41FIpOxUiJXkOUWbkP/LAhyp5W+qodc/bFo
	TJK93uWPvsABSOYNOwQsrhdUbScvUuZSrikvIj9Z/7VtuhoOKTwTqISkzYePOmdnj1Q==
X-Received: by 2002:a50:9871:: with SMTP id h46mr27768360edb.69.1561973809851;
        Mon, 01 Jul 2019 02:36:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTkFxK8xj/twhudSivVgfoGESvBn3TlqG8gfVWrMmrDVu6cn1TES2OjTZNnqopmU9HGB3o
X-Received: by 2002:a50:9871:: with SMTP id h46mr27768308edb.69.1561973809183;
        Mon, 01 Jul 2019 02:36:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561973809; cv=none;
        d=google.com; s=arc-20160816;
        b=Hj/j5FTRkztIRYQKOmjJnkHWJmvQiwVDKE64qRKR+ijtn9UfWbgiXcJxJW857+XlNF
         2rrYsaFIpA/JoU+UYjnr4icYGtiIbMjPkKFqMeqots8GHwOTujOQ5kdBt4QOGNo3R1i5
         iCtnY4rql73dRoCPoLvA0C8FHXgJhjTaXxOYnPrZcdZR/sEoMOf55/7z8vtMz1LaIuxd
         Bo8i9xz8ZjD5EV0wabUEWygvGbDy2lOte4fqc0rUHZxfo83EJKXrbk4u7NEByQzfvTER
         BSPChVk6DXGfYr1dUoJDyNeDr3CmmAwMhTwOzeQWzfc453cjekXirz+ji/AKNGsMoc5c
         EnWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=12nYwyiXilJzBxToKzNLEmj5rK6MLil18sZLss9HaFQ=;
        b=wQmZhukY9WZaL2NTK3vxbLptZQWhcDr5yxBInoZi0TUNH1JCt5Ed5QJUb8BXDpVZ0X
         rjBPofIHlSCEnAkxi68GaasakNdwFRw2DBPetr2bdDzhktPLHIiTivCtrhiWUiy1U3+y
         B5XW5YAxC/UOUuyfPF9ekTwtLVH5uT3kCGgAoGB0aj21lGd10M7HS3xST1Vn/WI35Q5R
         YpxGl/JBZ05kL60f8KJ8yX0Xgp7WjeKWZYo22bHKMWDcdnWCs08molG0YHnQl220D2Df
         9t+orjyVXZiC7hdCJePkOjxuRbs6lYzUhZ1NBcmRW9ZPT7YuwT8BIkSRBrCGFL0f0srG
         7F8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si7062199ejg.75.2019.07.01.02.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 02:36:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6E628AB87;
	Mon,  1 Jul 2019 09:36:48 +0000 (UTC)
Date: Mon, 1 Jul 2019 11:36:44 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
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
Message-ID: <20190701093640.GA17349@linux>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-11-david@redhat.com>
 <20190701085144.GJ6376@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701085144.GJ6376@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 10:51:44AM +0200, Michal Hocko wrote:
> Yeah, we do not allow to offline multi zone (node) ranges so the current
> code seems to be over engineered.
> 
> Anyway, I am wondering why do we have to strictly check for already
> removed nodes links. Is the sysfs code going to complain we we try to
> remove again?

No, sysfs will silently "fail" if the symlink has already been removed.
At least that is what I saw last time I played with it.

I guess the question is what if sysfs handling changes in the future
and starts dropping warnings when trying to remove a symlink is not there.
Maybe that is unlikely to happen?

-- 
Oscar Salvador
SUSE L3

