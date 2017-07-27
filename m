Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9911E6B037C
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:15:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 123so247460997pgj.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:15:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l1si8507424plg.715.2017.07.27.07.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 07:15:54 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6REELjg103683
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:15:53 -0400
Received: from e24smtp02.br.ibm.com (e24smtp02.br.ibm.com [32.104.18.86])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2byerm94uh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:15:53 -0400
Received: from localhost
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 11:15:50 -0300
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6REFlDq41025754
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:15:47 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6RBFla6021682
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:15:47 -0300
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-18-git-send-email-linuxram@us.ibm.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [RFC v6 17/62] powerpc: implementation for arch_set_user_pkey_access()
In-reply-to: <1500177424-13695-18-git-send-email-linuxram@us.ibm.com>
Date: Thu, 27 Jul 2017 11:15:36 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87d18m3r07.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com


Ram Pai <linuxram@us.ibm.com> writes:
> @@ -113,10 +117,14 @@ static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
>  	return 0;
>  }
>
> +extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> +		unsigned long init_val);
>  static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>  		unsigned long init_val)
>  {
> -	return 0;
> +	if (!pkey_inited)
> +		return -1;
> +	return __arch_set_user_pkey_access(tsk, pkey, init_val);
>  }

If non-zero, the return value of this function will be passed to
userspace by the pkey_alloc syscall. Shouldn't it be returning an errno
macro such as -EPERM?

Also, why are there both arch_set_user_pkey_access and
__arch_set_user_pkey_access? Is it a speed optimization so that the
early return is inlined into the caller? Ditto for execute_only_pkey
and __arch_override_mprotect_pkey.

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
