Date: Mon, 30 Aug 2004 17:33:39 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040830203339.GA2955@logos.cnet>
References: <20040828151349.00f742f4.akpm@osdl.org> <20040828222816.GZ5492@holomorphy.com> <20040829033031.01c5f78c.akpm@osdl.org> <20040829141526.GC10955@suse.de> <20040829141718.GD10955@suse.de> <20040829131824.1b39f2e8.akpm@osdl.org> <20040829203011.GA11878@suse.de> <20040829135917.3e8ffed8.akpm@osdl.org> <20040830152025.GA2901@logos.cnet> <41336B6F.6050806@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41336B6F.6050806@pandora.be>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Karl Vogel <karl.vogel@pandora.be>
Cc: Andrew Morton <akpm@osdl.org>, Jens Axboe <axboe@suse.de>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 30, 2004 at 08:01:19PM +0200, Karl Vogel wrote:
> Marcelo Tosatti wrote:
> 
> >What is the problem Karl is seeing again? There seem to be several, lets
> >separate them
> >
> >- OOM killer triggering (if there's swap space available and 
> >"enough" anonymous memory to be swapped out this should not happen). 
> >One of his complaint on the initial report (about the OOM killer).
> 
> Correct. On my 512Mb RAM system with 1Gb swap partition, running a 
> calloc(1Gb) causes the process to get OOM killed when using CFQ.
> The problem is not CFQ as such.. the problem is when nr_requests is too 
> large (8192 being the default for CFQ).
> 
> The same will happen with the default nr_request of 128 which AS uses, 
> if you use a low memory system. e.g. I booted with mem=128M and then a 
> calloc(128Mb) can trigger the OOM.

Karl,

Can you please try the following - it limits the number of in-flight writeback 
pages to 25% of total RAM at the VM level. 

Does wonders for me with 8192 nr_requests. The hogs finish _much_ faster and 
and interactivity feels much better.

With nr_requests=128, this limit is not reached (probably never), but with 8192, 
it certainly does.

--- a/mm/vmscan.c	2004-08-30 17:50:25.000000000 -0300
+++ b/mm/vmscan.c	2004-08-30 18:34:54.666423368 -0300
@@ -247,6 +247,12 @@
 
 static int may_write_to_queue(struct backing_dev_info *bdi)
 {
+	int nr_writeback = read_page_state(nr_writeback);
+
+	if (nr_writeback > (totalram_pages * 25 / 100)) { 
+		blk_congestion_wait(WRITE, HZ/5);
+		return 0;
+	}
 	if (current_is_kswapd())
 		return 1;
 	if (current_is_pdflush())	/* This is unlikely, but why not... */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
