Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23D89C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D43F1274E8
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MjNLlQZl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D43F1274E8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7804E6B026E; Mon,  3 Jun 2019 12:55:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E09E6B026F; Mon,  3 Jun 2019 12:55:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5ABA56B0270; Mon,  3 Jun 2019 12:55:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 268556B026E
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:47 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id c48so8101776qta.19
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/k2k5Ar8aCCQf+9D9Tu+JwXv9rH7AXQNa2sn1Y51ZQ4=;
        b=VErLUUU6FckLEzlTmTUnpaC6VTTSvAzaiAmEA0W3ZT/r8BMvDCpw04+pv9nXxCpM6L
         DSz3NbepXLLePsIrl5MXS7YfNOt0p+rZanfW0Kg52p52Q0Rq41XGLNaJDMvq/zDmNY9g
         g934UsGnN4b//g0LR4jOeq+pC9YT5FlWyvRUhApC1vWm1ME/imxOuiefodLPacAFxZbE
         wVhlWsiEHVHbh+lQuNnN//Dfs14LLhiWkB/AtEOlsqqdLgWCqrNvtgGq/A/yInArBOK5
         bvYfFpr8h73Q9YdxmnjqZ2e08ZxnZRoiQj9jcf++Rs7VKcBP/+T508kj37bTJp6mUZEz
         0qlA==
X-Gm-Message-State: APjAAAU9/mfrtpkVBVYXram6HitC+24PE1LrRQJ0nDVdt/JIRJtjGS56
	AKeIsfqAKwvyvYV0GdU+EMRqa+XD0wIkBfbb7Z9Q4TYfWKUlffOa9Duv/z2uXQGdHzIAiTNuR2B
	W0sp+L9T9amL3r1HnFGXV0F6GI2k8wTYaYjNueyRh8s0NpXFxBdL7rSJj46lcXwjLZQ==
X-Received: by 2002:ac8:16ac:: with SMTP id r41mr24250433qtj.346.1559580946855;
        Mon, 03 Jun 2019 09:55:46 -0700 (PDT)
X-Received: by 2002:ac8:16ac:: with SMTP id r41mr24250393qtj.346.1559580946354;
        Mon, 03 Jun 2019 09:55:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580946; cv=none;
        d=google.com; s=arc-20160816;
        b=obTGQ6VY4CePBySlovjZRk2NNHNGfs1nHCGhgmXK9frzWtyBvQi6wRD7G7PUsZb/y+
         5WBKmAmYecaqZn9w/PovHtosWzTP94kNdEFxzyazvu/yxaGMhzigSY9MfeffpU/0BHs1
         3HMGorls1ycjZTPYz2ZWOu8icr3E+WlMPJeT34C9YAAh24YUljzLp5uhp79SzhI0EYNI
         OqMF5KimACGOfSG76ClLIk39CTmKp2QmtoeNB2UFJ54GTJH4Bhhy0zO62YJVsL2HwNMM
         buwFp4x9Nh0T0U4WAQNAL2GmULW/MDaPeT8lcp+DcOB7GCen529Je7AndvWBM7xvA92e
         URwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/k2k5Ar8aCCQf+9D9Tu+JwXv9rH7AXQNa2sn1Y51ZQ4=;
        b=A5nGC3/ek2qSQlvyvRXzQbFKN1wgb/jqDUbW8Bc4WiwSdHYFcHn5mVb+8QKiMsWamu
         foTbHYF/sVU6j/UFkAzNyHhkcWw5jwv0hiyUCg7h3OdBCy9dFWC/iZwAwqHElEsqObh8
         b0WWK5WBmcMwyH2nbs73tE28f53B3Mv7TJzi2NKbDYiXhl0jZII79QXpBqziC2inu2sN
         5CK1RnpXVvCIunMtOqWyPYAVgYGKOHbO8IBzD5id8faar6PlZhz+45EyE+8kduXustGX
         dcYrh3YJm8SkemcYfaRP/ZZ+56IY7LaM0K5JX0KVMyCiKB2kAOW7b2RX63x22gdf6CTy
         7vVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MjNLlQZl;
       spf=pass (google.com: domain of 3elh1xaokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ElH1XAoKCHcViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x27sor1714161qvf.38.2019.06.03.09.55.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3elh1xaokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MjNLlQZl;
       spf=pass (google.com: domain of 3elh1xaokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ElH1XAoKCHcViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/k2k5Ar8aCCQf+9D9Tu+JwXv9rH7AXQNa2sn1Y51ZQ4=;
        b=MjNLlQZlNit0qhAOpvEzanta6aMm/HnKYesq3iqhkQTbbVYKucWsuURNV/pZ0fdIgr
         1ylaKkgQteB/frXQLyR10kOE8zU+ZyRD8TpKfDcQZGCnFFNsjXxOEavz8cj17GKJRCyB
         J2x5kMGyd9MMKiWAlK7ocfm8aGFbZzr0Rdh98fVFvwjIhfiuVXpvvAuYt2OnDM/XCpZC
         VWufB4qSPQOsK3r33NC8xnn++nCnsO734V+hLJqo/vulWZ1igyxoTiVpIzF6BQyRc9HL
         xirXgN3vt5YoqdUqHeQ92rql4obffE5Q5C/gZo+mx+uqLs8kG3FDDu05FA2VnYDjJKl9
         Kwrg==
X-Google-Smtp-Source: APXvYqwZjlBwbqsUyeG8rZrRtMFJQ4x0s68oHB37CApZiK1GoR+JjJPXBY4ob8DyF+o+kojgj7/dpioneK7jLRPa
X-Received: by 2002:a0c:b5c5:: with SMTP id o5mr3845483qvf.6.1559580946056;
 Mon, 03 Jun 2019 09:55:46 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:09 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <da1d0e0f6d69c15a12987379e372182f416cbc02.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 07/16] mm, arm64: untag user pointers in get_vaddr_frames
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
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
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

get_vaddr_frames uses provided user pointers for vma lookups, which can
only by done with untagged pointers. Instead of locating and changing
all callers of this function, perform untagging in it.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/frame_vector.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index c64dca6e27c2..c431ca81dad5 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -46,6 +46,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
 		nr_frames = vec->nr_allocated;
 
+	start = untagged_addr(start);
+
 	down_read(&mm->mmap_sem);
 	locked = 1;
 	vma = find_vma_intersection(mm, start, start + 1);
-- 
2.22.0.rc1.311.g5d7573a151-goog

