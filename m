Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 468F16B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 10:06:20 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p20so66332820pgd.21
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 07:06:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f6si786399plj.60.2017.03.27.07.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 07:06:19 -0700 (PDT)
Date: Mon, 27 Mar 2017 07:06:10 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Remove pointless might_sleep() in remove_vm_area().
Message-ID: <20170327140610.GA27285@bombadil.infradead.org>
References: <1490352808-7187-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <59149d48-2a8e-d7c0-8009-1d0b3ea8290b@virtuozzo.com>
 <201703242140.CHJ64587.LFSFQOJOOMtFHV@I-love.SAKURA.ne.jp>
 <fe511b26-f2e5-0a0e-09cc-303d38d2ad05@virtuozzo.com>
 <20170324161732.GA23110@bombadil.infradead.org>
 <0eceef23-a20c-bca7-2153-b9b5baf1f1d8@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0eceef23-a20c-bca7-2153-b9b5baf1f1d8@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hch@lst.de, jszhang@marvell.com, joelaf@google.com, chris@chris-wilson.co.uk, joaodias@google.com, tglx@linutronix.de, hpa@zytor.com, mingo@elte.hu, Thomas Hellstrom <thellstrom@vmware.com>, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>

On Mon, Mar 27, 2017 at 04:26:02PM +0300, Andrey Ryabinin wrote:
> [+CC drm folks, see the following threads:
> 	http://lkml.kernel.org/r/201703232349.BGB95898.QHLVFFOMtFOOJS@I-love.SAKURA.ne.jp
> 	http://lkml.kernel.org/r/1490352808-7187-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> ]
> 
> On 03/24/2017 07:17 PM, Matthew Wilcox wrote:
> > On Fri, Mar 24, 2017 at 06:05:45PM +0300, Andrey Ryabinin wrote:
> >> Just fix the drm code. There is zero point in releasing memory under spinlock.
> > 
> > I disagree.  The spinlock has to be held while deleting from the hash
> > table. 
> 
> And what makes you think so?

The bad naming of the function.  If somebody has a function called
'hashtable_remove' I naturally think it means "remove something from
the hash table".  This function should be called drm_ht_destroy().
And then, yes, it becomes obvious that there is no need to protect
destuction against usage because if anyone is still using the hashtable,
they're about to get a NULL pointer dereference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
