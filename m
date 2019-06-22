Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF17AC43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 05:02:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAA0D20665
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 05:02:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAA0D20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F14A6B0007; Sat, 22 Jun 2019 01:02:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C9348E0002; Sat, 22 Jun 2019 01:02:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DF1D8E0001; Sat, 22 Jun 2019 01:02:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8CD6B0007
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 01:02:33 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o6so4685788plk.23
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 22:02:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=DavbICgu00nwUVeE6fz5Fu5xxoCHNHrqxo0oXSSB3Kc=;
        b=T0CzOde2UDYFKZLmdmlPl+AmA4SAkWNUg2FbPQhyGCyWcMn8uTb7z8NHilcU46SVtG
         QBUrSv9KhLjsABb6vZPJarO+Rrrpg383HwCFE/uaBxBPBIIVleNtQxK1Ha8V0kQ7hdp+
         /4XukSGnl7XDmG/0Btn1sb4/JgY6eO57tECg0Cazi/N3V0h//OvjiMNzkz45BlosH4C1
         dKjCGvrFQYj1skJBXLU0VEmLy0wYfRmD+BoxGOotAF/5yQAbnHcRl+R8Q1OHkNXpsX6/
         HFbbMzkjr0zcSCoIkhUsmp9/VZzfjycN0rEmeWRZAuCuVrXDktfs/+wcoNUilUI2cxnx
         cnSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAUeb/CkdX6u4wGoUyVG6Yy3xuApgj7aMjOvg62bV5Yvf+uDf87K
	pu23d2+ZSrZWRvOtf6LMAhd6Ax9N2CrcM155Zl8jQJ92UhbIulNMRcLUBZFNuK9ehRfCUBzSPFo
	+u8ldzJSjoCHXcyHgvInyMOczB8GKUc/4Y7z+T9BmVfYXEQ+ws7EBr9Ew5f6u9Kanqg==
X-Received: by 2002:a63:d218:: with SMTP id a24mr22396405pgg.419.1561179752788;
        Fri, 21 Jun 2019 22:02:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyaRQH90+DNQY1uC8oEOBO9TVAKczWr3/s/oHzQAuGxaoie6dnMUgpvvyQ7f8MuqT0mhgp
X-Received: by 2002:a63:d218:: with SMTP id a24mr22396367pgg.419.1561179752108;
        Fri, 21 Jun 2019 22:02:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561179752; cv=none;
        d=google.com; s=arc-20160816;
        b=nGLwk6iM+YWAUxP0gRYNcBCY2MR7tOp3lCrxybqAp5kSNvP2j9RYIe4NharRUsFaKj
         DkY7QnMuPor8thCozeSbqhpgyGVVrLxRZZgN0e4zTcO8xASc+v25wOHQhKEg5yKqbanG
         ao/4XAxeRGxqMac8ZwKbrLIdD4FJQwgEIEW7CfemP367bD/kcsvQqYhbc1aJU137R8iM
         xo62FTwC6ex4tVd634PvOS2xLg4GckYWh0kCoJsWn26tMD4Ha39X1nh2HHdWnaWf1NX/
         ulSFKAQPC11mGvpmmsq34yW/jcNIbxOVJhwmcLyXNG1GmPBpQY4SwasvsXbQvduKwXwg
         mDCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=DavbICgu00nwUVeE6fz5Fu5xxoCHNHrqxo0oXSSB3Kc=;
        b=sKy4gbKj4kI8TMz+N8QFouua9e79Di0CBGxLcOOKpvGzBguJwjZkYVqJbr6+N896Pk
         eY8hGBDSYM1FfodJP9JcarL4znmyVZhUTtHsK7CTYmYeI505G0HMXUXbb9XpAM4E/PqE
         GWZB/RPZ3i3jo7mw+4BKSr1ZErTZLGFZK1l4Pv7lB4XOGISWaAS53PlzOcsCaLc0/pZV
         smP89DEkMvSrEKFsi6yPudhIyuDy6nNI70H3OqeyhOkHoXE3b7Kk6eIFE7krulQxAYuU
         83j6FTjbC+kXkN3Xb9KD/NKrWV3DN3meKkuDOLcuw2grxe77b4u3GV2BTl6XgVxPGHVN
         3rCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id b191si4308012pga.589.2019.06.21.22.02.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Jun 2019 22:02:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 21 Jun 2019 22:02:27 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 3C55341723;
	Fri, 21 Jun 2019 22:02:25 -0700 (PDT)
From: Ajay Kaher <akaher@vmware.com>
To: <aarcange@redhat.com>, <jannh@google.com>, <oleg@redhat.com>,
	<peterx@redhat.com>, <rppt@linux.ibm.com>, <jgg@mellanox.com>,
	<mhocko@suse.com>
CC: <jglisse@redhat.com>, <akpm@linux-foundation.org>,
	<mike.kravetz@oracle.com>, <viro@zeniv.linux.org.uk>,
	<riandrews@android.com>, <arve@android.com>, <yishaih@mellanox.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<matanb@mellanox.com>, <leonro@mellanox.com>,
	<linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>,
	<devel@driverdev.osuosl.org>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	<akaher@vmware.com>, <srivatsab@vmware.com>, <amakhalov@vmware.com>
Subject: [PATCH v3 0/2] [v4.9.y] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Sat, 22 Jun 2019 18:32:19 +0530
Message-ID: <1561208539-29682-3-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1561208539-29682-1-git-send-email-akaher@vmware.com>
References: <1561208539-29682-1-git-send-email-akaher@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: akaher@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

coredump: fix race condition between mmget_not_zero()/get_task_mm()
and core dumping

[PATCH v3 1/2]:
Backporting of commit 04f5866e41fb70690e28397487d8bd8eea7d712a upstream.

[PATCH v3 2/2]:
Extension of commit 04f5866e41fb to fix the race condition between
get_task_mm() and core dumping for IB->mlx4 and IB->mlx5 drivers.

[diff from v2]:
- moved mmget_still_valid to mm.h in [PATCH v3 1/2]
- added binder.c changes in [PATCH v3 1/2]
- added [PATCH v3 2/2]

