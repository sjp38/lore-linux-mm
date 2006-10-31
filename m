From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [RFC] reduce hugetlb_instantiation_mutex usage
Date: Mon, 30 Oct 2006 18:54:46 -0800
Message-ID: <000001c6fc97$ecd8cbd0$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20061027040626.GI11733@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>, Andrew Morton <akpm@osdl.org>
Cc: 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Thursday, October 26, 2006 9:06 PM
> > Alternatively, we could put the page into pagecache whether or not the
> > mapping is MAP_SHARED.  Then pull it out again prior to unlocking it if
> > it's MAP_PRIVATE.  So we're using pagecache just as a way for the
> > concurrent faulter to locate the page.
> 
> Hrm.. interesting if we can make it work.  I'd be worried about cases
> with concurrent PRIVATE and SHARED pages on the same file offset.

I got side tracked on to the radix-tree stuff.  The comments in
hugetlb_no_page() make me wonder whether we have a race issue on
private mapping:

        /*
         * Use page lock to guard against racing truncation
         * before we get page_table_lock.
         */

Private mapping won't use radix tree during instantiation.  What protects
racy truncate against fault in that scenario?  Don't we have a bug here?

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
