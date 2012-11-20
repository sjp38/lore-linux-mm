Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 95AC66B0095
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 09:29:00 -0500 (EST)
Date: Tue, 20 Nov 2012 22:28:56 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: fadvise interferes with readahead
Message-ID: <20121120142856.GA19467@localhost>
References: <CAGTBQpaDR4+V5b1AwAVyuVLu5rkU=Wc1WeUdLu5ag=WOk5oJzQ@mail.gmail.com>
 <20121120080427.GA11019@localhost>
 <50AB8396.4040504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50AB8396.4040504@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Claudio Freire <klaussfreire@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

> >Yes. The kernel readahead code by design will outperform simple
> >fadvise in the case of clustered random reads. Imagine the access
> >pattern 1, 3, 2, 6, 4, 9. fadvise will trigger 6 IOs literally. While
> 
> You mean it will trigger 6 IOs in the POSIX_FADV_RANDOM case or
> POSIX_FADV_WILLNEED case?

Yes. However note that I'm assuming 1-page sized and prefetch depth
fadvise(POSIX_FADV_WILLNEED) calls in this example. Given more
prefetch depth or good timing, there will be possibility for IO
requests (eg. 3 and 2) be merged at block layer.

> >kernel readahead will likely trigger 3 IOs for 1, 3, 2-9. Because on
> >the page miss for 2, it will detect the existence of history page 1
> >and do readahead properly. For hard disks, it's mainly the number of
> 
> If the first IO read 1, it will call page_cache_sync_read() since
> cache miss,
> if (offset - (ra->prev_pos) >> PAGE_CACHE_SHIFT) <= 1UL)
>     goto initial_readahead;
> If the initial_readahead will be called? Because offset is equal to
> 1 and ra->prev_pos is equal to 0. If my assume is true, 2 also will
> be readahead.

ra->prev_pos is initialized to -1 in file_ra_state_init(), so that if
the very first read is on page 0, it will trigger readahead.

Sorry I gave a confusing example. We may as well use 1001, 1003, 1002,
1006, 1004, 1009 as the example numbers.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
