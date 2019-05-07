Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E07ECC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:35:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CDAF2087F
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:35:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="J3SFayp4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CDAF2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45F406B000D; Tue,  7 May 2019 01:35:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40F936B000E; Tue,  7 May 2019 01:35:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 326E86B0010; Tue,  7 May 2019 01:35:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F17086B000D
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:35:38 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so3467374pff.11
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:35:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UeEdaTfY8RS1P4E0//p21u8CwzJHpUuwTyQ57GqywBQ=;
        b=GmsQxXcfd++zqiqvatZLff3buNVO6lIN7yNCtDM94qMqC9TaHQT+zpIi1JgzsX06ZS
         1a1WXzLnLcef3qQPm0pAyMXezDcmjFEmLbMlWi+VSKS96GdkShdLcO8mCiOwilopPFdc
         3jyh0Ke199zbmx+Utlef6AX3baRSXsAaw6Tpl5/YztDkzs0awiG5heiNUepI07WxZ04o
         TSRT2h4aI4OV/8C7OuDDIArFBq90bLWSCCVc6tE6kw4B0vRizHBZCAJqfX1rS5257QkU
         goqLnxbDmScfCw1XP0Bu667b/F6XqeJl5+hULJ9v7JdWQYpVyeUvZIumvV0MvVB/EUXi
         GuXw==
X-Gm-Message-State: APjAAAVean1Y2Rtofp5xQtSpS8URi+4HJUPGFHDk9py5Sah+qSH3Xwa5
	C1XRrWTZ2yWR+bKQ5lszS/fUiZ4EHQudW6LARLHkmC3z1mbq3mUCRw2YR8RxB5j1OaG75eWnpfw
	BbRS+PGNvZVq4Yt+pjGJWqLucqqL6V4wTosXYU0IbOOJUqNF0Mbv3DL43ncRZ8J87cw==
X-Received: by 2002:a65:64d3:: with SMTP id t19mr37911336pgv.57.1557207338660;
        Mon, 06 May 2019 22:35:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyieaJNrnNjibkgUAKGYmJsylvbTAh5KCokL4I1Rd/ss2WkEOW8viNKLR/EWchONDPexaGW
X-Received: by 2002:a65:64d3:: with SMTP id t19mr37911280pgv.57.1557207337946;
        Mon, 06 May 2019 22:35:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207337; cv=none;
        d=google.com; s=arc-20160816;
        b=C0RHpT+JT3T0rG5vy+soaCkYUp3ICwILuy0W4YGKjky6k45rllLKp6/0r6OWEKd9fd
         YmgIcynwdjkiUttCajAr9CfKT8duhcOmLuZT5PBmSICUjuiV3vyvDeyxSNmwsuvy8fo5
         36gAgRLEnz5IzRy/qkRdeeHSzsOP/wSwCM6CGF3St3WxOOkYJSgZojAPi0/56XZioLK3
         hFdVtBfVRCMMSCMi1zdPvN8U2j9pDXpwCIUTyl7+8oFGa7ibBYKn7+tiuvSSA9FMY+kX
         eNW6BLUb6CXhwzv383CkpCCcaMibg3zNFQAueu6xrwkzo4BPn8FIxUGJq/PB7Uo3h79t
         kScQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UeEdaTfY8RS1P4E0//p21u8CwzJHpUuwTyQ57GqywBQ=;
        b=X8NgUMIBUKLH9brmKSG9FvIzj7CMAIMhqLKd23A45950AYjtJb+9GuNYdbZSQPWMPB
         eg6JaMoeWCJl8ZE61wGDI6OXR4pkjPcHT2Okk6bbO87m6Tw19a+irJC10yLh4lpY2GZP
         l4AUBVwj+PyHG6kAgWbXCP/3K3FT+2ytQX/kcdoWaY8evtpJygqrniCKrQ8JKMV1MTN+
         GZCS5mxYyWS4Vl3L0LsKBgF6Gem3VLXzp4naSHbqxqwfkIXj2mJKUHxQW7HDZj93VddB
         WAwz3hRCBIdGKRvWbt8e5c9+1dXyqO+Go7A+7YcM9RqpGTt07rMD4UjKJ/acE7LrA9zi
         e/HA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=J3SFayp4;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d31si18967929pla.89.2019.05.06.22.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:35:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=J3SFayp4;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1FB0E206A3;
	Tue,  7 May 2019 05:35:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207337;
	bh=wob8WZPaNjCLnvlLrtC58ILBzzqC6eYuSMmdNm1osRk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=J3SFayp4me1ZN7/DHCZcyWEcfPN+4w06BRNHA5plTneWWD6TCMIOzxqUi/DWpjmmy
	 R1I1YWn8B34LEOQueY96KRwb8QbMB6LmlJfS7YP1297NrGLiM4IlKmJx68Z6YqsM/o
	 QXr+rwgVW9S4biLxO0HgpGt8qa0JsPpyflwl6vf0=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Oscar Salvador <osalvador@suse.de>,
	Wei Yang <richard.weiyang@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Pankaj Gupta <pagupta@redhat.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 94/99] mm/memory_hotplug.c: drop memory device reference after find_memory_block()
Date: Tue,  7 May 2019 01:32:28 -0400
Message-Id: <20190507053235.29900-94-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053235.29900-1-sashal@kernel.org>
References: <20190507053235.29900-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: David Hildenbrand <david@redhat.com>

[ Upstream commit 89c02e69fc5245f8a2f34b58b42d43a737af1a5e ]

Right now we are using find_memory_block() to get the node id for the
pfn range to online.  We are missing to drop a reference to the memory
block device.  While the device still gets unregistered via
device_unregister(), resulting in no user visible problem, the device is
never released via device_release(), resulting in a memory leak.  Fix
that by properly using a put_device().

Link: http://lkml.kernel.org/r/20190411110955.1430-1-david@redhat.com
Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
Signed-off-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Wei Yang <richard.weiyang@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Pankaj Gupta <pagupta@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 11593a03c051..7493f50ee880 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -858,6 +858,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	 */
 	mem = find_memory_block(__pfn_to_section(pfn));
 	nid = mem->nid;
+	put_device(&mem->dev);
 
 	/* associate pfn range with the zone */
 	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
-- 
2.20.1

