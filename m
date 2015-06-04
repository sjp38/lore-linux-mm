Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4F07E900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 23:30:56 -0400 (EDT)
Received: by padj3 with SMTP id j3so20215126pad.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:30:56 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ng3si3804486pdb.52.2015.06.03.20.30.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 20:30:55 -0700 (PDT)
Received: by padj3 with SMTP id j3so20214913pad.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:30:55 -0700 (PDT)
Date: Thu, 4 Jun 2015 12:31:18 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 03/10] zsmalloc: introduce zs_can_compact() function
Message-ID: <20150604033118.GG1951@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604025533.GE2241@blaptop>
 <20150604031514.GE1951@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604031514.GE1951@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (06/04/15 12:15), Sergey Senozhatsky wrote:
> I'm still thinking how good it should be.
> 
> for automatic compaction we don't want to uselessly move objects between
> pages and I tend to think that it's better to compact less, than to waste
> more cpu cycless.
> 
> 
> on the other hand, this policy will miss cases like:
> 
> -- free objects in class: 5 (free-objs class capacity)
> -- page1: inuse 2
> -- page2: inuse 2
> -- page3: inuse 3
> -- page4: inuse 2
> 
> so total "insuse" is greater than free-objs class capacity. but, it's
> surely possible to compact this class. partial inuse summ <= free-objs class
> capacity (a partial summ is a ->inuse summ of any two of class pages:
> page1 + page2, page2 + page3, etc.).
> 
> otoh, these partial sums will badly affect performance. may be for automatic
> compaction (the one that happens w/o user interaction) we can do zs_can_compact()
> and for manual compaction (the one that has been triggered by a user) we can
> old "full-scan".
> 
> anyway, zs_can_compact() looks like something that we can optimize
> independently later.
> 

so what I'm thinking of right now, is:

-- first do "if we have enough free objects to free at least one page"
check. compact if true.

  -- if false, then we can do on a per-page basis
     "if page->inuse <= class free-objs capacity" then compact it,
     else select next almost_empty page.

     here would be helpful to have pages ordered by ->inuse. but this
     is far to expensive.


I have a patch that I will post later that introduces weak/partial
page ordering within fullness_list (really inexpensive: just one int
compare to add a page with a higher ->inuse to list head instead of
list tail).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
