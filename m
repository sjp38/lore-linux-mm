Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EB9FC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 05:57:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DA6D20700
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 05:57:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DA6D20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B851F6B0003; Thu, 28 Mar 2019 01:57:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B35C76B0006; Thu, 28 Mar 2019 01:57:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D78D6B0007; Thu, 28 Mar 2019 01:57:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 635E06B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 01:57:39 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q7so5876210plr.7
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 22:57:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=t6t4lcMObyXRQ+SE7rAT68YzcAHuSiVHg6LDOnYL700=;
        b=Ui5kz5ofswY6vPaosq3D0zFtJ01UH5HrEhE7HLAcA8V85bvh22p0Rqr+MCQdbjSBEi
         Fi8CTRoXVIxbqogmhDrbnfLip5g41l04PvnnJpaavxUUmMnmBcRGrGLLJoxRQy3DqQ09
         SzIu/TFDXVJlTfo6zrNkFMHiQdz+KGkc+KqL1OC9sLUcw+ADLntyiZ3Hrkc8D7DYiuEh
         TRI2Urwfd3N+lIgtKyewmig90O1UaV4ai9iCIyjmUz2viZK1JRA9FIdFNjJrD7xVTNJW
         cVAUsbEOvddqa0YD7Xe/l+MV17GdyFYfdIomylGks8Od+tjGQWlfAC4O5W2HmrqFa+0g
         WxZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUyo5ZDx1rhxfvn4k3TzBAMUMty2l/66628A4m47p5Znfta12GW
	ENNF6Jbw2PggE3q5IDIXmr7fH6kyuF0wglE2LUIoSpb+86JUy+LLIgSY3WFV0eFTai1QeXg7aZr
	qMqqkTNVIIfDJRBZ1sFvpUtdyOjQgBxsUzlg5smoA2AemaF31w+xUTBbYHqhAORo45A==
X-Received: by 2002:a17:902:b717:: with SMTP id d23mr22810738pls.260.1553752658809;
        Wed, 27 Mar 2019 22:57:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp9y2EA5B2i+FTshsSmZ0eDXCJRDj8mrFyTN2k6V1bfcDh0/OuYozsZBen6wL3iqyCh5Jv
X-Received: by 2002:a17:902:b717:: with SMTP id d23mr22810694pls.260.1553752657923;
        Wed, 27 Mar 2019 22:57:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553752657; cv=none;
        d=google.com; s=arc-20160816;
        b=YGOnJPEhjrtQRIGumsm5QtFcQEYUpv9MGW54smhoB1wmGc5bCL8m+QZpzA5DpvpOj+
         Kk42Mby03xsoF2cYG/SORgmmW8jR51F0Z/ODsMIc4sON/fu3C++gj+Z6Y9ozjD23+ZSB
         Otj8oWKczXhnydiLJD7IyoPe1xdU4q2G2WlPoMiNfUcfoYt+duKA6knoRlgvGnNd5KG0
         UJs9YjnPJV0cho6ZWPJNHvzvTEv1xhACcd09Lf/vB54nL921h8gozG2d/mYZPoYi2xPH
         GM5kglAbNkjVWs7LzHz9bq5FWUqA9VzitVTlURlgx9LPzKcdMUz3V7Ta9bQTb76N+ymo
         ni8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=t6t4lcMObyXRQ+SE7rAT68YzcAHuSiVHg6LDOnYL700=;
        b=0VzDeUBQnkpSgEgsFMYrAawVtPbaFpa7Ni/nRke5v5e0CmqoaIlOKC3+npXzQiPGgP
         gfH/WzkgbLf+QrcVsed2Ss++rtEyNw66zTmptWS9QT74q6jM1mS4JpQdIue9V15DFs3G
         rzq5pORDy0xcdk4JlWrmCj+Zk1P0Vl5e9Xq/8JAr4wiqxctDVtlvUV4U+n7zdR5JBW71
         Vx895uqgTlSTARRm4qMNIKfkqIuNrijE9Zf4u9tyKDLkYA22aN6jSlpIjLm9zXMxU7mO
         WxdW13tpXsZvkSlPgxm/xuk3aTKZr70/1B4DDGjnfkbt3aLKWTRHwdBYBkHhG0o2T7qq
         bPWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j17si9792505pgk.114.2019.03.27.22.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 22:57:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2S5nCWn104317
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 01:57:37 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rgnk0pe5n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 01:57:37 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 28 Mar 2019 05:57:34 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 28 Mar 2019 05:57:26 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2S5vPYa44761316
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 05:57:25 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 28854A4051;
	Thu, 28 Mar 2019 05:57:25 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B9B51A405D;
	Thu, 28 Mar 2019 05:57:22 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 28 Mar 2019 05:57:22 +0000 (GMT)
Date: Thu, 28 Mar 2019 07:57:21 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Sasha Levin <sashal@kernel.org>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
        Catalin Marinas <catalin.marinas@arm.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        Christoph Hellwig <hch@lst.de>,
        "David S. Miller" <davem@davemloft.net>,
        Dennis Zhou <dennis@kernel.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greentime Hu <green.hu@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>,
        Guo Ren <ren_guo@c-sky.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Juergen Gross <jgross@suse.com>, Mark Salter <msalter@redhat.com>,
        Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>,
        Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>,
        Petr Mladek <pmladek@suse.com>, Richard Weinberger <richard@nod.at>,
        Rich Felker <dalias@libc.org>, Rob Herring <robh+dt@kernel.org>,
        Rob Herring <robh@kernel.org>, Russell King <linux@armlinux.org.uk>,
        Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>,
        Vineet Gupta <vgupta@synopsys.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org
Subject: Re: [PATCH AUTOSEL 5.0 015/262] memblock:
 memblock_phys_alloc_try_nid(): don't panic
References: <20190327180158.10245-1-sashal@kernel.org>
 <20190327180158.10245-15-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190327180158.10245-15-sashal@kernel.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032805-0020-0000-0000-00000328A172
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032805-0021-0000-0000-0000217AE66F
Message-Id: <20190328055720.GB14864@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-28_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=21 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1031 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903280044
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 27, 2019 at 01:57:50PM -0400, Sasha Levin wrote:
> From: Mike Rapoport <rppt@linux.ibm.com>
> 
> [ Upstream commit 337555744e6e39dd1d87698c6084dd88a606d60a ]
> 
> The memblock_phys_alloc_try_nid() function tries to allocate memory from
> the requested node and then falls back to allocation from any node in
> the system.  The memblock_alloc_base() fallback used by this function
> panics if the allocation fails.
> 
> Replace the memblock_alloc_base() fallback with the direct call to
> memblock_alloc_range_nid() and update the memblock_phys_alloc_try_nid()
> callers to check the returned value and panic in case of error.

This is a part of memblock refactoring, I don't think it should be applied
to -stable.
 
> Link: http://lkml.kernel.org/r/1548057848-15136-7-git-send-email-rppt@linux.ibm.com
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> Acked-by: Michael Ellerman <mpe@ellerman.id.au>		[powerpc]
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Dennis Zhou <dennis@kernel.org>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Greentime Hu <green.hu@gmail.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Guan Xuetao <gxt@pku.edu.cn>
> Cc: Guo Ren <guoren@kernel.org>
> Cc: Guo Ren <ren_guo@c-sky.com>				[c-sky]
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Juergen Gross <jgross@suse.com>			[Xen]
> Cc: Mark Salter <msalter@redhat.com>
> Cc: Matt Turner <mattst88@gmail.com>
> Cc: Max Filippov <jcmvbkbc@gmail.com>
> Cc: Michal Simek <monstr@monstr.eu>
> Cc: Paul Burton <paul.burton@mips.com>
> Cc: Petr Mladek <pmladek@suse.com>
> Cc: Richard Weinberger <richard@nod.at>
> Cc: Rich Felker <dalias@libc.org>
> Cc: Rob Herring <robh+dt@kernel.org>
> Cc: Rob Herring <robh@kernel.org>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Stafford Horne <shorne@gmail.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Sasha Levin <sashal@kernel.org>
> ---
>  arch/arm64/mm/numa.c   | 4 ++++
>  arch/powerpc/mm/numa.c | 4 ++++
>  mm/memblock.c          | 4 +++-
>  3 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
> index ae34e3a1cef1..2c61ea4e290b 100644
> --- a/arch/arm64/mm/numa.c
> +++ b/arch/arm64/mm/numa.c
> @@ -237,6 +237,10 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
>  		pr_info("Initmem setup node %d [<memory-less node>]\n", nid);
>  
>  	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
> +	if (!nd_pa)
> +		panic("Cannot allocate %zu bytes for node %d data\n",
> +		      nd_size, nid);
> +
>  	nd = __va(nd_pa);
>  
>  	/* report and initialize */
> diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
> index 87f0dd004295..8ec2ed30d44c 100644
> --- a/arch/powerpc/mm/numa.c
> +++ b/arch/powerpc/mm/numa.c
> @@ -788,6 +788,10 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
>  	int tnid;
>  
>  	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
> +	if (!nd_pa)
> +		panic("Cannot allocate %zu bytes for node %d data\n",
> +		      nd_size, nid);
> +
>  	nd = __va(nd_pa);
>  
>  	/* report and initialize */
> diff --git a/mm/memblock.c b/mm/memblock.c
> index ea31045ba704..d5923df56acc 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1342,7 +1342,9 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
>  
>  	if (res)
>  		return res;
> -	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
> +	return memblock_alloc_range_nid(size, align, 0,
> +					MEMBLOCK_ALLOC_ACCESSIBLE,
> +					NUMA_NO_NODE, MEMBLOCK_NONE);
>  }
>  
>  /**
> -- 
> 2.19.1
> 

-- 
Sincerely yours,
Mike.

