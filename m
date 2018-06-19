Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2A76B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 05:22:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j8-v6so4242835pfn.6
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:22:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g1-v6si6316397pgs.377.2018.06.19.02.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 02:22:33 -0700 (PDT)
Date: Tue, 19 Jun 2018 02:22:30 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v14 00/74] Convert page cache to XArray
Message-ID: <20180619092230.GA1438@bombadil.infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
 <20180619031257.GA12527@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180619031257.GA12527@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Mon, Jun 18, 2018 at 09:12:57PM -0600, Ross Zwisler wrote:
> Hit another deadlock.  This one reproduces 100% of the time in my setup with
> XFS + DAX + generic/340.  It doesn't reproduce for me at all with
> next-20180615.  Here's the output from "echo w > /proc/sysrq-trigger":

*sigh*.  I wonder what the differences are between our setups ...

> [   92.849119] sysrq: SysRq : Show Blocked State
> [   92.850506]   task                        PC stack   pid father
> [   92.852299] holetest        D    0  1651   1466 0x00000000
> [   92.853912] Call Trace:
> [   92.854610]  __schedule+0x2c5/0xad0
> [   92.855612]  schedule+0x36/0x90
> [   92.856602]  get_unlocked_entry+0xce/0x120
> [   92.857756]  ? dax_insert_entry+0x2b0/0x2b0
> [   92.858931]  grab_mapping_entry+0x19e/0x250
> [   92.860119]  dax_iomap_pte_fault+0x115/0x1140
> [   92.860836]  dax_iomap_fault+0x37/0x40
...
> This looks very similar to the one I reported last week with generic/269.

Yeah, another missing wakeup, no doubt.  Can you bisect this?  That was
how I found the last one; bisected it to a single patch and stared very
hard at the patch until I saw it.  I'm not going to be in a position to
tinker with my DAX setup until the first week of July.
