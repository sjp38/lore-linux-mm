Received: from amigo.daimi.au.dk (amigo.daimi.au.dk [130.225.16.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA15678
	for <Linux-MM@kvack.org>; Fri, 21 May 1999 06:07:50 -0400
Message-ID: <19990521120725.A581384@daimi.au.dk>
Date: Fri, 21 May 1999 12:07:25 +0200
From: Erik Corry <erik@arbat.com>
Subject: Re: Assumed Failure rates in Various o.s's ?
References: <199905191428.QAA1295681@beryllium.daimi.au.dk> <199905191737.KAA85790@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199905191737.KAA85790@google.engr.sgi.com>; from Kanoj Sarcar on Wed, May 19, 1999 at 10:37:42AM -0700
Sender: owner-linux-mm@kvack.org
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: ak-uu@muc.de, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 19, 1999 at 10:37:42AM -0700, Kanoj Sarcar wrote:
> > 
> > to http://x35.deja.com/=dnc/[ST_rn=ps]/getdoc.xp?AN=467741389
> 
> Unfortunately, I couldn't quite trace back to the roots of this
> thread,

You can click on the 'Thread button to get an overview of the
thread.  I don't think there is an actual bug demonstration or
exploit available.

> I think my patch might actually help your situation, given that the
> *software* is checking the pte bits and making decisions about writability,
> rather than relying on broken *hardware* which ignores the pte writability
> bit.

Yes.  Though the performace hit would be even worse on the i386.

> Now for a proposal: I don't see a down(mm->mmap_sem) being done
> in the code path leading up to calls to __verify_write. Am I missing
> it? If a down(mm->mmap_sem) were added around __verify_write, you could
> quit worrying about simultaneous munmaps while an user access function 
> was executing. 

I think this is the wrong place.  As far as I understand it,
the verify_write runs before the actual copying takes place.
So after verify_write has run, while the copy_to_user is
taking place there can be a page fault (is that even necessary
on SMP?).  While that is happening, the black hat user can do
an mmap/munmap in another thread.  But I haven't really looked
into it much, I am relying mostly on hearsay here.

According to Andi you already fixed this with a read lock that
prevents mmap and mmunmap from doing anything while the copy
is running.  This makes sense, since if you do it right with a
readers/writers lock you can keep out mmap without serialising
copy_to_user or copy_from_user.

-- 
Erik Corry erik@arbat.com     Ceterum censeo, Microsoftem esse delendam!
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
