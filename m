Date: Sun, 4 Jan 2004 13:11:26 +0800
From: Eugene Teo <eugene.teo@eugeneteo.net>
Subject: Re: [Kernel-janitors] [PATCH] Check return code in mm/vmscan.c
Message-ID: <20040104051125.GF20458@eugeneteo.net>
Reply-To: Eugene Teo <eugene.teo@eugeneteo.net>
References: <20040103132524.GA21909@eugeneteo.net> <20040103222706.GM6982@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040103222706.GM6982@parcelfarce.linux.theplanet.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <willy@debian.org>
Cc: linux-mm@kvack.org, kernel-janitors@osdl.org
List-ID: <linux-mm.kvack.org>

<quote sender="Matthew Wilcox">
> On Sat, Jan 03, 2004 at 09:25:24PM +0800, Eugene Teo wrote:
> > http://www.anomalistic.org/patches/vmscan-check-ret-kernel_thread-fix-2.6.1-rc1-mm1.patch
> > 
> > diff -Naur -X /home/amnesia/w/dontdiff 2.6.1-rc1-mm1/mm/vmscan.c 2.6.1-rc1-mm1-fix/mm/vmscan.c
> > --- 2.6.1-rc1-mm1/mm/vmscan.c	2004-01-03 20:33:39.000000000 +0800
> > +++ 2.6.1-rc1-mm1-fix/mm/vmscan.c	2004-01-03 21:16:30.000000000 +0800
> > @@ -1093,10 +1093,16 @@
> >  
> >  static int __init kswapd_init(void)
> >  {
> > +	int ret;
> >  	pg_data_t *pgdat;
> >  	swap_setup();
> > -	for_each_pgdat(pgdat)
> > -		kernel_thread(kswapd, pgdat, CLONE_KERNEL);
> > +	for_each_pgdat(pgdat) {
> > +		ret = kernel_thread(kswapd, pgdat, CLONE_KERNEL);
> > +		if (ret < 0) {
> > +			printk("%s: unable to start kernel thread\n", __FUNCTION__);
> > +			return ret;
> > +		}
> > +	}
> >  	total_memory = nr_free_pagecache_pages();
> >  	return 0;
> >  }
> 
> If your new code is triggered, we've just failed to set up total_memory.
> I expect the system to behave very oddly after this ;-)

a panic call seems to be more appropriate :)

Here is the new fix. Patch compiles, and tested.

http://www.anomalistic.org/patches/vmscan-check-ret-kernel_thread-fix-2.6.1-rc1-mm1.patch

diff -Naur -X /home/amnesia/w/dontdiff 2.6.1-rc1-mm1/mm/vmscan.c 2.6.1-rc1-mm1-fix/mm/vmscan.c
--- 2.6.1-rc1-mm1/mm/vmscan.c	2004-01-04 10:29:24.000000000 +0800
+++ 2.6.1-rc1-mm1-fix/mm/vmscan.c	2004-01-04 13:04:52.000000000 +0800
@@ -1093,10 +1093,14 @@
 
 static int __init kswapd_init(void)
 {
+	int ret;
 	pg_data_t *pgdat;
 	swap_setup();
-	for_each_pgdat(pgdat)
-		kernel_thread(kswapd, pgdat, CLONE_KERNEL);
+	for_each_pgdat(pgdat) {
+		ret = kernel_thread(kswapd, pgdat, CLONE_KERNEL);
+		if (ret < 0)
+			panic("%s: unable to initialise kswapd\n", __FUNCTION__);
+	}
 	total_memory = nr_free_pagecache_pages();
 	return 0;
 }

-- 
Eugene TEO   <eugeneteo@eugeneteo.net>   <http://www.anomalistic.org/>
1024D/14A0DDE5 print D851 4574 E357 469C D308  A01E 7321 A38A 14A0 DDE5
main(i) { putchar(182623909 >> (i-1) * 5&31|!!(i<7)<<6) && main(++i); }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
