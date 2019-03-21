Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0F45C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 10:03:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6AA6218D3
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 10:03:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6AA6218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 251896B0003; Thu, 21 Mar 2019 06:03:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 201706B0006; Thu, 21 Mar 2019 06:03:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11A536B0007; Thu, 21 Mar 2019 06:03:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF2E56B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:03:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d5so1991585edl.22
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 03:03:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LzHCm0222w9//IUougpPZTLTk12UjU1d65uoLzJeIwQ=;
        b=ZPTMGZkqasqkUDOGpZkAtPXlzbnTo7pDFHIgGOmZ9zy8ZPOy0785YwRBwpn8OKewCi
         97qvdgPVlnsTonn5IiEKQfxlTo/Ep1uZtwJDfYN9hl2p63Yh3bXmv96ptsCY8hqbzEh1
         GQvv8LKZ0cu5m6EBzHZml/WCUo0d26KXFCp2e4nHN9DqCHEyglHDlRcRF6LGKKaPeN8r
         kutEA7r2Q4PjDQ+inRsKwLwVSu4KwY6ApIblxLcCNVo2GXC9oSkeltcMnYSO3UEansEs
         uTpxpixQtHp+Z/lrzw1zM/MqUPC4edD7LsJch70uzII+J99RYwheAetJ+pZ4JitJdwTq
         kmig==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXTPVP5av08CC5aEmAb1QZgssblppLratKqLF0+YTiJOMD1X1dc
	7/ODaYX834R0w9FCMOvh+8Rrd2hsefi7e639hhMNskyg9t4/zMjr4hUyRB+kFp3w056Fsfz92lJ
	ikmvV41JRRTyPiRdLVr7Z6ge7sHdeIWf7+H/Nd3Lw+lFmqJ38VU4dSHooOAbg/7w=
X-Received: by 2002:a17:906:88d:: with SMTP id n13mr1825215eje.154.1553162599262;
        Thu, 21 Mar 2019 03:03:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCXhCifKR7+PETQxJZtVvISDBzuO3ZsP82D9PXtzdmyDw07U0PAtTNkUWwMAp01kMAmxs5
X-Received: by 2002:a17:906:88d:: with SMTP id n13mr1825174eje.154.1553162598399;
        Thu, 21 Mar 2019 03:03:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553162598; cv=none;
        d=google.com; s=arc-20160816;
        b=jaa3wVTsJKJ3nCFApF8mvn33KqsWCOX3v1jN9RRggPW9NyGMQ9Vs45vxeK9N+D5/xq
         qz6VRZpuoBfcU90Z11jZqa4JcRjTFwK4fmnDtfL7QT8XdWx2UxADHsxqwyBESnRCRmeb
         4yD4O/c6jwpui5LmABpWMPo3/PrJ5TNQXFpzAkMIHpQItdppxTJTIns6GL/8xMJT019l
         AYtKJ+Q7bW7IbDFQZOsweUk1TW0VRLtbCQEDrqqzVMG4/keiUfTusxFGiFCjAZvsGeVw
         13to31nFKnYCO/HhqvlIVNbDtQ/9+pFdACldmrS6Mx33x8iDFf0EZKigc/bipMHCd+I2
         gqow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LzHCm0222w9//IUougpPZTLTk12UjU1d65uoLzJeIwQ=;
        b=SZywEeAYMOtwaS7pBtw9XnrPnIyWoJZ7wWDXtDvw65rAXI9ZAsynfEephCkPaBTRwY
         uYWvCILMAIvt9QELm24Pg6fe1VjfRondCncMZ2gzgvIKFIyjpdGbwvYlsOLG3pyIIQen
         miWrNqirx5K/7kP9TiraUeQ+/1bJNNBmkLDT+Bb7hMzvgIiXr/yaUKyN7WWkX+HRK/nW
         NJCvWYcHsmmWPDbdhXyt74Lub+dtAvA+XvVmcFOu4Yi/GXBl/F26bdRh9hcQLPKTDxV7
         fW655fgGtgW+QbX0xZDAdJoHwq6V/WT+FDXaPui/meM/F0EBLLNPd0QxsK4sVaNrzbWD
         9Baw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v26si1853191edy.431.2019.03.21.03.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 03:03:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AB793B049;
	Thu, 21 Mar 2019 10:03:17 +0000 (UTC)
Date: Thu, 21 Mar 2019 11:03:16 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, mike.kravetz@oracle.com,
	zi.yan@cs.rutgers.edu, akpm@linux-foundation.org
Subject: Re: [PATCH] mm/isolation: Remove redundant pfn_valid_within() in
 __first_valid_page()
Message-ID: <20190321100316.GN8696@dhcp22.suse.cz>
References: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
 <20190321094237.onu3kar2ez7xv5wj@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190321094237.onu3kar2ez7xv5wj@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-03-19 10:42:40, Oscar Salvador wrote:
> On Thu, Mar 21, 2019 at 09:43:15AM +0530, Anshuman Khandual wrote:
> > pfn_valid_within() calls pfn_valid() when CONFIG_HOLES_IN_ZONE making it
> > redundant for both definitions (w/wo CONFIG_MEMORY_HOTPLUG) of the helper
> > pfn_to_online_page() which either calls pfn_valid() or pfn_valid_within().
> > pfn_valid_within() being 1 when !CONFIG_HOLES_IN_ZONE is irrelevant either
> > way. This does not change functionality.
> > 
> > Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
> > Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> 
> About the "Fixes:" tag issue, I agree with Michal that the code is not
> really broken, but perhaps "suboptimal" depending on how much can affect
> performance on those systems where pfn_valid_within() is more complicated than
> simple returning true.
> 
> I see that on arm64, that calls memblock_is_map_memory()->memblock_search(),
> to trigger a search for the region containing the address, so I guess it
> is an expensive operation.
> 
> Depending on how much time we can shave, it might be worth to have the tag
> Fixes, but the removal of the code is fine anyway, so:

Yeah, seeing a noticesable slowdown (actual numbers) would warrant a
backport to 5.0.

-- 
Michal Hocko
SUSE Labs

