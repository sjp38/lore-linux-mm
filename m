Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id B824E6B025F
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 13:03:35 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so114899091wic.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 10:03:35 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id gg17si23473589wjc.5.2015.09.28.10.03.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 10:03:33 -0700 (PDT)
Date: Mon, 28 Sep 2015 19:03:32 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm: fix cpu hangs on truncating last page of a 16t
 sparse file
Message-ID: <20150928170332.GA12732@two.firstfloor.org>
References: <560723F8.3010909@gmail.com>
 <alpine.LSU.2.11.1509261835360.9917@eggly.anvils>
 <560752C7.80605@gmail.com>
 <alpine.LSU.2.11.1509270953460.1024@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1509270953460.1024@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: angelo <angelo70@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Jeff Layton <jlayton@poochiereds.net>, Eryu Guan <eguan@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

> I can't tell you why MAX_LFS_FILESIZE was defined to exclude half
> of the available range.  I've always assumed that it's because there
> were known or feared areas of the code, which manipulate between
> bytes and pages, and might hit sign extension issues - though
> I cannot identify those places myself.

The limit was intentional to handle old user space. I don't think
it has anything to do with the kernel.

off_t is sometimes used signed, mainly with lseek SEEK_CUR/END when you
want to seek backwards. It would be quite odd to sometimes
have off_t be signed (SEEK_CUR/END) and sometimes be unsigned
(when using SEEK_SET).  So it made some sense to set the limit
to the signed max value.

Here's the original "Large file standard" that describes
the issues in more details:

http://www.unix.org/version2/whatsnew/lfs20mar.html

This document explicitly requests signed off_t:

>>>


Mixed sizes of off_t
    During a period of transition from existing systems to systems able to support an arbitrarily large file size, most systems will need to support binaries with two or more sizes of the off_t data type (and related data types). This mixed off_t environment may occur on a system with an ABI that supports different sizes of off_t. It may occur on a system which has both a 64-bit and a 32-bit ABI. Finally, it may occur when using a distributed system where clients and servers have differing sizes of off_t. In effect, the period of transition will not end until we need 128-bit file sizes, requiring yet another transition! The proposed changes may also be used as a model for the 64 to 128-bit file size transition. 
Offset maximum
    Most, but unfortunately not all, of the numeric values in the SUS are protected by opaque type definitions. In theory this allows programs to use these types rather than the underlying C language data types to avoid issues like overflow. However, most existing code maps these opaque data types like off_t to long integers that can overflow for the values needed to represent the offsets possible in large files.

    To protect existing binaries from arbitrarily large files, a new value (offset maximum) will be part of the open file description. An offset maximum is the largest offset that can be used as a file offset. Operations attempting to go beyond the offset maximum will return an error. The offset maximum is normally established as the size of the off_t "extended signed integral type" used by the program creating the file description.

    The open() function and other interfaces establish the offset maximum for a file description, returning an error if the file size is larger than the offset maximum at the time of the call. Returning errors when the 
<<<

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
