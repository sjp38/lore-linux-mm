Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC2F6B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:50:59 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w19-v6so1029793plq.2
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 04:50:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o30si3496858pgc.282.2018.03.15.04.50.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 04:50:57 -0700 (PDT)
Date: Thu, 15 Mar 2018 12:50:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: fix boot hang in memmap_init_zone
Message-ID: <20180315115055.GD23100@dhcp22.suse.cz>
References: <20180313224240.25295-1-neelx@redhat.com>
 <20180314141727.GE23100@dhcp22.suse.cz>
 <CACjP9X8u8Q2Jwp3CqYGJZhUdf0ivv4qGe+ZRB4A6+Z=z0vTLNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACjP9X8u8Q2Jwp3CqYGJZhUdf0ivv4qGe+ZRB4A6+Z=z0vTLNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: Naresh Kamboju <naresh.kamboju@linaro.org>, Sudeep Holla <sudeep.holla@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Paul Burton <paul.burton@imgtec.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>

On Thu 15-03-18 02:30:41, Daniel Vacek wrote:
> On Wed, Mar 14, 2018 at 3:17 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 13-03-18 23:42:40, Daniel Vacek wrote:
> >> On some architectures (reported on arm64) commit 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
> >> causes a boot hang. This patch fixes the hang making sure the alignment
> >> never steps back.
> >
> > I am sorry to be complaining again, but the code is so obscure that I
> 
> No worries, I'm glad for any review. Which code exactly you do find
> obscure? This patch or my former fix or the original commit
> introducing memblock_next_valid_pfn()? Coz I'd agree the original
> commit looks pretty obscure...

As mentioned in the other email, the whole going back and forth in the
same loop is just too ugly to live.

> > would _really_ appreciate some more information about what is going
> > on here. memblock_next_valid_pfn will most likely return a pfn within
> > the same memblock and the alignment will move it before the old pfn
> > which is not valid - so the block has some holes. Is that correct?
> 
> I do not understand what you mean by 'pfn within the same memblock'?

Sorry, I should have said in the same pageblock

> And by 'the block has some holes'?

memblock_next_valid_pfn clearly returns pfn which is within a pageblock
and that is why we do not initialize pages in the begining of the block
while move_freepages_block does really expect the full pageblock to be
initialized properly. That is the fundamental problem, right?

> memblock has types 'memory' (as usable memory) and 'reserved' (for
> unusable mem), if I understand correctly.

We might not have struct pages for invalid pfns. That really depends on
the memory mode. Sure sparse mem model will usually allocate struct
pages for whole memory sections but that is not universally true and
adding such a suble assumption is simply wrong.

I suspect you are making strong assumptions based on a very specific
implementation which might be not true in general. That was the feeling
I've had since the patch was proposed for the first time. This is such a
cluttered area that I am not really sure myself, thoug.
-- 
Michal Hocko
SUSE Labs
