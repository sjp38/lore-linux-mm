Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 300C26B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 16:32:40 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j128so79590275oif.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 13:32:40 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id t125si32258800oig.109.2016.09.16.13.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 13:32:39 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id w11so125504626oia.2
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 13:32:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com>
References: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com>
 <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com> <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 Sep 2016 13:32:38 -0700
Message-ID: <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sam Varshavchik <mrsam@courier-mta.com>, Brent <fix@bitrealm.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Sep 16, 2016 at 1:10 PM, Laura Abbott <labbott@redhat.com> wrote:
>
> As far as I can tell this isn't Fedora specific.

Some googling does seem to say that "datalimit 20M" and "named.conf"
ends up being some really old default that just gets endlessly copied.

So no, it's not Fedora-specific per se.

But I suspect most people with a named.conf did either

 (a) get it from their distro and didn't change it and so if the
distro just updates theirs, things will automatically "just work"

 (b) actually did write their own (or at least edited it), and knows
what they are doing, and have absolutely no problem removing or
updating that datalimit thing.

> I would like to see RLIMIT_DATA actually do something useful so worse
> case I'll figure out something to carry in Fedora and this thread
> can be an FYI for people googling.

Yeah, even if we only get a good hit for "named segmentation fault", I
guess that will help people a lot.

The really annoying thing seems to be that the kernel message has been
hidden too much. IOW, Sam in his bugzilla report clearly found the
system messages with

    Sep 10 07:38:23 shorty systemd-coredump: Process 1651 (named) of
user 25 dumped core.

but for some reason never noticed the kernel saying (quoting Jason):

   mmap: named (593): VmData 27566080 exceed data ulimit 20971520.
Update limits or use boot option ignore_rlimit_data

at the same time.

Ok, the kernel only says it *once*. Maybe Sam had it in his logs, but
didn't notice the initial failure (which would have had the kernel
message too), and he then looked at the logs for when he tried to
re-start.

Or maybe the system logs don't have those kernel messages, which would
be a disaster.

So maybe we should just change the "pr_warn_once()" into
"pr_warn_ratelimited()", except the default rate limits for that are
wrong (we'd perhaps want something like "at most once every minute" or
similar, while the default rate limits are along the lines of "max 10
lines every 5 _seconds_").

Sam, do you end up seeing the kernel warning in your logs if you just
go back earlier in the boot?

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
