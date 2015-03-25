Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id B0E536B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 01:29:13 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so17015375pdn.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 22:29:13 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id e6si1935883pdo.202.2015.03.24.22.29.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 22:29:13 -0700 (PDT)
Received: by pdnc3 with SMTP id c3so17015108pdn.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 22:29:12 -0700 (PDT)
Date: Wed, 25 Mar 2015 14:29:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/2] zsmalloc: do not remap dst page while prepare next
 src page
Message-ID: <20150325052922.GA1675@swordfish>
References: <1427210687-6634-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1427210687-6634-2-git-send-email-sergey.senozhatsky@gmail.com>
 <5512421D.4000603@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5512421D.4000603@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, sunae.seo@samsung.com, cmlaika.kim@samsung.com

On (03/25/15 14:05), Heesub Shin wrote:
> No, it's not unnecessary. We should do kunmap_atomic() in the reverse
> order of kmap_atomic(), so unfortunately it's inevitable to
> kunmap_atomic() both on d_addr and s_addr.
> 

Andrew, can you please drop this patch?


> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > ---
> >  mm/zsmalloc.c | 2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index d920e8b..7af4456 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1536,12 +1536,10 @@ static void zs_object_copy(unsigned long src, unsigned long dst,
> >  			break;
> >  
> >  		if (s_off + size >= PAGE_SIZE) {
> > -			kunmap_atomic(d_addr);
> >  			kunmap_atomic(s_addr);
> 
> Removing kunmap_atomic(d_addr) here may cause BUG_ON() at __kunmap_atomic().
> 
> I tried yours to see it really happens:
> > kernel BUG at arch/arm/mm/highmem.c:113!

oh, arm. tested on x86_64 only. I see why it happens there. thanks for reporting.


sorry, should have checked.

> > Internal error: Oops - BUG: 0 [#1] SMP ARM
> > Modules linked in:
> > CPU: 2 PID: 1774 Comm: bash Not tainted 4.0.0-rc2-mm1+ #105
> > Hardware name: ARM-Versatile Express
> > task: ee971300 ti: e8a26000 task.ti: e8a26000
> > PC is at __kunmap_atomic+0x144/0x14c
> > LR is at zs_object_copy+0x19c/0x2dc

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
