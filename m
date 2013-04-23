Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id A9C846B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 18:31:03 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ro2so271560pbb.32
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 15:31:02 -0700 (PDT)
Date: Tue, 23 Apr 2013 15:31:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: page eviction from the buddy cache
In-Reply-To: <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1304231518430.14137@eggly.anvils>
References: <51504A40.6020604@ya.ru> <20130327150743.GC14900@thunk.org> <alpine.LNX.2.00.1303271135420.29687@eggly.anvils> <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com> <515CD665.9000300@gmail.com> <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com>
 <51730619.3030204@fastmail.fm> <20130420235718.GA28789@thunk.org> <5176785D.5030707@fastmail.fm> <20130423122708.GA31170@thunk.org> <alpine.LNX.2.00.1304231230340.12850@eggly.anvils> <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Bernd Schubert <bernd.schubert@fastmail.fm>, Alexey Lyahkov <alexey.lyashkov@gmail.com>, Will Huck <will.huckk@gmail.com>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de

On Tue, 23 Apr 2013, Andrew Morton wrote:
> On Tue, 23 Apr 2013 12:57:45 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> 
> I do agree that we should be able to set both PageReferenced and
> PageActive on a lru_add_pvecs page and have those hints honoured when
> lru_add_pvecs is spilled onto the LRU.
> 
> At present the code decides up-front which LRU the lru_add_pvecs page
> will eventually be spilled onto.  That's a bit strange and I wonder why
> we did it that way.  Why not just have a single (per-cpu) magazine of
> pages which are to go onto the LRUs, and decide *which* LRU that will
> be at the last possible moment?

Yes, it is strange, and I'm wanting to get away from that: though I
won't be surprised if we discover that it's actually important for
avoiding races in the current scheme - which won't cope well with a
page being marked PageActive at the wrong moment (an instant after
it has been placed on the Inactive list).

What I want is for pages on the the per-cpu lru_add_pvecs to be already
marked PageLRU, and without raised page count, so that they are eligible
for isolation and migration without needing a drain.  (But I may be too
ambitious in trying to avoid the raised page count for lru_rotate_pvecs
and the others too.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
