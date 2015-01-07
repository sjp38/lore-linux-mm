Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB266B006E
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 19:43:44 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id z20so5063053igj.16
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 16:43:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v14si386101icn.79.2015.01.06.16.43.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 16:43:42 -0800 (PST)
Date: Tue, 6 Jan 2015 16:43:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm:change meminfo cached calculation
Message-Id: <20150106164340.55e83f742d6f57c19e6500ff@linux-foundation.org>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103EDAF89E160@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
	<CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
	<35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
	<20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
	<35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
	<20141208114601.GA28846@node.dhcp.inet.fi>
	<35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
	<CALYGNiMEytHuND37f+hNdMKqCPzN0k_uha6CaeL_fyzrj-obNQ@mail.gmail.com>
	<35FD53F367049845BC99AC72306C23D103E688B31408@CNBJMBX05.corpusers.net>
	<35FD53F367049845BC99AC72306C23D103EDAF89E14C@CNBJMBX05.corpusers.net>
	<35FD53F367049845BC99AC72306C23D103EDAF89E160@CNBJMBX05.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: "'minchan@kernel.org'" <minchan@kernel.org>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, "'Kirill A. Shutemov'" <kirill@shutemov.name>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'n-horiguchi@ah.jp.nec.com'" <n-horiguchi@ah.jp.nec.com>, "'pintu.k@samsung.com'" <pintu.k@samsung.com>, Hugh Dickins <hughd@google.com>linux-mm@kvack.org

On Fri, 26 Dec 2014 19:56:49 +0800 "Wang, Yalin" <Yalin.Wang@sonymobile.com> wrote:

> This patch subtract sharedram from cached,
> sharedram can only be swap into swap partitions,
> they should be treated as swap pages, not as cached pages.
> 
> ...
>
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -45,7 +45,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  	committed = percpu_counter_read_positive(&vm_committed_as);
>  
>  	cached = global_page_state(NR_FILE_PAGES) -
> -			total_swapcache_pages() - i.bufferram;
> +			total_swapcache_pages() - i.bufferram - i.sharedram;
>  	if (cached < 0)
>  		cached = 0;

Documentation/filesystems/proc.txt says

:      Cached: in-memory cache for files read from the disk (the
:              pagecache).  Doesn't include SwapCached

So yes, I guess it should not include shmem.

And why not do this as well?


--- a/Documentation/filesystems/proc.txt~mm-change-meminfo-cached-calculation-fix
+++ a/Documentation/filesystems/proc.txt
@@ -811,7 +811,7 @@ MemAvailable: An estimate of how much me
      Buffers: Relatively temporary storage for raw disk blocks
               shouldn't get tremendously large (20MB or so)
       Cached: in-memory cache for files read from the disk (the
-              pagecache).  Doesn't include SwapCached
+              pagecache).  Doesn't include SwapCached or Shmem.
   SwapCached: Memory that once was swapped out, is swapped back in but
               still also is in the swapfile (if memory is needed it
               doesn't need to be swapped out AGAIN because it is already
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
