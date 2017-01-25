Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7EA6B0069
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 23:25:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so261487960pfb.7
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 20:25:17 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id i88si22083832pfk.178.2017.01.24.20.25.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 20:25:16 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id e4so13399693pfg.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 20:25:16 -0800 (PST)
Date: Wed, 25 Jan 2017 13:25:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-ID: <20170125042530.GD2234@jagdpanzerIV.localdomain>
References: <CGME20170119001317epcas1p188357c77e1f4ff08b6d3dcb76dedca06@epcas1p1.samsung.com>
 <afd38699-f1c4-f63f-7362-29c514e9ffb4@samsung.com>
 <20170119024421.GA9367@bbox>
 <0a184bbf-0612-5f71-df68-c37500fa1eda@samsung.com>
 <20170119062158.GB9367@bbox>
 <e0e1fcae-d2c4-9068-afa0-b838d57d8dff@samsung.com>
 <20170123052244.GC11763@bbox>
 <20170123053056.GB2327@jagdpanzerIV.localdomain>
 <20170123054034.GA12327@bbox>
 <7488422b-98d1-1198-70d5-47c1e2bac721@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7488422b-98d1-1198-70d5-47c1e2bac721@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/24/17 23:06), Chulmin Kim wrote:
[..]
> > > > Yeb, Thanks.
> > > > 
> > > > Perhaps, did you tried flush page before the writing?
> > > > I think arm64 have no d-cache alising problem but worth to try it.
> > > > Who knows :)
> > > 
> > > I thought that flush_dcache_page() is only for cases when we write
> > > to page (store that makes pages dirty), isn't it?
> > 
> > I think we need both because to see recent stores done by the user.
> > I'm not sure it should be done by block device driver rather than
> > page cache. Anyway, brd added it so worth to try it, I thought. :)

Cc Dan, Seth

(https://marc.info/?l=linux-mm&m=148514896820940)


> Thanks for the suggestion!
> It might be helpful
> though proving it is not easy as the problem appears rarely.
> 
> Have you thought about
> zram swap or zswap dealing with self modifying code pages (ex. JIT)?
> (arm64 may have i-cache aliasing problem)
> 
> If it is problematic,
> especiallly zswap (without flush_dcache_page in zswap_frontswap_load()) may
> provide the corrupted data
> and even swap out (compressing) may see the corrupted data sooner or later,
> i guess.

hm, interesting. there is a report of zswap_frontswap_load() failing to
decompress the page: https://marc.info/?l=linux-mm&m=148468457306971

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
