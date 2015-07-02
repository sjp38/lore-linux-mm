Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id D53BB6B025B
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 22:37:09 -0400 (EDT)
Received: by qgat90 with SMTP id t90so8561842qga.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:37:09 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id 139si4714949qhx.121.2015.07.01.19.37.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 19:37:09 -0700 (PDT)
Received: by qkhu186 with SMTP id u186so43272384qkh.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:37:08 -0700 (PDT)
Date: Wed, 1 Jul 2015 22:37:06 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 41/51] writeback: make wakeup_flusher_threads() handle
 multiple bdi_writeback's
Message-ID: <20150702023706.GK26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-42-git-send-email-tj@kernel.org>
 <20150701081528.GB7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701081528.GB7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello,

On Wed, Jul 01, 2015 at 10:15:28AM +0200, Jan Kara wrote:
> I was looking at who uses wakeup_flusher_threads(). There are two usecases:
> 
> 1) sync() - we want to writeback everything
> 2) We want to relieve memory pressure by cleaning and subsequently
>    reclaiming pages.
> 
> Neither of these cares about number of pages too much if you write enough.

What's enough tho?  Saying "yeah let's try about 1000 pages" is one
thing and "let's try about 1000 pages on each of 100 cgroups" is a
quite different operation.  Given the nature of "let's try to write
some", I'd venture to say that writing somewhat less is an a lot
better behavior than possibly trying to write out possibly huge amount
given that the amount of fluctuation such behaviors may cause
system-wide and how non-obvious the reasons for such fluctuations
would be.

> So similarly as we don't split the passed nr_pages argument among bdis, I

bdi's are bound by actual hardware.  wb's aren't.  This is a purely
logical construct and there can be a lot of them.  Again, trying to
write 1024 pages on each of 100 devices and trying to write 1024 * 100
pages to single device are quite different.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
