Date: Thu, 13 Apr 2000 10:59:06 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: page->offset
Message-ID: <20000413105906.D11123@redhat.com>
References: <CA2568C0.001B9300.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568C0.001B9300.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Thu, Apr 13, 2000 at 10:23:03AM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Apr 13, 2000 at 10:23:03AM +0530, pnilesh@in.ibm.com wrote:
> 
> Here the call fails .
> I tried to map at / from offset 512 that also failed.
> however with the offset of 1024 it succeded.

Odd, it shouldn't.  Which kernel is this?

>         char *p = mmap (NULL,10,PROT_READ,MAP_SHARED,fd,1024);
>         char *s = mmap (NULL,10,PROT_READ,MAP_SHARED,fd,1024);

strace shows:

  old_mmap(NULL, 10, PROT_READ, MAP_SHARED, 3, 0x400) = -1 EINVAL (Invalid argument)
  old_mmap(NULL, 10, PROT_READ, MAP_SHARED, 3, 0x400) = -1 EINVAL (Invalid argument)

on a 1k blocksize filesystem.

> Does these virtual addresses point to only one physical page ?
> This page is in the page cache if I am not wrong with page->count = 3 ?
> (2.2.x)

Correct.

> If I do read () from 1024 offset the data I will get will be from the above
> phyiscal page or from .... ?

read() _always_ invokes the page cache with pagesize-aligned
page offsets.  If a correctly aligned page is not present, a new one
will be created.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
