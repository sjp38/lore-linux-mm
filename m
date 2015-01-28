Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0DEA46B006E
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 23:55:10 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so23033734pab.9
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 20:55:09 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id i1si4128679pdh.217.2015.01.27.20.55.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 20:55:09 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so23054034pac.13
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 20:55:09 -0800 (PST)
Date: Wed, 28 Jan 2015 13:55:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
Message-ID: <20150128045501.GC32712@blaptop>
References: <20150126141709.GA985@swordfish>
 <20150126160007.GC528@blaptop>
 <20150127021704.GA665@swordfish>
 <20150127031823.GA16797@blaptop>
 <20150127040305.GB665@swordfish>
 <20150128001526.GA25828@blaptop>
 <20150128002203.GB25828@blaptop>
 <20150128020759.GA343@swordfish>
 <20150128025707.GB32712@blaptop>
 <20150128035354.GA7790@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128035354.GA7790@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>

On Wed, Jan 28, 2015 at 12:53:54PM +0900, Sergey Senozhatsky wrote:
> On (01/28/15 11:57), Minchan Kim wrote:
> [..]
> > > second,
> > > after kick_all_cpus_sync() new RW operations will see false init_done().
> > > bdev->bd_holders protects from resetting device which has read/write
> > > operation ongoing on the onther CPU.
> > > 
> > > I need to refresh on how ->bd_holders actually incremented/decremented.
> > > can the following race condition take a place?
> > > 
> > > 	CPU0					CPU1
> > > reset_store()
> > > bdev->bd_holders == false
> > > 					zram_make_request
> > > 						-rm- down_read(&zram->init_lock);
> > > 					init_done(zram) == true
> > > zram_reset_device()			valid_io_request()
> > > 					__zram_make_request
> > > down_write(&zram->init_lock);		zram_bvec_rw
> > > [..]
> > > set_capacity(zram->disk, 0);
> > > zram->init_done = false;
> > > kick_all_cpus_sync();			zram_bvec_write or zram_bvec_read()
> > > zram_meta_free(zram->meta);		
> > > zcomp_destroy(zram->comp);		zcomp_compress() or zcomp_decompress()
> > 
> > You're absolutely right. I forgot rw path is blockable so
> > kick_all_cpus_sync doesn't work for our case, unfortunately.
> > So, I want to go with srcu. Do you agree? or another suggestion?
> 
> yes, I think we need to take a second look on srcu approach.
> 
> 	-ss

Another idea is to introduce atomic refcount on zram for meta's lifetime management
so that rw path should get a ref for right before using the meta and put it on done.
If the refcount is negative, anyone shouldn't go with it.

However, I guess we can do it simple and more scalable with srcu rather than
introducing new atomic count. ;-)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
