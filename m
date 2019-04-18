Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E339C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:56:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EA2B217FA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:56:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="CSy3UDoB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EA2B217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C38546B000A; Thu, 18 Apr 2019 11:56:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE8A16B000C; Thu, 18 Apr 2019 11:56:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD77A6B000D; Thu, 18 Apr 2019 11:56:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76D406B000A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:56:24 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id t17so1711277plj.18
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:56:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :in-reply-to:message-id:mime-version:content-transfer-encoding;
        bh=AAsZntR4QTMeD5qDfgenEpXJ31laiwTUaYLdRCK8Cgk=;
        b=UwbwLz1TReba9bTJNUk6i7f1sl1zTx3SiYRHWMUxVm8FwZyDb4BWKs6cwF+N1G0xvM
         vK/EbJ8pXnsUS2sOxKFeLfMBw5oMn0diTqXXADF+YCHfEMab1hy3QqmN6e+YKBurAdcV
         oDIh+/RM7u7N5yurmC8mQL0W20d+HDZQp9jaoSyM3bhe7Zj32sZMgpdAYVe57jrcsT1F
         LYmCy30x1uhb+cy/Kei+fvvukesRvqaFdRhq7K0np856/9O+ofHjdfQPhS1bBSEQoYG5
         tr9QkWh5NT0spTSZp/kooMrTQT/fJkR3w5x1apIKrdU4b698ks+AY58rxc8m9CygqLqW
         W83g==
X-Gm-Message-State: APjAAAVkofjKGIY8AW9PJwDqvI4+5irYX3byy6/GokTW0DP1cIQhgH0b
	XgYySlOVpAewJJAfycDmw2mJffgX13h9sxLSRyQSCrpz3VVpJfcH9S+BlvydMEX4LP4Cfd7kEpR
	B4k1QwmtUFqB9y2V0JPYtdg3PLTqnniptI6GvwbAU4nnJHVW02/x3bMzNFdPgDdL49Q==
X-Received: by 2002:a63:5953:: with SMTP id j19mr85363765pgm.260.1555602984072;
        Thu, 18 Apr 2019 08:56:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyojImamONVwdQMMRtOSEwWBY+niv4SANavuHk1vTmHoQuqqxbe/P7vVgpN2sQ+FjLOnGy7
X-Received: by 2002:a63:5953:: with SMTP id j19mr85363715pgm.260.1555602983331;
        Thu, 18 Apr 2019 08:56:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602983; cv=none;
        d=google.com; s=arc-20160816;
        b=1CqYlZkSDqOzNRUb89xQxjnZZX3K62vTwpjRPZQIUEPQeUFQW+YdoZ7SvUNtH6aFG9
         Lo91EJU0giCDkUAfr5hv3p/locBVqhXlhi4rscQW4Hw4TzKlcHDUbomNUK81H8LDz+HB
         2yXOpOqRfG8hADuAmvqAW8ZWeW4hxcSWsFoQZuB0LsWLUdhaeK9I55BLXmyKUQQtkHw/
         NdgA9ih/wCCkL6J7NNlQDXKg1bKsHF+I2u5CXoGrmq7thlVYrpHidd1RxivZ6NpCuUlM
         9KB74ZOvI4GsdwLsTRuWGl6mYi0meshelH0eVt8ohwJkEH1wPus08wncmUC0AdM31b5F
         X+cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:in-reply-to:date
         :from:cc:to:subject:dkim-signature;
        bh=AAsZntR4QTMeD5qDfgenEpXJ31laiwTUaYLdRCK8Cgk=;
        b=a2m7jfJrkmQuslndipbl49bCMmZH05dvBbHy+7Hc4P/eg8hvUyf3lohYbuvK/0rLg2
         5h9vBegPP7GkOKAag5SB8M1w7HcOEFVIWHiUTJsH7D66o/7GPbnUmRl2aSr1KGqPevwq
         x4W+x38EC1gq76nIkKbkL5ObNWx+OfR0AE69UuDTgr7kQ3VNEF1H2X2mM57J3bziVC8r
         +cz2aZ16wDp4g8hnSmEr+jWeA418rpW7bk4TSpK0sySDvymeQnVsXEmCwS75Pi8DUemO
         tGXg+c6IHZt9gVHm0K92utyc8Pp6Akt66EQ3GacxQH+orgaax1MBpQa9QkNT8RCya5+y
         T71Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CSy3UDoB;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i40si2524894plb.177.2019.04.18.08.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 08:56:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CSy3UDoB;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 876102148D;
	Thu, 18 Apr 2019 15:56:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555602983;
	bh=hPsLjJSmnGf0gnEla9rofRN5R/yhc9Az6thHUgVjheY=;
	h=Subject:To:Cc:From:Date:In-Reply-To:From;
	b=CSy3UDoBaPup1Qgjim5AFbpWLmowpOf8AhMUsx7dk08eAgV8BIeDSP7+Jlwl3jj1u
	 N3AlWpll8GsE/NJ1R6ZXunaU86KX1/3TNPJ1R9OX3OZMe95vlsdTPxqpb68/ixsK/l
	 pHeBxu5LCh4cQye7b+L24ry/gSmc9fpa1nMt2a64=
Subject: Patch "[PATCH 4.19.y 2/2] mm: hide incomplete nr_indirectly_reclaimable in sysfs" has been added to the 4.19-stable tree
To: gregkh@linuxfoundation.org,guro@fb.com,khlebnikov@yandex-team.ru,linux-mm@kvack.org,vbabka@suse.cz
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Thu, 18 Apr 2019 17:56:10 +0200
In-Reply-To: <155482954368.2823.12386748649541618609.stgit@buzz>
Message-ID: <1555602970148100@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
X-stable: commit
X-Patchwork-Hint: ignore 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This is a note to let you know that I've just added the patch titled

    [PATCH 4.19.y 2/2] mm: hide incomplete nr_indirectly_reclaimable in sysfs

to the 4.19-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     mm-hide-incomplete-nr_indirectly_reclaimable-in-sysfs.patch
and it can be found in the queue-4.19 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


From khlebnikov@yandex-team.ru  Thu Apr 18 17:53:53 2019
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 09 Apr 2019 20:05:43 +0300
Subject: [PATCH 4.19.y 2/2] mm: hide incomplete nr_indirectly_reclaimable in sysfs
To: stable@vger.kernel.org
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>
Message-ID: <155482954368.2823.12386748649541618609.stgit@buzz>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

In upstream branch this fixed by commit b29940c1abd7 ("mm: rename and
change semantics of nr_indirectly_reclaimable_bytes").

This fixes /sys/devices/system/node/node*/vmstat format:

...
nr_dirtied 6613155
nr_written 5796802
 11089216
...

Cc: <stable@vger.kernel.org> # 4.19.y
Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/base/node.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -197,11 +197,16 @@ static ssize_t node_read_vmstat(struct d
 			     sum_zone_numa_state(nid, i));
 #endif
 
-	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+		/* Skip hidden vmstat items. */
+		if (*vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
+				 NR_VM_NUMA_STAT_ITEMS] == '\0')
+			continue;
 		n += sprintf(buf+n, "%s %lu\n",
 			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
 			     NR_VM_NUMA_STAT_ITEMS],
 			     node_page_state(pgdat, i));
+	}
 
 	return n;
 }


Patches currently in stable-queue which might be from khlebnikov@yandex-team.ru are

queue-4.19/mm-hide-incomplete-nr_indirectly_reclaimable-in-sysfs.patch
queue-4.19/sched-core-fix-buffer-overflow-in-cgroup2-property-c.patch

