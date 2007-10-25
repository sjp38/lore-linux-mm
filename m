Date: Wed, 24 Oct 2007 19:50:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 13/14] dentries: Extract common code to remove dentry
 from lru
In-Reply-To: <20071024193458.ca4300be.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710241944340.30425@schroedinger.engr.sgi.com>
References: <20070925232543.036615409@sgi.com> <20070925233008.523093726@sgi.com>
 <20071022142939.1b815680.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0710241921570.29434@schroedinger.engr.sgi.com>
 <20071024193458.ca4300be.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Oct 2007, Andrew Morton wrote:

> > Sometimes we check the list head using list_empty() so we cannot avoid 
> > list_del_init. Always using list_del_init results in a consistent state of 
> > affairs before the object is freed (which the slab defrag patchset depends 
> > on)
> 
> OK, but it's slower.
> 
> So I think it should be changlogged as such, with an explanation that there
> will (hopefully) be a net benefit because it enables slab defrag, and it
> should be moved into the slab-defrag patchset.

really?

list_del_init does:

static inline void list_del_init(struct list_head *entry)
{
        __list_del(entry->prev, entry->next);
        INIT_LIST_HEAD(entry);
}

So it touches the cachelines of the entry and prev/next to fix up the 
links.

list_del does:

#ifndef CONFIG_DEBUG_LIST
static inline void list_del(struct list_head *entry)
{
        __list_del(entry->prev, entry->next);
        entry->next = LIST_POISON1;
        entry->prev = LIST_POISON2;
}
#else
extern void list_del(struct list_head *entry);
#endif

In the !DEBUG case it touches the same cachelines. The only change is that 
we poison entry. 

So its not slower.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
