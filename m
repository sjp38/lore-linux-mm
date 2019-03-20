Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 356F3C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1F3A218A2
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KRMkdxMD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1F3A218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 895246B0010; Wed, 20 Mar 2019 10:52:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86DB96B0266; Wed, 20 Mar 2019 10:52:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 734026B0269; Wed, 20 Mar 2019 10:52:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 510866B0010
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:10 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id a75so3407598ywh.8
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=MRHHZYm6qbbddi64ikktRuAjn8BoXK8Gf7bv/2tC2r0=;
        b=H2rGSXnFQ6bWvFXGH/6GWYXX7QJzA8et1n0HlZ4FEIy7Kla5inaA47brnb5bAQhUn6
         m/d9mDoh1gF4pD3AIWCOhrG2ZN7QMiKL1gf6b1pmH4XEwgsTIPx3cbkBje1Kt33DZ+uc
         3t2NXDipI5iP8kOcv6S2AK85j/py/5ubDEXUMCpfWx5loLKmBE5KsQJQ91nThtM0leDS
         0D8uUcPFgnGva6TSeiXLG+vgxzZWeEu7QqhQWUo5JRQRx8iVNIN3pSzUss8r9b+cpoaa
         dkY1Uz90Y9akT6lBmU/zynG/bm0tBR4odK6GsL6jSwsYFZBli4OrL3lZqzP6PQN9qJJ8
         PaKg==
X-Gm-Message-State: APjAAAWTZzC0voiO2g6AM3CExGAwJ93TMEG6Pmxy0r/K6iy5EunMddua
	+mfm/JOVlhqTDdlKP2FyQgP3B3Dv6XTZ63MGAFJkFDiY+rEM7s8G/Vg18LSUAVM6/jdN5tPoArB
	mQg1sSSq7weLDJkd+o1FWd7Ao7Qm8Mhhf0OXOMm4pcEIRfF0yGuTuBRi+QH8ChVypuw==
X-Received: by 2002:a25:1ec3:: with SMTP id e186mr7133498ybe.189.1553093530089;
        Wed, 20 Mar 2019 07:52:10 -0700 (PDT)
X-Received: by 2002:a25:1ec3:: with SMTP id e186mr7133445ybe.189.1553093529382;
        Wed, 20 Mar 2019 07:52:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093529; cv=none;
        d=google.com; s=arc-20160816;
        b=bx2qZs9HqSKnLbQ8cOLaw2xXsShMTlnYmvSCEBd0ecTCerks3VLJXeyyNAQHvbPTiO
         DcbdXblQo65qcBboYqs/aLb8GFJVnkitjOrwHE+JLDbCmq/baen3sKGxLFh/pf92KUIQ
         SGtETFozGmIXpCyhpegXvyAuzzdTocNoodC1nlJHqiHAvOoflCpzoZ/+J/qYvtaU1h9m
         xbkZl+QHbnYfDZshZNelmLAsc32gGIiqRVgmg9cb2ZjG0dattEC+C+MTtxTBayTMC1zl
         jcHV1LtzdPzYD3+V4KorSHTB/buYvD/jDALujWEkRZ7YEEZ7g5kjiYFrj5BRy4TGso1H
         zUHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=MRHHZYm6qbbddi64ikktRuAjn8BoXK8Gf7bv/2tC2r0=;
        b=aOJsRM1SBKV0B36rJMX4Wu2ZdPSDMPmsw/8+R+tBCR13u/G9SMy7nyDTAX9oJm32LV
         EIzZLL/0erxh44GOBIOyZp/3RAh5MMmXNNcGNjB84bEKY8TS299FCzIopVhU5468efzR
         XzzrAzAhQfJDo6WPm8eshiKbCvXbj80N6hkUdn34B0KwDg5Jl4TzqiFvNjz5iF33xxmx
         ErS7D3h/2mi8YryLsmfIxTGOC5M00eBdIpNvfVPdUyuWztJhtZEUJ2SKyt8VZNS1dZjl
         NTXd8T0oP9gSALNATO0KaCGQ5MH/qGy+dvwShNX96gpo9i4Fx9rqHe8O+bLAOjhy3iUG
         VBiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KRMkdxMD;
       spf=pass (google.com: domain of 3mfosxaokchmreuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3mFOSXAoKCHMReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j125sor761528ywe.8.2019.03.20.07.52.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3mfosxaokchmreuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KRMkdxMD;
       spf=pass (google.com: domain of 3mfosxaokchmreuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3mFOSXAoKCHMReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=MRHHZYm6qbbddi64ikktRuAjn8BoXK8Gf7bv/2tC2r0=;
        b=KRMkdxMD5r/ER0b2EYOaeTinlF21JbEs5hD7NF/4KuqBnnQC7/Ye6Qw9DCv6nYaIx6
         4U2cUzqhytwW3z5B4iRPFCCYHJA/xIASnuuJbgU+DFTxxvtbMCxk2YOQuO+k3FhjQZxT
         +HNaP52fISwxZzgGzVRKuYbp7Q8oH3K6BetnL7BXKag5ZZAYsbr0n35Pp3LUj50J49dx
         O5jbTLSzQ9if52c7p/5fn1S3OpB1gYH1iUyL2wrB6P1nRrgD/9GDVY3gp4qdOHpbJY1p
         i3H4A9ArVAT2nkBdJ2JerrQkq4TGT69QXIEYb6sDErAg40bUbxmWd7KaeWagNV837y9+
         Oy3A==
X-Google-Smtp-Source: APXvYqwr9m8YxgeUDBeeozt2hDgx245cPvqj3jehL0crcqpJn0rfr3qEPeO8cHwuraZTKRyiRzSC54VlM7fEpP7b
X-Received: by 2002:a81:7acf:: with SMTP id v198mr2201203ywc.16.1553093528977;
 Wed, 20 Mar 2019 07:52:08 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:22 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <dc4aa5f958ea98ff0add6350ec238acdc6523779.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 08/20] fs, arm64: untag user pointers in fs/userfaultfd.c
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

userfaultfd_register() and userfaultfd_unregister() use provided user
pointers for vma lookups, which can only by done with untagged pointers.

Untag user pointers in these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/userfaultfd.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 89800fc7dc9d..a3b70e0d9756 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1320,6 +1320,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 
+	uffdio_register.range.start =
+		untagged_addr(uffdio_register.range.start);
+
 	ret = validate_range(mm, uffdio_register.range.start,
 			     uffdio_register.range.len);
 	if (ret)
@@ -1507,6 +1510,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
 		goto out;
 
+	uffdio_unregister.start = untagged_addr(uffdio_unregister.start);
+
 	ret = validate_range(mm, uffdio_unregister.start,
 			     uffdio_unregister.len);
 	if (ret)
-- 
2.21.0.225.g810b269d1ac-goog

