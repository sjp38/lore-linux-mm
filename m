Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8B16B000A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 19:03:55 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id p73-v6so3164329qkp.2
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 16:03:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g4-v6si543014qvk.217.2018.10.09.16.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 16:03:54 -0700 (PDT)
Date: Tue, 9 Oct 2018 19:03:52 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181009230352.GE9307@redhat.com>
References: <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
 <20181005073854.GB6931@suse.de>
 <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
 <20181009094825.GC6931@suse.de>
 <20181009122745.GN8528@dhcp22.suse.cz>
 <20181009130034.GD6931@suse.de>
 <20181009142510.GU8528@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009142510.GU8528@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue, Oct 09, 2018 at 04:25:10PM +0200, Michal Hocko wrote:
> On Tue 09-10-18 14:00:34, Mel Gorman wrote:
> > On Tue, Oct 09, 2018 at 02:27:45PM +0200, Michal Hocko wrote:
> > > [Sorry for being slow in responding but I was mostly offline last few
> > >  days]
> > > 
> > > On Tue 09-10-18 10:48:25, Mel Gorman wrote:
> > > [...]
> > > > This goes back to my point that the MADV_HUGEPAGE hint should not make
> > > > promises about locality and that introducing MADV_LOCAL for specialised
> > > > libraries may be more appropriate with the initial semantic being how it
> > > > treats MADV_HUGEPAGE regions.
> > > 
> > > I agree with your other points and not going to repeat them. I am not
> > > sure madvise s the best API for the purpose though. We are talking about
> > > memory policy here and there is an existing api for that so I would
> > > _prefer_ to reuse it for this purpose.
> > > 
> > 
> > I flip-flopped on that one in my head multiple times on the basis of
> > how strict it should be. Memory policies tend to be black or white --
> > bind here, interleave there, etc. It wasn't clear to me what the best
> > policy would be to describe "allocate local as best as you can but allow
> > fallbacks if necessary".

MPOL_PREFERRED is not black and white. In fact I asked David earlier
if MPOL_PREFERRED could check if it would already be a good fit for
this. Still the point is it requires privilege (and for a good
reason).

> I was thinking about MPOL_NODE_PROXIMITY with the following semantic:
> - try hard to allocate from a local or very close numa node(s) even when
> that requires expensive operations like the memory reclaim/compaction
> before falling back to other more distant numa nodes.

If MPOL_PREFERRED can't work something like this could be added.

I think "madvise vs mbind" is more an issue of "no-permission vs
permission" required. And if the processes ends up swapping out all
other process with their memory already allocated in the node, I think
some permission is correct to be required, in which case an mbind
looks a better fit. MPOL_PREFERRED also looks a first candidate for
investigation as it's already not black and white and allows spillover
and may already do the right thing in fact if set on top of
MADV_HUGEPAGE.

Thanks,
Andrea
