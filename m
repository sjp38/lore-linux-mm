Date: Tue, 30 Oct 2007 16:22:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] hugetlb: Fix quota management for private mappings
Message-Id: <20071030162219.511394fb.akpm@linux-foundation.org>
In-Reply-To: <20071030204615.16585.60817.stgit@kernel>
References: <20071030204554.16585.80588.stgit@kernel>
	<20071030204615.16585.60817.stgit@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, kenchen@google.com, apw@shadowen.org, haveblue@us.ibm.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Oct 2007 13:46:15 -0700
Adam Litke <agl@us.ibm.com> wrote:

> 
> The hugetlbfs quota management system was never taught to handle
> MAP_PRIVATE mappings when that support was added.  Currently, quota is
> debited at page instantiation and credited at file truncation.  This
> approach works correctly for shared pages but is incomplete for private
> pages.  In addition to hugetlb_no_page(), private pages can be instantiated
> by hugetlb_cow(); but this function does not respect quotas.
> 
> Private huge pages are treated very much like normal, anonymous pages.
> They are not "backed" by the hugetlbfs file and are not stored in the
> mapping's radix tree.  This means that private pages are invisible to
> truncate_hugepages() so that function will not credit the quota.
> 
> This patch (based on a prototype provided by Ken Chen) moves quota
> crediting for all pages into free_huge_page().  page->private is used to
> store a pointer to the mapping to which this page belongs.  This is used to
> credit quota on the appropriate hugetlbfs instance.
> 

Consuming page.private on hugetlb pages is a noteworthy change.  I'm in
fact surprised that it's still available.

I'd expect that others (eg Christoph?) have designs upon it as well.  We
need to work out if this is the best use we can put it to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
