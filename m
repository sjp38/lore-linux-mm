Date: Fri, 9 Aug 2002 11:12:20 -0400
Mime-Version: 1.0 (Apple Message framework v482)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Subject: Broad questions about the current design
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Message-Id: <66ABF318-ABAA-11D6-8D07-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi folks,

I'm in process of trying to do some experiments that require modifying the 
VM system to gather recency hit distribution statistics online.  I'm just 
beginning to get the hang of the code, so I need some help, particularly 
with the latest versions which are substantially different (it seems to me)
  from the last versions that were (semi-)documented.  Some of these 
questions may be foolish, and the last one in particular rambles a bit as 
I think straight into the keyboard, but I am interested in your responses:

1) What happened to page ages?  I found them in 2.4.0, but they're
    gone by 2.4.19, and remain gone in 2.5.30.  The active list scan
    seems to start at the tail and work its way towards the head,
    demoting to the inactive list those pages whose reference bit is
    cleared.  This seems to be like some kind of hybrid inbetween a
    FIFO policy and a CLOCK algorithm.  Pages are inserted and scanned
    based on the FIFO ordering, but given a second chance much like a
    CLOCK.  Is a similar approach used for queuing pages for cleaning
    and for reclaimation?  Am I interpreting this code in
    refill_inactive correctly?

2) Is there only one inactive list now?  Again, somewhere between
    2.4.0 and 2.4.19, inactive_dirty_list and the per-zone
    inactive_clean_lists disappeared.  How are the inactive_clean
    and inactive_dirty pages separated?  Or are they no longer kept
    separate in that way, and simply distinguished when trying to
    reclaim pages?

3) Does the scanning of pages (roughly every page within a minute)
    create a lot of avoidable overhead?  I can see that such scanning
    is necessary when page aging is used, as the ages must be updated
    to maintain this frequency-of-use information.  However, in the
    absence of page ages, scanning seems superfluous.  Some amount of
    scanning for the purpose of flushing groups of dirty pages seems
    appropriate, but that doesn't requiring the continual scanning of
    all pages.  Clearing reference bits on roughly the same time scale
    with which those bits are set could require regular and complete
    scanning, but the value of that reference-bit-clearing has not been
    clearly demonstrated (or has it?).

    How much overhead *does* this scanning introduce?  Does it really
    yield performance that is so much better than, say, a SEGQ
    (CLOCK->LRU) structure with a single-handed clock?  Is it worth
    raising this point when justifying rmap?  Specifically, we're
    already accustomed to some amount of overhead in VM bookkeeping in
    order to avoid bad memory management -- what fraction of the total
    overhead would be due to rmap in bad cases when compared to this
    overhead?

Many thanks for answers and thoughts that you can provide.  I do have one 
other important question to me:  How much should I expect this code to 
continue to change?  Is this basic structure likely to change, or will 
there only be tuning improvements and minor modifications?

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9U9vX8eFdWQtoOmgRAtzLAKCcKtzpOIfQyE27vwFaf1o6tvFlfACdHtY+
T3EXbIQg/aqxNWqxXn5LAW4=
=RZc9
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
