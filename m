Received: from knoppix.wat.veritas.com ([10.10.188.58]) (2025 bytes) by
    megami.veritas.com via sendmail with P:esmtp/R:smart_host/T:smtp
    (sender: <hugh@veritas.com>) id <m1Bwgk2-0000zlC@megami.veritas.com> for
    <linux-mm@kvack.org>; Mon, 16 Aug 2004 05:37:34 -0700 (PDT)
    (Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Mon, 16 Aug 2004 13:37:29 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: __set_page_dirty_nobuffers superfluous check
In-Reply-To: <20040814133717.GA32755@logos.cnet>
Message-ID: <Pine.LNX.4.44.0408161324140.31643-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 14 Aug 2004, Marcelo Tosatti wrote:
> 
> Makes sense, why arent tmpfs/swap using mpage operations? 

They don't fit together usefully.

Because the multipage operations are designed to help
disk-based filesystems, gathering together readaheads and writeouts
to reduce disk seeking; but tmpfs and swap are cases too special.

writepages is important for guaranteeing data to disk efficiently;
but tmpfs and swap don't need any such guarantee, sync'ing them is
just a waste of effort (and so they're marked as "memory_backed"
to avoid it).

swap already had its own swapin_readahead (of limited value:
swap locality is much less significant than file locality),
not much point in trying to convert that over to readpages.

tmpfs is mainly in memory, does overflow to swap and thence to disk,
but the rules of that exchange are too peculiar to use general routines.

When he originated the readpages and writepages operations, akpm did
start off calling writepages from vmscan.c.  I don't remember just why
he dropped that in the end (certainly tmpfs had to suppress it, I forget
how it fared with swap), perhaps just too much complication for too little
gain.  Nowadays, if vmscan is doing too many little file writeouts, the
answer is usually to tweak thresholds to kick in pdflush earlier to do
the more efficient writepages, rather than try to shoehorn writepages
back into vmscan.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
