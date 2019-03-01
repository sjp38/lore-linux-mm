Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B101C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:46:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AB532083E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:46:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AB532083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B01248E0004; Fri,  1 Mar 2019 06:46:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB0EB8E0001; Fri,  1 Mar 2019 06:46:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A0E78E0004; Fri,  1 Mar 2019 06:46:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B17E8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 06:46:15 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h70so18692488pfd.11
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 03:46:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=TWXh/f/vxZucfd0azlrPKeVIpV2c4umlgI75dWBLNVQ=;
        b=tH8Qx312P3slg/1PpIQlCsW5SnY6emEOCMM0oUvcUCIzfwZWxMe8NE84e0AcCotHVH
         LUOHU4nqz0bjFLpF1uOQyAE+duksLW3tfS6N6bFAy1pXyEfIrbEEXmJol56cPYyZLFaj
         Us3dZRX+ruXEgIDKpUHn/tRUfu5Ip/3hAflV6VxWKezlMe9O23S7If2tVtQcDnplqErs
         8J8w3uq2ZsLkah+h3sh7mL6I11g8HHaNQaOQRwV1oDiPq76wv3MgeZcOz9Szwkz5LDlB
         TPSpuQpdlGQICfl5E9NePj6H1Fonq3k3N368onAgOlVU0MpwjwBRxU/ZPnuiurl9rxtV
         WZLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXR3FQnRX4WAcEyZ0GlQZa/NCApA20YEpvZAc3VqdlCtrLKnv5F
	YfjotwlCVPOHq0JCD6w3Z1ynG7YXmpB3Tmp6jdiCUogYJ50KDvYE7SEmrqqb7a5TaFEI+q8GkMN
	ps70l/gmPgD2ti5Ac8ij7nZNzivbACCswddK8AtS4LS58hKkJ8qqSS7S93uaLapSMFw==
X-Received: by 2002:a17:902:31c3:: with SMTP id x61mr4939807plb.113.1551440775038;
        Fri, 01 Mar 2019 03:46:15 -0800 (PST)
X-Google-Smtp-Source: APXvYqyXaz/ydQ7aoOCbU0xemUF0oblPLOYF4ZRRn11xVaM2VaCNQ+abXnBHf3/1xTLZWCfzqp8b
X-Received: by 2002:a17:902:31c3:: with SMTP id x61mr4939754plb.113.1551440774088;
        Fri, 01 Mar 2019 03:46:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551440774; cv=none;
        d=google.com; s=arc-20160816;
        b=q9v/32TWF7Dqna84WC7n11LJEQMjJme52VsyMBL3kcgcVAEjKZFS1xV3IzSmAGFsGf
         PPcF494xupytdu4XzTc9IQzFjTSh5tQc+fM8NQzZvXRPDqbRjaW3P1j7ibhi2w6d9rbH
         sV0kELLPkB7Ukikzg8ICUdiJh16G5VJYaHTSPOCOdTCq+dQammZLN+dOqKd93gw50hg6
         D9pPXyOpiKT/+P4fDgdYe9NPSQN015jSPS9uYNENeAVi6OeaJYROUuUCG3sGx+h/HUPm
         uk6UrZlmXeUc0o6RS75wHlfP3VXzJL+/h68ffmMwKXPaxCSXZGThgY9P9C9LTyb+DNaL
         dQlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=TWXh/f/vxZucfd0azlrPKeVIpV2c4umlgI75dWBLNVQ=;
        b=PTMMZ0mEmOMALYceDTy+iEEtDE3NegX2ilZhz+uKrF20z+vbe2nAoR+PRVw8Mj0XR/
         A0XG4zFD4Tpak3sUBI58Dt9f0H4uUcchLrxj5ol+tAWOh+LCWtWjGU2fHF4kz1hMdoXZ
         rlR9i1SqztPkcaU8p6FMdGSoCrsAFKeq7NbKyGTZxCyql+NzjMBDSEQgPeRyMl2qc3GG
         HzMrfjHlTQNvJ5oun2sSVLWEXASJisEByNbNRNJb60ZCgrPAHXG/R6IZ8WQmXm9Xe05q
         D7UKw3XPf4rEElgJBzuG56B9uGozL/CzjVY5LySCez2opWjjL4jtme2yBe80Dl5VP9m2
         qzEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e127si10242415pgc.360.2019.03.01.03.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 03:46:14 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x21Bi1NS024078
	for <linux-mm@kvack.org>; Fri, 1 Mar 2019 06:46:13 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qy2ajwq4r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 01 Mar 2019 06:46:13 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 1 Mar 2019 11:46:10 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 1 Mar 2019 11:46:03 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x21Bk2Cb32505906
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 1 Mar 2019 11:46:02 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4E71CA404D;
	Fri,  1 Mar 2019 11:46:02 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B5AB8A4051;
	Fri,  1 Mar 2019 11:45:57 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.73])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri,  1 Mar 2019 11:45:57 +0000 (GMT)
Date: Fri, 1 Mar 2019 13:45:54 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Steven Price <steven.price@arm.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Mark Rutland <Mark.Rutland@arm.com>,
        the arch/x86 maintainers <x86@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Will Deacon <will.deacon@arm.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
        Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
        James Morse <james.morse@arm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-m68k <linux-m68k@lists.linux-m68k.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v3 09/34] m68k: mm: Add p?d_large() definitions
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-10-steven.price@arm.com>
 <CAMuHMdXCjuurBiFzQBeLPUFu=mmSowvb=37XyWmF_=xVhkQm4g@mail.gmail.com>
 <20190228113653.GB3766@rapoport-lnx>
 <CAMuHMdU5gn6ftAHNwHNPDoUy_JvcZLcXbkk1hvUmYxtfJRfTTQ@mail.gmail.com>
 <a17f5ad7-9fba-9d51-4d6e-7a9effe81e4e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a17f5ad7-9fba-9d51-4d6e-7a9effe81e4e@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19030111-0012-0000-0000-000002FBBE46
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030111-0013-0000-0000-000021336E2C
Message-Id: <20190301114553.GC5156@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-01_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903010083
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 12:04:08PM +0000, Steven Price wrote:
> On 28/02/2019 11:53, Geert Uytterhoeven wrote:
> > Hi Mike,
> > 
> > On Thu, Feb 28, 2019 at 12:37 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >> On Wed, Feb 27, 2019 at 08:27:40PM +0100, Geert Uytterhoeven wrote:
> >>> On Wed, Feb 27, 2019 at 6:07 PM Steven Price <steven.price@arm.com> wrote:
> >>>> walk_page_range() is going to be allowed to walk page tables other than
> >>>> those of user space. For this it needs to know when it has reached a
> >>>> 'leaf' entry in the page tables. This information is provided by the
> >>>> p?d_large() functions/macros.
> >>>>
> >>>> For m68k, we don't support large pages, so add stubs returning 0
> >>>>
> >>>> CC: Geert Uytterhoeven <geert@linux-m68k.org>
> >>>> CC: linux-m68k@lists.linux-m68k.org
> >>>> Signed-off-by: Steven Price <steven.price@arm.com>
> >>>
> >>> Thanks for your patch!
> >>>
> >>>>  arch/m68k/include/asm/mcf_pgtable.h      | 2 ++
> >>>>  arch/m68k/include/asm/motorola_pgtable.h | 2 ++
> >>>>  arch/m68k/include/asm/pgtable_no.h       | 1 +
> >>>>  arch/m68k/include/asm/sun3_pgtable.h     | 2 ++
> >>>>  4 files changed, 7 insertions(+)
> >>>
> >> Maybe I'm missing something, but why the stubs have to be defined in
> >> arch/*/include/asm/pgtable.h rather than in include/asm-generic/pgtable.h?
> > 
> > That would even make more sense, given most architectures don't
> > support huge pages.
> 
> Where the architecture has folded a level stubs are provided by the
> asm-generic layer, see this later patch:
> 
> https://lore.kernel.org/lkml/20190227170608.27963-25-steven.price@arm.com/
> 
> However just because an architecture port doesn't (currently) support
> huge pages doesn't mean that the architecture itself can't have large[1]
> mappings at higher levels of the page table. For instance an
> architecture might use large pages for the linear map but not support
> huge page mappings for user space.

Well, I doubt m68k can support large mappings at higher levels at all.
This, IMHO, applies to many other architectures and spreading p?d_large all
over those architecture seems wrong to me...

> My previous posting of this series attempted to define generic versions
> of p?d_large(), but it was pointed out to me that this was fragile and
> having a way of knowing whether the page table was a 'leaf' is actually
> useful, so I've attempted to implement for all architectures. See the
> discussion here:
> https://lore.kernel.org/lkml/20190221113502.54153-1-steven.price@arm.com/T/#mf0bd0155f185a19681b48a288be212ed1596e85d

I'll reply on that thread, somehow I missed it then.
 
> Steve
> 

-- 
Sincerely yours,
Mike.

