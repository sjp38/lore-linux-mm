Date: Wed, 15 Mar 2006 08:35:17 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page migration: Fail with error if swap not setup
In-Reply-To: <44180D5A.7000202@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0603150827460.26633@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
 <20060314192443.0d121e73.akpm@osdl.org> <Pine.LNX.4.64.0603141945060.24395@schroedinger.engr.sgi.com>
 <20060314195234.10cf35a7.akpm@osdl.org> <Pine.LNX.4.64.0603141955370.24487@schroedinger.engr.sgi.com>
 <44180D5A.7000202@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2006, Nick Piggin wrote:

> > There are a number of possible failure conditions. The strategy of the
> > migration function is to migrate as much as possible and return the rest
> > without giving any reason. migrate_pages() returns the number of leftover
> > pages not the reasons they failed.
> Could you return the reason the first failing page failed. At least then
> the caller can have some idea about what is needed to make further progress.

The return value of migrate_pages() is the number of pages that were not 
migrated. It is up to the caller to figure out why a page was not 
migrated. We could change that in the future but that would be a big 
change to the code. Migrate_pages() makes the best effort at 
migration and categorizes failing pages into those who with permanent 
failures and those which may be retriable. Currently page migration simply 
skips over any soft or hard failures to migrate pages and leaves them in 
place. The current page migration code is intentionally designed to only 
make a reasonable attempt on a group of pages. Earlier code attempted to 
guarantee migration but that never worked the right way and introduced 
unacceptable delays while holding locks.

The calling program may go through the list of failing pages and 
investigate the reasons by inspecting page count, mapping, swap etc. I 
guess we could add some sort of a callback in the future that determines 
what to do on failure. Or add some flags to return immediately if 
migration fails.

But I think the current code is just fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
