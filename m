Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id A9B616B0074
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:34:22 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 16 Nov 2012 11:34:21 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B43F23E40039
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:34:13 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAGIY4uI124596
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:34:04 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAGIY3bO025756
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:34:03 -0700
Message-ID: <50A68718.3070002@linux.vnet.ibm.com>
Date: Fri, 16 Nov 2012 10:34:00 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Bug 50181] New: Memory usage doubles after more then 20 hours
 of uptime.
References: <bug-50181-27@https.bugzilla.kernel.org/> <20121113140352.4d2db9e8.akpm@linux-foundation.org> <1352988349.6409.4.camel@c2d-desktop.mypicture.info> <20121115141258.8e5cc669.akpm@linux-foundation.org> <1353021103.6409.31.camel@c2d-desktop.mypicture.info>
In-Reply-To: <1353021103.6409.31.camel@c2d-desktop.mypicture.info>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milos Jakovljevic <sukijaki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On 11/15/2012 03:11 PM, Milos Jakovljevic wrote:
> Or maybe, it is just some problem with nvidia blob and 3.7 kernel
> loosing VM_RELEASE  (in a blob's mmap.c it was replaced with
> VM_DONTEXPAND | VM_DONTDUMP ).  - or maybe I'm just saying nonsense
> here.

I'm using Intel graphics, so it's not nvidia related for me, at least.

I've been recording a bunch of gunk from /proc once a minute for the
past 16 hours or so.  I've grepped some of it in to a log file (but I've
got a *LOT* more than this):

	http://sr71.net/~dave/linux/leak-20121113/log.1353087988.txt.gz

>From meminfo, it shows MemFree/Buffers/Cached/AnonPages/Slab/PageTables,
and their sum.  That should capture _most_ of the memory use on the
system, and if we see that sum going down, it's probably a sign of the
leak, especially when we see a trend over a long period.  The file is in
roughly this format, if anyone cares:

	<nr/date>  <meminfo fields> sums:  <sum fields> <delta>

The system in question is my laptop.  What I can tell is that it doesn't
leak much when I'm not using it.  But, it's leaking pretty steadily
since I started using the system today (~6am in the logs).  It
_averages_ leaking about 400kB/minute when idle and almost 9MB/minute
when in active use.

I've tried to provoke the leak doing specific things like large
downloads, kernel compiles, watching video, alloc'ing a bunch of
transparent huge pages, then exiting...  No smoking gun so far.

Anybody have ideas what to try next or want to poke holes in my
statistics? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
