Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83EFBC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 429CA272DE
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="x+hU3+pd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 429CA272DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CB976B0285; Sat,  1 Jun 2019 09:20:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A4296B0286; Sat,  1 Jun 2019 09:20:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56A366B0287; Sat,  1 Jun 2019 09:20:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 178036B0285
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:31 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f9so9627727pfn.6
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x3xJmDMnZ0nsOgvD1uW4vRlg+dxuxjec4P4nUs18SO0=;
        b=TrodxTa7hzswEJrcs3vweCgMupxEVpqPj14EoPSRL+R8gl3fk4USSgchnSwjllRJOF
         3OQk/WITelPxBPtYT975XYlVBq/gbglGfEIT/TUH7j8R3uJn2bdhhAqVtJ3YLWrw0Quy
         IqG5/K/iqI3YPRUSdUSnhXwOYGziSbthJ8xNDknYdhqyGAnkIRCBp4TmHzdtBZLnUxX+
         JpJHRPIjgPoIuLL3LXldxOt/AnMk7QsDrsVHxcRQAD5yU6Z+MBVWbYuTwVvfRNHLWqQe
         50WBb0ny/vavxOAt8ywa6Qew90P5Fu1DrMJ7/E2/SXT3L+0hVnVrfad4bNQscSYOrZyR
         PTsw==
X-Gm-Message-State: APjAAAV+fASKdNjbu2etdv4JTtCeKjzxUkor1xhg3pW5lug7hseufilB
	biEMPEr4Gyvftjew6km6LMThJ6wvHVjUJ534JozQlHdhg8yncorrRH+yL27YaVN2yCkANQ/iMKg
	8Acu8vKLcGInkjVQQrq2vHhRS0Wa+TNiHYRW75olXQMMjpEXZ0Fp5tj4/LWk9NyxAlA==
X-Received: by 2002:a17:902:8a83:: with SMTP id p3mr16550405plo.88.1559395230732;
        Sat, 01 Jun 2019 06:20:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbTSEdWi8jRtLB3Fspr1QeOMk0XOpUMe6tnsFFtPf7i1tscukeGWvYaAk3PgkaDm2oSKZa
X-Received: by 2002:a17:902:8a83:: with SMTP id p3mr16550346plo.88.1559395230161;
        Sat, 01 Jun 2019 06:20:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395230; cv=none;
        d=google.com; s=arc-20160816;
        b=M+DHihkulHo3wmYvrpHdMEVmlJNgYGyEEV+DJvYAusznZwE+FrHHoe7iZUAuboRcIo
         Jz27arNkLhVeDaVDslAlJFGI/G/XugOVJEaKOOs+8AhMPYwXBnXjanzF+B6kWecAV/M8
         lFoUQPQiLKL0aKDxJRVt/Jve8emLwVFkmyAn59cOsoYySnzz7QY8UXqsYBcZJRgDJ6Ah
         5OEdwYU6gxmtKIF+iwJ6vaZbt0lJvtPtf0ctlWONsdA484+7BIOHtlMdEopoHoNWyxQT
         Na/gF6jgiS0uHXIDSU5TrdI3z2ydXq6UuX1fzhpKnju54PWYFwHEV1QxNCob0G5W59WQ
         mfpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=x3xJmDMnZ0nsOgvD1uW4vRlg+dxuxjec4P4nUs18SO0=;
        b=IBIzeNiLwg9211WaVnmXlm7Rb4mHrJDJXosNMvipHipSmpciZAKVTHJd05osjkQ4jL
         /tyRIsbS3WtXS4+e9VXWDhU/Ck1mGlXYRow0pt8Lf00igoagAOZ6capbt2LYQw0qJ+W9
         dXQTXdcl3J2PPOkmECyq4Tqq/KgLbO4fd9WOdmERKQNhrrcz1sUj97MEjOVDaTyOEbee
         IRa6Gb5jU0iQS3d4wuM62TbiT9ZLhHhFWPOqP7t9RS2imF/CyeWXQGnh4QhXF6Hu2mmL
         XU8k8FPI5noqLw/lBFDMP8Wn3+W8Q0mdvjt9bc5ABSn0HM3wCcaX4vJV0ZeEdhzrRjSP
         bxVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=x+hU3+pd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 9si9905647pgu.189.2019.06.01.06.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=x+hU3+pd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A191D272DE;
	Sat,  1 Jun 2019 13:20:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395229;
	bh=DHR7kqRzoj0p2zUAiXG+aU4DQZFfXRciLoxmjLkKDQY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=x+hU3+pd/Vc6FNGedGcso1ElgcqREezAShbeqlEzN8/y/3TiPWOxo3Qlh4rmFflXi
	 oRYY0lFQtiKOuk6cV2q7865DlUoEZJ4n06gXXn1jGBjCnXovMZYqX49f45mZOQOdDD
	 EpU9dJsgNn6zjJ/9YIKpMEvCC8pR6QyqJhWfmsp4=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Baoquan He <bhe@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Wei Yang <richard.weiyang@gmail.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 016/173] mm/memory_hotplug.c: fix the wrong usage of N_HIGH_MEMORY
Date: Sat,  1 Jun 2019 09:16:48 -0400
Message-Id: <20190601131934.25053-16-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131934.25053-1-sashal@kernel.org>
References: <20190601131934.25053-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Baoquan He <bhe@redhat.com>

[ Upstream commit d3ba3ae19751e476b0840a0c9a673a5766fa3219 ]

In node_states_check_changes_online(), N_HIGH_MEMORY is used to substitute
ZONE_HIGHMEM directly.  This is not right.  N_HIGH_MEMORY is to mark the
memory state of node.  Here zone index is checked, which should be
compared with 'ZONE_HIGHMEM' accordingly.

Replace it with ZONE_HIGHMEM.

This is a code cleanup - no known runtime effects.

Link: http://lkml.kernel.org/r/20190320080732.14933-1-bhe@redhat.com
Fixes: 8efe33f40f3e ("mm/memory_hotplug.c: simplify node_states_check_changes_online")
Signed-off-by: Baoquan He <bhe@redhat.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e06e7a89d0e5b..33f1b8d307e64 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -684,7 +684,7 @@ static void node_states_check_changes_online(unsigned long nr_pages,
 	if (zone_idx(zone) <= ZONE_NORMAL && !node_state(nid, N_NORMAL_MEMORY))
 		arg->status_change_nid_normal = nid;
 #ifdef CONFIG_HIGHMEM
-	if (zone_idx(zone) <= N_HIGH_MEMORY && !node_state(nid, N_HIGH_MEMORY))
+	if (zone_idx(zone) <= ZONE_HIGHMEM && !node_state(nid, N_HIGH_MEMORY))
 		arg->status_change_nid_high = nid;
 #endif
 }
-- 
2.20.1

