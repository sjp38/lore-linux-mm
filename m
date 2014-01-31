Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7D18C6B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 14:03:03 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so4749561pab.16
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 11:03:03 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id yt9si3533454pab.323.2014.01.31.11.03.01
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 11:03:02 -0800 (PST)
Message-ID: <1391194978.2172.20.camel@dabdike.int.hansenpartnership.com>
Subject: [LSF/MM TOPIC] Fixing large block devices on 32 bit
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 31 Jan 2014 11:02:58 -0800
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-scsi <linux-scsi@vger.kernel.org>, linux-ide <linux-ide@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: lsf-pc@lists.linux-foundation.org

It has been reported:

http://marc.info/?t=139111447200006

That large block devices (specifically devices > 16TB) crash when
mounted on 32 bit systems.  The problem specifically is that although
CONFIG_LBDAF extends the size of sector_t within the block and storage
layers to 64 bits, the buffer cache isn't big enough.  Specifically,
buffers are mapped through a single page cache mapping on the backing
device inode.  The size of the allowed offset in the page cache radix
tree is pgoff_t which is 32 bits, so once the size of device goes beyond
16TB, this offset wraps and all hell breaks loose.

The problem is that although the current single drive limit is about
4TB, it will only be a couple of years before 16TB devices are
available.  By then, I bet that most arm (and other exotic CPU) Linux
based personal file servers are still going to be 32 bit, so they're not
going to be able to take this generation (or beyond) of drives.  The
thing I'd like to discuss is how to fix this.  There are several options
I see, but there might be others.

     1. Try to pretend that CONFIG_LBDAF is supposed to cap out at 16TB
        and there's nothing we can do about it ... this won't be at all
        popular with arm based file server manufacturers.
     2. Slyly make sure that the buffer cache won't go over 16TB by
        keeping filesystem metadata below that limit ... the horse has
        probably already bolted on this one.
     3. Increase pgoff_t and the radix tree indexes to u64 for
        CONFIG_LBDAF.  This will blow out the size of struct page on 32
        bits by 4 bytes and may have other knock on effects, but at
        least it will be transparent.
     4. add an additional radix tree lookup within the buffer cache, so
        instead of a single inode for the buffer cache, we have a radix
        tree of them which are added and removed at the granularity of
        16TB offsets as entries are requested.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
