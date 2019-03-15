Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EA2CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFE5B2063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="m8TjLlxT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFE5B2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71E546B02BF; Fri, 15 Mar 2019 15:52:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CDD16B02C0; Fri, 15 Mar 2019 15:52:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E5606B02C1; Fri, 15 Mar 2019 15:52:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 386B36B02BF
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:26 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v123so13111721ywf.16
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=sAfWvHiPwt89rwowuJd122MWpb2hIcncHtjST15rjKY=;
        b=NbtB3T0/3t97vdrygB89AoZUjRj2MQ4tWNwtpMTVBXY7kvmWlybCvYfIz7QOwIktbT
         z9D5CyJZVg2pqLQr3WDE49WO18dRyp1AIizRyu6TG8/2ZNkYgGWMXVfvbjRLWCyubweR
         fYHp/yxWGpmI5xIWBPy7kS2e3Xnu5NtxttXqFWdIL42taMe7EjnINyNUdtGJwW5q7RbX
         8BHM/KoS3/eGXn/weFi4NqKyQ0ldqMXKUxZw3V/H1P21pbK76px6l6UwqptFen1KzBJ2
         VFMBJxVaiga6WQqyBuAPT1XoSX/BeDmSI9FRD9b15W5DGUnq9G/vJrmRumKioSIMe4GZ
         EPCQ==
X-Gm-Message-State: APjAAAXZYnoFucE6ZKhJojXn9o/QAkuCrcUs6LgCQoHuhQozBwQqi+ir
	4zlldcX7OLq/uQ0gHUl+OsG6VGWSq+zkVpbjOBWYxe4MP8fcEc2dyJwMdqVyG6BS8C+Bt2k6wtH
	zXI3IGF7VOR536Aa2QT9Ts7/cBqHpx4m43mI5vTh4mg18qpGM+sSaP94Ww2Pm3qqyFA==
X-Received: by 2002:a25:7582:: with SMTP id q124mr4788920ybc.136.1552679546008;
        Fri, 15 Mar 2019 12:52:26 -0700 (PDT)
X-Received: by 2002:a25:7582:: with SMTP id q124mr4788874ybc.136.1552679545187;
        Fri, 15 Mar 2019 12:52:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679545; cv=none;
        d=google.com; s=arc-20160816;
        b=CvEa13fq/69vsoapHo3gl6Zr+VjmFx3ndJupJdSIGfrw4QBF0eb7MjSwAhdA3k8Sfc
         9achUukg6w/1HQEtU0kqxgcUNmeFeq32qvhcdZHXp0wva7CE6gn9Nua4HJ1mTTXOVRvV
         SCQCRDGM2xMvADdNojXqLZzuE98D6aGPziH58rrYHEKds465rMUx1OrOVlpsRhxlEwHY
         dyAha3cVkvxfbABR6pDJRXfcNAaCdMT+m+3vUDA+4pb0/ILb2lo6i0srx8XKbvjCEFky
         VD/M4pkIBzv2yoOR++EVdLBB88bYKm5vVNfWnB534++sshraOX81TNVGAIGI+a4nI8rH
         t1ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=sAfWvHiPwt89rwowuJd122MWpb2hIcncHtjST15rjKY=;
        b=yS/GyqZO8gOQatx4GMXq39w6K7Av4MlZ85DXhHPGCB46IA6AcYsmEFT1C3TZtVsf8F
         kEZvKp7CkbdJbw3U2212dQFvF9utOEuIk427oEmau6gCsObeDgAe35p+szSHCjErHdE9
         Q7ft7wIt+k5krYKul8pyX3nSGcEj7v4HKHsv0NeUe+d8UQMnhXcyu5a9meVSF97YLh/t
         3e1+QkZHAog95bDl9EWCRi7N9+XZZnV+lQcNZp885jL/jn/dzVg5JMOWOPv3L85/t0y5
         i7ey+FiXHHudvt58jD50DknYvmBURk+9ChCZtahM3KEkli+XPA40o05LTiVcEnsUcYnK
         V/Wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m8TjLlxT;
       spf=pass (google.com: domain of 3eakmxaokcjc1e4i5pbemc7ff7c5.3fdc9elo-ddbm13b.fi7@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3eAKMXAoKCJc1E4I5PBEMC7FF7C5.3FDC9ELO-DDBM13B.FI7@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i9sor1679568yba.142.2019.03.15.12.52.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3eakmxaokcjc1e4i5pbemc7ff7c5.3fdc9elo-ddbm13b.fi7@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m8TjLlxT;
       spf=pass (google.com: domain of 3eakmxaokcjc1e4i5pbemc7ff7c5.3fdc9elo-ddbm13b.fi7@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3eAKMXAoKCJc1E4I5PBEMC7FF7C5.3FDC9ELO-DDBM13B.FI7@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=sAfWvHiPwt89rwowuJd122MWpb2hIcncHtjST15rjKY=;
        b=m8TjLlxTJg+rOoEWUReYdn8rdh11EMoghrFHbVAb9WAMjVa0U/T9FqdGOvqwTZpUfm
         vVbcFLqWrP3TVwdj34DrYszJNIoQ9EJXeAXrC/wvs/z5IYKQAqYP9RwBD+8emDJu5PVP
         Vo+huuqc6PHspT4+rXUR6NPieF9KLiWfhrJ7gi13d3MatbDKM4RF0bkO2DrrarQnmyYR
         3h3NjRcSXCNOJ75ka4ui6zatbnk/g1PfEFqJlZRnqOTJFOnY1jqqoDx3fG9sQrGexBtX
         ZZ96/DuknTpKXEYqtVY62yQBCWP1T+ifr5PT3FJRXj7RVMG+M4Fgps93zJ4tkNbNYwin
         RjCQ==
X-Google-Smtp-Source: APXvYqx6fJ/Xf2Wycfnq24ZgFIr73HZ4gPKerA6ul2fF+VVXr0NweKm2RI8g9OR3XNR3hwcUmUxVL0qXK1MAydWo
X-Received: by 2002:a25:41c2:: with SMTP id o185mr2528725yba.96.1552679544923;
 Fri, 15 Mar 2019 12:52:24 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:37 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <bf0abceeaf32e6b9cdbc9dde45cc5966b5747ec4.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 13/14] arm64: update Documentation/arm64/tagged-pointers.txt
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

Document the ABI changes in Documentation/arm64/tagged-pointers.txt.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 Documentation/arm64/tagged-pointers.txt | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/Documentation/arm64/tagged-pointers.txt b/Documentation/arm64/tagged-pointers.txt
index a25a99e82bb1..07fdddeacad0 100644
--- a/Documentation/arm64/tagged-pointers.txt
+++ b/Documentation/arm64/tagged-pointers.txt
@@ -17,13 +17,15 @@ this byte for application use.
 Passing tagged addresses to the kernel
 --------------------------------------
 
-All interpretation of userspace memory addresses by the kernel assumes
-an address tag of 0x00.
+The kernel supports tags in pointer arguments (including pointers in
+structures) of syscalls, however such pointers must point to memory ranges
+obtained by anonymous mmap() or brk().
 
-This includes, but is not limited to, addresses found in:
+The kernel supports tags in user fault addresses. However the fault_address
+field in the sigcontext struct will contain an untagged address.
 
- - pointer arguments to system calls, including pointers in structures
-   passed to system calls,
+All other interpretations of userspace memory addresses by the kernel
+assume an address tag of 0x00, in particular:
 
  - the stack pointer (sp), e.g. when interpreting it to deliver a
    signal,
@@ -33,11 +35,7 @@ This includes, but is not limited to, addresses found in:
 
 Using non-zero address tags in any of these locations may result in an
 error code being returned, a (fatal) signal being raised, or other modes
-of failure.
-
-For these reasons, passing non-zero address tags to the kernel via
-system calls is forbidden, and using a non-zero address tag for sp is
-strongly discouraged.
+of failure. Using a non-zero address tag for sp is strongly discouraged.
 
 Programs maintaining a frame pointer and frame records that use non-zero
 address tags may suffer impaired or inaccurate debug and profiling
-- 
2.21.0.360.g471c308f928-goog

