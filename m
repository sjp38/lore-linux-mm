Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF8A3C73C66
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 17:11:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60AC8205F4
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 17:11:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60AC8205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8FF26B0003; Sun, 14 Jul 2019 13:11:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1A2A6B0006; Sun, 14 Jul 2019 13:11:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86B0F6B0007; Sun, 14 Jul 2019 13:11:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 622B96B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 13:11:44 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id p20so12164235yba.17
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 10:11:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=LXYhoAzIAko0pjuEZO6mefKeBSfRy4BP1eDO9GE2VDw=;
        b=Mxup7Qerg3rolPyjM6Z7gyIdpYtZaobYxrzq4Jie+XAPU+fzVVi7WXq4K6XOzAgA0l
         58QK0epICX9hZTeKoIns51FAKzGDzoaFxQDnoPpQY78Tl9GEZmMURYyxmtsyxkV9ABOH
         +os/T3A2WY69JuXAi3mV+vdakGjB5VtPKrpNfOBAC3bEk6h+WmHNWbIPBIk0C6+H6ov1
         UNpDKuqc8Gy2KKpbzLsmo0pFguOph40Er1L7zm7ROcxhLnz4IaAbBKe1RGTwEKAOZqQR
         fB4bStAz+e8cP82EZp2P3r37BTkMfDKgwhr/vZ8B13gG8ra7lWjl9foK1aupDo0dXS8c
         nFTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW1fcf5OnkUO5yKH6s3Ls236Xz3u2oqE0uW67djc+ClePrXysPN
	mhtXVLlT8ltulFAmnduS8EoxHsLq21bF7vtmqsgwRzJIVLoPgq62MsjmYo/MPBQxYguWFjT3nS2
	Wfc2sgvXXstyZY3+54qL/9b1X5PmaJzOiwqUe7qrYuMQcna2NMg7FteG+q+scnDBWEQ==
X-Received: by 2002:a81:6a05:: with SMTP id f5mr13594853ywc.368.1563124304068;
        Sun, 14 Jul 2019 10:11:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztag7AX75rfBaw6YYICwTWCH7dkI+w72awWgCTBJGUazqCE1kiv9SgF0GFkaSzb7Eiw6GV
X-Received: by 2002:a81:6a05:: with SMTP id f5mr13594809ywc.368.1563124303186;
        Sun, 14 Jul 2019 10:11:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563124303; cv=none;
        d=google.com; s=arc-20160816;
        b=wpdrkeWC7rXLbr4Q0Ped8OfdmzPYgb5XMtnnGaNxsy2k6N0MixfAEHpG6/5Y7Ec+qj
         zN0lLRb7q8iodO6QKMSbPh/IVAauAtB8KH+CXNTPJMMYdeDMxL5IGIRumW+9PVpBP6C1
         Kz/Yy5j+nXZ5UEyUZX/45zVxNDCUTiA24kvL9mhHaxjm9hqERwOFBFFMVXEWvnRNBK1N
         +eLG6DwHreYfSVHVtK25Uz9W2FxUHlFFY8+nLmbKKGLQC4NgIiq8MIAFn2Zs3ipbd25K
         5MXBFyycAVIg8CuDxngNv8u5GIeEDF/+tjkKp56Nam94QT9Mak2sJ2cF3DYXstM3GKIZ
         eOPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:subject:cc:to:from:date;
        bh=LXYhoAzIAko0pjuEZO6mefKeBSfRy4BP1eDO9GE2VDw=;
        b=VZmMiERONGhmr9IW5C3cu7UZ4rzTviiVPKsVE6kKRf6Cvt/X7/XVFPmj1l4IdSlE6j
         q+kEPhiSxOuvZVJS3OksVBhWFkgaSa1ooQq+aps+lYRcrsE4BWOmj7UPW5u2TAQjbxua
         XJNSI+AnstRsE8Te4e9gL7Zk1nrY1gzxU6VY2QBr5i8QsCPYjN0deF4X8E8QWc5KN5A8
         47wDVzvk+hVL5HnSODX1jFT3/CqdVz9cTM+c6N2KP0ZN6I/R5bspWONtkkmgj+2F1ObP
         ncW4ezh9dU14jOfieuBhA9ERcdAn/AIwzYR10JVyiFemSQWfEG7ev2uaPPFC430HlMKP
         2dGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h83si3060725ybh.36.2019.07.14.10.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 10:11:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6EH6lu6054178
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 13:11:42 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tr7qnsbpu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 13:11:42 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 14 Jul 2019 18:11:40 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 14 Jul 2019 18:11:34 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6EHBXm638994046
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 14 Jul 2019 17:11:33 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3AE1211C052;
	Sun, 14 Jul 2019 17:11:33 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 22C2C11C04C;
	Sun, 14 Jul 2019 17:11:31 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.136])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun, 14 Jul 2019 17:11:31 +0000 (GMT)
Date: Sun, 14 Jul 2019 20:11:29 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Peter Zijlstra <peterz@infradead.org>,
        Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com,
        rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
        x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
        liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
        rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de>
 <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
 <7FDF08CB-A429-441B-872D-FAE7293858F5@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7FDF08CB-A429-441B-872D-FAE7293858F5@amacapital.net>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19071417-0008-0000-0000-000002FD2B05
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071417-0009-0000-0000-0000226A9A79
Message-Id: <20190714171127.GA15645@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-14_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907140213
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 10:45:06AM -0600, Andy Lutomirski wrote:
> 
> 
> > On Jul 12, 2019, at 10:37 AM, Alexandre Chartre <alexandre.chartre@oracle.com> wrote:
> > 
> > 
> > 
> >> On 7/12/19 5:16 PM, Thomas Gleixner wrote:
> >>> On Fri, 12 Jul 2019, Peter Zijlstra wrote:
> >>>> On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:
> >>>> 
> >>>> I think that's precisely what makes ASI and PTI different and independent.
> >>>> PTI is just about switching between userland and kernel page-tables, while
> >>>> ASI is about switching page-table inside the kernel. You can have ASI without
> >>>> having PTI. You can also use ASI for kernel threads so for code that won't
> >>>> be triggered from userland and so which won't involve PTI.
> >>> 
> >>> PTI is not mapping         kernel space to avoid             speculation crap (meltdown).
> >>> ASI is not mapping part of kernel space to avoid (different) speculation crap (MDS).
> >>> 
> >>> See how very similar they are?
> >>> 
> >>> Furthermore, to recover SMT for userspace (under MDS) we not only need
> >>> core-scheduling but core-scheduling per address space. And ASI was
> >>> specifically designed to help mitigate the trainwreck just described.
> >>> 
> >>> By explicitly exposing (hopefully harmless) part of the kernel to MDS,
> >>> we reduce the part that needs core-scheduling and thus reduce the rate
> >>> the SMT siblngs need to sync up/schedule.
> >>> 
> >>> But looking at it that way, it makes no sense to retain 3 address
> >>> spaces, namely:
> >>> 
> >>>   user / kernel exposed / kernel private.
> >>> 
> >>> Specifically, it makes no sense to expose part of the kernel through MDS
> >>> but not through Meltdow. Therefore we can merge the user and kernel
> >>> exposed address spaces.
> >>> 
> >>> And then we've fully replaced PTI.
> >>> 
> >>> So no, they're not orthogonal.
> >> Right. If we decide to expose more parts of the kernel mappings then that's
> >> just adding more stuff to the existing user (PTI) map mechanics.
> > 
> > If we expose more parts of the kernel mapping by adding them to the existing
> > user (PTI) map, then we only control the mapping of kernel sensitive data but
> > we don't control user mapping (with ASI, we exclude all user mappings).
> > 
> > How would you control the mapping of userland sensitive data and exclude them
> > from the user map?
> 
> As I see it, if we think part of the kernel is okay to leak to VM guests,
> then it should think it’s okay to leak to userspace and versa. At the end
> of the day, this may just have to come down to an administrator’s choice
> of how careful the mitigations need to be.
> 
> > Would you have the application explicitly identify sensitive
> > data (like Andy suggested with a /dev/xpfo device)?
> 
> That’s not really the intent of my suggestion. I was suggesting that
> maybe we don’t need ASI at all if we allow VMs to exclude their memory
> from the kernel mapping entirely.  Heck, in a setup like this, we can
> maybe even get away with turning PTI off under very, very controlled
> circumstances.  I’m not quite sure what to do about the kernel random
> pools, though.

I think KVM already allows excluding VMs memory from the kernel mapping
with the "new guest mapping interface" [1]. The memory managed by the host
can be restricted with "mem=" and KVM maps/unmaps the guest memory pages
only when needed.

It would be interesting to see if /dev/xpfo or even
madvise(MAKE_MY_MEMORY_PRIVATE) can be made useful for multi-tenant
container hosts.

[1] https://lore.kernel.org/lkml/1548966284-28642-1-git-send-email-karahmed@amazon.de/

-- 
Sincerely yours,
Mike.

