Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA11075
	for <linux-mm@kvack.org>; Fri, 15 Nov 2002 16:39:02 -0800 (PST)
Message-ID: <3DD593A5.9DB99F5@digeo.com>
Date: Fri, 15 Nov 2002 16:39:01 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: VM trouble, both 2.4 and 2.5
References: <02111521422000.00195@7ixe4> <3DD578D1.1E3134A0@digeo.com> <02111601184000.00209@7ixe4>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@keyaccess.nl>
Cc: linux-mm@kvack.org, Con Kolivas <contest@kolivas.net>
List-ID: <linux-mm.kvack.org>

Rene Herman wrote:
> 
> On Friday 15 November 2002 23:44, Andrew Morton wrote:
> 
> > Are you *sure* it happens with ext2?  Checked /proc/mounts to ensure
> > that /tmp is really ext2?
> 
> Darn it!
> 
> You are absolutely correct, /tmp was on /, ext3 builtin, ext2 as module, so
> it was really still ext3. /bin/mount lied to me. When I moved /tmp to its own
> partition, really ext2 this time, things stopped misbehaving. That ext2/ext3
> thing was the very first thing I tried, wasted a lot of time :-(

heh.  That mount(8) thing really sucks.  Especially if you spend
time helping folk out with ext3 problems.

Maybe we should fix it...

> > I could certainly believe that the (weird) ext3 behaviour would upset
> > the overcommit beancounting though.  Hundreds of megabytes of memory
> > on the inactive list but not in pagecache probably looks like anonymous
> > memory to the overcommit logic.
> 
> Does this bit mean the report was still somewhat useful (for fixing either
> ext3 or the overcommit accounting) though, or was it already well-known?

Very useful thanks, no it's not well known.  Or at least, it wasn't.

It's at the "hm, that's funny.  Oh, I know what that is" stage.  The
pages are trivially reclaimable, but I hadn't thought about the
effect on overcommit's deadreckoning logic.

The problem got worse in 2.5 because truncate got better - the first
pass of truncate will zoom over the locked pages and shoot down all
the dirty pages which aren't under IO yet.  Then it will go back and
do the under-IO pages.  It's all the dirty pages which were reaped
by the first pass which cause this problem.
 
> Well, anyways, thanks heaps for the explanation, was going slowly mad here ...

Well.  What the heck am I going to do about it?  I guess change the
overcommit logic to look at page_states.nr_mapped or something.  Or
maybe take a look at fixing ext3.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
