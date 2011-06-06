Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DF5DB6B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 04:37:49 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so1724768gwa.14
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 01:37:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602142242.GA4115@maxin>
References: <20110602142242.GA4115@maxin>
Date: Mon, 6 Jun 2011 09:37:46 +0100
Message-ID: <BANLkTimYw-WAK3Hd21XQWrjBn_1+wRMzUQ@mail.gmail.com>
Subject: Re: [PATCH] mm: dmapool: fix possible use after free in dmam_pool_destroy()
From: Maxin B John <maxin.john@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eike-kernel@sf-tec.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dima@android.com, willy@linux.intel.com, segooon@gmail.com, tj@kernel.org, jkosina@suse.cz, tglx@linutronix.de

Hi,

On Thu, Jun 2, 2011 at 3:22 PM, Maxin B John <maxin.john@gmail.com> wrote:
> On Thu, Jun 2, 2011 at 12:47 PM, Rolf Eike Beer <eike-kernel@sf-tec.de> w=
rote:
>> Maxin B John wrote:
>>> "dma_pool_destroy(pool)" calls "kfree(pool)". The freed pointer
>>> "pool" is again passed as an argument to the function "devres_destroy()=
".
>>> This patch fixes the possible use after free.
>>
>> The pool itself is not used there, only the address where the pool
>> has been.This will only lead to any trouble if something else is allocat=
ed to
>> the same place and inserted into the devres list of the same device betw=
een
>> the dma_pool_destroy() and devres_destroy().
>
> Thank you very much for explaining it in detail.
>
>> But I agree that this is bad style. But if you are going to change
>> this please also have a look at devm_iounmap() in lib/devres.c. Maybe al=
so the
>> devm_*irq* functions need the same changes.
>
> As per your suggestion, I have made similar modifications for lib/devres.=
c and
> kernel/irq/devres.c
>
> CCed the maintainers of the respective files.
>
> Signed-off-by: Maxin B. John <maxin.john@gmail.com>
> ---
> diff --git a/kernel/irq/devres.c b/kernel/irq/devres.c
> index 1ef4ffc..bd8e788 100644
> --- a/kernel/irq/devres.c
> +++ b/kernel/irq/devres.c
> @@ -87,8 +87,8 @@ void devm_free_irq(struct device *dev, unsigned int irq=
, void *dev_id)
> =A0{
> =A0 =A0 =A0 =A0struct irq_devres match_data =3D { irq, dev_id };
>
> - =A0 =A0 =A0 free_irq(irq, dev_id);
> =A0 =A0 =A0 =A0WARN_ON(devres_destroy(dev, devm_irq_release, devm_irq_mat=
ch,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &match_data))=
;
> + =A0 =A0 =A0 free_irq(irq, dev_id);
> =A0}
> =A0EXPORT_SYMBOL(devm_free_irq);
> diff --git a/lib/devres.c b/lib/devres.c
> index 6efddf5..7c0e953 100644
> --- a/lib/devres.c
> +++ b/lib/devres.c
> @@ -79,9 +79,9 @@ EXPORT_SYMBOL(devm_ioremap_nocache);
> =A0*/
> =A0void devm_iounmap(struct device *dev, void __iomem *addr)
> =A0{
> - =A0 =A0 =A0 iounmap(addr);
> =A0 =A0 =A0 =A0WARN_ON(devres_destroy(dev, devm_ioremap_release, devm_ior=
emap_match,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (void *)addr)=
);
> + =A0 =A0 =A0 iounmap(addr);
> =A0}
> =A0EXPORT_SYMBOL(devm_iounmap);
>

Could you please let me know your thoughts on this patch ?

Best Regards,
Maxin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
