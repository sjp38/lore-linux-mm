Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 47FC36B005D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 07:37:53 -0400 (EDT)
Date: Wed, 3 Oct 2012 13:37:00 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: iwl3945: order 5 allocation during ifconfig up; vm problem?
Message-ID: <20121003113659.GD2259@redhat.com>
References: <20120909213228.GA5538@elf.ucw.cz>
 <alpine.DEB.2.00.1209091539530.16930@chino.kir.corp.google.com>
 <20120910111113.GA25159@elf.ucw.cz>
 <20120911162536.bd5171a1.akpm@linux-foundation.org>
 <20120912101826.GL11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912101826.GL11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Machek <pavel@ucw.cz>, David Rientjes <rientjes@google.com>, linux-wireless@vger.kernel.org, johannes.berg@intel.com, wey-yi.w.guy@intel.com, ilw@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 12, 2012 at 11:18:26AM +0100, Mel Gorman wrote:
> On Tue, Sep 11, 2012 at 04:25:36PM -0700, Andrew Morton wrote:
> > On Mon, 10 Sep 2012 13:11:13 +0200
> > Pavel Machek <pavel@ucw.cz> wrote:
> > 
> > > On Sun 2012-09-09 15:40:55, David Rientjes wrote:
> > > > On Sun, 9 Sep 2012, Pavel Machek wrote:
> > > > 
> > > > > On 3.6.0-rc2+, I tried to turn on the wireless, but got
> > > > > 
> > > > > root@amd:~# ifconfig wlan0 10.0.0.6 up
> > > > > SIOCSIFFLAGS: Cannot allocate memory
> > > > > SIOCSIFFLAGS: Cannot allocate memory
> > > > > root@amd:~# 
> > > > > 
> > > > > It looks like it uses "a bit too big" allocations to allocate
> > > > > firmware...? Order five allocation....
> > > > > 
> > > > > Hmm... then I did "echo 3  > /proc/sys/vm/drop_caches" and now the
> > > > > network works. Is it VM problem that it failed to allocate memory when
> > > > > it was freeable?
> > > > > 
> > > > 
> > > > Do you have CONFIG_COMPACTION enabled?
> > > 
> > > Yes:
> > > 
> > > pavel@amd:/data/l/linux-good$ zgrep CONFIG_COMPACTION /proc/config.gz 
> > > CONFIG_COMPACTION=y
> > 
> > Asking for a 256k allocation is pretty crazy - this is an operating
> > system kernel, not a userspace application.
> > 
> > I'm wondering if this is due to a recent change, but I'm having trouble
> > working out where the allocation call site is.
> 
> It may be indirectly due to a recent change and this was somewhat
> deliberate. Order-5 is larger than PAGE_ALLOC_COSTLY_ORDER and I doubt
> __GFP_REPEAT was set so it is treated as something that can fail in
> preference to aggressively reclaiming pages to satisfy the allocation. In
> older kernels with lumpy reclaim and an aggressive kswapd it would have
> probably succeeded but now it errs on the side of failing early instead
> assuming that the caller can recover. Drivers that depend on order-5
> allocations to succeed for correct operation are somewhat frowned upon.

So, can this problem be solved like on below patch, or I should rather
split firmware loading into chunks similar like was already iwlwifi did?

diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/iwlegacy/common.h
index 5f50177..1b58222 100644
--- a/drivers/net/wireless/iwlegacy/common.h
+++ b/drivers/net/wireless/iwlegacy/common.h
@@ -2247,7 +2247,7 @@ il_alloc_fw_desc(struct pci_dev *pci_dev, struct fw_desc *desc)
 
 	desc->v_addr =
 	    dma_alloc_coherent(&pci_dev->dev, desc->len, &desc->p_addr,
-			       GFP_KERNEL);
+			       GFP_KERNEL | __GFP_REPEAT);
 	return (desc->v_addr != NULL) ? 0 : -ENOMEM;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
