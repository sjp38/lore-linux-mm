Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74927C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:51:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 221C72063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:51:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NsZbFgqg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 221C72063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 974AB6B02A7; Fri, 15 Mar 2019 15:51:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87D3F6B02A8; Fri, 15 Mar 2019 15:51:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7440F6B02A9; Fri, 15 Mar 2019 15:51:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 492D36B02A7
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:51:48 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id j127so8704976itj.7
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:51:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=7EwJOZO2FU3roQl0F5aaHfBG2l97MDWb8Nx8DHL3tHk=;
        b=ImXpPdY3dVyF4uos+NHMYqmET0QZDf9CRgmEVd/62wvB7DL96IqZDQr7xtDiqGxUmf
         ragvqgsCqM7oL/2xMgRXer993L5ZqyEYshfaiIFGwEfyTRyukHcMajkppMzGZ9W/j4EM
         vDhjDKGehhPaIqKzyPosdd28ye74HozKInHsfknyQD6Z6AlJehRA63YoPouSq11wCXTp
         Zi1FYeckA1AwhBI2Ubto5NLXoqMWhbAui4Ef9ytFH99BLYdtkdb7BYavwPMKW/x+PRHQ
         YNahWwpcqqtJgFn8h733cQbecD+55IwjVHMlboR1h7dOJg8cg0xVSYIm03gJecoyik1L
         Zr0g==
X-Gm-Message-State: APjAAAXjLuKeqXU3bZjqohTDb2IbT6xs30sz3UKXRYUZHGpEjRwqZXcu
	QlN01Xe+tb3VfgOrhmE2x0oJhqmWdUd/T6ol1dB6w1qljteBqwb2EU5klNBNqz9ez8JDCkwBxkN
	/qlkZM1PPUxy+dRbMarAE07QbuXyYHEz5XorwqKmlBZ1j9iFIh/v+9jGWyEreni99qQ==
X-Received: by 2002:a6b:8b50:: with SMTP id n77mr3192342iod.222.1552679508008;
        Fri, 15 Mar 2019 12:51:48 -0700 (PDT)
X-Received: by 2002:a6b:8b50:: with SMTP id n77mr3192306iod.222.1552679507220;
        Fri, 15 Mar 2019 12:51:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679507; cv=none;
        d=google.com; s=arc-20160816;
        b=GURPF5KHR90tDhuv+cVMcB26srsl7XibwPLG6UDR9TrEgABTxTCpsZKCPLHdCsNsPy
         QzsyklT4lNstsFXeWPLY/msoJggBP6D2KuQS9JwEhvkDxFjdw9QdTSTsDQ4lda0yVfWl
         qJby14b2Kl7yVuzV4Di2F+54uuvrB0OTY7ZDBXlwLs1d2uplTuQzYJMZQ0sj/90+3/zz
         AoGgxKi0DhZpsKBCADRJHkyMZslPuCfsyEgrk0CSiv5HiUsyRE87zxuE9DY3yKuLxJSx
         m9H5zw8MfL6pJ5aj0Xh4mGu/wgJ/vNz+HsrfZ7kf5towuha4kI8gozEcQvCrEt2dUp2c
         enXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=7EwJOZO2FU3roQl0F5aaHfBG2l97MDWb8Nx8DHL3tHk=;
        b=cscGM+bRc5KQ0RTrYfFXZPcWSylJc2b07fl8jldtO2Dz7ArGAkH2QYruMUHtQFr2nE
         RY8Xra/TWD2XIomQYDmHWdrd/CyIyOEVDQ95xKb5ND6Ig2Pr1GtIQ7WJRVqOOLIQlyfb
         cW2OahO7hS7bfz6Y0GGSSqBbcyAwwW/NQva7Rhn90SZUf60PAJ1ppfA698xU7heBJ4HI
         o+kueue/JdsKJRez5hzV996+uuoyBrra9DwzRNc0Ss5r+BujX5ELZ6KUvay5+BbLrSe+
         ImWfWe0Oqispe8CTh1Ek14LCNcb/pCbEV2IcjxB0hi3qS4Syvjss1YCGWPotxD/TIImJ
         3jPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NsZbFgqg;
       spf=pass (google.com: domain of 3ugkmxaokchepcsgtnzckavddvat.rdbaxcjm-bbzkprz.dgv@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3UgKMXAoKCHEPcSgTnZckaVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id s5sor3238580itb.19.2019.03.15.12.51.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:51:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ugkmxaokchepcsgtnzckavddvat.rdbaxcjm-bbzkprz.dgv@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NsZbFgqg;
       spf=pass (google.com: domain of 3ugkmxaokchepcsgtnzckavddvat.rdbaxcjm-bbzkprz.dgv@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3UgKMXAoKCHEPcSgTnZckaVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=7EwJOZO2FU3roQl0F5aaHfBG2l97MDWb8Nx8DHL3tHk=;
        b=NsZbFgqg7rNL+MmKx3BQKEQu20uV5j38Y50xV/nkSWdpaI1ml/U6N36zAaOr/fw5UA
         vw0RHRh7TFVUW8EczyoyJgPl2GwQ0O2Y3mdoA35Hyc638cKh6Ou6T8eYWBn4JvcpMD/p
         rAobGvHGGcaX0d5KUxoitmIQyCm1jnvtMKLMyUhfKXJwo6H8C9LXAnbI3Vm9NBlauUvF
         LSPFoGZmvnqqM1DaPRlnN62YYv9Ww/FkPY+qI6Xd7c1DGMrBJfACmaSSGw3vWzqTDpi4
         0fO7tv8nv58nySaGO3aBtIsMUSYoC0bWVWTZpEnNl/6BuoGd6099E0jO7AssN7waL7VF
         i1Ag==
X-Google-Smtp-Source: APXvYqw3EhdS69JFOaj1SqCWxq2uMXIiNWdBlJ3prBk3wjQoeZqkO0NrFGiKQ0BULG0Vahh3MxRaQ9/Jyb5Vnlog
X-Received: by 2002:a24:7bd3:: with SMTP id q202mr100068itc.32.1552679506915;
 Fri, 15 Mar 2019 12:51:46 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:25 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <bee403f76b40f37c6790d144a4142f293e0a7d9f.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 01/14] uaccess: add untagged_addr definition for other arches
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

To allow arm64 syscalls to accept tagged pointers from userspace, we must
untag them when they are passed to the kernel. Since untagging is done in
generic parts of the kernel, the untagged_addr macro needs to be defined
for all architectures.

Define it as a noop for architectures other than arm64.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 76769749b5a5..4d674518d392 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 
+#ifndef untagged_addr
+#define untagged_addr(addr) (addr)
+#endif
+
 #ifndef __pa_symbol
 #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
 #endif
-- 
2.21.0.360.g471c308f928-goog

