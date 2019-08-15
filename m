Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10E4BC433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 06:06:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A67A7206C2
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 06:06:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="YEebXXY2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A67A7206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 030676B0003; Thu, 15 Aug 2019 02:06:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F223E6B0005; Thu, 15 Aug 2019 02:06:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E37E86B0007; Thu, 15 Aug 2019 02:06:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id BC2496B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 02:06:32 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 349324FE6
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 06:06:32 +0000 (UTC)
X-FDA: 75823627824.21.stove15_1be47c556995b
X-HE-Tag: stove15_1be47c556995b
X-Filterd-Recvd-Size: 3901
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 06:06:31 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id B65DD42A2C7;
	Wed, 14 Aug 2019 23:07:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1565849232;
	bh=OG6evudYvLj50ZFoTIDecZ1Ho1oufmSz1imiu12yfjk=;
	h=From:To:Cc:Subject:Date;
	b=YEebXXY2Y14FST6xyHsv3SPFD9wRuNltXbAlw1y/+RiWHbr31RIpHP4zHvdIQ3LOJ
	 TUV567FDvdD8dCUPDqI7UOFUN6AS845eFF181M8SHU9z2uKDlCKCuootWa0/KsKGIB
	 PPZdMRK/cD5JjSPsPu6bUXk+H9C5abYwMpt/lTzN2oQ0pHI1J++ZDTw0m2sYmxBPPw
	 1T9KUZyjs6sLZDO0KISu9uxakqn4vyFJoL9x/omYdgzzIq36crLYBn5PsI0givIB22
	 v7nqhZD9DThU6VcPspilWEkRwT/DVxkngQtGzk0aCYC/YMCZ/uE8ftejUrYGD1FBld
	 Chec4Yp4UIKTQ==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id A8B7142A296;
	Wed, 14 Aug 2019 23:07:12 -0700 (PDT)
From: Edward Chron <echron@arista.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Shakeel Butt <shakeelb@google.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	colona@arista.com,
	Edward Chron <echron@arista.com>
Subject: [PATCH] mm/oom: Add killed process selection information
Date: Wed, 14 Aug 2019 23:06:04 -0700
Message-Id: <20190815060604.3675-1-echron@arista.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For an OOM event: print oom_score_adj value for the OOM Killed process
to document what the oom score adjust value was at the time the process
at the time of the OOM event. The value can be set by the user and it
effects the resulting oom_score so useful to document this value.

Sample message output:
Aug 14 23:00:02 testserver kernel: Out of memory: Killed process 2692
 (oomprocs) total-vm:1056800kB, anon-rss:1052760kB, file-rss:4kB,i
 shmem-rss:0kB oom_score_adj:1000

Signed-off-by: Edward Chron <echron@arista.com>
---
 mm/oom_kill.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a0bdc6..6b1674cac377 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -858,6 +858,7 @@ static void __oom_kill_process(struct task_struct *vi=
ctim, const char *message)
 	struct task_struct *p;
 	struct mm_struct *mm;
 	bool can_oom_reap =3D true;
+	long adj;
=20
 	p =3D find_lock_task_mm(victim);
 	if (!p) {
@@ -877,6 +878,8 @@ static void __oom_kill_process(struct task_struct *vi=
ctim, const char *message)
 	count_vm_event(OOM_KILL);
 	memcg_memory_event_mm(mm, MEMCG_OOM_KILL);
=20
+	adj =3D (long)victim->signal->oom_score_adj;
+
 	/*
 	 * We should send SIGKILL before granting access to memory reserves
 	 * in order to prevent the OOM victim from depleting the memory
@@ -884,12 +887,12 @@ static void __oom_kill_process(struct task_struct *=
victim, const char *message)
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
 	mark_oom_victim(victim);
-	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file=
-rss:%lukB, shmem-rss:%lukB\n",
+	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file=
-rss:%lukB, shmem-rss:%lukB oom_score_adj:%ld\n",
 		message, task_pid_nr(victim), victim->comm,
 		K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
 		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)), adj);
 	task_unlock(victim);
=20
 	/*
--=20
2.20.1


