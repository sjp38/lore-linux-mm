Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7123C74A21
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 13:22:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C91F2064B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 13:22:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C91F2064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8B9C8E0074; Wed, 10 Jul 2019 09:22:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3C9C8E0032; Wed, 10 Jul 2019 09:22:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2AAC8E0074; Wed, 10 Jul 2019 09:22:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE398E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 09:22:34 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 6so1337510pfz.10
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 06:22:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:organization
         :reply-to:mail-reply-to:in-reply-to:references:user-agent:message-id;
        bh=DQvRhIDNzoRVD6utvNNP2JJTLpl217g6G6NKeCYSne4=;
        b=iRgQ4WT5iU+ECGLu7cBOq2QmhkpX6uQxNaAiFZ84uXU30RFKbYE4Bz56DhUB2OOtw+
         x6LSdMgvMoqURMwZkC4Bi9zGwpNNtR0qcvepbdo2yDbC2AMqnCx5qTLlkypvwyuRF4gK
         u9icgOwXRGm4qOamSIhtwVNf4brpjHgrn7MZ43B3dyiVu1hmVhYqXLVZGesIEtAq2+V+
         /YvjFjoHJmztlIm/FQjwcKC0GUSHbUQ0O0Xg844HdYMD3HOR4uIoRNeSmyqiXlZzI7Xt
         vxlHHqI0N7s/xcQTl8ew6EjLimSvzHb/1ce6Cm+DFtFYFn9TIUlHW2Ua9PxiZg4kiOtc
         kWxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWpsHJOUYaVwwHN1oCEAgKOXkhy70aM5GsQH1JuncVBFKlT40OM
	IjVuNLuYkp1J+myyfbijM5I2T6t/CqMJ2dyDJCcUGQmSRMk/JJCkNp5U5YjcgOuu0CR+o9fFkTy
	rmUeq9VTSLgVZ9fPDkfM16CPkyXBI6189f6jYbgWnK+6aJ1wZT7J2y+VIcWZ8YL1zLQ==
X-Received: by 2002:a65:654f:: with SMTP id a15mr36235746pgw.73.1562764953973;
        Wed, 10 Jul 2019 06:22:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3ZS5LFxE52MG1L4C/q9cyWg7uKPEoQIQHNSszT9ziZjWNbL/wzMpkaGzLBtBoSeg9/U+o
X-Received: by 2002:a65:654f:: with SMTP id a15mr36235678pgw.73.1562764953153;
        Wed, 10 Jul 2019 06:22:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562764953; cv=none;
        d=google.com; s=arc-20160816;
        b=C1erTQiagz5iDmhFmyD2MKLhm+UPDDCJLfR6yG0JKbPPpF0PT85MC8ozRRoCsbtRnf
         v1ABLtZjLEvGl2pKvs1guaDYMIA0KkFIYhwdCqj4dyJi7SX2RMOPj/ALjy/uenwZ3r3E
         vIqCrQ5LV2TVsnOU+luZ9J52RNA+H/MUA9LAmZSN3/0CanqLPYzaVfk2WSFyWwjBbjVU
         9T+SfTJG5VWqg4O+iQ81MJJIDKk7x+PU5jCXmfSgk7lyJkF82b0XGahOhyCyDjt/UAxm
         XAjwUnIsQXTispgK1AfqVWf4i8rT75VRb0BhGV7+1UdPNUd4kRoj4RHumgbRT10GoeFS
         Wp2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:references:in-reply-to:mail-reply-to:reply-to
         :organization:subject:cc:to:from:date:content-transfer-encoding
         :mime-version;
        bh=DQvRhIDNzoRVD6utvNNP2JJTLpl217g6G6NKeCYSne4=;
        b=wR2mtM1QwAQC1QvqLNuNW0FjjKkrCuJORIDdWlX83rUvdIBaXHnxtXBMeIxPItFtLk
         SaADDyvzJL1/gOHK3mRp/HvODngKzdnF+IPMHX/PDD0VIlDQRJzPPFZWhaJ5mAKSJ1Lc
         zb67SqeLG8xwKcgz6YxSLdyxE+sx3wf8U7sVJmD8UkaEofAM3ssya90zAdPCrmb8/nHH
         cXXOBsZlwi/7QqWcOznvWzqqeYu05nwJ/OQXuPqLUb8oOIDhIvj/+dJ5mmyJScHUfdOK
         ONDmcdCrBvDV4OrYyKl+z6jhQ2yQyD8YY2aSoS11dgTwwL74cOQEaFpd4wlzvGllsFfH
         UP9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id cb5si2089205plb.172.2019.07.10.06.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 06:22:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of janani@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=janani@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6ADJKls037362
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 09:22:32 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tng31jp2s-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 09:22:32 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <janani@linux.ibm.com>;
	Wed, 10 Jul 2019 14:22:30 +0100
Received: from b03cxnp08025.gho.boulder.ibm.com (9.17.130.17)
	by e33.co.us.ibm.com (192.168.1.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 10 Jul 2019 14:22:28 +0100
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6ADMQHe37355980
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Jul 2019 13:22:26 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B9DA06A047;
	Wed, 10 Jul 2019 13:22:26 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5F6FF6A057;
	Wed, 10 Jul 2019 13:22:26 +0000 (GMT)
Received: from ltc.linux.ibm.com (unknown [9.16.170.189])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 10 Jul 2019 13:22:26 +0000 (GMT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Jul 2019 08:24:56 -0500
From: janani <janani@linux.ibm.com>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linuxram@us.ibm.com, cclaudio@linux.ibm.com,
        kvm-ppc@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com,
        aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com,
        sukadev@linux.vnet.ibm.com,
        Anshuman Khandual <khandual@linux.vnet.ibm.com>,
        Linuxppc-dev <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>
Subject: Re: [PATCH v5 7/7] KVM: PPC: Ultravisor: Add PPC_UV config option
Organization: IBM
Reply-To: janani@linux.ibm.com
Mail-Reply-To: janani@linux.ibm.com
In-Reply-To: <20190709102545.9187-8-bharata@linux.ibm.com>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-8-bharata@linux.ibm.com>
X-Sender: janani@linux.ibm.com
User-Agent: Roundcube Webmail/1.0.1
X-TM-AS-GCONF: 00
x-cbid: 19071013-0036-0000-0000-00000AD591AA
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011404; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01230167; UDB=6.00647931; IPR=6.01011436;
 MB=3.00027665; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-10 13:22:30
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071013-0037-0000-0000-00004C890942
Message-Id: <6759c8a79b2962d07ed99f2b1cd05637@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-10_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907100155
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-09 05:25, Bharata B Rao wrote:
> From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> 
> CONFIG_PPC_UV adds support for ultravisor.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> [ Update config help and commit message ]
> Signed-off-by: Claudio Carvalho <cclaudio@linux.ibm.com>
  Reviewed-by: Janani Janakiraman <janani@linux.ibm.com>
> ---
>  arch/powerpc/Kconfig | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index f0e5b38d52e8..20c6c213d2be 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -440,6 +440,26 @@ config PPC_TRANSACTIONAL_MEM
>         ---help---
>           Support user-mode Transactional Memory on POWERPC.
> 
> +config PPC_UV
> +	bool "Ultravisor support"
> +	depends on KVM_BOOK3S_HV_POSSIBLE
> +	select HMM_MIRROR
> +	select HMM
> +	select ZONE_DEVICE
> +	select MIGRATE_VMA_HELPER
> +	select DEV_PAGEMAP_OPS
> +	select DEVICE_PRIVATE
> +	select MEMORY_HOTPLUG
> +	select MEMORY_HOTREMOVE
> +	default n
> +	help
> +	  This option paravirtualizes the kernel to run in POWER platforms 
> that
> +	  supports the Protected Execution Facility (PEF). In such platforms,
> +	  the ultravisor firmware runs at a privilege level above the
> +	  hypervisor.
> +
> +	  If unsure, say "N".
> +
>  config LD_HEAD_STUB_CATCH
>  	bool "Reserve 256 bytes to cope with linker stubs in HEAD text" if 
> EXPERT
>  	depends on PPC64

