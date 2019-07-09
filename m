Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2F99C73C53
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:39:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66E162082A
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:39:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66E162082A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0188A8E0059; Tue,  9 Jul 2019 15:39:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0CD08E0032; Tue,  9 Jul 2019 15:39:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAC3F8E0059; Tue,  9 Jul 2019 15:39:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A220F8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 15:39:51 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d3so13285177pgc.9
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 12:39:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:organization
         :reply-to:mail-reply-to:in-reply-to:references:user-agent:message-id;
        bh=To0NjXsfNHceO+XAMOoVCeQE36cNhkRzdZkjYWdf0eA=;
        b=V/wOTLXEjzP4iJ0oLD2ZlkxPNkTE5iVy9oklgHMmgm8ugeSV9B6CFiOtyyGpxyRclf
         hoeF8RP6FZTbJh1TD9/ig84/+j6qHSwQ63lxz3qVlGi48ST0TKQHs6V44t9iMomSQuhC
         AqPugXu2/Xvk9bPjZd+VWuQvr/WSj/FQLKxxCBiW3HaQWyobVjiPQopGjMuky/oH5GOa
         5Haas8g55l9Fr8ffs5T3UF/PphwNbbAR7vI0wbmsAwzLBOMw+chh5LGsG+rDZlixCTPf
         J4HQKOp8Ce/OEJX/1AhoIUDTIw0fim+KMLpYcwcwtEfU8oSAKlNDbp542zQKztax+XXi
         838w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVh3wxu5rG0CJ0G1Xw1AWpes+lRE29jIwAyRJzcU80Qmp3UWh+O
	8vJy+iJM7GRS3BuAKQ74+44g/ux4vSMomzcmX5311IbsWyTBrl4+5HjiqrAlTk6azlFTHmqvU87
	BQhwGLN+/k/eGqak3URpyMkYaQ9y27hvgD+T60FA2O5rHqDiOn9P2av3MHnvys4lvsg==
X-Received: by 2002:a17:90a:17ab:: with SMTP id q40mr2014028pja.106.1562701191237;
        Tue, 09 Jul 2019 12:39:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOsAjZAtxBoDRa5gqaG4ZyJUyJ3cKVL/nTkaXD9af6GfL499SJc26ydu2IBYKzB+/iKLXP
X-Received: by 2002:a17:90a:17ab:: with SMTP id q40mr2013983pja.106.1562701190457;
        Tue, 09 Jul 2019 12:39:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562701190; cv=none;
        d=google.com; s=arc-20160816;
        b=Fmk0Al8AcNdCLeEezUm9dBmyTugzJwtEs7pXrah9YO5TdLb4gdtJXdA7jDLvpuXHAD
         zi+7/heTkHtSMHKOxWpdvIS5P2abppwXk+wBj/O2aRbx0BpRPS+fegzdEPrz0ZHULVVG
         SCcJfS6o2YjFWMyd3QEu56+hyshKZY1QO20Z5FnlXzi95dfKW0AC5PeAlCdMUk5niUKT
         U23Yd/tvf/mw0hZ4dWF2uht0QwRMRwrhRvNqULetpuighxLv+TVFW5Nj7Gwd5g0Ka/Xu
         OLXVXhOjruVyWmpkLzGSKayMjYIKPpmXHAqfOtJu9VERVtEtx+t607+tDlySiTpQFPOB
         JuaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:references:in-reply-to:mail-reply-to:reply-to
         :organization:subject:cc:to:from:date:content-transfer-encoding
         :mime-version;
        bh=To0NjXsfNHceO+XAMOoVCeQE36cNhkRzdZkjYWdf0eA=;
        b=aOGmUSo918QpUbJWXiLYabusZGS20B9RWqrIPqo3y9htZh6OQzeerYova5AlnqqelF
         P5x0mTt5KvPG3kb4EfvkHGBmDA3IH2a6bwT4qiWVr6WMEMKBW5YEFSUG2jHHbAhT/kBL
         9Vn+56aBbS4qBC6YKSLHNESkiHdwaGYeQ5yi2ilyckpLsuC1MMfmlIqg3JGOpUE2Bbqz
         UQkzW8uNfL6TQUS9dp2toX1TiOE5Gl97durwBwL1IY04U3t9L5G7a8MU6lk2coQC9SES
         27xLfYEcvZYYjAyGT9WM/M4WO1gQNacR0j8oBKttacgC3TlmGcMS4fwDsLyYT/EKLLtT
         ITHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q187si22071904pga.220.2019.07.09.12.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 12:39:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69JdJbA036359
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 15:39:49 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tmxrmp5md-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 15:39:49 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <janani@linux.ibm.com>;
	Tue, 9 Jul 2019 20:39:48 +0100
Received: from b01cxnp23033.gho.pok.ibm.com (9.57.198.28)
	by e14.ny.us.ibm.com (146.89.104.201) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 20:39:45 +0100
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69JditA36503966
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 19:39:44 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4AEB9AC05B;
	Tue,  9 Jul 2019 19:39:44 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 31575AC059;
	Tue,  9 Jul 2019 19:39:43 +0000 (GMT)
Received: from ltc.linux.ibm.com (unknown [9.16.170.189])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  9 Jul 2019 19:39:43 +0000 (GMT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 09 Jul 2019 14:42:10 -0500
From: janani <janani@linux.ibm.com>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linuxram@us.ibm.com, cclaudio@linux.ibm.com,
        kvm-ppc@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com,
        aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com,
        sukadev@linux.vnet.ibm.com,
        Linuxppc-dev
 <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>
Subject: Re: [PATCH v5 3/7] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Organization: IBM
Reply-To: janani@linux.ibm.com
Mail-Reply-To: janani@linux.ibm.com
In-Reply-To: <20190709102545.9187-4-bharata@linux.ibm.com>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-4-bharata@linux.ibm.com>
X-Sender: janani@linux.ibm.com
User-Agent: Roundcube Webmail/1.0.1
X-TM-AS-GCONF: 00
x-cbid: 19070919-0052-0000-0000-000003DC5A21
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011401; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01229823; UDB=6.00647719; IPR=6.01011082;
 MB=3.00027657; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-09 19:39:47
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070919-0053-0000-0000-000061A06A38
Message-Id: <03532ade57f5d556246b1583f6f1d3f7@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090232
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-09 05:25, Bharata B Rao wrote:
> H_SVM_INIT_START: Initiate securing a VM
> H_SVM_INIT_DONE: Conclude securing a VM
> 
> As part of H_SVM_INIT_START, register all existing memslots with
> the UV. H_SVM_INIT_DONE call by UV informs HV that transition of
> the guest to secure mode is complete.
> 
> These two states (transition to secure mode STARTED and transition
> to secure mode COMPLETED) are recorded in kvm->arch.secure_guest.
> Setting these states will cause the assembly code that enters the
> guest to call the UV_RETURN ucall instead of trying to enter the
> guest directly.
> 
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> Acked-by: Paul Mackerras <paulus@ozlabs.org>
  Reviewed-by: Janani Janakiraman <janani@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/hvcall.h         |  2 ++
>  arch/powerpc/include/asm/kvm_book3s_hmm.h | 12 ++++++++
>  arch/powerpc/include/asm/kvm_host.h       |  4 +++
>  arch/powerpc/include/asm/ultravisor-api.h |  1 +
>  arch/powerpc/include/asm/ultravisor.h     |  9 ++++++
>  arch/powerpc/kvm/book3s_hv.c              |  7 +++++
>  arch/powerpc/kvm/book3s_hv_hmm.c          | 34 +++++++++++++++++++++++
>  7 files changed, 69 insertions(+)
> 
> diff --git a/arch/powerpc/include/asm/hvcall.h
> b/arch/powerpc/include/asm/hvcall.h
> index 05b8536f6653..fa7695928e30 100644
> --- a/arch/powerpc/include/asm/hvcall.h
> +++ b/arch/powerpc/include/asm/hvcall.h
> @@ -343,6 +343,8 @@
>  /* Platform-specific hcalls used by the Ultravisor */
>  #define H_SVM_PAGE_IN		0xEF00
>  #define H_SVM_PAGE_OUT		0xEF04
> +#define H_SVM_INIT_START	0xEF08
> +#define H_SVM_INIT_DONE		0xEF0C
> 
>  /* Values for 2nd argument to H_SET_MODE */
>  #define H_SET_MODE_RESOURCE_SET_CIABR		1
> diff --git a/arch/powerpc/include/asm/kvm_book3s_hmm.h
> b/arch/powerpc/include/asm/kvm_book3s_hmm.h
> index 21f3de5f2acb..8c7aacabb2e0 100644
> --- a/arch/powerpc/include/asm/kvm_book3s_hmm.h
> +++ b/arch/powerpc/include/asm/kvm_book3s_hmm.h
> @@ -11,6 +11,8 @@ extern unsigned long kvmppc_h_svm_page_out(struct kvm 
> *kvm,
>  					  unsigned long gra,
>  					  unsigned long flags,
>  					  unsigned long page_shift);
> +extern unsigned long kvmppc_h_svm_init_start(struct kvm *kvm);
> +extern unsigned long kvmppc_h_svm_init_done(struct kvm *kvm);
>  #else
>  static inline unsigned long
>  kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gra,
> @@ -25,5 +27,15 @@ kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long 
> gra,
>  {
>  	return H_UNSUPPORTED;
>  }
> +
> +static inline unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
> +{
> +	return H_UNSUPPORTED;
> +}
> +
> +static inline unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
> +{
> +	return H_UNSUPPORTED;
> +}
>  #endif /* CONFIG_PPC_UV */
>  #endif /* __POWERPC_KVM_PPC_HMM_H__ */
> diff --git a/arch/powerpc/include/asm/kvm_host.h
> b/arch/powerpc/include/asm/kvm_host.h
> index ac1a101beb07..0c49c3401c63 100644
> --- a/arch/powerpc/include/asm/kvm_host.h
> +++ b/arch/powerpc/include/asm/kvm_host.h
> @@ -272,6 +272,10 @@ struct kvm_hpt_info {
> 
>  struct kvm_resize_hpt;
> 
> +/* Flag values for kvm_arch.secure_guest */
> +#define KVMPPC_SECURE_INIT_START	0x1 /* H_SVM_INIT_START has been 
> called */
> +#define KVMPPC_SECURE_INIT_DONE		0x2 /* H_SVM_INIT_DONE completed */
> +
>  struct kvm_arch {
>  	unsigned int lpid;
>  	unsigned int smt_mode;		/* # vcpus per virtual core */
> diff --git a/arch/powerpc/include/asm/ultravisor-api.h
> b/arch/powerpc/include/asm/ultravisor-api.h
> index f1c5800ac705..07b7d638e7af 100644
> --- a/arch/powerpc/include/asm/ultravisor-api.h
> +++ b/arch/powerpc/include/asm/ultravisor-api.h
> @@ -20,6 +20,7 @@
>  /* opcodes */
>  #define UV_WRITE_PATE			0xF104
>  #define UV_RETURN			0xF11C
> +#define UV_REGISTER_MEM_SLOT		0xF120
>  #define UV_PAGE_IN			0xF128
>  #define UV_PAGE_OUT			0xF12C
> 
> diff --git a/arch/powerpc/include/asm/ultravisor.h
> b/arch/powerpc/include/asm/ultravisor.h
> index 16f8e0e8ec3f..b46042f1aa8f 100644
> --- a/arch/powerpc/include/asm/ultravisor.h
> +++ b/arch/powerpc/include/asm/ultravisor.h
> @@ -61,6 +61,15 @@ static inline int uv_page_out(u64 lpid, u64 dst_ra,
> u64 src_gpa, u64 flags,
>  	return ucall(UV_PAGE_OUT, retbuf, lpid, dst_ra, src_gpa, flags,
>  		     page_shift);
>  }
> +
> +static inline int uv_register_mem_slot(u64 lpid, u64 start_gpa, u64 
> size,
> +				       u64 flags, u64 slotid)
> +{
> +	unsigned long retbuf[UCALL_BUFSIZE];
> +
> +	return ucall(UV_REGISTER_MEM_SLOT, retbuf, lpid, start_gpa,
> +		     size, flags, slotid);
> +}
>  #endif /* !__ASSEMBLY__ */
> 
>  #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
> diff --git a/arch/powerpc/kvm/book3s_hv.c 
> b/arch/powerpc/kvm/book3s_hv.c
> index 8ee66aa0da58..b8f801d00ad4 100644
> --- a/arch/powerpc/kvm/book3s_hv.c
> +++ b/arch/powerpc/kvm/book3s_hv.c
> @@ -1097,6 +1097,13 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu 
> *vcpu)
>  					    kvmppc_get_gpr(vcpu, 5),
>  					    kvmppc_get_gpr(vcpu, 6));
>  		break;
> +	case H_SVM_INIT_START:
> +		ret = kvmppc_h_svm_init_start(vcpu->kvm);
> +		break;
> +	case H_SVM_INIT_DONE:
> +		ret = kvmppc_h_svm_init_done(vcpu->kvm);
> +		break;
> +
>  	default:
>  		return RESUME_HOST;
>  	}
> diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c 
> b/arch/powerpc/kvm/book3s_hv_hmm.c
> index 36562b382e70..55bab9c4e60a 100644
> --- a/arch/powerpc/kvm/book3s_hv_hmm.c
> +++ b/arch/powerpc/kvm/book3s_hv_hmm.c
> @@ -62,6 +62,40 @@ struct kvmppc_hmm_migrate_args {
>  	unsigned long page_shift;
>  };
> 
> +unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
> +{
> +	struct kvm_memslots *slots;
> +	struct kvm_memory_slot *memslot;
> +	int ret = H_SUCCESS;
> +	int srcu_idx;
> +
> +	srcu_idx = srcu_read_lock(&kvm->srcu);
> +	slots = kvm_memslots(kvm);
> +	kvm_for_each_memslot(memslot, slots) {
> +		ret = uv_register_mem_slot(kvm->arch.lpid,
> +					   memslot->base_gfn << PAGE_SHIFT,
> +					   memslot->npages * PAGE_SIZE,
> +					   0, memslot->id);
> +		if (ret < 0) {
> +			ret = H_PARAMETER;
> +			goto out;
> +		}
> +	}
> +	kvm->arch.secure_guest |= KVMPPC_SECURE_INIT_START;
> +out:
> +	srcu_read_unlock(&kvm->srcu, srcu_idx);
> +	return ret;
> +}
> +
> +unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
> +{
> +	if (!(kvm->arch.secure_guest & KVMPPC_SECURE_INIT_START))
> +		return H_UNSUPPORTED;
> +
> +	kvm->arch.secure_guest |= KVMPPC_SECURE_INIT_DONE;
> +	return H_SUCCESS;
> +}
> +
>  /*
>   * Bits 60:56 in the rmap entry will be used to identify the
>   * different uses/functions of rmap. This definition with move

