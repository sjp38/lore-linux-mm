Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98DAD6B0253
	for <linux-mm@kvack.org>; Mon, 16 May 2016 08:44:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so42504445wme.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 05:44:56 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id v7si38482684wjg.17.2016.05.16.05.44.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 05:44:55 -0700 (PDT)
Subject: Re: UBIFS and page migration (take 3)
References: <1462974823-3168-1-git-send-email-richard@nod.at>
 <20160512114948.GA25113@infradead.org>
From: Richard Weinberger <richard@nod.at>
Message-ID: <5739C0C1.1090907@nod.at>
Date: Mon, 16 May 2016 14:44:49 +0200
MIME-Version: 1.0
In-Reply-To: <20160512114948.GA25113@infradead.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hughd@google.com, mgorman@techsingularity.net, vbabka@suse.cz

Christoph,

Am 12.05.2016 um 13:49 schrieb Christoph Hellwig:
> Hi Richard,
> 
> the series looks fine to me, but it fails to address the root cause:

Is this a Reviewed-by? :-)

> that we have an inherently dangerous default for ->migratepage that
> assumes that file systems are implemented a certain way.  I think the
> series should also grow a third patch to remove the default and just
> wire it up for the known good file systems, although we'd need some
> input on what known good is.
>
> Any idea what filesystems do get regular testing with code that's using
> CMA? A good approximation might be those that use the bufer_head
> based aops from fs/buffer.c

No idea how much is being tested.
I fear most issues are unknown. At least for UBIFS it took
years to get aware of the issue.
Thanks again to Maxime and Boris for providing a reproducer.

There are two classes of issues:
a) filesystems that use buffer_migrate_page() but shouldn't
b) filesystems that don't implement ->migratepage() and fallback_migrate_page()
   is not suitable.

As starter we could kill the automatic assignment of fallback_migrate_page() and
non-buffer_head filesystems need to figure out whether fallback_migrate_page()
is suitable or not.
UBIFS found out the hard way. ;-\

MM folks, do we have a way to force page migration?
Maybe we can create a generic stress test.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
