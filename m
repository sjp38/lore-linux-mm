Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0F20C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:38:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89A2C218D3
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:38:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89A2C218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25C678E001A; Thu,  7 Feb 2019 00:38:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E35C8E0002; Thu,  7 Feb 2019 00:38:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D4B58E001A; Thu,  7 Feb 2019 00:38:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9C988E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 00:38:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u19so2019199eds.12
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 21:38:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Mvn+7Ov2TBjSz+s3X5LPzMuvQ402qJsd+yKYiOONTeE=;
        b=W9R0cChq/3X+fKWqD7fb4ig6L5kJqqHnWQX2jLtcuDIAvUN9c6nQgnUd9NwSVSmkM+
         xYoY6Mt4+bkRxBbS0jVv1rpOuI9syvMKXsJbyV3x93yvKMlZ3CgUre+mc7nkwIzUQXZP
         VYJVLvk7cH3Sby4QLbNf9QesGjGljoS8jbApvqjlQtfjbdg8Qe7xJh+D8DDQXvHz5kit
         Cz2h87WnJ6kfGq66DOIm/+1H/NbNdxZXoPhKjFhM/sDUKgvWOH6Cc+Z0H4k9dUTuIBsG
         /pPkXmubzb/sOizlj1ORA9ey8piVl0fQYSTdiAPMspLm0DeCQEIQaBfZf2kAhzFDuHIZ
         spxg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAubBMaPjEIDtY1xCqXdvVMGXn9I69SnkgcdIQGWz3UWiOOZYH5c/
	IGRWtzxTYf+Ck5UoczcxVH6R6ISGCzz8NaueIgJGOBHQ8jrrdpxnwhopnc74fxPKYaP8qM4E1hR
	xzCTbhqrKxCiP64i18cAtPBAf3lJYfurIWCabDL4guCJzqXzPAitc+9miDpopHHw=
X-Received: by 2002:aa7:d35a:: with SMTP id m26mr10702936edr.244.1549517888256;
        Wed, 06 Feb 2019 21:38:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZEG6X/akN/gllkAOEvKwtOlWFkBKeaOZWFtwdVQw+I0IJe5vfg1E/6uiI4JFFcNfpm362U
X-Received: by 2002:aa7:d35a:: with SMTP id m26mr10702890edr.244.1549517887369;
        Wed, 06 Feb 2019 21:38:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549517887; cv=none;
        d=google.com; s=arc-20160816;
        b=tZFwNbxN1Gf5eUtPfts0KD3URt99xOOWsIOBCpSkNm4t0+MuBA61TEsOtHVawKMi7i
         hmoFVidhYbBJhhIuuz0gSLRWQgOwHzA5YxfzIzxobzJ4pYgb/QrtNsdI8YE+HJPhtPHT
         Faw07XKEK6wjUuXwSosVzh8fGkjlCFJZejRKNN3OOUNkzXZt934Dafylow4e/mCyyaQi
         IhaWC52DmNPIHrI/GD2mdwpUSgRUX8+YtePE0ifU+0yYVJCIILAfuv9EL24+45ZgxRah
         TmYzPubMeDoIqNrDThpZevRPnSrnxtMVUCIl/uAF8lO/iH8809BrR7pSWo5pl3I8qSsc
         XndQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Mvn+7Ov2TBjSz+s3X5LPzMuvQ402qJsd+yKYiOONTeE=;
        b=o+y8Yk0SIxXpuQhGOXGKixm/ZhPIiw+wr17SrKppooN4HPRyrcJrxtjvSnc23OlAn5
         Lcppg0s7EcZ1bl/bfjn0RE9HB+sebJgLIEyA8ceBwRj6poYjdGaD4TnXxq6R6oNJOHbi
         HEY7orf0BKUWKQupxbhJnIODb0h1eh9v00RxhSmOrXziL8Lbae1UYZikrxEqi/5ABH26
         3lrnPUOo/k2iwLBJTRkfDmAgGC48wh1yCYk2BnI372Ay7qJqAXJn8Uq3suxpDJKtlfyc
         Ojt8Qjo4UYpBvm8v4j80UqCtj+Ed3+3vQ+e6fR//MwMCdaJ/A7+EjP5rr0P4zXEh3UgU
         NEZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id d1si603033edd.122.2019.02.06.21.38.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 21:38:07 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 07 Feb 2019 06:38:05 +0100
Received: from localhost.localdomain (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Thu, 07 Feb 2019 05:38:00 +0000
From: Davidlohr Bueso <dave@stgolabs.net>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	dave@stgolabs.net,
	linux-kernel@vger.kernel.org
Subject: [PATCH -tip 0/2] more get_user_pages mmap_sem cleanups
Date: Wed,  6 Feb 2019 21:37:38 -0800
Message-Id: <20190207053740.26915-1-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000140, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Here are two more patchlets that cleanup mmap_sem and gup abusers.
The second is also a fixlet.

Compile-tested only. Please consider for v5.1

Thanks!

Davidlohr Bueso (2):
  xsk: do not use mmap_sem
  MIPS/c-r4k: do no use mmap_sem for gup_fast()

 arch/mips/mm/c-r4k.c | 6 +-----
 net/xdp/xdp_umem.c   | 6 ++----
 2 files changed, 3 insertions(+), 9 deletions(-)

-- 
2.16.4

