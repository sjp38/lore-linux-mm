Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D30AEC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8589B206BA
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JN7peWS7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8589B206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FEC76B026C; Wed, 20 Mar 2019 10:52:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58B9C6B026D; Wed, 20 Mar 2019 10:52:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 402CE6B026E; Wed, 20 Mar 2019 10:52:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5736B026C
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:28 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id y64so13388482qka.3
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=BhVJ8uqyuZN/RhYo8e4D2Wo6j82d4Ue7nF7755mNwHM=;
        b=h4ZuGy6EmMHZflRlWsXavzdORrbKMBgsICzQyY7BlMsXlw2TYvU8xs9dzdETQ+1JsN
         tz2cDxrfvADetgqg2XwsmAqpVS+aYgnWxzODq5AAlTLxYx11TVMzKwPdvZeKtnOy9/Gn
         Rpc0R25rT8pXJSrsNFPdC6kQH2awGnO/QABsqx+GNKFGwz8Cr001F/V6GfdjiH9LXIio
         6FX3vCrWlmhKCRfB2fxNnevm3JauxNhWjtHrWWEGUwhXY1u7k3fQQ/0Ky2kF33jX/rFg
         FflsOXaHK7k84lZ4wh8RYzGMleHiN3Z/w7APbVc+7S2xXFs1R7EV7++BUI1cgcyaKZhi
         GWSA==
X-Gm-Message-State: APjAAAV/68Qg2MdceZzxbMhzzt3IWjfmaeWztMf+SpvvgUfJwvpnAjEq
	i++K5X0+beEyZNs8tF6vE5jSOc7wG6ydzRsLyFEioA2693wy+FYfN/Ly4UFZYGFCFOsEUjOtOMF
	sRy3a1kjuiScyOdvMcjN2Wxyt9Dl6vI1m4ZZYjTegii5eMgzRlrIjO+vrDre/MYkLFw==
X-Received: by 2002:a0c:9ac1:: with SMTP id k1mr6821447qvf.36.1553093547884;
        Wed, 20 Mar 2019 07:52:27 -0700 (PDT)
X-Received: by 2002:a0c:9ac1:: with SMTP id k1mr6821398qvf.36.1553093547245;
        Wed, 20 Mar 2019 07:52:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093547; cv=none;
        d=google.com; s=arc-20160816;
        b=h4mXkMYRrZPEbIa1nDvnAU6fnizhPV4flCf0zkilACYhTN9wjICdtN6XmmiQ8QLbUL
         S0tzPP7z/vlJrBHmtY83zyO10zfvU+cZPl7BqxTdIsUaPq9KpaXWLqLvDBK8akGOKsRA
         9ZGNdvQGGxl8Vo24atnoHUCI23nHKN6DTYsJSWragMbPUWt4yTmysMrYrHrHgvQFtqvg
         LPdIToqUMcRW11CEFrl6HbaMtfWBTt/i+BGBcUb5+eTzKS/GyEK/mih/UMWXejKF1Tmd
         5Y/sT+xAmkjBDhwoAecfuMKHOMHorrqaTk/hNn/hbg0VZBkYHNeaHh4CphlEEbCyg06F
         1q6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=BhVJ8uqyuZN/RhYo8e4D2Wo6j82d4Ue7nF7755mNwHM=;
        b=JYB7+7CEhffpaMz3M05nUPt1NV6QQNaIJ6tgIu0naByW1SkQPKM5qf8GJ5bVrgYM1k
         xO9AfYov3F9+itPsD9c91OMewddh/9zFi3b2+x6bpzwepbTVcin2uJ+4kNVT9d8hMY+X
         Veol8M/TgpRiT/Mu9EaM4oYbo2mGcUkt0rNt6dLMH7QvHG0WLNTaImZH/3UAfsFV/Blk
         n1OxQ3Bkp1KFXi2pLDfNH2fgx+9LSkCr9e3uj6RhISge9dxjfVe9VIMSOHfPlvrpyY9f
         S+4Sn30rqEdLX5EHAifWJ40bwlKkjcna6PVlpOlRJ7JYfVFWQyADZ7h/afRtJjxhZnbR
         /73w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JN7peWS7;
       spf=pass (google.com: domain of 3qlosxaokciujwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3qlOSXAoKCIUjwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p123sor1738930qkd.121.2019.03.20.07.52.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3qlosxaokciujwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JN7peWS7;
       spf=pass (google.com: domain of 3qlosxaokciujwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3qlOSXAoKCIUjwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=BhVJ8uqyuZN/RhYo8e4D2Wo6j82d4Ue7nF7755mNwHM=;
        b=JN7peWS7Nez+2uGYBenvD1URtgpAIqAee70ib/k/sIrShjHTRTOTS60cMewca4/dl+
         dG9NPJL3RBHz+jByCPy9VsQpiotQxDiag9Y5aB1mow2uCgebTPUHJtgOnmaSI9Vr/YIx
         hQI/v/gR0GvyO5deZUXNGQI2iRQRxhpRf4qspE3jPUxJjXOAuD/wl6/iqPcyOgYmtLKK
         MWpwP9BARDOkmKwS67XX82wJzNDDELNK9gdSeTBhBvMrWdTjib0F+nJEJKUwKFoB/pDB
         SXeryLoUidHqjz93zv8BQ7DsI9WVz5TfwJy9iV6N2sA8iMykCz2Q8F38PNgxFh8B+8WB
         8apg==
X-Google-Smtp-Source: APXvYqwzO9qScb+3DLKygLOG3z91c2IWDiaev09n3TsGmqkOq4NcQ5CsSt3t0f+AffnIIDyplmnedU704klPsHau
X-Received: by 2002:a05:620a:15fa:: with SMTP id p26mr919440qkm.51.1553093546857;
 Wed, 20 Mar 2019 07:52:26 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:27 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <09d6b8e5c8275de85c7aba716578fbcb3cbce924.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 13/20] bpf, arm64: untag user pointers in stack_map_get_build_id_offset
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
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
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

Untag user pointers in this function for doing the lookup and
calculating the offset, but save as is in the bpf_stack_build_id
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

