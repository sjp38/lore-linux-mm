From: Karl Vogel <karl.vogel@seagha.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Date: Tue, 31 Aug 2004 01:02:06 +0200
References: <20040828151349.00f742f4.akpm@osdl.org> <41336B6F.6050806@pandora.be> <20040830203339.GA2955@logos.cnet>
In-Reply-To: <20040830203339.GA2955@logos.cnet>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200408310102.06510.karl.vogel@seagha.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Karl Vogel <karl.vogel@pandora.be>, Andrew Morton <akpm@osdl.org>, Jens Axboe <axboe@suse.de>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 30 August 2004 22:33, Marcelo Tosatti wrote:
> Can you please try the following - it limits the number of in-flight
> writeback pages to 25% of total RAM at the VM level.
>
> Does wonders for me with 8192 nr_requests. The hogs finish _much_ faster
> and and interactivity feels much better.
>
> With nr_requests=128, this limit is not reached (probably never), but with
> 8192, it certainly does.
>
> --- a/mm/vmscan.c	2004-08-30 17:50:25.000000000 -0300
> +++ b/mm/vmscan.c	2004-08-30 18:34:54.666423368 -0300
> @@ -247,6 +247,12 @@
>
>  static int may_write_to_queue(struct backing_dev_info *bdi)
>  {
> +	int nr_writeback = read_page_state(nr_writeback);
> +
> +	if (nr_writeback > (totalram_pages * 25 / 100)) {
> +		blk_congestion_wait(WRITE, HZ/5);
> +		return 0;
> +	}
>  	if (current_is_kswapd())
>  		return 1;
>  	if (current_is_pdflush())	/* This is unlikely, but why not... */

This fixes the OOM for me.. I can do some more testing if needed tomorrow..

[kvo@localhost sources]$ cat /proc/meminfo
MemTotal:       515728 kB
MemFree:        445084 kB
Buffers:          9492 kB
Cached:          33268 kB
SwapCached:          0 kB
Active:          19748 kB
Inactive:        28716 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       515728 kB
LowFree:        445084 kB
SwapTotal:     1044216 kB
SwapFree:      1044216 kB
Dirty:              84 kB
Writeback:           0 kB
Mapped:           8960 kB
Slab:            17284 kB
Committed_AS:     9544 kB
PageTables:        548 kB
VmallocTotal:   516020 kB
VmallocUsed:      2372 kB
VmallocChunk:   512624 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     4096 kB
[kvo@localhost sources]$ date;./expunge 1024;date;time cat /proc/meminfo;date
Tue Aug 31 00:51:20 CEST 2004
Tue Aug 31 00:51:55 CEST 2004
MemTotal:       515728 kB
MemFree:        381036 kB
Buffers:           272 kB
Cached:           2844 kB
SwapCached:     120572 kB
Active:           2036 kB
Inactive:       121868 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       515728 kB
LowFree:        381036 kB
SwapTotal:     1044216 kB
SwapFree:       919020 kB
Dirty:               0 kB
Writeback:           0 kB
Mapped:           1420 kB
Slab:             5932 kB
Committed_AS:     9764 kB
PageTables:        572 kB
VmallocTotal:   516020 kB
VmallocUsed:      2372 kB
VmallocChunk:   512624 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     4096 kB

real	0m0.071s
user	0m0.000s
sys	0m0.000s
Tue Aug 31 00:51:55 CEST 2004
[kvo@localhost sources]$ date;./expunge 1024;date;time cat /proc/meminfo;date
Tue Aug 31 00:52:41 CEST 2004
Tue Aug 31 00:53:16 CEST 2004
MemTotal:       515728 kB
MemFree:        383832 kB
Buffers:           220 kB
Cached:           2792 kB
SwapCached:     117196 kB
Active:           1944 kB
Inactive:       118652 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       515728 kB
LowFree:        383832 kB
SwapTotal:     1044216 kB
SwapFree:       922316 kB
Dirty:               0 kB
Writeback:       16432 kB
Mapped:           1484 kB
Slab:             6328 kB
Committed_AS:     9768 kB
PageTables:        572 kB
VmallocTotal:   516020 kB
VmallocUsed:      2372 kB
VmallocChunk:   512624 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     4096 kB

real	0m0.328s
user	0m0.000s
sys	0m0.001s
Tue Aug 31 00:53:16 CEST 2004
[kvo@localhost sources]$ exit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
