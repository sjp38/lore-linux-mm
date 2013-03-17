Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 199396B0005
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 20:42:07 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id 10so5797326ied.2
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 17:42:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <514502B6.2090804@gmail.com>
References: <DEACCBA4C6A9D145A6A68B5F5BE581B80FC057AB@HKXPRD0310MB353.apcprd03.prod.outlook.com>
	<514502B6.2090804@gmail.com>
Date: Sat, 16 Mar 2013 17:42:06 -0700
Message-ID: <CANN689HX9rhecNv3RsDn8QZO8iUrMsQQBgnhUDb5AdyfWgyFag@mail.gmail.com>
Subject: Re: mmap sync issue
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Gil Weber <gilw@cse-semaphore.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Sat, Mar 16, 2013 at 4:39 PM, Will Huck <will.huckk@gmail.com> wrote:
> On 03/15/2013 07:39 PM, Gil Weber wrote:
>> I am experiencing an issue with my device driver. I am using mmap and
>> ioctl to share information with my user space application.
>> The thing is that the shared memory does not seems to be synced. Do check
>> this, I have done a simple test:

So if I got this right, the issue is that the vmalloc_area is
virtually aliased between the kernel and the user space mapping, so
that coherency is not guaranteed on architectures that use virtually
aliased caches.

fs/aio.c does something similar to what you want with their ring
buffer. The kernel doesn't access the ring buffer through a vmalloc
area like you're trying to do; instead it uses kmap_atomic() ..
kunmap_atomic() whenever it wants to access it.

I don't actually consider myself an expert in this area but I believe
the above should solve your problem :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
