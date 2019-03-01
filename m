Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7995EC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:50:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E57E2085A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:50:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E57E2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D70CA8E0004; Fri,  1 Mar 2019 06:50:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF8098E0001; Fri,  1 Mar 2019 06:50:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9ABE8E0004; Fri,  1 Mar 2019 06:50:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDB38E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 06:50:09 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id d49so21589391qtd.15
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 03:50:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=P1w7ejXANsOjqq7lVFPo9e+0LEi/H3SBMT4g8+7qnWk=;
        b=LQZzteVw8o70jPTZGz7MsuWj44qF4JpDJmnCyIykngojA4x/qJEkZ0IP14ZVZq+fwT
         I+afKChFJDLHTnzM+A2IZG4dvFLBKiGme6igmji4B4qnLX3HoOLfbd4GsfbDeiWWMt5Y
         IZKDh7Q124pVyT3K48kfSssaO3y/JgQ9nAT3d+tQ5KSIlEQDHy3IbAZskylyf5SuqL/I
         T1miOKqr9SIgtqcmrxka4s/6Eh5rsai6JjgeMBgYQ0PFrNkMlmXdSdUpHAP+pB8ds7x9
         2szCbmeuruBKtUC6ObxgGCgwmNvhPqvnCWO1NqsrpfwSmjRzjCUMI88Z51dZdzn0qDAV
         kqJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVAVMcz9qicLoQRjU2ry+Jv5o/UCrEBrMVH5w6Ic3dj+POIiwax
	9yHjGxQd2aq0n8jG7qISGLUL+PxeSMIU5uNrVyPLsb7ncG/SiCdJHWTqyXpL76QMRUD2kjYFvH5
	zbLIWP7cozvTccEWd8L6eg6ULyEddTd/l53Th0PU5CeK8cCwK9BzBrtW9EYfd6bFIug==
X-Received: by 2002:a0c:928a:: with SMTP id b10mr3335146qvb.89.1551441009361;
        Fri, 01 Mar 2019 03:50:09 -0800 (PST)
X-Google-Smtp-Source: APXvYqwXgS6HfBwiNoCssNQukBOZ+RHV29lubtmEnVRVXLsfy7LIE3SEB9qnyZuvQXSD60uaIY1F
X-Received: by 2002:a0c:928a:: with SMTP id b10mr3335118qvb.89.1551441008694;
        Fri, 01 Mar 2019 03:50:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551441008; cv=none;
        d=google.com; s=arc-20160816;
        b=OtjWe2xm72DsLVqL/O8DWZPqU7Je7FsYQ125z3cGTBbMXXLxM46lGhqDUhtaysMHCk
         102TENgPIKZW7xdJwip+l96d6nOurtRHISLbyRJWvyTSJ+cUh2SZ+wfqQKNNFgt651fX
         OLuaalL2FCcJNwqoN0K7JvFD/AfjRc6yegL7GPUjaetoaMAsIyI7fqwgJEThiAFgL5pK
         obTmjcBF8nSDtD3CIH1sJYgGdsnLIcGGTli3suDAtEqbRhj5DDXhMPlx1lfd+sRtQYhd
         lqwuQV8aNo9eJD/Efh9cWDwGMthbBo3vaMNHWyQwiC3YKwAYqTvEfDvAz+uTnQMxR09p
         AmKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=P1w7ejXANsOjqq7lVFPo9e+0LEi/H3SBMT4g8+7qnWk=;
        b=yg3dsFp/ef/bSNBM4N8koek32fm93q2z/3uxalJf4RqpdN7No7Q6F8p17ubmTyGPnm
         PIh7G/2ZkQ4woOfdiUMGkDKKTLFDe4rq0Kqa2vIyTlomS+bRsMjOyPbz5sTfEJTaZYT2
         QI92/fha7pKUg2GQ7d1Eb8sUe8NaD9Drp9sR6zKGq5al4ZNFPOLzaCaATYhaKEchy0QE
         X4tnyxs4fXI0HjMcXkitdtleDxGgzxJFYJlAKrdaSZmwvV1ZeBrwlfXq2q2bmebjc+1o
         ry+ibBJwF+6PSIRIBnDy5VkMngFHu1gpLg7aGvc1H+sRVDlLeFXwHzYuF9orGEgoTt/1
         vhHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z32si5649441qtb.234.2019.03.01.03.50.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 03:50:08 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x21BnRXC008892
	for <linux-mm@kvack.org>; Fri, 1 Mar 2019 06:50:08 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qy3cpjj00-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 01 Mar 2019 06:50:07 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 1 Mar 2019 11:50:05 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 1 Mar 2019 11:49:58 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x21Bnvjh59637792
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 1 Mar 2019 11:49:57 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 988DF4C04E;
	Fri,  1 Mar 2019 11:49:57 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 72BA84C04A;
	Fri,  1 Mar 2019 11:49:55 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.73])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri,  1 Mar 2019 11:49:55 +0000 (GMT)
Date: Fri, 1 Mar 2019 13:49:53 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Steven Price <steven.price@arm.com>, Mark Rutland <Mark.Rutland@arm.com>,
        x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
        Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
        James Morse <james.morse@arm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        "Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
 <20190221142812.oa53lfnnfmsuh6ys@kshutemo-mobl1>
 <a3076d01-41b3-d59b-e98c-a0fd9ba5d3f5@arm.com>
 <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221145706.zqwfdoyiirn3lc7y@kshutemo-mobl1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19030111-0012-0000-0000-000002FBBE8F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030111-0013-0000-0000-000021336E7D
Message-Id: <20190301114953.GD5156@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-01_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903010084
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kirill,

On Thu, Feb 21, 2019 at 05:57:06PM +0300, Kirill A. Shutemov wrote:
> On Thu, Feb 21, 2019 at 02:46:18PM +0000, Steven Price wrote:
> > On 21/02/2019 14:28, Kirill A. Shutemov wrote:
> > > On Thu, Feb 21, 2019 at 11:34:52AM +0000, Steven Price wrote:
> > >> From: James Morse <james.morse@arm.com>
> > >>
> > >> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> > >> we may come across the exotic large mappings that come with large areas
> > >> of contiguous memory (such as the kernel's linear map).
> > >>
> > >> For architectures that don't provide p?d_large() macros, provided a
> > >> does nothing default.
> > > 
> > > Nak, sorry.
> > > 
> > > Power will get broken by the patch. It has pmd_large() inline function,
> > > that will be overwritten by the define from this patch.
> > > 
> > > I believe it requires more ground work on arch side in general.
> > > All architectures that has huge page support has to provide these helpers
> > > (and matching defines) before you can use it in a generic code.
> > 
> > Sorry about that, I had compile tested on power, but obviously not the
> > right config to actually see the breakage.
> 
> I don't think you'll catch it at compile-time. It would silently override
> the helper with always-false.

Can you explain why the compiler would override the helper define in, e.g.
arch/powerpc/include/asm/pgtable.h with the generic (0)?
Actually, I've tried to compile this on power with deliberately adding
errors to both power-specific and the generic definition of pmd_large and
the compilation failed the way I expected in the power-specific helper.
 
> > I'll do some grepping - hopefully this is just a case of exposing the
> > functions/defines that already exist for those architectures.
> 
> I see the same type of breakage on s390 and sparc.
> 
> > Note that in terms of the new page walking code, these new defines are
> > only used when walking a page table without a VMA (which isn't currently
> > done), so architectures which don't use p?d_large currently will work
> > fine with the generic versions. They only need to provide meaningful
> > definitions when switching to use the walk-without-a-VMA functionality.
> 
> How other architectures would know that they need to provide the helpers
> to get walk-without-a-VMA functionality? This looks very fragile to me.
> 
> -- 
>  Kirill A. Shutemov

-- 
Sincerely yours,
Mike.

