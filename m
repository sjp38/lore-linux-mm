Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E08CD6B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 17:15:10 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id 4so42121257pfd.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 14:15:10 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id kx15si14565499pab.43.2016.03.01.14.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 14:15:10 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
References: <20160301070911.GD3730@linux.intel.com>
 <20160301102541.GD27666@quack.suse.cz>
 <20160301214403.GJ3730@linux.intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56D61467.5000006@oracle.com>
Date: Tue, 1 Mar 2016 14:15:03 -0800
MIME-Version: 1.0
In-Reply-To: <20160301214403.GJ3730@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 03/01/2016 01:44 PM, Matthew Wilcox wrote:
> On Tue, Mar 01, 2016 at 11:25:41AM +0100, Jan Kara wrote:
>> On Tue 01-03-16 02:09:11, Matthew Wilcox wrote:
>>> There are a few issues around 1GB THP support that I've come up against
>>> while working on DAX support that I think may be interesting to discuss
>>> in person.
>>>
>>>  - Do we want to add support for 1GB THP for anonymous pages?  DAX support
>>>    is driving the initial 1GB THP support, but would anonymous VMAs also
>>>    benefit from 1GB support?  I'm not volunteering to do this work, but
>>>    it might make an interesting conversation if we can identify some users
>>>    who think performance would be better if they had 1GB THP support.
>>
>> Some time ago I was thinking about 1GB THP and I was wondering: What is the
>> motivation for 1GB pages for persistent memory? Is it the savings in memory
>> used for page tables? Or is it about the cost of fault?
> 
> I think it's both.  I heard from one customer who calculated that with
> a 6TB server, mapping every page into a process would take ~24MB of
> page tables.  Multiply that by the 50,000 processes they expect to run
> on a server of that size consumes 1.2TB of DRAM.  Using 1GB pages reduces
> that by a factor of 512, down to 2GB.
> 
> Another topic to consider then would be generalising the page table
> sharing code that is currently specific to hugetlbfs.  I didn't bring
> it up as I haven't researched it in any detail, and don't know how hard
> it would be.

Well, I have started down that path and have it working for some very
simple cases with some very hacked up code.  Too early/ugly to share.
I'm struggling a bit with fact that you can have both regular and huge
page mappings of the same regions.  The hugetlb code only has to deal
with huge pages.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
