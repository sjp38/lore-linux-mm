Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id EEBE96B0038
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 17:36:36 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id q5so7763791wiv.17
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 14:36:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id na16si10076268wic.20.2014.11.03.14.36.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 14:36:35 -0800 (PST)
Date: Mon, 3 Nov 2014 17:36:26 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct page
Message-ID: <20141103223626.GA12006@phnom.home.cmpxchg.org>
References: <20141103210607.GA24091@node.dhcp.inet.fi>
 <20141103213628.GA11428@phnom.home.cmpxchg.org>
 <20141103215206.GB24091@node.dhcp.inet.fi>
 <20141103.165807.2039166055692354811.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141103.165807.2039166055692354811.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: kirill@shutemov.name, akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, tj@kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 03, 2014 at 04:58:07PM -0500, David Miller wrote:
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> Date: Mon, 3 Nov 2014 23:52:06 +0200
> 
> > On Mon, Nov 03, 2014 at 04:36:28PM -0500, Johannes Weiner wrote:
> >> On Mon, Nov 03, 2014 at 11:06:07PM +0200, Kirill A. Shutemov wrote:
> >> > On Sat, Nov 01, 2014 at 11:15:54PM -0400, Johannes Weiner wrote:
> >> > > Memory cgroups used to have 5 per-page pointers.  To allow users to
> >> > > disable that amount of overhead during runtime, those pointers were
> >> > > allocated in a separate array, with a translation layer between them
> >> > > and struct page.
> >> > > 
> >> > > There is now only one page pointer remaining: the memcg pointer, that
> >> > > indicates which cgroup the page is associated with when charged.  The
> >> > > complexity of runtime allocation and the runtime translation overhead
> >> > > is no longer justified to save that *potential* 0.19% of memory.
> >> > 
> >> > How much do you win by the change?
> >> 
> >> Heh, that would have followed right after where you cut the quote:
> >> with CONFIG_SLUB, that pointer actually sits in already existing
> >> struct page padding, which means that I'm saving one pointer per page
> >> (8 bytes per 4096 byte page, 0.19% of memory), plus the pointer and
> >> padding in each memory section.  I also save the (minor) translation
> >> overhead going from page to page_cgroup and the maintenance burden
> >> that stems from having these auxiliary arrays (see deleted code).
> > 
> > I read the description. I want to know if runtime win (any benchmark data?)
> > from moving mem_cgroup back to the struct page is measurable.
> > 
> > If the win is not significant, I would prefer to not occupy the padding:
> > I'm sure we will be able to find a better use for the space in struct page
> > in the future.
> 
> I think the simplification benefits completely trump any performan
> metric.

I agree.

Also, nobody is using that space currently, and I can save memory by
moving the pointer in there.  Should we later add another pointer to
struct page we are only back to the status quo - with the difference
that booting with cgroup_disable=memory will no longer save the extra
pointer per page, but again, if you care that much, you can disable
memory cgroups at compile-time.

So don't look at it as occpuying the padding, it is rather taking away
the ability to allocate that single memcg pointer at runtime, while at
the same time saving a bit of memory for common configurations until
somebody else needs the struct page padding.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
