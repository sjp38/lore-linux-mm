Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BEB4C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:58:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D6D121019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:58:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D6D121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 951BB6B0008; Wed, 12 Jun 2019 13:58:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 902336B000A; Wed, 12 Jun 2019 13:58:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F1BD6B000D; Wed, 12 Jun 2019 13:58:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB066B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:58:04 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id p193so5368891vkd.7
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:58:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Re4Dt0O/x00kMRajxlQQ1fNxVXQ/i3h5Zs5UpC9Yu5Q=;
        b=a7o/x0wiF4vS/FeavJ0++WhoqFopAjJakvjrnLaaR5DwmtryUTovF0oZrK9PFcF7WU
         O7TeZ4vF7vGmcgtihm9wCR83zTlNulsW08MDdieL0prbvzAl7ny3AYRGeo+95ksHPskb
         HQJvOd9qpb6s71BzVUC7thJ74b1ktmA7uaUqkCYdH/oai3VLcVd/4o/qWd5mMtBJXOyU
         zKh16GykRkdjIHw/L3q9ddJa2oLuGxxhWQ9jgDiftsLkpOquGbbp4ExBOJmswECJEz/b
         YnDJHSreh1cXCCHqcKiayq3zHeELJD18mflFZihn8telZhTHIZZYIqUG7B4slji7TUQw
         pvpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jsavitz@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jsavitz@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVGcXgnum23ZVp14vtqhRPYj6gaiCNPpw5loOPl5P7cvnQXKevw
	VndlneCqNL2bUcd4IKRc289fa0oMBPxpw5wPl8ShpBzKIT5B2EpiGEMuvTH3IQ72QriC4CgYZ4o
	skDyQPgvBhlwE3SGpNuexnkXSFGoYnAS7HwclkzK37twBEf8R2En1dNQVw01hzNztrQ==
X-Received: by 2002:ab0:7035:: with SMTP id u21mr9485856ual.26.1560362284110;
        Wed, 12 Jun 2019 10:58:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCk5lOtgpSEjhWdldE0IcfpMaCy3NFP38nU2+G7H3l/fIz6eQf7Ct1NoLPnsAi2biVh8Cu
X-Received: by 2002:ab0:7035:: with SMTP id u21mr9485792ual.26.1560362283440;
        Wed, 12 Jun 2019 10:58:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560362283; cv=none;
        d=google.com; s=arc-20160816;
        b=vfj6q59DcHnAlErR3h8WYgR/kxZ+XqOwq+yW4n22zmtTgom/CVMmtyJueRc0J0byKq
         //iCFHMCqbXDediKSsqoTTZQ8JsVWwPCG6/JvH37GbLUyD3K2shGtIiARHOBM9q7yBbq
         TxqfIMQFqKBKjNQyY/kqVx4ge9NsoGwMRTDxVlLzktj9duqkXxXDl1st618vUjf8TwYA
         FZPVl6pcxCyShten/Zz+7v7CKPhpitNdpXnq+3PUpDYgaOfmDxS6O4uUda1UjJpw38Wu
         kOIP+3gxQzij22CAhIqZujDwPeSFidty/83cGpd5NZz+sUFFlhnvtXmYh6VvWx457hdh
         +T1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Re4Dt0O/x00kMRajxlQQ1fNxVXQ/i3h5Zs5UpC9Yu5Q=;
        b=e9PIoXbrPdEpDmPretG/sW1p1IJqWGSbjqZF7ydj4WjoOqDws16pY/jazBnbhOVQIb
         s8tjP0AJDGded2NAUor0vvjqh1Gvqv2ScHGfMMPsS5XgFu9N6obfAivJALub4beR0b7x
         T7gFXpizbyXALen5+RtSRaYM0AMJRypo+CQ6GwnFK+g05O0Ozh12ksvxqmvyITKtoRz/
         JlI+SRnHwJUnwLoceu+mC2+gxwas0SrwIccumjKvXooESRwACc03nzUtwBj7Wba7NmtF
         iU93l+KdWOoWRiGsEAfFpVLfG7mx6gKH+oNQHU2av+osM8mW2HFVYkmtEXcmckNYCRYe
         EnXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jsavitz@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jsavitz@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 95si149502uac.61.2019.06.12.10.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:58:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jsavitz@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jsavitz@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jsavitz@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8E4BC3001572;
	Wed, 12 Jun 2019 17:58:02 +0000 (UTC)
Received: from jsavitz.bos.com (dhcp-17-175.bos.redhat.com [10.18.17.175])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DE1371001B17;
	Wed, 12 Jun 2019 17:57:55 +0000 (UTC)
From: Joel Savitz <jsavitz@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Joel Savitz <jsavitz@redhat.com>,
	Rafael Aquini <aquini@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	linux-mm@kvack.org
Subject: [RESEND PATCH v2] mm/oom_killer: Add task UID to info message on an oom kill
Date: Wed, 12 Jun 2019 13:57:53 -0400
Message-Id: <1560362273-534-1-git-send-email-jsavitz@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 12 Jun 2019 17:58:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the event of an oom kill, useful information about the killed
process is printed to dmesg. Users, especially system administrators,
will find it useful to immediately see the UID of the process.

In the following example, abuse_the_ram is the name of a program
that attempts to iteratively allocate all available memory until it is
stopped by force.

Current message:

Out of memory: Killed process 35389 (abuse_the_ram)
total-vm:133718232kB, anon-rss:129624980kB, file-rss:0kB,
shmem-rss:0kB

Patched message:

Out of memory: Killed process 2739 (abuse_the_ram),
total-vm:133880028kB, anon-rss:129754836kB, file-rss:0kB,
shmem-rss:0kB, UID 0


Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Joel Savitz <jsavitz@redhat.com>
---
 mm/oom_kill.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3a2484884cfd..af2e3faa72a0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -874,12 +874,13 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
 	mark_oom_victim(victim);
-	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB, UID %d\n",
 		message, task_pid_nr(victim), victim->comm,
 		K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
 		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
+		from_kuid(&init_user_ns, task_uid(victim)));
 	task_unlock(victim);
 
 	/*
-- 
2.18.1

