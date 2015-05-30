Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AB6196B0070
	for <linux-mm@kvack.org>; Sat, 30 May 2015 00:16:17 -0400 (EDT)
Received: by padj3 with SMTP id j3so6114692pad.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 21:16:17 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id iv3si11261547pbb.202.2015.05.29.21.16.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 21:16:16 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so67344924pdb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 21:16:16 -0700 (PDT)
Date: Sat, 30 May 2015 13:16:38 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: clear disk io accounting when reset zram device
Message-ID: <20150530041638.GA525@swordfish>
References: <"000001d099be$fae6cc90$f0b465b0$@yang"@samsung.com>
 <20150529034141.GA1157@swordfish>
 <20150529145418.GG11609@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150529145418.GG11609@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Weijie Yang <weijie.yang@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, ngupta@vflare.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (05/29/15 23:54), Minchan Kim wrote:
> I think the problem is caused from weired feature "reset" of zram.

agree.

> Until a while ago, we didn't have hot_add/del feature so we should
> use custom reset function but now we have hot/add feature.
> So reset is logically same feature(ie, reset = hot_remove+hot_add
> but remains same device id).
> 

hm, sounds interesting, but I think it will end up being tricky.

zram_remove() will be called from device's sysfs node (now we call it from
zram_control sysfs class node, makes a huge difference). sysfs locks the node
until node's read/write handler returns back, so zram_remove() will be called
with lock(s_active#XXX) being locked (we had a lockdep splat with these locks
recently), while zram_remove()->sysfs_remove_group() will once again attempt
to lock this node (the very same lock(s_active#XXX)). in other words, we cannot
fully remove zram device from its sysfs attr. and I don't want to add any bool
flags to zram_remove() and zram_add() indicating that this is a "partial" device
remove: don't delete device's sysfs group in remove() and don't create it in add().


doing reset from zram_control is easy, for sure:
	lock idr mutex,
	do zram_remove() and zram_add()
	unlock idr lock.

`echo ID > /sys/.../zram_control/reset`

no need to modify remove()/add() -- idr will pick up just released idx,
so device_id will be preserved. but it'll be hard to drop the per-device
`reset` attr and to make it a zram_control attr. things would have been
much simpler if all of zram users were also zramctl users. zramctl, from
this point of view, lets us change zram interfaces easily -- we merely need
to teach/modify zramctl, the rest is transparent.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
