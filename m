Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3190C6B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 17:27:34 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so117131pde.11
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 14:27:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id nc6si212346pbc.263.2014.03.11.14.27.33
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 14:27:33 -0700 (PDT)
Date: Tue, 11 Mar 2014 14:27:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: implement POSIX_FADV_NOREUSE
Message-Id: <20140311142729.1e3e4e51186db4c8ee49a9f4@linux-foundation.org>
In-Reply-To: <531F2ABA.6060804@linux.intel.com>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
	<20140311140655.GD28292@dhcp22.suse.cz>
	<531F2ABA.6060804@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.cz>, Matthias Wirth <matthias.wirth@gmail.com>, Lukas Senger <lukas@fridolin.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fengguang Wu <fengguang.wu@intel.com>, Shaohua Li <shli@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Jiang Liu <liuj97@gmail.com>, David Rientjes <rientjes@google.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 11 Mar 2014 08:24:42 -0700 Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 03/11/2014 07:06 AM, Michal Hocko wrote:
> >> > In our implementation pages marked with the NoReuse flag are added to
> >> > the tail of the LRU list the first time they are read. Therefore they
> >> > are the first to be reclaimed.
> > page flags are really scarce and I am not sure this is the best usage of
> > the few remaining slots.
> 
> Yeah, especially since the use so so transient.

Yes, we're short on page flags.

> This also looks to ignore the reuse flag for existing pages. 

And it sets PG_noreuse on new pages whether or not they were within the
fadvise range (offset...offset+len).  It's not really an fadvise
operation at all.

A practical implementation might go through the indicated pages, clear
any referenced bits and move them to the tail of the inactive LRU?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
