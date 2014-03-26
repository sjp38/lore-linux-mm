Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE676B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 18:35:55 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so2562160pbb.31
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 15:35:55 -0700 (PDT)
Received: from bifrost.lang.hm (mail.lang.hm. [64.81.33.126])
        by mx.google.com with ESMTPS id h3si7570paw.373.2014.03.26.15.35.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 15:35:54 -0700 (PDT)
Date: Wed, 26 Mar 2014 15:35:42 -0700 (PDT)
From: David Lang <david@lang.hm>
Subject: Re: [Lsf] Postgresql performance problems with IO latency, especially
 during fsync()
In-Reply-To: <CALCETrVEjpFpKhY6=CEG-9Prm=uBDLS936imb=+hyWN4fXPjtg@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1403261532360.2190@nftneq.ynat.uz>
References: <20140326191113.GF9066@alap3.anarazel.de> <CALCETrUc1YvNc3EKb4ex579rCqBfF=84_h5bvbq49o62k2KpmA@mail.gmail.com> <20140326215518.GH9066@alap3.anarazel.de> <CALCETrVEjpFpKhY6=CEG-9Prm=uBDLS936imb=+hyWN4fXPjtg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andres Freund <andres@2ndquadrant.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>, rhaas@anarazel.de

On Wed, 26 Mar 2014, Andy Lutomirski wrote:

>>> I'm not sure I understand the request queue stuff, but here's an idea.
>>>  The block core contains this little bit of code:
>>
>> I haven't read enough of the code yet, to comment intelligently ;)
>
> My little patch doesn't seem to help.  I'm either changing the wrong
> piece of code entirely or I'm penalizing readers and writers too much.
>
> Hopefully some real block layer people can comment as to whether a
> refinement of this idea could work.  The behavior I want is for
> writeback to be limited to using a smallish fraction of the total
> request queue size -- I think that writeback should be able to enqueue
> enough requests to get decent sorting performance but not enough
> requests to prevent the io scheduler from doing a good job on
> non-writeback I/O.

The thing is that if there are no reads that are waiting, why not use every bit 
of disk I/O available to write? If you can do that reliably with only using part 
of the queue, fine, but aren't you getting fairly close to just having separate 
queues for reading and writing with such a restriction?

> As an even more radical idea, what if there was a way to submit truly
> enormous numbers of lightweight requests, such that the queue will
> give the requester some kind of callback when the request is nearly
> ready for submission so the requester can finish filling in the
> request?  This would allow things like dm-crypt to get the benefit of
> sorting without needing to encrypt hundreds of MB of data in advance
> of having that data actually be to the backing device.  It might also
> allow writeback to submit multiple gigabytes of writes, in arbitrarily
> large pieces, but not to need to pin pages or do whatever expensive
> things are needed until the IO actually happens.

the problem with a callback is that you then need to wait for that source to get 
the CPU and finish doing it's work. What happens if that takes long enough for 
you to run out of data to write? And is it worth the extra context switches to 
bounce around when the writing process was finished with that block already.

David Lang

> For reference, here's my patch that doesn't work well:
>
> diff --git a/block/blk-core.c b/block/blk-core.c
> index 4cd5ffc..c0dedc3 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -941,11 +941,11 @@ static struct request *__get_request(struct request_list *
>        }
>
>        /*
> -        * Only allow batching queuers to allocate up to 50% over the defined
> -        * limit of requests, otherwise we could have thousands of requests
> -        * allocated with any setting of ->nr_requests
> +        * Only allow batching queuers to allocate up to 50% of the
> +        * defined limit of requests, so that non-batching queuers can
> +        * get into the queue and thus be scheduled properly.
>         */
> -       if (rl->count[is_sync] >= (3 * q->nr_requests / 2))
> +       if (rl->count[is_sync] >= (q->nr_requests + 3) / 4)
>                return NULL;
>
>        q->nr_rqs[is_sync]++;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
