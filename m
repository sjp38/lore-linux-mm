Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 896736B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 13:24:17 -0500 (EST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Sun, 24 Feb 2013 11:24:15 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2A6A919D8045
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 11:24:08 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1OIO9Ku257996
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 11:24:09 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1OIO8UJ016854
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 11:24:08 -0700
Message-ID: <512A5AC4.30808@linux.vnet.ibm.com>
Date: Sun, 24 Feb 2013 10:24:04 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
References: <1361660281-22165-1-git-send-email-psusi@ubuntu.com> <1361660281-22165-2-git-send-email-psusi@ubuntu.com> <5129710F.6060804@linux.vnet.ibm.com> <51298B0C.2020400@ubuntu.com>
In-Reply-To: <51298B0C.2020400@ubuntu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: linux-mm@kvack.org

On 02/23/2013 07:37 PM, Phillip Susi wrote:
> This is the correct behavior prescribed by posix.  If you have been
> using it for that purpose in the past, then you were using the wrong
> syscall.  If you want to begin writeout now, then you should be using
> sync_file_range().  As it was, it only initiated writeout if the
> backing device was not already congested, which is going to no longer
> be the case rather soon if you ( or other tasks ) are writing
> significant amounts of data.
> 
> If you really want to stay out of memory reclaim entirely, then you
> should be using O_DIRECT.

These are folks that want to use the page cache, but also want to be in
control of when it gets written out (sync_file_range() is used) and when
it goes away.  Sure, they can use O_DIRECT and do all of the buffering
internally, but that means changing the application.

I actually really like the concept behind your patch.  It looks like
very useful functionality.  I'm just saying that I know it will break
_existing_ users.

I'm actually in the process of _trying_ to extricate this particular app
from handling their own reclaim management entirely.  Your patch looks
like a nice part of the puzzle.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
