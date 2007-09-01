Subject: Re: speeding up swapoff
References: <1188394172.22156.67.camel@localhost>
	<20070829073040.1ec35176@laptopd505.fenrus.org>
	<1188398683.22156.77.camel@localhost>
From: Andi Kleen <andi@firstfloor.org>
Date: 02 Sep 2007 00:20:22 +0200
In-Reply-To: <1188398683.22156.77.camel@localhost>
Message-ID: <p73fy1yvxi1.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Drake <ddrake@brontes3d.com>
Cc: Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Daniel Drake <ddrake@brontes3d.com> writes:
> 
> It's more-or-less a real life problem. We have an interactive
> application which, when triggered by the user, performs rendering tasks
> which must operate in real-time. In attempt to secure performance, we
> want to ensure everything is memory resident and that nothing might be
> swapped out during the process. So, we run swapoff at that time.

If the system gets under serious memory pressure it'll happily discard
your text pages too (and later reload them from disk). The same
for any file data you might need to access.

swapoff will only affect anonymous memory, but not all the other
memory you'll need as well.

There's no way around mlock/mlockall() to really prevent this.

Still even with that you could still lose dentries/inodes etc which
can also cause stalls. The only way to keep them locked
is to keep the files always open.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
