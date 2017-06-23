Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDC916B0388
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:46:23 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u110so10856159wrb.14
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:46:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y3si3519035wmh.28.2017.06.23.01.46.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 01:46:22 -0700 (PDT)
Date: Fri, 23 Jun 2017 10:46:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mmap, aslr: do not enforce legacy mmap on unlimited
 stacks
Message-ID: <20170623084619.GI5308@dhcp22.suse.cz>
References: <20170614082218.12450-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614082218.12450-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
Cc: Jiri Kosina <jkosina@suse.cz>, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, x86@kernel.org

ping?

On Wed 14-06-17 10:22:18, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Since cc503c1b43e0 ("x86: PIE executable randomization") we treat
> applications with RLIMIT_STACK configured to unlimited as legacy
> and so we a) set the mmap_base to 1/3 of address space + randomization
> and b) mmap from bottom to top. This makes some sense as it allows the
> stack to grow really large. On the other hand it reduces the address
> space usable for default mmaps (wihout address hint) quite a lot. We
> have received a bug report that SAP HANA workload has hit into this
> limitation.
> 
> We could argue that the user just got what he asked for when setting
> up the unlimited stack but to be realistic growing stack up to 1/6
> TASK_SIZE (allowed by mmap_base) is pretty much unimited in the real
> life. This would give mmap 20TB of additional address space which is
> quite nice. Especially when it is much more likely to use that address
> space than the reserved stack.
> 
> Digging into the history the original implementation of the
> randomization 8817210d4d96 ("[PATCH] x86_64: Flexmap for 32bit and
> randomized mappings for 64bit") didn't have this restriction.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> I am sending this as a RFC because I am not really sure how to deal with
> this. We might as well ignore the reported issue and claim "do not use
> unlimited stacks" and be done with it. I just stroke me as an unexpected
> behavior.
> 
>  arch/x86/mm/mmap.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> index 19ad095b41df..797295e792b2 100644
> --- a/arch/x86/mm/mmap.c
> +++ b/arch/x86/mm/mmap.c
> @@ -74,9 +74,6 @@ static int mmap_is_legacy(void)
>  	if (current->personality & ADDR_COMPAT_LAYOUT)
>  		return 1;
>  
> -	if (rlimit(RLIMIT_STACK) == RLIM_INFINITY)
> -		return 1;
> -
>  	return sysctl_legacy_va_layout;
>  }
>  
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
