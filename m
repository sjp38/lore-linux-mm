Date: Thu, 11 Jan 2007 22:58:48 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: ext3 data=journal hangs
Message-Id: <20070111225848.dd9515f7.akpm@osdl.org>
In-Reply-To: <20070111213412.0b52bf63.randy.dunlap@oracle.com>
References: <20070111213412.0b52bf63.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jan 2007 21:34:12 -0800
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> (resending for wider audience)
> 
> Date: Wed, 10 Jan 2007 16:03:51 -0800
> To: linux-ext4@vger.kernel.org
> 
> 
> On Tue, 9 Jan 2007 15:11:23 -0800 Randy Dunlap wrote:
> 
> > Hi,
> > 
> > (2.6.20-rc4, x86_64 1-proc on SMP kernel, 1 GB RAM)
> > 
> > I'm running fsx-linux (akpm ext3-tools version) on an ext3 fs
> > with data=journal and fs blocksize=2048.  I've been trying to
> > get some kind of kernel messages from it but I can't get any
> > debug IO done successfully.
> > 
> > It has hung on me 3 times in a row today.  I'm using this command:
> > fsx-linux -l 100M -N 50000 -S 0 fsxtestfile
> > 
> > This is run in a new partition on a IDE drive (/dev/hda7,
> > using legacy IDE drivers).
> > 
> > Any suggestions for debug output?  I can see SysRq output on-screen
> > (sometimes) but it doesn't make it to my serial console.
> > 
> > Any patches to test?  :)
> 
> More notes:
> Fails (hangs) with fs blocksize of 1024, 2048, or 4096.
> On data=journal mode hangs.  writeback and ordered run fine.
> 
> After several runs (hangs), I was able to get some sysrq output
> to the serial console.
> 
> kernel config:  http://oss.oracle.com/~rdunlap/configs/config-2620-rc4-hangs
> message log:    http://oss.oracle.com/~rdunlap/logs/fsx-capture.txt
> 
> Can anyone see what fsx-linux is waiting on there?
> 

Everybody got stuck in balance_dirty_pages().  The new thing in there is
that an nscd instance got stuck in balance_dirty_pages() on the pagefault's
new set_page_dirty_balance() path, so an mmap_sem is stuck, which causes
lots of other things to get stuck.

But I don't see why this should happen, really.  It all seems OK here. Is
any IO happening at all?

You don't have any shells at all?  If you do, try running /bin/sync,
see if the disk lights up.  Run `watch -n1 cat /proc/meminfo' when testing
to see what dirty memory is doing.  And `vmstat 1'.  Try sysrq-S, see if
that gets things unstuck.

I guess it's consistent with the disk system losing its brains, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
