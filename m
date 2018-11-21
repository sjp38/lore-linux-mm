Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF1D46B2386
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:20:50 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w7-v6so5492499plp.9
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 19:20:50 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u23sor25979268pfi.65.2018.11.20.19.20.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 19:20:49 -0800 (PST)
Date: Tue, 20 Nov 2018 19:20:40 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Memory hotplug softlock issue
In-Reply-To: <alpine.LSU.2.11.1811201630360.2061@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811201852370.2804@eggly.anvils>
References: <20181115143204.GV23831@dhcp22.suse.cz> <20181116012433.GU2653@MiWiFi-R3L-srv> <20181116091409.GD14706@dhcp22.suse.cz> <20181119105202.GE18471@MiWiFi-R3L-srv> <20181119124033.GJ22247@dhcp22.suse.cz> <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz> <20181119173312.GV22247@dhcp22.suse.cz> <alpine.LSU.2.11.1811191215290.15640@eggly.anvils> <20181119205907.GW22247@dhcp22.suse.cz> <20181120015644.GA5727@MiWiFi-R3L-srv> <alpine.LSU.2.11.1811192127130.2848@eggly.anvils>
 <3f1a82a8-f2aa-ac5e-e6a8-057256162321@suse.cz> <alpine.LSU.2.11.1811201630360.2061@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@kernel.org>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>

On Tue, 20 Nov 2018, Hugh Dickins wrote:
> On Tue, 20 Nov 2018, Vlastimil Babka wrote:
> > >  
> > >  	finish_wait(q, wait);
> > 
> > ... the code continues by:
> > 
> >         if (thrashing) {
> >                 if (!PageSwapBacked(page))
> > 
> > So maybe we should not set 'thrashing' true when lock < 0?
> 
> Very good catch, thank you Vlastimil: as you might have guessed, the
> patch from a pre-PSI kernel applied cleanly, and I just hadn't reviewed
> the surrounding context properly before sending out.
> 
> I cannot say immediately what the right answer is, I'll have to do some
> research first: maybe not enter the block that sets thrashing true when
> lock < 0, as you suggest, or maybe force lock < 0 to 0 and put_page()
> afterwards, or... 

... I still won't adjust the patch tonight, but the answer is obvious
now I look closer: as you show in your extract above, the only thing
it does with "page" at the end is to ask if it was SwapBacked, so we
just need to set one more bool at the beginning to check at the end
(or I could make "thrashing" a -1, 0, 1 int like "lock": but my guess
is that that would not be to other people's taste: acceptable for the
arg, but stretching your patience for the local variable).

By the way, I do have a further patch to wait_on_page_bit_common(),
which I could send at the same time, if it sounds right to you
(but it's a no-op in the put_and_wait page migration case).  That
__add_wait_queue_entry_tail() is right for the first time into
the loop, but I maintain that it should use __add_wait_queue()
for fairness thereafter, to avoid repeatedly sending older waiters
back to the back of the queue.  I don't have hard numbers for it,
but it's one of several patches, each of which helped to reduce our
wait_on_page_bit lockups in some (perhaps unrealistic) stress tests.

Hugh
