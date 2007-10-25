Date: Wed, 24 Oct 2007 20:03:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 13/14] dentries: Extract common code to remove dentry
 from lru
Message-Id: <20071024200311.6bb6bbd8.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0710241944340.30425@schroedinger.engr.sgi.com>
References: <20070925232543.036615409@sgi.com>
	<20070925233008.523093726@sgi.com>
	<20071022142939.1b815680.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0710241921570.29434@schroedinger.engr.sgi.com>
	<20071024193458.ca4300be.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0710241944340.30425@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Oleg Nesterov x <oleg@tv-sign.ru>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Oct 2007 19:50:19 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 24 Oct 2007, Andrew Morton wrote:
> 
> > > Sometimes we check the list head using list_empty() so we cannot avoid 
> > > list_del_init. Always using list_del_init results in a consistent state of 
> > > affairs before the object is freed (which the slab defrag patchset depends 
> > > on)
> > 
> > OK, but it's slower.
> > 
> > So I think it should be changlogged as such, with an explanation that there
> > will (hopefully) be a net benefit because it enables slab defrag, and it
> > should be moved into the slab-defrag patchset.
> 
> really?
> 
> list_del_init does:
> 
> static inline void list_del_init(struct list_head *entry)
> {
>         __list_del(entry->prev, entry->next);
>         INIT_LIST_HEAD(entry);
> }
> 
> So it touches the cachelines of the entry and prev/next to fix up the 
> links.
> 
> list_del does:
> 
> #ifndef CONFIG_DEBUG_LIST
> static inline void list_del(struct list_head *entry)
> {
>         __list_del(entry->prev, entry->next);
>         entry->next = LIST_POISON1;
>         entry->prev = LIST_POISON2;
> }
> #else
> extern void list_del(struct list_head *entry);
> #endif
> 
> In the !DEBUG case it touches the same cachelines. The only change is that 
> we poison entry. 

bugger, I'd forgotten that we do the poisoning even if !CONFIG_DEBUG_LIST.

We really shouldn't do that, especially now that we have the list debugging
config option.

Fixing this might break net/rxrpc/af_rxrpc.c and detach_timer(), but they
deserve to be broken.

> So its not slower.

It should be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
