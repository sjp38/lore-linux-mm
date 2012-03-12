Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 412ED6B0044
	for <linux-mm@kvack.org>; Sun, 11 Mar 2012 20:28:14 -0400 (EDT)
Received: by dadv6 with SMTP id v6so4804002dad.14
        for <linux-mm@kvack.org>; Sun, 11 Mar 2012 17:28:13 -0700 (PDT)
Date: Mon, 12 Mar 2012 09:28:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Control page reclaim granularity
Message-ID: <20120312002806.GA2436@barrios>
References: <20120308093514.GA28856@barrios>
 <20120308165403.GA10005@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120308165403.GA10005@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com

On Fri, Mar 09, 2012 at 12:54:03AM +0800, Zheng Liu wrote:
> Hi Minchan,
> 
> Sorry, I forgot to say that I don't subscribe linux-mm and linux-kernel
> mailing list.  So please Cc me.
> 
> IMHO, maybe we should re-think about how does user use mmap(2).  I
> describe the cases I known in our product system.  They can be
> categorized into two cases.  One is mmaped all data files into memory
> and sometime it uses write(2) to append some data, and another uses
> mmap(2)/munmap(2) and read(2)/write(2) to manipulate the files.  In the
> second case,  the application wants to keep mmaped page into memory and
> let file pages to be reclaimed firstly.  So, IMO, when application uses
> mmap(2) to manipulate files, it is possible to imply that it wants keep
> these mmaped pages into memory and do not be reclaimed.  At least these
> pages do not be reclaimed early than file pages.  I think that maybe we
> can recover that routine and provide a sysctl parameter to let the user
> to set this ratio between mmaped pages and file pages.

I am not convinced why we should handle mapped page specially.
Sometimem, someone may use mmap by reducing buffer copy compared to read system call.
So I think we can't make sure mmaped pages are always win.

My suggestion is that it would be better to declare by user explicitly.
I think we can implement it by madvise and fadvise's WILLNEED option.
Current implementation is just readahead if there isn't a page in memory but I think
we can promote from inactive to active if there is already a page in
memory.

It's more clear and it couldn't be affected by kernel page reclaim algorithm change
like this.

> 
> Regards,
> Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
