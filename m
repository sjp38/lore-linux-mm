Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 34DDA6B039E
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 19:01:28 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so4229269wgb.26
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 16:01:26 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com>
Date: Mon, 25 Jun 2012 19:01:26 -0400
Message-ID: <CAPbh3rvkKZOuGh_Pn9WpeV5_=vA=k9=x17oa2GoT8fEgRMr+WQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon, Jun 25, 2012 at 12:14 PM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> This patch adds support for a local_tlb_flush_kernel_range()
> function for the x86 arch. =A0This function allows for CPU-local
> TLB flushing, potentially using invlpg for single entry flushing,
> using an arch independent function name.

What x86 hardware did you use to figure the optimal number?

>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
> =A0arch/x86/include/asm/tlbflush.h | =A0 21 +++++++++++++++++++++
> =A01 file changed, 21 insertions(+)
>
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbfl=
ush.h
> index 36a1a2a..92a280b 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -168,4 +168,25 @@ static inline void flush_tlb_kernel_range(unsigned l=
ong start,
> =A0 =A0 =A0 =A0flush_tlb_all();
> =A0}
>
> +#define __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE
> +/*
> + * INVLPG_BREAK_EVEN_PAGES is the number of pages after which single tlb
> + * flushing becomes more costly than just doing a complete tlb flush.
> + * While this break even point varies among x86 hardware, tests have sho=
wn
> + * that 8 is a good generic value.
> +*/
> +#define INVLPG_BREAK_EVEN_PAGES 8
> +static inline void local_flush_tlb_kernel_range(unsigned long start,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long end)
> +{
> + =A0 =A0 =A0 if (cpu_has_invlpg &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (end - start)/PAGE_SIZE <=3D INVLPG_BREAK_E=
VEN_PAGES) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (start < end) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __flush_tlb_single(start);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start +=3D PAGE_SIZE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_flush_tlb();
> +}
> +
> =A0#endif /* _ASM_X86_TLBFLUSH_H */
> --
> 1.7.9.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
