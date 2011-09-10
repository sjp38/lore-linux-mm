Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id F3EF96B0273
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 22:41:35 -0400 (EDT)
Received: by vws12 with SMTP id 12so1939028vws.31
        for <linux-mm@kvack.org>; Fri, 09 Sep 2011 19:41:33 -0700 (PDT)
Message-ID: <4E6ACE5B.9040401@vflare.org>
Date: Fri, 09 Sep 2011 22:41:31 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com> <20110909203447.GB19127@kroah.com>
In-Reply-To: <20110909203447.GB19127@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, gregkh@suse.de, devel@driverdev.osuosl.org, dan.magenheimer@oracle.com, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On 09/09/2011 04:34 PM, Greg KH wrote:

> On Wed, Sep 07, 2011 at 09:09:04AM -0500, Seth Jennings wrote:
>> Changelog:
>> v2: fix bug in find_remove_block()
>>     fix whitespace warning at EOF
>>
>> This patchset introduces a new memory allocator for persistent
>> pages for zcache.  The current allocator is xvmalloc.  xvmalloc
>> has two notable limitations:
>> * High (up to 50%) external fragmentation on allocation sets > PAGE_SIZE/2
>> * No compaction support which reduces page reclaimation
> 
> I need some acks from other zcache developers before I can accept this.
> 

First, thanks for this new allocator; xvmalloc badly needed a replacement :)

I went through xcfmalloc in detail and would be posting detailed
comments tomorrow.  In general, it seems to be quite similar to the
"chunk based" allocator used in initial implementation of "compcache" --
please see section 2.3.1 in this paper:
http://www.linuxsymposium.org/archives/OLS/Reprints-2007/briglia-Reprint.pdf

I'm really looking forward to a slab based allocator as I mentioned in
the initial mail:
http://permalink.gmane.org/gmane.linux.kernel.mm/65467

With the current design xcfmalloc suffers from issues similar to the
allocator described in the paper:
 - High metadata overhead
 - Difficult implementation of compaction
 - Need for extra memcpy()s  etc.

With slab based approach, we can almost eliminate any metadata overhead,
remove any free chunk merging logic, simplify compaction and so on.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
