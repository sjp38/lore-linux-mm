Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A35868E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:46:30 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a9so11632263pla.2
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 02:46:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id q15si13016959pgm.420.2018.12.18.02.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Dec 2018 02:46:29 -0800 (PST)
Date: Tue, 18 Dec 2018 11:46:22 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/6] psi: introduce psi monitor
Message-ID: <20181218104622.GB15430@hirez.programming.kicks-ass.net>
References: <20181214171508.7791-1-surenb@google.com>
 <20181214171508.7791-7-surenb@google.com>
 <20181217162223.GD2218@hirez.programming.kicks-ass.net>
 <CAJuCfpHGsDnE-eAHY1QnX949stA3cvNA=078q1swqVnz95aJfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpHGsDnE-eAHY1QnX949stA3cvNA=078q1swqVnz95aJfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com

On Mon, Dec 17, 2018 at 05:21:05PM -0800, Suren Baghdasaryan wrote:
> On Mon, Dec 17, 2018 at 8:22 AM Peter Zijlstra <peterz@infradead.org> wrote:

> > How well has this thing been fuzzed? Custom string parser, yay!
> 
> Honestly, not much. Normal cases and some obvious corner cases. Will
> check if I can use some fuzzer to get more coverage or will write a
> script.
> I'm not thrilled about writing a custom parser, so if there is a
> better way to handle this please advise.

The grammar seems fairly simple, something like:

  some-full = "some" | "full" ;
  threshold-abs = integer ;
  threshold-pct = integer, { "%" } ;
  threshold = threshold-abs | threshold-pct ;
  window = integer ;
  trigger = some-full, space, threshold, space, window ;

And that could even be expressed as two scanf formats:

 "%4s %u%% %u" , "%4s %u %u"

which then gets your something like:

  char type[5];

  if (sscanf(input, "%4s %u%% %u", &type, &pct, &window) == 3) {
  	// do pct thing
  } else if (sscanf(intput, "%4s %u %u", &type, &thres, &window) == 3) {
  	// do abs thing
  } else return -EFAIL;

  if (!strcmp(type, "some")) {
  	// some
  } else if (!strcmp(type, "full")) {
  	// full
  } else return -EFAIL;

  // do more

which seems like a lot less error prone. Alternatively you can use 4
formats:

  "some %u%% %u" "some %u %u"
  "full %u%% %u" "full %u %u"

and avoid the whole 'type' thing.
