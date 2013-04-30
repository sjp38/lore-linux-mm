Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 9C3F46B011B
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:32:43 -0400 (EDT)
Date: Tue, 30 Apr 2013 12:32:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Better active/inactive list balancing
Message-ID: <20130430163230.GB1229@cmpxchg.org>
References: <517B6DF5.70402@gmail.com>
 <517B6E46.30209@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <517B6E46.30209@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mtrr Patt <mtrr.patt@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Sat, Apr 27, 2013 at 02:20:54PM +0800, Mtrr Patt wrote:
> cc linux-mm
> 
> On 04/27/2013 02:19 PM, Mtrr Patt wrote:
> >Hi Johannes,
> >
> >http://lwn.net/Articles/495543/
> >
> >This link said that "When active pages are considered for
> >eviction, they are first moved to the inactive list and unmapped
> >from the address space of the process(es) using them. Thus, once a
> >page moves to the inactive list, any attempt to reference it will
> >generate a page fault; this "soft fault" will cause the page to be
> >removed back to the active list."
> >
> >Why I can't find the codes unmap during page moved from active
> >list to inactive list?

Most architectures have the hardware track the referenced bit in the
page tables, but some don't.  For them, page_referenced_one() will
mark the mapping read-only when clearing the referenced/young bit and
the page fault handler will set the bit manually.

When mapped pages reach the end of the inactive list and have that bit
set, they get activated, see page_check_references().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
