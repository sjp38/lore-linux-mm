Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA03864
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 06:59:48 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> 	<m190lxmxmv.fsf@flinx.npwt.net> 	<199807141730.SAA07239@dax.dcs.ed.ac.uk> 	<m14swgm0am.fsf@flinx.npwt.net> 	<87d8b370ge.fsf@atlas.CARNet.hr> <199807221033.LAA00826@dax.dcs.ed.ac.uk>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 23 Jul 1998 12:59:38 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 22 Jul 1998 11:33:18 +0100"
Message-ID: <87hg08vnmt.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 18 Jul 1998 15:28:17 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > I must admit, after lot of critics I made upon page aging, that I
> > believe it's the right way to go, but it should be done properly.
> > Performance should be better, not worse.
> 
> Let me say one thing clearly: I'm not against page ageing (I implemented
> it in the first place for the swapper), I'm against the bad tuning it
> introduced.  *IF* we can fix that, then keep the ageing, sure.  However,
> we need to fix it _completely_.  The non-cache-ageing scheme at least
> has the advantage that we understand its behaviour, so fiddling too much
> this close to 2.2 is not necessarily a good idea.  2.1.110, for example,
> now fails to boot for me in low memory configurations because it cannot
> keep enough higher order pages free for 4k NFS to work, never mind 8k.
> 
> That's the danger: we need to introduce new schemes like this at the
> beginning of the development cycle for a new kernel, not the end.
> 

Cool!
Then we agree on all topics. :)

As promised, I did some testing and I maybe have a solution (big
words, yeah! :)).

As I see it, page cache seems too persistant (it grows out of bounds)
when we age pages in it.

One wrong way of fixing it is to limit page cache size, IMNSHO.

I tried the other way, to age page cache harder, and it looks like it
works very well. Patch is simple, so simple that I can't understand
nobody suggested (something like) it yet.


--- filemap.c.virgin   Tue Jul 21 18:41:30 1998
+++ filemap.c   Thu Jul 23 12:14:43 1998
@@ -171,6 +171,11 @@
                                touch_page(page);
                                break;
                        }
+                       /* Age named pages aggresively, so page cache
+                        * doesn't grow too fast.    -zcalusic
+                        */
+                       age_page(page);
+                       age_page(page);
                        age_page(page);
                        if (page->age)
                                break;


After lots of testing, I am quite pleased with performance with that
small change.

Where, using official kernel, copying few hundreds of data to
/dev/null would outswap cca 20MB (and constantly keep swapping, thus
killing performance), now it swaps out only 5MB, probably exactly that
pages that are not needed anyway. And that is something that I like
with aging.

I can provide thorough benchmark data, if needed.

If I put only two age_page()s, there's still too much swapping for my
taste.

With three age_page()s, read performance is as expected, and still we
manage memory more efficiently than without page aging.

Patch applies cleanly on 2.1.110.

Comments?

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	  Don't steal - the government hates competition...
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
