Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 49C876B02E7
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 21:38:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t88so181750pfg.17
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 18:38:36 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z77si37150pff.100.2018.01.02.18.38.34
        for <linux-mm@kvack.org>;
        Tue, 02 Jan 2018 18:38:35 -0800 (PST)
Subject: Re: About the try to remove cross-release feature entirely by Ingo
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R> <20171229035146.GA11757@thunk.org>
 <20171229072851.GA12235@X58A-UD3R>
 <20171230061624.GA27959@bombadil.infradead.org>
 <20171230154041.GB3366@thunk.org>
 <20171230204417.GF27959@bombadil.infradead.org>
 <20171230224028.GC3366@thunk.org> <20171230230057.GB12995@thunk.org>
 <20180101101855.GA23567@bombadil.infradead.org>
 <20180101160011.GA27417@thunk.org>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <6ee9ebc1-dc55-99d4-fa1f-ee9eb6084916@lge.com>
Date: Wed, 3 Jan 2018 11:38:33 +0900
MIME-Version: 1.0
In-Reply-To: <20180101160011.GA27417@thunk.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com, daniel@ffwll.ch

On 1/2/2018 1:00 AM, Theodore Ts'o wrote:
> On Mon, Jan 01, 2018 at 02:18:55AM -0800, Matthew Wilcox wrote:
>>> Clarification: all TCP connections that are used by kernel code would
>>> need to be in their own separate lock class.  All TCP connections used
>>> only by userspace could be in their own shared lock class.  You can't
>>> use a one lock class for all kernel-used TCP connections, because of
>>> the Network Block Device mounted on a local file system which is then
>>> exported via NFS and squirted out yet another TCP connection problem.
>>
>> So the false positive you're concerned about is write-comes-in-over-NFS
>> (with socket lock held), NFS sends a write request to local filesystem,
>> local filesystem sends write to block device, block device sends a
>> packet to a socket which takes that socket lock.
> 
> It's not just the socket lock, but any of the locks/mutexes/"waiters"
> that might be taken in the TCP code path and below, including in the
> NIC driver.
> 
>> I don't think we need to be as drastic as giving each socket its own lock
>> class to solve this.  All NFS sockets can be in lock class A; all NBD
>> sockets can be in lock class B; all user sockets can be in lock class
>> C; etc.
> 
> But how do you know which of the locks taken in the networking stack
> are for the NBD versus the NFS sockets?  What manner of horrific
> abstraction violation is going to pass that information all the way
> down to all of the locks that might be taken at the socket layer and
> below?
> 
> How is this "proper clasification" supposed to happen?  It's the
> repeated handwaving which claims this is easy which is rather
> frustrating.  The simple thing is to use a unique ID which is bumped
> for each struct sock, each struct super, struct block_device, struct
> request_queue, struct bdi, etc, but that runs into lockdep scalability
> issues.

This is what I mentioned with group ID in an example for you before.
To do that, the most important thing is to prevent running into
lockdep scalability.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
