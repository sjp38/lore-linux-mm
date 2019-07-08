Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MISSING_HEADERS,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28810C606AC
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 13:28:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E40BF204EC
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 13:28:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E40BF204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7625A8E0014; Mon,  8 Jul 2019 09:28:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6ED978E0002; Mon,  8 Jul 2019 09:28:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DA138E0014; Mon,  8 Jul 2019 09:28:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40BAD8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 09:28:04 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 5so16444613qki.2
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 06:28:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:cc;
        bh=xmpQG/YvPNoLqkL4mczESC7OrNcoM8yKqZCuImT3btc=;
        b=k0dlMd0WbmZDq7huVac0lgx1dzfd3iqWJiPPkvFD76MPajcFy0N/XUlqlYA3/ZvSVq
         IxULKf2SeVI3kPCcleWmYhikqbXoRH2I+5+xz6Od1nXnnHEtfWEjNkwTJp8oPXctAIO6
         fvrWTES7UuVy+gcw0BJr4XRY6VtiN3lxoTybuZuNs32ojoqaf1cC1opHfUNM1UtFLxHm
         ANZ9FanLdRlRhCJRNoqm0R8HA8WIJzr7EG8FJTjhUxqkGNxPaj0iO2R/m4ruACykxa+B
         hYoeL1Ot4qoYojySHMMXTHjkCFq0dj//MMvcZvwXQmWU6XNISZ/mnhlcaDftMEcXthm3
         USqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAWmA+drOAkU3jUBHWjHrcfTiFGazqgRg9ccJBChpnM3lnhz6OC+
	AfEwWyewvO26feknY1/J5bqck0ovfhjbZb2ASzQM9IxWo3gwy2F1iW++KEXVSeW+uazEbpvSYjf
	EoSY1xwgQ89CKpfD1GQ6vWfVVhBAiPzYU2v/OayblZ6HfDg4KsMBvBBEGTTTn224=
X-Received: by 2002:a0c:9916:: with SMTP id h22mr14688051qvd.95.1562592483894;
        Mon, 08 Jul 2019 06:28:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykmMp0EShYS3ZhttUT+Suzri7Ultu3avxazndAYr3pxuuhPAKge7ceq1V1Pba+rng/xjG+
X-Received: by 2002:a0c:9916:: with SMTP id h22mr14687999qvd.95.1562592483223;
        Mon, 08 Jul 2019 06:28:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562592483; cv=none;
        d=google.com; s=arc-20160816;
        b=0cTAIG8/vJC2+rJy2avO3FojD7JGQxeBQAkk1o54EsI0jwSA3S2vEXKACqZH4j4OMU
         S9FZSKJ1FCwGjuqFSUjqyyjfwD2wlFRccQtB1k1pEftCgnfxUkvcBNW34usDucgVlcox
         7j7OZaz89QPzVA+T9Wpd/wJ2rXg2v96rCkd4WE9bBjb502aYmy+9fowZfSqSY4X++lxb
         mWMUfJzOXqeD+xHTDoKr9WnLnNc9Mvd+yaWvqYia46a62KYyycDa8D+94i5g3x6/taRv
         nCN85yKnBR897B5z0oZF/2EUzTukTfZ+zH0tS6yNeOBWc0Hk3fSCp16dNO7qED9HtVVN
         kPRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:subject:message-id:date:from:in-reply-to:references:mime-version;
        bh=xmpQG/YvPNoLqkL4mczESC7OrNcoM8yKqZCuImT3btc=;
        b=gis2Ze4HahZISn1iMt/0wya/GMAAKHM0GQftx0K2hcFf66saAL/urry0zTtP2UwfSN
         93oDcS/TXGtdmcFz64PO3lHBEYdAc+R2CF0PQ/dulYImmz7whyo14oO50KYkedzVHp9u
         RR3PEECS5M0chyDnEKjs2uzhXH++TBEHqjEsyJmJd3QdtAKMBFHxnVG/Ui9mBunwJ+E5
         rzBLD/RDvYQ/AwUlEbkt4hUiqPV6UJLo+Ycnr3nU2PF9c/nrvbGGmhnWVjL4tmzk9E18
         IXZt9qh98FROk5jyLaz3/8juSQhzroBcs2yhLt1ScG8QQ4pYC/3XkbMs2VeD7tJ62dZn
         D7rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u125sor9920479qkd.151.2019.07.08.06.28.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 06:28:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Received: by 2002:a37:76c5:: with SMTP id r188mt13444333qkc.394.1562592482848;
 Mon, 08 Jul 2019 06:28:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190708124120.3400683-1-arnd@arndb.de>
In-Reply-To: <20190708124120.3400683-1-arnd@arndb.de>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 8 Jul 2019 15:27:45 +0200
Message-ID: <CAK8P3a2pn4s1aLWAd+riKHO9RGgu20u=62Ds1fWg1OCQEGiiOw@mail.gmail.com>
Subject: Re: [PATCH] vmscan: fix memcg_kmem build failure
Cc: Yang Shi <yang.shi@linux.alibaba.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, 
	Shakeel Butt <shakeelb@google.com>, David Rientjes <rientjes@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Roman Gushchin <guro@fb.com>, Chris Down <chris@chrisdown.name>, Yafang Shao <laoar.shao@gmail.com>, 
	Mel Gorman <mgorman@techsingularity.net>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 8, 2019 at 2:42 PM Arnd Bergmann <arnd@arndb.de> wrote:
>
> When CONFIG_MEMCG_KMEM is disabled, we get a build failure
> for calling a nonexisting memcg_expand_shrinker_maps():
>
> mm/vmscan.c:220:7: error: implicit declaration of function 'memcg_expand_shrinker_maps' [-Werror,-Wimplicit-function-declaration]
>                 if (memcg_expand_shrinker_maps(id)) {
>                     ^

I see now that a fix for this is already in today's linux-next, please ignore
my patch.

      Arnd

