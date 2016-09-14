Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 573506B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 21:01:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id t7so6057978qkh.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 18:01:16 -0700 (PDT)
Received: from mail-yw0-x230.google.com (mail-yw0-x230.google.com. [2607:f8b0:4002:c05::230])
        by mx.google.com with ESMTPS id k189si671740ywb.476.2016.09.13.18.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 18:01:15 -0700 (PDT)
Received: by mail-yw0-x230.google.com with SMTP id i129so3227815ywb.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 18:01:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160913214244.GB5020@twins.programming.kicks-ass.net>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com>
 <20160913150554.GI2794@worktop> <CANrsvRNarrDejL_ju-X=MtiBbwG-u2H4TNsZ1i_d=3nbd326PQ@mail.gmail.com>
 <20160913193829.GA5016@twins.programming.kicks-ass.net> <20160913214244.GB5020@twins.programming.kicks-ass.net>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Wed, 14 Sep 2016 10:01:14 +0900
Message-ID: <CANrsvRM08k7auvhvC2EuEh_W_ydAN0rRFgMSN9fvW=cmVM6gJw@mail.gmail.com>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Sep 14, 2016 at 6:42 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Sep 13, 2016 at 09:38:29PM +0200, Peter Zijlstra wrote:
>
>> > > I _think_ you propose to keep track of all prior held locks and then use
>> > > the union of the held list on the block-chain with the prior held list
>> > > from the complete context.
>> >
>> > Almost right. Only thing we need to do to consider the union is to
>> > connect two chains of two contexts by adding one dependency 'b -> a'.
>>
>> Sure, but how do you arrive at which connection to make. The document is
>> entirely silent on this crucial point.
>>
>> The union between the held-locks of the blocked and prev-held-locks of
>> the release should give a fair indication I think, but then, I've not
>> thought too hard on this yet.
>
> s/union/intersection/
>
> those that are in both sets.

Precisely speaking, I introduces separate chains.

For example,

1. Held-locks of the blocked,
A -> B -> C (which original lockdep builds)

2. Prev-held-locks of the release
G -> H -> I (which original lockdep builds, too)

3. Cross chain (which I introduced newly)
C -> G

Then the 'A -> B -> C -> G -> H -> I' can be traversed
when bfs is performed.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
