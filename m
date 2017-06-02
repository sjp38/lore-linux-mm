Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFB86B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 10:48:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q27so76964523pfi.8
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 07:48:43 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0091.outbound.protection.outlook.com. [104.47.0.91])
        by mx.google.com with ESMTPS id y13si11946845pgs.86.2017.06.02.07.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 07:48:41 -0700 (PDT)
Subject: Re: [PATCHv6 06/10] x86/mm: Add sync_global_pgds() for configuration
 with 5-level paging
References: <20170524095419.14281-1-kirill.shutemov@linux.intel.com>
 <20170524095419.14281-7-kirill.shutemov@linux.intel.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <86bddb33-4f07-2949-256b-caf931df98d8@virtuozzo.com>
Date: Fri, 2 Jun 2017 17:50:34 +0300
MIME-Version: 1.0
In-Reply-To: <20170524095419.14281-7-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/24/2017 12:54 PM, Kirill A. Shutemov wrote:
> This basically restores slightly modified version of original
> sync_global_pgds() which we had before folded p4d was introduced.
> 
> The only modification is protection against 'addr' overflow.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/mm/init_64.c | 39 +++++++++++++++++++++++++++++++++++++++
>  1 file changed, 39 insertions(+)
> 
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 95651dc58e09..ce410c05d68d 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -92,6 +92,44 @@ __setup("noexec32=", nonx32_setup);
>   * When memory was added make sure all the processes MM have
>   * suitable PGD entries in the local PGD level page.
>   */
> +#ifdef CONFIG_X86_5LEVEL
> +void sync_global_pgds(unsigned long start, unsigned long end)
> +{
> +	unsigned long addr;
> +
> +	for (addr = start; addr <= end; addr += ALIGN(addr + 1, PGDIR_SIZE)) {

                                        addr = ALIGN(addr + 1, PGDIR_SIZE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
