Received: from zape.um.es (localhost [127.0.0.1])
	by zape.um.es (8.9.1b+Sun/8.9.1) with ESMTP id OAA00565
	for <linux-mm@kvack.org>; Sun, 9 Dec 2001 14:03:49 +0100 (MET)
Date: Sun, 9 Dec 2001 13:58:50 +0100 (CET)
From: Juan Piernas Canovas <piernas@ditec.um.es>
Subject: Re: ext3 writeback mode slower than ordered mode?
In-Reply-To: <3C12C57C.FF93FAC0@zip.com.au>
Message-ID: <Pine.LNX.4.21.0112091353020.6975-100000@ditec.um.es>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: zlatko.calusic@iskon.hr, sct@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Dec 2001, Andrew Morton wrote:

> Zlatko Calusic wrote:
> > 
> > Hi!
> > 
> > My apologies if this is an FAQ, and I'm still catching up with
> > the linux-kernel list.
> > 
> > Today I decided to convert my /tmp partition to be mounted in
> > writeback mode, as I noticed that ext3 in ordered mode syncs every 5
> > seconds and that is something defenitely not needed for /tmp, IMHO.
> > 
> > Then I did some tests in order to prove my theory. :)
> > 
> > But, alas, writeback is slower.
> > 
> 
> I cannot reproduce this.  Using http://www.zip.com.au/~akpm/writer.c
> 
> ext2:            0.03s user 1.43s system 97% cpu 1.501 total
> ext3 writeback:  0.02s user 2.33s system 96% cpu 2.431 total
> ext3 ordered:    0.02s user 2.52s system 98% cpu 2.574 total
> 
> ext3 is significantly more costly in either journalling mode,
> probably because of the bitmap manipulation - each time we allocate
> a block to the file, we have to muck around doing all sorts
> of checks and list manipulations against the buffer which holds
> the bitmap.  Not only is this costly, but ext2 speculatively
> sets a bunch of bits at the same time, which ext3 cannot do
> for consistency reasons.
> 
> There are a few things we can do to pull this back, but given that
> this is all pretty insignificant once you actually start doing disk
> IO, we couldn't justify the risk of destabilising the filesystem
> for small gains.
Hi!

Sorry, but I can confirm that Ext3 is slower with "-o
data=writeback" option than with "-o data=ordered" option when you create
and delete a lot of files. I use 2.2.19 Linux kernel along with 0.0.7a
Ext3 version.

Bye!

	Juan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
