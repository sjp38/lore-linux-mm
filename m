Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 223C96B28EC
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 21:27:15 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id x7so11846125pll.23
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 18:27:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w10-v6sor57660940plp.31.2018.11.21.18.27.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 18:27:13 -0800 (PST)
Date: Wed, 21 Nov 2018 18:27:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
In-Reply-To: <20181121071132.GD12932@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1811211757070.5557@eggly.anvils>
References: <20181120134323.13007-1-mhocko@kernel.org> <20181120134323.13007-4-mhocko@kernel.org> <alpine.LSU.2.11.1811201721470.2061@eggly.anvils> <20181121071132.GD12932@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 21 Nov 2018, Michal Hocko wrote:
> On Tue 20-11-18 17:47:21, Hugh Dickins wrote:
> > On Tue, 20 Nov 2018, Michal Hocko wrote:
> > 
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > filemap_map_pages takes a speculative reference to each page in the
> > > range before it tries to lock that page. While this is correct it
> > > also can influence page migration which will bail out when seeing
> > > an elevated reference count. The faultaround code would bail on
> > > seeing a locked page so we can pro-actively check the PageLocked
> > > bit before page_cache_get_speculative and prevent from pointless
> > > reference count churn.
> > > 
> > > Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> > > Suggested-by: Jan Kara <jack@suse.cz>
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > 
> > Acked-by: Hugh Dickins <hughd@google.com>
> 
> Thanks!
> 
> > though I think this patch is more useful to the avoid atomic ops,
> > and unnecessary dirtying of the cacheline, than to avoid the very
> > transient elevation of refcount, which will not affect page migration
> > very much.
> 
> Are you sure it would really be transient? In other words is it possible
> that the fault around can block migration repeatedly under refault heavy
> workload? I just couldn't convince myself, to be honest.

I don't deny that it is possible: I expect that, using fork() (which does
not copy the ptes in a shared file vma), you can construct a test case
where each child faults one or another page near a page of no interest,
and that page of no interest is a target of migration perpetually
frustrated by filemap_map_pages()'s briefly raised refcount.

But I suggest that's a third-order effect: well worth fixing because
it's easily and uncontroversially dealt with, as you have; but not of
great importance.

The first-order effect is migration conspiring to defeat itself: that's
what my put_and_wait_on_page_locked() patch, in other thread, is about.

The second order effect is when a page that is really wanted is waited
on - the target of a fault, for which page refcount is raised maybe
long before it finally gets into the page table (whereupon it becomes
visible to try_to_unmap(), and its mapcount matches refcount so that
migration can fully account for the page).  One class of that can be
well dealt with by using put_and_wait_on_page_locked_killable() in
lock_page_or_retry(), but I was keeping that as a future instalment.

But I shouldn't denigrate the transient case by referring so lightly
to migrate_pages()' 10 attempts: each of those failed attempts can
be very expensive, unmapping and TLB flushing (including IPIs) and
remapping. It may well be that 2 or 3 would be a more cost-effective
number of attempts, at least when the page is mapped.

Hugh
