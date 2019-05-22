Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E9A3C072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 04:15:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1C9920862
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 04:15:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BjbQB6LH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1C9920862
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47ED06B0003; Wed, 22 May 2019 00:15:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42EC76B0006; Wed, 22 May 2019 00:15:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F84A6B0007; Wed, 22 May 2019 00:15:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF8F36B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 00:15:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y22so1599048eds.14
        for <linux-mm@kvack.org>; Tue, 21 May 2019 21:15:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=W1mMHFdH8LdhNbuZ9MIB8WQUKOtIKbe7nHI7E1ocWhU=;
        b=HucNDJxDZssxJo8hHxoghVRTcOsXojrjoT/1x/bUSaKoTw0CnFcMKnDihQXpiGG9sy
         wdMGzbwSx/a+U+3nos2KxgjV0VnOMors68924jLH3lusRqEa/m0N0dfQh8ra4ePpNzGN
         1KX+seGw6Z68InXu/Cb8u9uigXBeffmIvhStnv4bG7uBIGXx3o3qg4TKlFV9dDNg8vYG
         lzFz0RmHTLrSzsxBYfBMMifjk0dDoZhYYp7bVNP0JOENT58Y588m4aea1wsJ6dSqT7OF
         X6PnsULamsYbB3XqVMwEI6yX3n1G1z2K43VUjDE/pxT+WXF0j/uOVQAM+4TY0UddKhXk
         +jPQ==
X-Gm-Message-State: APjAAAWzEJY4FazY2GyR033F5UrTqfUPnwyBwfr7ZgTwyjq7pDJolsK4
	S9oYUayU7rwy6rPTB6CNs/0TIfIQnU3FkD5MJdF9+jFrgz9vjKWsXOKyUbekTACaPywhVcAarMo
	3Bio5Pathx0TREt9q75ZwxpoSH+/bAJCFWMwbIyXGJPFfdU6aaoor4vKZ7Bp3y5vOdQ==
X-Received: by 2002:a17:906:60c9:: with SMTP id f9mr32647897ejk.83.1558498549236;
        Tue, 21 May 2019 21:15:49 -0700 (PDT)
X-Received: by 2002:a17:906:60c9:: with SMTP id f9mr32647856ejk.83.1558498548251;
        Tue, 21 May 2019 21:15:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558498548; cv=none;
        d=google.com; s=arc-20160816;
        b=Byl5OIGB1dhaIV77HA5AJGwljCZurlnfqr4ientDbVOOdQO0g91s9l8shFHsr9lN2G
         gEc+FTSx+Zv73OjKkvK2nUnzymWQWgxX9zG53rMiOaPc0Hr6pWDNYNmXK62/XgxwgE+C
         RJB2dQ09K8/6WHg+9BXNWZQcj7Ak/lEWKpY68/kQKpLcFxwlkTsvfBUAYSyNO6GZSlAf
         +J8etgiZufftN2ZfNE+JQxkkpr7ESg8YvIR1PrqELwY/qNraJ7ZHaBbMu7+Nq+xElMcZ
         k5tLW1uLjlf5xfD2oX33RV1HQPDBy99fYEK2y+uJ0AGG8UMsZy0/sNlk/oifK9+yD10Q
         hVyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=W1mMHFdH8LdhNbuZ9MIB8WQUKOtIKbe7nHI7E1ocWhU=;
        b=Z0WH1Zux5ADai3Gdq0KCyRbu4FJ6hn5Gt52QPz5889PYbk/vBn+P3An2A7vPI4EzqQ
         DnQOKvjqGcYi3tEVKsHNROiknOZ1UYGBzeY1eTQ7J/9TdJt2GDW3O36p8ikDoW0NLMs2
         HasO1FFuwuuHkKoAk0hL55TG1MrQ8lKA1Tqwe5ZZauj4RfD1hMde6eBWp/k2+rhCIhk3
         aiEXKW7LHFQJdgrAtbftnHkeggRboycEstU1DuzbYhgTJxWIcb3ig3SjzIk39os6W2jB
         M5tUntmdUB35keLCI47b/Lh5CZ3m6+whidwTCHJfWoNCZqjATi8bWzmupyivauK23Vd5
         wZFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BjbQB6LH;
       spf=pass (google.com: domain of bgeffon@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=bgeffon@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x47sor3458302edd.22.2019.05.21.21.15.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 21:15:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of bgeffon@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BjbQB6LH;
       spf=pass (google.com: domain of bgeffon@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=bgeffon@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=W1mMHFdH8LdhNbuZ9MIB8WQUKOtIKbe7nHI7E1ocWhU=;
        b=BjbQB6LHoryPsCMVPN20Agf2ckcyZC7WPyl08x5tV34oEbj3E07oFCSXmENbPmsmhN
         lyKJBRfgsesKvqq+kZ8ZGl/geczara/vEuYSRaNvT+WkWfeuvddNb4rCW5FgiwcJG/Qe
         CN3U7xO3gpJq1DtLFT0VdPHzakxdLupuYUqeQfezNP3ssIl5tp+wiBNEM8Yurg8vaY23
         PTplyRYhCqhknMMZM3PrLFCupCULuvV9EOuKG+E2FtNZPbp5Bm4T1OavMv/MzWv/E6v0
         lax8lLL6mh3dWhw/Ie5yazQaoRUeO53cf080lBxqseSOw9wMmX07xGJv7vRT5wyRE8LR
         PMxw==
X-Google-Smtp-Source: APXvYqxJhMqFRLenfGMI6HGPIZeR5VSrReXqyJ/JYaYdJZ/aW2exvz/AJSqYJLtyqFcP6rbN1bUsBuH8aN818mOU/Fw=
X-Received: by 2002:a50:b487:: with SMTP id w7mr88482538edd.45.1558498547212;
 Tue, 21 May 2019 21:15:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <dbe801f0-4bbe-5f6e-9053-4b7deb38e235@arm.com>
 <CAEe=Sxka3Q3vX+7aWUJGKicM+a9Px0rrusyL+5bB1w4ywF6N4Q@mail.gmail.com>
 <1754d0ef-6756-d88b-f728-17b1fe5d5b07@arm.com> <CALvZod6ioRxSi7tHB-uSTxN1-hsxD+8O3mfFAjaqdsimjUVmcw@mail.gmail.com>
In-Reply-To: <CALvZod6ioRxSi7tHB-uSTxN1-hsxD+8O3mfFAjaqdsimjUVmcw@mail.gmail.com>
From: Brian Geffon <bgeffon@google.com>
Date: Tue, 21 May 2019 21:15:20 -0700
Message-ID: <CADyq12xwNwYOXeFadR+ibnaBtdDJHhA1Pgk4Wz=rz0DY7V-j5g@mail.gmail.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Shakeel Butt <shakeelb@google.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Tim Murray <timmurray@google.com>, 
	Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Daniel Colascione <dancol@google.com>, Sonny Rao <sonnyrao@google.com>, linux-api@vger.kernel.org
Content-Type: multipart/alternative; boundary="0000000000004a8092058972388d"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000004a8092058972388d
Content-Type: text/plain; charset="UTF-8"

To expand on the ChromeOS use case we're in a very similar situation to
Android. For example, the Chrome browser uses a separate process for each
individual tab (with some exceptions) and over time many tabs remain open
in a back-grounded or idle state. Given that we have a lot of information
about the weight of a tab, when it was last active, etc, we can benefit
tremendously from per-process reclaim. We're working on getting real world
numbers but all of our initial testing shows very promising results.

On Tue, May 21, 2019 at 5:57 AM Shakeel Butt <shakeelb@google.com> wrote:

> On Mon, May 20, 2019 at 7:55 PM Anshuman Khandual
> <anshuman.khandual@arm.com> wrote:
> >
> >
> >
> > On 05/20/2019 10:29 PM, Tim Murray wrote:
> > > On Sun, May 19, 2019 at 11:37 PM Anshuman Khandual
> > > <anshuman.khandual@arm.com> wrote:
> > >>
> > >> Or Is the objective here is reduce the number of processes which get
> killed by
> > >> lmkd by triggering swapping for the unused memory (user hinted)
> sooner so that
> > >> they dont get picked by lmkd. Under utilization for zram hardware is
> a concern
> > >> here as well ?
> > >
> > > The objective is to avoid some instances of memory pressure by
> > > proactively swapping pages that userspace knows to be cold before
> > > those pages reach the end of the LRUs, which in turn can prevent some
> > > apps from being killed by lmk/lmkd. As soon as Android userspace knows
> > > that an application is not being used and is only resident to improve
> > > performance if the user returns to that app, we can kick off
> > > process_madvise on that process's pages (or some portion of those
> > > pages) in a power-efficient way to reduce memory pressure long before
> > > the system hits the free page watermark. This allows the system more
> > > time to put pages into zram versus waiting for the watermark to
> > > trigger kswapd, which decreases the likelihood that later memory
> > > allocations will cause enough pressure to trigger a kill of one of
> > > these apps.
> >
> > So this opens up bit of LRU management to user space hints. Also because
> the app
> > in itself wont know about the memory situation of the entire system, new
> system
> > call needs to be called from an external process.
> >
> > >
> > >> Swapping out memory into zram wont increase the latency for a hot
> start ? Or
> > >> is it because as it will prevent a fresh cold start which anyway will
> be slower
> > >> than a slow hot start. Just being curious.
> > >
> > > First, not all swapped pages will be reloaded immediately once an app
> > > is resumed. We've found that an app's working set post-process_madvise
> > > is significantly smaller than what an app allocates when it first
> > > launches (see the delta between pswpin and pswpout in Minchan's
> > > results). Presumably because of this, faulting to fetch from zram does
> >
> > pswpin      417613    1392647     975034     233.00
> > pswpout    1274224    2661731    1387507     108.00
> >
> > IIUC the swap-in ratio is way higher in comparison to that of swap out.
> Is that
> > always the case ? Or it tend to swap out from an active area of the
> working set
> > which faulted back again.
> >
> > > not seem to introduce a noticeable hot start penalty, not does it
> > > cause an increase in performance problems later in the app's
> > > lifecycle. I've measured with and without process_madvise, and the
> > > differences are within our noise bounds. Second, because we're not
> >
> > That is assuming that post process_madvise() working set for the
> application is
> > always smaller. There is another challenge. The external process should
> ideally
> > have the knowledge of active areas of the working set for an application
> in
> > question for it to invoke process_madvise() correctly to prevent such
> scenarios.
> >
> > > preemptively evicting file pages and only making them more likely to
> > > be evicted when there's already memory pressure, we avoid the case
> > > where we process_madvise an app then immediately return to the app and
> > > reload all file pages in the working set even though there was no
> > > intervening memory pressure. Our initial version of this work evicted
> >
> > That would be the worst case scenario which should be avoided. Memory
> pressure
> > must be a parameter before actually doing the swap out. But pages if
> know to be
> > inactive/cold can be marked high priority to be swapped out.
> >
> > > file pages preemptively and did cause a noticeable slowdown (~15%) for
> > > that case; this patch set avoids that slowdown. Finally, the benefit
> > > from avoiding cold starts is huge. The performance improvement from
> > > having a hot start instead of a cold start ranges from 3x for very
> > > small apps to 50x+ for larger apps like high-fidelity games.
> >
> > Is there any other real world scenario apart from this app based
> ecosystem where
> > user hinted LRU management might be helpful ? Just being curious. Thanks
> for the
> > detailed explanation. I will continue looking into this series.
>
> Chrome OS is another real world use-case for this user hinted LRU
> management approach by proactively reclaiming reclaim from tabs not
> accessed by the user for some time.
>

--0000000000004a8092058972388d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">To expand on the ChromeOS use case we&#39;re in a very sim=
ilar situation to Android. For example, the Chrome browser uses a separate =
process for each individual tab (with some exceptions) and over time many t=
abs remain open in a back-grounded or idle state. Given that we have a lot =
of information about the weight of a tab, when it was last active, etc, we =
can benefit tremendously from per-process reclaim. We&#39;re working on get=
ting real world numbers but all of our initial testing shows very promising=
 results.</div><br><div class=3D"gmail_quote"><div dir=3D"ltr" class=3D"gma=
il_attr">On Tue, May 21, 2019 at 5:57 AM Shakeel Butt &lt;<a href=3D"mailto=
:shakeelb@google.com">shakeelb@google.com</a>&gt; wrote:<br></div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px =
solid rgb(204,204,204);padding-left:1ex">On Mon, May 20, 2019 at 7:55 PM An=
shuman Khandual<br>
&lt;<a href=3D"mailto:anshuman.khandual@arm.com" target=3D"_blank">anshuman=
.khandual@arm.com</a>&gt; wrote:<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt; On 05/20/2019 10:29 PM, Tim Murray wrote:<br>
&gt; &gt; On Sun, May 19, 2019 at 11:37 PM Anshuman Khandual<br>
&gt; &gt; &lt;<a href=3D"mailto:anshuman.khandual@arm.com" target=3D"_blank=
">anshuman.khandual@arm.com</a>&gt; wrote:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Or Is the objective here is reduce the number of processes wh=
ich get killed by<br>
&gt; &gt;&gt; lmkd by triggering swapping for the unused memory (user hinte=
d) sooner so that<br>
&gt; &gt;&gt; they dont get picked by lmkd. Under utilization for zram hard=
ware is a concern<br>
&gt; &gt;&gt; here as well ?<br>
&gt; &gt;<br>
&gt; &gt; The objective is to avoid some instances of memory pressure by<br=
>
&gt; &gt; proactively swapping pages that userspace knows to be cold before=
<br>
&gt; &gt; those pages reach the end of the LRUs, which in turn can prevent =
some<br>
&gt; &gt; apps from being killed by lmk/lmkd. As soon as Android userspace =
knows<br>
&gt; &gt; that an application is not being used and is only resident to imp=
rove<br>
&gt; &gt; performance if the user returns to that app, we can kick off<br>
&gt; &gt; process_madvise on that process&#39;s pages (or some portion of t=
hose<br>
&gt; &gt; pages) in a power-efficient way to reduce memory pressure long be=
fore<br>
&gt; &gt; the system hits the free page watermark. This allows the system m=
ore<br>
&gt; &gt; time to put pages into zram versus waiting for the watermark to<b=
r>
&gt; &gt; trigger kswapd, which decreases the likelihood that later memory<=
br>
&gt; &gt; allocations will cause enough pressure to trigger a kill of one o=
f<br>
&gt; &gt; these apps.<br>
&gt;<br>
&gt; So this opens up bit of LRU management to user space hints. Also becau=
se the app<br>
&gt; in itself wont know about the memory situation of the entire system, n=
ew system<br>
&gt; call needs to be called from an external process.<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt;&gt; Swapping out memory into zram wont increase the latency for a=
 hot start ? Or<br>
&gt; &gt;&gt; is it because as it will prevent a fresh cold start which any=
way will be slower<br>
&gt; &gt;&gt; than a slow hot start. Just being curious.<br>
&gt; &gt;<br>
&gt; &gt; First, not all swapped pages will be reloaded immediately once an=
 app<br>
&gt; &gt; is resumed. We&#39;ve found that an app&#39;s working set post-pr=
ocess_madvise<br>
&gt; &gt; is significantly smaller than what an app allocates when it first=
<br>
&gt; &gt; launches (see the delta between pswpin and pswpout in Minchan&#39=
;s<br>
&gt; &gt; results). Presumably because of this, faulting to fetch from zram=
 does<br>
&gt;<br>
&gt; pswpin=C2=A0 =C2=A0 =C2=A0 417613=C2=A0 =C2=A0 1392647=C2=A0 =C2=A0 =
=C2=A0975034=C2=A0 =C2=A0 =C2=A0233.00<br>
&gt; pswpout=C2=A0 =C2=A0 1274224=C2=A0 =C2=A0 2661731=C2=A0 =C2=A0 1387507=
=C2=A0 =C2=A0 =C2=A0108.00<br>
&gt;<br>
&gt; IIUC the swap-in ratio is way higher in comparison to that of swap out=
. Is that<br>
&gt; always the case ? Or it tend to swap out from an active area of the wo=
rking set<br>
&gt; which faulted back again.<br>
&gt;<br>
&gt; &gt; not seem to introduce a noticeable hot start penalty, not does it=
<br>
&gt; &gt; cause an increase in performance problems later in the app&#39;s<=
br>
&gt; &gt; lifecycle. I&#39;ve measured with and without process_madvise, an=
d the<br>
&gt; &gt; differences are within our noise bounds. Second, because we&#39;r=
e not<br>
&gt;<br>
&gt; That is assuming that post process_madvise() working set for the appli=
cation is<br>
&gt; always smaller. There is another challenge. The external process shoul=
d ideally<br>
&gt; have the knowledge of active areas of the working set for an applicati=
on in<br>
&gt; question for it to invoke process_madvise() correctly to prevent such =
scenarios.<br>
&gt;<br>
&gt; &gt; preemptively evicting file pages and only making them more likely=
 to<br>
&gt; &gt; be evicted when there&#39;s already memory pressure, we avoid the=
 case<br>
&gt; &gt; where we process_madvise an app then immediately return to the ap=
p and<br>
&gt; &gt; reload all file pages in the working set even though there was no=
<br>
&gt; &gt; intervening memory pressure. Our initial version of this work evi=
cted<br>
&gt;<br>
&gt; That would be the worst case scenario which should be avoided. Memory =
pressure<br>
&gt; must be a parameter before actually doing the swap out. But pages if k=
now to be<br>
&gt; inactive/cold can be marked high priority to be swapped out.<br>
&gt;<br>
&gt; &gt; file pages preemptively and did cause a noticeable slowdown (~15%=
) for<br>
&gt; &gt; that case; this patch set avoids that slowdown. Finally, the bene=
fit<br>
&gt; &gt; from avoiding cold starts is huge. The performance improvement fr=
om<br>
&gt; &gt; having a hot start instead of a cold start ranges from 3x for ver=
y<br>
&gt; &gt; small apps to 50x+ for larger apps like high-fidelity games.<br>
&gt;<br>
&gt; Is there any other real world scenario apart from this app based ecosy=
stem where<br>
&gt; user hinted LRU management might be helpful ? Just being curious. Than=
ks for the<br>
&gt; detailed explanation. I will continue looking into this series.<br>
<br>
Chrome OS is another real world use-case for this user hinted LRU<br>
management approach by proactively reclaiming reclaim from tabs not<br>
accessed by the user for some time.<br>
</blockquote></div>

--0000000000004a8092058972388d--

