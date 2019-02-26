Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFDF1C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:23:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B806021841
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:23:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B806021841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 552AF8E0003; Tue, 26 Feb 2019 09:23:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 502388E0001; Tue, 26 Feb 2019 09:23:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F1418E0003; Tue, 26 Feb 2019 09:23:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D9A188E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:23:54 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k21so2516837eds.19
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:23:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZsulBu4UyrGv/4rwZYd+rWNfPfV9R07nVJEG+I8XMNk=;
        b=k+SSF11kVEC1du4Prl0w88Ak1s/oGHe6KrmwRz19oBZkj1eX/WhXWsjkw/bMEHjvmK
         6lW4svocj22/WQz9G9IXw2n9gsbVm3NWM/LemkDRzJ9KL8l7YSg4Ef5iA8PLlnev6AYn
         ZJxh+gv2yPcMlxeIwbt2uA+Ri3gaJ7bb+3TUXSO8ZijtT+24MeVbTZiMHDo2Ie4zUuLz
         qts78c+YYT5GoMr3ITtBMJ9yBwpYzitIImeUN5EBSGFNDlBMFUUQzxp2maBb/Usr9wAF
         JUBXi8NHbKkAP+7H3B81m6RiMDk4NNyu/v6vMscEcV2szlb4u7EECgZhqfzk4jowuGg1
         Gd1w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubv8VhslLwn6+pJtg9vmAPNI5WUKavZ6S6MReCYU45oXbGVCvW/
	TB+u0Yu6fnmO+CbxWAvf6rpH6nH5khEDTGTzMqkmyfLa2HNpp4zrTcFVWxGxrOb+jYo+dd80RCS
	7Eyb2yV6oBulz5FA0sZwPdpO1r0BUJYyLNMwJ781g/I5czyHRTytnF1N/6PuFyIU=
X-Received: by 2002:a17:906:c286:: with SMTP id r6mr16952100ejz.7.1551191034463;
        Tue, 26 Feb 2019 06:23:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYx9zauJGY6W8keFRPS4QZ97hp7W0NqdNlgAzL/nb+IMMAGAh131dgYPDeWCWkSczeSKwaC
X-Received: by 2002:a17:906:c286:: with SMTP id r6mr16952055ejz.7.1551191033614;
        Tue, 26 Feb 2019 06:23:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551191033; cv=none;
        d=google.com; s=arc-20160816;
        b=IvXKYLilUyoOFbOll4eQ2tLsqV1Z+XWTtFtiYflwBnnSyiwJWQRz02LK+8phzXDLU+
         XGUa925ZBEV6EUKRKRFN9kCptCNoRp0D7//rj2W0AeAtAa4PFm3tG5yPqy7DQOi+pF4J
         /QowFuq5OaA95kuciLgEtA6UNs+bpec18i4NhjwMCG/vKnFQK246lsP7BSuelguOTSt5
         vYVfKFmY6hpKctOzQNyIXDEywbEilhlI7U9UCCicqtAFIOxHiqfVgNtTxLiC8ZG36UYd
         sTflVsR53tx5ZW4hWVonu/uob9kNJpM3e0rKnzWwww4bIHE/fTjBapCHrvslRCmCxJ6A
         diWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZsulBu4UyrGv/4rwZYd+rWNfPfV9R07nVJEG+I8XMNk=;
        b=Mhea8psR3F4qHqnnIklbLqcV0hbwyIGXKuoSrbPNFFakixJu+6gSOgHcZNbhYzPIeC
         cuBrZDrxBfik1D1/V5tJtshS01rRdpRLJbrCNJFgZpMGoCpaC4B7fVRmzqojCQfPL/FI
         /CojcBK/XXvWO0oTeOxM9XjGxh/Ee76hHutjIsEnctDVHwwIWpLjjeeh7KKn3GBhA6oN
         3b/Kr6mLpk1C/v+8fPeh9vkJcd82MpHB8dUqtKUlSrVEnBqlNA/xwkwuGq2TJ8nkqgBX
         T+QqEb4TM/83LJJRO6LFGz2DharCn4WnL8D9y0Akmyb8BbLvqITJBob9VL7dxsRGLPSa
         N+0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f22si752018ejk.265.2019.02.26.06.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 06:23:53 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AAD46AF57;
	Tue, 26 Feb 2019 14:23:52 +0000 (UTC)
Date: Tue, 26 Feb 2019 15:23:52 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Message-ID: <20190226142352.GC10588@dhcp22.suse.cz>
References: <20190225191710.48131-1-cai@lca.pw>
 <20190226123521.GZ10588@dhcp22.suse.cz>
 <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-02-19 09:16:30, Qian Cai wrote:
> 
> 
> On 2/26/19 7:35 AM, Michal Hocko wrote:
> > On Mon 25-02-19 14:17:10, Qian Cai wrote:
> >> When onlining memory pages, it calls kernel_unmap_linear_page(),
> >> However, it does not call kernel_map_linear_page() while offlining
> >> memory pages. As the result, it triggers a panic below while onlining on
> >> ppc64le as it checks if the pages are mapped before unmapping,
> >> Therefore, let it call kernel_map_linear_page() when setting all pages
> >> as reserved.
> > 
> > This really begs for much more explanation. All the pages should be
> > unmapped as they get freed AFAIR. So why do we need a special handing
> > here when this path only offlines free pages?
> > 
> 
> It sounds like this is exact the point to explain the imbalance. When offlining,
> every page has already been unmapped and marked reserved. When onlining, it
> tries to free those reserved pages via __online_page_free(). Since those pages
> are order 0, it goes free_unref_page() which in-turn call
> kernel_unmap_linear_page() again without been mapped first.

How is this any different from an initial page being freed to the
allocator during the boot?

-- 
Michal Hocko
SUSE Labs

