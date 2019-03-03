Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6653FC10F00
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 07:13:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFCE020857
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 07:13:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFCE020857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55BC68E0006; Sun,  3 Mar 2019 02:13:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50B018E0001; Sun,  3 Mar 2019 02:13:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FA248E0006; Sun,  3 Mar 2019 02:13:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 148338E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 02:13:09 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id 200so1361901ywe.11
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 23:13:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=lpOhPd1RktVOeonh2YY/z17sxLZUBBx8DuZxi/YnZI4=;
        b=SYt2cjf7kNPgQRP2xuiuXqpxlnxBKfCJ3vHDKztmte1y08P+AbUaNAjLOdlEdtwvHS
         iCwjTwMHWDwjssPjKggkbb4+HIOiuT27+DXYs1xTFd8WBOfm2leJ2o7FuOsqIwY3EOmz
         NKIO8Li2NC4sR06DcvR8Y7hpj6xGgpi1c1C67gdPDUeQq5trJdTINESXdFPUJ3UdiL7C
         oczSI/NRPBHDebA7+UdhuorzNgGBr/raYflKCIVumVESSTsBPcG9iCL3ceeXWMhrwRdt
         jU4ycA7mB0nlbd9DgjZtsNdL6GG9pKLeUo0ChX9i+IYiUdl0Z2oSrSLtid4o0oNqW8nr
         GL9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVpChYny2JTevmveXAHc3lbIGL0VANMwPpvzPoGxF3OKW6huMcq
	P4yaoSmn3l2VeWzCyCjtvfrdd74esB2ZRCtQJQzLXDOhzDTC9au5UWGt6MivlnP+S6i83aWckG1
	eLEkBjnUgbk47ncZv5NAiwT1Lp+2bkL9s2FmkzAxKDw6lAesyseJLul3agusS4iPaOA==
X-Received: by 2002:a81:7084:: with SMTP id l126mr9405736ywc.203.1551597188798;
        Sat, 02 Mar 2019 23:13:08 -0800 (PST)
X-Google-Smtp-Source: APXvYqwrVBx93UiaVcAWoIqOSzBc3dBNVB1yMvgU4WEgeuM7u5LH1Bjo7zSqTEkqJDxz8HIuOOcp
X-Received: by 2002:a81:7084:: with SMTP id l126mr9405696ywc.203.1551597187661;
        Sat, 02 Mar 2019 23:13:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551597187; cv=none;
        d=google.com; s=arc-20160816;
        b=lbAbDFvyeTsr1oQEU1xP+b3kgleu7HveyDOHgd9sasQT39baMKyQN0YKeUrR82ZIiI
         sahJr3Q0B2bVWpZDqRAFrpeflu+aXl40txR5dsowoqOP32KQIo83sj8JjtBuwhC6oZ2/
         9BVQjMlhu+b7NBqrX5VqiRSA6523/1jBlO/fREZRpbV4+eu0uv2kRic7iaSBz5wS8nqG
         cBUnKEg/+rXV5bFwtZq0p+POYzMGKpq19rpu3GAz0n1C5SPHewW6skqDZmVrv69Ibz16
         rfR9eKDawz3rD1lVMYslVCPQx6J7fUByrTENdNlSl1vdlY5vYnTkIuRC9QHLkhjxLpOX
         0wVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=lpOhPd1RktVOeonh2YY/z17sxLZUBBx8DuZxi/YnZI4=;
        b=Fg08RTuyakDvkZWORelk2xkYIu+egTcLMDxMl/xC6LVFzNvMzt0kyLchI6QKtXXP6X
         a4JF+Kef58U1/1bWHHfTn/ea1IQ4Ut0K/iy/1JB+Clie5gOpVIA/3mYx0XCYRgWYHw74
         ie6RKNS3db6achZey9tpN/2CabCussxps7hkwyBuJGYFuesCngK9rNyCcFnD3Ba7JwkP
         Syd/MCY8RwpL8h267788qZsFooN8NIielgsEYEAaGcanBpEFxpYXyxoGO5hcfLyNFAtq
         J5qRNNcxGS4SiD9811DUAZ3vxNxNgx/iZtUF+ZJy+lyITnZWOd1czjZljXW1MeKCSBiy
         tkmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p140si1619503ywe.202.2019.03.02.23.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 23:13:07 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2374sGR003771
	for <linux-mm@kvack.org>; Sun, 3 Mar 2019 02:13:06 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r07m5mh9h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 03 Mar 2019 02:13:06 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 3 Mar 2019 07:13:03 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 3 Mar 2019 07:12:57 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x237CuQi32702716
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Sun, 3 Mar 2019 07:12:56 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BFB4CA4055;
	Sun,  3 Mar 2019 07:12:56 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 484ECA4040;
	Sun,  3 Mar 2019 07:12:55 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun,  3 Mar 2019 07:12:55 +0000 (GMT)
Date: Sun, 3 Mar 2019 09:12:53 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Steven Price <steven.price@arm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
        Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
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
 <e0c7fc0c-7924-1106-a7a3-fc12136b7b82@arm.com>
 <20190221210618.voyfs5cnafpvgedh@kshutemo-mobl1>
 <20190301115300.GE5156@rapoport-lnx>
 <20190301123031.rw3dswcoaa2x7haq@kshutemo-mobl1>
 <b8bd0f99-1c5e-7cf5-32dd-ab52d921e86c@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b8bd0f99-1c5e-7cf5-32dd-ab52d921e86c@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19030307-4275-0000-0000-000003161E33
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030307-4276-0000-0000-000038246B23
Message-Id: <20190303071253.GA7585@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-03_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903030057
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 01, 2019 at 01:39:30PM +0000, Steven Price wrote:
> On 01/03/2019 12:30, Kirill A. Shutemov wrote:
> > On Fri, Mar 01, 2019 at 01:53:01PM +0200, Mike Rapoport wrote:
> >> Him Kirill,
> >>
> >> On Fri, Feb 22, 2019 at 12:06:18AM +0300, Kirill A. Shutemov wrote:
> >>> On Thu, Feb 21, 2019 at 05:16:46PM +0000, Steven Price wrote:
> >>>>>> Note that in terms of the new page walking code, these new defines are
> >>>>>> only used when walking a page table without a VMA (which isn't currently
> >>>>>> done), so architectures which don't use p?d_large currently will work
> >>>>>> fine with the generic versions. They only need to provide meaningful
> >>>>>> definitions when switching to use the walk-without-a-VMA functionality.
> >>>>>
> >>>>> How other architectures would know that they need to provide the helpers
> >>>>> to get walk-without-a-VMA functionality? This looks very fragile to me.
> >>>>
> >>>> Yes, you've got a good point there. This would apply to the p?d_large
> >>>> macros as well - any arch which (inadvertently) uses the generic version
> >>>> is likely to be fragile/broken.
> >>>>
> >>>> I think probably the best option here is to scrap the generic versions
> >>>> altogether and simply introduce a ARCH_HAS_PXD_LARGE config option which
> >>>> would enable the new functionality to those arches that opt-in. Do you
> >>>> think this would be less fragile?
> >>>
> >>> These helpers are useful beyond pagewalker.
> >>>
> >>> Can we actually do some grinding and make *all* archs to provide correct
> >>> helpers? Yes, it's tedious, but not that bad.
> >>
> >> Many architectures simply cannot support non-leaf entries at the higher
> >> levels. I think letting the use a generic helper actually does make sense.
> > 
> > I disagree.
> > 
> > It's makes sense if the level doesn't exists on the arch.
> 
> This is what patch 24 [1] of the series does - if the level doesn't
> exist then appropriate stubs are provided.
> 
> > But if the level exists, it will be less frugile to ask the arch to
> > provide the helper. Even if it is dummy always-false.
> 
> The problem (as I see it), is we need a reliable set of p?d_large()
> implementations to be able to walk arbitrary page tables. Either the
> entire functionality of walking page tables without a VMA has to be an
> opt-in per architecture, or we need to mandate that every architecture
> provide these implementations.

I agree that we need a reliable set of p?d_large(), but I'm still not
convinced that every architecture should provide these.

Why having generic versions if p?d_large() is more fragile, than e.g.
p??__access_permitted() or atomic ops?

IMHO, adding those functions/macros for architectures that support large
pages and providing defines to avoid override of 'static inline' implementations
would be robust enough and will avoid unnecessary stubs in architectures
that don't have large pages.
 
> I could provide an asm-generic header to provide a complete set of dummy
> implementations for architectures that don't support large pages at all,
> but that seems a bit overkill when most architectures only need to
> define 2 or 3 implementations (the rest being provided by the
> folded-levels automatically).
> 
> Thanks,
> 
> Steve
> 
> [1]
> https://lore.kernel.org/lkml/20190227170608.27963-25-steven.price@arm.com/

-- 
Sincerely yours,
Mike.

