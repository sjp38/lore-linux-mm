Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE7C6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 03:54:28 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so89499460wic.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 00:54:27 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id o3si9110390wix.62.2015.08.12.00.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 00:54:26 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so89498233wic.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 00:54:25 -0700 (PDT)
Message-ID: <55CAFBAF.104@plexistor.com>
Date: Wed, 12 Aug 2015 10:54:23 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH, RFC 2/2] dax: use range_lock instead of i_mmap_lock
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com> <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com> <20150811081909.GD2650@quack.suse.cz> <20150811093708.GB906@dastard> <20150811135004.GC2659@quack.suse.cz> <55CA0728.7060001@plexistor.com> <20150811152850.GA2608@node.dhcp.inet.fi> <55CA2008.7070702@plexistor.com> <20150811202639.GA1408@node.dhcp.inet.fi>
In-Reply-To: <20150811202639.GA1408@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Theodore Ts'o <tytso@mit.edu>

On 08/11/2015 11:26 PM, Kirill A. Shutemov wrote:
> On Tue, Aug 11, 2015 at 07:17:12PM +0300, Boaz Harrosh wrote:
>> On 08/11/2015 06:28 PM, Kirill A. Shutemov wrote:
>>> We also used lock_page() to make sure we shoot out all pages as we don't
>>> exclude page faults during truncate. Consider this race:
>>>
>>> 	<fault>			<truncate>
>>> 	get_block
>>> 	check i_size
>>>     				update i_size
>>> 				unmap
>>> 	setup pte
>>>
>>
>> Please consider this senario then:
>>
>>  	<fault>			<truncate>
>> 	read_lock(inode)
>>
>>  	get_block
>>  	check i_size
>> 	
>> 	read_unlock(inode)
>>
>> 				write_lock(inode)
>>
>>      				update i_size
>> 				* remove allocated blocks
>>  				unmap
>>
>> 				write_unlock(inode)
>>
>>  	setup pte
>>
>> IS what you suppose to do in xfs
> 
> Do you realize that you describe a race? :-P
> 
> Exactly in this scenario pfn your pte point to is not belong to the file
> anymore. Have fun.
> 

Sorry yes I have written it wrong, I have now returned to read the actual code
and the setup pte part is also part of the read lock inside the fault handler
before the release of the r_lock.
Da of course it is, it is the page_fault handler that does the
vm_insert_mixed(vma,,pfn) and in the case of concurrent faults the second
call to vm_insert_mixed will return -EBUSY which means all is well.

So the only thing left is the fault-to-fault zero-the-page race as Matthew described
and as Dave and me think we can make this part of the FS's get_block where it is
more natural.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
