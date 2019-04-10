Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 009CFC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE567218D2
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:06:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE567218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 700C16B0281; Wed, 10 Apr 2019 07:06:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6879C6B0283; Wed, 10 Apr 2019 07:06:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 541746B0284; Wed, 10 Apr 2019 07:06:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 028B66B0281
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:06:08 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id b16so1199153wrq.10
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:06:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=vE/h4iTaYWv2pX1V6FXNHaP6c7n1dI5SFaeY9qpaUbU=;
        b=dlNZVmWOldxpOhI9HRyQiQGneLgXEM+e07kPWFUO4Br3qv6Gdi7tTEUof1kNLmHckC
         YIuXFLU01I6PytYZSTPA4tF6YiXuFTvsyX/9XFNZOXoSB2zYLbANTSBiU8RFjT7xEShE
         evWLUWv+QxsM2FCaa3OqTjdRgUH7C3zgmmUKi6GN4C5kTTQIo3kDHIX21RCdNlSAA08N
         98au5vilL9AbE3bUYyZz+t49Xf+sEiWKT4XE2ib8/pqiuP3q5sPOjEwB0DUBDjCk9fbl
         VABe236RSaOHZLEGqYMl0sn2d7QOpHR5Qn9vId5fTJbwQQIRz2xgjFEAGfFdzg3qWwhJ
         2d4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWqCseqvMuTHG+xDp3EWjZqfgqU1vfHT4RW/MWQF3jd6Nv1aydu
	jtoPDXmc+I9TXESCzkp61t1PNgC7b8gaSThdTb/JAahIdhrY71EZeddjSF3s2TRnGzgqUvLvYG6
	Em/X/KzW4SH2AnLxw8jQ+2Rw5NW7PVxiT6Cmw0jeEd17XvpT4XZAu3EtWV7g2ebRQZw==
X-Received: by 2002:adf:b682:: with SMTP id j2mr26539235wre.3.1554894367534;
        Wed, 10 Apr 2019 04:06:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGz+Hwf+jrFzne/SU7o1727N7cW1Djv+Y1JinQhzZtD9PI0ooZCLq8mj/J1nNpqR1AmHIc
X-Received: by 2002:adf:b682:: with SMTP id j2mr26539141wre.3.1554894366297;
        Wed, 10 Apr 2019 04:06:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554894366; cv=none;
        d=google.com; s=arc-20160816;
        b=fzavHkbLqJaYausELyWTwZKqbIhLsBP7sOT13DmUAETzf0xL9h7LQEs9TVe0UYRoiz
         QkBOVSiE/aubdY9OdQGuRGmy4ZKure5Cl8gUjunl/pMoCM2Pg/jXu/MqGBxxFfXUiFKp
         iLSQ6xFcwF0JWUOlbrbTrGeF16R9FDLoudExPkLcmNoplUFYxVdOkiI26fH7eWSsIC00
         ypeyPY6J71hIyd+vEe5zxBuBSwv7EV2xnuyVT08Czvb6mGuKsUZtE7wZvy5Pqwrm088h
         1tRhXLgsbrMwKkovdSQuRayRFL4A6FmoivccMwDfN6eq7s9bto/QD7wDYEJ+KqD/3kJl
         9uKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=vE/h4iTaYWv2pX1V6FXNHaP6c7n1dI5SFaeY9qpaUbU=;
        b=RTCmgMyr+7WchBXPpTwpAXKesrbyaWkcMbPF94YjlxcGCGc5gAP1zb1LJOJOPVSWh5
         LXEKmI0Q+s7Z2T4HyNijY1aXFPYnlSE2TONswPceePD08PufUJ6UjRh2hIdKeXiok9j2
         kYAGzzoKJ6493/0f2bdnwzpuG+HJsxxDGC0xKfAWHCcJuyKJuhH6ebYr1j30APUS70Xo
         nmjuEY05quz26otBYGu18G5NpSoCAUJ1i5DqXi05gYaYV+B8E9RB8MgsnvNZnY93i+pN
         EX/8sK6J/VgvrKNwg6gRTx0dwX8x8YVPsmMv+AR8hor39SKdwqq+OrzkMb/th7j0tVFN
         vqEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z1si23395478wrm.153.2019.04.10.04.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Apr 2019 04:06:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hEB3G-00059b-0M; Wed, 10 Apr 2019 13:05:58 +0200
Message-Id: <20190410103645.774527030@linutronix.de>
User-Agent: quilt/0.65
Date: Wed, 10 Apr 2019 12:28:18 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org
Subject: [RFC patch 24/41] mm/kmemleak: Simplify stacktrace handling
References: <20190410102754.387743324@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the indirection through struct stack_trace by using the storage
array based interfaces.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org
---
 mm/kmemleak.c |   24 +++---------------------
 1 file changed, 3 insertions(+), 21 deletions(-)

--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -410,11 +410,6 @@ static void print_unreferenced(struct se
  */
 static void dump_object_info(struct kmemleak_object *object)
 {
-	struct stack_trace trace;
-
-	trace.nr_entries = object->trace_len;
-	trace.entries = object->trace;
-
 	pr_notice("Object 0x%08lx (size %zu):\n",
 		  object->pointer, object->size);
 	pr_notice("  comm \"%s\", pid %d, jiffies %lu\n",
@@ -424,7 +419,7 @@ static void dump_object_info(struct kmem
 	pr_notice("  flags = 0x%x\n", object->flags);
 	pr_notice("  checksum = %u\n", object->checksum);
 	pr_notice("  backtrace:\n");
-	print_stack_trace(&trace, 4);
+	stack_trace_print(object->trace, object->trace_len, 4);
 }
 
 /*
@@ -553,15 +548,7 @@ static struct kmemleak_object *find_and_
  */
 static int __save_stack_trace(unsigned long *trace)
 {
-	struct stack_trace stack_trace;
-
-	stack_trace.max_entries = MAX_TRACE;
-	stack_trace.nr_entries = 0;
-	stack_trace.entries = trace;
-	stack_trace.skip = 2;
-	save_stack_trace(&stack_trace);
-
-	return stack_trace.nr_entries;
+	return stack_trace_save(trace, MAX_TRACE, 2);
 }
 
 /*
@@ -2019,13 +2006,8 @@ early_param("kmemleak", kmemleak_boot_co
 
 static void __init print_log_trace(struct early_log *log)
 {
-	struct stack_trace trace;
-
-	trace.nr_entries = log->trace_len;
-	trace.entries = log->trace;
-
 	pr_notice("Early log backtrace:\n");
-	print_stack_trace(&trace, 2);
+	stack_trace_print(log->trace, log->trace_len, 2);
 }
 
 /*


