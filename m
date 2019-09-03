Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E7E4C3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:45:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37DC320882
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:45:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37DC320882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B22106B0003; Tue,  3 Sep 2019 10:45:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD3866B0005; Tue,  3 Sep 2019 10:45:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E9B76B0006; Tue,  3 Sep 2019 10:45:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0088.hostedemail.com [216.40.44.88])
	by kanga.kvack.org (Postfix) with ESMTP id 7F70C6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:45:20 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1D6E0181AC9BA
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:45:20 +0000 (UTC)
X-FDA: 75893882400.20.teeth70_85d53e0a0ea55
X-HE-Tag: teeth70_85d53e0a0ea55
X-Filterd-Recvd-Size: 4033
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:45:19 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id v38so12903670edm.7
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 07:45:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=iPLrKpMAKQl0z6IHiX3iRCTMRmBL1dJ+Y1ig1WZUOzQ=;
        b=DJt8VMJ6b0LT2BmHUk1CZspC9pwfE7RZQ5nmhnW0DujS/+siZ4WlEsszpaIK+B9ex2
         0Tkt9L38djpQ1jmOt1hwoCmq/ptD1I/SgUn/U3ZRM7q0NPa2ZZd7Hz7DZkccrnW3vcm4
         RcotHV6W1p6tjb5mjl3hPnxg95DeLIhuY9wP4Xsi1YQ0Ujk4W4IsPHIKFwJupNWWoJb1
         t5smuD13xlHk1Djnop/owd9jDUPyIonQeNQ2D0lG+QLmZeZSuRJTUsx32BTINEY/D+tU
         anz7XkCdfZlO4URLBqbcFvNtTnadjSJVjFhspSIxwt1xyz8lduf4Rb6V7qRmrM1AdeF9
         JOGA==
X-Gm-Message-State: APjAAAV4M7PVGochTO+FTRGO7G3tdEQvR71LPVMFdqKUJUbPGpFdj7iw
	WVHRpUd/8wRiFpkTFh41Cfb6+yel
X-Google-Smtp-Source: APXvYqzTogOw7QyxRitlg/CEOmeVi6TOyvu0Hhp6N18xrpDDkkPan96Nm1T/IuUg38GBBjdXGh0kBw==
X-Received: by 2002:a17:906:4d82:: with SMTP id s2mr12474357eju.94.1567521918154;
        Tue, 03 Sep 2019 07:45:18 -0700 (PDT)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id ga12sm132304ejb.40.2019.09.03.07.45.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 07:45:16 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
To: <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	David Rientjes <rientjes@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>
Subject: [RFC PATCH] mm, oom: disable dump_tasks by default
Date: Tue,  3 Sep 2019 16:45:12 +0200
Message-Id: <20190903144512.9374-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

dump_tasks has been introduced by quite some time ago fef1bdd68c81
("oom: add sysctl to enable task memory dump"). It's primary purpose is
to help analyse oom victim selection decision. This has been certainly
useful at times when the heuristic to chose a victim was much more
volatile. Since a63d83f427fb ("oom: badness heuristic rewrite")
situation became much more stable (mostly because the only selection
criterion is the memory usage) and reports about a wrong process to
be shot down have become effectively non-existent.

dump_tasks can generate a lot of output to the kernel log. It is not
uncommon that even relative small system has hundreds of tasks running.
Generating a lot of output to the kernel log both makes the oom report
less convenient to process and also induces a higher load on the printk
subsystem which can lead to other problems (e.g. longer stalls to flush
all the data to consoles).

Therefore change the default of oom_dump_tasks to not print the task
list by default. The sysctl remains in place for anybody who might need
to get this additional information. The oom report still provides an
information about the allocation context and the state of the MM
subsystem which should be sufficient to analyse most of the oom
situations.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a0bdc6..d0353705c6e6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -52,7 +52,7 @@
=20
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
-int sysctl_oom_dump_tasks =3D 1;
+int sysctl_oom_dump_tasks;
=20
 /*
  * Serializes oom killer invocations (out_of_memory()) from all contexts=
 to
--=20
2.20.1


