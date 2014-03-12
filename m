Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 67E9D6B00AF
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 10:46:46 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id n15so2279890wiw.5
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 07:46:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lp8si4116075wic.73.2014.03.12.07.46.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 07:46:44 -0700 (PDT)
Date: Wed, 12 Mar 2014 15:46:43 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: implement POSIX_FADV_NOREUSE
Message-ID: <20140312144643.GF11831@dhcp22.suse.cz>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
 <20140311140655.GD28292@dhcp22.suse.cz>
 <531F2ABA.6060804@linux.intel.com>
 <20140311142729.1e3e4e51186db4c8ee49a9f4@linux-foundation.org>
 <1394625592.543.52.camel@dinghy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394625592.543.52.camel@dinghy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Senger <lukas@fridolin.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Matthias Wirth <matthias.wirth@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fengguang Wu <fengguang.wu@intel.com>, Shaohua Li <shli@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Jiang Liu <liuj97@gmail.com>, David Rientjes <rientjes@google.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, i4passt <i4passt@lists.cs.fau.de>

On Wed 12-03-14 12:59:52, Lukas Senger wrote:
> > Why don't you use POSIX_FADV_DONTNEED when you no longer use those
> > pages? E.g. on close()?
> 
> Because DONTNEED throws out the pages even if other processes use them
> as well, so additional hacks are needed to prevent that (see for
> example[1]).

OK, that might be indeed to harsh.

[...]
> Ok, we understand that we can't add a page flag. We tried to find a flag
> to recycle but did not succeed. lruvec doesn't have page pointers and we
> don't have access to a pagevec and the file struct at the same time. We
> don't really understand the last suggestion, as we need to save this
> information for more than one page and going over a list every time we
> add something to an lru list doesn't seem like a good idea.
> 
> Would it be acceptable to add a member to struct page for our purpose?

No, it won't be that easy ;).

I think the Andrew's proposal makes sense. Why not simply move the pages
to the tail of inactive LRUs.

Or another approach might be to drop only those pages from the range
which are not mapped by other processes (something like a lite
DONTNEED).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
