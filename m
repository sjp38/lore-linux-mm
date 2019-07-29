Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3567AC76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 19:42:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA95520C01
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 19:42:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NaqhEn+n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA95520C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E7DE8E0003; Mon, 29 Jul 2019 15:42:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 398538E0002; Mon, 29 Jul 2019 15:42:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 287CA8E0003; Mon, 29 Jul 2019 15:42:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9D4E8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 15:42:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so39071163pfo.22
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 12:42:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=Frj/SS/W3AFZFbyzaOV4LWLnrMlPxcryoFLQjik2HTI=;
        b=fRSq1XEN7HpSe/YnPTvdGZ9pM4kYe0S7+ZgKfXHAWtMIRXNmZcTiUo8+VT6eUhiD1D
         hpVKpX4iFejTSlrKTOltk95tMOxQnaEib1BPM+6rXi1AC0sUOI4GeQFCkDsujSAPv2/h
         J0GIkwXUbnVU54qQLInxVATcpXecZU8SM/k79Y1hj++Bbox1eMg0YFx4X5Me/Th8AxJY
         tjAN+sWjc2tvHL0RKted6st8CGSeJ7NvC5bhLIRJcuRrAm7DOQK0pe25qIuWZHR549yZ
         ye4ASbADNf0MUyPggEh8IkGgRaYSm62qdO4Wi3KByfgibohn/Uf+MJXVlhCqWlh24lZd
         z+jQ==
X-Gm-Message-State: APjAAAXFWufG9j/I3NcFY1I79s9drskCWm40oLl5BR6ctKVNgKH/saO1
	b0MqLOvevkyBi2zQ7+nUXrXgrcpm8zaZSdXkrLiYIzKqySmgm4BcZe5Yy+Z9Sz46Ou/j+JWG4nV
	cP5efAnK+lEg6UIB0GTKia+VMkKVm8JLbtXkuX/994fEiB+XWUjA/YhTab9DUhd+31Q==
X-Received: by 2002:a65:4808:: with SMTP id h8mr104655273pgs.22.1564429331488;
        Mon, 29 Jul 2019 12:42:11 -0700 (PDT)
X-Received: by 2002:a65:4808:: with SMTP id h8mr104655216pgs.22.1564429330756;
        Mon, 29 Jul 2019 12:42:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564429330; cv=none;
        d=google.com; s=arc-20160816;
        b=fFObEMmSML0Ly2jwbDbaAfNEhL1QCcrqpBMBLdMmpymqPNQ5ZuMMYwwGOIX/bUHh3Z
         xzrQWa86xYKhLmjKvHQX/tZpXm4U3sXCiBku2XYuX3QvfeuH8mv400SWsAmhkGcbl+nz
         j3RW+N43uxACQqGG+wblcKBOyrLIkT3Ed+2ZQ89+v5tLNzrsUf5tMbzCmKqCFXDsZ89P
         cqTksaBx8pO/q0rnjcdkllfmuSQD/WQNqAnLcL1RVXCgz0wA+tqh5PrH+S6MiRaWKRdn
         5o1Ps3n/Fk0mahX8W6KM7eNfVpJAsLjyMnTbYXcCaWKebsSyayB7dU0Ylg6rwpmisCM3
         gpvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=Frj/SS/W3AFZFbyzaOV4LWLnrMlPxcryoFLQjik2HTI=;
        b=WruN1pJV0iLTShlRKp5mItHY+IDTJUrCqddTfHwOs/IRpaFcqRzMbIdpF+WJpOCeaz
         +kwEFgWcOGPWaJTsrPW+rBuZbtaqgk0BNDPuwzloUfTlXdIJvgkMZNUhfttMEquZbt4u
         xPsxZOlRPljfQSuWyJzZf0NGgI5MIia6s3KOPS+wdHSpYY8C9ETw47bbw2QP6/Nort/w
         29u+TXoBLIOrW9hHVJjPZ2E6gANAoiGIrV0ZBC2SaiE1SgZNhji3Gqgz1MVDwok+ZcSf
         0G7zSUkfJgCZR4ZD6PEsRh8i13H/ySCkmkhDiwBUGB/AaqQp/pXwgWHolqTc/UlptBL0
         Samg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NaqhEn+n;
       spf=pass (google.com: domain of 3euw_xqykcjyikh4d16ee6b4.2ecb8dkn-ccal02a.eh6@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3EUw_XQYKCJYIKH4D16EE6B4.2ECB8DKN-CCAL02A.EH6@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w8sor40302530pgr.42.2019.07.29.12.42.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 12:42:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3euw_xqykcjyikh4d16ee6b4.2ecb8dkn-ccal02a.eh6@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NaqhEn+n;
       spf=pass (google.com: domain of 3euw_xqykcjyikh4d16ee6b4.2ecb8dkn-ccal02a.eh6@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3EUw_XQYKCJYIKH4D16EE6B4.2ECB8DKN-CCAL02A.EH6@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=Frj/SS/W3AFZFbyzaOV4LWLnrMlPxcryoFLQjik2HTI=;
        b=NaqhEn+nWpsDdrbEejnjDaEBQITcPwt2PLGQeCcKpF/xtDBEPcIWyPuF7ZuPOpu8Pa
         jNyFsHX1Aqgj2NKuQj4deoctFI5yaGYWN+NwWkczUhWZtYXHWdQy6rGievfB0HcQR0CW
         80yz6PRH5wMlDl4QoAi3RlT1thGhUpyMhG5q208bELKjzUdINBEQDQSXotmYt7YzzewJ
         3VhbznDQsUgjfVPiFM2RR34iJmx2dpisKe6LolVq3LOjZu0Xr1BHMc0iHTyYRxMEQRiz
         JU4LhMPMcSrMTOwqhzoTY2rVjhoJaTHuS6CjxExljGBNKHF+98phmihBxTwGrkZSlXB/
         Guvg==
X-Google-Smtp-Source: APXvYqyf9K52n5I7/pZqfWtKK1UU5XmY8cIscUIXJkk8Ba5+O7oBV/xVhhZfFLdsElYAqR6YpFcVrndVWFg=
X-Received: by 2002:a63:a346:: with SMTP id v6mr59564547pgn.57.1564429329902;
 Mon, 29 Jul 2019 12:42:09 -0700 (PDT)
Date: Mon, 29 Jul 2019 12:42:05 -0700
Message-Id: <20190729194205.212846-1-surenb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH 1/1] psi: do not require setsched permission from the trigger creator
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, 
	dennisszhou@gmail.com, mingo@redhat.com, peterz@infradead.org, 
	akpm@linux-foundation.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, kernel-team@android.com, 
	Suren Baghdasaryan <surenb@google.com>, Nick Kralevich <nnk@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002940, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a process creates a new trigger by writing into /proc/pressure/*
files, permissions to write such a file should be used to determine whether
the process is allowed to do so or not. Current implementation would also
require such a process to have setsched capability. Setting of psi trigger
thread's scheduling policy is an implementation detail and should not be
exposed to the user level. Remove the permission check by using _nocheck
version of the function.

Suggested-by: Nick Kralevich <nnk@google.com>
Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 kernel/sched/psi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 7acc632c3b82..ed9a1d573cb1 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -1061,7 +1061,7 @@ struct psi_trigger *psi_trigger_create(struct psi_group *group,
 			mutex_unlock(&group->trigger_lock);
 			return ERR_CAST(kworker);
 		}
-		sched_setscheduler(kworker->task, SCHED_FIFO, &param);
+		sched_setscheduler_nocheck(kworker->task, SCHED_FIFO, &param);
 		kthread_init_delayed_work(&group->poll_work,
 				psi_poll_work);
 		rcu_assign_pointer(group->poll_kworker, kworker);
-- 
2.22.0.709.g102302147b-goog

