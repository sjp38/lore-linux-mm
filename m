Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id A28FE6B004D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 23:26:18 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id wz12so11075409pbc.27
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 20:26:17 -0800 (PST)
Date: Tue, 8 Jan 2013 12:26:09 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch]mm: make madvise(MADV_WILLNEED) support swap file prefetch
Message-ID: <20130108042609.GA2459@kernel.org>
References: <20130107081237.GB21779@kernel.org>
 <20130107120630.82ba51ad.akpm@linux-foundation.org>
 <50eb8180.6887320a.3f90.58b0SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50eb8180.6887320a.3f90.58b0SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, hughd@google.com, riel@redhat.com

On Tue, Jan 08, 2013 at 10:16:07AM +0800, Wanpeng Li wrote:
> On Mon, Jan 07, 2013 at 12:06:30PM -0800, Andrew Morton wrote:
> >On Mon, 7 Jan 2013 16:12:37 +0800
> >Shaohua Li <shli@kernel.org> wrote:
> >
> >> 
> >> Make madvise(MADV_WILLNEED) support swap file prefetch. If memory is swapout,
> >> this syscall can do swapin prefetch. It has no impact if the memory isn't
> >> swapout.
> >
> >Seems sensible.
> 
> Hi Andrew and Shaohua,
> 
> What's the performance in the scenario of serious memory pressure? Since
> in this case pages in swap are highly fragmented and cache hit is most
> impossible. If WILLNEED path should add a check to skip readahead in
> this case since swapin only leads to unnecessary memory allocation. 

pages in swap are not highly fragmented if you access memory sequentially. In
that case, the pages you accessed will be added to lru list side by side. So if
app does swap prefetch, we can do sequential disk access and merge small
request to big one.

Another advantage is prefetch can drive high disk iodepth.  For sequential
access, this can cause big request. Even for random access, high iodepth has
much better performance especially for SSD.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
