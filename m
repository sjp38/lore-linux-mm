Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id DFD986B0009
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 12:37:19 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so122259474wme.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 09:37:19 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id s125si19158412wmd.74.2016.02.14.09.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 09:37:18 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id a4so6874850wme.3
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 09:37:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160214165133.GB3965@htj.duckdns.org>
References: <145544094056.28219.12239469516497703482.stgit@zurg>
	<20160214165133.GB3965@htj.duckdns.org>
Date: Sun, 14 Feb 2016 20:37:18 +0300
Message-ID: <CALYGNiOpnVSpmL0smMu7xCT78GJ4J02LGeiuZBdVxROEpfrH+Q@mail.gmail.com>
Subject: Re: [PATCH RFC] Introduce atomic and per-cpu add-max and sub-min operations
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-arch <linux-arch@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Feb 14, 2016 at 7:51 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Konstantin.
>
> On Sun, Feb 14, 2016 at 12:09:00PM +0300, Konstantin Khlebnikov wrote:
>> bool atomic_add_max(atomic_t *var, int add, int max);
>> bool atomic_sub_min(atomic_t *var, int sub, int min);
>>
>> bool this_cpu_add_max(var, add, max);
>> bool this_cpu_sub_min(var, sub, min);
>>
>> They add/subtract only if result will be not bigger than max/lower that min.
>> Returns true if operation was done and false otherwise.
>
> If I'm reading the code right, all the above functions do is wrapping
> the corresponding cmpxchg implementations.  Given that most use cases
> would build further abstractions on top, I'm not sure how useful
> providing another layer of abstraction is.  For the most part, we
> introduce new per-cpu operations to take advantage of capabilities of
> underlying hardware which can't be utilized in a different way (like
> the x86 128bit atomic ops).

Yep, they are just abstraction around cmpxchg, as well as a half of atomic
operations. Probably some architectures could implement this differently.

This is basic block with clear interface which performs just one operaion.
without managing memory and logic behind it. Users often already have
per-cpu memory stuctures, so they don't need high level abstractrions
because this will waste memory for unneeded pointers. I think this new
abstraction could replace alot of opencoded hacks in common way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
