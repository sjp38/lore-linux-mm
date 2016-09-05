From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 07/20] x86: Provide general kernel support for
	memory encryption
Date: Mon, 5 Sep 2016 17:22:12 +0200
Message-ID: <20160905152211.GD18856@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
	<20160822223646.29880.28794.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160822223646.29880.28794.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Mon, Aug 22, 2016 at 05:36:46PM -0500, Tom Lendacky wrote:
> Adding general kernel support for memory encryption includes:
> - Modify and create some page table macros to include the Secure Memory
>   Encryption (SME) memory encryption mask
> - Update kernel boot support to call an SME routine that checks for and
>   sets the SME capability (the SME routine will grow later and for now
>   is just a stub routine)
> - Update kernel boot support to call an SME routine that encrypts the
>   kernel (the SME routine will grow later and for now is just a stub
>   routine)
> - Provide an SME initialization routine to update the protection map with
>   the memory encryption mask so that it is used by default
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>

...

> diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
> index c98a559..30f7715 100644
> --- a/arch/x86/kernel/head_64.S
> +++ b/arch/x86/kernel/head_64.S
> @@ -95,6 +95,13 @@ startup_64:
>  	jnz	bad_address
>  
>  	/*
> +	 * Enable memory encryption (if available). Add the memory encryption
> +	 * mask to %rbp to include it in the the page table fixup.
> +	 */
> +	call	sme_enable
> +	addq	sme_me_mask(%rip), %rbp
> +
> +	/*
>  	 * Fixup the physical addresses in the page table
>  	 */
>  	addq	%rbp, early_level4_pgt + (L4_START_KERNEL*8)(%rip)
> @@ -116,7 +123,8 @@ startup_64:
>  	movq	%rdi, %rax
>  	shrq	$PGDIR_SHIFT, %rax
>  
> -	leaq	(4096 + _KERNPG_TABLE)(%rbx), %rdx
> +	leaq	(4096 + __KERNPG_TABLE)(%rbx), %rdx
> +	addq	sme_me_mask(%rip), %rdx		/* Apply mem encryption mask */

Please add comments over the line and not at the side...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
