Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A86DF6B0492
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 13:33:16 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g32so11576926wrd.8
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:33:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b4si15673055wrf.401.2017.07.27.10.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 10:33:14 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6RHSivJ130281
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 13:33:13 -0400
Received: from e24smtp01.br.ibm.com (e24smtp01.br.ibm.com [32.104.18.85])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2byj6xfnd4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 13:33:13 -0400
Received: from localhost
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 14:33:11 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay04.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6RHX9Dd25428206
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:33:09 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6RHX97I025980
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:33:09 -0300
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-21-git-send-email-linuxram@us.ibm.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [RFC v6 20/62] powerpc: store and restore the pkey state across context switches
In-reply-to: <1500177424-13695-21-git-send-email-linuxram@us.ibm.com>
Date: Thu, 27 Jul 2017 14:32:59 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <878tj94wfo.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com


Ram Pai <linuxram@us.ibm.com> writes:

> Store and restore the AMR, IAMR and UMOR register state of the task
> before scheduling out and after scheduling in, respectively.
>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>

s/UMOR/UAMOR/

> diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
> index 2ad725e..9429361 100644
> --- a/arch/powerpc/kernel/process.c
> +++ b/arch/powerpc/kernel/process.c
> @@ -1096,6 +1096,11 @@ static inline void save_sprs(struct thread_struct *t)
>  		t->tar = mfspr(SPRN_TAR);
>  	}
>  #endif
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> +	t->amr = mfspr(SPRN_AMR);
> +	t->iamr = mfspr(SPRN_IAMR);
> +	t->uamor = mfspr(SPRN_UAMOR);
> +#endif
>  }
>
>  static inline void restore_sprs(struct thread_struct *old_thread,
> @@ -1131,6 +1136,14 @@ static inline void restore_sprs(struct thread_struct *old_thread,
>  			mtspr(SPRN_TAR, new_thread->tar);
>  	}
>  #endif
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> +	if (old_thread->amr != new_thread->amr)
> +		mtspr(SPRN_AMR, new_thread->amr);
> +	if (old_thread->iamr != new_thread->iamr)
> +		mtspr(SPRN_IAMR, new_thread->iamr);
> +	if (old_thread->uamor != new_thread->uamor)
> +		mtspr(SPRN_UAMOR, new_thread->uamor);
> +#endif
>  }

Shouldn't the saving and restoring of the SPRs be guarded by a check for
whether memory protection keys are enabled? What happens when trying to
access these registers on a CPU which doesn't have them?

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
