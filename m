Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8E06B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 14:11:05 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id m1so11677784oag.35
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 11:11:04 -0700 (PDT)
Received: from mail-oa0-x236.google.com (mail-oa0-x236.google.com [2607:f8b0:4003:c02::236])
        by mx.google.com with ESMTPS id u10si15717361obn.33.2014.04.01.11.11.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 11:11:04 -0700 (PDT)
Received: by mail-oa0-f54.google.com with SMTP id n16so11701939oag.13
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 11:11:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
 <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net> <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org>
 <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 1 Apr 2014 14:10:43 -0400
Message-ID: <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Apr 1, 2014 at 1:01 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> On Mon, 2014-03-31 at 17:05 -0700, Andrew Morton wrote:
>> On Mon, 31 Mar 2014 16:25:32 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
>>
>> > On Mon, 2014-03-31 at 16:13 -0700, Andrew Morton wrote:
>> > > On Mon, 31 Mar 2014 15:59:33 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
>> > >
>> > > > >
>> > > > > - Shouldn't there be a way to alter this namespace's shm_ctlmax?
>> > > >
>> > > > Unfortunately this would also add the complexity I previously mentioned.
>> > >
>> > > But if the current namespace's shm_ctlmax is too small, you're screwed.
>> > > Have to shut down the namespace all the way back to init_ns and start
>> > > again.
>> > >
>> > > > > - What happens if we just nuke the limit altogether and fall back to
>> > > > >   the next check, which presumably is the rlimit bounds?
>> > > >
>> > > > afaik we only have rlimit for msgqueues. But in any case, while I like
>> > > > that simplicity, it's too late. Too many workloads (specially DBs) rely
>> > > > heavily on shmmax. Removing it and relying on something else would thus
>> > > > cause a lot of things to break.
>> > >
>> > > It would permit larger shm segments - how could that break things?  It
>> > > would make most or all of these issues go away?
>> > >
>> >
>> > So sysadmins wouldn't be very happy, per man shmget(2):
>> >
>> > EINVAL A new segment was to be created and size < SHMMIN or size >
>> > SHMMAX, or no new segment was to be created, a segment with given key
>> > existed, but size is greater than the size of that segment.
>>
>> So their system will act as if they had set SHMMAX=enormous.  What
>> problems could that cause?
>
> So, just like any sysctl configurable, only privileged users can change
> this value. If we remove this option, users can theoretically create
> huge segments, thus ignoring any custom limit previously set. This is
> what I fear. Think of it kind of like mlock's rlimit. And for that
> matter, why does sysctl exist at all, the same would go for the rest of
> the limits.

Hmm. It's hard to agree. AFAIK 32MB is just borrowed from other Unix
and it doesn't respect any Linux internals. Look, non privileged user
can user unlimited memory, at least on linux. So I don't find out any
difference between regular anon and shmem.

So, I personally like 0 byte per default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
