Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3792C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 05:13:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 540B4218A1
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 05:13:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 540B4218A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A79C78E00AD; Wed,  6 Feb 2019 00:13:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A27A68E00AC; Wed,  6 Feb 2019 00:13:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 917358E00AD; Wed,  6 Feb 2019 00:13:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 45CB78E00AC
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 00:13:44 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id y8so3844585pgq.12
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 21:13:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=XftLi6UM73D30Ljii1WGGR07gDUtumlIuhHEzw7sPzY=;
        b=VQijTzFQKDe9jU+9blpu+cvQYnpLepMpdy36oW+Fk5CIsTlEd0pneMIo236Cvianxa
         yQ04P6JVTVK1GKLeNcjmcI8+LWOUbWfaUpggX3C8sF1q2xnI6Oi0KiCs5GEnGTbYx/1z
         jXQ7cjNyay4dLODv2yZT9U62/c58XNr2AAlZHSHb2AwBUvcwGQafTgHsIbMyCpDbozNT
         GlzFKxs1tMzYpxuO8VseTM4zffRk4d1lfCeVqT3owJqWtvkMuBTf150Mg3DNlpspNvbk
         MOpcGV0QKxuVWx9ouNr76+z2Y90eWzBqD/5g3O/wRJRC64sKe9fVmYJWprtQ/qEXsqiS
         QT2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: AHQUAuYamyQH8YGawSwNoDCDseLeEow+oYjFJrSX6ThSo2mDcgt4WmOD
	UizL3lS7qbAdF6i2+x8u0LHwyUqhe4x/a5wZCks3lbntTzxcmkZ7RUzrwIIwwdovmCf7Dg8HYrZ
	0ocosJhRKOBOrTcE7pl828sdBhs0IvDboX11l9MRcumsszlWvF02b5YNmaGDuWTPp9g==
X-Received: by 2002:aa7:8d57:: with SMTP id s23mr1184468pfe.237.1549430023913;
        Tue, 05 Feb 2019 21:13:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IarSgQM4UjBbMvPTdTCphU7DzI14z5sZEw5B4WAU9TK2Ol6FOQm/0HsLYm6y8vOYZb2Q4Ie
X-Received: by 2002:aa7:8d57:: with SMTP id s23mr1184405pfe.237.1549430022859;
        Tue, 05 Feb 2019 21:13:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549430022; cv=none;
        d=google.com; s=arc-20160816;
        b=EShlooAnEs9m/KYsthh61aKGZk2YYYdf9JFyHbE2Z5h74eMIXex8N8MgrHIot6Ijk1
         QLeesXUP+9ELbzJdxEJwJNJmqpuUKHkvCViZwEd8UYFiO9Ik8Gp0yn3kJtQW9n0AKS7r
         8iN6IhZCXi0CSEWEZXQ6SF3ZGASAy0Hljj9YxJot0tzQXs3GiCr6MovT9iQA5Gv1cGLk
         33QyLwwbmxloE8yhghuJ9PyEjlgdgiBEmn8KJk2uAvnPrpOUeOIjjAC686O/lMGjIU6L
         uUUoy9x9deTBmmzzfY1HU91TuZo1AKvBr+qZo7JJcHuqym6x0xyo/7rqJlHpffNdEiDA
         p+hQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=XftLi6UM73D30Ljii1WGGR07gDUtumlIuhHEzw7sPzY=;
        b=qfrbcRKxRrr1ALIH7txuyBKSObr4cWgCDWXXn1IXvq2PuSWVN66ZDvTw3ArK2bQejI
         udPMHZN5F3WaD6K0u9zpeEH49tg3tPoWyjY0jvzaDjCVuRqwQKJRRWDZ03ey79eb1cuL
         pnmZuxEPMXpvZrupXJpnvf2B+PZKgGZxnikJMGI2Ip2MrJ+w8QxKdRm579Tndo6ueyio
         aomxAEFrsT/Sa4thqJ3ngL9jVwrk5cr92+cDEoV1b2Z8ZOfDNYDZRQIrSlOsnja9UF6R
         xP9bilt9NlYTMIpB+wKjqGBjnPzYf/jMs1+XN0Q3lZtywK8K6SKVM3SvyvMxF2ZaSYZa
         o3Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id 38si4672550pgx.460.2019.02.05.21.13.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Feb 2019 21:13:42 -0800 (PST)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Tue, 5 Feb 2019 21:13:07 -0800
Received: from ubuntu.localdomain (unknown [10.33.115.182])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 965EE413EF;
	Tue,  5 Feb 2019 21:13:41 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Arnd Bergmann <arnd@arndb.de>, <linux-kernel@vger.kernel.org>, Julien
 Freche <jfreche@vmware.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason
 Wang <jasowang@redhat.com>, <linux-mm@kvack.org>,
	<virtualization@lists.linux-foundation.org>
Subject: [PATCH 0/6] vmw_balloon: 64-bit limit support, compaction, shrinker
Date: Tue, 5 Feb 2019 21:13:30 -0800
Message-ID: <20190206051336.2425-1-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Various enhancements for VMware balloon, some of which are remainder
from a previous patch-set.

Patch 1: Aumps the version number, following recent changes
Patch 2: Adds support for 64-bit memory limit
Patches 3-4: Support for compaction
Patch 5: Support for memory shrinker - disabled by default
Patch 6: Split refused pages to improve performance

Since the 3rd patch requires Michael Tsirkin ack, which has not arrived
in the last couple of times the patch was sent, please consider applying
patches 1-2 for 5.1.

Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: linux-mm@kvack.org
Cc: virtualization@lists.linux-foundation.org

Nadav Amit (5):
  vmw_balloon: bump version number
  mm/balloon_compaction: list interfaces
  vmw_balloon: compaction support
  vmw_balloon: add memory shrinker
  vmw_balloon: split refused pages

Xavier Deguillard (1):
  vmw_balloon: support 64-bit memory limit

 drivers/misc/Kconfig               |   1 +
 drivers/misc/vmw_balloon.c         | 511 ++++++++++++++++++++++++++---
 include/linux/balloon_compaction.h |   4 +
 mm/balloon_compaction.c            | 139 +++++---
 4 files changed, 566 insertions(+), 89 deletions(-)

-- 
2.17.1

