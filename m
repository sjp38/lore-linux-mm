Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBA14C31E5C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:10:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A52B9208CB
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:10:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="k9NH+beY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A52B9208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 446658E0002; Mon, 17 Jun 2019 11:10:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F7F18E0001; Mon, 17 Jun 2019 11:10:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E6C38E0002; Mon, 17 Jun 2019 11:10:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1022E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:10:58 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id l11so9468527qtp.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:10:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=AhzC1dqcXRssy7fdMkEhLgspqOslOvHdcVPRsk5zXZU=;
        b=oAzRtDeQSyy6rScolwp+kW4mmvQQruiKZiSYBWhn48KQRAySfU2pjSKo3GfdJKoECS
         ab5sfy8zs5nrpvgC1VXUarZHZFWJadDQKx2lQROSgomG1egeix7QI/QElm+XpmgYd/y9
         agxT8nURHRzToncwj+sQVRQ72n1twinUv9l5fhlyGHU81g95an+pxAXOiqhaFNYdbQNv
         31IqMGJ+lMRd/0PCU8tG6zhHJdrIb6CM0MuVGMkpM/ruyQsmn7cXCp7jifMJk8ZMOgL2
         hQAxK3wVLmCTXfYPTUI+KmXtr/vMMdwQxQ7FAe216Hz5q2GSLs5GV9pL57ZO540vktPM
         uTKw==
X-Gm-Message-State: APjAAAUITxCXCyS/P96Fzq+CC0+69jqTIrUhgoC/Kub0hvkfg5P+HwAx
	VfYOfv2aDInhsJ+t3Gc+bjHkJxaXA3i5iNClf181ZAnfVaUA9ojkco4HfsmLr60HDpcWbvKY/Iw
	Bwcqn+It5UB8y0LvM/GpMDvfI/JVmsuXsNuqBids6Aw1ug/oKqtj7KTlCrebb9Bit+Q==
X-Received: by 2002:a0c:9608:: with SMTP id 8mr20152340qvx.98.1560784257805;
        Mon, 17 Jun 2019 08:10:57 -0700 (PDT)
X-Received: by 2002:a0c:9608:: with SMTP id 8mr20152274qvx.98.1560784257119;
        Mon, 17 Jun 2019 08:10:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560784257; cv=none;
        d=google.com; s=arc-20160816;
        b=zj1iMbQLwdHXWn3aE/o+RlWG2sfCQrUwIOYjPn1TqI7Ob6qaApDasSHHqntjONf0OO
         LunuKPg9W0+7XyULhZs5Qwpe6Rb2X/qbWEz2fJgLBuCK4liMBf+sd9TNEJMiDa0/NI+p
         q26EnKOw3THSUe4Fg37Eh0dn8vzY5mXRwG4qCrhHGChgx5FT2EEZso8+synKoaaxD10B
         esJXaX9EE+HRuNBq7JhNfStdQ1XTYeCK+xvDONzwyARrNcVG4x4LhJefDsIYfdbBZJZf
         dI5y91B6Vs5qiqHJNHMwkp6+UUtCeaxiPElA63UY8cEeB1tRHWICzqRpCGE71pSw0SuK
         E69g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=AhzC1dqcXRssy7fdMkEhLgspqOslOvHdcVPRsk5zXZU=;
        b=faPLuHEqpgtRBvdgB5AdrkRPTnfpDI1LVyiq3HDO2W+ZU9I2dTU5asRDM1Ylk3gnaR
         MLUCFB/7JomIFctSVjjADlirzZHoAVD3ypxWp6u4S89sJ07mij/z7GveS4mtc6z7Z8hu
         aBIzOgTKsYkKXbRZhC4A0u5XNccn/7DqvHEsHfg3YTynTQDe++sFW80z5ZyT4jQ653a3
         XSb2kRqBl90dHx4DicsU4H8bcJ/eS2llDY0LgwGo9/4e+zXepgLPtj7ivVuF9n1LejHc
         p9gwPn2SZmZTVc19Sm4D9d4UffUnhSOFsRnj/4o0XBbMpop6DnGCj2MYr82lilE+D+Ve
         jSOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=k9NH+beY;
       spf=pass (google.com: domain of 3gk0hxqykcocpurmnapxxpun.lxvurwdg-vvtejlt.xap@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3gK0HXQYKCOcPURMNaPXXPUN.LXVURWdg-VVTeJLT.XaP@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d22sor16452397qtd.60.2019.06.17.08.10.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 08:10:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3gk0hxqykcocpurmnapxxpun.lxvurwdg-vvtejlt.xap@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=k9NH+beY;
       spf=pass (google.com: domain of 3gk0hxqykcocpurmnapxxpun.lxvurwdg-vvtejlt.xap@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3gK0HXQYKCOcPURMNaPXXPUN.LXVURWdg-VVTeJLT.XaP@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=AhzC1dqcXRssy7fdMkEhLgspqOslOvHdcVPRsk5zXZU=;
        b=k9NH+beY5eMjDnOaINDvVrgGcEx78KmzHeEJfkQN6Y9SX45KinI1QUz8a2DhSnPwty
         5kjZ5RuuasqO5gIcAhgkZUnJ5GT0kppbEhM9rHxo2vvxQJfsWk6uJ4QrX+Ea29xmQPeD
         8IsCVrYuEabNYcOitK3k+G1bBip5g5n1lG48JTDn/EqwzSUI5z4Uorhrr88udI3d+o6j
         RHT5IKO45+CRt1jDmPgvxO/tI9sYeKgKoAmcXlnkwutt1ZNFR12l5mPkKMTD0nu4F7YS
         SatuKTASkGkk2OrjCE5YEdnhVkD2b7xX5FLEHPbTJVQQpwuOyfkmjlwOpBT95MleK+pU
         LE6Q==
X-Google-Smtp-Source: APXvYqzSP5di/cDRVpILC8IiiOlVU005dHmsxZFgo+MqF+Qnmu099tvbtAFfTxug3VjFm5DpzWKfL/u7hSk=
X-Received: by 2002:ac8:2a69:: with SMTP id l38mr27804097qtl.212.1560784256777;
 Mon, 17 Jun 2019 08:10:56 -0700 (PDT)
Date: Mon, 17 Jun 2019 17:10:48 +0200
Message-Id: <20190617151050.92663-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v7 0/3] add init_on_alloc/init_on_free boot options
From: Alexander Potapenko <glider@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>
Cc: Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Michal Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Provide init_on_alloc and init_on_free boot options.

These are aimed at preventing possible information leaks and making the
control-flow bugs that depend on uninitialized values more deterministic.

Enabling either of the options guarantees that the memory returned by the
page allocator and SL[AU]B is initialized with zeroes.
SLOB allocator isn't supported at the moment, as its emulation of kmem
caches complicates handling of SLAB_TYPESAFE_BY_RCU caches correctly.

Enabling init_on_free also guarantees that pages and heap objects are
initialized right after they're freed, so it won't be possible to access
stale data by using a dangling pointer.

As suggested by Michal Hocko, right now we don't let the heap users to
disable initialization for certain allocations. There's not enough
evidence that doing so can speed up real-life cases, and introducing
ways to opt-out may result in things going out of control.

To: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Lameter <cl@linux.com>
To: Kees Cook <keescook@chromium.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: James Morris <jmorris@namei.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Desaulniers <ndesaulniers@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Sandeep Patil <sspatil@android.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Marco Elver <elver@google.com>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com

Alexander Potapenko (2):
  mm: security: introduce init_on_alloc=1 and init_on_free=1 boot
    options
  mm: init: report memory auto-initialization features at boot time

 .../admin-guide/kernel-parameters.txt         |  9 +++
 drivers/infiniband/core/uverbs_ioctl.c        |  2 +-
 include/linux/mm.h                            | 22 +++++++
 init/main.c                                   | 24 +++++++
 kernel/kexec_core.c                           |  2 +-
 mm/dmapool.c                                  |  2 +-
 mm/page_alloc.c                               | 63 ++++++++++++++++---
 mm/slab.c                                     | 16 ++++-
 mm/slab.h                                     | 19 ++++++
 mm/slub.c                                     | 33 ++++++++--
 net/core/sock.c                               |  2 +-
 security/Kconfig.hardening                    | 29 +++++++++
 12 files changed, 204 insertions(+), 19 deletions(-)
---
 v3: dropped __GFP_NO_AUTOINIT patches
 v5: dropped support for SLOB allocator, handle SLAB_TYPESAFE_BY_RCU
 v6: changed wording in boot-time message
 v7: dropped the test_meminit.c patch (picked by Andrew Morton already),
     minor wording changes
-- 
2.22.0.410.gd8fdbe21b5-goog

