Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35DE18D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 16:47:57 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <63a3434d-dc24-4dd0-9e1b-0169c4a2b219@default>
Date: Mon, 14 Mar 2011 13:47:45 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [LSF/MM TOPIC] (revised) RAMster: peer-to-peer transcendent memory
 (was: improving in-kernel transcendent memory)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@linuxfoundation.org, linux-mm@kvack.org
Cc: Nitin Gupta <ngupta@vflare.org>, kurt.hackel@oracle.com, chris.mason@oracle.com

(NOTE: No virtualization required so even those uninterested
in virtualization may find this interesting.)

In my original topic proposal here:

http://marc.info/?l=3Dlinux-mm&m=3D129684345708855=20

I concluded with the following teaser:

> I also hope to also be able to describe and possibly demo a
> brand new in-kernel (non-virtualization) user of transcendent
> memory (including both cleancache and frontswap) that I think
> attendees in ALL tracks will find intriguing, but I'm not ready
> to talk about until closer to LSF/MM workshop.

The code has come along well and I'd like to propose this
now as a topic.  If other track PC members are interested,
it can be a general talk; if not, it can be an MM track topic
or maybe a lightning talk.  (Or if few enough people have interest,
a hallway track topic or talk-to-myself track :-)

Thanks,
Dan Magenheimer

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

RAMSTER: Peer-to-peer Transcendent Memory

Assume you have two or more independent Linux systems connected
by a high-speed non-coherent interconnect (e.g. 10Gb ethernet).
It is not uncommon for the memory load in each system to
vary independently... sometimes system A has high memory
pressure and sometimes system B has high memory pressure but
it is exceedingly rare for both (or all) systems to have
high memory pressure at the same time.  In fact, if you could
magically and highly dynamically hot-plug chunks of RAM from
one system to another in response to memory pressure, the
sum of the RAM across all systems could be used more effectively
to avoid swapping on any system, or the need for adding RAM to
some or all of the individual systems.

This is the promise of RAMster, a "peer-to-peer" implementation
of Transcendent Memory.  Using the hooks already implemented
in cleancache and frontswap, clean page cache pages and swap
pages can be transparently moved from a system under memory
pressure to a system not under memory pressure.  As long as
the overhead to move a page between systems is significantly
faster than a read from or write to disk, RAMster is a net win.

The prototype implementation combines zcache (previously known
as kztmem) with the cluster foundation of ocfs2.  All pages
are compressed locally in zcache then, when a shrinker asks
zcache to surrender space, some pages are sent across the wire.
For "gets", zcache is checked first, and if the page has
been "remotified", the page is synchronously repatriated from
across the wire to satisfy the request and locally decompressed.

The prototype is still a proof-of-concept and needs a lot more
work, but should provoke some interesting discussion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
