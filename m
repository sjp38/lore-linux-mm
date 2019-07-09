Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17446C73C5A
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:51:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C80AB208C4
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:51:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C80AB208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51A058E005B; Tue,  9 Jul 2019 15:51:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C99B8E0032; Tue,  9 Jul 2019 15:51:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 343B18E005B; Tue,  9 Jul 2019 15:51:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE40A8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 15:51:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so11232879pla.18
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 12:51:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:organization
         :reply-to:mail-reply-to:in-reply-to:references:message-id:user-agent;
        bh=/XRAbmPSP/Eeq9PHJ7ICRrNSfFlGcXiv6CHzSk8BsFk=;
        b=kP+/2TDI7V6tBM4F5QBZD4dPcotHy85zvhBninDBBfsf7Ru6xOcYfS+j/Vhmm3Dc9/
         U+jfuKDKLYj8kVJO1LJz3HgrPkiuK5wzRuNlIFqzLHtH7jursbmBlcDcWNM7By/wembM
         PuLS4pHV1uj2XuXKVPpSQ5V+O/1lIxaMxyRUb/4soe7NykX48bz8gzBqH49d6AMlXddS
         lM0WM5gvDA55vdkSIDdzp3/OchqXBEqh1A1TPNP7vJMiCxaOfJ998nbiKNwDQ77TcRUv
         MxAbm/Lqzrcenqq1eY3kvxoDEjk4iCw4RJXMrFKfEuaKEj2rIqmlbPsoouurNpP/Mp4W
         G4vQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXctzdI4KTg7BIKs2Zqw/+wWFa6/dWxYY1tLRzQj8638Of6i+zQ
	rGvJuRmpRhdvPFr+shPAC5q63IePeP4goh9SFuCa1oMYwJJdPZ+VCHaEPmtutUwvk54JWRklSGf
	r3BqLryyt1PQOgppJyNrgDbwwzRWfGaG+SE6E+e4h9IAoRihO7LMDrY4tNgEs+c3jxg==
X-Received: by 2002:a17:90a:29c5:: with SMTP id h63mr1869521pjd.83.1562701883595;
        Tue, 09 Jul 2019 12:51:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHENZFHV13dIHiwmWBj8eg7TpwPycTCCwZq9hSuBhSIB6XHq7zqKEuA+A4eQyVv32cUiPr
X-Received: by 2002:a17:90a:29c5:: with SMTP id h63mr1869478pjd.83.1562701882847;
        Tue, 09 Jul 2019 12:51:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562701882; cv=none;
        d=google.com; s=arc-20160816;
        b=KjlfVbH0iNzwKb4uCthJ7bg3kOpWgKuCzDRsHPSTrv9U5BvAu3SC6k4BDD8nuei8zt
         hOzCaGJD8vHpENDvXksMUrWYGECA9Zx67vdA97v0sNr1GKu8wV3VEMZMmt9f5suQ3LGA
         jiO4Rg1YXvvReBzbKPmGqys4jBJxQkdV0yHnDRTvK8ZNTvKL0dY9KZvdb2dCd4r1UWoU
         H+3JnBS9zo2gBqPnnBKmAuZtXK+v+q6vfiNWa/AvKGnnnx9rs+2Lc14JOwKy1qSR/8/y
         krnJeJRkNMpRZV0BioIPvl7P9VUh2OXvo3B65LuKUhrcfPhAPGB62gEz4gWtSZLFV/QG
         MArg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:mail-reply-to:reply-to
         :organization:subject:cc:to:from:date:content-transfer-encoding
         :mime-version;
        bh=/XRAbmPSP/Eeq9PHJ7ICRrNSfFlGcXiv6CHzSk8BsFk=;
        b=W0nFZyCPktV/vVcMoGdB7lvXZgF9+5b6IOL1addE5oNk1P2n/DZ0sERf+7PKXfmojH
         RJZlmkGdAiu0W7YDRQTR6TUb4AW9JAmfCTdyhH8t8ZfDqERQCp9FSAh/7GISTYfT5FSP
         SnWiJWNEdCKdE+vbRCzB806wYGhyy2alphk90Z8GNk7LX7VK4TkDVe7TY7fPWHWnZKLI
         r7YS+akRUI6XmNjOqchmsbgKTSTuWw0j7ENqhOKnMWLj1PowBZfPlMWmKYhZaKfwP5lM
         xinfftc1p0OVinxla/H6qcRgoP4WsAnU2NVfqeTkr2QYhhprXoXiLj8u+6Os93Sa4cpi
         9crQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d16si1775919pfn.248.2019.07.09.12.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 12:51:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69JlKIC126474;
	Tue, 9 Jul 2019 15:51:22 -0400
Received: from ppma03dal.us.ibm.com (b.bd.3ea9.ip4.static.sl-reverse.com [169.62.189.11])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tn0mjj18t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 09 Jul 2019 15:51:22 -0400
Received: from pps.filterd (ppma03dal.us.ibm.com [127.0.0.1])
	by ppma03dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x69JnVJl002826;
	Tue, 9 Jul 2019 19:51:21 GMT
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by ppma03dal.us.ibm.com with ESMTP id 2tjk96qar8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 09 Jul 2019 19:51:21 +0000
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69JpJ8Z57737560
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 19:51:19 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 53FB06A04F;
	Tue,  9 Jul 2019 19:51:19 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E941B6A054;
	Tue,  9 Jul 2019 19:51:18 +0000 (GMT)
Received: from ltc.linux.ibm.com (unknown [9.16.170.189])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue,  9 Jul 2019 19:51:18 +0000 (GMT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 09 Jul 2019 14:53:47 -0500
From: janani <janani@linux.ibm.com>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linuxram@us.ibm.com, cclaudio@linux.ibm.com,
        kvm-ppc@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com,
        aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com,
        sukadev@linux.vnet.ibm.com,
        Linuxppc-dev
 <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>
Subject: Re: [RFC PATCH v5 5/7] kvmppc: Radix changes for secure guest
Organization: IBM
Reply-To: janani@linux.ibm.com
Mail-Reply-To: janani@linux.ibm.com
In-Reply-To: <20190709102545.9187-6-bharata@linux.ibm.com>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-6-bharata@linux.ibm.com>
Message-ID: <5c7231766bc1f78e3cc1a467186e3356@linux.vnet.ibm.com>
X-Sender: janani@linux.ibm.com
User-Agent: Roundcube Webmail/1.0.1
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090235
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-09 05:25, Bharata B Rao wrote:
> - After the guest becomes secure, when we handle a page fault of a page
>   belonging to SVM in HV, send that page to UV via UV_PAGE_IN.
> - Whenever a page is unmapped on the HV side, inform UV via 
> UV_PAGE_INVAL.
> - Ensure all those routines that walk the secondary page tables of
>   the guest don't do so in case of secure VM. For secure guest, the
>   active secondary page tables are in secure memory and the secondary
>   page tables in HV are freed when guest becomes secure.
> 
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
  Reviewed-by: Janani Janakiraman <janani@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/kvm_host.h       | 12 ++++++++++++
>  arch/powerpc/include/asm/ultravisor-api.h |  1 +
>  arch/powerpc/include/asm/ultravisor.h     |  7 +++++++
>  arch/powerpc/kvm/book3s_64_mmu_radix.c    | 22 ++++++++++++++++++++++
>  arch/powerpc/kvm/book3s_hv_hmm.c          | 20 ++++++++++++++++++++
>  5 files changed, 62 insertions(+)
> 
> diff --git a/arch/powerpc/include/asm/kvm_host.h
> b/arch/powerpc/include/asm/kvm_host.h
> index 0c49c3401c63..dcbf7480cb10 100644
> --- a/arch/powerpc/include/asm/kvm_host.h
> +++ b/arch/powerpc/include/asm/kvm_host.h
> @@ -865,6 +865,8 @@ static inline void
> kvm_arch_vcpu_block_finish(struct kvm_vcpu *vcpu) {}
>  #ifdef CONFIG_PPC_UV
>  extern int kvmppc_hmm_init(void);
>  extern void kvmppc_hmm_free(void);
> +extern bool kvmppc_is_guest_secure(struct kvm *kvm);
> +extern int kvmppc_send_page_to_uv(struct kvm *kvm, unsigned long gpa);
>  #else
>  static inline int kvmppc_hmm_init(void)
>  {
> @@ -872,6 +874,16 @@ static inline int kvmppc_hmm_init(void)
>  }
> 
>  static inline void kvmppc_hmm_free(void) {}
> +
> +static inline bool kvmppc_is_guest_secure(struct kvm *kvm)
> +{
> +	return false;
> +}
> +
> +static inline int kvmppc_send_page_to_uv(struct kvm *kvm, unsigned 
> long gpa)
> +{
> +	return -EFAULT;
> +}
>  #endif /* CONFIG_PPC_UV */
> 
>  #endif /* __POWERPC_KVM_HOST_H__ */
> diff --git a/arch/powerpc/include/asm/ultravisor-api.h
> b/arch/powerpc/include/asm/ultravisor-api.h
> index d6d6eb2e6e6b..9f5510b55892 100644
> --- a/arch/powerpc/include/asm/ultravisor-api.h
> +++ b/arch/powerpc/include/asm/ultravisor-api.h
> @@ -24,5 +24,6 @@
>  #define UV_UNREGISTER_MEM_SLOT		0xF124
>  #define UV_PAGE_IN			0xF128
>  #define UV_PAGE_OUT			0xF12C
> +#define UV_PAGE_INVAL			0xF138
> 
>  #endif /* _ASM_POWERPC_ULTRAVISOR_API_H */
> diff --git a/arch/powerpc/include/asm/ultravisor.h
> b/arch/powerpc/include/asm/ultravisor.h
> index fe45be9ee63b..f4f674794b35 100644
> --- a/arch/powerpc/include/asm/ultravisor.h
> +++ b/arch/powerpc/include/asm/ultravisor.h
> @@ -77,6 +77,13 @@ static inline int uv_unregister_mem_slot(u64 lpid,
> u64 slotid)
> 
>  	return ucall(UV_UNREGISTER_MEM_SLOT, retbuf, lpid, slotid);
>  }
> +
> +static inline int uv_page_inval(u64 lpid, u64 gpa, u64 page_shift)
> +{
> +	unsigned long retbuf[UCALL_BUFSIZE];
> +
> +	return ucall(UV_PAGE_INVAL, retbuf, lpid, gpa, page_shift);
> +}
>  #endif /* !__ASSEMBLY__ */
> 
>  #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
> diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c
> b/arch/powerpc/kvm/book3s_64_mmu_radix.c
> index f55ef071883f..c454600c454f 100644
> --- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
> +++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
> @@ -21,6 +21,8 @@
>  #include <asm/pgtable.h>
>  #include <asm/pgalloc.h>
>  #include <asm/pte-walk.h>
> +#include <asm/ultravisor.h>
> +#include <asm/kvm_host.h>
> 
>  /*
>   * Supported radix tree geometry.
> @@ -923,6 +925,9 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run
> *run, struct kvm_vcpu *vcpu,
>  	if (!(dsisr & DSISR_PRTABLE_FAULT))
>  		gpa |= ea & 0xfff;
> 
> +	if (kvmppc_is_guest_secure(kvm))
> +		return kvmppc_send_page_to_uv(kvm, gpa & PAGE_MASK);
> +
>  	/* Get the corresponding memslot */
>  	memslot = gfn_to_memslot(kvm, gfn);
> 
> @@ -980,6 +985,11 @@ int kvm_unmap_radix(struct kvm *kvm, struct
> kvm_memory_slot *memslot,
>  	unsigned long gpa = gfn << PAGE_SHIFT;
>  	unsigned int shift;
> 
> +	if (kvmppc_is_guest_secure(kvm)) {
> +		uv_page_inval(kvm->arch.lpid, gpa, PAGE_SIZE);
> +		return 0;
> +	}
> +
>  	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
>  	if (ptep && pte_present(*ptep))
>  		kvmppc_unmap_pte(kvm, ptep, gpa, shift, memslot,
> @@ -997,6 +1007,9 @@ int kvm_age_radix(struct kvm *kvm, struct
> kvm_memory_slot *memslot,
>  	int ref = 0;
>  	unsigned long old, *rmapp;
> 
> +	if (kvmppc_is_guest_secure(kvm))
> +		return ref;
> +
>  	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
>  	if (ptep && pte_present(*ptep) && pte_young(*ptep)) {
>  		old = kvmppc_radix_update_pte(kvm, ptep, _PAGE_ACCESSED, 0,
> @@ -1021,6 +1034,9 @@ int kvm_test_age_radix(struct kvm *kvm, struct
> kvm_memory_slot *memslot,
>  	unsigned int shift;
>  	int ref = 0;
> 
> +	if (kvmppc_is_guest_secure(kvm))
> +		return ref;
> +
>  	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
>  	if (ptep && pte_present(*ptep) && pte_young(*ptep))
>  		ref = 1;
> @@ -1038,6 +1054,9 @@ static int kvm_radix_test_clear_dirty(struct kvm 
> *kvm,
>  	int ret = 0;
>  	unsigned long old, *rmapp;
> 
> +	if (kvmppc_is_guest_secure(kvm))
> +		return ret;
> +
>  	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
>  	if (ptep && pte_present(*ptep) && pte_dirty(*ptep)) {
>  		ret = 1;
> @@ -1090,6 +1109,9 @@ void kvmppc_radix_flush_memslot(struct kvm *kvm,
>  	unsigned long gpa;
>  	unsigned int shift;
> 
> +	if (kvmppc_is_guest_secure(kvm))
> +		return;
> +
>  	gpa = memslot->base_gfn << PAGE_SHIFT;
>  	spin_lock(&kvm->mmu_lock);
>  	for (n = memslot->npages; n; --n) {
> diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c 
> b/arch/powerpc/kvm/book3s_hv_hmm.c
> index 55bab9c4e60a..9e6c88de456f 100644
> --- a/arch/powerpc/kvm/book3s_hv_hmm.c
> +++ b/arch/powerpc/kvm/book3s_hv_hmm.c
> @@ -62,6 +62,11 @@ struct kvmppc_hmm_migrate_args {
>  	unsigned long page_shift;
>  };
> 
> +bool kvmppc_is_guest_secure(struct kvm *kvm)
> +{
> +	return !!(kvm->arch.secure_guest & KVMPPC_SECURE_INIT_DONE);
> +}
> +
>  unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
>  {
>  	struct kvm_memslots *slots;
> @@ -494,6 +499,21 @@ kvmppc_h_svm_page_out(struct kvm *kvm, unsigned 
> long gpa,
>  	return ret;
>  }
> 
> +int kvmppc_send_page_to_uv(struct kvm *kvm, unsigned long gpa)
> +{
> +	unsigned long pfn;
> +	int ret;
> +
> +	pfn = gfn_to_pfn(kvm, gpa >> PAGE_SHIFT);
> +	if (is_error_noslot_pfn(pfn))
> +		return -EFAULT;
> +
> +	ret = uv_page_in(kvm->arch.lpid, pfn << PAGE_SHIFT, gpa, 0, 
> PAGE_SHIFT);
> +	kvm_release_pfn_clean(pfn);
> +
> +	return (ret == U_SUCCESS) ? RESUME_GUEST : -EFAULT;
> +}
> +
>  static u64 kvmppc_get_secmem_size(void)
>  {
>  	struct device_node *np;

