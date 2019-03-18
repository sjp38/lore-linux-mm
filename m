Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EC12C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19B6520863
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OVRG0jDx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19B6520863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E0DB6B026B; Mon, 18 Mar 2019 13:18:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D6AB6B026C; Mon, 18 Mar 2019 13:18:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C54B6B026D; Mon, 18 Mar 2019 13:18:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id C62026B026B
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:18:27 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id i21so23341930ywe.15
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:18:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=hfuKek+o8vy+53O51p2MPtj2JUyumu3LZdujtPFxXko=;
        b=R4Ti6TvpQx8kuYPuSTWX2PmU4J+jvHSOfjVRXGgYN6Bg1Tz4XV1gCh7KG5Nz/yizc4
         HBzFFHCrtmlV2QbSKG6rzkx+etthfrTVm+hnZTMW+TfC8Pis6NwWttApVbxQwLU00H1W
         JndDvJFcfXNXXZ1AP0rJxs2OIGYNvQ7LNO7lRMUZcHNNuob8YU6EMi4Q4JhXG6xw93SD
         Md7Q28OpL5d0ZCSfyxv80HxtfoIst2l1X4n4JvczH2th1IfAAPfM6JONN3pwOgXj53n7
         kzKaOJT36GMVAF9pSFG2lR1MXbrh529DCKzu5lBICo9M5dJ1eYh74hxQ3Z7GpyMRmCYt
         HB/Q==
X-Gm-Message-State: APjAAAUTcia3GOjUFPPgWAeZ51PiuSDMM+m/tGdeDdT0mBjHaWXonU6O
	Dkn8i5GUcQEwwd6xbh8UWeJKLn6XIUMgT3523ZFjy8C7l/H9WloUmSsGdy5VpauHO7DgwL/cBkr
	PA6F9RfgpzuHzG8rgCtRTCxNtPGmwwunzBSvXMcqsKiVWXCIbGGMXfQeqMo6y+9euiw==
X-Received: by 2002:a81:a0c7:: with SMTP id x190mr15223845ywg.62.1552929507551;
        Mon, 18 Mar 2019 10:18:27 -0700 (PDT)
X-Received: by 2002:a81:a0c7:: with SMTP id x190mr15223798ywg.62.1552929506682;
        Mon, 18 Mar 2019 10:18:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929506; cv=none;
        d=google.com; s=arc-20160816;
        b=Yw+/bhz27rSweops0dxg+IaJ4xZQHMdUQzUg5ah9wCrV0V/Q7ihBPZAmmk1XjaLFvl
         avlA23kcFYDBZwu43wYltQgPMxqFK/Rj+R/aM/QEwmD1SZtHsOZUuXJSLLDuP8w+kKaH
         L1ALPkUdWG8sQkrWWDDju/Y0jLYOvsptavBNui9wJUEIxYdnwNjPlXyrDwatjhVl99q8
         N0KoTsa0aYK5IpWa+Esu+UmrcFi6A4Zoc95XnbXyX793ETGVXjNVnJKqaqV4VCgPIKZn
         3g2APVi0JlL+WzdRQZihNF3VY8wTOXizj2I8KIMPLdQxxl1/AVZWIWvfTX9Y5txwDPTo
         TWkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=hfuKek+o8vy+53O51p2MPtj2JUyumu3LZdujtPFxXko=;
        b=T1+b/NtMKUUfketDsPxeziT1DQqxP4pBwV/M91N+fSZqrfADBvnYhsjH2WyQSp7lDZ
         PXL8elZmjZNP23ziGmkngRc+exOE8J40wv7Mcp1E3JT6Dym5bYK4hgJycCkp/JbeMe+j
         oMj43/RWsLPOR/63pnX0fm3RnXMWRfNcQlElXqk83lcbHyLihc/JtpTrQT8rRQ5gWbmx
         Y7EAm9KRHYwggNMeiqakoFnC3bfHbOqW9jVnRrHE4FLhoARplCauPR8MUc/nrRhUpUYv
         3jAlLXQNa/E3MMBIVXpWICshk7AeOBjriQ654tz1et+aWm+IitBgCleGTDsxAtHzt7v7
         kSVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OVRG0jDx;
       spf=pass (google.com: domain of 34tkpxaokclereuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34tKPXAoKCLEReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v13sor5038075ybb.64.2019.03.18.10.18.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:18:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 34tkpxaokclereuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OVRG0jDx;
       spf=pass (google.com: domain of 34tkpxaokclereuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34tKPXAoKCLEReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=hfuKek+o8vy+53O51p2MPtj2JUyumu3LZdujtPFxXko=;
        b=OVRG0jDx+a4bA2Xe0x2W0QLSaeWfLl/IABe0xhS3IFP8diCvylSVwKQWoIigEjNHVc
         yxjFs3rDXFN+YQZXXdBXqzoVuEhq+g8HP9vfnj/K/jnMV093FMqmv6YIj0itG5FlZbO1
         ke03j95r0/PkzmDHuCN3H9fGFOQlTbWpbvmuT2QemWXQk/lZDOT0fPG1qeBd7bYvwCAL
         AE3Z9++g1iD+M29C/0LdG7U5gglyxyekWqwWKO87UeLRgDFAy26KL+NKf1x9Z+3nMGJh
         HWwxBBm2ki5StK4NVq41umliE7Ge0hSfeTd7JwuOJHWr+3LKBGyWEd26Ba9MwuaG3MTr
         +/EQ==
X-Google-Smtp-Source: APXvYqyE9Hf1UP7XaN3S1ukCc+WMyyJkC7y8Hk/2DK6LClASlL+h1czCzSFlt0sWM+JMT6cpK2e3Il7FKfoAeEtz
X-Received: by 2002:a25:e648:: with SMTP id d69mr9320791ybh.95.1552929506037;
 Mon, 18 Mar 2019 10:18:26 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:44 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <7883ff7cbe2e8075c3a0f450eade08587f49f3bc.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 12/13] bpf, arm64: untag user pointers in stack_map_get_build_id_offset
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

stack_map_get_build_id_offset() uses provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag the user pointer in this function for doing the lookup and
calculating the offset, but save as is into the bpf_stack_build_id
struct.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/bpf/stackmap.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 950ab2f28922..bb89341d3faf 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -320,7 +320,9 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
 	}
 
 	for (i = 0; i < trace_nr; i++) {
-		vma = find_vma(current->mm, ips[i]);
+		u64 untagged_ip = untagged_addr(ips[i]);
+
+		vma = find_vma(current->mm, untagged_ip);
 		if (!vma || stack_map_get_build_id(vma, id_offs[i].build_id)) {
 			/* per entry fall back to ips */
 			id_offs[i].status = BPF_STACK_BUILD_ID_IP;
@@ -328,7 +330,7 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
 			memset(id_offs[i].build_id, 0, BPF_BUILD_ID_SIZE);
 			continue;
 		}
-		id_offs[i].offset = (vma->vm_pgoff << PAGE_SHIFT) + ips[i]
+		id_offs[i].offset = (vma->vm_pgoff << PAGE_SHIFT) + untagged_ip
 			- vma->vm_start;
 		id_offs[i].status = BPF_STACK_BUILD_ID_VALID;
 	}
-- 
2.21.0.225.g810b269d1ac-goog

