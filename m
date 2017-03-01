Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F4EB6B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 16:20:53 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q126so69101752pga.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 13:20:53 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 61si5614354plr.217.2017.03.01.13.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 13:20:52 -0800 (PST)
Subject: Re: [PATCH v2 1/3] sparc64: NG4 memset 32 bits overflow
References: <1488327283-177710-1-git-send-email-pasha.tatashin@oracle.com>
 <1488327283-177710-2-git-send-email-pasha.tatashin@oracle.com>
 <87h93dhmir.fsf@firstfloor.org>
 <70b638b0-8171-ffce-c0c5-bdcbae3c7c46@oracle.com>
 <20170301151910.GH26852@two.firstfloor.org>
 <6a26815d-0ec2-7922-7202-b1e17d58aa00@oracle.com>
 <20170301173136.GI26852@two.firstfloor.org>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <1e7db21b-808d-1f47-e78c-7d55c543ae39@oracle.com>
Date: Wed, 1 Mar 2017 16:20:28 -0500
MIME-Version: 1.0
In-Reply-To: <20170301173136.GI26852@two.firstfloor.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org

Hi Andi,

After thinking some more about this issue, I figured that I would not 
want to set default maximums.

Currently, the defaults are scaled with system memory size, which seems 
like the right thing to do to me. They are set to size hash tables one 
entry per page and, if a scale argument is provided, scale them down to 
1/2, 1/4, 1/8 entry per page etc.

So, in some cases the scale argument may be wrong, and dentry, inode, or 
some other client of alloc_large_system_hash() should be adjusted.

For example, I am pretty sure that scale value in most places should be 
changed from literal value (inode scale = 14, dentry scale = 13, etc to: 
(PAGE_SHIFT + value): inode scale would become (PAGE_SHIFT + 2), dentry 
scale would become (PAGE_SHIFT + 1), etc. This is because we want 1/4 
inodes and 1/2 dentries per every page in the system.
In alloc_large_system_hash() we have basically this:
nentries = nr_kernel_pages >> (scale - PAGE_SHIFT);

This is basically a bug, and would not change the theory, but I am sure 
that changing scales without at least some theoretical backup is not a 
good idea and would most likely lead to regressions, especially on some 
smaller configurations.

Therefore, in my opinion having one fast way to zero hash tables, as 
this patch tries to do, is a good thing. In the next patch revision I 
can go ahead and change scales to be (PAGE_SHIFT + val) from current 
literals.

Thank you,
Pasha

On 2017-03-01 12:31, Andi Kleen wrote:
> On Wed, Mar 01, 2017 at 11:34:10AM -0500, Pasha Tatashin wrote:
>> Hi Andi,
>>
>> Thank you for your comment, I am thinking to limit the default
>> maximum hash tables sizes to 512M.
>>
>> If it is bigger than 512M, we would still need my patch to improve
>
> Even 512MB seems too large. I wouldn't go larger than a few tens
> of MB, maybe 32MB.
>
> Also you would need to cover all the big hashes.
>
> The most critical ones are likely the network hash tables, these
> maybe be a bit larger (but certainly also not 0.5TB)
>
> -Andi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
