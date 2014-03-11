Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE2A6B00A6
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 11:34:19 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so8979270pbb.15
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 08:34:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ha5si20581976pbc.120.2014.03.11.08.34.17
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 08:34:18 -0700 (PDT)
Message-ID: <531F2ABA.6060804@linux.intel.com>
Date: Tue, 11 Mar 2014 08:24:42 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: implement POSIX_FADV_NOREUSE
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com> <20140311140655.GD28292@dhcp22.suse.cz>
In-Reply-To: <20140311140655.GD28292@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Matthias Wirth <matthias.wirth@gmail.com>
Cc: Lukas Senger <lukas@fridolin.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fengguang Wu <fengguang.wu@intel.com>, Shaohua Li <shli@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Jiang Liu <liuj97@gmail.com>, David Rientjes <rientjes@google.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/11/2014 07:06 AM, Michal Hocko wrote:
>> > In our implementation pages marked with the NoReuse flag are added to
>> > the tail of the LRU list the first time they are read. Therefore they
>> > are the first to be reclaimed.
> page flags are really scarce and I am not sure this is the best usage of
> the few remaining slots.

Yeah, especially since the use so so transient.  I can see why using a
flag is nice for a quick prototype, but this is a far cry from needing
one. :)  You might be able to reuse a bit like PageReadahead.  You could
probably also use a bit in the page pointer of the lruvec, or even have
a percpu variable that stores a pointer to the 'struct page' you want to
mark as NOREUSE.

This also looks to ignore the reuse flag for existing pages.  Have you
thought about what the semantics should be there?

Also, *should* readahead pages really have this flag set?  If a very
important page gets brought in via readahead, doesn't this put it at a
disadvantage for getting aged out?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
