Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6A7B96B00B4
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 06:18:32 -0400 (EDT)
Date: Wed, 12 Sep 2012 11:18:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: iwl3945: order 5 allocation during ifconfig up; vm problem?
Message-ID: <20120912101826.GL11266@suse.de>
References: <20120909213228.GA5538@elf.ucw.cz>
 <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com>
 <20120910111113.GA25159@elf.ucw.cz>
 <20120911162536.bd5171a1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120911162536.bd5171a1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Machek <pavel@ucw.cz>, David Rientjes <rientjes@google.com>, sgruszka@redhat.com, linux-wireless@vger.kernel.org, johannes.berg@intel.com, wey-yi.w.guy@intel.com, ilw@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 11, 2012 at 04:25:36PM -0700, Andrew Morton wrote:
> On Mon, 10 Sep 2012 13:11:13 +0200
> Pavel Machek <pavel@ucw.cz> wrote:
> 
> > On Sun 2012-09-09 15:40:55, David Rientjes wrote:
> > > On Sun, 9 Sep 2012, Pavel Machek wrote:
> > > 
> > > > On 3.6.0-rc2+, I tried to turn on the wireless, but got
> > > > 
> > > > root@amd:~# ifconfig wlan0 10.0.0.6 up
> > > > SIOCSIFFLAGS: Cannot allocate memory
> > > > SIOCSIFFLAGS: Cannot allocate memory
> > > > root@amd:~# 
> > > > 
> > > > It looks like it uses "a bit too big" allocations to allocate
> > > > firmware...? Order five allocation....
> > > > 
> > > > Hmm... then I did "echo 3  > /proc/sys/vm/drop_caches" and now the
> > > > network works. Is it VM problem that it failed to allocate memory when
> > > > it was freeable?
> > > > 
> > > 
> > > Do you have CONFIG_COMPACTION enabled?
> > 
> > Yes:
> > 
> > pavel@amd:/data/l/linux-good$ zgrep CONFIG_COMPACTION /proc/config.gz 
> > CONFIG_COMPACTION=y
> 
> Asking for a 256k allocation is pretty crazy - this is an operating
> system kernel, not a userspace application.
> 
> I'm wondering if this is due to a recent change, but I'm having trouble
> working out where the allocation call site is.

It may be indirectly due to a recent change and this was somewhat
deliberate. Order-5 is larger than PAGE_ALLOC_COSTLY_ORDER and I doubt
__GFP_REPEAT was set so it is treated as something that can fail in
preference to aggressively reclaiming pages to satisfy the allocation. In
older kernels with lumpy reclaim and an aggressive kswapd it would have
probably succeeded but now it errs on the side of failing early instead
assuming that the caller can recover. Drivers that depend on order-5
allocations to succeed for correct operation are somewhat frowned upon.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
