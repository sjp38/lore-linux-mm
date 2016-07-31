Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 704EF6B026A
	for <linux-mm@kvack.org>; Sun, 31 Jul 2016 02:22:56 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id s189so196258350vkh.0
        for <linux-mm@kvack.org>; Sat, 30 Jul 2016 23:22:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q3si6946422qkq.307.2016.07.30.23.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jul 2016 23:22:55 -0700 (PDT)
Date: Sun, 31 Jul 2016 08:22:49 +0200
From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: Is reading from /proc/self/smaps thread-safe?
Message-ID: <20160731062248.lqdakdzdyl7qya73@mguzik>
References: <CA+GA0_uRjKznAB+d-3bDqdNRDYBA+YQbYSUcB9=rDTLk1NJEmg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+GA0_uRjKznAB+d-3bDqdNRDYBA+YQbYSUcB9=rDTLk1NJEmg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 26, 2016 at 02:44:48PM +0200, Marcin A?lusarz wrote:
> Hey
> 
> I have a simple program that mmaps 8MB of anonymous memory, spawns 16
> threads, reads /proc/self/smaps in each thread and looks up whether
> mapped address can be found in smaps. From time to time it's not there.
> 
> Is this supposed to work reliably?
> 
> My guess is that libc functions allocate memory internally using mmap
> and modify process' address space while other thread is iterating over
> vmas.
> 
> I see that reading from smaps takes mmap_sem in read mode. I'm guessing
> vm modifications are done under mmap_sem in write mode.
> 
> Documentation/filesystem/proc.txt says reading from smaps is "slow but
> very precise" (although in context of RSS).
> 

Address space modification definitely happens as threads get their
stacks mmaped and unmapped.

If you run your program under strace you will see all threads perform
multiple read()s to get the content as the kernel keeps return short
reads (below 1 page size). In particular, seq_read imposes the limit
artificially.

Since there are multiple trips to the kernel, locks are dropped and
special measures are needed to maintain consistency of the result.

In m_start you can see there is a best-effort attempt: it is remembered
what vma was accessed by the previous run. But the vma can be unmapped
before we get here next time.

So no, reading the file when the content is bigger than 4k is not
guaranteed to give consistent results across reads.

I don't have a good idea how to fix it, and it is likely not worth
working on. This is not the only place which is unable to return
reliable information for sufficiently large dataset.

The obvious thing to try out is just storing all the necessary
information and generating the text form on read. Unfortunately even
that data is quite big -- over 100 bytes per vma. This can be shrinked
down significantly with encoding what information is present as opposed
to keeping all records). But with thousands of entries per application
this translates into kilobytes of memory which would have to allocated
just to hold it, sounds like a non-starter to me.

-- 
Mateusz Guzik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
