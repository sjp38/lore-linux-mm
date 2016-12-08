Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3A936B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 13:42:42 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 20so447613336uak.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 10:42:42 -0800 (PST)
Received: from mail-ua0-x22e.google.com (mail-ua0-x22e.google.com. [2607:f8b0:400c:c08::22e])
        by mx.google.com with ESMTPS id 4si7455291uay.138.2016.12.08.10.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 10:42:42 -0800 (PST)
Received: by mail-ua0-x22e.google.com with SMTP id b35so455737716uaa.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 10:42:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161208162150.148763-26-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com> <20161208162150.148763-26-kirill.shutemov@linux.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 8 Dec 2016 10:42:19 -0800
Message-ID: <CALCETrWE2WSUe-m9MKmKEK44zNQuuECJ_2agnTv=AkLdOFgR=A@mail.gmail.com>
Subject: Re: [RFC, PATCHv1 24/28] x86/mm: add sync_global_pgds() for
 configuration with 5-level paging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Dec 8, 2016 at 8:21 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> This basically restores slightly modified version of original
> sync_global_pgds() which we had before foldedl p4d was introduced.
>
> The only modification is protection against 'address' overflow.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/mm/init_64.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 47 insertions(+)
>
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index a991f5c4c2c4..d637893ac8c2 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -92,6 +92,52 @@ __setup("noexec32=", nonx32_setup);
>   * When memory was added/removed make sure all the processes MM have
>   * suitable PGD entries in the local PGD level page.
>   */
> +#ifdef CONFIG_X86_5LEVEL
> +void sync_global_pgds(unsigned long start, unsigned long end, int removed)
> +{
> +        unsigned long address;
> +
> +       for (address = start; address <= end && address >= start;
> +                       address += PGDIR_SIZE) {
> +                const pgd_t *pgd_ref = pgd_offset_k(address);
> +                struct page *page;
> +
> +                /*
> +                 * When it is called after memory hot remove, pgd_none()
> +                 * returns true. In this case (removed == 1), we must clear
> +                 * the PGD entries in the local PGD level page.
> +                 */
> +                if (pgd_none(*pgd_ref) && !removed)
> +                        continue;

This isn't quite specific to your patch, but can we assert that, if
removed=1, then we're not operating on the vmalloc range?  Because if
we do, this will be racy is nasty ways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
