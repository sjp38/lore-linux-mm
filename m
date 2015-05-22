Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id E741B6B0261
	for <linux-mm@kvack.org>; Fri, 22 May 2015 04:34:48 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so39729624wic.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 01:34:48 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id e10si2497799wjq.166.2015.05.22.01.34.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 01:34:47 -0700 (PDT)
Date: Fri, 22 May 2015 10:34:46 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 9/10] x86, mm, pat: Refactor !pat_enabled handling
In-Reply-To: <1431551151-19124-10-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1505220958050.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com> <1431551151-19124-10-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Wed, 13 May 2015, Toshi Kani wrote:

> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -182,7 +182,11 @@ void pat_init_cache_modes(void)
>  	char pat_msg[33];
>  	u64 pat;
>  
> -	rdmsrl(MSR_IA32_CR_PAT, pat);
> +	if (pat_enabled)
> +		rdmsrl(MSR_IA32_CR_PAT, pat);
> +	else
> +		pat = boot_pat_state;

boot_pat_state is 0 if pat is disabled, but this boot_pat_state multi
purpose usage is really horrible. We do 5 things at once with it and
of course all of it completely undocumented.

  	pat_msg[32] = 0;
>  	for (i = 7; i >= 0; i--) {
>  		cache = pat_get_cache_mode((pat >> (i * 8)) & 7,
> @@ -200,28 +204,58 @@ void pat_init(void)
>  	bool boot_cpu = !boot_pat_state;

The crap starts here and this really wants to be distangled.

void pat_init(void)
{
	static bool boot_done;

	if (!boot_done) {
	   	if (!cpu_has_pat)
  			pat_disable("PAT not supported by CPU.");

		if (pat_enabled) {
		   	rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
			if (!boot_pat_state)
				pat_disable("PAT read returns always zero, disabled.");
		}
	} else if (!cpu_has_pat && pat_enabled) {
		/*
		 * If this happens we are on a secondary CPU, but
		 * switched to PAT on the boot CPU. We have no way to
		 * undo PAT.
		 */
		pr_err("PAT enabled but not supported by secondary CPU\n");
		BUG();
	}

	
	if (!pat_enabled) {
	   .....
	} else {
	   .....	
	}

	if (!boot_done) {
	    ....
	    boot_done = true;	
	}
}

And this cleanup wants to be done as a seperate patch before you do
this other stuff.

> @@ -275,16 +309,8 @@ void pat_init(void)
>  		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
>  	}
>  
> -	/* Boot CPU check */
> -	if (!boot_pat_state) {
> -		rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
> -		if (!boot_pat_state) {
> -			pat_disable("PAT read returns always zero, disabled.");
> -			return;
> -		}
> -	}
> -
> -	wrmsrl(MSR_IA32_CR_PAT, pat);
> +	if (pat_enabled)
> +		wrmsrl(MSR_IA32_CR_PAT, pat);

Sigh.

	if (!pat_enabled) {
	   ....
	} else {
	   ....
	}
	
+	if (pat_enabled)

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
