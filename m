Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 422C26B1CDF
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 17:05:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 190-v6so27531225pfd.7
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 14:05:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 24sor14048278pgq.13.2018.11.19.14.05.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 14:05:36 -0800 (PST)
Date: Mon, 19 Nov 2018 14:05:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
In-Reply-To: <20181115090242.GH23831@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1811191404030.150313@chino.kir.corp.google.com>
References: <20181009083326.GG8528@dhcp22.suse.cz> <20181015150325.GN18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810151519250.247641@chino.kir.corp.google.com> <20181016104855.GQ18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810161416540.83080@chino.kir.corp.google.com>
 <20181017070531.GC18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810171256330.60837@chino.kir.corp.google.com> <20181018070031.GW18839@dhcp22.suse.cz> <20181114132306.GX23419@dhcp22.suse.cz> <alpine.DEB.2.21.1811141336010.200345@chino.kir.corp.google.com>
 <20181115090242.GH23831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Thu, 15 Nov 2018, Michal Hocko wrote:

> > The userspace had a single way to determine if thp had been disabled for a 
> > specific vma and that was broken with your commit.  We have since fixed 
> > it.  Modifying our software stack to start looking for some field 
> > somewhere else will not help anybody else that this has affected or will 
> > affect.  I'm interested in not breaking userspace, not trying a wait and 
> > see approach to see if anybody else complains once we start looking for 
> > some other field.  The risk outweighs the reward, it already broke us, and 
> > I'd prefer not to even open the possibility of breaking anybody else.
> 
> I very much agree on "do not break userspace" part but this is kind of
> gray area. VMA flags are a deep internal implementation detail and
> nobody should really depend on it for anything important. The original
> motivation for introducing it was CRIU where it is kind of
> understandable. I would argue they should find a different way but it is
> just too late for them.
> 
> For this particular case there was no other bug report except for yours
> and if it is possible to fix it on your end then I would really love to
> make the a sensible user interface to query the status. If we are going
> to change the semantic of the exported flag again then we risk yet
> another breakage.
> 
> Therefore I am asking whether changing your particular usecase to a new
> interface is possible because that would allow to have a longerm
> sensible user interface rather than another kludge which still doesn't
> cover all the usecases (e.g. there is no way to reliably query the
> madvise status after your patch).
> 

Providing another interface is great, I have no objection other than 
emitting another line for every vma on the system for smaps is probably 
overkill for something as rare as PR_SET_THP_DISABLE.

That said, I think the current handling of the "nh" flag being emitted in 
smaps is logical and ensures no further userspace breakage.  If that is to 
be removed, I consider it an unnecessary risk.  That would raised in code 
review.
