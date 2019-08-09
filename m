Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F0E2C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC5D62089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:01:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC5D62089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BCCE6B026C; Fri,  9 Aug 2019 12:01:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F37736B026F; Fri,  9 Aug 2019 12:00:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E27CA6B026D; Fri,  9 Aug 2019 12:00:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7BCD46B0266
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:00:59 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id t10so1727461wrn.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yrH2q+/apPGV2EQuMM5CIOxBMVZ3GLh+v2OfLTnon34=;
        b=WKyuvJjvpBZ7tESxlY2+ubKLHLsIWzbXz/HxQyXgTzGze2yin4Oi4dAtt6KxodfInt
         X7rOTX/5KSsR68MqT+3HNLlaSutGQ4kOlf9KQPz5Hswus7YPLTPodKUXWAnbtYUoEOMe
         BPLOYyV4ZJrt7mz1O1DH7dV/bCWycexh5sn0nYHoiHy2N5stp0rrWyAiHi2ab4ZAkmUN
         5on0dgXSVjmlj9OZaIi4xTChbEepW0Kt217MzUwpYUsso/QrWtjptoXPaxZlIBqPkzsz
         K/M1Hdf8/7owaocT+26wPYoq2MsK1VpSmJ1qRw3PpQ9PWPWFPn47hcEXlrEPBYT+ThBI
         pRcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVP3SPezL53EdOyEWErFP5Yaf3LHmiUFF3lMOAc+f4pIIvAROOA
	Ahzr5SfgPJgN0a7sbCaSbnt3VOKo91DFkA7d6Hm5pSdKry2j9JA8/WyCSxLq5iz34e9+kAvz08F
	LxzztE7kJyr5C90xReMWgZMpYQovze5maPFjTZPwzW/IpWYkWizp7S0Jgt8qQWx1zZQ==
X-Received: by 2002:a1c:ed09:: with SMTP id l9mr12004298wmh.58.1565366459069;
        Fri, 09 Aug 2019 09:00:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7i3Q31E3Kj5RfI4Db02tDVVKnhHpx8MJBFKJYckqFQYsMk7bbkNOX9gi2ebVtX14GqMcY
X-Received: by 2002:a1c:ed09:: with SMTP id l9mr12004168wmh.58.1565366457573;
        Fri, 09 Aug 2019 09:00:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366457; cv=none;
        d=google.com; s=arc-20160816;
        b=TSjUf3gsfbAPcxZ3tjfyIhksQJA4NvcSqjpTuGCvo4vs3zHeL66MduyZVf/a7Pczx+
         g4sSGRjjNkdqKDd6MLBpLGfSXdUS0JaUHz25DHtnhv1y2XTMoO2UJw4/8vtj1CNKg70d
         CJ14pgI6ieGdvlehsZTNpl34spObVfV4A5dfE+xwXnG8Wvhyy0xXu6g8NgPfgYRNUryC
         yLeqUCC9qO6kABnH9b0P7/33Qm/2hmIUi/xKnaiKi4ripPAZy4OxuFsUwBvq1Es3LxiG
         tTTWOtLELC9t1jOFmZ5lQpXeXIZbriVMtSR0ZO8URun63VgI7oPgYsMEbCLaMQoRiSkW
         rwew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yrH2q+/apPGV2EQuMM5CIOxBMVZ3GLh+v2OfLTnon34=;
        b=09elL+2el4rc1iersKIxyFa2fdUW+gNfkBC9zY+qxlzvn9OamvfoHOdNTDQdQvk3dj
         H8q96hmoNo7Mg6FAGwBzVoQMkzz3CEOft4t+lnwDD2dyGTSGMc+G9QHVAzw+zOG8TWDl
         rpQkwlHhI+PEpGJpcoxFTaIp2oDvwvOcg6IfbK4j/RUE9g+LEdewRRLn6huHJRanPzEs
         oBKeMAQ8p5Xe2rHseS0UDEDTKi6Q7e6zXKYlKlSkSTV+lc6TrkvPNo8Cd3rCRTF9xyWl
         vQLD27O0Nigb3C+s1QcQLTxKn6+c78y+WAaQ9Et8KwBzF6LYl7a98j6/ybXlrmp/uzSZ
         t+og==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id d8si88720296wrj.26.2019.08.09.09.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:00:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E7272305D3D4;
	Fri,  9 Aug 2019 19:00:56 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 67D83305B7A0;
	Fri,  9 Aug 2019 19:00:56 +0300 (EEST)
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
Subject: [RFC PATCH v6 13/92] kvm: introspection: make the vCPU wait even when its jobs list is empty
Date: Fri,  9 Aug 2019 18:59:28 +0300
Message-Id: <20190809160047.8319-14-alazar@bitdefender.com>
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

Usually, the vCPU thread will run the functions from its jobs list
(unless the thread is SIGKILL-ed) and continue to guest when the
list is empty. But, there are cases when it has to wait for something
(e.g. another vCPU runs in single-step mode, or the current vCPU waits
for an event reply from the introspection tool).

In these cases, it will append a "wait job" into its own list, which
will do (a) nothing if the list is not empty or it doesn't have to wait
any longer or (b) wait (in the same wake-queue used by KVM) until it
is kicked. It should be OK if the receiving worker appends a new job in
the same time.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 include/linux/swait.h | 11 ++++++
 virt/kvm/kvmi.c       | 80 +++++++++++++++++++++++++++++++++++++++++++
 virt/kvm/kvmi_int.h   |  2 ++
 3 files changed, 93 insertions(+)

diff --git a/include/linux/swait.h b/include/linux/swait.h
index 73e06e9986d4..2486625e7fb4 100644
--- a/include/linux/swait.h
+++ b/include/linux/swait.h
@@ -297,4 +297,15 @@ do {									\
 	__ret;								\
 })
 
+#define __swait_event_killable(wq, condition)				\
+	___swait_event(wq, condition, TASK_KILLABLE, 0,	schedule())	\
+
+#define swait_event_killable(wq, condition)				\
+({									\
+	int __ret = 0;							\
+	if (!(condition))						\
+		__ret = __swait_event_killable(wq, condition);		\
+	__ret;								\
+})
+
 #endif /* _LINUX_SWAIT_H */
diff --git a/virt/kvm/kvmi.c b/virt/kvm/kvmi.c
index 07ebd1c629b0..3c884dc0e38c 100644
--- a/virt/kvm/kvmi.c
+++ b/virt/kvm/kvmi.c
@@ -135,6 +135,19 @@ static void kvmi_free_job(struct kvmi_job *job)
 	kmem_cache_free(job_cache, job);
 }
 
+static struct kvmi_job *kvmi_pull_job(struct kvmi_vcpu *ivcpu)
+{
+	struct kvmi_job *job = NULL;
+
+	spin_lock(&ivcpu->job_lock);
+	job = list_first_entry_or_null(&ivcpu->job_list, typeof(*job), link);
+	if (job)
+		list_del(&job->link);
+	spin_unlock(&ivcpu->job_lock);
+
+	return job;
+}
+
 static bool alloc_ivcpu(struct kvm_vcpu *vcpu)
 {
 	struct kvmi_vcpu *ivcpu;
@@ -496,6 +509,73 @@ void kvmi_destroy_vm(struct kvm *kvm)
 	wait_for_completion_killable(&kvm->kvmi_completed);
 }
 
+void kvmi_run_jobs(struct kvm_vcpu *vcpu)
+{
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+	struct kvmi_job *job;
+
+	while ((job = kvmi_pull_job(ivcpu))) {
+		job->fct(vcpu, job->ctx);
+		kvmi_free_job(job);
+	}
+}
+
+static bool done_waiting(struct kvm_vcpu *vcpu)
+{
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+
+	return !list_empty(&ivcpu->job_list);
+}
+
+static void kvmi_job_wait(struct kvm_vcpu *vcpu, void *ctx)
+{
+	struct swait_queue_head *wq = kvm_arch_vcpu_wq(vcpu);
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+	int err;
+
+	err = swait_event_killable(*wq, done_waiting(vcpu));
+
+	if (err)
+		ivcpu->killed = true;
+}
+
+int kvmi_run_jobs_and_wait(struct kvm_vcpu *vcpu)
+{
+	struct kvmi_vcpu *ivcpu = IVCPU(vcpu);
+	int err = 0;
+
+	for (;;) {
+		kvmi_run_jobs(vcpu);
+
+		if (ivcpu->killed) {
+			err = -1;
+			break;
+		}
+
+		kvmi_add_job(vcpu, kvmi_job_wait, NULL, NULL);
+	}
+
+	return err;
+}
+
+void kvmi_handle_requests(struct kvm_vcpu *vcpu)
+{
+	struct kvmi *ikvm;
+
+	ikvm = kvmi_get(vcpu->kvm);
+	if (!ikvm)
+		return;
+
+	for (;;) {
+		int err = kvmi_run_jobs_and_wait(vcpu);
+
+		if (err)
+			break;
+	}
+
+	kvmi_put(vcpu->kvm);
+}
+
 int kvmi_cmd_control_vm_events(struct kvmi *ikvm, unsigned int event_id,
 			       bool enable)
 {
diff --git a/virt/kvm/kvmi_int.h b/virt/kvm/kvmi_int.h
index 97f91a568096..47418e9a86f6 100644
--- a/virt/kvm/kvmi_int.h
+++ b/virt/kvm/kvmi_int.h
@@ -85,6 +85,8 @@ struct kvmi_job {
 struct kvmi_vcpu {
 	struct list_head job_list;
 	spinlock_t job_lock;
+
+	bool killed;
 };
 
 #define IKVM(kvm) ((struct kvmi *)((kvm)->kvmi))

