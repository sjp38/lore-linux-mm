Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4566B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 19:28:39 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id jz11so3138009veb.39
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 16:28:39 -0700 (PDT)
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
        by mx.google.com with ESMTPS id ys8si43307veb.106.2014.03.26.16.28.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 16:28:38 -0700 (PDT)
Received: by mail-vc0-f178.google.com with SMTP id im17so3379333vcb.9
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 16:28:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrVoiFV29P9OfsdQgN7eon6JepCnkPGTCzaAotgUa2NexA@mail.gmail.com>
References: <20140326191113.GF9066@alap3.anarazel.de> <CALCETrUc1YvNc3EKb4ex579rCqBfF=84_h5bvbq49o62k2KpmA@mail.gmail.com>
 <20140326215518.GH9066@alap3.anarazel.de> <CALCETrVEjpFpKhY6=CEG-9Prm=uBDLS936imb=+hyWN4fXPjtg@mail.gmail.com>
 <alpine.DEB.2.02.1403261532360.2190@nftneq.ynat.uz> <CALCETrVoiFV29P9OfsdQgN7eon6JepCnkPGTCzaAotgUa2NexA@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 26 Mar 2014 16:28:18 -0700
Message-ID: <CALCETrWQhTodxYmmCPqqH0n3aD7dCj+_xOF-DL8SGGU0d4GpJg@mail.gmail.com>
Subject: Re: [Lsf] Postgresql performance problems with IO latency, especially
 during fsync()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Lang <david@lang.hm>
Cc: Andres Freund <andres@2ndquadrant.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>, rhaas@anarazel.de

On Wed, Mar 26, 2014 at 4:11 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Wed, Mar 26, 2014 at 3:35 PM, David Lang <david@lang.hm> wrote:
>> On Wed, 26 Mar 2014, Andy Lutomirski wrote:
>>
>>>>> I'm not sure I understand the request queue stuff, but here's an idea.
>>>>>  The block core contains this little bit of code:
>>>>
>>>>
>>>> I haven't read enough of the code yet, to comment intelligently ;)
>>>
>>>
>>> My little patch doesn't seem to help.  I'm either changing the wrong
>>> piece of code entirely or I'm penalizing readers and writers too much.
>>>
>>> Hopefully some real block layer people can comment as to whether a
>>> refinement of this idea could work.  The behavior I want is for
>>> writeback to be limited to using a smallish fraction of the total
>>> request queue size -- I think that writeback should be able to enqueue
>>> enough requests to get decent sorting performance but not enough
>>> requests to prevent the io scheduler from doing a good job on
>>> non-writeback I/O.
>>
>>
>> The thing is that if there are no reads that are waiting, why not use every
>> bit of disk I/O available to write? If you can do that reliably with only
>> using part of the queue, fine, but aren't you getting fairly close to just
>> having separate queues for reading and writing with such a restriction?
>>
>
> Hmm.
>
> I wonder what the actual effect of queue length is on throughput.  I
> suspect that using half the queue gives you well over half the
> throughput as long as the queue isn't tiny.
>
> I'm not so sure I'd go so far as having separate reader and writer
> queues -- I think that small synchronous writes should also not get
> stuck behind large writeback storms, but maybe that's something that
> can be a secondary goal.  That being said, separate reader and writer
> queues might solve the immediate problem.  It won't help for the case
> where a small fsync blocks behind writeback, though, and that seems to
> be a very common cause of Firefox freezing on my system.
>
> Is there an easy way to do a proof-of-concept?  It would be great if
> there was a ten-line patch that implemented something like this
> correctly enough to see if it helps.  I don't think I'm the right
> person to do it, because my knowledge of the block layer code is
> essentially nil.

I think it's at least a bit more subtle than this.  cfq distinguishes
SYNC and ASYNC, but very large fsyncs are presumably SYNC.  Deadline
pays no attention to rw flags.

Anyway, it seems like there's basically nothing prioritizing what
happens when the number of requests exceeds the congestion thresholds.
 I'd happily bet a beverage* that Postgres's slow requests are
spending an excessive amount of time waiting to get into the queue in
the first place.

* Since I'm back home now, any actual beverage transaction will be
rather delayed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
