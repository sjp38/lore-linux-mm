Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 631DB6B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 03:36:48 -0500 (EST)
Date: Tue, 31 Jan 2012 03:36:40 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-ID: <20120131083640.GA13556@infradead.org>
References: <1327996780.21268.42.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327996780.21268.42.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Wu Fengguang <wfg@linux.intel.com>

On Tue, Jan 31, 2012 at 03:59:40PM +0800, Shaohua Li wrote:
> Herbert Poetzl reported a performance regression since 2.6.39. The test
> is a simple dd read, but with big block size. The reason is:
> 
> T1: ra (A, A+128k), (A+128k, A+256k)
> T2: lock_page for page A, submit the 256k
> T3: hit page A+128K, ra (A+256k, A+384). the range isn't submitted
> because of plug and there isn't any lock_page till we hit page A+256k
> because all pages from A to A+256k is in memory
> T4: hit page A+256k, ra (A+384, A+ 512). Because of plug, the range isn't
> submitted again.
> T5: lock_page A+256k, so (A+256k, A+512k) will be submitted. The task is
> waitting for (A+256k, A+512k) finish.
> 
> There is no request to disk in T3 and T4, so readahead pipeline breaks.
> 
> We really don't need block plug for generic_file_aio_read() for buffered
> I/O. The readahead already has plug and has fine grained control when I/O
> should be submitted. Deleting plug for buffered I/O fixes the regression.
> 
> One side effect is plug makes the request size 256k, the size is 128k
> without it. This is because default ra size is 128k and not a reason we
> need plug here.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> Tested-by: Herbert Poetzl <herbert@13thfloor.at>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Please also CC -stable on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
