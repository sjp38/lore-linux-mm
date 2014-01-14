Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF496B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 00:04:48 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bj1so4713428pad.8
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 21:04:48 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id tb5si17691667pac.307.2014.01.13.21.04.46
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 21:04:47 -0800 (PST)
Date: Tue, 14 Jan 2014 14:05:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zswap: Check all pool pages instead of one pool pages
Message-ID: <20140114050528.GA1992@bbox>
References: <000101cf0ea0$f4e7c560$deb75020$@samsung.com>
 <20140113233505.GS1992@bbox>
 <52D4909B.7070107@oracle.com>
 <20140114045022.GZ1992@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140114045022.GZ1992@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Cai Liu <cai.liu@samsung.com>, sjenning@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, liucai.lfn@gmail.com

On Tue, Jan 14, 2014 at 01:50:22PM +0900, Minchan Kim wrote:
> Hello Bob,
> 
> On Tue, Jan 14, 2014 at 09:19:23AM +0800, Bob Liu wrote:
> > 
> > On 01/14/2014 07:35 AM, Minchan Kim wrote:
> > > Hello,
> > > 
> > > On Sat, Jan 11, 2014 at 03:43:07PM +0800, Cai Liu wrote:
> > >> zswap can support multiple swapfiles. So we need to check
> > >> all zbud pool pages in zswap.
> > > 
> > > True but this patch is rather costly that we should iterate
> > > zswap_tree[MAX_SWAPFILES] to check it. SIGH.
> > > 
> > > How about defining zswap_tress as linked list instead of static
> > > array? Then, we could reduce unnecessary iteration too much.
> > > 
> > 
> > But if use linked list, it might not easy to access the tree like this:
> > struct zswap_tree *tree = zswap_trees[type];
> 
> struct zswap_tree {
>     ..
>     ..
>     struct list_head list;
> }
> 
> zswap_frontswap_init()
> {
>     ..
>     ..
>     zswap_trees[type] = tree;
>     list_add(&tree->list, &zswap_list);
> }
> 
> get_zswap_pool_pages(void)
> {
>     struct zswap_tree *cur;
>     list_for_each_entry(cur, &zswap_list, list) {
>         pool_pages += zbud_get_pool_size(cur->pool);
>     }
>     return pool_pages;
> }
> 
> 
> > 
> > BTW: I'm still prefer to use dynamic pool size, instead of use
> > zswap_is_full(). AFAIR, Seth has a plan to replace the rbtree with radix
> > which will be more flexible to support this feature and page migration
> > as well.
> > 
> > > Other question:
> > > Why do we need to update zswap_pool_pages too frequently?
> > > As I read the code, I think it's okay to update it only when user
> > > want to see it by debugfs and zswap_is_full is called.
> > > So could we optimize it out?
> > > 
> > >>
> > >> Signed-off-by: Cai Liu <cai.liu@samsung.com>
> > 
> > Reviewed-by: Bob Liu <bob.liu@oracle.com>
> 
> Hmm, I really suprised you are okay in this code piece where we have
> unnecessary cost most of case(ie, most system has a swap device) in
> *mm* part.
> 
> Anyway, I don't want to merge this patchset.
> If Andrew merge it and anybody doesn't do right work, I will send a patch.
> Cai, Could you redo a patch?
> I don't want to intercept your credit.
> 
> Even, we could optimize to reduce the the number of call as I said in
> previous reply.

You did it already. Please write it out in description.

> 
> Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
