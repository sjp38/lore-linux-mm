Received: from f03n07e
	by ausmtp02.au.ibm.com (IBM AP 1.0) with ESMTP id OAA219788
	for <linux-mm@kvack.org>; Thu, 13 Apr 2000 14:56:42 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n07e (8.8.8m2/8.8.7) with SMTP id PAA42470
	for <linux-mm@kvack.org>; Thu, 13 Apr 2000 15:01:25 +1000
Message-ID: <CA2568C0.001B9300.00@d73mta05.au.ibm.com>
Date: Thu, 13 Apr 2000 10:23:03 +0530
Subject: Re: page->offset
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I think I had put up the question in a wrong way.

If I mmap a file from/at a particular offset.
char *p;
fd = open("anyfile");
p = mmap (NULL,100,PROT_READ|PROT_WRITE, MAP_SHARED,fd,10);

Here the call fails .
I tried to map at / from offset 512 that also failed.
however with the offset of 1024 it succeded.

So I can not mmap anything which is not fs block size aligned .

#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
main (int argc, char **argv)
{
        int i = 0;
        int fd = open("./anyfile",O_RDWR);
        char *p = mmap (NULL,10,PROT_READ,MAP_SHARED,fd,1024);
        char *s = mmap (NULL,10,PROT_READ,MAP_SHARED,fd,1024);
        char *q = 0;

        q = (char*)((int)p & 0xfffff000);
        printf ("p %x masked p %x\n",p,q);
        q = (char*)((int)s & 0xfffff000);
        printf ("s %x masked s %x\n",s,q);
}
The output of this was
p 40014000 masked p 40014000
s 40015000 masked s 40015000

Does these virtual addresses point to only one physical page ?
This page is in the page cache if I am not wrong with page->count = 3 ?
(2.2.x)


If I do read () from 1024 offset the data I will get will be from the above

phyiscal page or from .... ?

Nilesh




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
