Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E5F8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC9C32184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DgQCTHAw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC9C32184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C48C6B000E; Wed, 20 Mar 2019 10:52:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 477096B0010; Wed, 20 Mar 2019 10:52:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33CFF6B0266; Wed, 20 Mar 2019 10:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18AFA6B000E
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:07 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id y64so13387535qka.3
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/AfMcWXUpr8qOV9jNlH+KOvJdLIB2O2rWZvj+eGhaHk=;
        b=qhgmf0RAc6sEnceqG/qc4Eq85OO6sTNnSmqb6jAeMbRVu4T06neOui3Fji5MmFOWP0
         Fv2cAFJ236pfrzaLLwVMl7FtXSO3l0tbcK6Yen3z7TBfW3Da5bXW6JBVwDH4ICevzuMD
         tnbnYkoNRhjBe14Lv81x4Y5MrJU1Xo2zufXMADpdw0snqu8PS9e/Kw7aw9PXsQEw7pQk
         tRPiu3+9tPszywGnLZxZrabw1oA4Z4BXJJSV+TmfX8Vkvjz8PVrcEINHIGCL5ZWSU6Ai
         4u4w7yu9tGIlehdR+WxdKgAZCrsNRFBW8IxnhjDUILqQfLSSjJiDChQC1fCOI9mO0cOM
         DPLQ==
X-Gm-Message-State: APjAAAWu4ZwXEYS5pEhmbCVYOrTsJsCSd9B7IzCXM89qvLob7fVOx3ap
	39raM20pC7K6S3NGoQSZgzbBZaPd/s29FOWfJgFcgeojILDMIKVgljhhqA1majiQm6shb66TIQS
	ylHH2jU9SEgDyv4nlADG//wG+QE3phPIADrfdX8IWiIgytMJV7PrAfYV3vb5ICjA6zQ==
X-Received: by 2002:aed:2307:: with SMTP id h7mr7294876qtc.87.1553093526833;
        Wed, 20 Mar 2019 07:52:06 -0700 (PDT)
X-Received: by 2002:aed:2307:: with SMTP id h7mr7294825qtc.87.1553093526213;
        Wed, 20 Mar 2019 07:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093526; cv=none;
        d=google.com; s=arc-20160816;
        b=Tc3kxslJ1iTqDAff3SnFfVTicLPjlfjBvneTes8h2WQarwABGdlMnHBNY6Uxkm8FsI
         DCHUc1kfn6qmpFlWSWNm5JTpbJHqWUZBQgoJmzaXkeC5/YOF6TYEX6d3ULXcCtdbfrqL
         IC5ffEm6IjwsppdO6ZLt5eoF+jNuYETRE8WT62zokRQ2yGIdtohxeq/F+ILv88he+AmA
         7BDzJeCVgQCZwMJMR0PLfXRCblG8v8KUytRTYt//drYWTVbt28QNYEI2Zu6HAmJ7UQhY
         pfO4al0UH1mjZghqJLI8PkWcZIJ9lnpLsmevTDCz0I/XLIcudqKE98VJ14FYKX6xeiEX
         N+NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/AfMcWXUpr8qOV9jNlH+KOvJdLIB2O2rWZvj+eGhaHk=;
        b=S5X5wz+sxBEAQy+CmqWVIoIeRAy3jWzzfsP7BIob0KPKF3mb/VCp01ZmPRzMCwfS4I
         h3/0CgD9986ePfToxtSdl7GhmXT5apIl0kKz3CXwctSUMAfwRUN6JC40MD4+fZz11aMd
         8EntRo5wKa6DSRGELq+UhOdZgC2aWPG8rvrfXL6vKZUQLmlfSXBvmWFP/iZyKtZCws1G
         k0agI5sysSCTZwKngNmkhIqit9n4c4Adxm2f5xgw0H2oaPAvlkVyls3ozFDFjUjhDZVZ
         ttZ1N+9SIiK1JMLfQhoNuw5fV01oAm4vNM13OxV0mKNxaERbVirfrK9gC9ibgVJ5d/rP
         F5lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DgQCTHAw;
       spf=pass (google.com: domain of 3lvosxaokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3lVOSXAoKCHAObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 34sor3988322qte.45.2019.03.20.07.52.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3lvosxaokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DgQCTHAw;
       spf=pass (google.com: domain of 3lvosxaokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3lVOSXAoKCHAObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/AfMcWXUpr8qOV9jNlH+KOvJdLIB2O2rWZvj+eGhaHk=;
        b=DgQCTHAwsx9nOdP43FdX5LVEo87GnIfu0WmZk1NYabcIGCtKnsiekk4mOZRYJIhI1U
         rvCehvhBc06o8DcFgsseTvDqXb0bAW+gvKfeVD4L0KGfj2wOOOXK/fMnySAD9d5mCKCu
         3Xy6ZFurPUHQ7qTNFw0+B5iut5R52YvqgYU/a0JEMSrKC9jRWo3AU420WBXrCWxeTOM5
         YeoFqgkUOZ10TFamvrA+SuUuvAxE8e7foqYee5urs8q1dYqDp/xiKxBavemBAmX/sEHw
         DPuDEUNXQvvEZmE9YUfwESNhCqe00SvlS+lCubr0KgJlNbkXCmKhNkb8zOctNt9/cPVR
         Rukg==
X-Google-Smtp-Source: APXvYqy+ZGj1oA4MFc9JnMXadH7vhqJKC4uAMJ0YAN7IR5yuNOlRtTgk0L4VAoRYkahPatQ5yAXGf8UXWvJkE4CW
X-Received: by 2002:ac8:38b7:: with SMTP id f52mr14823448qtc.7.1553093525814;
 Wed, 20 Mar 2019 07:52:05 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:21 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <9f7d95da28b1fd5e601cbe43e81ee646e1ca6880.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 07/20] fs, arm64: untag user pointers in copy_mount_options
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
2.21.0.225.g810b269d1ac-goog

