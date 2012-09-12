Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 70CCE6B00A3
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 01:57:28 -0400 (EDT)
Date: Tue, 11 Sep 2012 22:57:12 -0700
From: Marc MERLIN <marc@merlins.org>
Subject: Re: iwl3945: order 5 allocation during ifconfig up; vm problem?
Message-ID: <20120912055712.GE11613@merlins.org>
References: <20120909213228.GA5538@elf.ucw.cz> <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com> <20120910111113.GA25159@elf.ucw.cz> <20120911162536.bd5171a1.akpm@linux-foundation.org> <1347426988.13103.684.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347426988.13103.684.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Machek <pavel@ucw.cz>, David Rientjes <rientjes@google.com>, sgruszka@redhat.com, linux-wireless@vger.kernel.org, johannes.berg@intel.com, wey-yi.w.guy@intel.com, ilw@linux.intel.com, Andrew Morton <akpm@osdl.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 12, 2012 at 07:16:28AM +0200, Eric Dumazet wrote:
> On Tue, 2012-09-11 at 16:25 -0700, Andrew Morton wrote:
> 
> > Asking for a 256k allocation is pretty crazy - this is an operating
> > system kernel, not a userspace application.
> > 
> > I'm wondering if this is due to a recent change, but I'm having trouble
> > working out where the allocation call site is.
> > --
> 
> (Adding Marc Merlin to CC, since he reported same problem)
> 
> Thats the firmware loading in iwlwifi driver. Not sure if it can use SG.
> 
> drivers/net/wireless/iwlwifi/iwl-drv.c
> 
> iwl_alloc_ucode() -> iwl_alloc_fw_desc() -> dma_alloc_coherent()
> 
> It seems some sections of /lib/firmware/iwlwifi*.ucode files are above
> 128 Kbytes, so dma_alloc_coherent() try order-5 allocations

Thanks for looping me in, yes, this looks very familiar to me :)

In the other thread, Johannes Berg gave me this patch which is supposed to
help: http://p.sipsolutions.net/11ea33b376a5bac5.txt

Unfortunately due to very long work days, I haven't had the time to try it
out yet, but I will soon.

Would that help in this case too?

And to answer David Rientjes, I also have compaction on:
gandalfthegreat:~# zgrep CONFIG_COMPACTION /proc/config.gz 
CONFIG_COMPACTION=y

Full config:
http://marc.merlins.org/tmp/config-3.5.2-amd64-preempt-noide-20120731

If that helps for comparison, my thread is here:
http://www.spinics.net/lists/linux-wireless/msg96438.html

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
