Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C00506B01A7
	for <linux-mm@kvack.org>; Mon, 25 May 2015 20:09:07 -0400 (EDT)
Received: by paza2 with SMTP id a2so70057400paz.3
        for <linux-mm@kvack.org>; Mon, 25 May 2015 17:09:07 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id rd8si18169528pab.72.2015.05.25.17.09.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 17:09:06 -0700 (PDT)
Received: by pacwv17 with SMTP id wv17so79199917pac.2
        for <linux-mm@kvack.org>; Mon, 25 May 2015 17:09:06 -0700 (PDT)
Date: Tue, 26 May 2015 09:09:27 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: check compressor name before setting it
Message-ID: <20150526000927.GA566@swordfish>
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish>
 <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish>
 <555F2E7C.4090707@samsung.com>
 <20150525061838.GB555@swordfish>
 <20150525142149.GD14922@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150525142149.GD14922@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Marcin Jabrzyk <m.jabrzyk@samsung.com>, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com

Hi,

On (05/25/15 23:21), Minchan Kim wrote:
[..]
> find_backend is just utility function to get zcomp_backend.
> IOW, it might be used for several cases in future so I want
> make error report as caller's work.

[..]
> >  	if (sz > 0 && zram->compressor[sz - 1] == '\n')
> >  		zram->compressor[sz - 1] = 0x00;
> >  
> > +	if (!zcomp_known_algorithm(zram->compressor))
> 
> In here, we could report back to the user.

the motivation was that we actually change user land interface
here and it's quite possible that none of the existing scripts
handle errors returned from `echo X > /../comp_algorithm`, simply
because it has never issued any errors; not counting -BUSY, which
may be not relevant for the vast majority of the scripts:

  #!/bin/sh
  modprobe zram
  echo $1 > /sys/block/zram0/max_comp_streams
  echo $2 > /sys/block/zram0/comp_algorithm

  [..]

  echo $3 > /sys/block/zram0/disksize
  if [ $? ... ]
     ...
  fi

  mkfs.xxx /dev/zram0
  mount -o xxx /dev/zram0 /xxx


`echo $2 > /sys/block/zram0/comp_algorithm` -EINVAL return can be
ignored (and, thus, syslog message as well); because `comp_algorithm`
has never returned anything for that trivial script. so that's why I
wanted to print extra `unknown compression algorithm` message during
disksize store.


	-ss

> > +		len = -EINVAL;
> > +
> >  	up_write(&zram->init_lock);
> >  	return len;
> >  }
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
