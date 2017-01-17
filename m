Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 026746B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:15:01 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so280535240pfb.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:15:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id n2si1289099pgn.27.2017.01.16.23.15.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 23:15:00 -0800 (PST)
Date: Tue, 17 Jan 2017 08:14:56 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 07/15] lockdep: Implement crossrelease feature
Message-ID: <20170117071456.GK25813@worktop.programming.kicks-ass.net>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-8-git-send-email-byungchul.park@lge.com>
 <20170116151001.GD3144@twins.programming.kicks-ass.net>
 <20170117020541.GF3326@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117020541.GF3326@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Jan 17, 2017 at 11:05:42AM +0900, Byungchul Park wrote:
> On Mon, Jan 16, 2017 at 04:10:01PM +0100, Peter Zijlstra wrote:
> > On Fri, Dec 09, 2016 at 02:12:03PM +0900, Byungchul Park wrote:

> > > @@ -155,6 +164,9 @@ struct lockdep_map {
> > >  	int				cpu;
> > >  	unsigned long			ip;
> > >  #endif
> > > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > > +	struct cross_lock		*xlock;
> > > +#endif
> > 
> > The use of this escapes me; why does the lockdep_map need a pointer to
> > this?
> 
> Lockdep interfaces e.g. lock_acquire(), lock_release() and lock_commit()
> use lockdep_map as an arg, but crossrelease need to extract cross_lock
> instances from that.

> > Why not do something like:
> > 
> > struct lockdep_map_cross {
> > 	struct lockdep_map	map;
> > 	struct held_lock	hlock;
> > }

Using a structure like that, you can pass lockdep_map_cross around just
fine, since the lockdep_map is the first member, so the pointers are
interchangeable. At worst we might need to munge a few typecasts.

But then the cross release code can simply cast to the bigger type and
have access to the extra data it knows to be there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
