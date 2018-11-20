Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2C026B1EE4
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 02:48:02 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so825261edr.7
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 23:48:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t24-v6si1010704ejo.216.2018.11.19.23.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 23:48:01 -0800 (PST)
Date: Tue, 20 Nov 2018 08:48:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
Message-ID: <20181120074759.GB22247@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1810151519250.247641@chino.kir.corp.google.com>
 <20181016104855.GQ18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810161416540.83080@chino.kir.corp.google.com>
 <20181017070531.GC18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810171256330.60837@chino.kir.corp.google.com>
 <20181018070031.GW18839@dhcp22.suse.cz>
 <20181114132306.GX23419@dhcp22.suse.cz>
 <alpine.DEB.2.21.1811141336010.200345@chino.kir.corp.google.com>
 <20181115090242.GH23831@dhcp22.suse.cz>
 <alpine.DEB.2.21.1811191404030.150313@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1811191404030.150313@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Mon 19-11-18 14:05:34, David Rientjes wrote:
> On Thu, 15 Nov 2018, Michal Hocko wrote:
> 
> > > The userspace had a single way to determine if thp had been disabled for a 
> > > specific vma and that was broken with your commit.  We have since fixed 
> > > it.  Modifying our software stack to start looking for some field 
> > > somewhere else will not help anybody else that this has affected or will 
> > > affect.  I'm interested in not breaking userspace, not trying a wait and 
> > > see approach to see if anybody else complains once we start looking for 
> > > some other field.  The risk outweighs the reward, it already broke us, and 
> > > I'd prefer not to even open the possibility of breaking anybody else.
> > 
> > I very much agree on "do not break userspace" part but this is kind of
> > gray area. VMA flags are a deep internal implementation detail and
> > nobody should really depend on it for anything important. The original
> > motivation for introducing it was CRIU where it is kind of
> > understandable. I would argue they should find a different way but it is
> > just too late for them.
> > 
> > For this particular case there was no other bug report except for yours
> > and if it is possible to fix it on your end then I would really love to
> > make the a sensible user interface to query the status. If we are going
> > to change the semantic of the exported flag again then we risk yet
> > another breakage.
> > 
> > Therefore I am asking whether changing your particular usecase to a new
> > interface is possible because that would allow to have a longerm
> > sensible user interface rather than another kludge which still doesn't
> > cover all the usecases (e.g. there is no way to reliably query the
> > madvise status after your patch).
> > 
> 
> Providing another interface is great, I have no objection other than 
> emitting another line for every vma on the system for smaps is probably 
> overkill for something as rare as PR_SET_THP_DISABLE.

Let me think about a full patch and see how it looks like.

> 
> That said, I think the current handling of the "nh" flag being emitted in 
> smaps is logical and ensures no further userspace breakage.

I have already expressed a concern that there is no way to query for
MADV_NOHUGEPAGE if we overload the flag. So this is not a riskfree
option.

> If that is to 
> be removed, I consider it an unnecessary risk.  That would raised in code 
> review.

-- 
Michal Hocko
SUSE Labs
