Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B906FC04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:22:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 797262075C
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:22:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 797262075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D0556B026E; Wed, 29 May 2019 03:22:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2859C6B0270; Wed, 29 May 2019 03:22:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1486F6B0271; Wed, 29 May 2019 03:22:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id E38DF6B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:22:01 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id 126so1258487ybw.9
        for <linux-mm@kvack.org>; Wed, 29 May 2019 00:22:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=UUaZisK+vU/C/Az61XsuCiJnFQevGKk/DQSz/jQIcUY=;
        b=EZHhdG2MadZjhQea1nKHkRKndGbI4NHFl0smNYODaTlljR9i/NoPlqJgLki4FdLcbs
         B/CMyKM2YDJre7o/TU3p5/FJ6rgcXYcQtIygyZNXIKs8cUPNLg8FwK5sl9h7XYRQ2lms
         mnRAeRhXNBPX7SudNwdziesJ/l/HIrQY7XOUdXi9WH4Btvlj39mS/NSK34JiHwz0JtE2
         3WHpUD5aVs2vv+PEtBVHBABUlLjvWy+ZczUaX8BIJ7KscT/a3+NQcAun/+mzcfciDx1u
         zDDvloHaT6eDLFOp9A988MIfDQ0DxK3f7EKqBODHJkwDc/tlZewBJYRd8l9zRQrF1bmw
         l9/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU4ZVaKlFj2D0yYXsGkRGZx9tuBysMY/q9pgmASyFyFGvOLsQbP
	Vo8U/lGP/FUNYqnMG6jefZoRZLq0ApTyay5v2mou6sXeUYWHv8PkgOg2o6aAzlM7tQJgP8HbHbL
	6/epXf0MuINMb86E63J22chTu8AihzXzNHiNH3E1L36I4pbYTZFa78dceFowHZNRjAQ==
X-Received: by 2002:a81:364b:: with SMTP id d72mr30321107ywa.70.1559114521677;
        Wed, 29 May 2019 00:22:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2DmIAAy2nGPZI5RWqAPb0VIl9QEOZBqKel/YN7aD1d5+6WcjIGK/Yxx9x5uWA1+m3xB4h
X-Received: by 2002:a81:364b:: with SMTP id d72mr30321087ywa.70.1559114520899;
        Wed, 29 May 2019 00:22:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559114520; cv=none;
        d=google.com; s=arc-20160816;
        b=cm/+M8r2Sn4WOa2nX1CWXfEga5AZfGRkOWJaCc/heB3jUiANuTleNQ4EMyBQWKdMZt
         oZe5TcAiPNP1o0kbPLJlV7dTROza0O49JO+Dt1CRXIcOPNOH2vhU2akG0rdJ1rot7v1/
         91Z1h2Bj2SM+BKtntuFNSPluqolwtWNAfuW0JdLeEm2b5BIqHXUMOLO3pCrG/ciivAww
         3OFZwZzJYvVn/aLmBFW6xGYtaAXLdLp4yG7xI08tmFKwXlir8aT4R94beAH6eOdG92l3
         Jf3YsKb3z68RCO/ig7QvQ8qGBE1xuDEMzCNF1K3tvLyRQlypysdxq8utg7xPbkO3hsZ9
         xECg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:subject:cc:to:from:date;
        bh=UUaZisK+vU/C/Az61XsuCiJnFQevGKk/DQSz/jQIcUY=;
        b=vOaB/ZhPdmkQqAXmsEwbNL+JpEHxEUD6ls9ObeNYZV3zrWpNAkkiA7+Xtaou8XmUHv
         a0aY+aG2PZoVkqcY85aUP8OwnudckgXRVaBdEtViiHchPLtLsP5OlaFRNVDPygqCk/xH
         hOsW0o/Srx+uZiWMhOqWvufWdazYUqW1sqmSHLPYyLuEMCig2DVUpdWyfV29Y7Vt/wJR
         k8WQJ86XliZFfZx8KxeutYsJGESG59jrxNB2l71IgzsgFX+AWuH+op1sVUfq47zk249z
         JjBk1d1Gh5geS8ZXITnP5UBzO/mHkFT2ekQi77jIPOCQlxNpn1+irrHsY5rkEqPZolwx
         PlMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g187si301492ywg.75.2019.05.29.00.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 00:22:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4T7JHIN043467
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:22:00 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sskwsv1dm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:22:00 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 29 May 2019 08:21:58 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 29 May 2019 08:21:53 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4T7LqrD48693492
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 07:21:52 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CE5FC4C052;
	Wed, 29 May 2019 07:21:51 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7C0104C04E;
	Wed, 29 May 2019 07:21:50 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 29 May 2019 07:21:50 +0000 (GMT)
Date: Wed, 29 May 2019 10:21:48 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
        Peter Zijlstra <peterz@infradead.org>,
        Andy Lutomirski <luto@amacapital.net>,
        David Howells <dhowells@redhat.com>, Kees Cook <keescook@chromium.org>,
        Dave Hansen <dave.hansen@intel.com>,
        Kai Huang <kai.huang@linux.intel.com>,
        Jacob Pan <jacob.jun.pan@linux.intel.com>,
        Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
        kvm@vger.kernel.org, keyrings@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 57/62] x86/mktme: Overview of Multi-Key Total Memory
 Encryption
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-58-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190508144422.13171-58-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19052907-0008-0000-0000-000002EB7A72
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052907-0009-0000-0000-000022584A02
Message-Id: <20190529072148.GE3656@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-29_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905290049
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:17PM +0300, Kirill A. Shutemov wrote:
> From: Alison Schofield <alison.schofield@intel.com>
> 
> Provide an overview of MKTME on Intel Platforms.
> 
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  Documentation/x86/mktme/index.rst          |  8 +++
>  Documentation/x86/mktme/mktme_overview.rst | 57 ++++++++++++++++++++++

I'd expect addition of mktme docs to Documentation/x86/index.rst

>  2 files changed, 65 insertions(+)
>  create mode 100644 Documentation/x86/mktme/index.rst
>  create mode 100644 Documentation/x86/mktme/mktme_overview.rst
> 
> diff --git a/Documentation/x86/mktme/index.rst b/Documentation/x86/mktme/index.rst
> new file mode 100644
> index 000000000000..1614b52dd3e9
> --- /dev/null
> +++ b/Documentation/x86/mktme/index.rst
> @@ -0,0 +1,8 @@
> +
> +=========================================
> +Multi-Key Total Memory Encryption (MKTME)
> +=========================================
> +
> +.. toctree::
> +
> +   mktme_overview
> diff --git a/Documentation/x86/mktme/mktme_overview.rst b/Documentation/x86/mktme/mktme_overview.rst
> new file mode 100644
> index 000000000000..59c023965554
> --- /dev/null
> +++ b/Documentation/x86/mktme/mktme_overview.rst
> @@ -0,0 +1,57 @@
> +Overview
> +=========
> +Multi-Key Total Memory Encryption (MKTME)[1] is a technology that
> +allows transparent memory encryption in upcoming Intel platforms.
> +It uses a new instruction (PCONFIG) for key setup and selects a
> +key for individual pages by repurposing physical address bits in
> +the page tables.
> +
> +Support for MKTME is added to the existing kernel keyring subsystem
> +and via a new mprotect_encrypt() system call that can be used by
> +applications to encrypt anonymous memory with keys obtained from
> +the keyring.
> +
> +This architecture supports encrypting both normal, volatile DRAM
> +and persistent memory.  However, persistent memory support is
> +not included in the Linux kernel implementation at this time.
> +(We anticipate adding that support next.)
> +
> +Hardware Background
> +===================
> +
> +MKTME is built on top of an existing single-key technology called
> +TME.  TME encrypts all system memory using a single key generated
> +by the CPU on every boot of the system. TME provides mitigation
> +against physical attacks, such as physically removing a DIMM or
> +watching memory bus traffic.
> +
> +MKTME enables the use of multiple encryption keys[2], allowing
> +selection of the encryption key per-page using the page tables.
> +Encryption keys are programmed into each memory controller and
> +the same set of keys is available to all entities on the system
> +with access to that memory (all cores, DMA engines, etc...).
> +
> +MKTME inherits many of the mitigations against hardware attacks
> +from TME.  Like TME, MKTME does not mitigate vulnerable or
> +malicious operating systems or virtual machine managers.  MKTME
> +offers additional mitigations when compared to TME.
> +
> +TME and MKTME use the AES encryption algorithm in the AES-XTS
> +mode.  This mode, typically used for block-based storage devices,
> +takes the physical address of the data into account when
> +encrypting each block.  This ensures that the effective key is
> +different for each block of memory. Moving encrypted content
> +across physical address results in garbage on read, mitigating
> +block-relocation attacks.  This property is the reason many of
> +the discussed attacks require control of a shared physical page
> +to be handed from the victim to the attacker.
> +
> +--
> +1. https://software.intel.com/sites/default/files/managed/a5/16/Multi-Key-Total-Memory-Encryption-Spec.pdf
> +2. The MKTME architecture supports up to 16 bits of KeyIDs, so a
> +   maximum of 65535 keys on top of the “TME key” at KeyID-0.  The
> +   first implementation is expected to support 5 bits, making 63
> +   keys available to applications.  However, this is not guaranteed.
> +   The number of available keys could be reduced if, for instance,
> +   additional physical address space is desired over additional
> +   KeyIDs.
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

