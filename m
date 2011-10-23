Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFD16B002D
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 12:39:07 -0400 (EDT)
Received: by yxp4 with SMTP id 4so2150906yxp.14
        for <linux-mm@kvack.org>; Sun, 23 Oct 2011 09:39:04 -0700 (PDT)
Message-ID: <4EA4431A.3010104@amacapital.net>
Date: Sun, 23 Oct 2011 09:38:50 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during writeback
 for various fses
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com> <87tyd31fkc.fsf@devron.myhome.or.jp> <20110510123819.GB4402@quack.suse.cz> <87hb924s2x.fsf@devron.myhome.or.jp> <20110510132953.GE4402@quack.suse.cz> <878vue4qjb.fsf@devron.myhome.or.jp> <87zkmu3b2i.fsf@devron.myhome.or.jp> <20110510145421.GJ4402@quack.suse.cz> <87zkmupmaq.fsf@devron.myhome.or.jp> <20110510162237.GM4402@quack.suse.cz>
In-Reply-To: <20110510162237.GM4402@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On 05/10/2011 09:22 AM, Jan Kara wrote:
> On Wed 11-05-11 01:12:13, OGAWA Hirofumi wrote:
>> Jan Kara<jack@suse.cz>  writes:
>>
>>>> Did you already consider, to copy only if page was writeback (like
>>>> copy-on-write)? I.e. if page is on I/O, copy, then switch the page for
>>>> writing new data.
>>>    Yes, that was considered as well. We'd have to essentially migrate the
>>> page that is under writeback and should be written to. You are going to pay
>>> the cost of page allocation, copy, increased memory&  cache pressure.
>>> Depending on your backing storage and workload this may or may not be better
>>> than waiting for IO...
>>
>> Maybe possible, but you really think on usual case just blocking is
>> better?
>    Define usual case... As Christoph noted, we don't currently have a real
> practical case where blocking would matter (since frequent rewrites are
> rather rare). So defining what is usual when we don't have a single real
> case is kind of tough ;)
>

I'm a bit late to the party, but I have such a use case.  I have a 
real-time program that generates logs.  There's a thread that makes sure 
that there are always mlocked, MAP_SHARED, writable pages for the logs, 
and under normal (or even very heavy) load, the mlocked pages always 
stay far ahead of the logs.  On 2.6.39, it works great [1].  On 3.0, 
it's unusable -- latencies of 30-100 ms are very common.

In this case, neither throughput nor available memory matter at all -- 
I'm not stressing either.  So copying the pages (especially if they're 
mlocked) would be more than a small percentage win -- it would be the 
difference between great performance and unusability.

I wonder if we want a stronger version of mlock that says "this page 
must not be swapped out and, in addition, ptes must always be mapped 
with all appropriate permission bits set".  (This is only possible with 
hardware dirty and accessed bits, but we could come close even without 
them.)


[1] file_update_time is a problem.  patches coming.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
