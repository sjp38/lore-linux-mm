Date: Thu, 28 Sep 2000 08:31:56 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: 2.4.0-t9p7 and mmap002 - freeze
In-Reply-To: <39D264D0.77B3142@norran.net>
Message-ID: <Pine.Linu.4.10.10009280803050.1233-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Sep 2000, Roger Larsson wrote:

> Hi,
> 
> Tried latest patch with the same result - freeze...

Ditto.

> No extra patches added.

Ditto.

> running from console as root
> mmap002 from memtest-0.0.3
> with RAMSIZE defined as 90 MB (I have 96MB)
> after a while with heavy disk access (thrashing?) the drive
> becomes silent - no more progress...
> [if you can not repeat this - try with less memory 32 MB...]

I'm using a little proggy from Christoph Rohland (swptst.c), and
do not have to jump through any hoops to reproduce the freeze.

> Magic works!
> 
> Magic memory
>  Constantly LOW on inactive_clean (0 is the most common)
>  lots of shared memory (almost equals active)
>  [can be normal condition since mmap002 produces dirty
>   mmaped pages]
> 
> Magic process:
>   Manual samples gave the following locations.
>   (NOTE: not a call trace)

If a kdb call trace will help (doubt it.. see below) I can post one.

>   We are trying to clean pages, but do we make any
>   progress since disk is silent?
> 
> Trace; c0127d85 <page_launder+3d/724>
> Trace; c0126dad <deactivate_page_nolock+13d/248>
> Trace; c0127e00 <page_launder+b8/724>
> Trace; c0128035 <page_launder+2ed/724>
> Trace; c0127dcc <page_launder+84/724>
> Trace; c0127dd0 <page_launder+88/724>
> Trace; c0127e00 <page_launder+b8/724>
> Trace; c012fd38 <try_to_free_buffers+4/138>
> 
> Magic Sigterm (Alt+SysRq+E)
>  Gives you a running system again.

Not here.  I looked at it with an IKD kernel, and here it's the same
loop as before.. __alloc_pages() running through try_again forever.
inactive_clean=0, a few pages bouncing between active and inactive_dirty.
__switch_to() never happens.  (though I can artificially yield and thus
make sysrq-e work.  Artificially scheduling only ensures that all other
tasks loop the same way. [coz inactive_clean=0.. page_launder() is always
failing to find something freeable])

> Notes:
>  Probably timing critical for entry into this state
>  since adding a few printk:s makes it happen less often.
>  I have even got complete mmap002 runs succeed - but
>  disk is running too much and for too long time...
>  a lot more than 10 min - normal run on previous testX
>  did usually take less than 3 minutes.

I'm still at < 1 minute survival.. with many seconds to spare ;-)
I have yet to have a run succeed, though virgin source _does_ last
a bit longer (odd) than KDB enabled kernel.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
