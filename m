Date: Wed, 4 Mar 1998 16:33:46 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [uPATCH] small kswapd improvement ???
In-Reply-To: <199803041400.PAA06227@boole.fs100.suse.de>
Message-ID: <Pine.LNX.3.91.980304162522.24591A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: sct@dcs.ed.ac.uk, torvalds@transmeta.com, blah@kvack.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Mar 1998, Dr. Werner Fink wrote:

> Maybe that's the reason why the bigger initial age for swapped in pages gives
> an improvement in 2.0.33 ... it's a ``better protection'' for often needed
> pages.

I think I'm going to try a more LRU like aging algorithm
now. (I've worked with some SGI boxes at school, and it
looks like they're less phrone to trashing)

Algorithm:

age_page(page) {
	page->age >>= 1;
}
touch_page(page) {
	page->age >>= 1;
	page->age |= 0x80;
}

and in vmscan.c/filemap.c:

-	if (page->age)
+	if (page->age < 1 << (MIN_SWAP_AGE + (nr_free_pages < free_pages_low 
? 1 : 0))

Then we could use the MIN_SWAP_AGE sysctl variable
to control the CPU usage / swap 'precision' of
kswapd. Even better would be a dynamic adjusment,
so kswapd would:
- never use more than 5% CPU (over a 10 sec interval?)
- use the maximum precision possible
- scan a maximum of MIN_SWAP_AGE + 2 times the number of
  pages it frees

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
