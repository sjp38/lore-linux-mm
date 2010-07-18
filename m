Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6DD33600365
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 04:12:24 -0400 (EDT)
Received: by pvc30 with SMTP id 30so1597331pvc.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 01:12:23 -0700 (PDT)
Message-ID: <4C42B782.7060106@vflare.org>
Date: Sun, 18 Jul 2010 13:42:50 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] zcache: page cache compression support
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org> <4C42B228.9040401@cs.helsinki.fi>
In-Reply-To: <4C42B228.9040401@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 07/18/2010 01:20 PM, Pekka Enberg wrote:
> Nitin Gupta wrote:
>> Frequently accessed filesystem data is stored in memory to reduce access to
>> (much) slower backing disks. Under memory pressure, these pages are freed and
>> when needed again, they have to be read from disks again. When combined working
>> set of all running application exceeds amount of physical RAM, we get extereme
>> slowdown as reading a page from disk can take time in order of milliseconds.
>>
>> Memory compression increases effective memory size and allows more pages to
>> stay in RAM. Since de/compressing memory pages is several orders of magnitude
>> faster than disk I/O, this can provide signifant performance gains for many
>> workloads. Also, with multi-cores becoming common, benefits of reduced disk I/O
>> should easily outweigh the problem of increased CPU usage.
>>
>> It is implemented as a "backend" for cleancache_ops [1] which provides
>> callbacks for events such as when a page is to be removed from the page cache
>> and when it is required again. We use them to implement a 'second chance' cache
>> for these evicted page cache pages by compressing and storing them in memory
>> itself.
>>
<snip>

> 
> So why would someone want to use zram if they have transparent page cache compression with zcache? That is, why is this not a replacement for zram?
> 

zcache complements zram; it's not a replacement:

 - zram compresses anonymous pages while zcache is for page cache compression.
So, workload which depends heavily on "heap memory" usage will tend to prefer
zram and those which are I/O intensive will prefer zcache. Though I have not
yet experimented much, most workloads may want to have a mix of them.

 - zram is not just for swap. /dev/zram<id> are generic in-memory compressed
block devices which can be used for, say, /tmp, /var/... etc. temporary storage.

 - /dev/zram<id> being a generic block devices, can be used as raw disk in other
OSes also (using virtualization): For example:
http://www.vflare.org/2010/05/compressed-ram-disk-for-windows-virtual.html

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
