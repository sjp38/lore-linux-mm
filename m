Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id F24FE6B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 16:37:50 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <e33a2c0e-3b51-4d89-a2b2-c1ed9c8f862c@default>
Date: Thu, 6 Sep 2012 13:37:41 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: add support for zsmalloc and zcache
References: <<1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>>
In-Reply-To: <<1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

In response to this RFC for zcache promotion, I've been asked to summarize
the concerns and objections which led me to NACK the previous zcache
promotion request.  While I see great potential in zcache, I think some
significant design challenges exist, many of which are already resolved in
the new codebase ("zcache2").  These design issues include:

A) Andrea Arcangeli pointed out and, after some deep thinking, I came
   to agree that zcache _must_ have some "backdoor exit" for frontswap
   pages [2], else bad things will eventually happen in many workloads.
   This requires some kind of reaper of frontswap'ed zpages[1] which "evict=
s"
   the data to the actual swap disk.  This reaper must ensure it can reclai=
m
   _full_ pageframes (not just zpages) or it has little value.  Further the
   reaper should determine which pageframes to reap based on an LRU-ish
   (not random) approach.

B) Zsmalloc has potentially far superior density vs zbud because zsmalloc c=
an
   pack more zpages into each pageframe and allows for zpages that cross pa=
geframe
   boundaries.  But, (i) this is very data dependent... the average compres=
sion
   for LZO is about 2x.  The frontswap'ed pages in the kernel compile bench=
mark
   compress to about 4x, which is impressive but probably not representativ=
e of
   a wide range of zpages and workloads.  And (ii) there are many historica=
l
   discussions going back to Knuth and mainframes about tight packing of da=
ta...
   high density has some advantages but also brings many disadvantages rela=
ted to
   fragmentation and compaction.  Zbud is much less aggressive (max two zpa=
ges
   per pageframe) but has a similar density on average data, without the
   disadvantages of high density.

   So zsmalloc may blow zbud away on a kernel compile benchmark but, if bot=
h were
   runners, zsmalloc is a sprinter and zbud is a marathoner.  Perhaps the b=
est
   solution is to offer both?

   Further, back to (A), reaping is much easier with zbud because (i) zsmal=
loc
   is currently unable to deal with pointers to zpages from tmem data struc=
tures
   which may be dereferenced concurrently, (ii) because there may be many m=
ore such
   pointers, and (iii) because zpages stored by zsmalloc may cross pagefram=
e boundaries.
   The locking issues that arise with zsmalloc for reaping even a single pa=
geframe
   are complex; though they might eventually be solved with zsmalloc, this =
is
   likely a very big project.

C) Zcache uses zbud(v1) for cleancache pages and includes a shrinker which
   reclaims pairs of zpages to release whole pageframes, but there is
   no attempt to shrink/reclaim cleanache pageframes in LRU order.
   It would also be nice if single-cleancache-pageframe reclaim could
   be implemented.

D) Ramster is built on top of zcache, but required a handful of changes
   (on the order of 100 lines).  Due to various circumstances, ramster was
   submitted as a fork of zcache with the intent to unfork as soon as
   possible.  The proposal to promote the older zcache perpetuates that for=
k,
   requiring fixes in multiple places, whereas the new codebase supports
   ramster and provides clearly defined boundaries between the two.

The new codebase (zcache) just submitted as part of drivers/staging/ramster
resolves these problems (though (A) is admittedly still a work in progress)=
.
Before other key mm maintainers read and comment on zcache, I think
it would be most wise to move to a codebase which resolves the known design
problems or, at least to thoroughly discuss and debunk the design issues
described above.  OR... it may be possible to identify and pursue some
compromise plan.  In any case, I believe the promotion proposal is prematur=
e.

Unfortunately, I will again be away from email for a few days, but
will be happy to respond after I return if clarification or more detailed
discussion is needed.

Dan

Footnotes:
[1] zpage is shorthand for a compressed PAGE_SIZE-sized page.
[2] frontswap, since it uses the tmem architecture, has always had a "front=
door
    bouncer"... any frontswap page can be rejected by zcache for any reason=
,
    such as if there is no non-emergency pageframes available or if any ind=
ividual
    page (or long sequence of pages) compresses poorly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
