Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC2F78E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 21:31:14 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id s5-v6so10742654iop.3
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 18:31:14 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c52-v6si5622093jak.49.2018.09.14.18.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 18:31:13 -0700 (PDT)
Message-ID: <5B9C60D4.30106@oracle.com>
Date: Fri, 14 Sep 2018 18:31:00 -0700
From: Prakash Sangappa <prakash.sangappa@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 0/6] VA to numa node information
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com> <20180913084011.GC20287@dhcp22.suse.cz> <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com> <20180913171016.55dca2453c0773fc21044972@linux-foundation.org> <3c77cc75-976f-1fb8-9380-cc6ab9854a26@intel.com>
In-Reply-To: <3c77cc75-976f-1fb8-9380-cc6ab9854a26@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nao.horiguchi@gmail.com, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com

On 9/13/2018 5:25 PM, Dave Hansen wrote:
> On 09/13/2018 05:10 PM, Andrew Morton wrote:
>>> Also, VMAs having THP pages can have a mix of 4k pages and hugepages.
>>> The page walks would be efficient in scanning and determining if it is
>>> a THP huge page and step over it. Whereas using the API, the application
>>> would not know what page size mapping is used for a given VA and so would
>>> have to again scan the VMA in units of 4k page size.
>>>
>>> If this sounds reasonable, I can add it to the commit / patch description.
> As we are judging whether this is a "good" interface, can you tell us a
> bit about its scalability?  For instance, let's say someone has a 1TB
> VMA that's populated with interleaved 4k pages.  How much data comes
> out?  How long does it take to parse?  Will we effectively deadlock the
> system if someone accidentally cat's the wrong /proc file?

For the worst case scenario you describe, it would be one line(range) 
for each 4k. Which would
be similar to what you get with  '/proc/*/pagemap'. The amount of data 
copied out at a
time is based on the buffer size used in the kernel. Which is 1024. That 
is if one line(one range)
printed is about 40 bytes(char), that means  about 25 lines per copy 
out.  Main concern would
be holding  'mmap_sem' lock, which can cause hangs. When the 1024 buffer 
gets filled the
mmap_sem is dropped and the buffer content is copied out to the user 
buffer. Then the
mmap_sem lock is reacquired and the page walk continues as needed until 
the specified user
buffer size is filed or till end of process address space is reached.

One potential issue could be that there is  a large VA range with all 
pages populated from
one numa node, then the page walk could take longer while holding 
mmap_sem lock. This
can be addressed by dropping and re-acquiring the mmap_sem lock after 
certain number of
pages have been walked(Say 512 - which is what happens in 
'/proc/*/pagemap' case).

>
> /proc seems like a really simple way to implement this, but it seems a
> *really* odd choice for something that needs to collect a large amount
> of data.  The lseek() stuff is a nice addition, but I wonder if it's
> unwieldy to use in practice.  For instance, if you want to read data for
> the VMA at 0x1000000 you lseek(fd, 0x1000000, SEEK_SET, right?  You read
> ~20 bytes of data and then the fd is at 0x1000020.  But, you're getting
> data out at the next read() for (at least) the next page, which is also
> available at 0x1001000.  Seems funky.  Do other /proc files behave this way?
>
Yes, SEEK_SET to the VA.  The lseek offset is the process VA. So it is 
not going to be
different from reading a normal text file.  Expect that  /proc files are 
special. Ex In
/proc/*/pagemap' file case, read enforces that seek/file offset and the 
user buffer size
passed in to  be a  multiple of the pagemap_entry_t  size or else the 
read would fail.

The usage for numa_vamaps file will be to SEEK_SET to the VA from where 
VA range
to numa node information needs to be read.

The  'fd' offset is not taken into consideration here, just the VA. Say 
each va range to numa
node id printed is about 40 bytes(chars). Now if  the read only read 20 
bytes, it would have read
part of the line. Subsequent read would read the remaining bytes of the 
line, which will
be stored in the kernel buffer.
