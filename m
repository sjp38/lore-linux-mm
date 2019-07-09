Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07FA1C73C56
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:41:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C53812082A
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:41:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C53812082A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B0A88E005A; Tue,  9 Jul 2019 15:41:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 239758E0032; Tue,  9 Jul 2019 15:41:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B3CB8E005A; Tue,  9 Jul 2019 15:41:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4AB48E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 15:41:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r142so12998860pfc.2
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 12:41:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:organization
         :reply-to:mail-reply-to:in-reply-to:references:user-agent:message-id;
        bh=QeNokUFy+zTJ4UUuOi4n8XlyCmSZCr1DK7stz0ZeJv4=;
        b=qidRLaxFAK0+ZJPhCbaSKvUdUVxqPDQAuRlM5QwqFDv6teuEX08WND2byg1qZbU4ph
         TqUsmhnOfxVZEkN5SQU4f7qOnBxhmc3fzjeMqj9n+IbsyK1k8UyPWSqztDrECmzD+HiP
         6SNN+Xl8ZPJ0oF12UV+r6+L8bUgdLeeg8jyQyKYgS77JkKoxDbrqa5xdqh/iPKIYzJto
         EL9eWi2h1VIxcS9JsxJkgiDUM0xp7zXC6+J7ASclewAbqAdic9zZXpGrQ8U1V4i97haq
         x9Nlxju8ZhdibYLDl4tl19lRYkiR5i8riYRhKl9sIqFgRcxSFI0alD3H6lO2DFvmqLvP
         ZGNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWxBwYz/ToZ/TtlgnVmJwjjC2zbfAF9H58EUp/Rd/G5SJBLcGDP
	hqbai0tvUJGjQTQnP5iRL9nMehxY6pm7j/tK0BQUgk2hOYKPuzioH+LTPhJ+gEnHXjnoxdpP3dU
	Jgnk/QGYPH6EeuNh8EnvXyFo0XA89YaD4XRSm59nTvVoEUA7uAk1829ijgh4hjr7J8g==
X-Received: by 2002:a17:902:d81:: with SMTP id 1mr35328665plv.323.1562701287495;
        Tue, 09 Jul 2019 12:41:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCEE0en6OQ/R4RBaBSmcqmkBIV10wFxasvSVvW3B3BFs1Ysu9gtrZZQqOlnMVwuPCNt2nZ
X-Received: by 2002:a17:902:d81:: with SMTP id 1mr35328634plv.323.1562701286911;
        Tue, 09 Jul 2019 12:41:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562701286; cv=none;
        d=google.com; s=arc-20160816;
        b=duLFBwQ+EDzwVD/90AFoSQ0ELyUb6CazYeNXgmfeul+/w+4hGJm5rB2wKhVnA+YEJI
         RuvGSwTw9RCi/pUnhugd8gNiLdCOK5KYqtzSQFUc7DR4sCe36nRq5A0eZ+WdMgsE8Ubm
         WbEhdjyPtVRIkX6cGT5y3R8HDSkZ0ybnxYzNmSCanqZrT1eEK3nlGx42knJU9+wlQbSM
         ajWPecDKLpKi07XDJBlO1OLPO9stTyPxcTn+/W27I/3c3XvBCSmXPZ4FZdQbqQlpGFfB
         W7aABn/Vb68K4PELusWjs7QuGxKhYKTeVB6ZWZZ26reJhEf2B9X7UR0vOsA7c6/lD0cM
         bDZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:references:in-reply-to:mail-reply-to:reply-to
         :organization:subject:cc:to:from:date:content-transfer-encoding
         :mime-version;
        bh=QeNokUFy+zTJ4UUuOi4n8XlyCmSZCr1DK7stz0ZeJv4=;
        b=KQIzUBLPqHlKwjTNGdKTSFcxb37c5N/VoYzYODJhQB4R5AZSTqSAr13AVl/sEe2XUC
         H9+AQ4Owb+xeeGzffkS/KxT1d4niuIRhHoETdR/N64iTK2wprf9GOVOpyZPteuu3QZXy
         wi4RsgCVwifLpu/6x+EaRn96bgsFZoxoWuxSIQ6DOVF58pS7BFslsIQ2V0RsW22MeSjX
         y4qNnGFHIeWSvEEB648WUPeic6mk8sBNLrS+bWba1tV6uMKIELnspn5hTEhRAFgMfgX4
         XxvY6Wn0Qb4NmibFzGs6DkE6lZOfIEGvdwZ8C1oh6s/3QPwIawzrqsVGdzEiIua7BKxr
         eEDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i97si22844405plb.50.2019.07.09.12.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 12:41:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69JdJg4082401
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 15:41:26 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tn05wtqux-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 15:41:26 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <janani@linux.ibm.com>;
	Tue, 9 Jul 2019 20:41:25 +0100
Received: from b03cxnp08025.gho.boulder.ibm.com (9.17.130.17)
	by e31.co.us.ibm.com (192.168.1.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 20:41:21 +0100
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69JfKmc43123054
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 19:41:20 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 18BBBC605B;
	Tue,  9 Jul 2019 19:41:20 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B8560C6055;
	Tue,  9 Jul 2019 19:41:19 +0000 (GMT)
Received: from ltc.linux.ibm.com (unknown [9.16.170.189])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue,  9 Jul 2019 19:41:19 +0000 (GMT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 09 Jul 2019 14:43:47 -0500
From: janani <janani@linux.ibm.com>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linuxram@us.ibm.com, cclaudio@linux.ibm.com,
        kvm-ppc@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com,
        aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com,
        sukadev@linux.vnet.ibm.com,
        Linuxppc-dev
 <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>
Subject: Re: [PATCH v5 4/7] kvmppc: Handle memory plug/unplug to secure VM
Organization: IBM
Reply-To: janani@linux.ibm.com
Mail-Reply-To: janani@linux.ibm.com
In-Reply-To: <20190709102545.9187-5-bharata@linux.ibm.com>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-5-bharata@linux.ibm.com>
X-Sender: janani@linux.ibm.com
User-Agent: Roundcube Webmail/1.0.1
X-TM-AS-GCONF: 00
x-cbid: 19070919-8235-0000-0000-00000EB44E59
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011401; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01229823; UDB=6.00647720; IPR=6.01011082;
 MB=3.00027657; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-09 19:41:23
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070919-8236-0000-0000-000046546CF6
Message-Id: <730f4bbd1be9abae7640ddc7366b0beb@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=978 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090232
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-09 05:25, Bharata B Rao wrote:
> Register the new memslot with UV during plug and unregister
> the memslot during unplug.
> 
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> Acked-by: Paul Mackerras <paulus@ozlabs.org>
  Reviewed-by: Janani Janakiraman <janani@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/ultravisor-api.h |  1 +
>  arch/powerpc/include/asm/ultravisor.h     |  7 +++++++
>  arch/powerpc/kvm/book3s_hv.c              | 19 +++++++++++++++++++
>  3 files changed, 27 insertions(+)
> 
> diff --git a/arch/powerpc/include/asm/ultravisor-api.h
> b/arch/powerpc/include/asm/ultravisor-api.h
> index 07b7d638e7af..d6d6eb2e6e6b 100644
> --- a/arch/powerpc/include/asm/ultravisor-api.h
> +++ b/arch/powerpc/include/asm/ultravisor-api.h
> @@ -21,6 +21,7 @@
>  #define UV_WRITE_PATE			0xF104
>  #define UV_RETURN			0xF11C
>  #define UV_REGISTER_MEM_SLOT		0xF120
> +#define UV_UNREGISTER_MEM_SLOT		0xF124
>  #define UV_PAGE_IN			0xF128
>  #define UV_PAGE_OUT			0xF12C
> 
> diff --git a/arch/powerpc/include/asm/ultravisor.h
> b/arch/powerpc/include/asm/ultravisor.h
> index b46042f1aa8f..fe45be9ee63b 100644
> --- a/arch/powerpc/include/asm/ultravisor.h
> +++ b/arch/powerpc/include/asm/ultravisor.h
> @@ -70,6 +70,13 @@ static inline int uv_register_mem_slot(u64 lpid,
> u64 start_gpa, u64 size,
>  	return ucall(UV_REGISTER_MEM_SLOT, retbuf, lpid, start_gpa,
>  		     size, flags, slotid);
>  }
> +
> +static inline int uv_unregister_mem_slot(u64 lpid, u64 slotid)
> +{
> +	unsigned long retbuf[UCALL_BUFSIZE];
> +
> +	return ucall(UV_UNREGISTER_MEM_SLOT, retbuf, lpid, slotid);
> +}
>  #endif /* !__ASSEMBLY__ */
> 
>  #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
> diff --git a/arch/powerpc/kvm/book3s_hv.c 
> b/arch/powerpc/kvm/book3s_hv.c
> index b8f801d00ad4..7cbb5edaed01 100644
> --- a/arch/powerpc/kvm/book3s_hv.c
> +++ b/arch/powerpc/kvm/book3s_hv.c
> @@ -77,6 +77,7 @@
>  #include <asm/hw_breakpoint.h>
>  #include <asm/kvm_host.h>
>  #include <asm/kvm_book3s_hmm.h>
> +#include <asm/ultravisor.h>
> 
>  #include "book3s.h"
> 
> @@ -4504,6 +4505,24 @@ static void
> kvmppc_core_commit_memory_region_hv(struct kvm *kvm,
>  	if (change == KVM_MR_FLAGS_ONLY && kvm_is_radix(kvm) &&
>  	    ((new->flags ^ old->flags) & KVM_MEM_LOG_DIRTY_PAGES))
>  		kvmppc_radix_flush_memslot(kvm, old);
> +	/*
> +	 * If UV hasn't yet called H_SVM_INIT_START, don't register memslots.
> +	 */
> +	if (!kvm->arch.secure_guest)
> +		return;
> +
> +	/*
> +	 * TODO: Handle KVM_MR_MOVE
> +	 */
> +	if (change == KVM_MR_CREATE) {
> +		uv_register_mem_slot(kvm->arch.lpid,
> +					   new->base_gfn << PAGE_SHIFT,
> +					   new->npages * PAGE_SIZE,
> +					   0,
> +					   new->id);
> +	} else if (change == KVM_MR_DELETE) {
> +		uv_unregister_mem_slot(kvm->arch.lpid, old->id);
> +	}
>  }
> 
>  /*

