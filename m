Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0F716B0038
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 15:44:26 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so571261256pfy.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 12:44:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n6si20836990pla.148.2016.12.06.12.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 12:44:25 -0800 (PST)
Date: Tue, 6 Dec 2016 12:44:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 33/33] Reimplement IDR and IDA using the radix tree
Message-Id: <20161206124453.3d3ce26a1526fedd70988ab8@linux-foundation.org>
In-Reply-To: <1480369871-5271-34-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
	<1480369871-5271-34-git-send-email-mawilcox@linuxonhyperv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>

On Mon, 28 Nov 2016 13:50:37 -0800 Matthew Wilcox <mawilcox@linuxonhyperv.com> wrote:

> The IDR is very similar to the radix tree.  It has some functionality
> that the radix tree did not have (alloc next free, cyclic allocation,
> a callback-based for_each, destroy tree), which is readily implementable
> on top of the radix tree.  A few small changes were needed in order to
> use a tag to represent nodes with free space below them.
> 
> The IDA is reimplemented as a client of the newly enhanced radix tree.
> As in the current implementation, it uses a bitmap at the last level of
> the tree.
> 
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> ---
>  include/linux/idr.h                     |  132 ++--
>  include/linux/radix-tree.h              |    5 +-
>  init/main.c                             |    3 +-
>  lib/idr.c                               | 1078 -------------------------------
>  lib/radix-tree.c                        |  632 ++++++++++++++++--

hm.  It's just a cosmetic issue, but perhaps the idr
wrappers-around-radix-tree code should be in a different .c file.



Before:

akpm3:/usr/src/25> size lib/idr.o lib/radix-tree.o  
   text    data     bss     dec     hex filename
   6566      89      16    6671    1a0f lib/idr.o
  11811     117       8   11936    2ea0 lib/radix-tree.o

After:

   text    data     bss     dec     hex filename
  14151     118       8   14277    37c5 lib/radix-tree.o


So 4500 bytes saved.  Decent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
