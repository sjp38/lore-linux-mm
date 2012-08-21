Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 51A906B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 18:53:02 -0400 (EDT)
Subject: Re: [RFC PATCH 2/2] mm: Batch page_check_references in
 shrink_page_list sharing the same i_mmap_mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20120821132129.GC6960@linux.intel.com>
References: <1345251998.13492.235.camel@schen9-DESK>
	 <1345480982.13492.239.camel@schen9-DESK>
	 <20120821132129.GC6960@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Aug 2012 15:53:01 -0700
Message-ID: <1345589581.13492.259.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>

On Tue, 2012-08-21 at 09:21 -0400, Matthew Wilcox wrote:

> 
> The only clunky bit would seem to be this bit:
> 
> >  		if (page_mapped(page) && mapping) {
> > -			switch (try_to_unmap(page, TTU_UNMAP)) {
> > +			switch (try_to_unmap(page, TTU_UNMAP,
> > +						mmap_mutex_locked)) {
> 
> Which I think has to look like this:
> 
> 		if (page_mapped(page) && mapping) {
> -			switch (try_to_unmap(page, TTU_UNMAP)) {
> +			int result;
> +			if (i_mmap_mutex)
> +				result = __try_to_unmap(page, TTU_UNMAP);
> +			else
> +				result = try_to_unmap(page, TTU_UNMAP);
> +			switch (result) {
> 

I think

-			switch (try_to_unmap(page, TTU_UNMAP)) {
+ 			switch (__try_to_unmap(page, TTU_UNMAP)) {

should be enough when your changes are adopted.  Because if the page
mmap mutex needs to be locked, we will have locked it here before
__try_to_unmap gets used.  

+               if (needs_page_mmap_mutex(page) &&
+                               i_mmap_mutex != &page->mapping->i_mmap_mutex) {
+                       if (i_mmap_mutex)
+                               mutex_unlock(i_mmap_mutex);
+                       i_mmap_mutex = &page->mapping->i_mmap_mutex;
+                       mutex_lock(i_mmap_mutex);
+               }


Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
