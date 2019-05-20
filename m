Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB67EC04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:17:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5624720815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:17:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rWn+EsvA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5624720815
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B40BE6B0003; Mon, 20 May 2019 13:17:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF0FB6B0005; Mon, 20 May 2019 13:17:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DF936B0006; Mon, 20 May 2019 13:17:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65E9F6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 13:17:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x13so10167248pgl.10
        for <linux-mm@kvack.org>; Mon, 20 May 2019 10:17:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:user-agent:mime-version;
        bh=5elJHjWFjcHkVboxjAYPJGmbdCVMyqMVQma7x79oi5w=;
        b=oCoUjp3eB9LRalZXD4rIoAzoeouCH68dMzt17z7enzka5vlCxWOeU5UMmvmQumQd2g
         i94lfmkkxcW9JDCq1mpRa19uUgoKId+tMsJl1l/C83Fx9RX9SMlGtnequ7f4uTtn0FQE
         19ulFTVXgUgf4hDjnj/mn5YULWR3rfecp7q2YrOQfXtmJbHVi01NSBKBvjlI3iypw7q5
         /SrmkUQdKHRTV00pY+GFHmIVM2Hp9iEqBwuoObmbPxFGQbqPGDD+atjwXtZjRCNLAnWt
         W//O2+GQ9oatjhFwUitQF4NYIUAuoO+Lyn8UNvd/8DdhTRNQk7aZIP324WuL3qTsP0Q1
         09+w==
X-Gm-Message-State: APjAAAVOeVTAUQ1Sz1pqaVKhjLuuu3K/dnX/J6EdyoE0gbvMCKXaTL2B
	Ztq2dMYM4FJFqnO6uzaqqtXDVZ8I0Cv3ar8dMwSDWzIT0Kjjd0vOfnE8LKvM9wZX2Le7EoPQpVC
	QGLRIe+CQK434TkEl/+7RYW6ei4rjvC1a8CbTBRESH7TJjpjjUxgf4mqqT0xaBd3aUg==
X-Received: by 2002:a63:3:: with SMTP id 3mr75571373pga.360.1558372630965;
        Mon, 20 May 2019 10:17:10 -0700 (PDT)
X-Received: by 2002:a63:3:: with SMTP id 3mr75571310pga.360.1558372630295;
        Mon, 20 May 2019 10:17:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558372630; cv=none;
        d=google.com; s=arc-20160816;
        b=Z847EDcTx1K8R6XRBMPpnEvgXdzjX7pW9ij4m85NufV9P8Xpdkh/V7sPF7pW2lKRiV
         wD478xvCrNXh/QfpYIs8uT1mAJY+jp9N/mUm0M5h53LFCT8nDu3q7XxuW9/00eDUB6ku
         lsB1jwVM98BlNCzaTd/UJTYJA/knUAZhHE/cPQJyCVPgFcm4ZMLvLbqN/l4o+ujRXNei
         oQBSJ7iD6DiVrIV84e7joEnGfpQw0mNfcmyNildh623SG58OR2akomnaX1fiac2JRofD
         y8MREnwunApj9q0AEThMQz9LlqLSyMU/pAUYNBppd6wyngtnUXLFxKAiuMiVr6+U7RBt
         oL9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date
         :dkim-signature;
        bh=5elJHjWFjcHkVboxjAYPJGmbdCVMyqMVQma7x79oi5w=;
        b=wuQY8F9HWkdYh/sz2wcJbOCnlDfZcXVHOcpUd+0jGkxkTCK7ni7bX87zE2DUcQi47q
         Zn6BB7PQaYKIhJ+tzqhtaKTLMrR+APQqqsuM0/V7Z0A4EXYbchm/STbQug7N01wP+aZX
         ACCZMBu8AHvJb3o+xEPUIH3MYoiiqTBFWAzKo3OxGZTikI1JKNXj42TMZMioD/ApRs3a
         5DeB0M6SmfooydFZBXcuREl9rymokLP4+vrpT4gYTyRRNVuBm3IU2XNwIDG84Vy54WXX
         bRjHWFR+jAuiLl06Xs4aK47NxoiE7rfEVFfTi2ChwyABcec3njCZNzTvKv8++Ri/VX+W
         IG3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rWn+EsvA;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j38sor20014591plb.12.2019.05.20.10.17.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 10:17:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rWn+EsvA;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:user-agent:mime-version;
        bh=5elJHjWFjcHkVboxjAYPJGmbdCVMyqMVQma7x79oi5w=;
        b=rWn+EsvAorjVENwh7JlIbDVc57R3JWoqjR73qwRihQZiBnK+YwG0K6l1wYwLD8rFPp
         Z6D+3/fdsOX87p9owDzg6F4IbYUuxR0DU7jiJYpYmKP/x0g/aC6C+y9D6XguDr2CVtNu
         ldjLIQnx2Dk+vzONRFJskS4t+DH5N6uuoNSYPNK/gz5hAWYPPr0jWMbDOlLqaaVZdaq6
         LqV4vIkHgbK/6SIu9wGtKbtABkTv7/GZOOdmGDYirNW6X56x6KdapnSlqk2lXnTLHJIg
         BTRqKv7qCurs/xhLh81Ohe6/ZwjUeWiPDlSfqlihmxhnyJGkpsH199xLbUhAiaZEDETm
         mvJA==
X-Google-Smtp-Source: APXvYqyFCPpqDFtqCO69hkM+WWU7MeJZkOtx1/BENRwuW7Ovz9W3qeVavkcieYfqDUbQl7zah2+kYg==
X-Received: by 2002:a17:902:82ca:: with SMTP id u10mr63981326plz.231.1558372629432;
        Mon, 20 May 2019 10:17:09 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id e10sm37445962pfm.137.2019.05.20.10.17.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 10:17:08 -0700 (PDT)
Date: Mon, 20 May 2019 10:17:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, 
    tcharding <me@tobin.cc>, Christoph Lameter <cl@linux.com>, 
    Vlastimil Babka <vbabka@suse.cz>, penberg@kernel.org, 
    iamjoonsoo.kim@lge.com, Al Viro <viro@zeniv.linux.org.uk>, 
    Linux-MM <linux-mm@kvack.org>, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: [patch] mm, slab: remove obsoleted CONFIG_DEBUG_SLAB_LEAK
Message-ID: <alpine.DEB.2.21.1905201015460.96074@chino.kir.corp.google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_DEBUG_SLAB_LEAK has been removed, so remove it from defconfig.

Fixes: 7878c231dae0 ("slab: remove /proc/slab_allocators")
Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/parisc/configs/c8000_defconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/parisc/configs/c8000_defconfig b/arch/parisc/configs/c8000_defconfig
--- a/arch/parisc/configs/c8000_defconfig
+++ b/arch/parisc/configs/c8000_defconfig
@@ -225,7 +225,6 @@ CONFIG_UNUSED_SYMBOLS=y
 CONFIG_DEBUG_FS=y
 CONFIG_MAGIC_SYSRQ=y
 CONFIG_DEBUG_SLAB=y
-CONFIG_DEBUG_SLAB_LEAK=y
 CONFIG_DEBUG_MEMORY_INIT=y
 CONFIG_DEBUG_STACKOVERFLOW=y
 CONFIG_PANIC_ON_OOPS=y

