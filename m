Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id BA2F06B005D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 10:53:21 -0500 (EST)
Date: Thu, 22 Nov 2012 23:53:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Problem in Page Cache Replacement
Message-ID: <20121122155318.GA12636@localhost>
References: <20121120182500.GH1408@quack.suse.cz>
 <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com>
 <1353485630.17455.YahooMailNeo@web141106.mail.bf1.yahoo.com>
 <50AC9220.70202@gmail.com>
 <20121121090204.GA9064@localhost>
 <50ACA209.9000101@gmail.com>
 <1353491880.11679.YahooMailNeo@web141102.mail.bf1.yahoo.com>
 <50ACA634.5000007@gmail.com>
 <CAJOrxZBpefqtkXr+XTxEZ6qy-6SCwQJ11makD=Lg_M4itY5Ang@mail.gmail.com>
 <20121122154107.GB11736@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20121122154107.GB11736@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Metin =?utf-8?B?RMO2xZ9sw7w=?= <metindoslu@gmail.com>
Cc: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Nov 22, 2012 at 11:41:07PM +0800, Fengguang Wu wrote:
> On Wed, Nov 21, 2012 at 12:07:22PM +0200, Metin DA?A?lA 1/4  wrote:
> > On Wed, Nov 21, 2012 at 12:00 PM, Jaegeuk Hanse <jaegeuk.hanse@gmail.com> wrote:
> > >
> > > On 11/21/2012 05:58 PM, metin d wrote:
> > >
> > > Hi Fengguang,
> > >
> > > I run tests and attached the results. The line below I guess shows the data-1 page caches.
> > >
> > > 0x000000080000006c       6584051    25718  __RU_lA___________________P________    referenced,uptodate,lru,active,private
> > >
> > >
> > > I thinks this is just one state of page cache pages.
> > 
> > But why these page caches are in this state as opposed to other page
> > caches. From the results I conclude that:
> > 
> > data-1 pages are in state : referenced,uptodate,lru,active,private
> 
> I wonder if it's this code that stops data-1 pages from being
> reclaimed:
> 
> shrink_page_list():
> 
>                 if (page_has_private(page)) {
>                         if (!try_to_release_page(page, sc->gfp_mask))
>                                 goto activate_locked;
> 
> What's the filesystem used?

Ah it's more likely caused by this logic:

        if (is_active_lru(lru)) {
                if (inactive_list_is_low(mz, file))
                        shrink_active_list(nr_to_scan, mz, sc, priority, file);

The active file list won't be scanned at all if it's smaller than the
active list. In this case, it's inactive=33586MB > active=25719MB. So
the data-1 pages in the active list will never be scanned and reclaimed.

> > data-2 pages are in state : referenced,uptodate,lru,mappedtodisk
> 
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
