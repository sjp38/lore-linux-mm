Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1606B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 13:41:11 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ib6so37538591pad.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 10:41:11 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id o128si4967976pfg.246.2016.07.07.10.33.01
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 10:33:07 -0700 (PDT)
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net>
From: Dave Hansen <dave@sr71.net>
Message-ID: <577E924C.6010406@sr71.net>
Date: Thu, 7 Jul 2016 10:33:00 -0700
MIME-Version: 1.0
In-Reply-To: <20160707144508.GZ11498@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On 07/07/2016 07:45 AM, Mel Gorman wrote:
> On Thu, Jul 07, 2016 at 05:47:28AM -0700, Dave Hansen wrote:
>> > 
>> > From: Dave Hansen <dave.hansen@linux.intel.com>
>> > 
>> > This establishes two more system calls for protection key management:
>> > 
>> > 	unsigned long pkey_get(int pkey);
>> > 	int pkey_set(int pkey, unsigned long access_rights);
>> > 
>> > The return value from pkey_get() and the 'access_rights' passed
>> > to pkey_set() are the same format: a bitmask containing
>> > PKEY_DENY_WRITE and/or PKEY_DENY_ACCESS, or nothing set at all.
>> > 
>> > These can replace userspace's direct use of the new rdpkru/wrpkru
>> > instructions.
...
> This one feels like something that can or should be implemented in
> glibc.

I generally agree, except that glibc doesn't have any visibility into
whether a pkey is currently valid or not.

> There is no real enforcement of the values yet looking them up or
> setting them takes mmap_sem for write.

There are checks for mm_pkey_is_allocated().  That's the main thing
these syscalls add on top of the raw instructions.

> Applications that frequently get
> called will get hammed into the ground with serialisation on mmap_sem
> not to mention the cost of the syscall entry/exit.

I think we can do both of them without mmap_sem, as long as we resign
ourselves to this just being fundamentally racy (which it is already, I
think).  But, is it worth performance-tuning things that we don't expect
performance-sensitive apps to be using in the first place?  They'll just
use the RDPKRU/WRPKRU instructions directly.

Ingo, do you still feel strongly that these syscalls (pkey_set/get())
should be included?  Of the 5, they're definitely the two with the
weakest justification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
