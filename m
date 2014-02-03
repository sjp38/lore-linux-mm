Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 76B9F6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 15:22:38 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k4so11051371qaq.1
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 12:22:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 8si15613732qav.66.2014.02.03.12.22.37
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 12:22:38 -0800 (PST)
Date: Mon, 3 Feb 2014 15:22:01 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] block devices: validate block device capacity
In-Reply-To: <20140203081506.GA10961@infradead.org>
Message-ID: <alpine.LRH.2.02.1402031513070.18926@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1401301531040.29912@file01.intranet.prod.int.rdu2.redhat.com> <1391122163.2181.103.camel@dabdike.int.hansenpartnership.com> <alpine.LRH.2.02.1401301805590.19506@file01.intranet.prod.int.rdu2.redhat.com>
 <1391125027.2181.114.camel@dabdike.int.hansenpartnership.com> <alpine.LRH.2.02.1401301905520.25766@file01.intranet.prod.int.rdu2.redhat.com> <1391132609.2181.131.camel@dabdike.int.hansenpartnership.com> <alpine.LRH.2.02.1401302116180.9767@file01.intranet.prod.int.rdu2.redhat.com>
 <1391147127.2181.159.camel@dabdike.int.hansenpartnership.com> <alpine.LRH.2.02.1401310316560.21451@file01.intranet.prod.int.rdu2.redhat.com> <20140203081506.GA10961@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Jens Axboe <axboe@kernel.dk>, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, dm-devel@redhat.com, "David S. Miller" <davem@davemloft.net>, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>, linux-raid@vger.kernel.org, linux-mm@kvack.org



On Mon, 3 Feb 2014, Christoph Hellwig wrote:

> On Fri, Jan 31, 2014 at 03:20:17AM -0500, Mikulas Patocka wrote:
> > So if you think you can support 16TiB devices and leave pgoff_t 32-bit, 
> > send a patch that does it.
> > 
> > Until you make it, you should apply the patch that I sent, that prevents 
> > kernel lockups or data corruption when the user uses 16TiB device on 
> > 32-bit kernel.
> 
> Exactly.  I had actually looked into support for > 16TiB devices for
> a NAS use case a while ago, but when explaining the effort involves
> the idea was dropped quickly.  The Linux block device is too deeply
> tied to the pagecache to make it easily feasible.

The memory management routines use pgoff_t, so we could define pgoff_t to 
be 64-bit type. But there is lib/radix_tree.c that uses unsigned long as 
an index into the radix tree - and pgoff_t is cast to unsigned long when 
calling the radix_tree routines - so we'd need to change lib/radix_tree to 
use pgoff_t.

Then, there may be other places where pgoff_t is cast to unsigned long and 
they are not trivial to find (one could enable some extra compiler 
warnings about truncating values when casting them, but I suppose, this 
would trigger a lot of false positives). This needs some deep review by 
people who designed the memory management code.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
