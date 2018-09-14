Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D5C498E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 20:25:34 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bg5-v6so3405993plb.20
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 17:25:34 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z5-v6si5662569pgf.488.2018.09.13.17.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 17:25:33 -0700 (PDT)
Subject: Re: [PATCH V2 0/6] VA to numa node information
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
 <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
 <20180913171016.55dca2453c0773fc21044972@linux-foundation.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3c77cc75-976f-1fb8-9380-cc6ab9854a26@intel.com>
Date: Thu, 13 Sep 2018 17:25:32 -0700
MIME-Version: 1.0
In-Reply-To: <20180913171016.55dca2453c0773fc21044972@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, prakash.sangappa@oracle.com
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nao.horiguchi@gmail.com, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com

On 09/13/2018 05:10 PM, Andrew Morton wrote:
>> Also, VMAs having THP pages can have a mix of 4k pages and hugepages.
>> The page walks would be efficient in scanning and determining if it is
>> a THP huge page and step over it. Whereas using the API, the application
>> would not know what page size mapping is used for a given VA and so would
>> have to again scan the VMA in units of 4k page size.
>>
>> If this sounds reasonable, I can add it to the commit / patch description.

As we are judging whether this is a "good" interface, can you tell us a
bit about its scalability?  For instance, let's say someone has a 1TB
VMA that's populated with interleaved 4k pages.  How much data comes
out?  How long does it take to parse?  Will we effectively deadlock the
system if someone accidentally cat's the wrong /proc file?

/proc seems like a really simple way to implement this, but it seems a
*really* odd choice for something that needs to collect a large amount
of data.  The lseek() stuff is a nice addition, but I wonder if it's
unwieldy to use in practice.  For instance, if you want to read data for
the VMA at 0x1000000 you lseek(fd, 0x1000000, SEEK_SET, right?  You read
~20 bytes of data and then the fd is at 0x1000020.  But, you're getting
data out at the next read() for (at least) the next page, which is also
available at 0x1001000.  Seems funky.  Do other /proc files behave this way?
