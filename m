Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id BA0FD6B0037
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 11:23:49 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Tue, 30 Jul 2013 20:43:38 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 97D261258052
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 20:53:12 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6UFOegj33620104
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 20:54:44 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6UFNcJO015380
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:23:39 +1000
Date: Mon, 29 Jul 2013 10:11:04 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] Add rbtree postorder iteration functions, runtime
 tests, and update zswap to use.
Message-ID: <20130729151104.GD4381@variantweb.net>
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

On Fri, Jul 26, 2013 at 02:13:38PM -0700, Cody P Schafer wrote:
> Postorder iteration yields all of a node's children prior to yielding the node
> itself, and this particular implementation also avoids examining the leaf links
> in a node after that node has been yielded.
> 
> In what I expect will be it's most common usage, postorder iteration allows the

s/it's/its/

> deletion of every node in an rbtree without modifying the rbtree nodes (no
> _requirement_ that they be nulled) while avoiding referencing child nodes after
> they have been "deleted" (most commonly, freed).
> 
> I have only updated zswap to use this functionality at this point, but numerous
> bits of code (most notably in the filesystem drivers) use a hand rolled
> postorder iteration that NULLs child links as it traverses the tree. Each of
> those instances could be replaced with this common implementation.

Thanks for doing this Cody!  Other than the nits I've sent, it looks
good.  Whole set:

Reviewed-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

> 
> Cody P Schafer (5):
>   rbtree: add postorder iteration functions.
>   rbtree: add rbtree_postorder_for_each_entry_safe() helper.
>   rbtree_test: add test for postorder iteration.
>   rbtree: allow tests to run as builtin
>   mm/zswap: use postorder iteration when destroying rbtree
> 
>  include/linux/rbtree.h | 21 +++++++++++++++++++++
>  lib/Kconfig.debug      |  2 +-
>  lib/rbtree.c           | 40 ++++++++++++++++++++++++++++++++++++++++
>  lib/rbtree_test.c      | 12 ++++++++++++
>  mm/zswap.c             | 15 ++-------------
>  5 files changed, 76 insertions(+), 14 deletions(-)
> 
> -- 
> 1.8.3.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
