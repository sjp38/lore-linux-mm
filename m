Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D4A1D6B0131
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 18:55:47 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so878781pab.18
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 15:55:47 -0700 (PDT)
Date: Wed, 2 Apr 2014 15:55:37 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 3/6] aio/dio: enable PI passthrough
Message-ID: <20140402225537.GE10230@birch.djwong.org>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140324162251.10848.56452.stgit@birch.djwong.org>
 <20140402200133.GK2394@lenny.home.zabbo.net>
 <20140402204420.GB10230@birch.djwong.org>
 <20140402223311.GN2394@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402223311.GN2394@lenny.home.zabbo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 02, 2014 at 03:33:11PM -0700, Zach Brown wrote:
> > One thing I'm not sure about: What's the largest IO (in terms of # of blocks,
> > not # of struct iovecs) that I can throw at the kernel?
> 
> Yeah, dunno.  I'd guess big :).  I'd hope that the PI code already has a
> way to clamp the size of bios if there's a limit to the size of PI data
> that can be managed downstream?

I guess if we restricted the size of the PI buffer to a page's worth of
pointers to struct page, that limits us to 128M on x64 with DIF and 512b
sectors.  That's not really a whole lot; I suppose one could (ab)use vmalloc.

Yes, blk-integrity clamps the size of the bio to fit the downstream device's
maximum integrity sg size.  See max_integrity_segments for details, or the
mostly-undocumented sg_prot_tablesize sysfs attribute that reveals it.

I don't know what a practical limit is; scsi_debug sets it to 65536.

--D
> 
> - z
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
