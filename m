Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A24AC32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E60C92086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E60C92086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 069016B02F3; Fri,  9 Aug 2019 12:03:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01A366B02F5; Fri,  9 Aug 2019 12:03:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E729F6B02F6; Fri,  9 Aug 2019 12:03:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93F096B02F3
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:03:35 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id s19so1065690wmc.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:03:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7mcumJBqdazdFc0uiihrbxjc9n4H1WzR9co/oSUGg5w=;
        b=mF3OYTsQS1kWvRY0Vzvi7LfB+Ff7+4tAPJKgebP58UZK0WswOVpB0cpcQtn186mleh
         MwNy6Oi6te8ackyGl1OPkR1x0mtNScmTrhIGyM7uVxPcXpLSroVlEHGgvIlUvClz0Yoc
         iwvpexG3r1T79A5iYjaWGaDw9RRLSenQlk3p+w4mrpCMDM1/QTGZVqUhx/ALP20CeRGX
         JKTVihvKs/B/eomxJaeQblE9jqKGz6gaY+/hH05MAdnaDlyeQ52boSOlesFffiX+Lj4V
         3ud16fbN9PVfSpBhHXzfJ1Avji4CNHC9nDq11GRvqSntBWO/LMeJ4iTecqx2V4gKlZ0w
         hFEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWvxrhJaairZJjgsHs1xj6p39Kblt2RG/i4F4R0ABDxvZP7lEyp
	fEMg0wLjtCh9oC5+YQ+v+llVEqdHG7N83YOnU1wzlqxrkeSxpf7Ue3x4N2vJzN607fiDKN0LzRJ
	zZ+3czC7mOQxbEpQXA3gT3MtyvRg/TVjOE9alWD1O1e6VHKRQX/5jp1gzhtLTcVxCNA==
X-Received: by 2002:a7b:c212:: with SMTP id x18mr11507413wmi.77.1565366614684;
        Fri, 09 Aug 2019 09:03:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3yN+5UApJ/Js8lqaii3GIip6VDDjE9SEeFvazhgzeYBrC8PmEm+COIOmsgINlVCiyMTib
X-Received: by 2002:a7b:c212:: with SMTP id x18mr11495308wmi.77.1565366489252;
        Fri, 09 Aug 2019 09:01:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366489; cv=none;
        d=google.com; s=arc-20160816;
        b=KOSAnsgYRu8WtWcROcEdQgnes8z3qk/11KJqHwtZT0RTum19lLcerLmOQ+p9EFteX4
         57nX38giIKF+VZKTk7B/PMPixeHe83BDGyU+XV1QuU7tDlzeqEQmsjr98D63TWINBEHO
         33QbSvbHqBJNaFVlnNnMeOA6N2WMG+z0TE3rhyO9McIASWFFlO9bM9FL14EcPwI6kdSE
         EIAhlxa6QglVdYF0w8KX414WBZFi8COFwtDrVOri5iYqoZ+oOmEDghcHyD0uZit5vWYo
         7KPMktG4k33L8f+9ykPK2+2PlpESGCa7umcB6JurjI0qyXhXt4pNpPNsXylfg7wpTeFO
         mYGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7mcumJBqdazdFc0uiihrbxjc9n4H1WzR9co/oSUGg5w=;
        b=0ipbN507UuK6nmGfMbcSXO00LG6grtbNd5aGrT2XPQ1LFUF+LKAxgzACheBeM1sZEi
         FPjhbFb3eg6v9HunKrhei1fcL6AS0+oEgannGI+j36QsHu5NuYEtkqEvMvyUP+4zCTme
         WcqqcuOpH+Vw89btsc9ozucn7cWSFSmax9W9jgutKJKaKoK85DbNahgx+Zlr5uv4x5C2
         sPCsVYsLkcxJ3rbXC5huYv5QkRgT3+Lr+0G6XDoKz2d/QLqUmRJDbdElD2PDP3qRLKFu
         dEhAxOXu/c7jdc6iJQmhv1zo2L4xqY/AT8Xbri6iffwLZDJgkqqHKdQIbxfgp7m4/Xmp
         zMVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id p1si86566151wrn.142.2019.08.09.09.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id A22CB305D356;
	Fri,  9 Aug 2019 19:01:28 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 58C85305B7A3;
	Fri,  9 Aug 2019 19:01:28 +0300 (EEST)
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
	=?UTF-8?q?Nicu=C8=99or=20C=C3=AE=C8=9Bu?= <ncitu@bitdefender.com>
Subject: [RFC PATCH v6 65/92] kvm: introspection: add KVMI_EVENT_SINGLESTEP
Date: Fri,  9 Aug 2019 19:00:20 +0300
Message-Id: <20190809160047.8319-66-alazar@bitdefender.com>
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

From: Nicușor Cîțu <ncitu@bitdefender.com>

This event is sent when the current instruction has been single stepped
as a result of a KVMI_EVENT_PF event to which the introspection tool
set the singlestep field and responded with CONTINUE.

Signed-off-by: Nicușor Cîțu <ncitu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 25 +++++++++++++++++++
 virt/kvm/kvmi.c                    | 40 ++++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 8721a470de87..572abab1f6ef 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -1574,3 +1574,28 @@ introspection has been enabled for this event (see **KVMI_CONTROL_EVENTS**).
 	KVMI_DESC_TR
 
 ``write`` is 1 if the descriptor was written, 0 otherwise.
+
+12. KVMI_EVENT_SINGLESTEP
+-------------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event;
+
+:Returns:
+
+::
+
+	struct kvmi_vcpu_hdr;
+	struct kvmi_event_reply;
+
+This event is sent when the current instruction has been executed
+(as a result of a *KVMI_EVENT_PF* event to which the introspection
+tool set the ``singlestep`` field and responded with *CONTINUE*)
+and the introspection has been enabled for this event
+(see **KVMI_CONTROL_EVENTS**).
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index a3a5af9080a9..3dfedf3ae739 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -1182,6 +1182,44 @@ void kvmi_trap_event(struct kvm_vcpu *vcpu)
 	kvmi_put(vcpu->kvm);
 }
 
+static u32 kvmi_send_singlestep(struct kvm_vcpu *vcpu)
+{
+	int err, action;
+
+	err = kvmi_send_event(vcpu, KVMI_EVENT_SINGLESTEP, NULL, 0,
+			      NULL, 0, &action);
+	if (err)
+		return KVMI_EVENT_ACTION_CONTINUE;
+
+	return action;
+}
+
+static void __kvmi_singlestep_event(struct kvm_vcpu *vcpu)
+{
+	u32 action;
+
+	action = kvmi_send_singlestep(vcpu);
+	switch (action) {
+	case KVMI_EVENT_ACTION_CONTINUE:
+		break;
+	default:
+		kvmi_handle_common_event_actions(vcpu, action, "SINGLESTEP");
+	}
+}
+
+static void kvmi_singlestep_event(struct kvm_vcpu *vcpu)
+{
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+
+	if (!ivcpu->ss_requested)
+		return;
+
+	if (is_event_enabled(vcpu, KVMI_EVENT_SINGLESTEP))
+		__kvmi_singlestep_event(vcpu);
+
+	ivcpu->ss_requested = false;
+}
+
 static bool __kvmi_create_vcpu_event(struct kvm_vcpu *vcpu)
 {
 	u32 action;
@@ -1616,6 +1654,8 @@ void kvmi_stop_ss(struct kvm_vcpu *vcpu)
 
 	ivcpu->ss_owner = false;
 
+	kvmi_singlestep_event(vcpu);
+
 out:
 	kvmi_put(kvm);
 }

