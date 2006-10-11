Date: Wed, 11 Oct 2006 10:11:43 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: SPAM: Re: [patch 2/5] mm: fault vs invalidate/truncate race fix
In-Reply-To: <20061011165717.GB5259@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0610111007000.3952@g5.osdl.org>
References: <20061010121314.19693.75503.sendpatchset@linux.site>
 <20061010121332.19693.37204.sendpatchset@linux.site> <20061010213843.4478ddfc.akpm@osdl.org>
 <452C838A.70806@yahoo.com.au> <20061010230042.3d4e4df1.akpm@osdl.org>
 <Pine.LNX.4.64.0610110916540.3952@g5.osdl.org> <20061011165717.GB5259@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Wed, 11 Oct 2006, Nick Piggin wrote:
> > 
> > The original IO could have been started by a person who didn't have 
> > permissions to actually carry it out successfully, so if you enter with 
> > the page locked (because somebody else started the IO), and you wait for 
> > the page and it's not up-to-date afterwards, you absolutely _have_ to try 
> > the IO, and can only return a real IO error after your _own_ IO has 
> > failed.
> 
> Sure, but we currently try to read _twice_, don't we?

Well, we have the read-ahead, and then the real read. By the time we do 
the real read, we have forgotten about the read-ahead details, so..

We also end up often having a _third_ one, simply because the _user_ tries 
it twice: it gets a partial IO read first, and then tries to continue and 
won't give up until it gets a real error.

So yes, we can end up reading it even more than twice, if only due to 
standard UNIX interfaces: you always have to have one extra "read()" 
system call in order to get the final error (or - much more commonly - 
EOF, of course).

If we tracked the read-aheads that _we_ started, we could probably get rid 
of one of them.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
