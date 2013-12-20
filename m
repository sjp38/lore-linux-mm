Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f48.google.com (mail-qe0-f48.google.com [209.85.128.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5D92B6B0031
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 03:09:00 -0500 (EST)
Received: by mail-qe0-f48.google.com with SMTP id gc15so2045177qeb.7
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 00:09:00 -0800 (PST)
Received: from eusmtp01.atmel.com (eusmtp01.atmel.com. [212.144.249.243])
        by mx.google.com with ESMTPS id r6si5157275qaj.95.2013.12.20.00.08.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Dec 2013 00:08:59 -0800 (PST)
Date: Fri, 20 Dec 2013 09:08:51 +0100
From: Ludovic Desroches <ludovic.desroches@atmel.com>
Subject: Re: possible regression on 3.13 when calling flush_dcache_page
Message-ID: <20131220080851.GC16592@ldesroches-Latitude-E6320>
References: <20131212143149.GI12099@ldesroches-Latitude-E6320>
 <20131212143618.GJ12099@ldesroches-Latitude-E6320>
 <20131213015909.GA8845@lge.com>
 <20131216144343.GD9627@ldesroches-Latitude-E6320>
 <20131218072117.GA2383@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20131218072117.GA2383@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ludovic Desroches <ludovic.desroches@atmel.com>

Hello,

On Wed, Dec 18, 2013 at 04:21:17PM +0900, Joonsoo Kim wrote:
> On Mon, Dec 16, 2013 at 03:43:43PM +0100, Ludovic Desroches wrote:
> > Hello,
> > 
> > On Fri, Dec 13, 2013 at 10:59:09AM +0900, Joonsoo Kim wrote:
> > > On Thu, Dec 12, 2013 at 03:36:19PM +0100, Ludovic Desroches wrote:
> > > > fix mmc mailing list address error
> > > > 
> > > > On Thu, Dec 12, 2013 at 03:31:50PM +0100, Ludovic Desroches wrote:
> > > > > Hi,
> > > > > 
> > > > > With v3.13-rc3 I have an error when the atmel-mci driver calls
> > > > > flush_dcache_page (log at the end of the message).
> > > > > 
> > > > > Since I didn't have it before, I did a git bisect and the commit introducing
> > > > > the error is the following one:
> > > > > 
> > > > > 106a74e slab: replace free and inuse in struct slab with newly introduced active
> > > > > 
> > > > > I don't know if this commit has introduced a bug or if it has revealed a bug
> > > > > in the atmel-mci driver.
> > > 
> > > Hello,
> > > 
> > > I think that this commit may not introduce a bug. This patch remove one
> > > variable on slab management structure and replace variable name. So there
> > > is no functional change.
> > > 
> > 
> > If I have reverted this patch and other ones you did on top of it and
> > the issue disappear.
> 
> Hello,
> 
> Could you give me your '/proc/slabinfo' before/after this commit (106a74e)?
> 
> And how about testing with artificially increasing size of struct slab on
> top of this commit (106a74e)?
> 
> I really wonder why the problem happens, because this doesn't cause any
> functional change as far as I know. Only side-effect from this patch is
> decreasing size of struct slab.

Sorry I am not at the office, I have tried to reproduce it with a
different device and a different sdcard but without success. I'll test
it on Monday.

Regards

Ludovic

> 
> Thanks.
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 2ec2336..d2240fd 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -174,6 +174,7 @@ struct slab {
>         struct {
>                 struct list_head list;
>                 void *s_mem;            /* including colour offset */
> +               unsigned int x;
>                 unsigned int active;    /* num of objs active in slab */
>         };
>  };
> 
> > 
> > > I doubt that side-effect of this patch reveals a bug in other place.
> > > Side-effect is reduced memory usage for slab management structure. It would
> > > makes some slabs have more objects with more density since slab management
> > > structure is sometimes on the page for objects. So if it diminishes, more
> > > objects can be in the page.
> > > 
> > > Anyway, I will look at it more. If you have any progress, please let me know.
> > 
> > No progress at the moment.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
