Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id D4A2C6B0098
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 08:00:33 -0400 (EDT)
Received: by mail-ea0-f171.google.com with SMTP id n15so4878368ead.2
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 05:00:33 -0700 (PDT)
Received: from moutng.kundenserver.de (moutng.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id w48si46909691een.77.2014.03.12.05.00.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Mar 2014 05:00:32 -0700 (PDT)
Message-ID: <1394625592.543.52.camel@dinghy>
Subject: Re: [PATCH] mm: implement POSIX_FADV_NOREUSE
From: Lukas Senger <lukas@fridolin.com>
Date: Wed, 12 Mar 2014 12:59:52 +0100
In-Reply-To: <20140311142729.1e3e4e51186db4c8ee49a9f4@linux-foundation.org>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
	 <20140311140655.GD28292@dhcp22.suse.cz> <531F2ABA.6060804@linux.intel.com>
	 <20140311142729.1e3e4e51186db4c8ee49a9f4@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, Matthias Wirth <matthias.wirth@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce
 Fields" <bfields@fieldses.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fengguang Wu <fengguang.wu@intel.com>, Shaohua Li <shli@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Minchan Kim <minchan@kernel.org>, "Kirill
 A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Jiang Liu <liuj97@gmail.com>, David Rientjes <rientjes@google.com>, "Srivatsa S.
 Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, i4passt <i4passt@lists.cs.fau.de>

> Why don't you use POSIX_FADV_DONTNEED when you no longer use those
> pages? E.g. on close()?

Because DONTNEED throws out the pages even if other processes use them
as well, so additional hacks are needed to prevent that (see for
example[1]).

> This also looks to ignore the reuse flag for existing pages.  Have you
> thought about what the semantics should be there?

The idea is to only treat the pages special when they are first read
from disk. This way we achieve the main goal of not displacing useful
cache content.

> Also, *should* readahead pages really have this flag set?  If a very
> important page gets brought in via readahead, doesn't this put it at a
> disadvantage for getting aged out?

If the flag is not set on readahead pages, the advise barely has any
effect at all, since most of the file gets read through readahead. Of
course that very important page has a disadvantage at the beginning, but
as soon as it has been moved into the active list the NOREUSE doesn't
affect it anymore. Worst case it gets read once more without the flag.

On Tue, 2014-03-11 at 14:27 -0700, Andrew Morton wrote:
> And it sets PG_noreuse on new pages whether or not they were within the
> fadvise range (offset...offset+len).  It's not really an fadvise
> operation at all.

NORMAL, SEQUENTIAL and RANDOM don't honor the range either. So we
figured it would be ok to do so for the sake of keeping the
implementation simple.

> > page flags are really scarce and I am not sure this is the best
> usage of
> > the few remaining slots.
> 
> Yeah, especially since the use so so transient.  I can see why using a
> flag is nice for a quick prototype, but this is a far cry from needing
> one. :)  You might be able to reuse a bit like PageReadahead.  You
> could
> probably also use a bit in the page pointer of the lruvec, or even
> have
> a percpu variable that stores a pointer to the 'struct page' you want
> to
> mark as NOREUSE.

Ok, we understand that we can't add a page flag. We tried to find a flag
to recycle but did not succeed. lruvec doesn't have page pointers and we
don't have access to a pagevec and the file struct at the same time. We
don't really understand the last suggestion, as we need to save this
information for more than one page and going over a list every time we
add something to an lru list doesn't seem like a good idea.

Would it be acceptable to add a member to struct page for our purpose?

---

[1] http://insights.oetiker.ch/linux/fadvise.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
