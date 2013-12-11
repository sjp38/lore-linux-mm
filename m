Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF066B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 03:44:25 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so9573458pbb.3
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 00:44:25 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id 8si12919370pbe.10.2013.12.11.00.44.23
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 00:44:24 -0800 (PST)
Date: Wed, 11 Dec 2013 17:47:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 7/7] mm/migrate: remove result argument on page
 allocation function for migration
Message-ID: <20131211084719.GA2043@lge.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-8-git-send-email-iamjoonsoo.kim@lge.com>
 <00000142d83adfc7-81b70cc9-c87b-4e7e-bd98-0a97ee21db31-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000142d83adfc7-81b70cc9-c87b-4e7e-bd98-0a97ee21db31-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 04:40:06PM +0000, Christoph Lameter wrote:
> On Mon, 9 Dec 2013, Joonsoo Kim wrote:
> 
> > First, we don't use error number in fail case. Call-path related to
> > new_page_node() is shown in the following.
> >
> > do_move_page_to_node_array() -> migrate_pages() -> unmap_and_move()
> > -> new_page_node()
> >
> > If unmap_and_move() failed, migrate_pages() also returns err, and then
> > do_move_page_to_node_array() skips to set page's status to user buffer.
> > So we don't need to set error number to each pages on failure case.
> 
> I dont get this. new_page_node() sets the error condition in the
> page_to_node array before this patch. There is no post processing in
> do_move_page_to_node_array(). The function simply returns and relies on
> new_page_node() to have set the page status. do_move_pages() then returns
> the page status back to userspace. How does the change preserve these
> diagnostics?

Hello, Christoph.

In do_move_pages(), if error occurs, 'goto out_pm' is executed and the
page status doesn't back to userspace. So we don't need to store err number.

Perhaps my description should be changed something like below.

  *do_move_pages()* -> do_move_page_to_node_array() -> migrate_pages()
  -> unmap_and_move() -> new_page_node()

  If unmap_and_move() failed, migrate_pages() also returns err, and then
  *do_move_pages()* skips to set page's status to user buffer.
  So we don't need to set error number to each pages on failure case.

Is it sufficient explanation?

> 
> > Next, we don't need to set node id of the new page in unmap_and_move(),
> > since it cannot be different with pm->node. In new_page_node(), we always
> > try to allocate the page in exact node by referencing pm->node. So it is
> > sufficient to set node id of the new page in new_page_node(), instead of
> > unmap_and_move().
> 
> Thats a good thought.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
