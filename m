Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB6B6B0388
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 18:10:28 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y187so21167229wmy.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 15:10:28 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id g76si6151995wmc.39.2017.03.01.15.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 15:10:26 -0800 (PST)
Date: Wed, 1 Mar 2017 15:10:25 -0800
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 1/3] sparc64: NG4 memset 32 bits overflow
Message-ID: <20170301231025.GJ26852@two.firstfloor.org>
References: <1488327283-177710-1-git-send-email-pasha.tatashin@oracle.com>
 <1488327283-177710-2-git-send-email-pasha.tatashin@oracle.com>
 <87h93dhmir.fsf@firstfloor.org>
 <70b638b0-8171-ffce-c0c5-bdcbae3c7c46@oracle.com>
 <20170301151910.GH26852@two.firstfloor.org>
 <6a26815d-0ec2-7922-7202-b1e17d58aa00@oracle.com>
 <20170301173136.GI26852@two.firstfloor.org>
 <1e7db21b-808d-1f47-e78c-7d55c543ae39@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1e7db21b-808d-1f47-e78c-7d55c543ae39@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org

> For example, I am pretty sure that scale value in most places should
> be changed from literal value (inode scale = 14, dentry scale = 13,
> etc to: (PAGE_SHIFT + value): inode scale would become (PAGE_SHIFT +
> 2), dentry scale would become (PAGE_SHIFT + 1), etc. This is because
> we want 1/4 inodes and 1/2 dentries per every page in the system.

This is still far too much for a large system. The algorithm
simply was not designed for TB systems.

It's unlikely to have nowhere near that many small files active, as it's 
better to use the memory for something that is actually useful.

Also even a few hops in the open hash table are normally not a problems
dentry/inode; it is not that file lookups are that critical.

For networking the picture may be different, but I suspect GBs worth of
hash tables are still overkill there (Dave et.al. may have stronger opinions on this) 

I think a upper size (with user override which already exists) is fine,
but if you really don't want to do it then scale the factor down 
very aggressively for larger sizes, so that we don't end up with more
than a few tens of MB.

> This is basically a bug, and would not change the theory, but I am
> sure that changing scales without at least some theoretical backup

One dentry per page would only make sense if the files are zero sized.
If the file even has one byte then it already needs more than 1 page just to
cache the contents (even ignoring inodes and other caches)

With larger files that need multiple pages it makes even less sense.

So clearly one dentry per page theory is nonsense if the files are actually
used.

There is the "make find / + stat fast" case (where only the entries 
and inodes are cached). But even there it is unlikely that the TB system
has a much larger file system with more files than the 100GB system, so
I once a reasonable plateau is reached I don't see why you would want 
to exceed that.

Also the reason to make hash tables big is to minimize collisions,
but we have fairly good hash functions and a few hops worse case 
are likely not a problem for an already expensive file access
or open.

BTW the other option would be to switch all the large system hashes to a
rhashtable and do the resizing only when it is actually needed. 
But that would be more work than just adding a reasonable upper limit.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
