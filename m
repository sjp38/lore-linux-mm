Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id BFC696B009D
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 10:06:58 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id t61so10075293wes.16
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 07:06:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hu4si21442803wjb.92.2014.03.11.07.06.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 07:06:57 -0700 (PDT)
Date: Tue, 11 Mar 2014 15:06:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: implement POSIX_FADV_NOREUSE
Message-ID: <20140311140655.GD28292@dhcp22.suse.cz>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Wirth <matthias.wirth@gmail.com>
Cc: Lukas Senger <lukas@fridolin.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fengguang Wu <fengguang.wu@intel.com>, Shaohua Li <shli@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Jiang Liu <liuj97@gmail.com>, David Rientjes <rientjes@google.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 11-03-14 11:25:41, Matthias Wirth wrote:
> Backups, logrotation and indexers don't need files they read to remain
> in the page cache. Their pages can be reclaimed early and should not
> displace useful pages. POSIX specifices the POSIX_FADV_NOREUSE flag for
> these use cases but it's currently a noop.

Why don't you use POSIX_FADV_DONTNEED when you no longer use those
pages? E.g. on close()?

> In our implementation pages marked with the NoReuse flag are added to
> the tail of the LRU list the first time they are read. Therefore they
> are the first to be reclaimed.

page flags are really scarce and I am not sure this is the best usage of
the few remaining slots.

> We needed to add flags to the file and page structs in order to pass
> down the hint to the actual call to list_add.
> 
> Signed-off-by: Matthias Wirth <matthias.wirth@gmail.com>
> Signed-off-by: Lukas Senger <lukas@fridolin.com>
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
