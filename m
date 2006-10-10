Date: Tue, 10 Oct 2006 06:11:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010041141.GL15822@wotan.suse.de>
References: <20061010023654.GD15822@wotan.suse.de> <Pine.LNX.4.64.0610091951350.3952@g5.osdl.org> <20061009202039.b6948a93.akpm@osdl.org> <20061010033412.GH15822@wotan.suse.de> <20061009205030.e247482e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061009205030.e247482e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2006 at 08:50:30PM -0700, Andrew Morton wrote:
> On Tue, 10 Oct 2006 05:34:12 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > the problem is that page_mapping is still free to go NULL at any
> > time, and __set_page_dirty_buffers wasn't checking for that.
> > 
> > If there is another race, then it must be because the buffer code
> > cannot cope with dirty buffers against a truncated page. It is
> > kind of spaghetti, though. What stops set_page_dirty_buffers from
> > racing with block_invalidatepage, for example?
> 
> Nothing that I can think of.

block_invalidatepage
 discard_buffer
                         set_page_dirty_buffers
  try_to_release_page
   try_to_free_buffers
    drop_buffers [fails because buffer is dirty]

Hmm...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
