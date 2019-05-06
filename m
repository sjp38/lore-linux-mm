Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FCACC04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:32:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA96520B7C
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:32:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZAV3tC6y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA96520B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 241146B027A; Mon,  6 May 2019 12:31:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2157C6B027B; Mon,  6 May 2019 12:31:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 130676B027C; Mon,  6 May 2019 12:31:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2DC56B027A
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:54 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id g1so2714736vsg.13
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=E5WO9ODhUeb7gchIl3e11LSllsWmM1E2YpuEe+KMyVo=;
        b=Pn1e8VUd53wLulfuyRGx1tWxZlC6KqhVNfFHp4p6BBk+5BZozH9RHVLUgPS0ds1JYq
         C+58jaX0c/Uv7FY6zcAdqUE6pktF4ZUv6nqbbldRuDQxJPwnN5V5Se7WA2VVV24qhSJE
         f3cNNucIp2xNYmaE+qmzdMXpAycCOisPYsYOmoKLyvQfco/PLdtb/bY7Nhtz+pfk7OR5
         JNfTqw6LVAX3+DNhwDhu7XFNWBaSaHhXHIOxfa6A2wapsNdQoBhJz10LhyUPPg44bYfi
         uAh+1kyG2ek1XeUBPNSrboBALFbbgu49w+lTo8IQr3g0OC0GGJlRzyEj/Peb6gwA4eS7
         hWnQ==
X-Gm-Message-State: APjAAAV6JT0YAMOp7CoDmgScIUwWXahoedt9MugFUNBtnASdr6D8DRas
	VEgRr6b3TABLrLqc+jLIrSySt2J7Pf/uWHx8YWF8u6WIXJhaRVvuxS5LOMMQ2uBryMVbV/dcaJe
	mfqnGAIBUxmWnUk0FIRrk+Z302THmAxCexddTMQFqx7zSj1kCGAjD7xThWOWucTTnGw==
X-Received: by 2002:a9f:23c8:: with SMTP id 66mr12818940uao.76.1557160314575;
        Mon, 06 May 2019 09:31:54 -0700 (PDT)
X-Received: by 2002:a9f:23c8:: with SMTP id 66mr12818893uao.76.1557160313905;
        Mon, 06 May 2019 09:31:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160313; cv=none;
        d=google.com; s=arc-20160816;
        b=dWmNhln34dsK7D4oKA8ZQPAUgUzo+wuQh1oOt3HD16jVEQ3DM2LkP8DLVppPlnFr7H
         oiLA0B4QShFOa7r4DOGS73XOWcuYpQwnCfEdj8ZK7yeLgk4mWQaHvDcOK6CLu08R94Wu
         ha24D/tyYQ7AvqPCVbQ9uV4cCG8azH9s0HrkU+90+AR4P1HA0lLtD0vhitxh/cKBl+FT
         WeKKsYPLzC7viMp8tWLlvoGrm8e5SLqgILXIG55zcrt+SuIi8eLtSuMGQ5xvRHBy9heK
         SbgxN63Nq5iH2pDygfTcLIKPFyTANo+eiXNw1qwYXE7RF6v1oElxdL4BhckT80CrMtvr
         DPLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=E5WO9ODhUeb7gchIl3e11LSllsWmM1E2YpuEe+KMyVo=;
        b=Cj+qUn4RONNUrmS+9JeFU8RKcOOhvjOgoQLod2CWD+WQKuGlZplLnyowh7VJKWwQWN
         i9+SJbHsd5mptLt3TFWqkcmrhhlPlO0jsrP8UFybYnfA+uRQDDqg3Xy3a20d+wddUPN3
         5djvftfu4kh4Gg3bIU7s0YQ0WWWsGbdmbhV5O7jr3udLNqnWBOM4X9/woF280sXAXG4B
         RndI3fkuwGYS7fW1H55zGgyBxfgPla/MD/rFkecXzkF60E0SAVsu8qmMXJVZd3J8uyv6
         ZY5zJF0rFIbWH7gLlVM37gQtF7MVTyjeZLMrfDU4qR5bWjhsXDO2upfCB8xuMLxFwvBj
         BuvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZAV3tC6y;
       spf=pass (google.com: domain of 3ewhqxaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3eWHQXAoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o25sor5284316vsp.47.2019.05.06.09.31.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ewhqxaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZAV3tC6y;
       spf=pass (google.com: domain of 3ewhqxaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3eWHQXAoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=E5WO9ODhUeb7gchIl3e11LSllsWmM1E2YpuEe+KMyVo=;
        b=ZAV3tC6ygeuQpYDYrKMnamvWU4Ola27jwmOvJT0NrB9zkA9/9VwZpqZILeD/kCkNoz
         2YieZRVMa/AXiEzwBIxCU1l+GEYmKclsxxyQTiWJfi3V4eZQV5Ty6cVbJ946qs6vtwua
         FnVZYy8h8LlcT9zEGoHGJFhxw76fNhlXkwiMMdgNAFJQ0fdrxIy60WNM3Dx5/MSJjbMm
         JoRnUusKGOL9DOHOG1d4lxStTE2KnFUHyp2053KQyza8HaWrD88UcCSEHERhBeycqSfG
         PaS1O1Y2zDlyyujLwl9tuNkVlIoFOsc0GRtgaeegMD911ZalfKNXqOUfZljQAA2/cuom
         1W3Q==
X-Google-Smtp-Source: APXvYqw1xOoCnPO8YfwpZ5nRgaPpPr24xspNBV17LLiBFtD2eWt0/j9p08QSESkEcGjJ9SGNKNyhv8KaV3q9K4HX
X-Received: by 2002:a67:efcc:: with SMTP id s12mr4512139vsp.120.1557160313543;
 Mon, 06 May 2019 09:31:53 -0700 (PDT)
Date: Mon,  6 May 2019 18:31:01 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <cdf0b98edefa9227db4a3d1fb6e3c7bc5a6a6215.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 15/17] tee, arm64: untag user pointers in tee_shm_register
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
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

tee_shm_register()->optee_shm_unregister()->check_mem_type() uses provided
user pointers for vma lookups (via __check_mem_type()), which can only by
done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/tee/tee_shm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
index 0b9ab1d0dd45..8e7b52ab6c63 100644
--- a/drivers/tee/tee_shm.c
+++ b/drivers/tee/tee_shm.c
@@ -263,6 +263,7 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
 	shm->teedev = teedev;
 	shm->ctx = ctx;
 	shm->id = -1;
+	addr = untagged_addr(addr);
 	start = rounddown(addr, PAGE_SIZE);
 	shm->offset = addr - start;
 	shm->size = length;
-- 
2.21.0.1020.gf2820cf01a-goog

