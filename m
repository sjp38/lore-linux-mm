Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E02576B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 03:33:32 -0400 (EDT)
Date: Wed, 18 Aug 2010 16:32:34 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/9] Hugepage migration (v2)
Message-ID: <20100818073234.GA28961@spritzera.linux.bs1.fc.nec.co.jp>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1008110806070.673@router.home>
 <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
 <alpine.DEB.2.00.1008130744550.27542@router.home>
 <20100816091935.GB3388@spritzera.linux.bs1.fc.nec.co.jp>
 <alpine.DEB.2.00.1008160707420.11420@router.home>
 <20100817023719.GC12736@spritzera.linux.bs1.fc.nec.co.jp>
 <20100817081817.GA28969@spritzera.linux.bs1.fc.nec.co.jp>
 <20100817094007.GA18161@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100817094007.GA18161@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 11:40:08AM +0200, Andi Kleen wrote:
> > When get_user_pages_fast() is called before try_to_unmap(),
> > direct I/O code increments refcount on the target page.
> > Because this refcount is not associated to the mapping,
> > migration code will find remaining refcounts after try_to_unmap()
> > unmaps all mappings. Then refcount check decides migration to fail,
> > so direct I/O is continued safely.
> 
> This would imply that direct IO can make migration fail arbitarily.
> Also not good. Should we add some retries, at least for the soft offline
> case?

Soft offline is kicked from userspace, so the retry logic can be implemented
in userspace. However, currently we can't distinguish migration failure from
"unknown page" error by return value (-EIO in both case for now.)
How about changing return value to -EAGAIN when migration failed?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
