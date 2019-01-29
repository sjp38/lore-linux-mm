Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FD2CC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 395C720844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 395C720844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9D3D8E0008; Tue, 29 Jan 2019 13:50:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4BA58E0003; Tue, 29 Jan 2019 13:50:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A11D18E0008; Tue, 29 Jan 2019 13:50:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDC78E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:01 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so8312950edb.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=k7wnSh0/AWdeE9IE2N0pFqQz9uaZdVz3WI19ff9zm4Y=;
        b=FJuJhWZoUUSO09RJr7MPslNi45iVntgw2H9GvtYi/CU7i8wORXIhvbi+UwZQ5F98Yq
         vMx7ktK6CLPqDEAuKlQGn0vmck38ddcowuRTuHAAwAFyc1nv2HxPe3hT9YWBwwKD2xmq
         CkdKoToVmcPAt+QhPS6Y4gB4fB0jPj5GT91/jDZev0exbCx4Vr37wqM1kFFhESDkSpZM
         CyvgaEW54X5VcAoBuITyAHOaSVPq+7FQCMsV59f3THSNBlGUAvNo+ATaPAuskN+A63MF
         uricGFaPzzsn5n+rEgxulKAEkSq5g286xW2/vaY9RtjRotc1uPDu6Iyfh7fmieq4dxhT
         lt3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukeEKq4T1mTSAM27zkGYSbdz+pF5KaeSSZySmoDfA8wmAvGrAaCK
	rxxb0pKrBu5LkxjDhvvmpt1STxEco1h12b+ObxyjyW+VCaRnveDc111ifIY5bvyqT8tVicX8j48
	MLFnbRbmjlOCM5LnrQdpr14marJi5exvhT+OhQpvxcb+EQH6N5c1VGi7I7elESDZ81A==
X-Received: by 2002:aa7:dd0f:: with SMTP id i15mr25423213edv.29.1548787800875;
        Tue, 29 Jan 2019 10:50:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5D/cc8Pvfobcng/yVBMiKgAPkUgKyyyYppoPx1g0GomMPjvQGYUJFwK2V5777bi8duKdXr
X-Received: by 2002:aa7:dd0f:: with SMTP id i15mr25423178edv.29.1548787800094;
        Tue, 29 Jan 2019 10:50:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787800; cv=none;
        d=google.com; s=arc-20160816;
        b=GjGlk4f426yTjjEvibDoiHD0/D7QqZr656Wf4Nxs6PmLQ35yJ9q553rFHYLZ8VL9q4
         HCpjisgnNSNvVeXVFx5kctCguAKYEtiZmLk0SF+Ds5Qv6S+aAVt3dqsb9z32gvNOg7dG
         8HUlVbva8c4q9rh1lB3M0Yyd3Btk9LKX97SOqXVyC9lLGdxE18CHR8eMByTa+K7wa+xL
         VFvp3JbIO/hfhJTXW6DDjA8z37tPi2/wpwKGc4+0fv+8aecN2GylaXK4+poxG8SVcQT6
         qpeqBnacYPwaWaKH84mY1qBaqdL3BzKrDixtWVfuV0vAYLOvMzv3N9dHVMqb+9StpQXD
         h+5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=k7wnSh0/AWdeE9IE2N0pFqQz9uaZdVz3WI19ff9zm4Y=;
        b=EHfQlshV/aIZQrTZIuoQk0vEqc/YATmIqIr9HGFLxGlQvb95WzP4TMRMQhlpuwQkUa
         5CNm5Rcmbq14Qf3AlgBBW4S+igJ5XseBmMPKPDsStB0mknEWmaZBdV+EHUxEYqjf8tNj
         DAYnT5UjLNVGn8fm3fopO33M3i1xvl40dR12jgl87X1b9EDqbaDiDYP2JucNzXE8I7eN
         9enCYWqpGg20T79XIf2FHYEJ+bj0WqyUfMZT1Uih/BcXADQ1bBkjRT5BWc9wd6PO/QYc
         Wf4riXEOPCLBtINRIlJaztI3VXiJ3aa31Njt40fQAmZflvMHbKXnL5DfjbMpzXPkP/u+
         COmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m22si3009302edj.434.2019.01.29.10.49.59
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:00 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1E30E1596;
	Tue, 29 Jan 2019 10:49:59 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 711903F557;
	Tue, 29 Jan 2019 10:49:56 -0800 (PST)
From: James Morse <james.morse@arm.com>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	Borislav Petkov <bp@alien8.de>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>,
	james.morse@arm.com
Subject: [PATCH v8 07/26] ACPI / APEI: Remove spurious GHES_TO_CLEAR check
Date: Tue, 29 Jan 2019 18:48:43 +0000
Message-Id: <20190129184902.102850-8-james.morse@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190129184902.102850-1-james.morse@arm.com>
References: <20190129184902.102850-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ghes_notify_nmi() checks ghes->flags for GHES_TO_CLEAR before going
on to __process_error(). This is pointless as ghes_read_estatus()
will always set this flag if it returns success, which was checked
earlier in the loop. Remove it.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
---
 drivers/acpi/apei/ghes.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index a34f79153b1a..c20e1d0947b1 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -940,9 +940,6 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 			__ghes_panic(ghes, buf_paddr);
 		}
 
-		if (!(ghes->flags & GHES_TO_CLEAR))
-			continue;
-
 		__process_error(ghes);
 		ghes_clear_estatus(ghes, buf_paddr);
 	}
-- 
2.20.1

