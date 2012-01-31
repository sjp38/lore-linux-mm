Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 730C96B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 09:47:44 -0500 (EST)
Date: Tue, 31 Jan 2012 09:47:34 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-ID: <20120131144734.GA4378@redhat.com>
References: <1327996780.21268.42.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327996780.21268.42.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Wu Fengguang <wfg@linux.intel.com>

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

Why IO is not submitted because of plug? Doesn't task now get scheduled
out causing an unplug? IOW, are we now busy waiting somewhere preventing
unplug?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
