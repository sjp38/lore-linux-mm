Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1618DC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:09:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B985C2086C
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:09:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="IUEd3GXJ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FJFoK3yA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B985C2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kroah.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 431DF8E0003; Fri,  1 Feb 2019 09:09:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 409148E0001; Fri,  1 Feb 2019 09:09:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D06B8E0003; Fri,  1 Feb 2019 09:09:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 013998E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 09:09:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id r145so7145673qke.20
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 06:09:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kh208pwU0DHoRepH3JHwazRnR9a3aEF0XNjNIFI4NjA=;
        b=EXQho55TFh6jHzOL7riNxpazXMk9CZdhYFAmnR/CcWKBOuvIkJHU8PQ7eBJKprwzGd
         hzwcdLUmfAopsp01Yba+RgVX7MUlVIt21XLjuRMcpurT8kUcj6QCEbaE/tihR8ZeOo+c
         UP5vWKvMvitJY+HoggTVg7D5G23VmMkcqw7fSmlggirZJc856zLRvBxCG7Vjbpt1Rx1l
         mLctXf8G/Gi+eXx9usm5EY48q1Yd7/OAETrKxV4TQ6KY2PfAhcZ5J/5bFpAzsAAqrznl
         l8r+rMR/yKCZC1EcrH4ADadEaIMl4ioeO1QWzxQA784dH5lq0uXTi0HbwftnPRx9xzbb
         Riog==
X-Gm-Message-State: AJcUuke+h7SoNmP7rfdKiZHn1YpIzcM/0JcvUGFNberyHQZ2RLRXOxc7
	cEmdjJPFNKjBRcXR/pHXU2mnL+7C9tKLaVTgrHeCLLB4J0i36OJTMI4zHOuK4tssu00NBdaGxmK
	SGaUm14EASyjnODcgZt1AJwR0d71OyR1AlYkWtBHtoC174XNzIy8JEa0FnjZI+cZ3Rg==
X-Received: by 2002:ac8:1b34:: with SMTP id y49mr39721406qtj.374.1549030167722;
        Fri, 01 Feb 2019 06:09:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4MNAaYsuDpi8fqEoEg/HMMkvbzp4TtOvBRIfCqLD6QGg6u2IMGEkVbFdBpbcMivF5LGu/8
X-Received: by 2002:ac8:1b34:: with SMTP id y49mr39721335qtj.374.1549030167021;
        Fri, 01 Feb 2019 06:09:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549030167; cv=none;
        d=google.com; s=arc-20160816;
        b=lOfEz3bvuiHchxGQYiZDx02JVU/AL8+HCLIB1ji9FW4FzEMGIOksBliU2bKShF/08g
         wNN0mP3kzeBf7xPIjQB493cxSpxBRDUXy/Y6uQM7jOEORtMIRo4wjf2lr6Gu2k5NS+iQ
         r5N6IZhNr0sPZid8iFZ6kJwPyN97IujHi3P0iaNEOQOXBCqVzOnExiKnhZSGT68W+WcM
         G8lQdk5UzbpxYjPclFOjB5+Bs5a4Nb0t6/2Eg5zVd+oBEtZ0S3E0ac8ehusLq4FxatDY
         mrTL5pOuBmbH05xgjAsicKTutaOLnc5VzFqTQQELoD7n5o2sr77FNHA8y+e+cTBGAAT4
         kBFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=kh208pwU0DHoRepH3JHwazRnR9a3aEF0XNjNIFI4NjA=;
        b=tVvLXA4VblDp8ms/revPfbs9z6Y5l5de1rfSYh6GOqqzwpBEyb0nV5dS+AQ7cFtEpi
         LQn0x0BnMmBnZtTth/uuqa/WDJY7AQ+YP79h7VFIWGCR7GxBdGTznOC9kbJdExBOlAY/
         /FKv/87NPSSwY4cZ3U0vwbmCFdc25gOWaPWxjq5Y2ES4tvjNIgjSoZV8T3GC1rVuAQ+Y
         uRcZnTKthSJ7GOngutVi9VdF/BVy1XRw0VzJsqXJlCM34dUAxw+dss13rWIgAbpPpQc2
         tPlKYR3vLusjC6txn27tOnlf4b4P+eyaCS068DRIWr4/rR4uREkJfM7i5kjNCL5EUPhN
         +WtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kroah.com header.s=fm2 header.b=IUEd3GXJ;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=FJFoK3yA;
       spf=pass (google.com: domain of greg@kroah.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id m14si3485264qtp.177.2019.02.01.06.09.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 06:09:26 -0800 (PST)
Received-SPF: pass (google.com: domain of greg@kroah.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kroah.com header.s=fm2 header.b=IUEd3GXJ;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=FJFoK3yA;
       spf=pass (google.com: domain of greg@kroah.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.west.internal (Postfix) with ESMTP id 758341264;
	Fri,  1 Feb 2019 09:09:24 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute6.internal (MEProxy); Fri, 01 Feb 2019 09:09:25 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
	date:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=kh208pwU0DHoRepH3JHwazRnR9a
	3aEF0XNjNIFI4NjA=; b=IUEd3GXJ/k9uKEYr9LBZgsZ0CK3QCHH6E0bAlrLug4V
	ONOc8A2erGaRLWPCFD61ES47CdlOxsNp2139AJueSzyuTDnsbJH+Gl6YPcCuJzYx
	lQGE4qphnifqpg90s+avv+Knp5nDU2+dRPlzv3ariLgi38piOvpdbsmUliGdeU1m
	erCQJ9S7fHWf7HfO9aUj/N8fXszn6fublaQ+9OJEoICJfKQojQrz+nNeI4URIpaW
	Zp45TCqZ2b7k97ghHG4vQbJ5XPPdOUD3gWz67p/o3cpl9Igljv141Iw9+idhIiJZ
	dytIFgpUWwUz1jzTBBX0S1yRnzFzn7L5C+SHkbMFMPg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=kh208p
	wU0DHoRepH3JHwazRnR9a3aEF0XNjNIFI4NjA=; b=FJFoK3yAAMjwlkttwou4Dc
	1oogG0GB1/z8YnahCoTASp98yDDpNsNECDPwOKKiUgV9a4SdrNwywMK3x/CenSC4
	CTsrsxyRd4Ule+57VsdXZrcnv8R5doD2NIny4ZzMXFC9jYoQeRk7VuEOVA1tTXd9
	Mp2rqdeOEwlRrxEE/rX9FWLnUnsIVulKOFiRPaf4ub1Fr9JuPKS56HQ2DSdefR5j
	avnxFqK1i57tbgeYQp4AbASCNBK4zIz8jnKVlPLSzcizm6HATSn1QkxjHTxXXFSe
	rQkdv2Z6bswQFAd3JnH9AC3x+Rpc0Q/pdTnzr849v7s8HMP/drt1IhaK2r99aPqQ
	==
X-ME-Sender: <xms:EFNUXLxRhPaOdJuU0Tgfk6NFaHLiUPBPGQcFsdyHxOE00b9t-JIISA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeekgdeiudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhepfffhvffukfhfgg
    gtuggjfgesthdtredttdervdenucfhrhhomhepifhrvghgucfmjfcuoehgrhgvgheskhhr
    ohgrhhdrtghomheqnecukfhppeekfedrkeeirdekledruddtjeenucfrrghrrghmpehmrg
    hilhhfrhhomhepghhrvghgsehkrhhorghhrdgtohhmnecuvehluhhsthgvrhfuihiivgep
    td
X-ME-Proxy: <xmx:EVNUXIi-FEiGGq78XN7kGzhPgEvzRfR-3IVdFP0grPXitliVOM0O0w>
    <xmx:EVNUXHDv9sF-yGwmSKxW2-VPNAzVXBR7HT_ihWjm2JqVRsKFby3Q4g>
    <xmx:EVNUXNuIy4AN3cDjriZD3pPruPyv29igcq-mSN9x1AHQpA-qv-K2Fw>
    <xmx:FFNUXJ7MF39NRac2O6WFluDSsA0UNATsmJcnPZ3Ydj2UFdCE6HD8PQ>
Received: from localhost (5356596b.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	by mail.messagingengine.com (Postfix) with ESMTPA id 51872E409D;
	Fri,  1 Feb 2019 09:09:20 -0500 (EST)
Date: Fri, 1 Feb 2019 15:09:18 +0100
From: Greg KH <greg@kroah.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Matthew Wilcox <willy@infradead.org>,
	Vratislav Bendel <vbendel@redhat.com>,
	Rafael Aquini <aquini@redhat.com>,
	Konstantin Khlebnikov <k.khlebnikov@samsung.com>,
	Minchan Kim <minchan@kernel.org>, Sasha Levin <sashal@kernel.org>,
	stable@vger.kernel.org
Subject: Re: [PATCH v2 for-4.4-stable] mm: migrate: don't rely on
 __PageMovable() of newpage after unlocking it
Message-ID: <20190201140918.GB20335@kroah.com>
References: <20190131020448.072FE218AF@mail.kernel.org>
 <20190201134347.11166-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201134347.11166-1-david@redhat.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 02:43:47PM +0100, David Hildenbrand wrote:
> This is the backport for 4.4-stable.
> 
> We had a race in the old balloon compaction code before commit b1123ea6d3b3
> ("mm: balloon: use general non-lru movable page feature") refactored it
> that became visible after backporting commit 195a8c43e93d
> ("virtio-balloon: deflate via a page list") without the refactoring.
> 
> The bug existed from commit d6d86c0a7f8d ("mm/balloon_compaction: redesign
> ballooned pages management") till commit b1123ea6d3b3 ("mm: balloon: use
> general non-lru movable page feature"). commit d6d86c0a7f8d
> ("mm/balloon_compaction: redesign ballooned pages management") was
> backported to 3.12, so the broken kernels are stable kernels [3.12 - 4.7].
> 
> There was a subtle race between dropping the page lock of the newpage
> in __unmap_and_move() and checking for
> __is_movable_balloon_page(newpage).
> 
> Just after dropping this page lock, virtio-balloon could go ahead and
> deflate the newpage, effectively dequeueing it and clearing PageBalloon,
> in turn making __is_movable_balloon_page(newpage) fail.
> 
> This resulted in dropping the reference of the newpage via
> putback_lru_page(newpage) instead of put_page(newpage), leading to
> page->lru getting modified and a !LRU page ending up in the LRU lists.
> With commit 195a8c43e93d ("virtio-balloon: deflate via a page list")
> backported, one would suddenly get corrupted lists in
> release_pages_balloon():
> - WARNING: CPU: 13 PID: 6586 at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0
> - list_del corruption. prev->next should be ffffe253961090a0, but was dead000000000100
> 
> Nowadays this race is no longer possible, but it is hidden behind very
> ugly handling of __ClearPageMovable() and __PageMovable().
> 
> __ClearPageMovable() will not make __PageMovable() fail, only
> PageMovable(). So the new check (__PageMovable(newpage)) will still hold
> even after newpage was dequeued by virtio-balloon.
> 
> If anybody would ever change that special handling, the BUG would be
> introduced again. So instead, make it explicit and use the information
> of the original isolated page before migration.
> 
> This patch can be backported fairly easy to stable kernels (in contrast
> to the refactoring).
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Vratislav Bendel <vbendel@redhat.com>
> Cc: Rafael Aquini <aquini@redhat.com>
> Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sasha Levin <sashal@kernel.org>
> Cc: stable@vger.kernel.org # 3.12 - 4.7
> Fixes: d6d86c0a7f8d ("mm/balloon_compaction: redesign ballooned pages management")
> Reported-by: Vratislav Bendel <vbendel@redhat.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/migrate.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)

What is the git commit id of this patch in Linus's tree?

thanks,

greg k-h

