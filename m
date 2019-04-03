Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F225C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:12:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4708920882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:12:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4708920882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7A606B026D; Wed,  3 Apr 2019 00:12:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D29B76B026F; Wed,  3 Apr 2019 00:12:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C18DE6B0272; Wed,  3 Apr 2019 00:12:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9557C6B026D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:12:26 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id c21so5959357oig.20
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:12:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=Hlc49p4j4wJfcgtD04rAu2J6UwDtSrmPflFFBjh8eQY=;
        b=afd2naoM4qBrXMMX6M4OwVIUGRAnxVIrVG6Nmzm7GRpGx6/PLEvMIpdSfqTriY/Hk9
         ou3Rp9cPPbfJs7hkCxM11BdW5bGWz5t2TmJ1dBok7PlTc7hZuNK10JbVUmVzsa8BOWYp
         cBtZYROTeudsjNATwAtLHuJR03JYcH4QXjKug1KY9mD2/22c6WMDAH5p4WtGWyk/BC4W
         0lCqQNUztD54MkMlunpnqCAVB1eVLEsnn5uk2UfuWztcu0P3e/1dUp3eVQHayVBJrEsL
         20EJATQfYhMV6tPdAqAy1ihdYL1lqZcrYXpsNlrEFf6zpj4fVzRWgcZ/Qe1N+Gf9fy+G
         hBug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
X-Gm-Message-State: APjAAAWpoF+FU56JhYK7TpwWzOtxrmb7ElLI+VUqIogx9LEV0eoKrDt9
	BP9os+VoSKV1MaZg1tXNc+20mG8GrSEO1vuFxI436VyHGHzpK+O2bhVISD2sRO/xmQogPuZH6wE
	4s8MHxzHUk93AnhCkpcrEAl++2Yzb1BFRakUn/SfrAkhaliFQpHkxuYropOC8c3KtqA==
X-Received: by 2002:aca:d7d5:: with SMTP id o204mr333282oig.23.1554264746261;
        Tue, 02 Apr 2019 21:12:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDkhfNbQreSq5suQJ+xNN/jqWx3X2Wc4ZY5qAWc/KSujvAHay+oD8WDPshw7ZJSDAShio2
X-Received: by 2002:aca:d7d5:: with SMTP id o204mr333255oig.23.1554264745475;
        Tue, 02 Apr 2019 21:12:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554264745; cv=none;
        d=google.com; s=arc-20160816;
        b=YqjQYVcUUI/K1X6ZPjk271XP7WYShmbKCYe8+SZP/VCmzCn7ufuJDLM1sTIOfKggfR
         HrtHpwGcU8Jt/4VabAkTn/oukqMMflbbSQ2nY0+CIkwd/d8V59z7ohPCnZYmf7Kg6NQh
         7tg33NUn2FHSrxa8c9P84B0qqLmhcptO2Eu+6bVk/ua/qHLJomG+d18Zqvs58JWzXBYj
         2kp86Gxg4GP7LR/mUKBMYgquyGwmGZtUNoonTVWQlZpdXFcklX/BSNN87NSMKNUs4Q3i
         huZx9zJcr4KW2hXUpZI5pB+zjjzNrCt229BlXskdLzGsf0Yi7tzTGNAy6Pnt9fQqOHtr
         XtPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=Hlc49p4j4wJfcgtD04rAu2J6UwDtSrmPflFFBjh8eQY=;
        b=dLggEjll1pgE3pEQNzTfdgdIvlgTuYPBA2Dk6Fyk6mygY8zU0ta2krObHCdM8vTxHh
         dcKZVV8p4VYLmp7UidHCilCa/KBxuOLaXaDuUVzBa8tlwEm0y1JvWpo5j/oYAqpvw/RL
         PnP0+dea5xkqpUyYkWOW2UnT1A5LmT5SVpMkn5eKiOPMJ4t1LdV7+1l0U7K0TwraI+rW
         0x0i890p7NVj2iy7pP4URuazReGaG4j/U/qq7oWckgaP/kya+InYohspk25F+P0Pm5SI
         b11o7/t7P91+T5qAr7Ythu5Yf4HPStJZdRcgjAN3JezO6y68ASeDjOIW4l8o81tOd45s
         DiLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id o82si6596524oia.0.2019.04.02.21.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:12:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [10.3.19.210])
	by Forcepoint Email with ESMTP id C2D53B5303F3517EEFF6;
	Wed,  3 Apr 2019 12:12:20 +0800 (CST)
Received: from huawei.com (10.66.68.70) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Wed, 3 Apr 2019
 12:12:14 +0800
From: f00440829 <fanglinxu@huawei.com>
To: <osalvador@suse.de>
CC: <akpm@linux-foundation.org>, <fanglinxu@huawei.com>, <linux-mm@kvack.org>,
	<mhocko@suse.com>, <pavel.tatashin@microsoft.com>, <vbabka@suse.cz>
Subject: Re: [PATCH] mem-hotplug: fix node spanned pages when we have a node with only zone_movable
Date: Wed, 3 Apr 2019 12:06:07 +0800
Message-ID: <1554264367-14900-1-git-send-email-fanglinxu@huawei.com>
X-Mailer: git-send-email 2.8.1.windows.1
In-Reply-To: <20190402145708.7b2xp3cc72vqqlzl@d104.suse.de>
References: <20190402145708.7b2xp3cc72vqqlzl@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.66.68.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> will actually set zone_start_pfn/zone_end_pfn to the values from node0's
> ZONE_NORMAL?

> So we use clamp to actually check if such values fall within what node1's
> memory spans, and ignore them otherwise?

That's right.
Normally, zone_start_pfn/zone_end_pfn has the same value for all nodes.
Let's look at another example, which is obtained by adding some debugging
information.





e.g.
Zone ranges:
  DMA      [mem 0x0000000000001000-0x0000000000ffffff]
  DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
  Normal   [mem 0x0000000100000000-0x0000000792ffffff]
Movable zone start for each node
  Node 0: 0x0000000100000000
  Node 1: 0x00000002b1000000
  Node 2: 0x0000000522000000
Early memory node ranges
  node   0: [mem 0x0000000000001000-0x000000000009efff]
  node   0: [mem 0x0000000000100000-0x00000000bffdefff]
  node   0: [mem 0x0000000100000000-0x00000002b0ffffff]
  node   1: [mem 0x00000002b1000000-0x0000000521ffffff]
  node   2: [mem 0x0000000522000000-0x0000000792ffffff]

Node 0:
node_start_pfn=1        node_end_pfn=2822144
DMA      zone_low=1        zone_high=4096
DMA32    zone_low=4096     zone_high=1048576
Normal   zone_low=1048576  zone_high=7942144
Movable  zone_low=0        zone_high=0

Node 1:
node_start_pfn=2822144  node_end_pfn=5382144
DMA      zone_low=1        zone_high=4096
DMA32    zone_low=4096     zone_high=1048576
Normal   zone_low=1048576  zone_high=7942144
Movable  zone_low=0        zone_high=0

Node 2:
node_start_pfn=5382144  node_end_pfn=7942144
DMA      zone_low=1        zone_high=4096
DMA32    zone_low=4096     zone_high=1048576
Normal   zone_low=1048576  zone_high=7942144
Movable  zone_low=0        zone_high=0

Before this patch, zone_start_pfn/zone_end_pfn in node 0,1,2 is the same:
  DMA      zone_start_pfn:1        zone_end_pfn:4096
  DMA32    zone_start_pfn:4096     zone_end_pfn:1048576
  Normal   zone_start_pfn:1048576  zone_end_pfn:7942144
  Movable  zone_start_pfn:0        zone_end_pfn:0
  spaned pages resuelt:
  node 0:
    DMA      spanned:4095
    DMA32    spanned:1044480
    Normal   spanned:0
    Movable  spanned:1773568
    totalpages:2559869
  node 1:
    DMA      spanned:0
    DMA32    spanned:0
    Normal   spanned:2560000
    Movable  spanned:2560000
    totalpages:5120000
  node 2:
    DMA      spanned:0
    DMA32    spanned:0
    Normal   spanned:2560000
    Movable  spanned:2560000
    totalpages:5120000

After this patch:
  node 0:
    DMA      zone_start_pfn:1        zone_end_pfn:4096    spanned:4095
    DMA32    zone_start_pfn:4096     zone_end_pfn:1048576 spanned:1044480
    Normal   zone_start_pfn:1048576  zone_end_pfn:2822144 spanned:0
    Movable  zone_start_pfn:0        zone_end_pfn:0       spanned:1773568
    totalpages:2559869
  node 1:
    DMA      zone_start_pfn:4096     zone_end_pfn:4096    spanned:0
    DMA32    zone_start_pfn:1048576  zone_end_pfn:1048576 spanned:0
    Normal   zone_start_pfn:2822144  zone_end_pfn:5382144 spanned:0
    Movable  zone_start_pfn:0        zone_end_pfn:0       spanned:2560000
    totalpages:2560000
  node 2:
    DMA      zone_start_pfn:4096     zone_end_pfn:4096    spanned:0
    DMA32    zone_start_pfn:1048576  zone_end_pfn:1048576 spanned:0
    Normal   zone_start_pfn:5382144  zone_end_pfn:7942144 spanned:0
    Movable  zone_start_pfn:0        zone_end_pfn:0       spanned:2560000
    totalpages:2560000

It is easy to construct such a scenario by configuring kernelcore=mirror
in a multi-NUMA machine without full mirrored memory. 
Of course, it can be a machine without any mirrored memory. 
A great difference can be observed by startup information and viewing
/proc/pagetypeinfo.

On earlier kernel versions, such BUGs will directly double the memory of
some nodes.
Although these redundant memory exists in the form of reserved memory,
this should not be expected.

