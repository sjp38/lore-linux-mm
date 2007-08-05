Date: Sun, 5 Aug 2007 22:21:12 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805202112.GA32088@lazybastard.org>
References: <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804210351.GA9784@elte.hu> <20070804225121.5c7b66e0@the-village.bc.nu> <20070805072141.GA4414@elte.hu> <20070805085354.GC6002@1wt.eu> <20070805141708.GB25753@lazybastard.org> <1186336953.2777.17.camel@laptopd505.fenrus.org> <20070805183714.GA31606@lazybastard.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070805183714.GA31606@lazybastard.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Arjan van de Ven <arjan@infradead.org>, Willy Tarreau <w@1wt.eu>, =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, 5 August 2007 20:37:14 +0200, JA?rn Engel wrote:
> 
> Guess I should throw in a kernel compile test as well, just to get a
> feel for the performance.

Three runs each of noatime, relatime and atime, both with cold caches
and with warm caches.  Scripts below.  Run on a Thinkpad T40, 1.5GHz,
2GiB RAM, 60GB 2.5" IDE disk, ext3.

Biggest difference between atime and noatime (median run, cold cache) is
~2.3%, nowhere near the numbers claimed by Ingo.  Ingo, how did you
measure 10% and more?

noatime, cold cache	relatime, cold cache	atime, cold cache
	                	                
real    2m10.242s	real    2m10.549s	real    2m10.388s
user    1m46.886s	user    1m46.680s	user    1m47.000s
sys     0m8.243s	sys     0m8.423s	sys     0m8.239s
	                	                
real    2m11.270s	real    2m11.212s	real    2m14.280s
user    1m46.940s	user    1m46.776s	user    1m46.670s
sys     0m8.139s	sys     0m8.283s	sys     0m8.503s
	                	                
real    2m11.601s	real    2m14.861s	real    2m14.335s
user    1m46.920s	user    1m47.103s	user    1m46.846s
sys     0m8.246s	sys     0m8.266s	sys     0m8.349s
	                	                
noatime, warm cache	relatime, warm cache	atime, warm cache
	                	                
real    1m55.894s	real    1m56.053s	real    1m56.905s
user    1m46.683s	user    1m46.600s	user    1m46.853s
sys     0m8.186s	sys     0m8.349s	sys     0m8.249s
	                	                
real    1m55.823s	real    1m56.093s	real    1m57.077s
user    1m46.583s	user    1m46.913s	user    1m46.590s
sys     0m8.259s	sys     0m7.966s	sys     0m8.523s
	                	                
real    1m55.789s	real    1m56.214s	real    1m57.224s
user    1m46.803s	user    1m46.753s	user    1m46.953s
sys     0m8.053s	sys     0m8.113s	sys     0m8.113s

JA?rn

-- 
Data expands to fill the space available for storage.
-- Parkinson's Law

Cold cache script:
#!/bin/sh
make distclean
echo 1 > /proc/sys/vm/drop_caches
echo 2 > /proc/sys/vm/drop_caches
echo 3 > /proc/sys/vm/drop_caches
make allnoconfig
time make

Warm cache script:
#!/bin/sh
make distclean
make allnoconfig
rgrep laksdflkdsaflkadsfja .
time make

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
