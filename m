Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 672D26B02A4
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 09:50:36 -0400 (EDT)
Received: by pwi8 with SMTP id 8so2540503pwi.14
        for <linux-mm@kvack.org>; Tue, 20 Jul 2010 06:50:34 -0700 (PDT)
Message-ID: <4C45A9BA.1090903@vflare.org>
Date: Tue, 20 Jul 2010 19:20:50 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] zcache: page cache compression support
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org> <4f986c65-c17e-47d8-9c30-60cd17809cbb@default>
In-Reply-To: <4f986c65-c17e-47d8-9c30-60cd17809cbb@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 07/20/2010 01:27 AM, Dan Magenheimer wrote:
>> We only keep pages that compress to PAGE_SIZE/2 or less. Compressed
>> chunks are
>> stored using xvmalloc memory allocator which is already being used by
>> zram
>> driver for the same purpose. Zero-filled pages are checked and no
>> memory is
>> allocated for them.
> 
> I'm curious about this policy choice.  I can see why one
> would want to ensure that the average page is compressed
> to less than PAGE_SIZE/2, and preferably PAGE_SIZE/2
> minus the overhead of the data structures necessary to
> track the page.  And I see that this makes no difference
> when the reclamation algorithm is random (as it is for
> now).  But once there is some better reclamation logic,
> I'd hope that this compression factor restriction would
> be lifted and replaced with something much higher.  IIRC,
> compression is much more expensive than decompression
> so there's no CPU-overhead argument here either,
> correct?
> 
>

Its true that we waste CPU cycles for every incompressible page
encountered but still we can't keep such pages in RAM since this
is what host wanted to reclaim and we can't help since compression
failed. Compressed caching makes sense only when we keep highly
compressible pages in RAM, regardless of reclaim scheme.

Keeping (nearly) incompressible pages in RAM probably makes sense
for Xen's case where cleancache provider runs *inside* a VM, sending
pages to host. So, if VM is limited to say 512M and host has 64G RAM,
caching guest pages, with or without compression, will help.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
