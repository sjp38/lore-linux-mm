Date: Wed, 16 Aug 2000 16:46:53 -0300
Subject: [RFC] Some random 2.5 swapfile ideas
Message-ID: <20000816164653.A464@cesarb.personal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Here's some random ideas about swapfiles I had yesterday when going to sleep:

(for the famous 2.5 VM of course, let's not break 2.4 again)

1) Remote swapfile

Swapping over ndb or over nfs. Probably already works. Useful only in diskless
nfs workstations.

2) 'Hidden' swapfiles

After running the swapon syscall, the user mode swapon unlinks the swapfile.
Probably already works. But the VM should expect this and avoid being confused
by it.

3) (the main idea) dynamically resizing swapfiles

Instead of having a fixed size swapfile, the swapfile can change size between a
user-mode supplied minimum and min(a user-mode supplied maximum, a user-mode
supplied percentage*the free space in the swapfile's filesystem). The defaults
I've thought of are a minimum of 0 pages and a maximum of 4*physical mem size
or 2% of the disk free space (the 4*physical mem size idea came from the page
overcommit setting of Windows 3.1)

This would allow the swapfile to grow a lot without always wasting a fixed
amount of the disk's space (I've already seen a 256+MB box with about 768MB of
swap, 100% swap free -- 768MB wasted). Combined with 'hidden' swapfiles, this
makes a neat effect (using the disk's free area as a swapfile).

To use it in remote swapping without having to use a file in nfs, a new
protocol would have to be used (together with a kernel daemon -- knetswap) to
allow the resizing.

The difficulties of this scheme (that will need help from the VM and even the
VFS) are:

- The VM must be able to deal with an ever-changing amount of free swap space.
- The VM must be able to deal with partial swapoffs
- The VFS must have a disk_pressure callback to ask the swapfile to shrink (and
  return a flag indicating if it was possible), when the background kunswapd
  (look riel I found a use for that name =) ) wasn't enough (or the user told
  us to use 100% of the disk's free space).

To do the partial swapoffs, the VM will need to keep a MRU list for the pages
in the swap. The partial swapoff might be synchronous (disk_pressure callback,
swapoff syscall, or a change in the user-requested min/max values for that
swapfile) or asynchronous (background kunswapd daemon notices the free disk
space has shrunk). A disk_pressure-induced partial swapoff must also be able to
return false (meaning "I can't free more space -- sorry") when doing a partial
swapoff would cause a OOM situation.


You might think "I'll never need/use this" -- but someone will. And I think
it's useful enough that someone will end up coding a patch for it. It'll be a
lot easier if the VM is already prepared to deal with swapfiles which change
size the whole time.

Comments?

-- 
Cesar Eduardo Barros
cesarb@nitnet.com.br
cesarb@dcc.ufrj.br
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
