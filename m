Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C28F46B13F1
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 12:30:53 -0500 (EST)
MIME-Version: 1.0
Message-ID: <6a13108f-a473-4ea1-9d05-7f52c30adcc8@default>
Date: Wed, 1 Feb 2012 09:30:52 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] memory compaction & ballooning
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Konrad Wilk <konrad.wilk@oracle.com>

Re: http://marc.info/?l=3Dlinux-mm&m=3D132732724710038&w=3D2=20
(sorry I couldn't properly thread this)

> I would like to discuss / brainstorm improvements to
> compaction and ways to keep memory allocations better
> separated, to be better able to come up with contiguous
> 2MB areas.

Hi Rik --

I have some thoughts on how in-kernel cleancache/tmem can be
used to help achieve this.  We can talk about it more
in April, but basically:

- IMHO the big issue with superpage ballooning is that you need
  to either maintain a ready-to-use free-list of superpages
  (but keeping this list is far too wasteful of space); or you
  need to do just-in-time compaction of a lot of superpages
  which is time-consuming (periodic "pauses") and subject
  to failure due to fragmentation.
- Under the conditions where you would want to do ballooning,
  most of the wasted space in a superpage free list would
  otherwise be used for clean file-mapped pagecache pages.
  So a large superpage free list would lead to a potentially
  large increase in refaults (and thus disk reads).

So:

- Implement a zcache-like driver that allocates 2MB superpages
  and uses each to store large quantities of cleancache 4K
  pages (compressed or not) AND all associated meta-data,
  such that all 4K pages stored in the superpage can be instantly
  evicted from cleancache simply by removing the superpage
  from a list.
- This list of reclaimable superpages would be primarily used by
  the balloon superpage driver but can also be reclaimed under
  certain low-memory conditions.
- If implemented properly, there is no internal fragmentation
  (in the non-compression case).

Of course this is not free either; it serves a similar
purpose to compaction but amortizes the cost over time.
And you have the choice of compression, which increases
density by increasing CPU cost, or non-compression which
has only page-copy overhead and some small meta-data space
overhead.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
