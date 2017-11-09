Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6BE440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 13:47:23 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id q33so2412450qta.18
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 10:47:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l5sor4684075qti.49.2017.11.09.10.47.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 10:47:22 -0800 (PST)
Date: Thu, 9 Nov 2017 16:47:15 -0200
From: Breno Leitao <leitao@debian.org>
Subject: Re: [PATCH v9 44/51] selftest/vm: powerpc implementation for generic
 abstraction
Message-ID: <20171109184714.xs523k4cvmqghew3@gmail.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-45-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509958663-18737-45-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linux-arch@vger.kernel.org, ebiederm@xmission.com, linux-doc@vger.kernel.org, x86@kernel.org, dave.hansen@intel.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

Hi Ram,

On Mon, Nov 06, 2017 at 12:57:36AM -0800, Ram Pai wrote:
> @@ -206,12 +209,14 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
>  
>  	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
>  	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
> -	fpregset = uctxt->uc_mcontext.fpregs;
> -	fpregs = (void *)fpregset;

Since you removed all references for fpregset now, you probably want to
remove the declaration of the variable above.

> @@ -219,20 +224,21 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
>  	 * state.  We just assume that it is here.
>  	 */
>  	fpregs += 0x70;
> -#endif
> -	pkey_reg_offset = pkey_reg_xstate_offset();

With this code, you removed all the reference for variable
pkey_reg_offset, thus, its declaration could be removed also.

> -	*(u64 *)pkey_reg_ptr = 0x00000000;
> +	dprintf1("si_pkey from siginfo: %lx\n", si_pkey);
> +#if defined(__i386__) || defined(__x86_64__) /* arch */
> +	dprintf1("signal pkey_reg from xsave: %016lx\n", *pkey_reg_ptr);
> +	*(u64 *)pkey_reg_ptr &= reset_bits(si_pkey, PKEY_DISABLE_ACCESS);
> +#elif __powerpc64__

Since the variable pkey_reg_ptr is only used for Intel code (inside
#ifdefs), you probably want to #ifdef the variable declaration also,
avoid triggering "unused variable" warning on non-Intel machines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
