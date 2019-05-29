Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BC44C46470
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F601208C3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:21:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F601208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A98A46B026D; Wed, 29 May 2019 03:21:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4A146B026E; Wed, 29 May 2019 03:21:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 913596B0270; Wed, 29 May 2019 03:21:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 589C36B026D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:21:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e69so1112190pgc.7
        for <linux-mm@kvack.org>; Wed, 29 May 2019 00:21:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=GM7xt6veaCEBHCX3f9+a/GJAy8jzMp/yRCmGPqa3Ibk=;
        b=HLqjdLtydpZLvgKAKfuwXL/f4AhOrFa4nB6bwGIKCqLg5x00Pu5lbpF12Bk7w5LzD8
         mIJGHYjKrH5EDaqkQdHeu+/+CiItz4O+3v04Hm7SiJGxFTmH+uUhlnI7aFxHGCO0pDO2
         HT4Na6pt6RX1gS/f+APwvxnd34md0D0/RvTQc8RYS33WWYNidxH3aQgRRI1tXcs8AR6i
         TdC1UH1ejBM5JSuaempNyuf6mplj44gPyLbQDDqnIDUEzWhBK96N/M2cd2BIPYcvGppu
         s3pfQpRjCRnbpTIWNMKpc8XqDN76SN5xMPGnQ+skHf4OUQTgAbw6ONh9tAo++JKTxxXN
         ihrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXztBEtqy/Bztlwhhx1LDDYrkH2cfcWEX8Lao/XDRyzPIp3d9Kh
	oJ31b2PqNhXQphdBq3O9XW5jmptypUvxd8oQX54+CsmUG08GJzUn3TI+OqHiLUR/NEc0Gah5rdq
	W1YVWLTF1vCb9WXR/Tz+Bb8XpAabFP628VjAHwruMll0BNb1YfaocUOeAGYSBJe9fHg==
X-Received: by 2002:a17:902:27e6:: with SMTP id i35mr32054690plg.190.1559114510884;
        Wed, 29 May 2019 00:21:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoFXgZLwNiYfgfgPX3pfc6LeiNBEVMAMpxS/H7ZdCgloYUgxj8rwOvRaUiT/pHlYpC14tW
X-Received: by 2002:a17:902:27e6:: with SMTP id i35mr32054661plg.190.1559114510202;
        Wed, 29 May 2019 00:21:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559114510; cv=none;
        d=google.com; s=arc-20160816;
        b=Q5lkakcEm2lpnixjlh6DZwGTux7Ia8blH+rxPArvEjBty3d1Ve89kMtd13IdwQFQiM
         3G7kX3sIbPQUx2rqwz4jAaztYcBffcoebY8lDJXnxAVKLT2OgfHJ9Li4cPty6F4T61r1
         tiYKveQ11Dj4yTRzCz5b/ElDUcSgkGUQanDOaCwHaBQmdsnwyzi8sU2qTZ89cbxcKC37
         qlId7IzvpCUfEHdorBVj/nveWO3RBXJPvV8UYPcpeOCuCyiLl8zp4Q4HBm7pgJBmfmBL
         k/o57HBOgdFfwVuoql+hVnjaf/gHXyIXmcPzsx+cBE79huugRafTwFK8IRyrufPrdbgw
         rlaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=GM7xt6veaCEBHCX3f9+a/GJAy8jzMp/yRCmGPqa3Ibk=;
        b=TqQvMbi3llDUk36GxN7DI4h0Vmd2vmJszf2CO2F6XHbUwvQfTZaIFJZ8htibFX6mj+
         rzZtoVucnDi/F0I2GAjDQGeee/J/+9yFGQ9b+Y889WYTsP52V1SlVHBkMuEpMnB46Yod
         QOr0f04y734da/c3uOFt8fKoTCkKYVn2GLXib6QxEfUTyX6FIZ7luDiyBnFbT3OdPMoz
         6588eEdgTEdfSwYscrepRreAHP1EKkG0qdPMvlDrUGrfML7MOQXT8RpQwftSEZmuGwe9
         g+ENf3w15MZXYv+Fx/eRyqi2CydfwrjQ5O68XE4l8sRLToYXoEEe+r4czy31zLHB08RO
         mYCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v1si23527326plp.26.2019.05.29.00.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 00:21:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4T7JIFT046941
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:21:49 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ssmbdu1bd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:21:49 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 29 May 2019 08:21:46 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 29 May 2019 08:21:41 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4T7LeBG14745774
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 07:21:40 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 05A7111C05E;
	Wed, 29 May 2019 07:21:40 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9E86011C04C;
	Wed, 29 May 2019 07:21:38 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 29 May 2019 07:21:38 +0000 (GMT)
Date: Wed, 29 May 2019 10:21:37 +0300
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
Subject: Re: [PATCH, RFC 43/62] syscall/x86: Wire up a system call for MKTME
 encryption keys
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-44-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-44-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19052907-0012-0000-0000-000003207EE0
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052907-0013-0000-0000-0000215948FF
Message-Id: <20190529072136.GD3656@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-29_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905290049
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:03PM +0300, Kirill A. Shutemov wrote:
> From: Alison Schofield <alison.schofield@intel.com>
> 
> encrypt_mprotect() is a new system call to support memory encryption.
> 
> It takes the same parameters as legacy mprotect, plus an additional
> key serial number that is mapped to an encryption keyid.

Shouldn't this patch be after the encrypt_mprotect() is added?
 
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/entry/syscalls/syscall_32.tbl | 1 +
>  arch/x86/entry/syscalls/syscall_64.tbl | 1 +
>  include/linux/syscalls.h               | 2 ++
>  include/uapi/asm-generic/unistd.h      | 4 +++-
>  kernel/sys_ni.c                        | 2 ++
>  5 files changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index 1f9607ed087c..dbcd4c28d743 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -433,3 +433,4 @@
>  425	i386	io_uring_setup		sys_io_uring_setup		__ia32_sys_io_uring_setup
>  426	i386	io_uring_enter		sys_io_uring_enter		__ia32_sys_io_uring_enter
>  427	i386	io_uring_register	sys_io_uring_register		__ia32_sys_io_uring_register
> +428	i386	encrypt_mprotect	sys_encrypt_mprotect		__ia32_sys_encrypt_mprotect
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index 92ee0b4378d4..d01bd132e9ee 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -349,6 +349,7 @@
>  425	common	io_uring_setup		__x64_sys_io_uring_setup
>  426	common	io_uring_enter		__x64_sys_io_uring_enter
>  427	common	io_uring_register	__x64_sys_io_uring_register
> +428	common	encrypt_mprotect	__x64_sys_encrypt_mprotect
> 
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index e446806a561f..38a2d7b95397 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -988,6 +988,8 @@ asmlinkage long sys_rseq(struct rseq __user *rseq, uint32_t rseq_len,
>  asmlinkage long sys_pidfd_send_signal(int pidfd, int sig,
>  				       siginfo_t __user *info,
>  				       unsigned int flags);
> +asmlinkage long sys_encrypt_mprotect(unsigned long start, size_t len,
> +				     unsigned long prot, key_serial_t serial);
> 
>  /*
>   * Architecture-specific system calls
> diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
> index dee7292e1df6..86f942f54b1b 100644
> --- a/include/uapi/asm-generic/unistd.h
> +++ b/include/uapi/asm-generic/unistd.h
> @@ -832,9 +832,11 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
>  __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
>  #define __NR_io_uring_register 427
>  __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
> +#define __NR_encrypt_mprotect 428
> +__SYSCALL(__NR_encrypt_mprotect, sys_encrypt_mprotect)
> 
>  #undef __NR_syscalls
> -#define __NR_syscalls 428
> +#define __NR_syscalls 429
> 
>  /*
>   * 32 bit systems traditionally used different
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index d21f4befaea4..80da8d9ac8b1 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -350,6 +350,8 @@ COND_SYSCALL(pkey_mprotect);
>  COND_SYSCALL(pkey_alloc);
>  COND_SYSCALL(pkey_free);
> 
> +/* multi-key total memory encryption keys */
> +COND_SYSCALL(encrypt_mprotect);
> 
>  /*
>   * Architecture specific weak syscall entries.
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

