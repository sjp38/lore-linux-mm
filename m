Message-ID: <3D2CCF23.3AD6043@zip.com.au>
Date: Wed, 10 Jul 2002 17:19:47 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <3D2CBE6A.53A720A0@zip.com.au> <167170000.1026343616@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> ...
> > But NMI-based oprofile is bang-on target so I recommend you use that.
> > I'll publish my oprofile-for-2.5 asap.
> 
> That'd be good, but I'm not sure my box likes NMIs too much ;-)
> We'll see ....

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.25/oprofile.patch.gz

Now, oprofile trick for young players: the most useful metric
is CPU_CLK_UNHALTED.  And the example commandline at http://oprofile.sourceforge.net/doc.php3 works just fine.

But the kernel halts the clock in default_idle, and the numbers
you get out of the profiler only reflect the amount of time which
was spent with the clock unhalted.

So for example if you run oprofile against an idle machine,
it looks like the machine is spending 40% of its cycles handling
the clock timer.  Because it doesn't account for halted cycles.

I find this interpolation hurts my brain too much, so I always
use the `idle=poll' kernel boot parameter so the clock is never
halted.  This gives profiles which are comprehensible even to simple
Australians.

So.

- Set NR_CPUS to 8.  Otherwise oprofile does kmalloc(256kbytes)
  and won't start.  This is Rusty's fault.

- patch, build, install kernel

- oprofile keeps stuff in /var/opd, and I'm never sure whether
  my profiles are fresh, or are a mixture of this one and the
  previous one.  So I always blow away /var/opd first.

	rm -rf /var/opd
	<start benchmark>
	op_start --vmlinux=/boot/vmlinux --map-file=/boot/System.map \
			--ctr0-event=CPU_CLK_UNHALTED --ctr0-count=300000
	op_stop
	<benchmark ends>
	oprofpp -dl -i /boot/vmlinux

Easy.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
