Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD051C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A670920830
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A670920830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B0466B000A; Tue, 26 Mar 2019 05:02:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15F7F6B000C; Tue, 26 Mar 2019 05:02:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04E8E6B000D; Tue, 26 Mar 2019 05:02:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6D836B000A
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:02:55 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id a15so8241215qkl.23
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:02:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=z5ci/X/lLiFuZNLGAa3MIXoyWsKM2relopxyFwJjuV4=;
        b=HGqXevR6pXgy4t+SQVrEJHWlJwJ11cL0mgUOSYITydIN1wbyKlP86Zh9qh1eDKC+37
         VngFGshraBVdyGu9So3w7BSc4HsKPpq2gahj+DJ6EVFX5fUDpMv4W04/byHLrMxCJda2
         6fqCkaq/wVjA/Ne1SWau8EgnoHipifTRttLne+ZKSw0OyzMbJyMUru3MZxWFIYTOyKyV
         OvI6rMgnXP0ikJ3uq05EnTAvomEoSz7ZmNYd4f/9htayDg1jb/7A+73+vdyXA+o0MPke
         /wcaJj6lFu4GdRb5pPumHArQNlcW7gRfrY6Z1p0xBi6ZCfhO0YD2DHwn8vKM8uZXEYDH
         vtnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX7IuUiX9GAR4elX/lnvMj+vMYqRfirLbSdPBpl14wqni4YCrp2
	W47v1yoM1xW8gLL6LMEdsEw4X2JYiVUb/FoNH0i/UQOgW0HaMAt9nbLqMHjEdZAJY+HAkB2TGR+
	apDnIQRmx6gt2gEpdsm0o3JMSEFJerW9/0Ubq02zStj4GWROmG++4fiz2BTh/sO5ahA==
X-Received: by 2002:ac8:1acf:: with SMTP id h15mr24387455qtk.85.1553590975635;
        Tue, 26 Mar 2019 02:02:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz78T6T50j5LTXQBJcOh/TfNeOzXt13UBxg844k5EAYH0qwu4t6/plqjh5tA4NYv58v/NPZ
X-Received: by 2002:ac8:1acf:: with SMTP id h15mr24387398qtk.85.1553590974776;
        Tue, 26 Mar 2019 02:02:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553590974; cv=none;
        d=google.com; s=arc-20160816;
        b=0jicNPzWlmvx3Mc3bHnzSMxN0k2fAHFifInidVSuumEDFzKmV6S9HjMmn1tKKTUK2s
         C2TLpte5rDhDKZ2idlRMIK51FLwGDoIxQIM+WnNM4E/mC0a8sg7FJwJTtKQ17TFby1BD
         YprzTjCgm+/+sUUH1xbkBa5z5ReLMzUPkcfykRWnx5trqsbvhijHzCJFK8fa1uPmnTsn
         8WD920i1e7htrMNh8M15KWIO6MVU5idkoH6+Pcl12EHIsxgmrNC2zZC4quoyxIlWfzI7
         vuvYJ1rKcQhEzrVGmKTm7+Zx7ElftF1MjROSrZSoAI7DK5+OoJ64XMVfrmHLmElNTHgs
         DVPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=z5ci/X/lLiFuZNLGAa3MIXoyWsKM2relopxyFwJjuV4=;
        b=W1wU+yT5yPxy71CZyMrRJVVDK1COw7x6RnNEF3ilw9Ofns1YEH7X6t9R2xh9PO4oW0
         qEf8hBIuOkIDy6DO7ntyx8ksUbxy9z/mBRq5JgnLI4aleSh5Iz7z/sqc7sXbcMu6qvU9
         3ekq2/MH0oVsvEUhBkkBF6oB4iMbofOL532Z1K53ms5LjHpFEV353420z1zIKsd0FKvg
         k6XjQ83Ht2nnomScMBjwfQe7vC92AMlw0tVjczSDFhboQwnqRhanSZqhr4OVCBeJETBa
         T84kZVMOfOQteJeCb9pyfo35m0zgPXLG+wpokjhbueH9BIxxmO8kXKOE8k9ZdiSENiVL
         Wg8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q57si1779905qtf.374.2019.03.26.02.02.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:02:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2F58988318;
	Tue, 26 Mar 2019 09:02:53 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 49BFB8261C;
	Tue, 26 Mar 2019 09:02:49 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	rppt@linux.ibm.com,
	osalvador@suse.de,
	willy@infradead.org,
	william.kucharski@oracle.com,
	Baoquan He <bhe@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>
Subject: [PATCH v2 4/4] drivers/base/memory.c: Rename the misleading parameter
Date: Tue, 26 Mar 2019 17:02:27 +0800
Message-Id: <20190326090227.3059-5-bhe@redhat.com>
In-Reply-To: <20190326090227.3059-1-bhe@redhat.com>
References: <20190326090227.3059-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 26 Mar 2019 09:02:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The input parameter 'phys_index' of memory_block_action() is actually
the section number, but not the phys_index of memory_block. Fix it.

Signed-off-by: Baoquan He <bhe@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
---
 drivers/base/memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index cb8347500ce2..184f4f8d1b62 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -231,13 +231,13 @@ static bool pages_correctly_probed(unsigned long start_pfn)
  * OK to have direct references to sparsemem variables in here.
  */
 static int
-memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
+memory_block_action(unsigned long sec, unsigned long action, int online_type)
 {
 	unsigned long start_pfn;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	int ret;
 
-	start_pfn = section_nr_to_pfn(phys_index);
+	start_pfn = section_nr_to_pfn(sec);
 
 	switch (action) {
 	case MEM_ONLINE:
@@ -251,7 +251,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
 		break;
 	default:
 		WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
-		     "%ld\n", __func__, phys_index, action, action);
+		     "%ld\n", __func__, sec, action, action);
 		ret = -EINVAL;
 	}
 
-- 
2.17.2

