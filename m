Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F8B4C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:21:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DF712084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:21:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DF712084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A66718E000B; Mon, 25 Feb 2019 13:21:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A15498E0009; Mon, 25 Feb 2019 13:21:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DEA48E000B; Mon, 25 Feb 2019 13:21:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDA68E0009
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:21:19 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 59so7841829plc.13
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:21:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=i7ECJv7f/dfu1RsqQpPTxHrLI9npK8F9rkv8d5+XGT0=;
        b=UHB51OoAkz2pKY2WhUhByMUqmsB9f91k0TE/A1XhTyigBfxYu4mVVBIHvlqH1wuoNW
         3FHKlqxOUU9/zliixQ2eyuUfFqcIREta8Ef2myKuqN/ZGTGaMBxc/amZbz0kZ5wwITsi
         +5tle+gkvANVdL8L4sBnprkO77KwdDK17ROQpjA2d1ieEnspFp7HsuWUYfxWF7zfHpz0
         wlIUSEwSRtrW16MKmv6M3kcpQvUYbH4aqST8wCxV6Nmrk71xTsoOlZyNth4KiYD9A3Cs
         vxLG+481jFCb0jYB6MS/YzdWEEhjRYiDNmgLIOpGXREIOx4AKXZbx6cza68XwlU8/Hek
         l4Nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuagccx6YVS4rAPFQAFWh8/pi4lL3HtMDxxJw0cVh/iMkt81DeFT
	zGhz5h7ij5ua40dJHLG8RhFmTee1KgbLKWrOXdeCJEjoLFjlHCIT5UzGmNggrAPwBlfC1ZZXjbv
	TEUnfE5sG2G0U1m+J+myTHo++Fu2lh+ViEh5OXQWp9S7WS37XNrIebpECw5ivA9Ow8Q==
X-Received: by 2002:a63:2f47:: with SMTP id v68mr19968903pgv.144.1551118878998;
        Mon, 25 Feb 2019 10:21:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZPny2CeChZ3CehD9KCnsDzS/j6/ctdWre2a733eTKvSOOUImAmP6fQuXyax3CzreTiplny
X-Received: by 2002:a63:2f47:: with SMTP id v68mr19968865pgv.144.1551118878173;
        Mon, 25 Feb 2019 10:21:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551118878; cv=none;
        d=google.com; s=arc-20160816;
        b=DE9CVAl1xpnwqt+7tGSm3FDZ4pX/PyC7VTB7qlWsZafoMVO7rzEQcFvnbu27KxL7+/
         EHB/+0EPuHR0YUfQPHqXoO2YRzHZaCrEefNKH/tSBK6xkcYj+uNWXwqsSzJYEgQgyP6t
         WmbF+Sws/1UuLxDn/uyMUrWANaZ1XHDlGT7BV3PU2LAfmoh5J2UEO7FizWrCjVK5VTBs
         ZS4lXAKdUaH/YfRheoi4cuI13qotQNbdeq1zbIziDyamtleBpGGasjATWCTolrmZF6PS
         1mBv3RuQRMk/f03cNyjA3dxqU0DEmWqz7OCCPCNcKfLpWAqrcw5Ug6Hv9cxI7P0ZwlNQ
         d3Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=i7ECJv7f/dfu1RsqQpPTxHrLI9npK8F9rkv8d5+XGT0=;
        b=0En1GYZJP0n39F30nS1JFEZHByxDakyXLb3L+qwoNfSfj4i7MinpAaEKNavxi4/A6x
         4854cXYZYOW22WZRbwVwMBz/Q5aN8MScExuW5EZAh+IaLytGNkLx1V5rmckwLP+Q34Sd
         mGffIm7ivFjZ3PKBLefBdOymrbE1a16WeMz+vQSz79JcTsrprzMYRsgLQKLfJZxp+AhS
         fBmjRUPCJbk55uIRuebeUMRs4k1YfakrsBhUI+lyI25ZRqm1MES9VNKxivze30ZNoJFj
         IkvibwVlTBYDA6GoaXCIH5HNS4N3bMfsDeq5FLRSl3HDbdShTMsh4ZAJsk/UebZUjHyv
         WDPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h2si9492016pgp.60.2019.02.25.10.21.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 10:21:18 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PIKsMY018675
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:21:15 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvnamrq8w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:21:15 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 18:21:12 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 18:21:07 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PIL6uR23003248
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 18:21:06 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 56DE34203F;
	Mon, 25 Feb 2019 18:21:06 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8C20642042;
	Mon, 25 Feb 2019 18:20:58 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.26])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 18:20:58 +0000 (GMT)
Date: Mon, 25 Feb 2019 20:20:45 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 16/26] userfaultfd: wp: add pmd_swp_*uffd_wp() helpers
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-17-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-17-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022518-0016-0000-0000-0000025ABC11
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022518-0017-0000-0000-000032B51AD2
Message-Id: <20190225182044.GH24917@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=987 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250134
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:22AM +0800, Peter Xu wrote:
> Adding these missing helpers for uffd-wp operations with pmd
> swap/migration entries.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  arch/x86/include/asm/pgtable.h     | 15 +++++++++++++++
>  include/asm-generic/pgtable_uffd.h | 15 +++++++++++++++
>  2 files changed, 30 insertions(+)
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 6863236e8484..18a815d6f4ea 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -1401,6 +1401,21 @@ static inline pte_t pte_swp_clear_uffd_wp(pte_t pte)
>  {
>  	return pte_clear_flags(pte, _PAGE_SWP_UFFD_WP);
>  }
> +
> +static inline pmd_t pmd_swp_mkuffd_wp(pmd_t pmd)
> +{
> +	return pmd_set_flags(pmd, _PAGE_SWP_UFFD_WP);
> +}
> +
> +static inline int pmd_swp_uffd_wp(pmd_t pmd)
> +{
> +	return pmd_flags(pmd) & _PAGE_SWP_UFFD_WP;
> +}
> +
> +static inline pmd_t pmd_swp_clear_uffd_wp(pmd_t pmd)
> +{
> +	return pmd_clear_flags(pmd, _PAGE_SWP_UFFD_WP);
> +}
>  #endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
> 
>  #define PKRU_AD_BIT 0x1
> diff --git a/include/asm-generic/pgtable_uffd.h b/include/asm-generic/pgtable_uffd.h
> index 643d1bf559c2..828966d4c281 100644
> --- a/include/asm-generic/pgtable_uffd.h
> +++ b/include/asm-generic/pgtable_uffd.h
> @@ -46,6 +46,21 @@ static __always_inline pte_t pte_swp_clear_uffd_wp(pte_t pte)
>  {
>  	return pte;
>  }
> +
> +static inline pmd_t pmd_swp_mkuffd_wp(pmd_t pmd)
> +{
> +	return pmd;
> +}
> +
> +static inline int pmd_swp_uffd_wp(pmd_t pmd)
> +{
> +	return 0;
> +}
> +
> +static inline pmd_t pmd_swp_clear_uffd_wp(pmd_t pmd)
> +{
> +	return pmd;
> +}
>  #endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
> 
>  #endif /* _ASM_GENERIC_PGTABLE_UFFD_H */
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

