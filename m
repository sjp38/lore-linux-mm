Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0336B0032
	for <linux-mm@kvack.org>; Sun, 31 May 2015 06:15:31 -0400 (EDT)
Received: by wgez8 with SMTP id z8so92949386wge.0
        for <linux-mm@kvack.org>; Sun, 31 May 2015 03:15:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ew7si16745371wjc.139.2015.05.31.03.15.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 31 May 2015 03:15:29 -0700 (PDT)
Message-ID: <556ADF39.4080709@suse.com>
Date: Sun, 31 May 2015 12:15:21 +0200
From: Juergen Gross <jgross@suse.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] x86/pat: Merge pat_init_cache_modes() into its caller
References: <20150531094655.GA20440@pd.tnic> <1433065686-20922-1-git-send-email-bp@alien8.de> <1433065686-20922-2-git-send-email-bp@alien8.de>
In-Reply-To: <1433065686-20922-2-git-send-email-bp@alien8.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, arnd@arndb.de, Elliott@hp.com, hch@lst.de, hmh@hmh.eng.br, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, konrad.wilk@oracle.com, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, stefan.bader@canonical.com, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, x86-ml <x86@kernel.org>, yigal@plexistor.com

On 05/31/2015 11:48 AM, Borislav Petkov wrote:
> From: Borislav Petkov <bp@suse.de>
>
> This way we can pass pat MSR value directly.
>
> No functionality change.

You are breaking the Xen build with that change. pat_init_cache_modes()
is called from arch/x86/xen/enlighten.c as well.


Juergen

>
> Signed-off-by: Borislav Petkov <bp@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: arnd@arndb.de
> Cc: Elliott@hp.com
> Cc: hch@lst.de
> Cc: hmh@hmh.eng.br
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: jgross@suse.com
> Cc: konrad.wilk@oracle.com
> Cc: linux-mm <linux-mm@kvack.org>
> Cc: linux-nvdimm@lists.01.org
> Cc: Luis R. Rodriguez <mcgrof@suse.com>
> Cc: stefan.bader@canonical.com
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Toshi Kani <toshi.kani@hp.com>
> Cc: x86-ml <x86@kernel.org>
> Cc: yigal@plexistor.com
> ---
>   arch/x86/mm/pat.c | 39 ++++++++++++++++-----------------------
>   1 file changed, 16 insertions(+), 23 deletions(-)
>
> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> index 476d0780560f..4d28759f5a1a 100644
> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -172,32 +172,14 @@ static enum page_cache_mode pat_get_cache_mode(unsigned pat_val, char *msg)
>
>   #undef CM
>
> -/*
> - * Update the cache mode to pgprot translation tables according to PAT
> - * configuration.
> - * Using lower indices is preferred, so we start with highest index.
> - */
> -void pat_init_cache_modes(void)
> -{
> -	int i;
> -	enum page_cache_mode cache;
> -	char pat_msg[33];
> -	u64 pat;
> -
> -	rdmsrl(MSR_IA32_CR_PAT, pat);
> -	pat_msg[32] = 0;
> -	for (i = 7; i >= 0; i--) {
> -		cache = pat_get_cache_mode((pat >> (i * 8)) & 7,
> -					   pat_msg + 4 * i);
> -		update_cache_mode_entry(i, cache);
> -	}
> -	pr_info("x86/PAT: Configuration [0-7]: %s\n", pat_msg);
> -}
> -
>   #define PAT(x, y)	((u64)PAT_ ## y << ((x)*8))
>
>   static void pat_bsp_init(u64 pat)
>   {
> +	enum page_cache_mode cache;
> +	char pat_msg[33];
> +	int i;
> +
>   	if (!cpu_has_pat) {
>   		pat_disable("PAT not supported by CPU.");
>   		return;
> @@ -211,7 +193,18 @@ static void pat_bsp_init(u64 pat)
>
>   	wrmsrl(MSR_IA32_CR_PAT, pat);
>
> -	pat_init_cache_modes();
> +	pat_msg[32] = 0;
> +
> +	/*
> +	 * Update the cache mode to pgprot translation tables according to PAT
> +	 * configuration. Using lower indices is preferred, so we start with
> +	 * highest index.
> +	 */
> +	for (i = 7; i >= 0; i--) {
> +		cache = pat_get_cache_mode((pat >> (i * 8)) & 7, pat_msg + 4 * i);
> +		update_cache_mode_entry(i, cache);
> +	}
> +	pr_info("x86/PAT: Configuration [0-7]: %s\n", pat_msg);
>   }
>
>   static void pat_ap_init(u64 pat)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
