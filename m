Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4E85C6B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 23:50:31 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so23295809pdb.6
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 20:50:31 -0800 (PST)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id r17si4213063pdi.141.2015.01.27.20.50.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 20:50:30 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id y10so23278183pdj.7
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 20:50:30 -0800 (PST)
Date: Wed, 28 Jan 2015 13:50:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
Message-ID: <20150128045028.GB577@swordfish>
References: <20150126160007.GC528@blaptop>
 <20150127021704.GA665@swordfish>
 <20150127031823.GA16797@blaptop>
 <20150127040305.GB665@swordfish>
 <20150128001526.GA25828@blaptop>
 <20150128002203.GB25828@blaptop>
 <20150128020759.GA343@swordfish>
 <20150128025707.GB32712@blaptop>
 <20150128035354.GA7790@swordfish>
 <20150128040757.GA577@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128040757.GA577@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>

On (01/28/15 13:07), Sergey Senozhatsky wrote:
> On (01/28/15 12:53), Sergey Senozhatsky wrote:
> > > So, I want to go with srcu. Do you agree? or another suggestion?
> > 
> > yes, I think we need to take a second look on srcu approach.
> > 
> 
> ... or we can ask lockdep to stop false alarming us and leave it as is.
> I wouldn't say that ->init_lock is so hard to understand.
> just as an option.
> 

so... returning back to barriers performance implications.

x86_64, lzo, 4 comp streams, 2G zram, ext4, mount -o rw,relatime,data=ordered

 ./iozone -t 3 -R -r 16K -s 60M -I +Z

       test           base          srcu
"  Initial write " 1299639.75   1277621.03
"        Rewrite " 2139387.50   2004663.94
"           Read " 6193415.00   5091000.00
"        Re-read " 6199050.38   4814297.88
"   Reverse Read " 4693868.88   4367201.75
"    Stride read " 4470633.75   4247550.00
"    Random read " 5115339.50   4517352.75
" Mixed workload " 4340747.06   3880517.31
"   Random write " 1982369.75   1892456.25
"         Pwrite " 1352550.22   1248667.78
"          Pread " 2853150.06   2445154.41
"         Fwrite " 2367397.81   2262384.56
"          Fread " 8100746.50   7578071.75

not good.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
