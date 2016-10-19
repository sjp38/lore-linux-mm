Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 258DE6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 09:05:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x79so8290492lff.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 06:05:55 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id a10si54242155wjd.63.2016.10.19.06.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 06:05:53 -0700 (PDT)
Date: Wed, 19 Oct 2016 15:05:52 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as
	potentially sleeping
Message-ID: <20161019130552.GB5876@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de> <1476773771-11470-3-git-send-email-hch@lst.de> <20161019111541.GQ29358@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019111541.GQ29358@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Christoph Hellwig <hch@lst.de>, akpm@linux-foundation.org, joelaf@google.com, jszhang@marvell.com, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>

On Wed, Oct 19, 2016 at 12:15:41PM +0100, Chris Wilson wrote:
> On Tue, Oct 18, 2016 at 08:56:07AM +0200, Christoph Hellwig wrote:
> > This is how everyone seems to already use them, but let's make that
> > explicit.
> 
> Ah, found an exception, vmapped stacks:

Oh, fun.  So if we can't require vfree to be called from process context
we also can't use a mutex to wait for the vmap flushing.  Given that we
free stacks from the scheduler context switch I also fear there is no
good way to get a sleepable context there.

The only other idea I had was to use vmap_area_lock for the protection
that purge_lock currently provides, but that would require some serious
refactoring to avoid recursive locking first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
