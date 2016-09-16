Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7FBA6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 18:35:30 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id b133so57196590vka.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 15:35:30 -0700 (PDT)
Received: from www.courier-mta.com (www.courier-mta.com. [216.254.115.190])
        by mx.google.com with ESMTPS id p66si6458745qki.25.2016.09.16.15.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 15:35:29 -0700 (PDT)
References: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com> <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com> <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com> <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
Message-ID: <cone.1474065027.299244.29242.1004@monster.email-scan.com>
From: Sam Varshavchik <mrsam@courier-mta.com>
Subject: Re: [REGRESSION] =?UTF-8?Q?RLIMIT=5FDATA?= crashes named
Date: Fri, 16 Sep 2016 18:30:27 -0400
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Laura Abbott <labbott@redhat.com>, Brent <fix@bitrealm.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, =?UTF-8?Q?linux-mm=40kvack=2Eorg?= <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Linus Torvalds writes:

> On Fri, Sep 16, 2016 at 1:10 PM, Laura Abbott <labbott@redhat.com> wrote:
> >
> > As far as I can tell this isn't Fedora specific.
>
> Some googling does seem to say that "datalimit 20M" and "named.conf"
> ends up being some really old default that just gets endlessly copied.
>
> So no, it's not Fedora-specific per se.

I'll confirm that.

It's been sitting in my named.conf for at least ten years. I don't remember  
where it came from. The Google sources are very likely. I probably copied  
it, from some tutorial.

> But I suspect most people with a named.conf did either
>
>  (a) get it from their distro and didn't change it and so if the
> distro just updates theirs, things will automatically "just work"
>
>  (b) actually did write their own (or at least edited it), and knows
> what they are doing, and have absolutely no problem removing or
> updating that datalimit thing.

(b) in my case. Now that the root cause is mostly known, I'll just bump it  
up.

> The really annoying thing seems to be that the kernel message has been
> hidden too much. IOW, Sam in his bugzilla report clearly found the
> system messages with
>
>     Sep 10 07:38:23 shorty systemd-coredump: Process 1651 (named) of
> user 25 dumped core.
>
> but for some reason never noticed the kernel saying (quoting Jason):
>
>    mmap: named (593): VmData 27566080 exceed data ulimit 20971520.
> Update limits or use boot option ignore_rlimit_data
>
> at the same time.
>
> Ok, the kernel only says it *once*. Maybe Sam had it in his logs, but
> didn't notice the initial failure (which would have had the kernel
> message too), and he then looked at the logs for when he tried to
> re-start.

I still have this log file. Looking over it, this is indeed what happened.

> Or maybe the system logs don't have those kernel messages, which would
> be a disaster.
>
> So maybe we should just change the "pr_warn_once()" into
> "pr_warn_ratelimited()", except the default rate limits for that are
> wrong (we'd perhaps want something like "at most once every minute" or
> similar, while the default rate limits are along the lines of "max 10
> lines every 5 _seconds_").
>
> Sam, do you end up seeing the kernel warning in your logs if you just
> go back earlier in the boot?

Yes, I found it.

Sep 10 07:36:29 shorty kernel: mmap: named (1108): VmData 52588544 exceed  
data ulimit 20971520. Update limits or use boot option ignore_rlimit_data.

Now that I know what to search for: this appeared about 300 lines earlier in  
/var/log/messages.

When trying to figure out what's going on with named, searching backwards in  
time, and finding the logged segault @07:38:23, IIRC I only looked as far  
back until the @07:38:23 timestamp started, and did not see anything other  
the apparent segfault. Before that, /var/log/messages was full of other  
noise. The original named that was launched two minutes earlier was ancient  
history, by then.

All I saw was that named was apparently segfaulting after booting a new  
kernel. Ok, boot back to the previous kernel, search bugzilla to see if it  
was reported already, and, if not, create it yourself. That's what happened.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
