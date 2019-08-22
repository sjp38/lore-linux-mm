Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2641C3A5A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 17:32:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B254F233FC
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 17:32:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="UI+s7seU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B254F233FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FE816B0342; Thu, 22 Aug 2019 13:32:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 283996B0344; Thu, 22 Aug 2019 13:32:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1990C6B0345; Thu, 22 Aug 2019 13:32:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0224.hostedemail.com [216.40.44.224])
	by kanga.kvack.org (Postfix) with ESMTP id E1DEA6B0342
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 13:32:02 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8FAF28248AA6
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 17:32:02 +0000 (UTC)
X-FDA: 75850756884.23.grain15_11bb8667e0b29
X-HE-Tag: grain15_11bb8667e0b29
X-Filterd-Recvd-Size: 4606
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 17:32:01 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 08B5142743A;
	Thu, 22 Aug 2019 10:32:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566495165;
	bh=VS7LeuGqbPwIcHqY2XBp8+c2oKqQvPTyP/4ofEIs1qM=;
	h=From:To:Cc:Subject:Date;
	b=UI+s7seUH3h+J1ieyZ9ZWXCsGPQYgN6+OC21RjWYBBs1BZr9su6WVbTIujTSfgpJg
	 adXZoGyymThG9MtCLbc1Wqcw/JeysqLe/FEZ3VMta5nPxE9bn78rdC5kkk1Sq416YN
	 E9vDeXw5dh7j/2ykrqLMLsgf/rClu6jMK575OIbNSNZ92GgYPkwvViewd0AWxjmyWT
	 hTIOP2XKMCLwgCb2sVea0U0oYHCHX2htPSMu1rYH3gSmFv+t6kCcee6mh7bYVg3IqU
	 CZKWQGyHZqx6P1EtEA2knqeCCPvdzyuVrHeUClCWLOz+2u7C/Z3yklCeU37gB2EzBW
	 TcV5mb9VOP0Ng==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id EE3F342745B;
	Thu, 22 Aug 2019 10:32:44 -0700 (PDT)
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
Subject: [PATCH] mm/oom: Add oom_score_adj and pgtables to Killed process message
Date: Thu, 22 Aug 2019 10:31:57 -0700
Message-Id: <20190822173157.1569-1-echron@arista.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For an OOM event: print oom_score_adj value for the OOM Killed process to
document what the oom score adjust value was at the time the process was
OOM Killed. The adjustment value can be set by user code and it affects
the resulting oom_score so it is used to influence kill process selection=
.

When eligible tasks are not printed (sysctl oom_dump_tasks =3D 0) printin=
g
this value is the only documentation of the value for the process being
killed. Having this value on the Killed process message is useful to
document if a miscconfiguration occurred or to confirm that the
oom_score_adj configuration applies as expected.

An example which illustates both misconfiguration and validation that
the oom_score_adj was applied as expected is:

Aug 14 23:00:02 testserver kernel: Out of memory: Killed process 2692
 (systemd-udevd) total-vm:1056800kB, anon-rss:1052760kB, file-rss:4kB,
 shmem-rss:0kB pgtables:22kB oom_score_adj:1000

The systemd-udevd is a critical system application that should have
an oom_score_adj of -1000. It was miconfigured to have a adjustment of
1000 making it a highly favored OOM kill target process. The output
documents both the misconfiguration and the fact that the process
was correctly targeted by OOM due to the miconfiguration. This can
be quite helpful for triage and problem determination.

The addition of the pgtables_bytes shows page table usage by the
process and is a useful measure of the memory size of the process.

Signed-off-by: Edward Chron <echron@arista.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a0bdc6..98cb3943e5a2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -884,12 +884,12 @@ static void __oom_kill_process(struct task_struct *=
victim, const char *message)
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
 	mark_oom_victim(victim);
-	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file=
-rss:%lukB, shmem-rss:%lukB\n",
-		message, task_pid_nr(victim), victim->comm,
-		K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file=
-rss:%lukB, shmem-rss:%lukB pgtables:%lukB oom_score_adj:%hd\n",
+		message, task_pid_nr(victim), victim->comm, K(mm->total_vm),
+		K(get_mm_counter(mm, MM_ANONPAGES)),
+		K(get_mm_counter(mm, MM_FILEPAGES)),
+		K(get_mm_counter(mm, MM_SHMEMPAGES)),
+		mm_pgtables_bytes(mm), victim->signal->oom_score_adj);
 	task_unlock(victim);
=20
 	/*
--=20
2.20.1


