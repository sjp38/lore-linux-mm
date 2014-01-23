Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE9B6B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 14:54:44 -0500 (EST)
Received: by mail-ve0-f177.google.com with SMTP id jz11so1397284veb.36
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 11:54:44 -0800 (PST)
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
        by mx.google.com with ESMTPS id uq6si7195150vcb.75.2014.01.23.11.54.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 11:54:43 -0800 (PST)
Received: by mail-vc0-f180.google.com with SMTP id ks9so1325105vcb.39
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 11:54:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52DF7D9B.20904@symas.com>
References: <CALCETrUaotUuzn60-bSt1oUb8+94do2QgiCq_TXhqEHj79DePQ@mail.gmail.com>
 <52D8AEBF.3090803@symas.com> <52D982EB.6010507@amacapital.net>
 <52DE23E8.9010608@symas.com> <20140121111727.GB13997@dastard>
 <CALCETrUWhWDSJNHT5OEmNSyBuGx4-AxqeS3YBcKL0nejZ6kQ4w@mail.gmail.com>
 <20140121203620.GD13997@dastard> <CALCETrV3jL-m74apTyEN+vb0vFQqoCnCrtJVW3_MWk57WS0kqw@mail.gmail.com>
 <20140121230333.GH13997@dastard> <52DF7D9B.20904@symas.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 23 Jan 2014 11:54:22 -0800
Message-ID: <CALCETrU=WNbpoNyNFZOw94B=1y6ad=dASgAmOGLuKp5k2cdD4g@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] [ATTEND] Persistent memory
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Howard Chu <hyc@symas.com>
Cc: Dave Chinner <david@fromorbit.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jan 22, 2014 at 12:13 AM, Howard Chu <hyc@symas.com> wrote:
> Dave Chinner wrote:
>>
>> On Tue, Jan 21, 2014 at 12:59:42PM -0800, Andy Lutomirski wrote:
>>>
>>> On Tue, Jan 21, 2014 at 12:36 PM, Dave Chinner <david@fromorbit.com>
>
>>> If we're using dm-crypt using an NV-DIMM "block" device as cache and a
>>> real disk as backing store, then ideally mmap would map the NV-DIMM
>>> directly if the data in question lives there.
>>
>>
>> dm-crypt does not use any block device as a cache. You're thinking
>> about dm-cache or bcache. And neither of them are operating at the
>> filesystem level or are aware of the difference between fileystem
>> metadata and user data.
>
>
> Why should that layer need to be aware? A page is a page, as far as they're
> concerned.

I think that, ideally, the awareness would go the other way.

dm-cache (where the backing store is a normal disk but the cache
storage is persistent memory) should not care what kind of page it's
caching.  On the other hand, the filesystem sitting on top of dm-cache
should be able to tell when a page (in the device exposed by dm-cache)
is actually CPU-addressable so it can avoid allocating yet another
copy in pagecache.  Similarly, it should be able to be notified when
that page is about to stop being cpu-addressable.

This might be an argument to have, in addition (or as a replacement
to) direct_access, XIP ops that ask for a reference to a page, are
permitted to fail (i.e. say "sorry, not CPU addressable right now),
and a way to be notified when a page is going away.

(This is totally unnecessary if using something like an NV-DIMM
directly -- it's only important for more complicated things like
dm-cache.)

>
>
>> But talking about non-existent block layer
>> functionality doesn't answer my the question about keeping user data
>> and filesystem metadata needed to reference that user data
>> coherent in persistent memory...
>
>
> One of the very useful tools for PCs in the '80s was reset-survivable
> RAMdisks. Given the existence of persistent memory in a machine, this is a
> pretty obvious feature to provide.

I think that a file on pmfs or ext4-xip will work like this.  Ideally
/dev/loop will be XIP-capable if the file it's sitting on top of is
XIP.

>
>
>>> If that's happening,
>>> then, assuming that there are no metadata changes, you could just
>>> flush the relevant hw caches.  This assumes, of course, no dm-crypt,
>>> no btrfs-style checksumming, and, in general, nothing else that would
>>> require stable pages or similar things.
>>
>>
>> Well yes. Data IO path transformations are another reason why we'll
>> need the volatile page cache involved in the persistent memory IO
>> path. It follows immediately from this that applicaitons will still
>> require fsync() and other data integrity operations because they
>> have no idea where the persistence domain boundary lives in the IO
>> stack.
>
>
> And my point, stated a few times now, is there should be a way for
> applications to discover the existence and characteristics of persistent
> memory being used in the system.

Agreed.  Or maybe just some very low-level library that exposes a more
useful interface (e.g. sync this domain) to applications.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
