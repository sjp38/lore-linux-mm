Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87A78C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 05:06:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 359DC25F8C
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 05:06:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="RI7EzQb/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 359DC25F8C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 897956B0278; Thu, 30 May 2019 01:06:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 848AA6B0279; Thu, 30 May 2019 01:06:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 737196B027A; Thu, 30 May 2019 01:06:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9286B0278
	for <linux-mm@kvack.org>; Thu, 30 May 2019 01:06:14 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b127so3734056pfb.8
        for <linux-mm@kvack.org>; Wed, 29 May 2019 22:06:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition;
        bh=471RtXe1UXBWmO9V0tHQdL3qmf1+11dEHQ7BpybB+PE=;
        b=cm+m6XJBSMFcKRm3IsTEHtSQSpaUyvGyjjdivcYettvNxIs70Cgas+s7GTb1NFYh0r
         ESIQoKjN54jatthm0sjbhoEdRBZXTQY+i98bto/NuxKEvOUL4J/xXGY7uuxtb3vIRPDE
         qPGd71ZM0ubiM+B4VinWbEP7wPhx8z1v5Zox0fAXnO7WDtaR016vJSqXsmzhCqwM6WuQ
         BdbBRxnERakR4VHNOxe/ne8nkhp9ZQ7wDAROwuIKkyAn7/vfYm+90KRxNk1ncj/osC5d
         6qrFjltsQ6Vxm6oznaL8yRApytAv8wU7v33rYicC5MGIpnhw72nN/dYDS6ptZJr3VN5h
         nXKA==
X-Gm-Message-State: APjAAAVhUifV6jFgdFYPH8Xa0Hsq3VfD1X+DZFOxm3/i3d0Op6EZchNK
	f96T49EP34NxJHn6r+S4m3H5WA3qoH+CAQnVAG7m2o4Ep22ne/VI+ZJOidzJOrNE4czWuZPV6rN
	AuWBmK+P9YyqrdsLZrFpZ9l41rWIaIChhRWPMyGS2WfzkHklWmRmP1mGwU2hepLYymw==
X-Received: by 2002:a17:90a:aa88:: with SMTP id l8mr1720414pjq.65.1559192773836;
        Wed, 29 May 2019 22:06:13 -0700 (PDT)
X-Received: by 2002:a17:90a:aa88:: with SMTP id l8mr1720362pjq.65.1559192773077;
        Wed, 29 May 2019 22:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559192773; cv=none;
        d=google.com; s=arc-20160816;
        b=PjWhWmQC/Dy/54UNdxCjrxN1BoZeM89oFqkmE3s42OSboczlsms6HWkwAB2OVf3wRo
         uSgC0m8ZGLi3nYnjb3Wuz+M1OW5lLbSmhW9uGlawr2uL+utYW8ek6QnsZ2gQIACIE6/M
         ReaeyE/qXvT5+r2QBDd3sxxrB4LVN+aepw1qOJps33hadQxjg97OzuOcSG+QvpqwI04n
         WtGGGlNxmW+nupLVi8wnPWX22M6MP6A3dbNuAtDu3u6yCUTkjOuV5XnRgE4utKHJHhOV
         G0wt0Pba6m+D9uKJvLm+K8v5eoq3bB5yzDfHoI1QV9tA2AL5uEwKoXylWPoCMCZzvid1
         sIPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date
         :dkim-signature;
        bh=471RtXe1UXBWmO9V0tHQdL3qmf1+11dEHQ7BpybB+PE=;
        b=mvzbEjT4oztARiy0GxH4C9cGP0lxYJea7txk6J/OMEqqyA+PdF5ONK1WZWmf3hEoBh
         AZVZDpJQW4zRwvhD9FlBPMURFBHcBxq/mCgkamWY5+Glz8z0KD0B4ayXc9SZ3/7fYLhp
         qya+vpKjiiwZm8sQmziqNQN0WhzxrFoB+yzlEqvuIaaewUaGASJ2pvM0jZSIBr9Hih5o
         or3sOaA5Ro7tdbUJgggTCdI+gLE01FU7JSwemQUG80A4tIVxFTLGWPC1OoBibj9szFJW
         2wwJFSNpdXWqNZcsqs6FugmjmPWuf9y9lWTB6Ss3uloIrf8XH0FECtp27plonCumWHcg
         BEHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="RI7EzQb/";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o123sor1975398pfb.5.2019.05.29.22.06.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 22:06:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="RI7EzQb/";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition;
        bh=471RtXe1UXBWmO9V0tHQdL3qmf1+11dEHQ7BpybB+PE=;
        b=RI7EzQb/M/CcAHTc8S4WrXUzCm+WIGyI3SftLZJJnbXwcZhXORjprHP60+53pX00Ey
         rcnOE74/AAiNr3M3419C6MljaHWFaEriztx1L+8vNrMDfrLJwz6yRWbFvK0Sx2ZI6QzW
         2/KfLiMzKdxmhWoepoiZrWSyFnJgeaFSaRnyA=
X-Google-Smtp-Source: APXvYqwX7bem3flmwMHVAUUo8QOnTzGP+RQylHxKnMa94V6FQv9HForlf84NLP6f2VgM4WxUoPrKyA==
X-Received: by 2002:a62:b40a:: with SMTP id h10mr1908195pfn.216.1559192772734;
        Wed, 29 May 2019 22:06:12 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id h7sm1428273pfo.108.2019.05.29.22.06.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 22:06:11 -0700 (PDT)
Date: Wed, 29 May 2019 22:06:10 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH] mm/kconfig: Fix neighboring typos
Message-ID: <201905292203.CD000546EB@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This fixes a couple typos I noticed in the slab Kconfig:

	sacrifies -> sacrifices
	accellerate -> accelerate

Seeing as no other instances of these typos are found elsewhere in the
kernel and that I originally added one of the two, I can only assume
working on slab must have caused damage to the spelling centers of
my brain.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 init/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 4592bf7997c0..2dfb3d7f8079 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1750,7 +1750,7 @@ config SLAB_FREELIST_HARDENED
 	help
 	  Many kernel heap attacks try to target slab cache metadata and
 	  other infrastructure. This options makes minor performance
-	  sacrifies to harden the kernel slab allocator against common
+	  sacrifices to harden the kernel slab allocator against common
 	  freelist exploit methods.
 
 config SLUB_CPU_PARTIAL
@@ -1758,7 +1758,7 @@ config SLUB_CPU_PARTIAL
 	depends on SLUB && SMP
 	bool "SLUB per cpu partial cache"
 	help
-	  Per cpu partial caches accellerate objects allocation and freeing
+	  Per cpu partial caches accelerate objects allocation and freeing
 	  that is local to a processor at the price of more indeterminism
 	  in the latency of the free. On overflow these caches will be cleared
 	  which requires the taking of locks that may cause latency spikes.
-- 
2.17.1


-- 
Kees Cook

