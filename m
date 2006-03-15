Date: Tue, 14 Mar 2006 19:49:11 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page migration: Fail with error if swap not setup
In-Reply-To: <20060314192443.0d121e73.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603141945060.24395@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
 <20060314192443.0d121e73.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Mar 2006, Andrew Morton wrote:

> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > Currently the migration of anonymous pages will silently fail if no swap 
> > is setup.
> 
> Why?

The allocation of the swap page will fail in migrate_pages() and then the 
page is going on the permant failure list. Hmm... This is not a real 
total failure of page migration since file backed pages can be migrated 
without having swap and page migration will continue for those. However, 
all anonymous pages will end up on the failed list. At the end of page 
migration these will be returned to the LRU. Thus they stay where they 
were.

> I mean, if something tries to allocate a swap page and that fails then the
> error should be propagated back.  That's race-free.

It is propaged back in the form of a list of pages that failed to migrate. 
Its just no clear at the end what the reasons for the individual failures
were. Its better just to check for swap availability before migration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
