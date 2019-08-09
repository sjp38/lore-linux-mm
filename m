Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0EE8C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40C652089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40C652089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A0D06B0284; Fri,  9 Aug 2019 12:01:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DB586B0285; Fri,  9 Aug 2019 12:01:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0FE6B0286; Fri,  9 Aug 2019 12:01:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF6F66B0285
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:13 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id j10so3892800wrb.16
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WRqFCfCUQtbhQbqxG+++3XzmVb9MUlvlyqu21r7TEwI=;
        b=D4rXuVTtOiWUXdtV9peITQXWfYJ+Z+B8KlBYIAlw31YaN+88GoXX834nMOOYRnFbyJ
         WxQozKUjFPbV0XXooRH8nuLUYHOwdAKhSVpq/jm9pV0BrD/aXrBxumLET/8dsoaXBB4t
         dUTT79H76VZdt8E3QKqz6VLIMLpunKqngwiPOxyZaTKYXr025cMKxnKPyvULL+Uv0PrV
         6riAv+me2pnOW1/+y2lAnG7pJOTZZS3tMWsZ1GC01Xkapu8kGpbHlNxWXtEWcS4P67OA
         goaETfUj9ylHdJBoGlB3zBVczDdPyGkQ5ptiUZ8ioX7cCD+z8K5wb3DP3blU3BUkEHDk
         8Xvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWhP+OFnYr4y2AeSuA0Ov+keRbFWDqqkA2cST27SDZCHHBGMsqH
	6YKZxfv614Nri2SXMTmhuywzonDLIhOYTrfaMFIyQ2yx/ZD8ZASJtFHF8Is/54gYPumagJAqqno
	hBK3+d26KzlK1y1G40RY2qbIJZZ9MCCuy2PtXcxHeA0XcvOsmtyd8FefIdY7ohGqDEw==
X-Received: by 2002:a1c:7c08:: with SMTP id x8mr11800119wmc.19.1565366473280;
        Fri, 09 Aug 2019 09:01:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfN02P1+fmyYtk8fE3vSwWkFMPkzLzlIE3VKXxsVoJY3v2qJtg+X0vAtxwnQC+GlxR5aWR
X-Received: by 2002:a1c:7c08:: with SMTP id x8mr11799916wmc.19.1565366471094;
        Fri, 09 Aug 2019 09:01:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366471; cv=none;
        d=google.com; s=arc-20160816;
        b=VZneE9mK2KOFAVezbxT2OsK+Y5fJbdbguVg7MyemUrbjunCvKmHMADXXnaIe2iLcwQ
         DzDAqqmshAvGQ9sEf5K0djBmv7VmQ79KB23YpbGix1O8zQV5nkVIL5qk3836pJL0a7xH
         +nN4ex/SJzPTsOUM/oXtCjau2XUtu3hsfS+QcvId9SJDtbosyxSH8BuR6PIHw3Fy8qzD
         NQWIqHVNN/UID/7F4uQga5EEej7eDNe4BkKjiulQ2Ykb1eFkephJXXUIRuYRYVwaLXla
         nYtqtxIbJgTPYeHkL5OwclGDtxtKlEH+4mFAz8qsk+Y8/fCIjqee6ltW3GY37f0N/4k7
         RPaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WRqFCfCUQtbhQbqxG+++3XzmVb9MUlvlyqu21r7TEwI=;
        b=kEUDOho8JLqWNjXml9U+ftEFA7KWWORkeqHimBMSo4qxJ2B+FKGcQ8RjbBZYnBjG1z
         kXatNM9lzTasMGl15+UKMlghSc/NWHAbZSJ2rjWkeEjgGN7T79FtkH3mUTNNKeTtNdFt
         D2T1vZ7KKcmGXsih4AmF6xTYoxQveKQAFM4M7E5bbFXh6QGi1yehezJy0msMb2a+AmAj
         vr5ImjnxOhuXra8PUFTOvVFxCeHb2TexCj8MOJI+nqKIwcfl2JzHJvV/9W2zhZawYcsT
         J2C1yZ9dWPa7JboZ6JzKWiW8T99c3WDhGMIux1/7B81ROmU0YwnwFNZTB6oPUZa5C/y8
         GQVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id j6si88397564wrn.199.2019.08.09.09.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 7A332302478E;
	Fri,  9 Aug 2019 19:01:10 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 0075D305B7A3;
	Fri,  9 Aug 2019 19:01:08 +0300 (EEST)
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
	He Chen <he.chen@linux.intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [RFC PATCH v6 39/92] KVM: VMX: Introduce SPP user-space IOCTLs
Date: Fri,  9 Aug 2019 18:59:54 +0300
Message-Id: <20190809160047.8319-40-alazar@bitdefender.com>
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

From: Yang Weijiang <weijiang.yang@intel.com>

User application, e.g., QEMU or VMI, must initialize SPP
before gets/sets SPP subpages, the dynamic initialization is to
reduce the extra storage cost if the SPP feature is not not used.

Co-developed-by: He Chen <he.chen@linux.intel.com>
Signed-off-by: He Chen <he.chen@linux.intel.com>
Co-developed-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Co-developed-by: Yang Weijiang <weijiang.yang@intel.com>
Signed-off-by: Yang Weijiang <weijiang.yang@intel.com>
Message-Id: <20190717133751.12910-7-weijiang.yang@intel.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/x86.c       | 73 ++++++++++++++++++++++++++++++++++++++++
 include/linux/kvm_host.h |  3 ++
 include/uapi/linux/kvm.h |  3 ++
 3 files changed, 79 insertions(+)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index b8ae25cb227b..ef29ef7617bf 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -4926,6 +4926,53 @@ long kvm_arch_vm_ioctl(struct file *filp,
 		if (copy_from_user(&hvevfd, argp, sizeof(hvevfd)))
 			goto out;
 		r = kvm_vm_ioctl_hv_eventfd(kvm, &hvevfd);
+	}
+	case KVM_SUBPAGES_GET_ACCESS: {
+		struct kvm_subpage spp_info;
+
+		if (!kvm->arch.spp_active) {
+			r = -ENODEV;
+			goto out;
+		}
+
+		r = -EFAULT;
+		if (copy_from_user(&spp_info, argp, sizeof(spp_info)))
+			goto out;
+
+		r = -EINVAL;
+		if (spp_info.npages == 0 ||
+		    spp_info.npages > SUBPAGE_MAX_BITMAP)
+			goto out;
+
+		r = kvm_vm_ioctl_get_subpages(kvm, &spp_info);
+		if (copy_to_user(argp, &spp_info, sizeof(spp_info))) {
+			r = -EFAULT;
+			goto out;
+		}
+		break;
+	}
+	case KVM_SUBPAGES_SET_ACCESS: {
+		struct kvm_subpage spp_info;
+
+		if (!kvm->arch.spp_active) {
+			r = -ENODEV;
+			goto out;
+		}
+
+		r = -EFAULT;
+		if (copy_from_user(&spp_info, argp, sizeof(spp_info)))
+			goto out;
+
+		r = -EINVAL;
+		if (spp_info.npages == 0 ||
+		    spp_info.npages > SUBPAGE_MAX_BITMAP)
+			goto out;
+
+		r = kvm_vm_ioctl_set_subpages(kvm, &spp_info);
+		break;
+	}
+	case KVM_INIT_SPP: {
+		r = kvm_vm_ioctl_init_spp(kvm);
 		break;
 	}
 	default:
@@ -9906,6 +9953,32 @@ bool kvm_arch_has_irq_bypass(void)
 	return kvm_x86_ops->update_pi_irte != NULL;
 }
 
+int kvm_arch_get_subpages(struct kvm *kvm,
+			  struct kvm_subpage *spp_info)
+{
+	if (!kvm_x86_ops->get_subpages)
+		return -EINVAL;
+
+	return kvm_x86_ops->get_subpages(kvm, spp_info);
+}
+
+int kvm_arch_set_subpages(struct kvm *kvm,
+			  struct kvm_subpage *spp_info)
+{
+	if (!kvm_x86_ops->set_subpages)
+		return -EINVAL;
+
+	return kvm_x86_ops->set_subpages(kvm, spp_info);
+}
+
+int kvm_arch_init_spp(struct kvm *kvm)
+{
+	if (!kvm_x86_ops->init_spp)
+		return -EINVAL;
+
+	return kvm_x86_ops->init_spp(kvm);
+}
+
 int kvm_arch_irq_bypass_add_producer(struct irq_bypass_consumer *cons,
 				      struct irq_bypass_producer *prod)
 {
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 0b9a0f546397..ae4106aae16e 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -837,6 +837,9 @@ struct kvm_mmu_page *kvm_mmu_get_spp_page(struct kvm_vcpu *vcpu,
 int kvm_get_subpages(struct kvm *kvm, struct kvm_subpage *spp_info);
 int kvm_set_subpages(struct kvm *kvm, struct kvm_subpage *spp_info);
 int kvm_init_spp(struct kvm *kvm);
+int kvm_arch_get_subpages(struct kvm *kvm, struct kvm_subpage *spp_info);
+int kvm_arch_set_subpages(struct kvm *kvm, struct kvm_subpage *spp_info);
+int kvm_arch_init_spp(struct kvm *kvm);
 
 #ifndef __KVM_HAVE_ARCH_VM_ALLOC
 /*
diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
index ad8f2a3ca72d..86dd57e67539 100644
--- a/include/uapi/linux/kvm.h
+++ b/include/uapi/linux/kvm.h
@@ -1248,6 +1248,9 @@ struct kvm_vfio_spapr_tce {
 					struct kvm_userspace_memory_region)
 #define KVM_SET_TSS_ADDR          _IO(KVMIO,   0x47)
 #define KVM_SET_IDENTITY_MAP_ADDR _IOW(KVMIO,  0x48, __u64)
+#define KVM_SUBPAGES_GET_ACCESS   _IOR(KVMIO,  0x49, __u64)
+#define KVM_SUBPAGES_SET_ACCESS   _IOW(KVMIO,  0x4a, __u64)
+#define KVM_INIT_SPP              _IOW(KVMIO,  0x4b, __u64)
 
 /* enable ucontrol for s390 */
 struct kvm_s390_ucas_mapping {

