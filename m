Date: Tue, 16 May 2000 12:41:05 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: More observations...
In-Reply-To: <20000516112012.D26581@redhat.com>
Message-ID: <Pine.LNX.4.21.0005161228030.30661-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mike Simons <msimons@moria.simons-clan.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 16 May 2000, Stephen C. Tweedie wrote:

> The concept is quite simple: if you can limit a process's RSS,
> you can limit the amount of memory which is pinned in process
> page tables, and thus subject to expensive swapping.  Note that
> you don't have to get rid of the pages --- you can leave them in
> the page cache/swap cache, where they can be re-faulted rapidly
> if needed, but if the memory is needed for something else then
> shrink_mmap can reclaim the pages rapidly.

There's one problem with this idea. The current implementation
of shrink_mmap() skips over dirty pages, leading to a failing
shrink_mmap(), calls to swap_out() and replacement of the wrong
pages...

> Rick's old memory hog flag is essentially a simple case of an
> RSS limit (the task RSS is limited to what it is currently set
> at).

Not really. The anti-hog code did a number of things:
- swap_out() scans tasks more and more agressively the
  bigger their RSS gets bigger, meaning we "push back
  harder" if a process is very big
- slow down the allocation rate of very big processes
  by having them call try_to_free_pages() if they want
  to allocate something. It doesn't have to steal a page
  from itself, but can steal the page from anywhere.

The effect should be comperable to RSS limits, only simpler ;)

(After all, all RSS limits do is make sure that the VM subsystem
"pushes back harder" against the VM pressure of big processes)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
