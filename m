Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2F61C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 07:01:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACB4D206DF
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 07:01:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACB4D206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4151B6B000A; Wed, 27 Mar 2019 03:01:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C5586B000C; Wed, 27 Mar 2019 03:01:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B4046B000D; Wed, 27 Mar 2019 03:01:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9DF6B000A
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 03:01:36 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x58so16044852qtc.1
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 00:01:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=+tAH2xcgBrSRADmZ6HcJf6eGMVF/XnjCBFBDhIT93co=;
        b=JMGcnoQhK2pTkgh1qa6n6NFqZ7pUuFbUhNWmnUbKkf/N06+xsUWnzt12hAGt2XOwhf
         ECwLqL7JskBUIhXIaGLlko83rlxpFb6RcEM+4VqpJn9vsn1kDLQHzc2yjq/emZ2kPARu
         KPxoNVgY/JqLHJoZm5rYs5GHktAKVrBHhWZKTBlHJsJLCLPIDvaBv57x2Jak7GOQOoYG
         Uwr6qy/s8LqdRiwlpna6wqvZ0WNSRU7zEeDT+Nfidbk2+eKiMT9xtALEZcHqW3QV8YO3
         6USMq7VySMZCL8UTpAFu0HL4n2xqNs8IUmr919cSlBNmnLP8YUY2EfpBOmghDzm6sWMI
         CA7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVG9vMwH0iqxqAscvqf0e1dfPjDaYUnlEu+5qD3ipKJSsz4azaz
	sK46Sps7YwEo7QDAY+IlK9HZRm8U2xRCmXB0mEjbuKX/ou24EwbyVm4xRlsjxh8X+A8ahJns9bt
	nndkmU18/igVnh8K9AYseF0Ib27KT/n25rEhcJeQ1gANscggbNTMrcQtwVKjazX78Eg==
X-Received: by 2002:a05:620a:13d7:: with SMTP id g23mr27773976qkl.198.1553670095764;
        Wed, 27 Mar 2019 00:01:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqHPgmCg4dvu9GXEX7wgNzvbD3SUXh2vy2Nlu9ziPwSw8xNwB44+oDSubZMWtcl2+b2di2
X-Received: by 2002:a05:620a:13d7:: with SMTP id g23mr27773930qkl.198.1553670095013;
        Wed, 27 Mar 2019 00:01:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553670095; cv=none;
        d=google.com; s=arc-20160816;
        b=0o31aLOU6haN9clkoErB32N9XPAAjLzz5OB1IJ59QgExCz86JcYwKnqHeCjBfhcSLN
         e6yWJ0e6ZdAkzWl2i/Cyr883JpQQEMi3Vj+kIyIH0ENT8Y/zW60+XlrOl2wVPfLxa4eC
         n4PQr+q3zxdT99GBl1OenBjxbL8/7BoNh4aiGSq/YA2CKq14nFhSpdD6C8x9/fU9JYwQ
         7c/36XclwjrsnyGLBKY+5Un4JGgIP78RfoDc+8uoIyiji5c+Wmt34FproyJJfmUWBpM/
         4QKBDj028KZZQ1TrDh3+7S8X0y9hbGxfVr3Qlik8mFoZF0OEPRm+JsPOXkQ1jBdABLij
         sjQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:to:subject;
        bh=+tAH2xcgBrSRADmZ6HcJf6eGMVF/XnjCBFBDhIT93co=;
        b=RTkhiOaOXofCVTm2itGELaSQ+Fy+Nn65VDwJm5F9GD7qgpLKLxWyy924MWowA140Mh
         7GCQxdwz4EnBodkekX350gSDnTbnwcTERFTjXxpQJkzgBbAQ0meGeneafoI8odeKlpQf
         tQ4K0xEY+kbtK2vFfuF1rrmyWaIBKWD0M2mqg76m2//Sr0FIiH1lJchtXHelSDdqo3pH
         CDxG1JB0b5M4Rh/GKxaU3twf6FYRQpCzBDsg3wqbEURrMuKIDObh7pjgm9kz5hyAKRx0
         rylzhQCcL7bmpZDoZLUTTCcHi9Eh7G60wLYZ4L9dZDY5cQXgY+xU3S2xz4QEfwbHDjIB
         JA0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n188si498072qke.116.2019.03.27.00.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 00:01:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2R6xr0n138555
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 03:01:34 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rg3ca2duf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 03:01:34 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 27 Mar 2019 07:01:33 -0000
Received: from b03cxnp07028.gho.boulder.ibm.com (9.17.130.15)
	by e35.co.us.ibm.com (192.168.1.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Mar 2019 07:01:26 -0000
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2R71NFe23986222
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Mar 2019 07:01:24 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D880DC605B;
	Wed, 27 Mar 2019 07:01:23 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 188B1C6063;
	Wed, 27 Mar 2019 07:01:12 +0000 (GMT)
Received: from [9.102.0.57] (unknown [9.102.0.57])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 27 Mar 2019 07:01:11 +0000 (GMT)
Subject: Re: [PATCH v8 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Alexandre Ghiti <alex@ghiti.fr>, mpe@ellerman.id.au,
        Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon
 <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        "David S . Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
        x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-mm@kvack.org
References: <20190327063626.18421-1-alex@ghiti.fr>
 <20190327063626.18421-5-alex@ghiti.fr>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Wed, 27 Mar 2019 12:31:10 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190327063626.18421-5-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19032707-0012-0000-0000-0000171DBC1B
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010822; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000282; SDB=6.01180287; UDB=6.00617666; IPR=6.00961004;
 MB=3.00026175; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-27 07:01:32
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032707-0013-0000-0000-000056A767C6
Message-Id: <f6e74ad8-acca-3b1e-27eb-a2881ac8437d@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-27_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903270049
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/27/19 12:06 PM, Alexandre Ghiti wrote:
> On systems without CONTIG_ALLOC activated but that support gigantic pages,
> boottime reserved gigantic pages can not be freed at all. This patch
> simply enables the possibility to hand back those pages to memory
> allocator.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
>
> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> index ec2a55a553c7..7013284f0f1b 100644
> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> @@ -36,8 +36,8 @@ static inline int hstate_get_psize(struct hstate *hstate)
>   	}
>   }
>   
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> -static inline bool gigantic_page_supported(void)
> +#define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
> +static inline bool gigantic_page_runtime_supported(void)
>   {
>   	/*
>   	 * We used gigantic page reservation with hypervisor assist in some case.
> @@ -49,7 +49,6 @@ static inline bool gigantic_page_supported(void)
>   
>   	return true;
>   }
> -#endif
>   
>   /* hugepd entry valid bit */
>   #define HUGEPD_VAL_BITS		(0x8000000000000000UL)

Is that correct when CONTIG_ALLOC is not enabled? I guess we want

gigantic_page_runtime_supported to return false when CONTIG_ALLOC is not 
enabled on all architectures and on POWER when it is enabled we want it 
to be conditional as it is now.

-aneesh

