Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38CA1C10F03
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:53:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9AC42087E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:53:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9AC42087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 975CD8E0003; Fri,  1 Mar 2019 06:53:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 926768E0001; Fri,  1 Mar 2019 06:53:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 815EB8E0003; Fri,  1 Mar 2019 06:53:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFD28E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 06:53:17 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id n23so3672374plp.23
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 03:53:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=9Up8EvMDCJEj7ynkGctG8fnwe7ark9USZXpO0DY7r70=;
        b=ItVnEu+KBbm1AFlYioCqNWwFcutBl3taqaaJ/mvi/b/kRDY+N44a7tEHVNJFowEFYc
         pj9qabF6wLItQwn2B1IJqvv1P4T7GFTNvV94dj797fEVRcQRgrPj8Z8+/RA/SQk1Snxo
         p8H9WHO06Rt8tLGqqVXknTaJ0HnINZgQi6BS0IoDh8K/TcEjWvmPa40pwBqeYEQjuhK9
         Uz4SMLli9qpTWdSj7fPeP8klNVSbdAPN+EUeHmGjU+iDwjLwrvGalcrK/1AQ9R3nj/eX
         nMNpqrOs+E9Fo805ORplHWHz/EJbeIMunGA/EhCKeeLxcK/EJ439qTp3MR9MrpWAMlVu
         sUPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU4nxHmD8+F9YiujyijcSKhrhtGefd1qOljiWfy2dUwI2bsyg65
	4ZLLgSpWXxdxY6/H6KbN/EPe8CMCzJZRaze3I6Kg8AIaqPJwTSQvf2lKYn5kohu1DPkOrWC7XFP
	663OsqrLM6L4iI2KRWAPQeDjkPyANu8vLbBHgVabUEspu5Uw0YhZ+WqTbx9JIS9JaJQ==
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr5089894plb.110.1551441196916;
        Fri, 01 Mar 2019 03:53:16 -0800 (PST)
X-Google-Smtp-Source: APXvYqw6qDUuo8avCX2hOF+vNt+vQ5w578mokwB7X7ysudbKcIXn4lVg7VZqIpfzVLvtV3ULyBwN
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr5089853plb.110.1551441196119;
        Fri, 01 Mar 2019 03:53:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551441196; cv=none;
        d=google.com; s=arc-20160816;
        b=aTQ2ce4X5YfljAkMU2GJGvLoY+95IqOXpmg8ozMKeGLTlHfFzUWsl6whN1WaixWb7h
         aKfU1T3SKrXhUDP4TrIo8e4EWh17HUsJngRBkLzW4ksyRQLz0uMqoifu2waYRONq4SeE
         gI5bFyyNfmhs2wP2KwF3cC6I1NhagfLx+4E7Dd11Kjuws8fBy+Au7scrzIpf1nMfySiI
         85CAYtta0+ISi+IZMe1t82xRzFVAyS9ULfOh47nBxFmIppmxHI/eOPkIrYpbD2R1uVAA
         XpMwJAGiJQ8HSP9JSh8/fuGx6sKLoURY0KhMgTrP4TurEeXaGqDueZxhBC1+8TOPqx89
         YqNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=9Up8EvMDCJEj7ynkGctG8fnwe7ark9USZXpO0DY7r70=;
        b=A+lAvhrDyfWflMNjZKhp1Y5jfFb519mhPBc0xJ/2xNXtX22c+FjBwIAgCdm5mTg4N8
         nqaam3BnCAawZuc79MuvoGgwwmi4U442urcviqqnIxQ+h7ilUCSaYKor5S2NakIFqlpl
         9OjA1A9tYNSW/ZrjYUiOaFekGDW59Np1YWPwGlirpoGIoYTsK+D58au+uHg/SLJL8kvO
         AEZJ7RXrthBOuIaWpURU1U+2dMEcdjqZfaDna3g+DtWbF0/MW8q9wlGQBQyvq2UM/hbL
         DxrJkZ8RoxsRRx3u9G96UeqPhNBkukDV/kT9Zw2b5TL80j5VKZGwOgeQg6cBbtMFJnF+
         VamQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h12si14928460pgl.277.2019.03.01.03.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 03:53:16 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x21BnX1W090668
	for <linux-mm@kvack.org>; Fri, 1 Mar 2019 06:53:15 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qy3q5hj9e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 01 Mar 2019 06:53:15 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 1 Mar 2019 11:53:12 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 1 Mar 2019 11:53:06 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x21Br55c31522890
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 1 Mar 2019 11:53:05 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 41070A404D;
	Fri,  1 Mar 2019 11:53:05 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 127F4A4040;
	Fri,  1 Mar 2019 11:53:03 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.73])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri,  1 Mar 2019 11:53:02 +0000 (GMT)
Date: Fri, 1 Mar 2019 13:53:01 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Steven Price <steven.price@arm.com>, Mark Rutland <Mark.Rutland@arm.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221210618.voyfs5cnafpvgedh@kshutemo-mobl1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19030111-0016-0000-0000-0000025C7989
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030111-0017-0000-0000-000032B6ED0A
Message-Id: <20190301115300.GE5156@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-01_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=936 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903010084
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Him Kirill,

On Fri, Feb 22, 2019 at 12:06:18AM +0300, Kirill A. Shutemov wrote:
> On Thu, Feb 21, 2019 at 05:16:46PM +0000, Steven Price wrote:
> > >> Note that in terms of the new page walking code, these new defines are
> > >> only used when walking a page table without a VMA (which isn't currently
> > >> done), so architectures which don't use p?d_large currently will work
> > >> fine with the generic versions. They only need to provide meaningful
> > >> definitions when switching to use the walk-without-a-VMA functionality.
> > > 
> > > How other architectures would know that they need to provide the helpers
> > > to get walk-without-a-VMA functionality? This looks very fragile to me.
> > 
> > Yes, you've got a good point there. This would apply to the p?d_large
> > macros as well - any arch which (inadvertently) uses the generic version
> > is likely to be fragile/broken.
> > 
> > I think probably the best option here is to scrap the generic versions
> > altogether and simply introduce a ARCH_HAS_PXD_LARGE config option which
> > would enable the new functionality to those arches that opt-in. Do you
> > think this would be less fragile?
> 
> These helpers are useful beyond pagewalker.
> 
> Can we actually do some grinding and make *all* archs to provide correct
> helpers? Yes, it's tedious, but not that bad.

Many architectures simply cannot support non-leaf entries at the higher
levels. I think letting the use a generic helper actually does make sense.
 
> I think we could provide generic helpers for folded levels in
> <asm-generic/pgtable-nop?d.h> and rest has to be provided by the arch.
> Architectures that support only 2 level paging would need to provide
> pgd_large(), with 3 -- pmd_large() and so on.
> 
> -- 
>  Kirill A. Shutemov

-- 
Sincerely yours,
Mike.

