Date: Tue, 16 May 2000 17:07:07 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: More observations...
Message-ID: <20000516170707.B30047@redhat.com>
References: <20000516112012.D26581@redhat.com> <Pine.LNX.4.21.0005161228030.30661-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0005161228030.30661-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Tue, May 16, 2000 at 12:41:05PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Mike Simons <msimons@moria.simons-clan.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, May 16, 2000 at 12:41:05PM -0300, Rik van Riel wrote:
> 
> > The concept is quite simple: if you can limit a process's RSS,
> > you can limit the amount of memory which is pinned in process
> > page tables, and thus subject to expensive swapping.  Note that
> > you don't have to get rid of the pages --- you can leave them in
> > the page cache/swap cache, where they can be re-faulted rapidly
> > if needed, but if the memory is needed for something else then
> > shrink_mmap can reclaim the pages rapidly.
> 
> There's one problem with this idea. The current implementation
> of shrink_mmap() skips over dirty pages, leading to a failing
> shrink_mmap(), calls to swap_out() and replacement of the wrong
> pages...

No, because if you have evicted the pages from the RSS, they are 
guaranteed to be clean.  The shrink_mmap reclaim will never have 
to block.  We always flush mmaped or anon pageson swapout, not on 
shrink_mmap().  

For writable shared file mappings, the flush only goes to the buffer
cache, not to disk, so we still rely on bdflush writeback, but 
currently filemap_swapout triggers the bdflush thread automatically
anyway.  Subsequent shrink_mmap reclaims will just find a locked
page and block, which is the desired behaviour.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
