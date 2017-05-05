Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63BA66B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 09:29:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y22so794681wry.1
        for <linux-mm@kvack.org>; Fri, 05 May 2017 06:29:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 71si5170890wmw.68.2017.05.05.06.29.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 06:29:43 -0700 (PDT)
Date: Fri, 5 May 2017 15:29:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 4/4] mm: Adaptive hash table scaling
Message-ID: <20170505132941.GB31461@dhcp22.suse.cz>
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
 <1488432825-92126-5-git-send-email-pasha.tatashin@oracle.com>
 <20170303153247.f16a31c95404c02a8f3e2c5f@linux-foundation.org>
 <20170426201126.GA32407@dhcp22.suse.cz>
 <40f72efa-3928-b3c6-acca-0740f1a15ba4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <40f72efa-3928-b3c6-acca-0740f1a15ba4@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Thu 04-05-17 14:23:24, Pasha Tatashin wrote:
> Hi Michal,
> 
> I do not really want to impose any hard limit, because I do not know what it
> should be.
> 
> The owners of the subsystems that use these large hash table should make a
> call, and perhaps pass high_limit, if needed into alloc_large_system_hash().

Some of surely should. E.g. mount_hashtable resp. mountpoint_hashtable
really do not need a large hash AFAIU. On the other hand it is somehow
handy to scale dentry and inode hashes according to the amount of
memory. But the scale factor should be much slower than the current
upstream implementation. As I've said I do not want to judge your
scaling change. All I am saying that making it explicit is just _wrong_
because it a) doesn't cover all cases just the two you have noticed and
b) new users will most probably just copy&paste existing users so
chances are they will introduce the same large hashtables without a good
reason. I would even say that user shouldn't care about how the scaling
is implemented. There is a way to limit it and if there is no limit set
then just do whatever is appropriate.

> 
> Previous growth rate was unacceptable, because in addition to allocating
> large tables (which is acceptable if we take a total system memory size), we
> also needed to zero that, and zeroing while we have only one CPU available
> was significantly reducing the boot time.
> 
> Now, on 32T the hash table is 1G instead of 32G, so the call is 32 times
> faster to finish. While it is not a good idea to waste memory, both 1G and
> 32G is insignificant amount of memory compared to the total amount of such
> 32T systems (0.09% and 0.003% accordingly).

Try to think in terms of hashed objects. How many objects would we need
to hash? Also this might be not a significant portion of the memory but
it is still a memory which can be used for other purposes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
