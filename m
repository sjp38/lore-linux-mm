Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id E5D806B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 03:06:47 -0500 (EST)
Received: by wicr5 with SMTP id r5so484090wic.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 00:06:37 -0800 (PST)
Message-ID: <1326355594.1999.7.camel@lappy>
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
From: Sasha Levin <levinsasha928@gmail.com>
Date: Thu, 12 Jan 2012 10:06:34 +0200
In-Reply-To: <20120111141219.271d3a97.akpm@linux-foundation.org>
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com>
	 <20120111141219.271d3a97.akpm@linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lizf@cn.fujitsu.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tyler Hicks <tyhicks@canonical.com>, Dustin Kirkland <kirkland@canonical.com>, ecryptfs@vger.kernel.org

On Wed, 2012-01-11 at 14:12 -0800, Andrew Morton wrote:
> There's nothing particularly special about memdup_user(): there are
> many ways in which userspace can trigger GFP_KERNEL allocations.
> 
> The problem here (one which your patch carefully covers up) is that
> ecryptfs_miscdev_write() is passing an unchecked userspace-provided
> `count' direct into kmalloc().  This is a bit problematic for other
> reasons: it gives userspace a way to trigger heavy reclaim activity and
> perhaps even to trigger the oom-killer.
> 
> A better fix here would be to validate the incoming arg before using
> it.  Preferably by running ecryptfs_parse_packet_length() before taking
> a copy of the data.  That would require adding a small copy_from_user()
> to peek at the message header. 

Let's split it to two parts: the specific ecryptfs issue I've given as
an example here, and a general view about memdup_user().

I fully agree that in the case of ecryptfs there's a missing validity
check, and just calling memdup_user() with whatever the user has passed
to it is wrong and dangerous. This should be fixed in the ecryptfs code
and I'll send a patch to do that.

The other part, is memdup_user() itself. Kernel warnings are usually
reserved (AFAIK) to cases where it would be difficult to notify the user
since it happens in a flow which the user isn't directly responsible
for.

memdup_user() is always located in path which the user has triggered,
and is usually almost the first thing we try doing in response to the
trigger. In those code flows it doesn't make sense to print a kernel
warnings and taint the kernel, instead we can simply notify the user
about that error and let him deal with it any way he wants.

There are more reasons kalloc() can show warnings besides just trying to
allocate too much, and theres no reason to dump kernel warnings when
it's easier to notify the user.

-- 

Sasha.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
