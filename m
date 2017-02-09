From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHv4 1/5] x86/mm: split arch_mmap_rnd() on compat/native
 versions
Date: Thu, 9 Feb 2017 14:55:25 +0100
Message-ID: <20170209135525.qlwrmlo7njk3fsaq@pd.tnic>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com>
 <20170130120432.6716-2-dsafonov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170130120432.6716-2-dsafonov@virtuozzo.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Mon, Jan 30, 2017 at 03:04:28PM +0300, Dmitry Safonov wrote:
> I need those arch_{native,compat}_rnd() to compute separately
> random factor for mmap() in compat syscalls for 64-bit binaries
> and vice-versa for native syscall in 32-bit compat binaries.
> They will be used in the following patches.
> 
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
> ---
>  arch/x86/mm/mmap.c | 25 ++++++++++++++++---------
>  1 file changed, 16 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> index d2dc0438d654..42063e787717 100644
> --- a/arch/x86/mm/mmap.c
> +++ b/arch/x86/mm/mmap.c
> @@ -65,20 +65,27 @@ static int mmap_is_legacy(void)
>  	return sysctl_legacy_va_layout;
>  }
>  
> -unsigned long arch_mmap_rnd(void)
> +#ifdef CONFIG_COMPAT
> +static unsigned long arch_compat_rnd(void)
>  {
> -	unsigned long rnd;
> +	return (get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1))
> +		<< PAGE_SHIFT;
> +}
> +#endif
>  
> -	if (mmap_is_ia32())
> +static unsigned long arch_native_rnd(void)
> +{
> +	return (get_random_long() & ((1UL << mmap_rnd_bits) - 1)) << PAGE_SHIFT;
> +}
> +
> +unsigned long arch_mmap_rnd(void)
> +{
>  #ifdef CONFIG_COMPAT
> -		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
> -#else
> -		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
> +	if (mmap_is_ia32())
> +		return arch_compat_rnd();
>  #endif

I can't say that I'm thrilled about the ifdeffery this is adding.

But I can't think of a cleaner approach at a quick glance, though -
that's generic and arch-specific code intertwined muck. Sad face.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
