Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 048396B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 19:00:28 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id hn18so1390708igb.2
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 16:00:27 -0800 (PST)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id l27si8530068iod.86.2015.01.26.16.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 16:00:27 -0800 (PST)
Received: by mail-ie0-f182.google.com with SMTP id ar1so12082690iec.13
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 16:00:27 -0800 (PST)
Date: Mon, 26 Jan 2015 16:00:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
In-Reply-To: <CA+yH71e2ewvA41BNyb=TTPn+yx2zWzY6rn09hRVVgWKoeMgwXQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1501261552440.29252@chino.kir.corp.google.com>
References: <20150107172452.GA7922@node.dhcp.inet.fi> <20150114152225.GB31484@google.com> <20150114233630.GA14615@node.dhcp.inet.fi> <alpine.DEB.2.10.1501211452580.2716@chino.kir.corp.google.com> <CA+yH71fNZSYVf1G+UUp3N6BhPhT0VJ4aGY=uPGbSD2raV55E3Q@mail.gmail.com>
 <alpine.DEB.2.10.1501221523390.27807@chino.kir.corp.google.com> <CA+yH71e2ewvA41BNyb=TTPn+yx2zWzY6rn09hRVVgWKoeMgwXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Primiano Tucci <primiano@chromium.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Petr Cermak <petrcermak@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Hugh Dickins <hughd@google.com>

On Fri, 23 Jan 2015, Primiano Tucci wrote:

> > If you reset the hwm for a process, rss grows to 100MB, another process
> > resets the hwm, and you see a hwm of 2MB, that invalidates the hwm
> > entirely.
> 
> Not sure I follow this scenario. Where does the 2MB come from?

It's a random number that the hwm gets reset to after the other process 
clears it.

> How can
> you see a hwm of 2MB, under which conditions? HVM can never be < RSS.
> Again, what you are talking about is the case of two profilers racing
> for using the same interface (hwm).
> This is the same case today of the PG_referenced bit.
> 

PG_referenced bit is not tracking the highest rss a process has ever 
attained.  PG_referenced is understood to be clearable at any time and the 
only guarantee is that it was at least cleared before returning from the 
write.  It could be set again before the write returns as well, but we can 
be sure that it was at least cleared.

With your approach, which completely invalidates the entire purpose of 
hwm, the following is possible:

	process A			process B
	---------			---------
	read hwm = 50MB			read hwm = 50MB
	write to clear hwm
	rss goes to 100MB
					write to clear hwm
					rss goes to 2MB
	read hwm = 2MB			read hwm = 2MB

This is a result of allowing something external (process B) be able to 
clear hwm so that you never knew the value went to 100MB.  That's the 
definition of a race, I don't know how to explain it any better and making 
any connection between clearing PG_referenced and mm->hiwater_rss is a 
stretch.  This approach just makes mm->hiwater_rss meaningless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
