Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B664E6B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 02:34:22 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h68so26154716lfh.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 23:34:22 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id t137si12786265wme.74.2016.06.09.23.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 23:34:21 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n184so15503621wmn.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 23:34:21 -0700 (PDT)
Date: Fri, 10 Jun 2016 08:34:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mmots-2016-06-09-16-49] kernel BUG at mm/slub.c:1616
Message-ID: <20160610063419.GB32285@dhcp22.suse.cz>
References: <20160610061139.GA374@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160610061139.GA374@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri 10-06-16 15:11:39, Sergey Senozhatsky wrote:
> Hello,
> 
> [  429.191962] gfp: 2
> [  429.192634] ------------[ cut here ]------------
> [  429.193281] kernel BUG at mm/slub.c:1616!
[...]
> [  429.217369]  [<ffffffff811ca221>] bio_alloc_bioset+0xbd/0x1b1
> [  429.218013]  [<ffffffff81148078>] mpage_alloc+0x28/0x7b
> [  429.218650]  [<ffffffff8114856a>] do_mpage_readpage+0x43d/0x545
> [  429.219282]  [<ffffffff81148767>] mpage_readpages+0xf5/0x152

OK, so this is flags & GFP_SLAB_BUG_MASK BUG_ON because gfp is
___GFP_HIGHMEM. It is my [1] patch which has introduced it.
I think we need the following. Andrew could you fold it into
mm-memcg-use-consistent-gfp-flags-during-readahead.patch or maybe keep
it as a separate patch?

[1] http://lkml.kernel.org/r/1465301556-26431-1-git-send-email-mhocko@kernel.org

Thanks for the report Sergey!

---
