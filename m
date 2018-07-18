Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81D776B0008
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 12:38:20 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e1-v6so2814962pld.23
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 09:38:20 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r25-v6si3466816pge.104.2018.07.18.09.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 09:38:17 -0700 (PDT)
Subject: Re: [PATCH v14 14/22] selftests/vm: Introduce generic abstractions
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-15-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <527bc6c2-0bfd-4ada-e601-08863443995f@intel.com>
Date: Wed, 18 Jul 2018 09:38:14 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-15-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 07/17/2018 06:49 AM, Ram Pai wrote:
> Introduce generic abstractions and provide architecture
> specific implementation for the abstractions.

I really wanted to see these two things separated:
1. introduce abstractions
2. introduce ppc implementation

But, I guess most of it is done except for the siginfo stuff.

>  #if defined(__i386__) || defined(__x86_64__) /* arch */
>  #include "pkey-x86.h"
> +#elif defined(__powerpc64__) /* arch */
> +#include "pkey-powerpc.h"
>  #else /* arch */
>  #error Architecture not supported
>  #endif /* arch */
> @@ -186,7 +191,16 @@ static inline int open_hugepage_file(int flag)
>  
>  static inline int get_start_key(void)
>  {
> -	return 1;
> +	return 0;
> +}

How does this not now break x86?
>  #endif /* _PKEYS_X86_H */
> diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
> index 304f74f..18e1bb7 100644
> --- a/tools/testing/selftests/vm/protection_keys.c
> +++ b/tools/testing/selftests/vm/protection_keys.c
> @@ -197,17 +197,18 @@ void dump_mem(void *dumpme, int len_bytes)
>  
>  int pkey_faults;
>  int last_si_pkey = -1;
> +void pkey_access_allow(int pkey);

Please just move the function.

>  void signal_handler(int signum, siginfo_t *si, void *vucontext)
>  {
>  	ucontext_t *uctxt = vucontext;
>  	int trapno;
>  	unsigned long ip;
>  	char *fpregs;
> +#if defined(__i386__) || defined(__x86_64__) /* arch */
>  	pkey_reg_t *pkey_reg_ptr;
> -	u64 siginfo_pkey;
> +#endif /* defined(__i386__) || defined(__x86_64__) */
> +	u32 siginfo_pkey;
>  	u32 *si_pkey_ptr;
> -	int pkey_reg_offset;
> -	fpregset_t fpregset;
>  
>  	dprint_in_signal = 1;
>  	dprintf1(">>>>===============SIGSEGV============================\n");
> @@ -217,12 +218,14 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
>  
>  	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
>  	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
> -	fpregset = uctxt->uc_mcontext.fpregs;
> -	fpregs = (void *)fpregset;
> +	fpregs = (char *) uctxt->uc_mcontext.fpregs;
>  
>  	dprintf2("%s() trapno: %d ip: 0x%016lx info->si_code: %s/%d\n",
>  			__func__, trapno, ip, si_code_str(si->si_code),
>  			si->si_code);
> +
> +#if defined(__i386__) || defined(__x86_64__) /* arch */
> +
>  #ifdef __i386__
>  	/*
>  	 * 32-bit has some extra padding so that userspace can tell whether
> @@ -230,20 +233,21 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
>  	 * state.  We just assume that it is here.
>  	 */
>  	fpregs += 0x70;
> -#endif
> -	pkey_reg_offset = pkey_reg_xstate_offset();
> -	pkey_reg_ptr = (void *)(&fpregs[pkey_reg_offset]);
> +#endif /* __i386__ */
>  
> -	dprintf1("siginfo: %p\n", si);
> -	dprintf1(" fpregs: %p\n", fpregs);
> +	pkey_reg_ptr = (void *)(&fpregs[pkey_reg_xstate_offset()]);

There are unnecessary parenthesis here.

Also, why are you bothering to mess with this?  This is inside the x86
#ifdef, right?

>  	/*
> -	 * If we got a PKEY fault, we *HAVE* to have at least one bit set in
> +	 * If we got a key fault, we *HAVE* to have at least one bit set in
>  	 * here.
>  	 */
>  	dprintf1("pkey_reg_xstate_offset: %d\n", pkey_reg_xstate_offset());
>  	if (DEBUG_LEVEL > 4)
>  		dump_mem(pkey_reg_ptr - 128, 256);
>  	pkey_assert(*pkey_reg_ptr);
> +#endif /* defined(__i386__) || defined(__x86_64__) */
> +
> +	dprintf1("siginfo: %p\n", si);
> +	dprintf1(" fpregs: %p\n", fpregs);
>  
>  	if ((si->si_code == SEGV_MAPERR) ||
>  	    (si->si_code == SEGV_ACCERR) ||
> @@ -252,22 +256,28 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
>  		exit(4);
>  	}
>  
> -	si_pkey_ptr = (u32 *)(((u8 *)si) + si_pkey_offset);
> +	si_pkey_ptr = siginfo_get_pkey_ptr(si);
>  	dprintf1("si_pkey_ptr: %p\n", si_pkey_ptr);
> -	dump_mem((u8 *)si_pkey_ptr - 8, 24);
> +	dump_mem(si_pkey_ptr - 8, 24);

You removed the cast here, why?  That changes the pointer math.

Can we merge this as-is.  No, I do not think we can.  If it were _just_
the #ifdefs, we could let it pass, but there are a bunch of rough spots,
not just the #ifdefs.
