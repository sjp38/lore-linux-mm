Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92561C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 09:47:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FC7E20828
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 09:47:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FC7E20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9446E6B0005; Tue, 19 Mar 2019 05:47:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F3EA6B0006; Tue, 19 Mar 2019 05:47:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E2A66B0007; Tue, 19 Mar 2019 05:47:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26CDD6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 05:47:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x98so5559544ede.18
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 02:47:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mXmOKB2JR8bRnwS7xGi+IiR2b0HFQb0xNT9YPCitEOo=;
        b=W0NWYtTTj6DHNEeW7QgytN3QhF/yw9bBcBtEhX1kvfXrDF47Va/w3o/Kvu6g0rvWHG
         2RWli+2/g13TTK/jGyAojGsf9Kb23twekOel1ic1Et4YwaQX5rSzKF9utjOcvEpkA5rK
         N8Ye7mPFCFq8r/P2mY2ukrnn6MNgV9IeHF3FZFoi8g74KcS/pX+7Q36b9Hsnl+Iy1niB
         O96OCeyY1ap+zbSrSvEYjZQSAmX4nIFJHaX1a3LJH6RnB7k2XAZ2LBrWm04iE5xr7Uir
         NeGrBn9yOCeMsk33gOvXuJpIVK1hHQrqkt3geYd8BYRB05tznGot3KhLXJYZ0unJtGQi
         k6VQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXqKccF9QdEC0mMMihBUJuRoLTsODcl703H2yWTMWQhJtf19RYL
	F1mGCLc2LvXnYS0kSshBKGh65LTHfRBpkTqFgz+8AP00cXP2KNFqs4ajG3kcPxnMmnSIDTH4w0h
	9U7OtCS5lOL5UMZnC1s1D/KeH5VGIKufrluWP/5bN7raTtff2yfpG5G78oR3y1JFTGw==
X-Received: by 2002:a50:d8c2:: with SMTP id y2mr16284272edj.65.1552988855719;
        Tue, 19 Mar 2019 02:47:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKux2YQOY/q44MgHancZJtWjexnlGQ1nEyJKbar8j/AWxolXQAl4xevvEvJ7uQySEgguuG
X-Received: by 2002:a50:d8c2:: with SMTP id y2mr16284227edj.65.1552988854893;
        Tue, 19 Mar 2019 02:47:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552988854; cv=none;
        d=google.com; s=arc-20160816;
        b=ESb7iUlZz6ohMryj+M890YlHjfD2Ecoel+vk4O9Mc2ixb8c/w1BqLPrZ+CW+/u49ud
         +DkTlJktrUSucoFBeMeezPplFO+Norou6a8A/lnCHW7TXBHtk4QUz3dDLUI+AyPl0Swv
         nSNHIjpzK5OCmvjQ62LL5VbqhewlaiI1T7PxA40ZeSy8KrtBZmPUOoICxyc9i8u2GHvE
         QqIYgOGVSSCulIsqSjxlT29AtzuJK8Zc97l77O+rYDYDvHWHiuK3qANk4pKNaZA1Wo/Q
         aLx5LXBlkwT0s85y78vpTz9pyPufzk15T2VqZe5zp3Vgz51oo9fEf3yMScG+f4bw2rLX
         etoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mXmOKB2JR8bRnwS7xGi+IiR2b0HFQb0xNT9YPCitEOo=;
        b=BxhMUeN9HUvuOI7V5ntfZ1L3BeHp7O9iyiopQ3ZA6dugYkTKf68QrOUJbQyDeHKXvs
         Pq46KYNF0eTNADhqcbxMVbsva5057FHqwbIoLIoVw/pUSETcy6JwUoccnB58seosj0go
         yVwMps1/RE8SREUdi7uU/nGWHxYk3htH7NI1Xh+2u8YiAU2a+2vwqKLNXWUF+YKSDrzy
         yLw+gEHLCC3MMC6bWLLDpJ/xmji2kWLfRDojJK7uqaxVv2UyUIlT4c75fLXwyn7VXAZ3
         RDTjDiiyjlClem15qMN74YyGdBZEwx/FWMdSLRj65Q29Hd7EwvEtvWepyytromuDvV6r
         boTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id i4si1713205ejb.200.2019.03.19.02.47.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 02:47:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 5D0D81C2AA1
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:47:34 +0000 (GMT)
Received: (qmail 3211 invoked from network); 19 Mar 2019 09:47:34 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[213.151.95.130])
  by 81.17.254.9 with ESMTPSA (DHE-RSA-AES256-SHA encrypted, authenticated); 19 Mar 2019 09:47:34 -0000
Date: Tue, 19 Mar 2019 09:47:33 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Takashi Iwai <tiwai@suse.de>, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
Message-ID: <20190319094733.4j6sp63ma56vygzr@techsingularity.net>
References:<20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
 <0c6393eb-b28d-4607-c386-862a71f09de6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To:<0c6393eb-b28d-4607-c386-862a71f09de6@suse.cz>
User-Agent: NeoMutt/20170912 (1.9.0)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 01:21:59PM +0100, Vlastimil Babka wrote:
> OK here's a new version that changes the patch to remove __GFP_COMP per
> the v2 discussion, and also fixes the bug Kirill spotted (thanks!).
> 
> ----8<----
> From 1fbc84c208573b885f51818ed823f89b3aa1e0ae Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 14 Mar 2019 10:19:30 +0100
> Subject: [PATCH v3] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
> 
> alloc_pages_exact*() allocates a page of sufficient order and then splits it
> to return only the number of pages requested. That makes it incompatible with
> __GFP_COMP, because compound pages cannot be split.
> 
> As shown by [1] things may silently work until the requested size (possibly
> depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
> triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.
> 
> There are several options here, none of them great:
> 
> 1) Don't do the spliting when __GFP_COMP is passed, and return the whole
> compound page. However if caller then returns it via free_pages_exact(),
> that will be unexpected and the freeing actions there will be wrong.
> 
> 2) Warn and remove __GFP_COMP from the flags. But the caller may have really
> wanted it, so things may break later somewhere.
> 
> 3) Warn and return NULL. However NULL may be unexpected, especially for
> small sizes.
> 
> This patch picks option 2, because as Michal Hocko put it: "callers wanted it"
> is much less probable than "caller is simply confused and more gfp flags is
> surely better than fewer".
> 
> [1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

