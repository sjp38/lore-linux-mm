Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 805A0C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:56:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F3512089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:56:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F3512089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFFFE6B0269; Fri,  7 Jun 2019 04:56:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB1336B026A; Fri,  7 Jun 2019 04:56:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C79E06B026B; Fri,  7 Jun 2019 04:56:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7526B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 04:56:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c13so2134674edx.16
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 01:56:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=0v9HsiHh93IM1pVklIufn9k/hFTDIbu7kcYAPOOtNvc=;
        b=QaBW09kTn6v0KXMVeRjYSvxPCMEPUaNq3+nCEMQ0U6dlLXPPzDkr7leTFWiHtJMNjN
         D91X2m+apEE0A7YdeUv8fIT/k9PvKk88G6xUZBSeKwzz7q3mz/hhiEZgMctf+LQYxhoe
         /CPfwq8M8HtFywIga5lBnJNxStgBSRuInse44jmtxbadtlYgiVbB4d+4lqlW1iNRnR5l
         Tjq7BV0FtcvugTmoGADXZsnRK87V8sHkN8bl47kN3LDSXs1fJBFZ9a+fJiXGdr1As0Eo
         Si5PNSQxHwg5GFy8PvY82LQlMFcLxYjwzJGawKEirPE+aanjsN75hbwI9ylVWG3PcB2F
         E/oA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWkx04mRK93a4MZLDQWIbpyhoOZQ8w9buJ0rxGzX4swFu3jIgCM
	r+RGCv0Oit1uvUYe0qo4dOe+ehIbKsPGY2rsrAiSAo1RkQsi3QJV/+4HkNNrs1anhf8+A0kREMT
	SIvmhcTNsBxAsFLmJoxwX2rAICiVawMZ+vXgW30OrTLqnvUOgMyo5iOjsKovgZDq9cw==
X-Received: by 2002:a17:906:3452:: with SMTP id d18mr26279526ejb.24.1559897789146;
        Fri, 07 Jun 2019 01:56:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxA62PNEp3k6q4QTJa3XZRy4jcdLsiGaaBPYF02p97pVwJDtit33i/ZOhUtXNvI0YdPyNOI
X-Received: by 2002:a17:906:3452:: with SMTP id d18mr26279481ejb.24.1559897788246;
        Fri, 07 Jun 2019 01:56:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559897788; cv=none;
        d=google.com; s=arc-20160816;
        b=LEpEkT1p5kYWAFSPgGwgvEua1O9EJkvYOqiYA+YzWYEA+Zuo2CtWalssUIOc4ySI3Z
         G7l2t9+ybiIbtzTOa2HhiZpt55no2at47H/7kkwokRB9zrLLObf/4yTpJFQ4qBG6CMXK
         LqdxVfCiIcS+ciTAEk80BKP0rDvNeogjv6Yso1RanKExO8XB0kUPYFKRTRqcco6lmNjr
         FOjntoFo+DvyF14LV4+0vu3xYWyhdJMdsYaYgHGpnTK1cZoEZvcjDSns6GN1+lV50Pi8
         XPYxl/Gh8sjoDDu/xBHkAHuOOZfUgdT213SsMWtYWybej9v8vFMuBTsBbZVnlgkwN70j
         rzDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=0v9HsiHh93IM1pVklIufn9k/hFTDIbu7kcYAPOOtNvc=;
        b=DCiK88NwocN8ji2Kqc0bPydBhn1taHl4dNlr/SSm9FWD27rYPurVF2Q2VQh/j0ha2A
         c1BH6L+cKgaDZRlmuWvw+44Kc9BM/tX4optjT5lsLW6uvP/dBmt8b0igAIGWSZ83pox3
         Z3C3S0lpT4CM1fmxKtmHX/BotIdj741BMgAmVLdc63uUlL8Zxl6ELsZjR581e0Cy4SZJ
         oY9N99FO1F46q6R8RsUDvteILm4D2zNGMIdwJNwiprAN/Oh+WCJHwZzMMVHOYokMx+/x
         +J1ua4ts6avjRhthwVkiZxotH214BoAx02PCsUdqefAl8D1k+sxVVRt4VBUQn6CsafQk
         i3Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d9si867737edz.195.2019.06.07.01.56.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 01:56:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 69A33ABB1;
	Fri,  7 Jun 2019 08:56:27 +0000 (UTC)
Date: Fri, 7 Jun 2019 10:56:24 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Toshi Kani <toshi.kani@hpe.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 10/12] mm/devm_memremap_pages: Enable sub-section remap
Message-ID: <20190607085612.GA5803@linux>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977193326.2443951.14201009973429527491.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <155977193326.2443951.14201009973429527491.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:58:53PM -0700, Dan Williams wrote:
> Teach devm_memremap_pages() about the new sub-section capabilities of
> arch_{add,remove}_memory(). Effectively, just replace all usage of
> align_start, align_end, and align_size with res->start, res->end, and
> resource_size(res). The existing sanity check will still make sure that
> the two separate remap attempts do not collide within a sub-section (2MB
> on x86).
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good to me:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

