Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 757B66B0007
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 08:41:09 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id o124so254799997oia.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 05:41:09 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id cc1si25906920oec.38.2016.01.04.05.41.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 05:41:08 -0800 (PST)
Subject: Re: __vmalloc() vs. GFP_NOIO/GFP_NOFS
References: <20160103071246.GK9938@ZenIV.linux.org.uk>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <568A7663.80407@I-love.SAKURA.ne.jp>
Date: Mon, 4 Jan 2016 22:40:51 +0900
MIME-Version: 1.0
In-Reply-To: <20160103071246.GK9938@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Ming Lei <ming.lei@canonical.com>

On 2016/01/03 16:12, Al Viro wrote:
> Those, AFAICS, are such callers with GFP_NOIO; however, there's a shitload
> of GFP_NOFS ones.  XFS uses memalloc_noio_save(), but a _lot_ of other
> callers do not.  For example, all call chains leading to ceph_kvmalloc()
> pass GFP_NOFS and none of them is under memalloc_noio_save().  The same
> goes for GFS2 __vmalloc() callers, etc.  Again, quite a few of those probably
> do not need GFP_NOFS at all, but those that do would appear to have
> hard-to-trigger deadlocks.
> 
> Why do we do that in callers, though?  I.e. why not do something like this:

This problem is not specific to vmalloc(). It is difficult for
non-fs developers to determine whether they need to use GFP_NOFS than
GFP_KERNEL in their code. Can't we annotate GFP_NOFS/GFP_NOIO sections like
http://marc.info/?l=linux-mm&m=142797559822655 ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
