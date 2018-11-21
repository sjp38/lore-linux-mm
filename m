Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76D6F6B22F7
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 20:21:40 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o23so4939416pll.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 17:21:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m9sor3306679pfj.63.2018.11.20.17.21.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 17:21:39 -0800 (PST)
Date: Tue, 20 Nov 2018 17:21:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Memory hotplug softlock issue
In-Reply-To: <20181120135803.GA3369@MiWiFi-R3L-srv>
Message-ID: <alpine.LSU.2.11.1811201710410.2061@eggly.anvils>
References: <20181119105202.GE18471@MiWiFi-R3L-srv> <20181119124033.GJ22247@dhcp22.suse.cz> <20181119125121.GK22247@dhcp22.suse.cz> <20181119141016.GO22247@dhcp22.suse.cz> <20181119173312.GV22247@dhcp22.suse.cz> <alpine.LSU.2.11.1811191215290.15640@eggly.anvils>
 <20181119205907.GW22247@dhcp22.suse.cz> <20181120015644.GA5727@MiWiFi-R3L-srv> <alpine.LSU.2.11.1811192127130.2848@eggly.anvils> <3f1a82a8-f2aa-ac5e-e6a8-057256162321@suse.cz> <20181120135803.GA3369@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, pifang@redhat.com, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>

On Tue, 20 Nov 2018, Baoquan He wrote:
> On 11/20/18 at 02:38pm, Vlastimil Babka wrote:
> > On 11/20/18 6:44 AM, Hugh Dickins wrote:
> > > [PATCH] mm: put_and_wait_on_page_locked() while page is migrated
> > > 
> > > We have all assumed that it is essential to hold a page reference while
> > > waiting on a page lock: partly to guarantee that there is still a struct
> > > page when MEMORY_HOTREMOVE is configured, but also to protect against
> > > reuse of the struct page going to someone who then holds the page locked
> > > indefinitely, when the waiter can reasonably expect timely unlocking.
> > > 
> > > But in fact, so long as wait_on_page_bit_common() does the put_page(),
> > > and is careful not to rely on struct page contents thereafter, there is
> > > no need to hold a reference to the page while waiting on it.  That does
> > 
> > So there's still a moment where refcount is elevated, but hopefully
> > short enough, right? Let's see if it survives Baoquan's stress testing.
> 
> Yes, I applied Hugh's patch 8 hours ago, then our QE Ping operated on
> that machine, after many times of hot removing/adding, the endless
> looping during mirgrating is not seen any more. The test result for
> Hugh's patch is positive. I even suggested Ping increasing the memory
> pressure to "stress -m 250", it still succeeded to offline and remove.
> 
> So I think this patch works to solve the issue. Thanks a lot for your
> help, all of you. 

Very good to hear, thanks a lot for your quick feedback.

> 
> High, will you post a formal patch in a separate thread?

Yes, I promise that I shall do so in the next few days, but not today:
some other things have to take priority.

And Vlastimil has raised an excellent point about the interaction with
PSI "thrashing": I need to read up and decide which way to go on that
(and add Johannes to the Cc when I post).

I think I shall probably post it directly to Linus (lists and other
people Cc'ed of course): not because I think it should be rushed in
too quickly, nor to sidestep Andrew, but because Linus was very closely
involved in both the PG_waiters and WQ_FLAG_BOOKMARK discussions:
it is an area of special interest to him.

Hugh
