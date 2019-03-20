Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21E4AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C893C2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fBgfxh9G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C893C2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC7AE6B0006; Wed, 20 Mar 2019 10:51:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D75306B0007; Wed, 20 Mar 2019 10:51:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF1CA6B0008; Wed, 20 Mar 2019 10:51:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9781B6B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:51:47 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id 32so218631uaf.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:51:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=20ADMBvUHCnrZbwN97RAJ/EQy38heFRI/sJcSeCbm08=;
        b=pnybUWcKwbEw3oHflT2bXmhVWy82v5h+OM884E2xPKRUKBMRRtMSFw+hx2MSozfR9c
         xLVIgYyr+YUoJPGdSQIFzwmWEZtPocrPAgLvB75PwdzvldV/pVDlssH5r76iaUAoHgCL
         wPWKWxWzgFuonVEJSyJTsEdIDLrNYLscSnhuaPtalzs4KkUTjV3i8HVw9odcPJ32UMKZ
         E9iVmPIU8qtbCx09PoO8hLmpcgUYbNyLGmDx9zVsV+L+aZL/PQbUY5N5K9lYSimgRdp+
         KVF91DXBTxJl5Ot+mKgJGkPN8Ul9SVgP+6IQv9MHB97BSEsEYGmOg/EYaTOGX7N43Zaa
         Uizw==
X-Gm-Message-State: APjAAAUPZ7r4jPrADD7TqaRFe5AlgqH+LdfD4wr7zKa/VXnFMIFOKLyv
	WbKJXi0lBbBa9TyrspQKiuZy4KiEy7J6KPB+K+aKQoGc74sXwrJb8HIUj/z6Pmf+Fo3zYneyJPk
	OT+CWN5O7AaerXDPHjxdATeNksqPyOTFACRosE3m73p44cVVcunu2Kxrc1CW/LPVOQQ==
X-Received: by 2002:ab0:85e:: with SMTP id b30mr4573890uaf.108.1553093507209;
        Wed, 20 Mar 2019 07:51:47 -0700 (PDT)
X-Received: by 2002:ab0:85e:: with SMTP id b30mr4573857uaf.108.1553093506517;
        Wed, 20 Mar 2019 07:51:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093506; cv=none;
        d=google.com; s=arc-20160816;
        b=ykh3+YcLLqHxjmHLD8kui4LPsSPBRzjvN5sjZdwbAD3f//a7jfRzLKhflps4oLf8Ts
         mRfoLyJlb7rzuOw7nEwpOyEi8B6Tri/GmdvxzBN+SL0kzoZLvS1QRJ9c2oapcvZ1/Kor
         KfdwEmzeEGAgA6o/DJ39CcZLzjABy078PEH0m71WnWybhaSABNgX7welRW66w1SLpV5P
         6z90JT4MYq7/lU//FOEPjvzRSmuWDl+/kMqVyvOVbbhcuO/m1Biv1Es1K/QJUPnC5oRj
         e90M5BJsAZUrkcL6tGiBXYtLXjuRmQ1d3nSeBCfqRaRBZXkFxB81rjnqCVyJ8xXEDzVn
         XQ/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=20ADMBvUHCnrZbwN97RAJ/EQy38heFRI/sJcSeCbm08=;
        b=n1BODu2Nwvxq28k9EnLCJk5V1IpF++Hfh7j1Vs01Uxuw362jc5ijma/zCRNX5dxJTU
         U2+kbfHQgFuUo5hplnfSI00b9iAAmcIF+Or5y3zj7q8wDj5EPBVaaVCN5H6mlMU5g89o
         4oa6f+fCAgYMtTuys0ax1dJBK9NpqPIhD3XpRvmEGSpni4e9eeyYXBeVQRLtectAn2F5
         vqqBIGOdfYC/FlBT5AAzJ1A5qbqTGTDCzs+tM1e4Poyu9r/zEfDfSh3KTz6mFdJ9Vxbg
         bvVNbevdif/ZZ+yMsXsyVawIm4vQKupLbOfa5UBA1YDmvPEURSoKx0RQ2m1WHf1MZ2me
         JWHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fBgfxh9G;
       spf=pass (google.com: domain of 3glosxaokcf05i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3glOSXAoKCF05I8M9TFIQGBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m3sor1305229vke.0.2019.03.20.07.51.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:51:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3glosxaokcf05i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fBgfxh9G;
       spf=pass (google.com: domain of 3glosxaokcf05i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3glOSXAoKCF05I8M9TFIQGBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=20ADMBvUHCnrZbwN97RAJ/EQy38heFRI/sJcSeCbm08=;
        b=fBgfxh9GgamRMHg2ccGZFUoBByz4GOt4sfGHL3tpn3ZQ1767xayTeCcyI3yXs2mSPo
         9L9Z+nWnCgS1IkEZKl0L10t99Kxoazx3+kM5cwGHIxLejwB/C6WPwJK7TADmWr+R7zyk
         SVEtWmrnvfwXlM1zlGyhZQZOBAu3t9jHBJl+/8o9qgFuWwu995t1w8VbhpR252WdIqRb
         sE8Ml1x7tGBmVRlYQ2buPK+l8HSNYgOfT1+UtDa9CPF/KYM3j84TJNM8Ny+6EFQlptxm
         +USjsypvXQxVHDirJ+TCg6zJChaLRFAlYddXbqGYhP/AQ/lMXeTl1LdpntucdrWI+Hfw
         RS9A==
X-Google-Smtp-Source: APXvYqwYZ0q0Kqz4Z5cFxviM/RSvP8v992XNq+tHsBzIasT+5NuCnNNfSRat/OKpd5fkXdzMwZGbNS7t4SMgCBo4
X-Received: by 2002:a1f:2a48:: with SMTP id q69mr16477241vkq.7.1553093506075;
 Wed, 20 Mar 2019 07:51:46 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:15 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <7747d94301bcb30de0026e9434a1e1879f84aae7.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 01/20] uaccess: add untagged_addr definition for other arches
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
2.21.0.225.g810b269d1ac-goog

