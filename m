Date: Sat, 8 Jan 2005 13:43:54 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] per thread page reservation patch
In-Reply-To: <m1vfa8w0nk.fsf@clusterfs.com>
Message-ID: <Pine.LNX.4.44.0501081336240.2804-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Andrew Morton <akpm@osdl.org>, pmarques@grupopie.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Jan 2005, Nikita Danilov wrote:
> Andrew Morton <akpm@osdl.org> writes:
> >
> > __alloc_pages(GFP_KERNEL, ...) doesn't return NULL.  It'll either succeed
> > or never return ;) That behaviour may change at any time of course, but it
> 
> Hmm... it used to, when I wrote that code.

And still does, if OOM decides to kill _your_ task: OOM sets PF_MEMDIE,
and then you don't get to go the retry route at all:

	/* This allocation should allow future memory freeing. */
	if ((p->flags & (PF_MEMALLOC | PF_MEMDIE)) && !in_interrupt()) {
		/* go through the zonelist yet again, ignoring mins */
		for (i = 0; (z = zones[i]) != NULL; i++) {
			page = buffered_rmqueue(z, order, gfp_mask);
			if (page)
				goto got_pg;
		}
		goto nopage;
	}
....
nopage:
	....
	return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
