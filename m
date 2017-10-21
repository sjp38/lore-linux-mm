Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0E06B0261
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 22:24:01 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j98so3454801lfi.0
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 19:24:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r76sor352001lja.96.2017.10.20.19.23.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 19:23:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1508529532.3029.15.camel@wdc.com>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
 <1508319532-24655-2-git-send-email-byungchul.park@lge.com>
 <1508455438.4542.4.camel@wdc.com> <alpine.DEB.2.20.1710200829340.3083@nanos> <1508529532.3029.15.camel@wdc.com>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Sat, 21 Oct 2017 11:23:58 +0900
Message-ID: <CANrsvRNnOp_rgEWG2FGg7qaEQi=yEyhiZkpWSW62w21BvJ9Shg@mail.gmail.com>
Subject: Re: [RESEND PATCH 1/3] completion: Add support for initializing
 completion with lockdep_map
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "hch@infradead.org" <hch@infradead.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "oleg@redhat.com" <oleg@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

On Sat, Oct 21, 2017 at 4:58 AM, Bart Van Assche <Bart.VanAssche@wdc.com> wrote:
> Sorry but I'm not sure that's the best possible answer. In my opinion
> avoiding that completion objects have dependencies on other lock objects,
> e.g. by avoiding to wait on a completion object while holding a mutex, is a
> far superior strategy over adding cross-release checking to completion
> objects. The former strategy namely makes it unnecessary to add
> cross-release checking to completion objects because that strategy ensures
> that these completion objects cannot get involved in a deadlock. The latter

It's true if we force it. But do you think it's possible?

> strategy can lead to false positive deadlock reports by the lockdep code,

What do you think false positives come from? It comes from assigning
lock classes falsely where we should more care, rather than lockdep code
itself. The same is applicable to cross-release.

> something none of us wants.
>
> A possible alternative strategy could be to enable cross-release checking
> only for those completion objects for which waiting occurs inside a critical
> section.

Of course, it already did. Cross-release doesn't consider any waiting
outside of critical sections at all, and it should do.

> As explained in another e-mail thread, unlike the lock inversion checking
> performed by the <= v4.13 lockdep code, cross-release checking is a heuristic
> that does not have a sound theoretical basis. The lock validator is an

It's not heuristic but based on the same theoretical basis as <=4.13
lockdep. I mean, the key basis is:

   1) What causes deadlock
   2) What is a dependency
   3) Build a dependency when identified

> important tool for kernel developers. It is important that it produces as few
> false positives as possible. Since the cross-release checks are enabled
> automatically when enabling lockdep, I think it is normal that I, as a kernel
> developer, care that the cross-release checks produce as few false positives
> as possible.

No doubt. That's why I proposed these patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
