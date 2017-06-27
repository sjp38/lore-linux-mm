Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 416BE6B02B4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:33:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u36so24914325pgn.5
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:33:07 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id g34si1885784pld.495.2017.06.27.04.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 04:33:06 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id j186so3990445pge.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:33:06 -0700 (PDT)
Message-ID: <1498563132.7935.15.camel@gmail.com>
Subject: Re: [RFC v4 03/17] x86: key creation with PKEY_DISABLE_EXECUTE
 disallowed
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 27 Jun 2017 21:32:12 +1000
In-Reply-To: <1498558319-32466-4-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
	 <1498558319-32466-4-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Tue, 2017-06-27 at 03:11 -0700, Ram Pai wrote:
> x86 does not support disabling execute permissions on a pkey.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/x86/kernel/fpu/xstate.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
> index c24ac1e..d582631 100644
> --- a/arch/x86/kernel/fpu/xstate.c
> +++ b/arch/x86/kernel/fpu/xstate.c
> @@ -900,6 +900,9 @@ int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>  	if (!boot_cpu_has(X86_FEATURE_OSPKE))
>  		return -EINVAL;
>  
> +	if (init_val & PKEY_DISABLE_EXECUTE)
> +		return -EINVAL;
> +
>  	/* Set the bits we need in PKRU:  */
>  	if (init_val & PKEY_DISABLE_ACCESS)
>  		new_pkru_bits |= PKRU_AD_BIT;

I am not an x86 expert. IIUC, execute disable is done via allocating an
execute_only_pkey and checking vma_key via AD + vma_flags against VM_EXEC.

Your patch looks good to me

Acked-by: Balbir Singh <bsingharora@gmail.com>

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
