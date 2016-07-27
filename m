Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 944756B0261
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 05:18:41 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so10469586lfg.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 02:18:41 -0700 (PDT)
Received: from rp02.intra2net.com (rp02.intra2net.com. [62.75.181.28])
        by mx.google.com with ESMTPS id k6si5966589wjy.153.2016.07.27.02.18.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 02:18:39 -0700 (PDT)
From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Re: [Bug 64121] New: [BISECTED] "mm" performance regression updating from 3.2 to 3.3
Date: Wed, 27 Jul 2016 11:18:36 +0200
Message-ID: <1650204.9z6KOJWgNh@storm>
In-Reply-To: <b3219832-110d-2b74-5ba9-694ab30589f0@suse.cz>
References: <bug-64121-27@https.bugzilla.kernel.org/> <b4aff3a2-cc22-c68c-cafc-96db332f86c3@intra2net.com> <b3219832-110d-2b74-5ba9-694ab30589f0@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Thursday, 21. July 2016 16:02:06 Vlastimil Babka wrote:
> > recently we've updated our production mail server from 3.14.69
> > to 3.14.73 and it worked fine for a few days. When the box is really
> > busy (=incoming malware via email), the I/O speed drops to crawl,
> 
> I don't see anything either, might be some change e.g. under fs/ though.
> How about git bisect?

One day later I failed to trigger it, so no easy git bisect.

Yesterday another busy mail server showed the same problem during backup 
creation. This time I knew about slabtop and could see that the 
ext4_inode_cache occupied about 393MB of the 776MB total low memory.
Write speed was down to 25 MB/s.

"sysctl -w vm.drop_caches=3" cleared the inode cache
and the write speed was back to 300 MB/s.

It might be related to memory fragmentation of low memory due to the 
inode cache, the mail server has over 1.400.000 millions files.

I suspect the problem is unrelated to 3.14.73 per se, it seems to trigger 
depending how busy the machine is and the memory layout.

A 64 bit kernel (even with a 32 bit userspace) is the proper solution here.
Still that would mean to deprecate working 32 bit only boxes.

Cheers,
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
