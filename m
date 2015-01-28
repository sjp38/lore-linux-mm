Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id AF9546B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 22:53:56 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so22797420pad.1
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 19:53:56 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id bu5si3956587pad.230.2015.01.27.19.53.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 19:53:55 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id g10so23022970pdj.0
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 19:53:55 -0800 (PST)
Date: Wed, 28 Jan 2015 12:53:54 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
Message-ID: <20150128035354.GA7790@swordfish>
References: <20150126013309.GA26895@blaptop>
 <20150126141709.GA985@swordfish>
 <20150126160007.GC528@blaptop>
 <20150127021704.GA665@swordfish>
 <20150127031823.GA16797@blaptop>
 <20150127040305.GB665@swordfish>
 <20150128001526.GA25828@blaptop>
 <20150128002203.GB25828@blaptop>
 <20150128020759.GA343@swordfish>
 <20150128025707.GB32712@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128025707.GB32712@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>

On (01/28/15 11:57), Minchan Kim wrote:
[..]
> > second,
> > after kick_all_cpus_sync() new RW operations will see false init_done().
> > bdev->bd_holders protects from resetting device which has read/write
> > operation ongoing on the onther CPU.
> > 
> > I need to refresh on how ->bd_holders actually incremented/decremented.
> > can the following race condition take a place?
> > 
> > 	CPU0					CPU1
> > reset_store()
> > bdev->bd_holders == false
> > 					zram_make_request
> > 						-rm- down_read(&zram->init_lock);
> > 					init_done(zram) == true
> > zram_reset_device()			valid_io_request()
> > 					__zram_make_request
> > down_write(&zram->init_lock);		zram_bvec_rw
> > [..]
> > set_capacity(zram->disk, 0);
> > zram->init_done = false;
> > kick_all_cpus_sync();			zram_bvec_write or zram_bvec_read()
> > zram_meta_free(zram->meta);		
> > zcomp_destroy(zram->comp);		zcomp_compress() or zcomp_decompress()
> 
> You're absolutely right. I forgot rw path is blockable so
> kick_all_cpus_sync doesn't work for our case, unfortunately.
> So, I want to go with srcu. Do you agree? or another suggestion?

yes, I think we need to take a second look on srcu approach.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
