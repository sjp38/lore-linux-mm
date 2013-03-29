Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id EDD256B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 18:20:01 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <72696b1d-3a45-4eb5-8072-6406db98c60c@default>
Date: Fri, 29 Mar 2013 15:19:43 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc/lzo compressibility vs entropy
References: <026ccf11-82db-4ddf-9882-294ee578775f@default>
In-Reply-To: <026ccf11-82db-4ddf-9882-294ee578775f@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Dan Magenheimer
> Sent: Wednesday, March 27, 2013 3:42 PM
> To: Seth Jennings; Konrad Wilk; Minchan Kim; Bob Liu; Robert Jennings; Ni=
tin Gupta; Wanpeng Li; Andrew
> Morton; Mel Gorman
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: zsmalloc/lzo compressibility vs entropy
>=20
> This might be obvious to those of you who are better
> mathematicians than I, but I ran some experiments
> to confirm the relationship between entropy and compressibility
> and thought I should report the results to the list.

A few new observations worth mentioning:

Since Seth long ago mentioned that the text of Moby Dick
resulted in poor (but not horribly poor) compression I thought
I'd look at some ASCII data.

I used the first sentence of the Gettysburg Address (91 characters)
and repeated it to fill a page.  Interestingly, LZO apparently
discovered the repetition... the page compressed to 118 bytes
even though the result had 15618 one-bits (fairly high entropy).

I used the full Gettysburg Address (1459 characters), again
repeated to fill a page.  LZO compressed this to 1070 bytes.
(14568 one-bits.)

To fill a page with text, I added part of the Declaration of
Independence.  No repeating text now.  This only compressed
to 2754 bytes (which, I assume, is close to Seth's observations
on Moby Dick).  14819 one-bits.

Last (for swap), to see if random ascii would compress better
than binary, I masked off the MSB in each byte of a random
page.  The mean zsize was 4116 bytes (larger than a page)
with a stddev of 51.  The one-bit mean was 14336 (7/16 of a page).

On a completely different track, I thought it would be relevant
to look at the difference between frontswap (anonymous) page
zsize distribution and cleancache (file) page zsize distribution.

Running kernbench, zsize mean was 1974 (stddev 895).

For a different benchmark, I did:

# find / | grep3

where grep3 is a simple bash script that does three separate
greps on the first argument.  Since this fills the page cache
and causes reclaiming, and reclaims are captured by cleancache
and fed to zcache, this data page stream approximates random
pages on the disk.

This "benchmark" generated a zsize mean of 2265 with stddev 1008.
Also of note: Only a fraction of a percent of cleancache pages
are zero-filled, so Wanpeng's zcache patch to handle zero-filled
pages more efficiently is very good for frontswap pages but may
have little benefit for cleancache pages.

Bottom line conclusions:  (1) Entropy is probably less a factor
for LZO-compressibility than data repetition. (2) Cleancache
data pages may have a very different zsize distribution than
frontswap data pages, anecdotally skewed to much higher zsize.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
