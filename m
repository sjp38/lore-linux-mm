Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 534DA6810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 16:09:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so633320wrb.6
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 13:09:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9si173573wrb.104.2017.07.11.13.09.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 13:09:25 -0700 (PDT)
Date: Tue, 11 Jul 2017 21:09:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170711200923.gyaxfjzz3tpvreuq@suse.de>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
 <20170711064149.bg63nvi54ycynxw4@suse.de>
 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170711191823.qthrmdgqcd3rygjk@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 08:18:23PM +0100, Mel Gorman wrote:
> I don't think we should be particularly clever about this and instead just
> flush the full mm if there is a risk of a parallel batching of flushing is
> in progress resulting in a stale TLB entry being used. I think tracking mms
> that are currently batching would end up being costly in terms of memory,
> fairly complex, or both. Something like this?
> 

mremap and madvise(DONTNEED) would also need to flush. Memory policies are
fine as a move_pages call that hits the race will simply fail to migrate
a page that is being freed and once migration starts, it'll be flushed so
a stale access has no further risk. copy_page_range should also be ok as
the old mm is flushed and the new mm cannot have entries yet.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
