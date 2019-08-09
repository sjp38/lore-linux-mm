Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8DE7C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79AE521743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:15:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="MkkcGqzT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79AE521743
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D8DF6B0005; Fri,  9 Aug 2019 18:15:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 089DC6B0006; Fri,  9 Aug 2019 18:15:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E925E6B0007; Fri,  9 Aug 2019 18:15:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id BBFAD6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:15:32 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id t26so1217464otm.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:15:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JkkxpeYogxXt1mAu9NfkWOylpyT0aB0+PMOJ/u4YL0k=;
        b=bMiEeSjXmp4lOfRUcyO9IPuiHGJ7FxB9EdL2y64R34qHaZQANQvf76LIbK6cx4iZio
         GvucgM6eo0cqITPJiVBbMCOl2DtghTkFSd7HQcyGahlCR2XLiJUavTSrhnRN/At+7vVt
         CqYh+Nf40qQtZ1xh1OKx3hMpGbXRt9EnpOhqy8iuJzp1DbZX/Tj+VHCugqH0RfcdFi2x
         5fMia9EO6034rCVF6FpBfmlg3gHQSj/NuHIW+vrjD5LeJUJxJJjQODE22LqK8cUxAxgX
         reCxo3F3v+g+yBYypGJgWsvLNcRll1+3C2OAXggiS1/MC1eYtqlN0ptuIc8IlLgQKLm+
         uxaw==
X-Gm-Message-State: APjAAAVuURjE8p4PHw0f++b761MTGPgPSkEXM6jwlAbIVJLqrHFPdDU6
	fyHdRkjn6dem3avmYsJ8fdl2F1MaIuOCYIOO43djzml06ggYabyYR1XMhyZZogd4Opy1RtIZhBL
	WbGxC21ojC9TxHadBM8mEpYt5bwbUFHq46mc6zuCwGoDqRXg2cvbLGetVuj5bLGARnUSbtNxpsx
	mHYfQ/fKT00d7XEwfaZVYefoQumlQ0s3PzatAUigdH8q/9HefJGSKf1JsHMIh7QZY0r8wMsO3ig
	whSrhR5mtDmmu9qXSZVOYEeUEs2iYHQ62grGlyvTjL1GQE+XrU=
X-Received: by 2002:a6b:7401:: with SMTP id s1mr21579292iog.67.1565388932376;
        Fri, 09 Aug 2019 15:15:32 -0700 (PDT)
X-Received: by 2002:a6b:7401:: with SMTP id s1mr21579170iog.67.1565388930954;
        Fri, 09 Aug 2019 15:15:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565388930; cv=none;
        d=google.com; s=arc-20160816;
        b=0Yw9R1QwPnFR8rKdDIeyz/HH9dJrX20sU/4wKA9XcSCyHm8azTvq7yG/objTYHcPFa
         4GRmKsgAzlIJ14ESYRFvQv5L5+mfZBYMc0Tgdbx89dTol92VwaVDh59qQS93PmCRbn4h
         4i6W/r8YnuxRCCXaMlHRyXfWClZJ0Ac2GMnqw/pTIBmLySC1WLOOM1XbctvXpt0uamlz
         jmp3iPBFN9xwIHzACdjweJ2iiOvHj4gWAEQmYz4QXPZHskbX7TuIBN/HZfEsFTIs0n2+
         7sxsZmGa8BhPwT6QBRCWHxH1RnlJZn/O6wJF2IrC+Boo49SQkR3udbMvvkfKaID1C2mk
         Qzpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JkkxpeYogxXt1mAu9NfkWOylpyT0aB0+PMOJ/u4YL0k=;
        b=MjGcKuJQz8TPdpj78QYLC5q9g9GaByswy0kBf91TDGZALVb0C07Bx45TGo1gJhRDxz
         o8c4w7LZrEqiihYRjOnCfJ4GsBxclog0Z2P8O2DVm/xz3v+Nb0ocX1pCXTEZceP46FuX
         EpWXLKquFsyjP9GfCKsKQlawhuCugkNZHPzaqKP5SoszqoCLZGpInUNhnpXaMSyI5+eY
         bfow6vmdBZ5adTPPO6K+g2/xI5OkriGj7l3xh+fYnwWa524R0y47KsnAAIcc9F9Umdyl
         i9T4qZ3WuKvCWKml3OMEiPJtrwnCSAXpcOTRQtH/UAvOiFp398MOh2kY1yPEGbmese1u
         oHUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@arista.com header.s=googlenew header.b=MkkcGqzT;
       spf=pass (google.com: domain of echron@arista.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=echron@arista.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=arista.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t7sor6491353ioi.148.2019.08.09.15.15.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 15:15:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of echron@arista.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@arista.com header.s=googlenew header.b=MkkcGqzT;
       spf=pass (google.com: domain of echron@arista.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=echron@arista.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=arista.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JkkxpeYogxXt1mAu9NfkWOylpyT0aB0+PMOJ/u4YL0k=;
        b=MkkcGqzTu3e9mcxM7I4NW6mUWWhZ/xFNhvsFLKBQQLXfMZWBRcxGmVcNh3XUL5lIjE
         wyJ5H1TvOOD2eLuVSubZek/sJPiyn0u/C8yRUcwtvTVaq64wb7dGK7Y8rlhdgDmnOJbP
         IxYRa7bWnYsBNeVd3NCncS6WsbV/forkBBx1tLN5RcAeMOjXIbiIFy90qn8opVVOInln
         /c+vUwrt2wjYLCSGZ5BpIpXegEF3RQF+MuFTK8Ri7xBEUI0mCxrnd5/Yrq4hwyDW0Z/l
         nWXm1uVsqMTlfWLFcRvpBZjZmborq+Z3hhOf9Rm38atGeHZ7gZWOAMFe27errm+ALtdQ
         OWBw==
X-Google-Smtp-Source: APXvYqygiWAvzs+XwfWDcS9/U4eJkrGFRaRPRPl2jO/Nf5OVj6YjcXANa+2MEs1vWxo/RfkPYDXpisH2fyhFzzNnBVM=
X-Received: by 2002:a6b:fb09:: with SMTP id h9mr5161130iog.15.1565388930450;
 Fri, 09 Aug 2019 15:15:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190808183247.28206-1-echron@arista.com> <20190808185119.GF18351@dhcp22.suse.cz>
 <CAM3twVT0_f++p1jkvGuyMYtaYtzgEiaUtb8aYNCmNScirE4=og@mail.gmail.com>
 <20190808200715.GI18351@dhcp22.suse.cz> <CAM3twVS7tqcHmHqjzJqO5DEsxzLfBaYF0FjVP+Jjb1ZS4rA9qA@mail.gmail.com>
 <20190809064032.GJ18351@dhcp22.suse.cz>
In-Reply-To: <20190809064032.GJ18351@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Fri, 9 Aug 2019 15:15:18 -0700
Message-ID: <CAM3twVRCTLdn+Lhcr+4ZdY3nYVvXFe1O19UR9H121W34H=oV7g@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add killed process selection information
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-CLOUD-SEC-AV-Info: arista,google_mail,monitor
X-CLOUD-SEC-AV-Sent: true
X-Gm-Spam: 0
X-Gm-Phishy: 0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry about top posting, responses inline.

On Thu, Aug 8, 2019 at 11:40 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> [Again, please do not top post - it makes a mess of any longer
> discussion]
>
> On Thu 08-08-19 15:15:12, Edward Chron wrote:
> > In our experience far more (99.9%+) OOM events are not kernel issues,
> > they're user task memory issues.
> > Properly maintained Linux kernel only rarely have issues.
> > So useful information about the killed task, displayed in a manner
> > that can be quickly digested, is very helpful.
> > But it turns out the totalpages parameter is also critical to make
> > sense of what is shown.
>
> We already do print that information (see mem_cgroup_print_oom_meminfo
> resp. show_mem).
>
> > So if we report the fooWidget task was using ~15% of memory (I know
> > this is just an approximation but it is often an adequate metric) we
> > often can tell just from that the number is larger than expected so we
> > can start there.
> > Even though the % is a ballpark number, if you are familiar with the
> > tasks on your system and approximately how much memory you expect them
> > to use you can often tell if memory usage is excessive.
> > This is not always the case but it is a fair amount of the time.
> > So the % of memory field is helpful. But we've found we need totalpages as well.
> > The totalpages effects the % of memory the task uses.
>
> Is it too difficult to calculate that % from the data available in the
> existing report? I would expect this would be a quite simple script
> which I would consider a better than changing the kernel code.
>

Depending on your environment the answer is yes, we don't have the full
/var/log/messages (dmesg buffer) readily available so it can be painful.

If you live in the data center world with large numbers of servers and
switches it's very common that you are sent select messages on your
laptop or phone because you can't possibly log in and check all of your
systems.

Logs get moved off servers and in some cases the servers run diskless
and the logs are sent through the network else where.

So it is optimal if you only have to go and find the correct log and search
or run your script(s) when you absolutely need to, not on every OOM event.

That is the whole point of triage and triage is easier when you have
relevant information to decide which events require action and with what
priority.

The OOM Killed message is the one message that we have go to
the console and or is sent as SNMP alert to the Admin to let the
Admin know that a server or switch has suffered a low memory OOM
event.

Maybe a few examples would be helpful to show why the few extra
bits of information would be helpful in such an environment.

For example if we see serverA and serverB are taking oom events
with the fooWidget being killed, something along the lines of
the following you will get message likes this:

Jul 21 20:07:48 serverA kernel: Out of memory: Killed process 2826
 (fooWidget) total-vm:10493400kB, anon-rss:10492996kB, file-rss:128kB,
 shmem-rss:0kB memory-usage:32.0% oom_score: 320 oom_score_adj:0
 total-pages: 32791748kB

Jul 21 20:13:51 serverB kernel: Out of memory: Killed process 2911
 (fooWidget) total-vm:11149196kB, anon-rss:11148508kB, file-rss:128kB,
 shmem-rss:0kB memory-usage:34.0% oom_score: 340 oom_score_adj:0
 total-pages: 32791748kB

It is often possible to recognize that fooWidget is using more memory than
expected on those systems and you can act on that possibly without ever
having to hunt down the log and run a script or otherwise analyze the
log. The % of memory and memory size can often be helpful to understand
if the numbers look reasonable or not. Maybe the application was updated
on just the those systems which explains why we don't see issues on the
other servers running that application, possible application memory leak.

Another example of an application being targeted where the extra
information is helpful:

Aug  6 09:37:21 serverC kernel: Killed process 7583
(fooWidget) total-vm:528408kB, anon-rss:527144kB, file-rss:32kB,
shmem-rss:0kB, memory-usage:1.6% oom_score:16 oom_score_adj:0
total-pages: 32579088kB

Here the fooWidget process is only using about ~1.6% of the memory
resources. Note that is has zero oom_score_adj and that Linux
calculated the oom_score to be 16 so no boosts the oom_score of
16 was the highest memory consuming process on the system.
If that is a reasonable size for this application, we know that
if we want to debug this further we'll need to access the log in
this case. Either we have a number of applications consuming enough
memory to drive a low memory OOM event or a process consuming
more memory has an OOM adjust that lowers it's score and avoids
making it a target but may help to drive the system to OOM.
Again here the information provided was useful to provide a quick
triage of the OOM event and we can act accordingly.

You can also imagine that if for example systemd-udev gets OOM killed,
well that should really grab your attention:

Jul 21 20:08:11 serverX kernel: Out of memory: Killed process 2911
 (systemd-udevd) total-vm:83128kB, anon-rss:80520kB, file-rss:128kB,
 shmem-rss:0kB memory-usage:0.1% oom_score: 1001 oom_score_adj:1000
 total-pages: 8312512kB

Here we see an obvious issue: systemd-udevd is a critical system app
and it should not have an oom_score_adj: 1000 that clearly has been changed
it should be -1000. So we'll need to track down what happened there.
Also this is an 8GB system so it may be running some low priority offload
work for example, so we may not need to prioritize finding out why the
system ran low on memory, though we will want to try and track down
why the oom_score_adj was changed from unkillable to most favored.
Possibly a script or command error.

I can give you additional examples of cases where 1st order triage
of OOM events are aided by having the additional information present
on the OOM Kill message if you need them to justify adding these
fields.

> [...]
> > The oom_score tells us how Linux calculated the score for the task,
> > the oom_score_adj effects this so it is helpful to have that in
> > conjunction with the oom_score.
> > If the adjust is high it can tell us that the task was acting as a
> > canary and so it's oom_score is high even though it's memory
> > utilization can be modest or low.
>
> I am sorry but I still do not get it. How are you going to use that
> information without seeing other eligible tasks. oom_score is just a
> normalized memory usage + some heuristics potentially (we have given a
> discount to root processes until just recently). So this value only
> makes sense to the kernel oom killer implementation. Note that the
> equation might change in the future (that has happen in the past several
> times) so looking at the value in isolation might be quite misleading.

We've been through the change where oom_scores went from -17 to 16
to -1000 to 1000. This was the change David Rientjes from Google made
back around 2010.

This was not a problem for us then and if you change again in the future
(though the current implementation seems quite reasonable) it shouldn't
be an issue for us going forward or for anyone else that can use the
additional information in the OOM Kill message we're proposing. Here
is why, looking at the proposed message:

Jul 21 20:07:48 yoursystem kernel: Out of memory: Killed process 2826
 (processname) total-vm:1056800kB, anon-rss:1052784kB, file-rss:4kB,
 shmem-rss:0kB memory-usage:3.2% oom_score:1032 oom_score_adj:1000
 total-pages: 32791748kB

Let me go through each field again, apologies for stating much that
you already know, but just to be clear:

oom_score_adj: Useful to document the adjustment at the time of the OOM
                          event. Also useful in helping to document
the oom_score.
                          Really should have been included from day
one in my opinion.
oom_score: The value, using your internal algorithm - documented with
                    source code, so its no secret, and is used to
select the task
                    to kill on the OOM event. Having this and the % of
memory used
                    tells us whether any additional adjustments were made to the
                    process. As you can see from the sample messages that I've
                    given: oom_score is % of memory, plus (+-
adjustment value)
                               + any internal adjustment.
                   Since David's implementation became the OOM algorithm
                   there was only one such adjustment the 3% root oom_score
                   reduction. That was added and then removed. If it came
                   back or others were added it would be reflected in the
                   oom_score. That is why having oom_score and  % memory
                   together would be quite helpful.
% memory: Simple to calculate for the kernel at the time of the OOM
                    event this documents how much memory the task was
                    using and is easier for humans to read and digest than
                    total-vm:1056800kB, anon-rss:1052784kB, file-rss:4kB,
                    shmem-rss:0kB though these fields are useful to know
                    Strictly speaking if you provide the totalpages in the
                    output we can calculate the % of memory used except
                    that oom_badness calculate this as rss + pte + swap
                    and that is not exactly what you provide in the kill
                    message. Since oom_badness calculates this and
                    there is little overhead in printing it it would better to
                    have the kernel print it. If the calculation changes
                    for some reason then it would print the value it
                   calculates. Knowing how much memory a task was
                   using seems quite valuable to an algorithm like
                   OOM so it seems unlikely that it won't matter.
totalpages: Gives the size of the memory+swap (if any) at the
                   time event. Quite useful to have that with the
                   kill message and it is readily available.

That's all we're asking. I hope I have explained why it is useful to
have these values with the kill message. Gosh, all the fields you
print are included in the OOM output, assuming you print all the
per task information, you could remove them and make the same
argument your making to me now, those are printed somewhere
else (probably). However, we would prefer you keep them in the
message and add the additional fields if possible.

Now what about the oom_score value changing that you mentioned?
What if you toss David's OOM Kill algorithm for a new algorithm?
That could happen. What happens to the message and how do we
tell things have changed?

A different oom_score requires a different oom adjustment variable.
I hope we can agree on that and history supports this.

As you recall when David's algorithm was brought in, the Kernel OOM
team took good care of us. They added a new adjustment value:
oom_score_adj. As you'll recall the previous oom adjustment variable
was oom_adj. To keep user level code from breaking the Kernel OOM
developers provided a conversion so that if your application set
oom_adj = -17 the Linux OOM code internally set oom_score_adj = -1000.
They had a conversion that handled all the values. Eventually the
deprecated oom_adj field was removed, but it was around for several years.

It is true that you can change the OOM algorithm but not
overnight. If it does happen when you update the code in the kernel
you can change the oom_score_adj: header to be oom_new_adj: or
whatever you wise guys and gals decide to call it. This will tell us
definitively what the oom_score that you're printing means, because
we know which version of the Linux kernel we're running, you told us
by the naming in this message. If small adjustments occur like the
3% reduction in oom_score that was present for a while for tasks with
root privilege (but it didn't last), that will be included in the oom_score
and since we'd also like % of memory, it won't confuse anything.

Further, you export oom_score through the /proc/pid/oom_score
interface. How the score is calculated could change but it is
accessible. It's accessible for a reason, it's useful to know how
the OOM algorithm scores a task and that can be used to help
set appropriate oom adjustment values. This because what the
oom_score means is in fact well documented. It needs to.
Otherwise, the oom adjustment value becomes impossible to
use intelligently. Thanks to David Rientjes et al for making this so.

One of the really nice design points of David Rientjes implementation
is that it is very straight forward to use and understand. So hopefully
if there is a change in the future it's to something that is just as easy
to use and to understand.

>
> I can see some point in printing oom_score_adj, though. Seeing biased -
> one way or the other - tasks being selected might confirm the setting is
> reasonable or otherwise (e.g. seeing tasks with negative scores will
> give an indication that they might be not biased enough). Then you can
> go and check the eligible tasks dump and see what happened. So this part
> makes some sense to me.

Agreed, the oom_score_adj is sorely needed and should be included.

In Summary:
----------------
I hope I have presented a reasonable enough argument for the proposed
additional parameters.

If you need more information I will be oblige as quickly as I can.

Of course it is your call what you are willing to include.
Any of the parameters suggested would be useful and we'll gladly take whatever
you can allow.

Again, Thank-you for your time and your consideration.

Best wishes,

-Edward Chron
Arista Networks

> --
> Michal Hocko
> SUSE Labs

