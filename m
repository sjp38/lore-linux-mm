Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 84EC56B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 04:24:16 -0400 (EDT)
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
References: <4A4D26C5.9070606@redhat.com>
From: Olaf Weber <olaf@sgi.com>
Date: Tue, 07 Jul 2009 11:07:30 +0200
In-Reply-To: <4A4D26C5.9070606@redhat.com> (Eric Sandeen's message of "Thu, 02 Jul 2009 16:29:41 -0500")
Message-ID: <bzyd48cc14d.fsf@fransum.emea.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Eric Sandeen <sandeen@redhat.com>
Cc: xfs mailing list <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "MASON, CHRISTOPHER" <CHRIS.MASON@oracle.com>
List-ID: <linux-mm.kvack.org>

Eric Sandeen writes:

> Talking w/ someone who had a raid6 of 15 drives on an areca
> controller, he wondered why he could only get 300MB/s or so
> out of a streaming buffered write to xfs like so:

> dd if=/dev/zero of=/mnt/storage/10gbfile bs=128k count=81920
> 10737418240 bytes (11 GB) copied, 34.294 s, 313 MB/s

> when the same write directly to the device was going closer
> to 700MB/s...

> With the following change things get moving again for xfs:

> dd if=/dev/zero of=/mnt/storage/10gbfile bs=128k count=81920
> 10737418240 bytes (11 GB) copied, 16.2938 s, 659 MB/s

> Chris had sent out something similar at Christoph's suggestion,
> and Christoph reminded me of it, and I tested it a variant of
> it, and it seems to help shockingly well.

> Feels like a bandaid though; thoughts?  Other tests to do?

If the nr_to_write calculation really yields a value that is too
small, shouldn't it be fixed elsewhere?

Otherwise it might make sense to make the fudge factor tunable.

> +
> +	/*
> +	 *  VM calculation for nr_to_write seems off.  Bump it way
> +	 *  up, this gets simple streaming writes zippy again.
> +	 */
> +	wbc->nr_to_write *= 4;
> +

-- 
Olaf Weber                 SGI               Phone:  +31(0)30-6696752
                           Veldzigt 2b       Fax:    +31(0)30-6696799
Technical Lead             3454 PW de Meern  Vnet:   955-7151
Storage Software           The Netherlands   Email:  olaf@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
