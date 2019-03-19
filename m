Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 750F4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 07:11:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F266D20857
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 07:11:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F266D20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54E416B0005; Tue, 19 Mar 2019 03:11:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FE166B0006; Tue, 19 Mar 2019 03:11:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ED246B0007; Tue, 19 Mar 2019 03:11:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 163C16B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 03:11:20 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 35so18952713qtq.5
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 00:11:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=4zHZB4HnLvEj6EKOuUMWItyI5voIzramqviDMhP/QE8=;
        b=PySBISbKmkMdKekuWz8W3xLKr1DGF74WuSdOpf+4BpF9bCUfk3/3WAtrSvh18wKaPC
         E12Zp89OeObpvwyPUxmjXid8pXpBS/yFbmxvqrREjTUnnWWL4DrJPTkCOM611oxW5uTK
         j4j6Nt2vNlr+vv/DrXBLUKfmO8Z2LX4JxvHJ4mZKQSrs+znaZuqGn1HELdJIWE6ZD8Wf
         tJPWnaBbTmwHRgG8Ter9mxmC2zfRMZV2R2hq71sE2Pia88rW9SatE2PluGX+QuNjXoyE
         bE7Z3iBnnAMtqQoqZeKze8+jZ9qvLBfJfk20E/6M1s1x1h5C6/erYkyAINVO2cyaaYrx
         04bQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUQCmdbNyMh/iRKmQb20nORv+A4xxt4d8hz3nd2UcTAH5WVSU+0
	0S90ZG08osCuoXtIr6HP/JOfLz38mG7qdB/VQnblN1oINQHK/Mzryv4bemeY4thZoq0ptqiJtbC
	zsQCw2bi/1eToCUtrYrKiynGJ8H+a30WK8RF0N+22CTspOZtb372517ndHEhqVqj4/w==
X-Received: by 2002:ac8:3feb:: with SMTP id v40mr700623qtk.102.1552979479810;
        Tue, 19 Mar 2019 00:11:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCuZ4nhWEUI7zubouvDQoBKV4l6Cm4bjHEmtdZgzG1xnR52WUU8fSa10VwbE//kTPNp7ds
X-Received: by 2002:ac8:3feb:: with SMTP id v40mr700582qtk.102.1552979478668;
        Tue, 19 Mar 2019 00:11:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552979478; cv=none;
        d=google.com; s=arc-20160816;
        b=q2RWlZxjk7bOUKNFiLaQYI/vgVtrrPa1K86GgTprDf1d32GUCfALSjrHmR45zaRCKc
         6offz5yVC3hDuFPmglT4+hwuPmZKYztwNDIhZz2vU3fk8dbHkcHrf+zHOhH2M8bXGVxd
         eUoHpWYzQ7tATovRb7BN1lo1bq/U3PeufCHjVji9KcANjqDaPwFW3CTvu2NPcdiUHWGI
         +PVMlJuf2perWknIZZHOSFPOBwnfYGmE5kaIZVNkZUGbT0W+W9AThVXuFtwHgxue9tAk
         wxxp8OGIjd4x4c2I/WLDDNejwTEWjxmqQebqtBwfmJAo6bHpNgi8qH9YsqbouoVlyLgw
         Q9Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=4zHZB4HnLvEj6EKOuUMWItyI5voIzramqviDMhP/QE8=;
        b=Nbe4mJIuydsTV2MllAXbVpCMud+FHxyZADHToi86m1rLpLhXtmYdyNXUTKVNqTRtvF
         1MwLhBdeuY+MQDyrWbEh4Kkpizd92GAwfvgx4RRDPlyC1vbVDc5jZTn7XpBgTVMvDdH9
         K+BAGblIljtDDX237xe2y8blfDmgPvd4KDMs+AMveiCksb3LiaLIZsJ/oIk8IpNDh469
         H8veReMwf98ZIriN0sOSJm0r2yd5684CdOhBjv9LETxI2iQerPOsxxDsxASTMClZ18bt
         tFKd1k3AgRLTk3aiRH1oExHHxFSpDhWrHKRaaLhpWD+GoxnjSjYeElK8WXkkQgqBTWFA
         X+zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p18si1707941qtc.229.2019.03.19.00.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 00:11:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2J757Jc099346
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 03:11:18 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ratf1ubuj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 03:11:17 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 19 Mar 2019 07:11:10 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 19 Mar 2019 07:11:04 -0000
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2J7B8gW40435914
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 19 Mar 2019 07:11:08 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 236B642049;
	Tue, 19 Mar 2019 07:11:08 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 74A6742045;
	Tue, 19 Mar 2019 07:11:06 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 19 Mar 2019 07:11:06 +0000 (GMT)
Date: Tue, 19 Mar 2019 09:11:04 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
        Hugh Dickins <hughd@google.com>, Luis Chamberlain <mcgrof@kernel.org>,
        Maxime Coquelin <maxime.coquelin@redhat.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
        Marty McFadden <mcfadden8@llnl.gov>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/1] userfaultfd/sysctl: add
 vm.unprivileged_userfaultfd
References: <20190319030722.12441-1-peterx@redhat.com>
 <20190319030722.12441-2-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319030722.12441-2-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19031907-0020-0000-0000-000003250493
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031907-0021-0000-0000-000021771BCD
Message-Id: <20190319071104.GA6392@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-19_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903190054
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Tue, Mar 19, 2019 at 11:07:22AM +0800, Peter Xu wrote:
> Add a global sysctl knob "vm.unprivileged_userfaultfd" to control
> whether userfaultfd is allowed by unprivileged users.  When this is
> set to zero, only privileged users (root user, or users with the
> CAP_SYS_PTRACE capability) will be able to use the userfaultfd
> syscalls.
> 
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Suggested-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

Just one minor note below

> ---
>  Documentation/sysctl/vm.txt   | 12 ++++++++++++
>  fs/userfaultfd.c              |  5 +++++
>  include/linux/userfaultfd_k.h |  2 ++
>  kernel/sysctl.c               | 12 ++++++++++++
>  4 files changed, 31 insertions(+)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 187ce4f599a2..f146712f67bb 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -61,6 +61,7 @@ Currently, these files are in /proc/sys/vm:
>  - stat_refresh
>  - numa_stat
>  - swappiness
> +- unprivileged_userfaultfd
>  - user_reserve_kbytes
>  - vfs_cache_pressure
>  - watermark_boost_factor
> @@ -818,6 +819,17 @@ The default value is 60.
> 
>  ==============================================================
> 
> +unprivileged_userfaultfd
> +
> +This flag controls whether unprivileged users can use the userfaultfd
> +syscalls.  Set this to 1 to allow unprivileged users to use the
> +userfaultfd syscalls, or set this to 0 to restrict userfaultfd to only
> +privileged users (with SYS_CAP_PTRACE capability).

Can you please fully spell "system call"?

> +
> +The default value is 1.
> +
> +==============================================================
> +
>  - user_reserve_kbytes
> 
>  When overcommit_memory is set to 2, "never overcommit" mode, reserve
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 89800fc7dc9d..7e856a25cc2f 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -30,6 +30,8 @@
>  #include <linux/security.h>
>  #include <linux/hugetlb.h>
> 
> +int sysctl_unprivileged_userfaultfd __read_mostly = 1;
> +
>  static struct kmem_cache *userfaultfd_ctx_cachep __read_mostly;
> 
>  enum userfaultfd_state {
> @@ -1921,6 +1923,9 @@ SYSCALL_DEFINE1(userfaultfd, int, flags)
>  	struct userfaultfd_ctx *ctx;
>  	int fd;
> 
> +	if (!sysctl_unprivileged_userfaultfd && !capable(CAP_SYS_PTRACE))
> +		return -EPERM;
> +
>  	BUG_ON(!current->mm);
> 
>  	/* Check the UFFD_* constants for consistency.  */
> diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> index 37c9eba75c98..ac9d71e24b81 100644
> --- a/include/linux/userfaultfd_k.h
> +++ b/include/linux/userfaultfd_k.h
> @@ -28,6 +28,8 @@
>  #define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
>  #define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
> 
> +extern int sysctl_unprivileged_userfaultfd;
> +
>  extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
> 
>  extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 7578e21a711b..9b8ff1881df9 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -66,6 +66,7 @@
>  #include <linux/kexec.h>
>  #include <linux/bpf.h>
>  #include <linux/mount.h>
> +#include <linux/userfaultfd_k.h>
> 
>  #include <linux/uaccess.h>
>  #include <asm/processor.h>
> @@ -1704,6 +1705,17 @@ static struct ctl_table vm_table[] = {
>  		.extra1		= (void *)&mmap_rnd_compat_bits_min,
>  		.extra2		= (void *)&mmap_rnd_compat_bits_max,
>  	},
> +#endif
> +#ifdef CONFIG_USERFAULTFD
> +	{
> +		.procname	= "unprivileged_userfaultfd",
> +		.data		= &sysctl_unprivileged_userfaultfd,
> +		.maxlen		= sizeof(sysctl_unprivileged_userfaultfd),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= &one,
> +	},
>  #endif
>  	{ }
>  };
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

