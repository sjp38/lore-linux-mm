Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2AE6B0038
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 02:21:23 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj1so5585943pad.30
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 23:21:22 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id cz3si13603967pbc.63.2013.12.17.23.21.20
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 23:21:21 -0800 (PST)
Date: Wed, 18 Dec 2013 16:21:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: possible regression on 3.13 when calling flush_dcache_page
Message-ID: <20131218072117.GA2383@lge.com>
References: <20131212143149.GI12099@ldesroches-Latitude-E6320>
 <20131212143618.GJ12099@ldesroches-Latitude-E6320>
 <20131213015909.GA8845@lge.com>
 <20131216144343.GD9627@ldesroches-Latitude-E6320>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131216144343.GD9627@ldesroches-Latitude-E6320>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, Dec 16, 2013 at 03:43:43PM +0100, Ludovic Desroches wrote:
> Hello,
> 
> On Fri, Dec 13, 2013 at 10:59:09AM +0900, Joonsoo Kim wrote:
> > On Thu, Dec 12, 2013 at 03:36:19PM +0100, Ludovic Desroches wrote:
> > > fix mmc mailing list address error
> > > 
> > > On Thu, Dec 12, 2013 at 03:31:50PM +0100, Ludovic Desroches wrote:
> > > > Hi,
> > > > 
> > > > With v3.13-rc3 I have an error when the atmel-mci driver calls
> > > > flush_dcache_page (log at the end of the message).
> > > > 
> > > > Since I didn't have it before, I did a git bisect and the commit introducing
> > > > the error is the following one:
> > > > 
> > > > 106a74e slab: replace free and inuse in struct slab with newly introduced active
> > > > 
> > > > I don't know if this commit has introduced a bug or if it has revealed a bug
> > > > in the atmel-mci driver.
> > 
> > Hello,
> > 
> > I think that this commit may not introduce a bug. This patch remove one
> > variable on slab management structure and replace variable name. So there
> > is no functional change.
> > 
> 
> If I have reverted this patch and other ones you did on top of it and
> the issue disappear.

Hello,

Could you give me your '/proc/slabinfo' before/after this commit (106a74e)?

And how about testing with artificially increasing size of struct slab on
top of this commit (106a74e)?

I really wonder why the problem happens, because this doesn't cause any
functional change as far as I know. Only side-effect from this patch is
decreasing size of struct slab.

Thanks.

diff --git a/mm/slab.c b/mm/slab.c
index 2ec2336..d2240fd 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -174,6 +174,7 @@ struct slab {
        struct {
                struct list_head list;
                void *s_mem;            /* including colour offset */
+               unsigned int x;
                unsigned int active;    /* num of objs active in slab */
        };
 };

> 
> > I doubt that side-effect of this patch reveals a bug in other place.
> > Side-effect is reduced memory usage for slab management structure. It would
> > makes some slabs have more objects with more density since slab management
> > structure is sometimes on the page for objects. So if it diminishes, more
> > objects can be in the page.
> > 
> > Anyway, I will look at it more. If you have any progress, please let me know.
> 
> No progress at the moment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
