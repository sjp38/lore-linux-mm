Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3766B900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 23:42:07 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so21305601pdb.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:42:07 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id k7si3805315pdn.158.2015.06.03.20.42.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 20:42:06 -0700 (PDT)
Received: by payr10 with SMTP id r10so20455269pay.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:42:06 -0700 (PDT)
Date: Thu, 4 Jun 2015 12:42:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 03/10] zsmalloc: introduce zs_can_compact() function
Message-ID: <20150604034230.GH1951@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604025533.GE2241@blaptop>
 <20150604031514.GE1951@swordfish>
 <20150604033014.GG2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604033014.GG2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (06/04/15 12:30), Minchan Kim wrote:
> > -- free objects in class: 5 (free-objs class capacity)
> > -- page1: inuse 2
> > -- page2: inuse 2
> > -- page3: inuse 3
> > -- page4: inuse 2
> 
> What scenario do you have a cocern?
> Could you describe this example more clear?

you mean "how is this even possible"?

well, for example,

make -jX
make clean

can introduce a significant fragmentation. no new objects, just random
objs removal. assuming that we keep some of the objects, allocated during
compilation.

e.g.

...

page1
  allocate baz.so
  allocate foo.o
page2
  allocate bar.o
  allocate foo.so
...
pageN



now `make clean`

page1:
  allocated baz.so
  empty

page2
  empty
  allocated foo.so

...

pageN

in the worst case, every page can turn out to be ALMOST_EMPTY.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
