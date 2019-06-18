Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B38D9C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 23:05:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 513872080C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 23:05:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 513872080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F4D46B0003; Tue, 18 Jun 2019 19:05:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97EBC8E0002; Tue, 18 Jun 2019 19:05:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D9A68E0001; Tue, 18 Jun 2019 19:05:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 406956B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 19:05:41 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h27so3769152pfq.17
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 16:05:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:references
         :user-agent:from:to:cc:subject:in-reply-to:date:mime-version
         :message-id;
        bh=upkLbL3DPmcdMbPg34kPtySrAjp767IbGKcKu/0c3zI=;
        b=YJUz5HNo9xVxOKORDQvNPjkIp20qMU6601Hy4UZdCUibPYyb76IqAWoqbiIuzczpQ4
         F/O7G+ArpX460j+APVGCnjfMg03cCwbbfdqi6IIQSodDAzycwCfCBqtZyxXq9X8KnedN
         NUspV4/lFKXHz0JreWSGBntdDsaMAIq9wln8fQYTNcOdSCSPv75afuY/61WPSnw3AWdQ
         9/0iNrhr4iynEnMa+nvD3RdjAHqcp9Vt+ByuhmVAc5QSNhD35c/l/ZQ57gKxlrSaK2Iw
         zdbRy1lqZseumpvB3W+psBg+mTcmizKFow07rBtiid+7ujcRoZ1dZ+Swo2/RumoW1jNl
         chWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bauerman@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bauerman@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUkcrl3vv1ZpBWmRM9z+sPgzyK1676OTiqLS4/kTj52fvBiKlpn
	R0A+nhxzm/42Fmf73lCVB7mr2nT5E7w70gexBJvyJdNSeE9cJpG9NIOXPsM2fwVYo9dUawEwE5C
	INGQEJF38LyiN2xAuB1r5W96WCV1aEsT+jSyE0IaC3Kf7grlkwe1A4rEx9i3LQAafAQ==
X-Received: by 2002:a17:902:3103:: with SMTP id w3mr6426424plb.84.1560899140806;
        Tue, 18 Jun 2019 16:05:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfN8E386MhJt7CTa3s0Je2/fTOYblYyVLO9fWjs5y93DjzkQFDVSrgZ7TBWpp8GwV3YqP2
X-Received: by 2002:a17:902:3103:: with SMTP id w3mr6426359plb.84.1560899139942;
        Tue, 18 Jun 2019 16:05:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560899139; cv=none;
        d=google.com; s=arc-20160816;
        b=zWxq1yZ4LpfP/Anq2LFceEsCdqXu8BvypDGVoxZsWdPE9Zlnw0Wuju3/AOteIqjiYj
         Fz+hRkwM81npcbBXM+w17md/yp2+mXcR2yT1/GjORVui0HbLa9P8ahF2HJh96WSFbyBt
         xgc1iGCEAE+AsIq69jcaG9h24Fha1iRQqNjaXfVrXpvYDXFKxvmpkp8dlckabGjUtA/k
         Ow9UvfRv/TYK22KVeh+CbknkTPHHoklVMWuY6RTyTts3wUFxyfeZk68GAfnvFkbBHEDr
         oeKjWDd6cr8blC9puHE0vHuA06OvHTx+viVPAF/lnQDE9Gcf2FIN/fVh/jpP5vHg+IXr
         p/Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:in-reply-to:subject:cc:to:from
         :user-agent:references;
        bh=upkLbL3DPmcdMbPg34kPtySrAjp767IbGKcKu/0c3zI=;
        b=BSRvGU59xlv0mXMpFPi5gam2nKTkAqErpQ37nUdfGtw1SsDaRA6rm/zJPItiM56iKQ
         7Sw3CPWREpwEQg3PXQfnzVb0h2RLxaE1ZZfJf6z/ZLgQXxS2J3Obsi4gHbAkHgPvdjGW
         ja1yMUTEPqLeDJFk3irQHaOXj7gWHNYlQWwnOobyRiTq+99Culo1kqQJPP7yztOFv6OK
         Ta4CpkMchXv/46M+iO3QaWmmYmTCT9SV/9FCtfFw53QB50LycqHN21fvVBgtD6WPJ6fI
         UKi/DxXS+O/YUc9/3DfLnuQdhFF2Vgifxbrpxg4vzHAWTQRh/BbggzKWKYE4wjfn+H2/
         E6Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bauerman@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bauerman@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t22si1314873pgk.507.2019.06.18.16.05.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 16:05:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of bauerman@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bauerman@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bauerman@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5IMvJu2087204
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 19:05:39 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t77ymu6d9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 19:05:38 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.ibm.com>;
	Wed, 19 Jun 2019 00:05:37 +0100
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e16.ny.us.ibm.com (146.89.104.203) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 19 Jun 2019 00:05:34 +0100
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5IN5Xdc35127798
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 18 Jun 2019 23:05:33 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 01820AC05E;
	Tue, 18 Jun 2019 23:05:33 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D5F6CAC059;
	Tue, 18 Jun 2019 23:05:30 +0000 (GMT)
Received: from morokweng.localdomain (unknown [9.80.212.11])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTPS;
	Tue, 18 Jun 2019 23:05:30 +0000 (GMT)
References: <20190528064933.23119-1-bharata@linux.ibm.com> <20190528064933.23119-4-bharata@linux.ibm.com>
User-agent: mu4e 1.2.0; emacs 26.2
From: Thiago Jung Bauermann <bauerman@linux.ibm.com>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com
Subject: Re: [PATCH v4 3/6] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
In-reply-to: <20190528064933.23119-4-bharata@linux.ibm.com>
Date: Tue, 18 Jun 2019 20:05:26 -0300
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19061823-0072-0000-0000-0000043E34AC
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011287; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01219945; UDB=6.00641721; IPR=6.01001087;
 MB=3.00027366; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-18 23:05:35
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061823-0073-0000-0000-00004CAE3D5C
Message-Id: <87y31y7avd.fsf@morokweng.localdomain>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-18_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=852 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906180185
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hello Bharata,

Bharata B Rao <bharata@linux.ibm.com> writes:

> diff --git a/arch/powerpc/include/asm/kvm_book3s_hmm.h b/arch/powerpc/include/asm/kvm_book3s_hmm.h
> index 21f3de5f2acb..3e13dab7f690 100644
> --- a/arch/powerpc/include/asm/kvm_book3s_hmm.h
> +++ b/arch/powerpc/include/asm/kvm_book3s_hmm.h
> @@ -11,6 +11,8 @@ extern unsigned long kvmppc_h_svm_page_out(struct kvm *kvm,
>  					  unsigned long gra,
>  					  unsigned long flags,
>  					  unsigned long page_shift);
> +extern unsigned long kvmppc_h_svm_init_start(struct kvm *kvm);
> +extern unsigned long kvmppc_h_svm_init_done(struct kvm *kvm);
>  #else
>  static inline unsigned long
>  kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gra,
> @@ -25,5 +27,15 @@ kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gra,
>  {
>  	return H_UNSUPPORTED;
>  }
> +
> +static inine unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
> +{
> +	return H_UNSUPPORTED;
> +}
> +
> +static inine unsigned long kvmppc_h_svm_init_done(struct kvm *kvm);
> +{
> +	return H_UNSUPPORTED;
> +}
>  #endif /* CONFIG_PPC_UV */
>  #endif /* __POWERPC_KVM_PPC_HMM_H__ */

This patch won't build when CONFIG_PPC_UV isn't set because of two
typos: "inine" and the ';' at the end of kvmppc_h_svm_init_done()
function prototype.

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

