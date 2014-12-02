Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 35E566B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 23:50:02 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so12637355pab.28
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 20:50:01 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id qg3si5581209pbb.8.2014.12.01.20.49.59
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 20:50:00 -0800 (PST)
Date: Tue, 2 Dec 2014 13:53:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141202045324.GC6268@js1304-P5Q-DELUXE>
References: <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
 <20141119212013.GA18318@cucumber.anchor.net.au>
 <546D2366.1050506@suse.cz>
 <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
 <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Tue, Dec 02, 2014 at 12:47:24PM +1100, Christian Marie wrote:
> On 28.11.2014 9:03, Joonsoo Kim wrote:
> > Hello,
> >
> > I didn't follow-up this discussion, but, at glance, this excessive CPU
> > usage by compaction is related to following fixes.
> >
> > Could you test following two patches?
> >
> > If these fixes your problem, I will resumit patches with proper commit
> > description.
> >
> > -------- 8< ---------
> 
> 
> Thanks for looking into this. Running 3.18-rc5 kernel with your patches has
> produced some interesting results.
> 
> Load average still spikes to around 2000-3000 with the processors spinning 100%
> doing compaction related things when min_free_kbytes is left at the default.
> 
> However, unlike before, the system is now completely stable. Pre-patch it would
> be almost completely unresponsive (having to wait 30 seconds to establish an
> SSH connection and several seconds to send a character).
> 
> Is it reasonable to guess that ipoib is giving compaction a hard time and
> fixing this bug has allowed the system to at least not lock up?
> 
> I will try back-porting this to 3.10 and seeing if it is stable under these
> strange conditions also.

Hello,

Good to hear!
Load average spike may be related to skip bit management. Currently, there is
no way to maintain skip bit permanently. So, after one iteration of compaction
is finished and skip bit is reset, all pageblocks should be re-scanned.

Your system has mellanox driver and although I don't know exactly what it is,
I heard that it allocates enormous pages and do get_user_pages() to
pin pages in memory. These memory aren't available to compaction, but,
compaction always scan it.

This is just my assumption, so if possible, please check it with
compaction tracepoint. If it is, we can make a solution for this
problem.

Anyway, could you test one more time without second patch?
IMO, first patch is reasonable to backport, because it fixes a real bug.
But, I'm not sure if second patch is needed to backport or not.
One more testing will help us to understand the effect of patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
