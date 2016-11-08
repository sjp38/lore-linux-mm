Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F22B6B0069
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 13:39:14 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so53871201pfv.5
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 10:39:14 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l5si31754346paq.190.2016.11.08.10.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 10:39:13 -0800 (PST)
Subject: Re: [PATCH] mm: only enable sys_pkey* when ARCH_HAS_PKEYS
References: <1477958904-9903-1-git-send-email-mark.rutland@arm.com>
 <c716d515-409f-4092-73d2-1a81db6c1ba3@linux.intel.com>
 <20161104234459.GA18760@remoulade> <20161108093042.GC3528@osiris>
 <20161108104112.GM1041@n2100.armlinux.org.uk> <20161108112400.GE3528@osiris>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <c4d177e7-c707-93aa-20be-5959d5193655@linux.intel.com>
Date: Tue, 8 Nov 2016 10:39:04 -0800
MIME-Version: 1.0
In-Reply-To: <20161108112400.GE3528@osiris>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>, Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Thomas Gleixner <tglx@linutronix.de>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On 11/08/2016 03:24 AM, Heiko Carstens wrote:
> Something like this:
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 11936526b08b..9fb86b107e49 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -484,6 +484,8 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
>  	return do_mprotect_pkey(start, len, prot, -1);
>  }
>  
> +#ifdef CONFIG_ARCH_HAS_PKEYS
> +
>  SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
>  		unsigned long, prot, int, pkey)
>  {
> @@ -534,3 +536,4 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
>  	 */
>  	return ret;
>  }
> +#endif /* CONFIG_ARCH_HAS_PKEYS */

That's fine with me, fwiw.  It ends up meaning that the config option
changes whether we get -ENOSPC vs. -ENOSYS, so the x86_32 behavior will
change, for instance.  But, I _think_ that's OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
