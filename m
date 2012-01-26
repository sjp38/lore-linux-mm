Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 346016B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 12:31:49 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 26 Jan 2012 12:31:48 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 84B55C902A5
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 12:28:28 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0QHSRxi313968
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 12:28:28 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0QHSQGT007746
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 10:28:27 -0700
Message-ID: <4F218D36.2060308@linux.vnet.ibm.com>
Date: Thu, 26 Jan 2012 09:28:22 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: implement WasActive page flag (for improving cleancache)
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
In-Reply-To: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>

On 01/25/2012 01:58 PM, Dan Magenheimer wrote:
> (Feedback welcome if there is a different/better way to do this
> without using a page flag!)
> 
> Since about 2.6.27, the page replacement algorithm maintains
> an "active" bit to help decide which pages are most eligible
> to reclaim, see http://linux-mm.org/PageReplacementDesign 
> 
> This "active' information is also useful to cleancache but is lost
> by the time that cleancache has the opportunity to preserve the
> pageful of data.  This patch adds a new page flag "WasActive" to
> retain the state.  The flag may possibly be useful elsewhere.

I guess cleancache itself is clearing the bit, right?  I didn't see any
clearing going on in the patch.

I do think it also needs to get cleared on the way in to the page
allocator.  Otherwise:

	PageSetWasActive(page);
	free_page(page);
	...
	another_user_page = get_free_page()
	// now cleancache sees the active bit for the prev user

Or am I missing somewhere it gets cleared non-explicitly somewhere?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
