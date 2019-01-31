Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16B87C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:42:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0D8C2087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 06:42:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0D8C2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE94E8E0002; Thu, 31 Jan 2019 01:42:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6F5A8E0001; Thu, 31 Jan 2019 01:42:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE88C8E0002; Thu, 31 Jan 2019 01:42:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F15C8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:42:02 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id u32so2572614qte.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:42:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=WXT+cElB+9LMBUwkC5AslWD1LurDKzzfmL5+K4AdmXI=;
        b=YmrBRcr310YVKb1xAN3vcBbD3EdeDZszpQOfYMQNsiyFJIM1L5MVGw0BGvSeAJpH0P
         EJJbR1hbpB17hF441O91XBtyXOqe770c+EWEs9DJVDo5i90LL8D4CpiWIgjNOgWbBJeD
         NHB5+ulVnYi29i8u0Yg2HHtmobFuAXkKsScbMewTAECGDLqB1aIDFJUi/rk1TrYh86k2
         LwM41hv4YauqaZjIG+OtHDyAjfDR6UC3dbWLBgHvIluVxbVRU08z6bqtEUtJu6pKWbU1
         5HyV8vWY3x++KD+5sL5kDaBJ0p5pGsXNvNOK3mDutwYZE+T9sm2JCpcNGikgQC5oM1MK
         LWrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukcs++Jrx90a3JnxFfEWYDZ4r5+21E7O1SqcjWQJ85hj3NHFKO8V
	69dzjDqQunOrqdpyhFC8iNnRwqHcesAuO8xSDELhzEpkOihJdfRwKtO4eeAtsis8L4VG1boCL15
	309cawGLs/b/ZM/734u3eM9n+XWdSyxmGH1yeuBgt+acoeMAKtzRT4olo61ll4kACmA==
X-Received: by 2002:a0c:9292:: with SMTP id b18mr31258696qvb.187.1548916922407;
        Wed, 30 Jan 2019 22:42:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5a7GKOkXWiGmQK4AMLMcW2aa4HeTfCMkS1D0GHVRpJJghbcZ+EXCQDiS0661ONsFmBf6th
X-Received: by 2002:a0c:9292:: with SMTP id b18mr31258662qvb.187.1548916921429;
        Wed, 30 Jan 2019 22:42:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548916921; cv=none;
        d=google.com; s=arc-20160816;
        b=nd1oAvKRKznv/R4TWGezgTUDmSRERO3pS4c+zaioJ+2NBwsg4G+FT4voIJ5SfflBeW
         pGVBILAtV/nBeFqg2/E1YXKstm/jyqk/qbLCSBtyRBSQjJD2gQPntk5pCVlsRLCrY6pm
         uIl4SjpvtlDSAJ8G0zTsqvQ8Ozv8yei2LMGJdK9n4WWCQAJV2O5eQ08YgKwowYrQbML8
         vw0ioG6DKyrqTKihG+aB+TQoSRkjfq+BZFr+JteS2Qn6NwX9SWZGxiP3RbZNyamn7uLU
         7Cl7d3gf4SnQOHsaWItw9YM5G/Pyu0iEUlKZQm8cslz+qG+qmEvCxH58UsR3SlJIZb59
         SLJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:subject:cc:to:from:date;
        bh=WXT+cElB+9LMBUwkC5AslWD1LurDKzzfmL5+K4AdmXI=;
        b=Zing/aV0X06vHIwHZBqc69vodOFdsWxZmeZCVq4K/Ag9WK4FRhbnjmrqTP/IsUKMb4
         eOkkP+qDUdgy4xPEClXfLFn+YVr1xjFrwZthDLX4Ug3xpueNZq1cRleTG6mS3W646Ld2
         QhpkFtBDZ/iliB2EjVsUCLuBPzYGAC6PJY/wDalOO8mUZVl0sgVrcKFlygjHV4wRnuDJ
         U7qy98EmlgKK5rwTtR1W6kQTYczTmNkCAEYNvSF2GviP3KGihdsPfuC8yTpe/h3Yl82q
         h8IiDEg6yIuFgPhKa50lHoEeP98yF1iotjquhHeR4+dVvoQDMMqTWMH/YL4vlYZR4uzY
         84Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m68si1415981qkd.120.2019.01.30.22.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 22:42:01 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0V6e5Nr129045
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:42:01 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qbtbkkvks-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:42:00 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 31 Jan 2019 06:41:57 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 06:41:45 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0V6filb25034870
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 06:41:44 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9DDB0A4054;
	Thu, 31 Jan 2019 06:41:44 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6E948A405C;
	Thu, 31 Jan 2019 06:41:41 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 31 Jan 2019 06:41:41 +0000 (GMT)
Date: Thu, 31 Jan 2019 08:41:39 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: linux-mm@kvack.org, Rich Felker <dalias@libc.org>,
        linux-ia64@vger.kernel.org, devicetree@vger.kernel.org,
        Catalin Marinas <catalin.marinas@arm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org,
        linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>,
        Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org,
        linux-c6x-dev@linux-c6x.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org,
        Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>,
        Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org,
        uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>,
        linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org,
        linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org,
        Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>,
        xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>,
        Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org,
        Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
        Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>,
        openrisc@lists.librecores.org, Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v2 19/21] treewide: add checks for the return value of
 memblock_alloc*()
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-20-git-send-email-rppt@linux.ibm.com>
 <b7c12014-14ae-2a38-900c-41fd145307bc@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b7c12014-14ae-2a38-900c-41fd145307bc@c-s.fr>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19013106-0028-0000-0000-00000341269A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013106-0029-0000-0000-000023FF2799
Message-Id: <20190131064139.GB28876@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310052
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 07:07:46AM +0100, Christophe Leroy wrote:
> 
> 
> Le 21/01/2019 à 09:04, Mike Rapoport a écrit :
> >Add check for the return value of memblock_alloc*() functions and call
> >panic() in case of error.
> >The panic message repeats the one used by panicing memblock allocators with
> >adjustment of parameters to include only relevant ones.
> >
> >The replacement was mostly automated with semantic patches like the one
> >below with manual massaging of format strings.
> >
> >@@
> >expression ptr, size, align;
> >@@
> >ptr = memblock_alloc(size, align);
> >+ if (!ptr)
> >+ 	panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
> >size, align);
> >
> >Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> >Reviewed-by: Guo Ren <ren_guo@c-sky.com>             # c-sky
> >Acked-by: Paul Burton <paul.burton@mips.com>	     # MIPS
> >Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # s390
> >Reviewed-by: Juergen Gross <jgross@suse.com>         # Xen
> >---
> 
> [...]
> 
> >diff --git a/mm/sparse.c b/mm/sparse.c
> >index 7ea5dc6..ad94242 100644
> >--- a/mm/sparse.c
> >+++ b/mm/sparse.c
> 
> [...]
> 
> >@@ -425,6 +436,10 @@ static void __init sparse_buffer_init(unsigned long size, int nid)
> >  		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
> >  						__pa(MAX_DMA_ADDRESS),
> >  						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
> >+	if (!sparsemap_buf)
> >+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
> >+		      __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
> >+
> 
> memblock_alloc_try_nid_raw() does not panic (help explicitly says: Does not
> zero allocated memory, does not panic if request cannot be satisfied.).

"Does not panic" does not mean it always succeeds.
 
> Stephen Rothwell reports a boot failure due to this change.

Please see my reply on that thread.

> Christophe
> 
> >  	sparsemap_buf_end = sparsemap_buf + size;
> >  }
> >
> 

-- 
Sincerely yours,
Mike.

