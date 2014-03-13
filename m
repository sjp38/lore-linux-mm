Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA0B6B0031
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 08:42:38 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e51so388967eek.7
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 05:42:37 -0700 (PDT)
Received: from moutng.kundenserver.de (moutng.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id w48si4285608een.203.2014.03.13.05.42.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Mar 2014 05:42:36 -0700 (PDT)
Message-ID: <1394714453.542.38.camel@dinghy>
Subject: Re: [PATCH] mm: implement POSIX_FADV_NOREUSE
From: Lukas Senger <lukas@fridolin.com>
Date: Thu, 13 Mar 2014 13:40:53 +0100
In-Reply-To: <532085E3.5030904@linux.intel.com>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
	 <20140311140655.GD28292@dhcp22.suse.cz> <531F2ABA.6060804@linux.intel.com>
	 <20140311142729.1e3e4e51186db4c8ee49a9f4@linux-foundation.org>
	 <1394625592.543.52.camel@dinghy> <532085E3.5030904@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Matthias Wirth <matthias.wirth@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce
 Fields" <bfields@fieldses.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fengguang Wu <fengguang.wu@intel.com>, Shaohua Li <shli@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Minchan Kim <minchan@kernel.org>, "Kirill
 A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Jiang Liu <liuj97@gmail.com>, David Rientjes <rientjes@google.com>, "Srivatsa S.
 Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, i4passt <i4passt@lists.cs.fau.de>


> But, why wouldn't this work there?  Define a percpu variable, and assign
> it to the target page in readahead's read_pages() and in
> do_generic_file_read() which deal with pages one at a time and not in lists.
> 
> struct page *read_me_once;
> void hint_page_read_once(struct page *page)
> {
> 	read_me_once = page;
> }
> 
> Then check for (read_me_once == page) in add_page_to_lru_list() instead
> of the page flag.  Then, make read_me_once per-cpu.  This won't be
> preempt safe, but we're talking about readahead and hints here, so we
> can probably just bail in the cases where we race.

Thanks for clarifying that. The problem now is that by the time we get
to add_page_to_lru_list we're dealing with multiple pages again, because
of the buffering in pagevecs. We could do the (read_me_once == page)
check in __lru_cache_add and then add it to a (new) lru_add_tail_pvec
that adds its pages to the tail of the lru_lists.

If this way isn't feasible, we'll take a look at Andrew and Michal's
DONTNEED lite idea. However, with a DONTNEED lite implemented in the
posix_fadvise, the syscall would be more cumbersome to use for
application programmers. They would need to call it after every read.
The tail-pvec approach only needs a single syscall after open, as do
NORMAL, SEQUENTIAL and RANDOM. Furthermore we suspect that implementing
it in a way that respects other processes (unlike DONTNEED) won't be
much simpler than the tail-pvec approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
