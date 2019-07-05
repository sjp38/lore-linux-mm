Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BF4CC0651F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:01:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBB7A218A4
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:01:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KxxQ/EOQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBB7A218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 601FF6B0003; Thu,  4 Jul 2019 23:01:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B35E8E0003; Thu,  4 Jul 2019 23:01:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A2AF8E0001; Thu,  4 Jul 2019 23:01:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF7216B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 23:01:14 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e6so3136169wrv.20
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 20:01:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=clMDBr0VH7M11Amw0B3Ri/sIv+DBHpDPWFocL6b0RWI=;
        b=mipikwBbGoKRbMJMkUrFlsbmAlZIm7lEDsYbWCaV5+ziRiQGFmDbC2QwkWviT0lf65
         b10ts4+OY/7r35VWZat8QjGvHhvhvreIXg/9UQao2utwtXGaAc+9UphX1KJoUKot//EJ
         n8ANavIfqecQgAaKsyc6TDEt+B7HgGRhSJBUyIS2TxbeqZgWNV3LKCFL2/ixCzKT7qq5
         awAXvhFFdUcyxf8+RNMSUMMA6r+2dUvtf85U8bGXiSbAhAiB8jzR+60OX7SjXzbwF11W
         rsi75Knpc2f9VSItKDMid5/4J/ke0gvK/zvXbieNddecOBNBeSEz+RVupwvI187T0udz
         gOyw==
X-Gm-Message-State: APjAAAVI8k2BsstMEb3EGLlTLgT7WHKTGB3L4eGNnn2Qs4WbQtZdNwGL
	dl98hLuNmjC1X+KubK7Mu5Rw1wfv+j6tMy6swtrYQv7n0Ip4ohqgvo+bwiwSkF59+i4IfUh0cpk
	ZJDRT8ljJNB1zzlg1WFe9OkzcfCAmeKovv/x747Kiuhat/5EwfIiTef98LNzofc0ZBQ==
X-Received: by 2002:a5d:4908:: with SMTP id x8mr1147543wrq.290.1562295674323;
        Thu, 04 Jul 2019 20:01:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdBemu5NxYrpW3a6zRI6gexnIgmYt8jkBvUJMX2Y50DKholbnqR4GwSzT71vUjuD+BvBVJ
X-Received: by 2002:a5d:4908:: with SMTP id x8mr1147481wrq.290.1562295673495;
        Thu, 04 Jul 2019 20:01:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562295673; cv=none;
        d=google.com; s=arc-20160816;
        b=k8Bwn4cI6fHu6l0dC/HBka1h9Blp+M4n0ce8iRkr/0Js+97/cXOL/HW9IL/tm960sU
         cqSqUWORDfEfFP9M3ql0HqTeC+5Sfs2XQ61FBhgqmzODdh0t5Ob8BgQRnM05pMzuCrPM
         Lz1U1XIiOPGppylKFBAohZeIO1QCKP3o88ewOUx+rWgL3IEfGzZNaHlmpNMTFkdH1pct
         xwMG6H3zX3SQlm+isv2xfTFN4DvVQnmMfpZ0nC9iWgZFNAkvSiUVOO17QMRdU/arAH4M
         klwDqEJCoNSNjtKMnMO9gSergzzUoaXgtCnP8g3P/NQ5c9vLT8yWST0/yPiCi0lrkwk1
         AceQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=clMDBr0VH7M11Amw0B3Ri/sIv+DBHpDPWFocL6b0RWI=;
        b=GJ/0dZsTgt9hiqGyIyxQ5bkhDqBQxGdqrIXKMyqLCDun5mEvsq6yzq/zF2+36h26mw
         IRvTSugBzJ5IfcGbJ8O+Miud6wEv0XNPv47sAJNw/lE+tZLZKdiVZDWJEcP9nDKd+lQB
         BLqb1rxh8m+NZIPksGjSt8ETKfYiut9VDoLB119BsOPwANq5cXToJKPwATA4eQkbES1t
         DQj+3DDW8eAmMB0mIMwSgJL7z0mzor4dY242cA0jjAJ1D60nfyuSFf4nUBqLyrt+ADjQ
         G9a54lolGlDUEGuDdxGQjJzKArEN/ts+Vd/0y74y5WHyRtDjE/0VzkuZon7yaZyQw/Iu
         65rA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="KxxQ/EOQ";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h83si4910936wmf.193.2019.07.04.20.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 04 Jul 2019 20:01:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="KxxQ/EOQ";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:Subject:Sender:
	Reply-To:Cc:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=clMDBr0VH7M11Amw0B3Ri/sIv+DBHpDPWFocL6b0RWI=; b=KxxQ/EOQrixPXe7WpCSxNyecNu
	ou7W9wMn/5tSGt9EiUzbFPZmmXzPOlV/lF0IdeZFJsJVc/dwXq8Iw/fPPvCcb+Yg3MDGptSBjJ+cS
	1IfnAHgJmmclULvexo48g0cubarcVOznsqZHs0UoglMrBPHeUHgRmtcan+WzIonpUSZ1IEcshWQAr
	P5ielI9z2OAukUBQWXSNGPFVRxCTPWIPE//nlqO8F+lLDa0j0Whf57onB5xYFzoCN3tK+BZJ+sGlb
	dPgpEPd+Lir60dUQ7L1iFTtdjksURL91i9fSoVwvvFwjz69tGIkHE2Ql9YiMumPw9/jLEN6pagl86
	WoQnlhXA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjETE-00077l-Nd; Fri, 05 Jul 2019 03:01:08 +0000
Subject: Re: mmotm 2019-07-04-15-01 uploaded (mm/vmscan.c)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <9cbdb785-b51d-9419-6b9a-ec282a4e4fa2@infradead.org>
Date: Thu, 4 Jul 2019 20:01:06 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/4/19 3:01 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-07-04-15-01 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 


on i386:
CONFIG_SLOB=y <<<<<<<<<<


../mm/vmscan.c: In function ‘prealloc_memcg_shrinker’:
../mm/vmscan.c:220:3: error: implicit declaration of function ‘memcg_expand_shrinker_maps’ [-Werror=implicit-function-declaration]
   if (memcg_expand_shrinker_maps(id)) {
   ^
In file included from ../include/linux/rbtree.h:22:0,
                 from ../include/linux/mm_types.h:10,
                 from ../include/linux/mmzone.h:21,
                 from ../include/linux/gfp.h:6,
                 from ../include/linux/mm.h:10,
                 from ../mm/vmscan.c:17:
../mm/vmscan.c: In function ‘shrink_slab_memcg’:
../mm/vmscan.c:608:54: error: ‘struct mem_cgroup_per_node’ has no member named ‘shrinker_map’
  map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
                                                      ^
../include/linux/rcupdate.h:321:12: note: in definition of macro ‘__rcu_dereference_protected’
  ((typeof(*p) __force __kernel *)(p)); \
            ^
../mm/vmscan.c:608:8: note: in expansion of macro ‘rcu_dereference_protected’
  map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
        ^
../mm/vmscan.c:608:54: error: ‘struct mem_cgroup_per_node’ has no member named ‘shrinker_map’
  map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
                                                      ^
../include/linux/rcupdate.h:321:35: note: in definition of macro ‘__rcu_dereference_protected’
  ((typeof(*p) __force __kernel *)(p)); \
                                   ^
../mm/vmscan.c:608:8: note: in expansion of macro ‘rcu_dereference_protected’
  map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map,
        ^




-- 
~Randy

