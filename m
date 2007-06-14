Date: Thu, 14 Jun 2007 00:47:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
In-Reply-To: <20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706140044400.22032@schroedinger.engr.sgi.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
 <20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
 <20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
 <20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, KAMEZAWA Hiroyuki wrote:

> In my understanding:
> 
> PageAnon(page) checks (page->mapping & 0x1). And, as you know, page->mapping
> is not cleared even if the page is removed from rmap.

But in that case the refcount is zero. We will not migrate the page.

> My patch should be
> ==
> +	if (PageAnon(page)) {
> +		anon_vma = page_lock_anon_vma(page);
> ==
> This is my mistake.

Do not worry I make lots of mistakes.... We just need to pool our minds 
and come up with the right solution. I think this is a critical piece of 
code that needs to be right for defrag and for memory unplug.

Why do you lock the page there? Its already locked from sys_move_pages 
etc. This will make normal page migration deadlock.

Just get the anonymous vma address from the mapping like in the last 
conceptual patch that I sent you.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
