Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9979EC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:06:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 601F221A80
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:06:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 601F221A80
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7AB98E00F5; Mon, 11 Feb 2019 11:06:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E27048E00E9; Mon, 11 Feb 2019 11:06:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEFF98E00F5; Mon, 11 Feb 2019 11:06:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A063D8E00E9
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:06:51 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 207so4524439qkf.9
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:06:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=Z1gHUmhJfw5kRS+Zul1SVYmZE1H42jFDyS+Ca8E/bH8=;
        b=PZxZ7J813kZT+dbCLj0xTROORh2+vU07UAIZ0cGJIBrOuqdJLpeBiMq54D/HbdmUmf
         s2If9/Wy1WzLli2L8sBoyl9TnzW+lN9yJ2GY1BrQG2nP3CR68uCKTW1Lyn/FrQyHNqOq
         E5m4bk/4LFBpM58h+Cu33z3J6KZIxYvbs07mpLNMIjCbx9pvAw95l+CcGBUqe/ybpRVX
         3fiyiGBcqou/dtzQ0vxuhVV8KRE7HZULaJ+vS2kLJsktucadNY0IYo9YhopQRIwU7e7v
         FrEmZ6yA1ZpKGXeonGLtMifC6OcDfAtsIlN5EVuVmTb9B4GgGXRfjyLWuC2udSem3KQH
         756A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaGm+oDzz2vepr7CUvQcUKjjyMJZt3vQgBsCdTm+wLAaozmbYh6
	mo18szhEAqJNJXVGX43SoZ0iTTgHUgulOyPqZQ/rAcow9F9nvu0pckJEBmfqW5VIqeRqyuxdwWE
	RKrAN84LXfIjtcwVXYTXvfaEBCWXKmlFWzF2psz1CWyAUTXhBGeMFFiHt7PFRfbmhQg==
X-Received: by 2002:ac8:191b:: with SMTP id t27mr15608481qtj.163.1549901211279;
        Mon, 11 Feb 2019 08:06:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY67bZNeD1flvrwL4SQ3+Drt4q8afu8GFbBi7X+xqDdT7nh7XWVmvrx88gM9+S4/68bKaUm
X-Received: by 2002:ac8:191b:: with SMTP id t27mr15608423qtj.163.1549901210619;
        Mon, 11 Feb 2019 08:06:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549901210; cv=none;
        d=google.com; s=arc-20160816;
        b=ttFGKWN3myhp0jhhNnljG1mes7JyLrVDbmtFk/6G+9+O+i6k03wK86RbsvbxeWZmy7
         XuwzwcNkpa59VL9JLftkdBbSs7zUEOPsSi7I/OBJhJ+eFs34VyfhzCrNZ/oipQRPn4oW
         mrBBgijuf+dtNFHk3jd8vn3MRpomrxVQ4fy41HnKID/j0F3sfu2L6UXkOV7C30z8PggQ
         hYsQglTz5TvDZx95A1uC4qWHhfnLhnqYpE4bgdBg+eRavdZJVqbzEqnsrkB11j2I5Zn5
         Plbogs79maVFCv+/nvYtv/Di5Jp9UqgUu6Fpb4M7W7OswZ6SJwS16M4sc2ZPpeAjhqMR
         jtfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=Z1gHUmhJfw5kRS+Zul1SVYmZE1H42jFDyS+Ca8E/bH8=;
        b=UDo66l250z/me/Vk06+EQoc33PwRBLkECesjt2MiuMHpygwzKmYeK0nktTckemeuS8
         4TQYkQ9Oqyu4FK1xhFnHscdtzl6TH8qoUmnEDYgGLR4bo8V/IUNSYlNKSWXmfAumhU+s
         EPMlAvth6zofPlaurcZ2WEKVk8FNn5tctoLgxWKoNyVTATRvHlPr491ekAdHMwzHqeWw
         /0kU89G5ASe9QCj+WrwVJN4TiE+V3CmaX63TETdyacsaNJNH06uhfcVYjYnHBq3YCRtO
         32teNMW5kSZ1JQHjJyLtaRWD9VVBxU3c1fkyx1LQVKDrDFLQQ6LQD50XV2wI2G8Q/G02
         t1Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w199si951947qkw.100.2019.02.11.08.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:06:50 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 766807F6C8;
	Mon, 11 Feb 2019 16:06:49 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0023D1850E;
	Mon, 11 Feb 2019 16:06:42 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id CD12330C2C6B3;
	Mon, 11 Feb 2019 17:06:41 +0100 (CET)
Subject: [net-next PATCH 0/2] Fix page_pool API and dma address storage
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: Toke =?utf-8?q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 11 Feb 2019 17:06:41 +0100
Message-ID: <154990116432.24530.10541030990995303432.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Mon, 11 Feb 2019 16:06:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As pointed out by David Miller in [1] the current page_pool implementation
stores dma_addr_t in page->private. This won't work on 32-bit platforms with
64-bit DMA addresses since the page->private is an unsigned long and the
dma_addr_t a u64.

Since no driver is yet using the DMA mapping capabilities of the API let's
fix this by storing the information in 'struct page' and use that to store
and retrieve DMA addresses from network drivers.

As long as the addresses returned from dma_map_page() are aligned the first
bit, used by the compound pages code should not be set.

Ilias tested this on Espressobin driver mvneta, for which we have patches
for using the DMA API of page_pool.

[1]: https://lore.kernel.org/netdev/20181207.230655.1261252486319967024.davem@davemloft.net/

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>

---
Question: Who of the maintainers MM or netdev will take these changes?

---

Ilias Apalodimas (1):
      net: page_pool: don't use page->private to store dma_addr_t

Jesper Dangaard Brouer (1):
      mm: add dma_addr_t to struct page


 include/linux/mm_types.h |    8 ++++++++
 net/core/page_pool.c     |   13 +++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

--

