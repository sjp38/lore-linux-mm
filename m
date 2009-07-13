Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1D64B6B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 22:58:08 -0400 (EDT)
Date: Mon, 13 Jul 2009 11:18:01 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH] switch free memory back to MIGRATE_MOVABLE
Message-ID: <20090713031801.GA4778@sli10-desk.sh.intel.com>
References: <20090713115803.b78a4f4f.kamezawa.hiroyu@jp.fujitsu.com> <20090713030444.GA2582@sli10-desk.sh.intel.com> <20090713120549.6252.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090713120549.6252.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 13, 2009 at 11:08:14AM +0800, KOSAKI Motohiro wrote:
> > On Mon, Jul 13, 2009 at 10:58:03AM +0800, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 13 Jul 2009 11:47:46 +0900 (JST)
> > > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > 
> > > > > When page is back to buddy and its order is bigger than pageblock_order, we can
> > > > > switch its type to MIGRATE_MOVABLE. This can reduce fragmentation. The patch
> > > > > has obvious effect when read a block device and then drop caches.
> > > > > 
> > > > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > > > 
> > > > This patch change hot path, but there is no performance mesurement description.
> > > > Also, I don't like modification buddy core for only drop caches.
> > > > 
> > > Li, does this patch imply fallback of migration type doesn't work well ?
> > > What is the bad case ?
> > The page is initialized as migrate_movable, and then switch to reclaimable or
> > something else when fallback occurs, but its type remains even the page gets
> > freed. When the page gets freed, its type actually can be switch back to movable,
> > this is what the patch does.
> 
> This answer is not actual answer.
> Why do you think __rmqueue_fallback() doesn't works well? Do you have
> any test-case or found a bug by review?
I never said __rmqueue_fallback() doesn't work well. The page is already freed, switching
back the pageblock to movable might make next page allocation (non-movable) skip this
pageblock. So this could potentially reduce fragmentation and improve memory offline.
But your guys are right, I have no number if this will impact performance.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
