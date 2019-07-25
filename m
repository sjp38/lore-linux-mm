Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEE62C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:51:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9089422BEF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:51:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9089422BEF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F55A8E0078; Thu, 25 Jul 2019 09:51:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A5248E0059; Thu, 25 Jul 2019 09:51:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26E088E0078; Thu, 25 Jul 2019 09:51:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CDD6E8E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:51:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y3so32158974edm.21
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:51:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=90j8pwPJbERCSOoptymIMwkhw4ze4sh3LmP3iWCdthg=;
        b=q+3IRwEPF0C75wbrlqksKsJyPOphpoRJ6muKqjiD0Eh7vSsxsyN/2G0GrUUDQK4rNW
         laGHmzCC06D861VnhM1mwZP3wL5l7Ri66mdKEWO+jXyVBSdwsZWTTBHzG4mw/kbW2IGs
         g7WgvsU2x1+T7UCA+wRmEPj6ZxIwbPHOhwipG5o5VrSz++9NTYGSSZWc+RUZarv+LQ3M
         ahsoaNJsUo/RHuR6rVvbsGd4fLUYqBSs9t5yRHFijZwPyIHgzvrBJAo8T9OKwEKSpuxR
         jDp76bvr0wgNRAedN58ZZqOtkOZ1i90y2VWuOUNlAL/VZKc9WrMK6/1EtMBRmfqkl/3o
         Jg8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAUf4kjzcYFgNmxWnPRzK31/gCJ6ZcUTZP9H+6ENFpx8xuOwUqDx
	KtIWVQK3COJ8PC4WGO/k/a31xRDBb8ZC9kCZ8ptbPVONmUXSJuhEm7dOZAMuRmcU52iNfnR0m14
	S7rnrjKz7Tmggab+BBwKYXQZUS9GMEvdbZHJJ5kE5V7got0j+tNNLF3FzvVLJqKB9Ow==
X-Received: by 2002:a50:9846:: with SMTP id h6mr75586172edb.263.1564062674404;
        Thu, 25 Jul 2019 06:51:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsAGvSw1VYRM8j8G19gw3gdFZ1SXVcgXeP37br/cAiI21corrvmJdoYm+WS2/t0nIOPcVj
X-Received: by 2002:a50:9846:: with SMTP id h6mr75586114edb.263.1564062673633;
        Thu, 25 Jul 2019 06:51:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564062673; cv=none;
        d=google.com; s=arc-20160816;
        b=bzKzrqjM5qDCcPpdzldyb+axg7sF5P22/b1rF/kNDT4BI77loydzHaHGPzcjkwcfXX
         C330kR+0AWdw0vS0CvXdO7XVcxyuRDE8E0QKj40xXazuFS63MfernSIJMPr0uvK3XIcs
         AGsghOTFdHHpEFkN6j5PIgbyTRo8kzW7XDTTmwGKrpUH5elJpwFn57JJHD7b5DaNL+Nt
         IaYpQ3AKrJWSrR/VPTVg99TXEU0gAGJgS2bESjvLCxGQ1JEclm4i5DkvZ9IMztbbYOyG
         10LOD2gAGc621LuBkZgb4ERjZJIMDFeqWOG3Y+IbguMmnRQKxLlUWb+gtWlq7QievtoT
         Fx4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=90j8pwPJbERCSOoptymIMwkhw4ze4sh3LmP3iWCdthg=;
        b=jWxOyHB7+19bbUz1uleMAnc0xmYgc24YJXpaAvFlXJl4w4ROV8J+03K//n9y4p6Gv2
         8G44yZHOU48f2w2RWz1LS47NTXBOfalwBZQviN+9hqd6RDnGr910YOjmkOsWorZHwkN5
         DfwBr4mz/t2eif6szYj5GF5cuJ4beU0CM6fApF7Afre95/MP4mFJU6Tf/xbqa8dLapBk
         Kh0fSspcGssfmvtTysl8w14oof4VNkhFV3ACj9yverHXsdc5f9naN0Z0ezqagziWjTsN
         k2cAE+/eddPSFvcKGaZZYsFklue/Cw2pHyv/+8Vo7P3LdeliDetcBljC4fqHosw/qI4T
         gzOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id p6si11133330eda.198.2019.07.25.06.51.13
        for <linux-mm@kvack.org>;
        Thu, 25 Jul 2019 06:51:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C83D428;
	Thu, 25 Jul 2019 06:51:12 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 592483F71F;
	Thu, 25 Jul 2019 06:51:11 -0700 (PDT)
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: vincenzo.frascino@arm.com,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>
Subject: [PATCH v6 0/2] arm64 relaxed ABI
Date: Thu, 25 Jul 2019 14:50:42 +0100
Message-Id: <20190725135044.24381-1-vincenzo.frascino@arm.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
References: <cover.1563904656.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On arm64 the TCR_EL1.TBI0 bit has been always enabled on the arm64 kernel,
hence the userspace (EL0) is allowed to set a non-zero value in the top
byte but the resulting pointers are not allowed at the user-kernel syscall
ABI boundary.

This patchset proposes a relaxation of the ABI with which it is possible
to pass tagged tagged pointers to the syscalls, when these pointers are in
memory ranges obtained as described in tagged-address-abi.txt contained in
this patch series.

Since it is not desirable to relax the ABI to allow tagged user addresses
into the kernel indiscriminately, this patchset documents a new sysctl
interface (/proc/sys/abi/tagged_addr) that is used to prevent the applications
from enabling the relaxed ABI and a new prctl() interface that can be used to
enable or disable the relaxed ABI.

This patchset should be merged together with [1].

[1] https://patchwork.kernel.org/cover/10674351/

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
Cc: Szabolcs Nagy <szabolcs.nagy@arm.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

Vincenzo Frascino (2):
  arm64: Define Documentation/arm64/tagged-address-abi.rst
  arm64: Relax Documentation/arm64/tagged-pointers.rst

 Documentation/arm64/tagged-address-abi.rst | 148 +++++++++++++++++++++
 Documentation/arm64/tagged-pointers.rst    |  23 +++-
 2 files changed, 164 insertions(+), 7 deletions(-)
 create mode 100644 Documentation/arm64/tagged-address-abi.rst

-- 
2.22.0

