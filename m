Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 202C66B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 15:16:38 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id tr6so27991691ieb.4
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 12:16:37 -0800 (PST)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id cy19si11113igc.10.2015.02.03.12.16.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 12:16:37 -0800 (PST)
Received: by mail-ie0-f170.google.com with SMTP id y20so28147963ier.1
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 12:16:37 -0800 (PST)
Date: Tue, 3 Feb 2015 12:16:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
In-Reply-To: <20150203155103.GB2644@blaptop>
Message-ID: <alpine.DEB.2.10.1502031213520.18250@chino.kir.corp.google.com>
References: <20150107172452.GA7922@node.dhcp.inet.fi> <20150114152225.GB31484@google.com> <20150114233630.GA14615@node.dhcp.inet.fi> <alpine.DEB.2.10.1501211452580.2716@chino.kir.corp.google.com> <CA+yH71fNZSYVf1G+UUp3N6BhPhT0VJ4aGY=uPGbSD2raV55E3Q@mail.gmail.com>
 <alpine.DEB.2.10.1501221523390.27807@chino.kir.corp.google.com> <CA+yH71e2ewvA41BNyb=TTPn+yx2zWzY6rn09hRVVgWKoeMgwXQ@mail.gmail.com> <alpine.DEB.2.10.1501261552440.29252@chino.kir.corp.google.com> <20150203032628.GA4006@google.com>
 <20150203155103.GB2644@blaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Petr Cermak <petrcermak@chromium.org>, Primiano Tucci <primiano@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Hugh Dickins <hughd@google.com>

On Wed, 4 Feb 2015, Minchan Kim wrote:

> > > This is a result of allowing something external (process B) be able to
> > > clear hwm so that you never knew the value went to 100MB.  That's the
> > > definition of a race, I don't know how to explain it any better and making
> > > any connection between clearing PG_referenced and mm->hiwater_rss is a
> > > stretch.  This approach just makes mm->hiwater_rss meaningless.
> > 
> > I understand your concern, but I hope you agree that the functionality we
> > are proposing would be very useful for profiling. Therefore, I suggest
> > adding an extra resettable field to /proc/pid/status (e.g.
> > resettable_hiwater_rss) instead. What is your view on this approach?
> 
> The idea would be very useful for measuring working set size for
> efficient memory management in userside, which becomes very popular
> with many platforms for embedded world with tight memory.
> 

The problem is the same as the aforementioned if you're only going to be 
adding one field.  If another process happens to clear the 
resettable_hiwater_rss before you can read it, you don't see potentially 
large spikes in size.

I understand the need for measuring working set size, and we have an 
in-house solution for that, but I don't think we should be introducing new 
fields that require only one root process on the system to be touching it 
for it to be effective.  Let me talk with some people about how difficult 
it would be to propose our in-house solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
