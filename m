Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id F41B76B00F2
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 16:36:41 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id d1so7751609wiv.7
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 13:36:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hs8si9827674wib.102.2014.11.03.13.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 13:36:41 -0800 (PST)
Date: Mon, 3 Nov 2014 16:36:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct page
Message-ID: <20141103213628.GA11428@phnom.home.cmpxchg.org>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
 <20141103210607.GA24091@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141103210607.GA24091@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 03, 2014 at 11:06:07PM +0200, Kirill A. Shutemov wrote:
> On Sat, Nov 01, 2014 at 11:15:54PM -0400, Johannes Weiner wrote:
> > Memory cgroups used to have 5 per-page pointers.  To allow users to
> > disable that amount of overhead during runtime, those pointers were
> > allocated in a separate array, with a translation layer between them
> > and struct page.
> > 
> > There is now only one page pointer remaining: the memcg pointer, that
> > indicates which cgroup the page is associated with when charged.  The
> > complexity of runtime allocation and the runtime translation overhead
> > is no longer justified to save that *potential* 0.19% of memory.
> 
> How much do you win by the change?

Heh, that would have followed right after where you cut the quote:
with CONFIG_SLUB, that pointer actually sits in already existing
struct page padding, which means that I'm saving one pointer per page
(8 bytes per 4096 byte page, 0.19% of memory), plus the pointer and
padding in each memory section.  I also save the (minor) translation
overhead going from page to page_cgroup and the maintenance burden
that stems from having these auxiliary arrays (see deleted code).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
