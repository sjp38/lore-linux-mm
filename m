Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB596B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 14:30:45 -0400 (EDT)
Received: by vxk20 with SMTP id 20so100444vxk.14
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 11:30:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com>
	<BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com>
	<BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com>
	<alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>
Date: Wed, 1 Jun 2011 22:30:43 +0400
Message-ID: <BANLkTinrviHh40fTfqyeB=SrcNS0yqZM0w@mail.gmail.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 6/1/11, David Rientjes <rientjes@google.com> wrote:
> On Wed, 1 Jun 2011, Dmitry Eremin-Solenikov wrote:
>
>> I've hit this with IrDA driver on PXA. Also I've seen the report regarding
>> other ARM platform (ep-something). Thus I've included Russell in the cc.
>>
>
> So you want to continue to allow the page allocator to return pages from
> anywhere, even when GFP_DMA is specified, just as though it was lowmem?

Yes and no. I'm asking for the grace period for the drivers authors to be able
to fix their code. After a grace period of one or two majors this permission
should be removed and your original patch should be effective.

> Why don't you actually address the problem with the driver you're
> complaining about with the patch below, which I already posted to you a
> few days ago?
>
> If this arm driver is going to be using GFP_DMA unconditionally, it better
> require CONFIG_ZONE_DMA for it to actually be meaningful until such time
> as it can be removed if it's truly not needed or generalized to only
> specific pieces of hardware.

No. This only workarounds the bug. And also a possible hundred of other bugs
in the PXA/etc. ARM drivers. Instead I'm asking for the way to
visualize all such
bugs.

Do you want to also add such workarounds to some PATA CF driver used on PXA?
To _any_ of the drivers allocating the GFP_DMA memory? Then CONFIG_ZONE_DMA
would serve no purpose. We can as well to drop that symbol. Believe me.

> ---
>  drivers/net/irda/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
> --- a/drivers/net/irda/Kconfig
> +++ b/drivers/net/irda/Kconfig
> @@ -374,6 +374,7 @@ config VIA_FIR
>  config PXA_FICP
>  	tristate "Intel PXA2xx Internal FICP"
>  	depends on ARCH_PXA && IRDA
> +	select ZONE_DMA
>  	help
>  	  Say Y or M here if you want to build support for the PXA2xx
>  	  built-in IRDA interface which can support both SIR and FIR.
>


-- 
With best wishes
Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
