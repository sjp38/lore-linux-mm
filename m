Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA21583
	for <linux-mm@kvack.org>; Mon, 21 Oct 2002 14:33:42 -0700 (PDT)
Message-ID: <3DB472B6.BC5B8924@digeo.com>
Date: Mon, 21 Oct 2002 14:33:42 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
References: <3DB46DFA.DFEB2907@digeo.com> <308170000.1035234988@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> >> My big NUMA box went OOM over the weekend and started killing things
> >> for no good reason (2.5.43-mm2). Probably running some background
> >> updatedb for locate thing, not doing any real work.
> >>
> >> meminfo:
> >>
> >
> > Looks like a plain dentry leak to me.  Very weird.
> >
> > Did the machine recover and run normally?
> 
> Nope, kept OOMing and killing everything .

Something broke.

> > Was it possible to force the dcache to shrink? (a cat /dev/hda1
> > would do that nicely)
> 
> Well, I didn't try that, but even looking at man pages got oom killed,
> so I guess not ... were you looking at the cat /dev/hda1 to fill pagecache
> or something? I have 16Gb of highmem (pretty much all ununsed) so
> presumably that'd fill the highmem first (pagecache?)

Blockdevices only use ZONE_NORMAL for their pagecache.  That cat will
selectively put pressure on the normal zone (and DMA zone, of course).
 
> > Is it reproducible?
> 
> Will try again. Presumably "find /" should do it? ;-)

You must have a lot of files.

Actually, I expect a `find /' will only stat directories,
whereas an `ls -lR /' will stat plain files as well.  Same
thing for dcache, but the ls will push the icache harder.

I don't know if updatedb stats regular files.  Presumably not.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
