Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74422C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 06:58:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F05B214AF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 06:58:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F05B214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A72F58E0003; Tue, 12 Mar 2019 02:58:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FAAA8E0002; Tue, 12 Mar 2019 02:58:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 875928E0003; Tue, 12 Mar 2019 02:58:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 30ADE8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 02:58:47 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id n2so663718wrs.15
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:58:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=ut8PRn768vHIOsnHn2nMwm+QlmN7BB81CwJixaKVnng=;
        b=S3WgL8jJRXKkKOp+7O3/vmu35NwlK7GiAqvGFUikrqgA2grYEwpMZsSwKbcp8n29tF
         Ka0o2e2WsFVzWB28C4Z54fIF1gEnvb0FHxrQulqE8aFttnUstApzMMGL2qKISf7jTyc/
         a45D6F8P+NBH2Nzrix1rCAc5kIlojeihAEk/SPrSxL1WnWNTBDeqgMX1oXDgCe0L/8im
         7T02cQ86ao2JS+V3JOQ/mcSGXRyoDT7wT9c/owOAevYNGAK8FRPl3CF7KYkjt0knN/TU
         6V+pBiuwF3py/FRNOgiJhm14R761al3g8am+5yQ7GC007powdfyLITCZC7SKoX+IlBXp
         w1UA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWZMDEyj1rNgSfdOk4D0qWzYgmS3o9RTyUgBSVCaeX83A/pASwT
	MKo+gT2TLV7BFJXMkkZusQ/mqSwqOL2tGObsnn1NMDE1UzyIltBQNYv04cO89blxBElQGFv7Vqk
	zs+RAkgkNHmjvMPqhLvQiwuopQ9ivV/LhT7r2up1VeHBNE9rtqUQhN0VdCj3XbcqWyA==
X-Received: by 2002:adf:b3d3:: with SMTP id x19mr22848603wrd.181.1552373926756;
        Mon, 11 Mar 2019 23:58:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIHeU4+kTEej+giAp0GTb/RAAbHBJtFL4XCDWwyOoKi5B+/bA8h+NoaUqdE8UQl0OByLKx
X-Received: by 2002:adf:b3d3:: with SMTP id x19mr22848552wrd.181.1552373925776;
        Mon, 11 Mar 2019 23:58:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552373925; cv=none;
        d=google.com; s=arc-20160816;
        b=GxH7l4xTeoLDwHyqJGnF+QT2WeQOsLKhcsk3UGqX1L/DtKxIhYgvzWlXeYYXgzh4Hv
         oOpFVXnid5zR/O9AkZPCMgXfq79f6inQ5fLYo0XHbqFuqXHN25rGZGKsvRSUdgOJ1Zk+
         pSacwXIui9Cp/rNtdA9ClWGtjaATYdnoDasV2OOLSMlBDTeOnuEEYSWiHtfOl9bv5zAz
         JIYYJJYo1xVAnHMNaS2Tr/X6BczexZxdO34+GWEoDfrJY/giBlpXfkZPWZ6QGl98SUVn
         PxkOl+76k3atW9Aeym/ZHw7gagKGX1wcmcqpCtb2xa+yudA2j6Noy9z2qcHT0FzJSXnL
         IYrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=ut8PRn768vHIOsnHn2nMwm+QlmN7BB81CwJixaKVnng=;
        b=s4vN98R8+cWf8kHSZpVOJNOulCY4NYSiAp7gBwJZ1kHqDdp5J5lq/45Ylr4du/RPbA
         Lrqc78rJ3kR9brB3WFKOjOQvpJM079b2I7zEwbuBNYKaq79msxi8rt+JObIGc1+m3MHd
         eBK8RDTj16tbKoQeRURe2jaOCEfS+bXDIJOS6g7/iZ7QyFRA3tDSI9Nrb75nF0SYICPO
         IYAYo4ihY6f9TjnkN2sHoKM0SlB0wqomEmb4OrspEsZyYbPLa7lUM8+N53i0R+8UX2Dd
         YLzDloRE8hcWYmysdJSTTWOepLrBZ2nqE/AvrPnmKAKokVolIDxBrG0ciAu2U+2tL4ni
         Sd9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o9si2923828wrm.230.2019.03.11.23.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 23:58:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2C6u1m4007927
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 02:58:44 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r66rdm1kt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 02:58:43 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 12 Mar 2019 06:58:41 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Mar 2019 06:58:34 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2C6wXce37879836
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 12 Mar 2019 06:58:34 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DEC47A4057;
	Tue, 12 Mar 2019 06:58:33 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2E1FCA4040;
	Tue, 12 Mar 2019 06:58:32 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 12 Mar 2019 06:58:32 +0000 (GMT)
Date: Tue, 12 Mar 2019 08:58:30 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
        Hugh Dickins <hughd@google.com>, Luis Chamberlain <mcgrof@kernel.org>,
        Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
        Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
        Marty McFadden <mcfadden8@llnl.gov>, Maya Gokhale <gokhale2@llnl.gov>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        linux-fsdevel@vger.kernel.org,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] userfaultfd/sysctl: introduce
 unprivileged_userfaultfd
References: <20190311093701.15734-1-peterx@redhat.com>
 <20190311093701.15734-2-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311093701.15734-2-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19031206-0016-0000-0000-00000260CE27
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031206-0017-0000-0000-000032BB70EE
Message-Id: <20190312065830.GB9497@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-12_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903120052
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 05:36:59PM +0800, Peter Xu wrote:
> Introduce a new sysctl called "vm.unprivileged_userfaultfd" that can
> be used to decide whether userfaultfd syscalls are allowed by
> unprivileged users.  It'll allow three modes:
> 
>   - disabled: disallow unprivileged users to use uffd
> 
>   - enabled:  allow unprivileged users to use uffd
> 
>   - kvm:      allow unprivileged users to use uffd only if the user
>               had enough permission to open /dev/kvm (this option only
>               exists if the kernel turned on KVM).
> 
> This patch only introduce the new interface but not yet applied it to
> the userfaultfd syscalls, which will be done in the follow up patch.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  fs/userfaultfd.c              | 96 +++++++++++++++++++++++++++++++++++
>  include/linux/userfaultfd_k.h |  5 ++
>  init/Kconfig                  | 11 ++++
>  kernel/sysctl.c               | 11 ++++
>  4 files changed, 123 insertions(+)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 89800fc7dc9d..c2188464555a 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -29,6 +29,8 @@
>  #include <linux/ioctl.h>
>  #include <linux/security.h>
>  #include <linux/hugetlb.h>
> +#include <linux/sysctl.h>
> +#include <linux/string.h>
> 
>  static struct kmem_cache *userfaultfd_ctx_cachep __read_mostly;
> 
> @@ -93,6 +95,95 @@ struct userfaultfd_wake_range {
>  	unsigned long len;
>  };
> 
> +enum unprivileged_userfaultfd {
> +	/* Disallow unprivileged users to use userfaultfd syscalls */
> +	UFFD_UNPRIV_DISABLED = 0,
> +	/* Allow unprivileged users to use userfaultfd syscalls */
> +	UFFD_UNPRIV_ENABLED,
> +#if IS_ENABLED(CONFIG_KVM)
> +	/*
> +	 * Allow unprivileged users to use userfaultfd syscalls only
> +	 * if the user had enough permission to open /dev/kvm
> +	 */
> +	UFFD_UNPRIV_KVM,
> +#endif
> +	UFFD_UNPRIV_NUM,
> +};
> +
> +static int unprivileged_userfaultfd __read_mostly;
> +static const char *unprivileged_userfaultfd_str[UFFD_UNPRIV_NUM] = {
> +	"disabled", "enabled",
> +#if IS_ENABLED(CONFIG_KVM)
> +	"kvm",
> +#endif
> +};
> +
> +static int unprivileged_uffd_parse(char *buf, size_t size)
> +{
> +	int i;
> +
> +	for (i = 0; i < UFFD_UNPRIV_NUM; i++) {
> +		if (!strncmp(unprivileged_userfaultfd_str[i], buf, size)) {
> +			unprivileged_userfaultfd = i;
> +			return 0;
> +		}
> +	}
> +
> +	return -EFAULT;
> +}
> +
> +static void unprivileged_uffd_dump(char *buf, size_t size)
> +{
> +	int i;
> +
> +	*buf = 0x00;
> +	for (i = 0; i < UFFD_UNPRIV_NUM; i++) {
> +		if (i == unprivileged_userfaultfd)
> +			strncat(buf, "[", size - strlen(buf));
> +		strncat(buf, unprivileged_userfaultfd_str[i],
> +			size - strlen(buf));
> +		if (i == unprivileged_userfaultfd)
> +			strncat(buf, "]", size - strlen(buf));
> +		strncat(buf, " ", size - strlen(buf));
> +	}
> +
> +}
> +
> +int proc_unprivileged_userfaultfd(struct ctl_table *table, int write,
> +				  void __user *buffer, size_t *lenp,
> +				  loff_t *ppos)
> +{
> +	struct ctl_table tmp_table = { .maxlen = 0 };
> +	int ret;
> +
> +	if (write) {
> +		tmp_table.maxlen = UFFD_UNPRIV_STRLEN;
> +		tmp_table.data = kmalloc(UFFD_UNPRIV_STRLEN, GFP_KERNEL);
> +
> +		ret = proc_dostring(&tmp_table, write, buffer, lenp, ppos);
> +		if (ret)
> +			goto out;
> +
> +		ret = unprivileged_uffd_parse(tmp_table.data,
> +					      UFFD_UNPRIV_STRLEN);
> +	} else {
> +		/* Leave space for "[]" */
> +		int len = UFFD_UNPRIV_STRLEN * UFFD_UNPRIV_NUM + 2;
> +
> +		tmp_table.maxlen = len;
> +		tmp_table.data = kmalloc(len, GFP_KERNEL);
> +
> +		unprivileged_uffd_dump(tmp_table.data, len);
> +
> +		ret = proc_dostring(&tmp_table, write, buffer, lenp, ppos);
> +	}
> +
> +out:
> +	if (tmp_table.data)
> +		kfree(tmp_table.data);
> +	return ret;
> +}
> +
>  static int userfaultfd_wake_function(wait_queue_entry_t *wq, unsigned mode,
>  				     int wake_flags, void *key)
>  {
> @@ -1955,6 +2046,11 @@ SYSCALL_DEFINE1(userfaultfd, int, flags)
> 
>  static int __init userfaultfd_init(void)
>  {
> +	char unpriv_uffd[UFFD_UNPRIV_STRLEN] =
> +	    CONFIG_USERFAULTFD_UNPRIVILEGED_DEFAULT;
> +
> +	unprivileged_uffd_parse(unpriv_uffd, sizeof(unpriv_uffd));
> +
>  	userfaultfd_ctx_cachep = kmem_cache_create("userfaultfd_ctx_cache",
>  						sizeof(struct userfaultfd_ctx),
>  						0,
> diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> index 37c9eba75c98..f53bc02ccffc 100644
> --- a/include/linux/userfaultfd_k.h
> +++ b/include/linux/userfaultfd_k.h
> @@ -28,6 +28,11 @@
>  #define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
>  #define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
> 
> +#define UFFD_UNPRIV_STRLEN 16
> +int proc_unprivileged_userfaultfd(struct ctl_table *table, int write,
> +				  void __user *buffer, size_t *lenp,
> +				  loff_t *ppos);
> +
>  extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
> 
>  extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
> diff --git a/init/Kconfig b/init/Kconfig
> index c9386a365eea..d90caa4fed17 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1512,6 +1512,17 @@ config USERFAULTFD
>  	  Enable the userfaultfd() system call that allows to intercept and
>  	  handle page faults in userland.
> 
> +config USERFAULTFD_UNPRIVILEGED_DEFAULT
> +        string "Default behavior for unprivileged userfault syscalls"
> +        depends on USERFAULTFD
> +        default "disabled"
> +        help
> +          Set this to "enabled" to allow userfaultfd syscalls from
> +          unprivileged users.  Set this to "disabled" to forbid
> +          userfaultfd syscalls from unprivileged users.  Set this to
> +          "kvm" to forbid unpriviledged users but still allow users
> +          who had enough permission to open /dev/kvm.

I'd phrase it a bit differently:

This option controls privilege level required to execute userfaultfd
system call.

Set this to "enabled" to allow userfaultfd system call from unprivileged
users. 
Set this to "disabled" to allow userfaultfd system call only for users who
have ptrace capability.
Set this to "kvm" to restrict userfaultfd system call usage to users with
permissions to open "/dev/kvm".
 
> +
>  config ARCH_HAS_MEMBARRIER_CALLBACKS
>  	bool
> 
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 7578e21a711b..5dc9f3d283dd 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -96,6 +96,9 @@
>  #ifdef CONFIG_LOCKUP_DETECTOR
>  #include <linux/nmi.h>
>  #endif
> +#ifdef CONFIG_USERFAULTFD
> +#include <linux/userfaultfd_k.h>
> +#endif
> 
>  #if defined(CONFIG_SYSCTL)
> 
> @@ -1704,6 +1707,14 @@ static struct ctl_table vm_table[] = {
>  		.extra1		= (void *)&mmap_rnd_compat_bits_min,
>  		.extra2		= (void *)&mmap_rnd_compat_bits_max,
>  	},
> +#endif
> +#ifdef CONFIG_USERFAULTFD
> +	{
> +		.procname	= "unprivileged_userfaultfd",
> +		.maxlen		= UFFD_UNPRIV_STRLEN,
> +		.mode		= 0644,
> +		.proc_handler	= proc_unprivileged_userfaultfd,
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

