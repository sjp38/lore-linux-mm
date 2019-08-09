Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDF69C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D2DD2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D2DD2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A357F6B0269; Fri,  9 Aug 2019 12:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A9B06B000E; Fri,  9 Aug 2019 12:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51F2A6B0269; Fri,  9 Aug 2019 12:00:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA0176B000E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:56 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id e6so46640647wrv.20
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PxAl2ay/WZndf3MUVVim+vjyHHH3w/V1qSzjjfQlgNk=;
        b=Jjl4tWBf1S+uHTxDZfiiIoMiKhKOt/vcjsq9lZCq6W5Z6MyOd+Tj1y0n0itd3l5l7b
         7kIBttpcZYpx1PJ/FtOYnt1otHBHZesFd/O0YonjUJvgOTiLRW2WY3UcicSP7KIKqYy3
         IJvQWlnfvozJ66q4Qn0AsDohW5mBWqpRTS/plJ1ptdbajWnXf+i65pQ1gKoylK111LvS
         8FmMq5MCcq9sAlxH19V23KZrseF6ewiA828LHmzPd+yOhYOMAle4l3sCd+RjVP68WBzg
         gxRzUZ2bkMEr24iF9kpx2GZQPLV8xS7NceGUKu29nC/iD1JC9YPtjlsAx2PpLTGqZpx7
         AoSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWr1Pp3CaPrYnc+iQj0h6oB/Q9HEGYVP7PZj88A9BMVgQ42ttSK
	u/eryYo0fJ7FTq8e+VuzfBVWxqonhNsJGLtolK2UIvGkuK3bNz+aGSC8s5QevhjLqaVzd8G5bDR
	vBIEIOxMHFongfoWmGrV14a5Zfs9n8Ukt1nDdayBoLTwC8iSvL8SdsBdJV5ly7Ujr6g==
X-Received: by 2002:a5d:51c1:: with SMTP id n1mr24649829wrv.254.1565366456528;
        Fri, 09 Aug 2019 09:00:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1hJC5tFVWOLjM2kDuWd7z59RlI/+NaAizgBZq90sajwVGGIxtz7Iq7XyziaYR2FpMoKID
X-Received: by 2002:a5d:51c1:: with SMTP id n1mr24649729wrv.254.1565366455562;
        Fri, 09 Aug 2019 09:00:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366455; cv=none;
        d=google.com; s=arc-20160816;
        b=cuUCMa3w4nYs8NV8t5r0FrBuGjx5mzJL/AK3Rlvq3ykusjYR6+NVrTpPACNovblmhu
         Gk8uu0p9zZcOeQFTG/BakpbY2UYKvpTZe0MUttAYmW/h/hT/2n7M5sNxRoZqBhQnMNfM
         cLppTS4qfQc1GU1wO03UQVpfL6ZOSfoKrDV/q9hvvFKPu5SfFmKorsBkfoIO+S+GFIXM
         02AdKovXkpJMM4xkpQRcvwtqAA9iEq4pvhCtV6yDXJ3PuaJg2juUp/BbI7FTy9OL3m+y
         WsMSU0hytAj4XtF13cE2Ah27l5ck8twFQXdtfTFvQKneadLUNSvmmVoXoaVWlnh4Tm3q
         8dnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PxAl2ay/WZndf3MUVVim+vjyHHH3w/V1qSzjjfQlgNk=;
        b=KX7Z45F3D5vbfIxc95gVAfCTCYZOqDm6RH6v2dgQpaZecmPyxtHT7ouTcAbfCh0hIO
         Ur5WokwHx1WrA36TU4p4r/UdMyOYKMBt8paNq86wwuzEGMDStWUx3Sf6jgBvAFmaDhRf
         uB450i6hfZ8ZpKiECJIiiU+KeJpvHlRBsZtu74v+KllC0ParXB1hJc0twGg7u6i6D6NG
         fz1N6tt9wf/9GKDH21Du7KnHWqqeQPygV9ttPNiDE1E7nnL/U4etcREuxpKewRc14+Zh
         11GNIo2DwXO5mNxP9JzvcXywBlJxlHZGhKkM5XoPNOx94/sdAmedP0cC5n+4HITRQNdR
         eaPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id v74si4434460wmf.17.2019.08.09.09.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E5A0C301AB4A;
	Fri,  9 Aug 2019 19:00:54 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id A705D305B7A0;
	Fri,  9 Aug 2019 19:00:54 +0300 (EEST)
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
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v6 09/92] kvm: introspection: add KVMI_GET_GUEST_INFO
Date: Fri,  9 Aug 2019 18:59:24 +0300
Message-Id: <20190809160047.8319-10-alazar@bitdefender.com>
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

From: Mihai Donțu <mdontu@bitdefender.com>

For now, this command returns only the number of online vCPUs.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/kvmi.rst | 18 ++++++++++++++++++
 include/uapi/linux/kvmi.h          |  5 +++++
 virt/kvm/kvmi_msg.c                | 14 ++++++++++++++
 3 files changed, 37 insertions(+)

diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
index 61cf69aa5d07..2fbe7c28e4f1 100644
--- a/Documentation/virtual/kvm/kvmi.rst
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -362,3 +362,21 @@ This command is always allowed.
 
 * -KVM_PERM - the event specified by ``id`` is disallowed
 * -KVM_EINVAL - padding is not zero
+
+5. KVMI_GET_GUEST_INFO
+----------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:: none
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_guest_info_reply {
+		__u32 vcpu_count;
+		__u32 padding[3];
+	};
+
+Returns the number of online vCPUs.
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
index 7390303371c9..367c8ec28f75 100644
--- a/include/uapi/linux/kvmi.h
+++ b/include/uapi/linux/kvmi.h
@@ -102,4 +102,9 @@ struct kvmi_check_event {
 	__u32 padding2;
 };
 
+struct kvmi_get_guest_info_reply {
+	__u32 vcpu_count;
+	__u32 padding[3];
+};
+
 #endif /* _UAPI__LINUX_KVMI_H */
diff --git a/virt/kvm/kvmi_msg.c b/virt/kvm/kvmi_msg.c
index e24996611e3a..cf8a120b0eae 100644
--- a/virt/kvm/kvmi_msg.c
+++ b/virt/kvm/kvmi_msg.c
@@ -12,6 +12,7 @@ static const char *const msg_IDs[] = {
 	[KVMI_CHECK_COMMAND]         = "KVMI_CHECK_COMMAND",
 	[KVMI_CHECK_EVENT]           = "KVMI_CHECK_EVENT",
 	[KVMI_CONTROL_CMD_RESPONSE]  = "KVMI_CONTROL_CMD_RESPONSE",
+	[KVMI_GET_GUEST_INFO]        = "KVMI_GET_GUEST_INFO",
 	[KVMI_GET_VERSION]           = "KVMI_GET_VERSION",
 };
 
@@ -213,6 +214,18 @@ static int handle_check_event(struct kvmi *ikvm,
 	return kvmi_msg_vm_maybe_reply(ikvm, msg, ec, NULL, 0);
 }
 
+static int handle_get_guest_info(struct kvmi *ikvm,
+				 const struct kvmi_msg_hdr *msg,
+				 const void *req)
+{
+	struct kvmi_get_guest_info_reply rpl;
+
+	memset(&rpl, 0, sizeof(rpl));
+	rpl.vcpu_count = atomic_read(&ikvm->kvm->online_vcpus);
+
+	return kvmi_msg_vm_maybe_reply(ikvm, msg, 0, &rpl, sizeof(rpl));
+}
+
 static int handle_control_cmd_response(struct kvmi *ikvm,
 					const struct kvmi_msg_hdr *msg,
 					const void *_req)
@@ -246,6 +259,7 @@ static int(*const msg_vm[])(struct kvmi *, const struct kvmi_msg_hdr *,
 	[KVMI_CHECK_COMMAND]         = handle_check_command,
 	[KVMI_CHECK_EVENT]           = handle_check_event,
 	[KVMI_CONTROL_CMD_RESPONSE]  = handle_control_cmd_response,
+	[KVMI_GET_GUEST_INFO]        = handle_get_guest_info,
 	[KVMI_GET_VERSION]           = handle_get_version,
 };
 

