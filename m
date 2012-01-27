Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 2693F6B005C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 19:31:52 -0500 (EST)
Date: Thu, 26 Jan 2012 16:31:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
Message-Id: <20120126163150.31a8688f.akpm@linux-foundation.org>
In-Reply-To: <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
	<4F218D36.2060308@linux.vnet.ibm.com>
	<9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>

On Thu, 26 Jan 2012 13:28:02 -0800 (PST)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > I do think it also needs to get cleared on the way in to the page
> > allocator.  Otherwise:
> > 
> > 	PageSetWasActive(page);
> > 	free_page(page);
> > 	...
> > 	another_user_page = get_free_page()
> > 	// now cleancache sees the active bit for the prev user
> > 
> > Or am I missing somewhere it gets cleared non-explicitly somewhere?
> 
> True, it is not getting cleared and it should be, good catch!

It should be added to PAGE_FLAGS_CHECK_AT_FREE.

> I'll find the place to add the call to ClearPageWasActive() for v2.

AFAICT this patch consumes our second-last page flag, or close to it. 
We'll all be breaking out in hysterics when the final one is gone.

This does appear to be a make or break thing for cleancache - if we
can't fix https://lkml.org/lkml/2012/1/22/61 then cleancache is pretty
much a dead duck.  But I'm going to ask for great effort to avoid
consuming another page flag.  Either fix cleancache via other means or,
much less desirably, find an existing page flag and overload it.

And I'm afraid that neither I nor other MM developers are likely to
help you with "fix cleancache via other means" because we weren't
provided with any description of what the problem is within cleancache,
nor how it will be fixed.  All we are given is the assertion "cleancache
needs this".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
