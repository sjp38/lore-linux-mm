Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 4557C6B0008
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:50:46 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 25 Feb 2013 12:50:45 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2A985C90023
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:50:34 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1PHoXkg26607694
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:50:34 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1PHoX6s019190
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:50:33 -0500
Message-ID: <512BA45D.5040201@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2013 09:50:21 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
References: <1361660281-22165-1-git-send-email-psusi@ubuntu.com> <1361660281-22165-2-git-send-email-psusi@ubuntu.com> <5129710F.6060804@linux.vnet.ibm.com> <51298B0C.2020400@ubuntu.com> <512A5AC4.30808@linux.vnet.ibm.com> <512A7AC4.5000006@ubuntu.com> <512A8550.2040200@linux.vnet.ibm.com> <512A965A.6060201@ubuntu.com>
In-Reply-To: <512A965A.6060201@ubuntu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: linux-mm@kvack.org

On 02/24/2013 02:38 PM, Phillip Susi wrote:
> On 02/24/2013 04:25 PM, Dave Hansen wrote:
>> Essentially, they don't want any I/O initiated except that which
>> is initiated by the app.  If you let the system get in to reclaim,
>> it'll start doing dirty writeout for pages other than those the app
>> is interested in.
> 
> Are you talking about IO initiated by the app, or other tasks in the
> system?  If the former then it won't be affected by this change.

Once we go in to reclaim, we'll start writeback on dirty pages.  The
VM's writeback patterns are not as efficient as if the app itself was
initiating them from sync_file_range(), and we see massive throughput
loss on the disk.

>From the looks of your patch, deactivating all the pages (if clean of
course) will get them on the LRU, and should keep any direct-reclaiming
tasks from actually going and initiating any additional I/O.

It looks like a promising approach, at least theoretically.  I'll
definitely test and see if it works in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
