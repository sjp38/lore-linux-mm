Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCD7CC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:27:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BED82084B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:27:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BED82084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24A8A8E0006; Tue, 18 Jun 2019 05:27:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D45E8E0001; Tue, 18 Jun 2019 05:27:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 075EF8E0006; Tue, 18 Jun 2019 05:27:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB5708E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:27:12 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id n25so457882wmc.7
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:27:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=wLTPJBXZmunStbE+y7KuITwpU+6UYwCLQzOFUh6PBJc=;
        b=RKRa2rULCISKONTTpodBYs4kH7p32E2o9FpvIFBh56+2KqEhqElGXN8BX5/O2zL+Kh
         ZN26et9+MzSiIv4NuOw9R43zSwCpi3h7X5fu2RL7PH+798ldzCALqCV8hN3CFdN7TK89
         YG/DhKcPEzmjdEY4mCmoKtzPXdbyJtk8Dlc2vWQc3gdw+6KDYbd4UaKHDVNL8ZiikuG2
         hkRYV5dC+MAXJ8T3bii5gHgT54JHWKm45gWyLoYKURJ00nK5GHZ2fsie3e9dT4/PKqTI
         DJq9qSg/FKsk/MP7KVqpdiG1KqyYQjoLLBAu5rex1vy6FoZbBHjD7DiWk2AfMicEL2un
         nwmg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.72.192.75 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAV0Ik8CiLpFTbYv4eoGL085y8jDCipKL726m6mRuiIyq/zC1NMs
	iVqKZc05bPssB53k8frOG//NoUGcuS+nJkAMuWDEKaFlwugzuWX1zeGgxLW8ax0AAb6iNWsAv/o
	t8YSP58MVZqerId/qgzFbyOh8azCLLX2d3iW0fMQy3P1FcFJKjlW1FjgiW+c7HO0=
X-Received: by 2002:a1c:99c6:: with SMTP id b189mr2677607wme.57.1560850032197;
        Tue, 18 Jun 2019 02:27:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzC+4rOvGmCISv+8DC0w/fI1IbdEkMZUC9EBAm8vy2QDOadnjMe+Rg+VIKDyUrjQfgr6x5m
X-Received: by 2002:a1c:99c6:: with SMTP id b189mr2677528wme.57.1560850031284;
        Tue, 18 Jun 2019 02:27:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560850031; cv=none;
        d=google.com; s=arc-20160816;
        b=CKIwlv8UUDzJPQ8Qds8pxR+rwnuUuS4z7conFz6TIighkUFX3yCBnL5dwogBPC6Yr5
         pBq4W/hEklCorbk6erzMMw3L4qz5kWra6tx6JbE+q5ceOOLD7lmDp0EbYPqS8sJhgyeO
         6RFdPWx0tJc9znGSo/zbulr/EoJDP2BSirfpADKbZzOe0OrIOkctU7LVxsmz2g4HBF1h
         8WKcGe9hg7wAyBkAgcWrJ7fEupqc2TMA89tHBvsc8DatMcHQUZx+akJ82YnEgS3rTS2v
         6phvpvXZLvVAjvaBbc6jh32JOsTjzpbaCNT67NXulV+Q4nQ3+CyQ4J4hLznFbHkX4dQZ
         IXzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=wLTPJBXZmunStbE+y7KuITwpU+6UYwCLQzOFUh6PBJc=;
        b=JByRZrtTapFGYs5daPECsvYxdLNmOqNDhWWZFWAgW3rSWGiDt82Bk+ihxGQJFriuV1
         ower5H54maEgtgPySyPHsn5+pgdA0HxhhiB4KDezV1Ny346q+0Tq92eWsZhpAgRPxJzn
         qeZ5Nub0eDl84duzAhbPHHFzsLWu5qesU5j7lXB2GvGl7y3FvEPBtV6Kj5fjpvfdxPuo
         A34ii7fKdvPm2HObYNi3uWO7gQeckvIuhOgjc5blQvssZr5PZbq8QuXSMpeHOewPsGvE
         H92xMZuyxK1SNT+8glCz2c30/L9axBZtvafghHwNTshl9WACUVbN/uOokxuBbpDPpw0o
         Tufw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.72.192.75 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.75])
        by mx.google.com with ESMTPS id l1si1408179wmi.5.2019.06.18.02.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 02:27:11 -0700 (PDT)
Received-SPF: neutral (google.com: 217.72.192.75 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=217.72.192.75;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.72.192.75 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.145]) with ESMTPA (Nemesis) id
 1MPGmZ-1hyPk2355h-00PcPO; Tue, 18 Jun 2019 11:27:03 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: Roman Penyaev <rpenyaev@suse.de>,
	Uladzislau Rezki <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Arnd Bergmann <arnd@arndb.de>,
	Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/vmalloc: avoid bogus -Wmaybe-uninitialized warning
Date: Tue, 18 Jun 2019 11:26:28 +0200
Message-Id: <20190618092650.2943749-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:9NZTdj7yHA17SVjH2nsfAF6APnEovvSLZjPtTFenlB3oKrJaDJO
 stMbkNAyqRtMaQzlUFZq5gMFl9e5fUH+jLGvVh/1GxRU2mwjU22tOO198CJxWdQkTkKa3Gf
 n2Ur2ohACWrOuIv4HOFefTF6AimVTY39XDgbKSv4ASeO4vIQjq/vqMliduz7kXeQ4KpTxPc
 FDvntWSMeWiJ/cL7slu9g==
X-UI-Out-Filterresults: notjunk:1;V03:K0:jKozyIbKSIg=:4cBighBCTsEi6eFn3Hf1bU
 lTcJF857e6/rZJtR3ljY7QsUglzRcHnQctUHBRPg4y7AiM72cT4uMwRE73kKbK9g5TfwHQY8E
 VQilimjiv/r9kBJAzUZsudyviQqowepJjhFdgOacpEfKiEyWRFRZzzEK6FZOtll9gkRkzOw5r
 8xWT+IqMLi46wA1sStXC+tY/TlF8odu+MWInAbwPk8kRiuCZk4/LkbBrF90jUwXkC4+mH92Jo
 2jRAdjtEO5vQzkNvDlvxnGwwAXDMuinixOGPoDemcwmEPEz22KMOurOO/MxO9QIohwC+wlT67
 f4RVwVRt6BSqgFPXhop+vHSLMQCzafwkOiwhy0XGeUTympDL/b4MkJOAI98cA+pPZJ51IYdf+
 T2X99HWuhxgfjNC6X955THzCzutkwalUcQlCMmjbCdUoQ7Ntx+VobHF7dP5pKP7mda2QWVLHr
 PMjQhKGJT36gCvyMPyfPMNihxXGlX4NBilG7RFYqQd6MrUb40xcMB7IXKzIF8iemdM4lu6gjk
 MDWpUYsKFl7TFnxdCaTrTUMQnbS6D2C95hR77lH2COVISmVvutl9mmRtrMlebExExKkZZLiSF
 GTLThNbIGCAfmNu+T308kS6mfMbrwQ/SzFGeU9WsWRbSUwA7vsylBi+XUT/uIXY8CvCU+exgF
 m7P/Nf1kStwR/esTk5NIlZy/BJeqFP35zmhqtflX9Mt1sq3qXynZjCZFasJkvEGZCg+qBIJWW
 Y6t8thZrqAtdN20hVu4ohWcIwAk59XoX4z5hSg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

gcc gets confused in pcpu_get_vm_areas() because there are too many
branches that affect whether 'lva' was initialized before it gets
used:

mm/vmalloc.c: In function 'pcpu_get_vm_areas':
mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
    insert_vmap_area_augment(lva, &va->rb_node,
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     &free_vmap_area_root, &free_vmap_area_list);
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mm/vmalloc.c:916:20: note: 'lva' was declared here
  struct vmap_area *lva;
                    ^~~

Add an intialization to NULL, and check whether this has changed
before the first use.

Fixes: 68ad4a330433 ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/vmalloc.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a9213fc3802d..42a6f795c3ee 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -913,7 +913,12 @@ adjust_va_to_fit_type(struct vmap_area *va,
 	unsigned long nva_start_addr, unsigned long size,
 	enum fit_type type)
 {
-	struct vmap_area *lva;
+	/*
+	 * GCC cannot always keep track of whether this variable
+	 * was initialized across many branches, therefore set
+	 * it NULL here to avoid a warning.
+	 */
+	struct vmap_area *lva = NULL;
 
 	if (type == FL_FIT_TYPE) {
 		/*
@@ -987,7 +992,7 @@ adjust_va_to_fit_type(struct vmap_area *va,
 	if (type != FL_FIT_TYPE) {
 		augment_tree_propagate_from(va);
 
-		if (type == NE_FIT_TYPE)
+		if (lva)
 			insert_vmap_area_augment(lva, &va->rb_node,
 				&free_vmap_area_root, &free_vmap_area_list);
 	}
-- 
2.20.0

