Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56C96C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:52:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB36F20823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:52:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB36F20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 435F58E0003; Mon,  4 Mar 2019 03:52:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E4B68E0001; Mon,  4 Mar 2019 03:52:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FD158E0003; Mon,  4 Mar 2019 03:52:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7AFC8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 03:52:11 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m25so2302517edd.6
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 00:52:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=P3IxFkulsP4nAN+yFpECaeeODNWR87CMqbLg3kC33t0=;
        b=CvRbI7IFo9pTYnKnSVvaaurS9eZZpVBTYVSrv8gTH2WOli8HeKzL3Vsj3txvtvC79B
         9urSa/Cncq0BEsxckv1ogVol6TxO4VSo7czlh1t5a9wV/8FDfcYtSwmFM2/9cvqI62Nh
         1YdbAdBh6X/Is5OzlSQuqfnwPHfvpnBd/E1QZy2b9NfejhqdfmjPi9Y6jpnrqVwPZXPO
         fAYnVfNppku5Uc2i3wo765nF5ee4df8T+SFDQ/ViykHTXn8EBiZj/gpkpGfeJ29R/AUl
         M61bADGHCJSnFQXGRUJ5yDbkEdBE+Hr0t7HKzvU/RpSeaqOBX3AtTeEVZsMEXyzkWoXu
         CS7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWDb2+EyUX8bTlRvVTfIX5gkLKoGbce0tRoLIeonf9STyFyOhDo
	5TB3Ew9S69O7Lzme9zVIwrwhTuW+g6EVQ7rjdj9XKV3jvXlvTgBQJtiIkWtoPCUnmA9NKH+SR/Q
	9OLwPHN4iAABTmnoeNWt8/+vr86QnRwYtw0lt8FM07NHrK1rb11410M/0OfosMF8YmQ==
X-Received: by 2002:a50:b482:: with SMTP id w2mr14658172edd.41.1551689531278;
        Mon, 04 Mar 2019 00:52:11 -0800 (PST)
X-Google-Smtp-Source: APXvYqwm3HGrHzGg86NAjttpjvm18q3z00Yf+dETPkifmelDU/k8yCIN2xQfbMdidNNqVjz/98q2
X-Received: by 2002:a50:b482:: with SMTP id w2mr14658130edd.41.1551689530252;
        Mon, 04 Mar 2019 00:52:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551689530; cv=none;
        d=google.com; s=arc-20160816;
        b=MC6AtP/ipwgdFJloF3oP16Cv8yjyKKY1RmhYiSm9IbsdojX1H/35/2PBDEIBeN42Fy
         1miUmQbgj1LaAuBE/YtXpchUpHFkuFeOILaNru2zW9Yx4m7vxZGVoKoXPvUPUmW413pE
         zafSuMHsZvresGAB9oLAh3OpLdpGEbRC36NiyBWqHjXubzvw4NAIC/ZfMTZcHbV4hEpX
         FkY9aO6ZSeN/4GKqkRkw5enOYEZh/3BgOlDXKFZUGQo0i/B8wlesUCzS95vGq4htDaHp
         PckZsodSXYFii3O2ni2Cn2kqvOdDlRSbK/AlAmTVLKgYtoV9H2aaY1JefVIZgrW5MO11
         QmPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=P3IxFkulsP4nAN+yFpECaeeODNWR87CMqbLg3kC33t0=;
        b=FJbbbPDtt/PRQ2iaEeAxBMuP/dHt07k93REqDwUMvyz/PWs53e7w5Kc49H00eA5p/e
         byqo+0PIT56ft4dPRBATi/JNQWiAjn/xLlzZvJEDSc4HK8aLOPDIFJ8CGzghVNojDtSQ
         4HTXZG+/x3mhTi7yrdoVQxNElVIVvFsgDD1BDLLCBOXqJsVztIs3Sxaxk9XrBLTsDZPa
         xbE+39PjFweF8BdjkX5mVE0PF+0lGIIuzPzOPmyriQ5BCrW+S4cSExtjLGQ6jzAu5S7h
         SVZTzTnLfAGYkQadqVUfRmY++beLj62jaMz0l04HX5L1nGbvQCa+h4EGGGvggQCRQuDv
         pmcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id b56si726722edc.402.2019.03.04.00.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 00:52:10 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Mon, 04 Mar 2019 09:52:09 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Mon, 04 Mar 2019 08:51:54 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	mike.kravetz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 0/2] Unlock 1GB-hugetlb on x86_64
Date: Mon,  4 Mar 2019 09:51:45 +0100
Message-Id: <20190304085147.556-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

RFC -> V1:
	- Split up the patch
	- Added Michal's Acked-by

The RFC version of this patch was discussed here [1], and it did not find any
objection.
I decided to split up the former patch because one of the changes enables
offlining operation for 1GB-hugetlb pages, while the other change is a mere
cleanup.

Patch1 contains all the information regarding 1GB-hugetlb pages change.

[1] https://lore.kernel.org/linux-mm/20190221094212.16906-1-osalvador@suse.de/

Oscar Salvador (2):
  mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
  mm,memory_hotplug: Drop redundant hugepage_migration_supported check

 mm/memory_hotplug.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

-- 
2.13.7

