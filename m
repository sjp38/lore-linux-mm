Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB9A3C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 18:56:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 911E220835
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 18:56:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 911E220835
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 364738E0002; Wed, 13 Feb 2019 13:56:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 313568E0001; Wed, 13 Feb 2019 13:56:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 229668E0002; Wed, 13 Feb 2019 13:56:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E16108E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:56:52 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id q20so2351901pls.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:56:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=SKXkBFNvapZ4DaF+ag7lUAJTMr4zrpN0lgNEsPaOdds=;
        b=PlcXdSwOgrZHvbr6QUc9RQPKSX7G3vDUQ5pOrO9dMKvy7SZYj9GJCp/QmZtnmXpHQa
         JG7m3FnpBl1XpLmRgHAuRDKE8iVAjVALxVBBU4WvXzErMeHI3pXQVyFkW9GlCOMuPJR1
         BOoOLwdolLNhtHHKJwiC6xQMWqAMRkp+TvdDqAQ9tMDNsO8R6KpQFkDXhRoHIjySrAx6
         Sm0+zQ1XdBDC+vIGrAbM8+6bfthgu8LS2M4sBFLzFjhMxi8HGx/wxF7Pai6zwTHPiOGI
         IwotqVAjrghsGZQun4AfnlX5GAbdkiYgSaH0T6iRjtWxTtNUvr8qmJxELIBd5UhiXeeO
         iRSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: AHQUAuYd62NvQqPRq9Ufp2pAHXMQ1F8bTxfTwn12K1bsG7ixVnTGAW/p
	OEAdCuhycvVI6y8NkM7P54oOq0Q8hmImC6FQ81LcmCW04qYcNFOrmcSA75W4sTeihJE8GHU1cNB
	TLbfzozFcgS58C4atv9URKLNX6jppDoeTdN97m5RGVWsRH7uHGndZDkL/iZNtK5n/ug==
X-Received: by 2002:a62:5fc4:: with SMTP id t187mr1919931pfb.66.1550084212584;
        Wed, 13 Feb 2019 10:56:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJ3y9jWv1KzAhQ+qJICR5ZZJ4QIrbabsdrk7/rQYzZDKgaL0c62Hv6HEC3XYVBoD+So2OT
X-Received: by 2002:a62:5fc4:: with SMTP id t187mr1919866pfb.66.1550084211487;
        Wed, 13 Feb 2019 10:56:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550084211; cv=none;
        d=google.com; s=arc-20160816;
        b=d9FXv1ll0bpkb0PyMhnkxbuNPbeE5a98jeoZIkIy4V6EUbc868r+Djk5gNOVAM5QvV
         d/4/tarheh3XlG59PmPo3loB2lSwnAkN851KvvoZwyauvaQ+NuUVcAEQOP2iw3zcqHqQ
         CAVI7RR2LYUfVxRLKDiZmUepggYCbiRRzFIEDEt0eSlCFcMCzWk3LKTj/WzhmEK5D/Yk
         ntru87QTEIabiwa3hq88Q0+uyWsro0c3tziDka6lHwfvmPy3gC2SEvKyK95m+fjW0Pc5
         PEtvXJG1Dun8CerUnsY0aya0QPW46nrl3yxpZo45FenVKr/UU1qQEqq/iUvezj7Xrb6U
         M9mQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=SKXkBFNvapZ4DaF+ag7lUAJTMr4zrpN0lgNEsPaOdds=;
        b=xD6LtyJPFM7xejLBV0fQcuUfD+714/PBKBLYtU/En8v9Qi9TvYQzISFfCXozpzpyPh
         IIayLCur70NDLaiJsNYojwMwlBn3YIGhVXOngU/kPc8FGY4t1L8EQQNMPZ49YK4/A6G0
         SmBdbDFkAIGnAy4ibCw23n7yhQioJfyoXYYxdBoQfTvBwJVsQtttwaMyxpU+X/M2Z1Ip
         BYSh13J30mRwNWWG7wsBfxzf8Ueq+R72zPlZB4aMjlJ4LHoJgo+xo3I1VceEXoa/HWTG
         U+6wtj/j/k/zlMufHNiqnf1TGPzOcaAc8fAMMCOgN/3EuQvO2UZDcYo6WFhQzZqp7Ymg
         q9Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id b4si60438pgq.43.2019.02.13.10.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 10:56:51 -0800 (PST)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 13 Feb 2019 10:56:49 -0800
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id 91600B221C;
	Wed, 13 Feb 2019 13:56:50 -0500 (EST)
From: Nadav Amit <namit@vmware.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Linux-MM <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Nadav Amit
	<namit@vmware.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Gargi Sharma
	<gs051095@gmail.com>
Subject: [PATCH] pid: remove next_pidmap() declaration
Date: Wed, 13 Feb 2019 03:37:36 -0800
Message-ID: <20190213113736.21922-1-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 95846ecf9dac ("pid: replace pid bitmap implementation with IDR API")
removed next_pidmap() but left its declaration.

Remove it. No functional change.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Gargi Sharma <gs051095@gmail.com>
Fixes: 95846ecf9dac ("pid: replace pid bitmap implementation with IDR API")
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 include/linux/pid.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/pid.h b/include/linux/pid.h
index 14a9a39da9c7..b6f4ba16065a 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -109,7 +109,6 @@ extern struct pid *find_vpid(int nr);
  */
 extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
-int next_pidmap(struct pid_namespace *pid_ns, unsigned int last);
 
 extern struct pid *alloc_pid(struct pid_namespace *ns);
 extern void free_pid(struct pid *pid);
-- 
2.17.1

