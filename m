Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 542C96B0034
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 06:03:34 -0500 (EST)
Date: Tue, 29 Jan 2013 12:02:28 +0100
From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-ID: <20130129110228.GA20242@lunn.ch>
References: <50F800EB.6040104@web.de>
 <201301172026.45514.arnd@arndb.de>
 <50FABBED.1020905@web.de>
 <20130119185907.GA20719@lunn.ch>
 <5100022D.9050106@web.de>
 <20130123162515.GK13482@lunn.ch>
 <510018B4.9040903@web.de>
 <51001BEE.9020201@web.de>
 <20130123181029.GE20719@lunn.ch>
 <5106E6A6.7010207@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5106E6A6.7010207@web.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, Jason Cooper <jason@lakedaemon.net>, Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

> Now I activated the debug messages in em28xx. From the messages I
> see no correlation of the pool exhaustion and lost sync. Also I
> cannot see any error messages from the em28xx driver.
> I see a lot of init_isoc/stop_urbs (maybe EPG scan?) without
> draining the coherent pool (checked with 'cat
> /debug/dma-api/num_free_entries', which gave stable numbers), but
> after half an hour there are only init_isoc messages without
> corresponding stop_urbs messages and num_free_entries decreased
> until coherent pool exhaustion.

Hi Soeren

em28xx_stop_urbs() is only called by em28xx_stop_streaming().

em28xx_stop_streaming() is only called by em28xx_stop_feed()
when 0 == dvb->nfeeds.

em28xx_stop_feed()and em28xx_start_feed() look O.K, dvb->nfeeds is
protected by a mutex etc.

Now, em28xx_init_isoc() is also called by buffer_prepare(). This uses
em28xx_alloc_isoc() to do the actual allocation, and that function
sets up the urb such that on completion the function
em28xx_irq_callback() is called.

It looks like there might be issues here:

Once the data has been copied out, it resubmits the urb:

       urb->status = usb_submit_urb(urb, GFP_ATOMIC);
        if (urb->status) {
                em28xx_isocdbg("urb resubmit failed (error=%i)\n",
                               urb->status);
        }
  
However, if the ubs_submit_urb fails, it looks like the urb is lost.

If you look at other code submitting urbs you have this pattern:

               rc = usb_submit_urb(isoc_bufs->urb[i], GFP_ATOMIC);
                if (rc) {
                        em28xx_err("submit of urb %i failed (error=%i)\n", i,
                                   rc);
                        em28xx_uninit_isoc(dev, mode);
                        return rc;
                }
 
Do you have your build such that you would see "urb resubmit failed"
in your logs? Are there any?

     Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
