Date: Fri, 27 Mar 1998 13:33:06 -0500 (U)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: new allocation algorithm
In-Reply-To: <Pine.LNX.3.95.980327092811.6613C-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.95.980327131931.8105A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Mar 1998, Linus Torvalds wrote:

> The current scheme is fairly efficient and extremely stable, and gives
> good behaviour for the cases we _really_ care about (pageorders 0, 1 and
> to some degree 2). It comes reasonably close to working for the higher
> orders too, but they really aren't as critical..

As a 'useful gathering of statistics' measure, could something along the
lines of the following pseudo-patch be added to 2.1.92?  This way we'll
learn of any memory allocation failures, rather than syscalls failing or
SIGSEGVs occurring and people not knowing what's up. 

in __get_free_pages:

 nopage:
+{ static long last_nomem_jiffies, nomem_fails;
+	if ((jiffies - last_nomem_jiffies) >= 2*HZ) {
+		printk("__get_free_pages(%x, %lu) failed (%ld)\n",
+			gfp_mask, order, ++nomem_fails);
+		last_nomem_jiffies = jiffies;
+	}
+}
 	return 0;

		-ben
