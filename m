Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4291C04AAC
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 08:53:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 475C72087F
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 08:53:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 475C72087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A69B36B0003; Sun,  5 May 2019 04:53:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A19496B0006; Sun,  5 May 2019 04:53:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E1326B0007; Sun,  5 May 2019 04:53:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 540FE6B0003
	for <linux-mm@kvack.org>; Sun,  5 May 2019 04:53:35 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j36so1388781pgb.20
        for <linux-mm@kvack.org>; Sun, 05 May 2019 01:53:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=/9jWs+EL2eMaqycQ3ZsXnIbDyIIHw5RHs1wWK0ePNfk=;
        b=a5nLKqGvPVZ6yjpSVm1L6vBziSUELEPmNEd0FQA5hpzNkR2Ygo3iTCxqyuMHYCH+IF
         Dm2E5/tLn0Je4IKIXTZzOPBAuWDxQpKIWcdS0ELD408syr27T56mAvslFTegBbNWO3H1
         uaSWJ/xuNRDNk7pK8xLD4jUaHwCRz+oF7d0HCnNKWjPyheGwdBDbhiZXMiQX4Nh/jXjX
         dCHUjBt3bewSnH6KGTUgmXFCM252Rf0rDOl1PLFY8jpYcjsnexoZZi0YMl4wad3xyF9b
         sSZDWslxX0WCfe736OzXD8In8j/jJVdpjiM4rmXxqheLqsCASHPnS/FVMpaDZxhbx2pX
         12RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVyKyeRSjZY608IUQZEVUeth5L/9zdrbnTHQ13QMFwb1kN+Znly
	0hJXVoc+zX1zEGPZxWbioGK4cvlTVNIcAKJyCZCOwJ90t6U8l4kQXiPWbMM9y/FrD9R3ujL4klK
	xF+7akIlkOzuP4p/gcO8PWBYdjwzvpPobR8UolgcvNUFWw2RPKUcgvlC3DvXLtNak1w==
X-Received: by 2002:a63:e004:: with SMTP id e4mr23731260pgh.344.1557046414864;
        Sun, 05 May 2019 01:53:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybrMJsKIWMnlheF6NVey0di/HnFg1MXXAYscGh+B1Vx1APobEk4gMzi/fwXdtUbfY/RTdj
X-Received: by 2002:a63:e004:: with SMTP id e4mr23731214pgh.344.1557046413908;
        Sun, 05 May 2019 01:53:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557046413; cv=none;
        d=google.com; s=arc-20160816;
        b=PrOUoz46zFSdMNvfb85JVDCACx8tZv1uFPcE8vrq54lELirxnVeSzDK/4s7G3RBKki
         r5JyAjqP+7vxlk0dJ2OXszPgC/sSIcwx9xMJQ0EYCiCuxUcSLEUsjPWzlT9qz5N6hj6t
         ox5NtpqiXKw5JFGQ7UjRYnhEIFlZ6S/LvgZwGWka/D+1TR4m6BGWv/FLyUO6Uz9BX2Hn
         bTGLHHr4Mxw1Hf0aKJrK/ijall3a2KJnNdAHT7Fo1OKsqVWAZ6+2ZY4UIIoTdU5KLjhg
         wH88KKdJZNCSrfFFgF56rZMZU0c15fe7bqNQX9eXd2naI1bNzUeDs4uo5XD5nlUsP4Ce
         Eifg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=/9jWs+EL2eMaqycQ3ZsXnIbDyIIHw5RHs1wWK0ePNfk=;
        b=WQ6McgbliZRWAgAgTsiv3WByG5sLF7jdyLZj1xDtfTUx5RY3HFMiuhAyBXug0JIfK1
         fxZGrS06XSnubjaAwH55wVN0DqkNI+c5kCM/Ai7hpiGMkMPw9mPcDIqmV4o8qs+LSWdg
         aFiWmuLPS6wEVbJcKEXAEjmO7+6FbZmn0xHsyq/a41mQHsN6PE+mRu8nbgwyy+QFLh8U
         goYhrzIXSmRp5KYcCLRMP/o2DgY1zkyAmaUGbP/KrSQfcRwmjhP9/rtzV77rcxfWMFcA
         fuHEPdcGoKjp860HtttgPsJf1Kvgbd2a76zmfnSacSrsWYd/WVBUq2KAAQuoU5kM8OX9
         mZVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id cm10si8309544plb.124.2019.05.05.01.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 May 2019 01:53:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x458qARE041359
	for <linux-mm@kvack.org>; Sun, 5 May 2019 04:53:32 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s9r8bqcjc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 05 May 2019 04:53:32 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 5 May 2019 09:53:29 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 5 May 2019 09:53:26 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x458rPKe63242432
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 5 May 2019 08:53:25 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7928852052;
	Sun,  5 May 2019 08:53:25 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 9E0295204F;
	Sun,  5 May 2019 08:53:24 +0000 (GMT)
Date: Sun, 5 May 2019 11:53:23 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Helge Deller <deller@gmx.de>
Cc: Mel Gorman <mgorman@techsingularity.net>,
        Matthew Wilcox <willy@infradead.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mikulas Patocka <mpatocka@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        linux-parisc@vger.kernel.org, linux-mm@kvack.org,
        Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
        linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <20190419142835.GM18914@techsingularity.net>
 <9e7b80a9-b90e-ac04-8b30-b2f285cd4432@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e7b80a9-b90e-ac04-8b30-b2f285cd4432@gmx.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19050508-0012-0000-0000-0000031878B9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050508-0013-0000-0000-00002150EEE3
Message-Id: <20190505085322.GH15755@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-05_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=793 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905050080
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Apr 19, 2019 at 10:08:31PM +0200, Helge Deller wrote:
> On 19.04.19 16:28, Mel Gorman wrote:
> > On Fri, Apr 19, 2019 at 07:05:21AM -0700, Matthew Wilcox wrote:
> >> On Fri, Apr 19, 2019 at 10:43:35AM +0100, Mel Gorman wrote:
> >>> DISCONTIG is essentially deprecated and even parisc plans to move to
> >>> SPARSEMEM so there is no need to be fancy, this patch simply disables
> >>> watermark boosting by default on DISCONTIGMEM.
> >>
> >> I don't think parisc is the only arch which uses DISCONTIGMEM for !NUMA
> >> scenarios.  Grepping the arch/ directories shows:
> >>
> >> alpha (does support NUMA, but also non-NUMA DISCONTIGMEM)
> >> arc (for supporting more than 1GB of memory)
> >> ia64 (looks complicated ...)
> >> m68k (for multiple chunks of memory)
> >> mips (does support NUMA but also non-NUMA)
> >> parisc (both NUMA and non-NUMA)
> >>
> >> I'm not sure that these architecture maintainers even know that DISCONTIGMEM
> >> is deprecated.  Adding linux-arch to the cc.
> >
> > Poor wording then -- yes, DISCONTIGMEM is still used but look where it's
> > used. I find it impossible to believe that any new arch would support
> > DISCONTIGMEM or that DISCONTIGMEM would be selected when SPARSEMEM is
> > available.`It's even more insane when you consider that SPARSEMEM can be
> > extended to support VMEMMAP so that it has similar overhead to FLATMEM
> > when mapping pfns to struct pages and vice-versa.
> 
> FYI, on parisc we will switch from DISCONTIGMEM to SPARSEMEM with kernel 5.2.
> The patch was quite simple and it's currently in the for-next tree:
> https://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux.git/commit/?h=for-next&id=281b718721a5e78288271d632731cea9697749f7

A while ago I've sent a patch that removes ARCH_DISCARD_MEMBLOCK option [1]
so the hunk below is not needed:

diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index c8038165b81f..26c215570adf 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -36,6 +36,7 @@ config PARISC
 	select GENERIC_STRNCPY_FROM_USER
 	select SYSCTL_ARCH_UNALIGN_ALLOW
 	select SYSCTL_EXCEPTION_TRACE
+	select ARCH_DISCARD_MEMBLOCK
 	select HAVE_MOD_ARCH_SPECIFIC
 	select VIRT_TO_BUS
 	select MODULES_USE_ELF_RELA


[1] https://lore.kernel.org/lkml/1556102150-32517-1-git-send-email-rppt@linux.ibm.com/
 
> Helge
> 

-- 
Sincerely yours,
Mike.

