Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA13562
	for <linux-mm@kvack.org>; Tue, 3 Mar 1998 18:00:29 -0500
Date: Tue, 3 Mar 1998 22:59:23 GMT
Message-Id: <199803032259.WAA02410@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Fairness in love and swapping
In-Reply-To: <Pine.LNX.3.91.980303001242.3788D-100000@mirkwood.dummy.home>
References: <199803022235.WAA03546@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.91.980303001242.3788D-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Dr. Werner Fink" <werner@suse.de>, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 3 Mar 1998 00:14:43 +0100 (MET), Rik van Riel <H.H.vanRiel@fys.ruu.nl> said:

>> I rather suspect with those patches that it's not simply the aging of
>> page cache pages which helps performance, but also the tuning of the
>> balance between page cache and data page reclamation.

> That's why I proposed the true LRU aging on those pages,
> so they get a better chance of (re)usal before they're
> really freed and forgotten about (and need to be reread
> in the case of readahead pages).

That's exactly what all the work on being able to look up ptes from
the page address is about.  To get the balancing right, we really want
a single vmscan routine which deals with every single page fairly,
rather than skipping about between free page sources.  To do that, we
need to be able to lookup the ptes from the physical address.

Given that functionality, whole new worlds open up. :)

There is one other big balancing problem right now --- if there are
insufficient free pages to instantly grow the buffer cache, then getting
a new buffer defaults to reusing the oldest buffer.  I'd like to nuke
that breakage, because it leaves the buffer cache at the mercy of the
other caches in a busy system, and stops us from caching useful stuff
such as commonly used indirect blocks and directories.

--Stephen
