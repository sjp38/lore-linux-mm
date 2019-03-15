Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C681C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E2732063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vzUF5/hV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E2732063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D114B6B02B1; Fri, 15 Mar 2019 15:52:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE8626B02B2; Fri, 15 Mar 2019 15:52:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFF5B6B02B3; Fri, 15 Mar 2019 15:52:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 95ACC6B02B1
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:04 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d18so13189715ywb.2
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=z/lbJIk5a8zt10jywFDNy5ZdetbtZxhqc2S4ejPNJ3g=;
        b=NM4OlT+vecKc0Y+5UYTrQgLIejnAYZe3TPjXmGzh+P2lbJt3lOoocsE9RLfJzjy81n
         +/QBG6goNNm0Mm2WNrw0fxKXQpPJVoPyZ1NDwG8L2xMMsVKJYP326UqvPaVRqhX3+lD/
         bbTOsmp0AWmrzrpktVQtqEjvZ5csFwpkZlRLlpGv6oXyQYrSLiAJD7FBssv45slhD/kq
         QdJI2oXeQtRgMBKlG5RgCBVpZWI4m3xGxTG0u1MlFGVZpQKeyxub6I+rwmco2oQkCLMO
         1cjO0nGEN50tJKB4+XII5y/KXFyJ9RoWSvgqK85Q/4QxFqs34puhAQQhCzQBGYK/fn1/
         obNA==
X-Gm-Message-State: APjAAAX42f9yno+01LmttRo8CWkujbamBN2wWrBxtHZgny9O95gzuBgA
	ArpluNigecwQAsWF4D5mpPS0HGkwXRWaRfyHF+/GqQ4c3Dl/tiBArw+g6yhK1n9N+fJatvnVNsb
	KpUXWSnm7b65DM8W2nvMCANFfvx8Wq14sOihJUgL7YImUb/M0230iTxleWQYHgcMRZQ==
X-Received: by 2002:a81:a08d:: with SMTP id x135mr4545620ywg.278.1552679524374;
        Fri, 15 Mar 2019 12:52:04 -0700 (PDT)
X-Received: by 2002:a81:a08d:: with SMTP id x135mr4545563ywg.278.1552679523299;
        Fri, 15 Mar 2019 12:52:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679523; cv=none;
        d=google.com; s=arc-20160816;
        b=RQNn+IQ9TJsTuCuYk4ak+nkP4Q3SZewlK2Em4JSui86qpxtvlmsZc6iJPCQOnPnrMC
         dFftTd1vY1ykW3cnjVG9Dguj20PrYaBamnslBC5YZM7siQlodZw4BjKQWQMDJM1BDOjc
         LKvCXl18H3EW6crW+APP6FDkg6bWn98CfeFdsgij2GAZhYmekoOrde+yHB80DvjVdYTk
         HM+yO4QO5nXvqxnkDBnz3Hr7Im2mEBuXqUAR/VwveIYMUoIEbUDuWIT2yXUvRnxv5NiL
         iTDEQBwS2wBMFSMz7gE+E2ek2AvBXnRlEQoI3UJlWEhOdapEYNfsP7GSD8+BG30Oncb8
         jfDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=z/lbJIk5a8zt10jywFDNy5ZdetbtZxhqc2S4ejPNJ3g=;
        b=LxZQvRL8CiYqlzM9FuOlHLgY9P+pTlBjWfegaDCPepU9TG2i3k+7SKoK0YwIqaB0c6
         bXSMzvo77NtfE+WFbiuVUIuF2HoibixVotHrgvxPydMI+Lk4fN5SMeqeLgSyKjLKvpaI
         daWLUR7scPWcsjHXqr3twcb4/+2axGthTm9mvkuFxfCcCre5nE3lu5EVJMo+6I3zjzzg
         asxbQwzuAE/d1EaYgHg79FvVJTq+6swR3sWuBzKTS2n6hFa2XVKEjaHlDsEgnvq+FN/7
         Suu86zZ8fJc8hw47vhBHWq4lu6CIF9xWd6u3lZI31pu2GL6DHjVukq9y2VDegS0i4bK4
         MF6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="vzUF5/hV";
       spf=pass (google.com: domain of 3ygkmxaokciefsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3YgKMXAoKCIEfsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h74sor537782ywa.130.2019.03.15.12.52.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ygkmxaokciefsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="vzUF5/hV";
       spf=pass (google.com: domain of 3ygkmxaokciefsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3YgKMXAoKCIEfsiwj3ps0qlttlqj.htrqnsz2-rrp0fhp.twl@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=z/lbJIk5a8zt10jywFDNy5ZdetbtZxhqc2S4ejPNJ3g=;
        b=vzUF5/hV3N6LymY3D+bJBpSatNRK6fXpwnZa/1KVNOg7xeGxEXTPkbw+wbEOfgpNDR
         np5G4rL7T1cd+Sz5iJ0RCOtU4P6bLZVS0l14Aq6zvISFR6mzBUWQWKFDoL13DmN3dbM+
         SpIGClyUMZd9169+i8j5m3A6jrJ+Hyb10rwBPEQoaeyLAtm17DlPNuWH2RVG7xX1Y6TF
         9LKSfozE1SWXebNzzat2ugJn18cSW7bw5YZG+7kazfWFB4UEOKlKg3watEf4bHP24M7o
         9DP2o8Vqy0brwdDfGOvD+zN5V6FQV40T4Y8K+j9OS7OnApB4pexBW7Q518EArWyVitEY
         H6yw==
X-Google-Smtp-Source: APXvYqzi5LEkko6ByM4uqeA/ILUmpPQs4A8NqtI2/DdkNKEbP39lGUp9icnx2HlBixyjeGCue9FZGuIPU0jeuK+1
X-Received: by 2002:a81:8a46:: with SMTP id a67mr2389102ywg.26.1552679522975;
 Fri, 15 Mar 2019 12:52:02 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:30 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <e12d6b5008f63b530d25ad73b2e3491939005c22.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 06/14] fs, arm64: untag user pointers in copy_mount_options
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, 
	linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, 
	bpf@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

In copy_mount_options a user address is being subtracted from TASK_SIZE.
If the address is lower than TASK_SIZE, the size is calculated to not
allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
However if the address is tagged, then the size will be calculated
incorrectly.

Untag the address before subtracting.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index c9cab307fa77..c27e5713bf04 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2825,7 +2825,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)data;
+	size = TASK_SIZE - (unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
-- 
2.21.0.360.g471c308f928-goog

