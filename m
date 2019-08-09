Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0BF3C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FC512089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FC512089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 610C46B0274; Fri,  9 Aug 2019 12:01:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C36F6B0278; Fri,  9 Aug 2019 12:01:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4170E6B0279; Fri,  9 Aug 2019 12:01:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA51E6B0274
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:02 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id d65so1447142wmd.3
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nk7ll5TwXkOt0rRg6By9PPWqd17DrrzkOPTyofxrVaQ=;
        b=kPQP2IqYfAENd7xwyrzM3PhpV6l/lLi7A/5Kd4PISvS/pHirVLFtFqHUssSM2SvBXX
         l2H3Rp7hDDYveFLVDNkT11w/TS5cJl+rlaqLRBivVLx2eih/UXEmkbyFoq4Dt0D1tA/3
         X2jA88C9OpFRDsEQDW1HbOz/Mh0DauoQOI6962nUkyAuzgFiJPVCvGs+PA4lcgTpAq41
         FdP9I8RNM67OjvNreAy6d5QE68dIi1KcHYdxqAu90d35A5Ab9f5hjOPYsvLUpbOT3hmq
         B3fwQ5ozVgEhKu3FpM7bQ+c040JQmpH5XaWmzqXUnr9v9OBHyKPbiJugIsOLWbhJ5bok
         8nyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVIiYs9oned84NPPWfJNOQ7jtLDqxM2JtFEW8L+IXvHoD+T0zQb
	/mYVMXd3R2KlMe3Xf7eR7XNxSdOU3QAe5EAZUc6ahTHCfXbIHe7d5XiF0fwtWRW6so7ZqsFdR2M
	0fIxe+eWg0+AncxpAZKbw6nRex0TSf/iTq4126eyqUbYGNJTgXvfpHooaE4S/1pl59A==
X-Received: by 2002:adf:db0e:: with SMTP id s14mr12362048wri.333.1565366462429;
        Fri, 09 Aug 2019 09:01:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjzUsmbZ71oBwm+4fq+1c76yF1RPJzjGuPWfN4BzusUrTvCqmf2F+dNjQ9OipsDbF0iwAY
X-Received: by 2002:adf:db0e:: with SMTP id s14mr12361946wri.333.1565366461486;
        Fri, 09 Aug 2019 09:01:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366461; cv=none;
        d=google.com; s=arc-20160816;
        b=UU1Tm9FsooJ1dI36uGcOV6fTyNsa2mC7BU7OqOANXryiPCV82zMjQ3SrLr+QitAwqm
         1wmkxk2EePbIEx77n9wFfdxxfYy6Nfeow2Ea1Ib8VBhXYtFShabu6MV2a6NEiqOyD9on
         JyW83yb6sKGPVDHStMUaZnRrTTwLRQfWXdKGPTpXTC/mSvagkZWqbegNizdticyl+Zj8
         NDU7q1n4c5N4btSyM8QLnBekE0P8wLEMJf2BN2mjZsZ6OOdlGyy9ACCjAI49o4H1+iwY
         evMXVkjcqzufNyAtQbOYjxdNEXEEZ+OV4By1Jjzg9Thf6kA/+H/HDyASv1h4iRq/HKsI
         cBjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nk7ll5TwXkOt0rRg6By9PPWqd17DrrzkOPTyofxrVaQ=;
        b=AyhICFdX0Lm8KqaCM/3hwrL8ZHV9DwJojwFnRh26QRELsaCUMwxrX7UAD0Q5RyIUGN
         COjPHL2ZqEGOqUOz96OORYUigIkzdJBkMUJOQhEYvjRTgnKAGZr4ovefPs3AXGFKiYY6
         xNcIE74lqvMbFJtabi279cUB5b7ZsFPZ260fwyEJd4Q0nStvN4VMqteXfgbSRwb98BcG
         N2E05DqOHrmY+4eKcBDT0wx/wPyW61EPZK/csDvnPtd0RkL4/uQXKzCUYk9ONa33T6p7
         u4MmqZdIBPVAvcF5JWmlu1mcXc64sGZXS759HQVUkMVYuELJmNRqZ/2zLXWIa2EvIKqI
         XUIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id a4si3944250wmh.23.2019.08.09.09.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E3977305D3DB;
	Fri,  9 Aug 2019 19:01:00 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 7B291305B7A3;
	Fri,  9 Aug 2019 19:01:00 +0300 (EEST)
From: =?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	=?UTF-8?q?Samuel=20Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	=?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>,
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>,
	Joerg Roedel <joro@8bytes.org>
Subject: [RFC PATCH v6 25/92] kvm: x86: intercept the write access on sidt and other emulated instructions
Date: Fri,  9 Aug 2019 18:59:40 +0300
Message-Id: <20190809160047.8319-26-alazar@bitdefender.com>
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is needed for the introspection subsystem to track the changes to
descriptor table registers.

CC: Joerg Roedel <joro@8bytes.org>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/x86.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 7aef002be551..c28e2a20dec2 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5185,11 +5185,14 @@ static int kvm_write_guest_virt_helper(gva_t addr, void *val, unsigned int bytes
 
 		if (gpa == UNMAPPED_GVA)
 			return X86EMUL_PROPAGATE_FAULT;
+		if (!kvm_page_track_prewrite(vcpu, gpa, addr, data, towrite))
+			return X86EMUL_RETRY_INSTR;
 		ret = kvm_vcpu_write_guest(vcpu, gpa, data, towrite);
 		if (ret < 0) {
 			r = X86EMUL_IO_NEEDED;
 			goto out;
 		}
+		kvm_page_track_write(vcpu, gpa, addr, data, towrite);
 
 		bytes -= towrite;
 		data += towrite;

