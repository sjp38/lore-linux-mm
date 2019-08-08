Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5473EC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 19:21:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAA0E214C6
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 19:21:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="fNKIGPAm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAA0E214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98A806B0003; Thu,  8 Aug 2019 15:21:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 939AB6B0006; Thu,  8 Aug 2019 15:21:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8034C6B0007; Thu,  8 Aug 2019 15:21:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5394D6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 15:21:44 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id b25so63669339otp.12
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 12:21:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vUngqMTEp/ERl5g0oBf+1nOMPoXtRIRatQxU3Tkkcjo=;
        b=Ogxuoq/GZbz+kXPo+7t1uL2Yu476JZb3z+HnKXYjRHFaRRj9KGCKGmZJm/zt5C6/12
         xMHaotj+dAmJ3oL2ObpFyWSooDWNYntk7h2xxMmWIuYN780NZqHYy5LKXSkiK/AtKtx2
         hWKi2M5BenLLDUszUadkLGGCv8CeAmEwNdCm52Sj3uEOnLIC2mf+GxLrt6slEPaP7CPr
         aCakw/vOvpKQhqpgvlAi0SjHuLwwFTbO9aHnVQDNz7N2l1l9GffIYlMZfIE865YZMrS0
         mY1KtbjsK1jB/Q5NKORVhvuc3ZRjo1n1q9NKFauOAVCMrp3vC60+k5qwsUYGu9dwSqks
         EBqw==
X-Gm-Message-State: APjAAAXAJX9s+Dtq1lxE/2bMpCNdnmKs1DbpBlhdSbK/eSgSo2gchzvg
	qCKav2mOTYf37XGguuTY5xqieGkM52Hwk7J51Ljwvq+aJGOXpS/OE+o9Ht01jybb7qjBydIsaBv
	kY1WOA5p30mREN3EqEZs6oZskhTWJ6qbOrybo3nIA2MA9B//CiKCSxR1bbblJU/T+lBtpfoPhU1
	3ckOKMjlwwMSwiGnQhzLrirgpJvps3AvJI1GRsEZbTN0bEAx2g96/iIJjybeZO6FdFPuQeF9RDg
	70yoQVXyCnauhaWFJqe0PT9a2grM5dbttBCqU8pld6FKUsn5qY=
X-Received: by 2002:a02:7121:: with SMTP id n33mr18126023jac.19.1565292103898;
        Thu, 08 Aug 2019 12:21:43 -0700 (PDT)
X-Received: by 2002:a02:7121:: with SMTP id n33mr18125947jac.19.1565292102959;
        Thu, 08 Aug 2019 12:21:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565292102; cv=none;
        d=google.com; s=arc-20160816;
        b=g7VYLuTHr3SQHaWyjx9nqG+FpOZCnKEyKgpO0Nmlg/YZsW+ZbVCzc9m0/6m4FCu07J
         WG6uxIukiYxNoAXPZTiolkUXQ7qX8GkRyYyvvK4qVLfLclHMIvKslUNgDGuTEVgCQv+X
         vv5OnXw3JA3618uFGcmdsAdD1RluX9BAcTuqY9Zr8WgEETM1vAy9K4LiIubU6gUNRVUY
         66DIj2tEKlOqd07DkfPltfGv3zwby25yXXHu5oAgZnfJjYOxIQlQQDkgpWr47G6FAZyr
         YtXyhLpCmbUGZwgS+KvntpkScWZUDxMI1OwQf4zp1bM+XJWfb6SYA/aCpwJEAV5ugz6k
         +SJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vUngqMTEp/ERl5g0oBf+1nOMPoXtRIRatQxU3Tkkcjo=;
        b=l/KQFf79Pg0LBGakJULsvZVVY3FRaa1KRvLbfMtye7rS1dIW6UCMPI8t3o/BWA9v3H
         HgTSg/WjMwid9hF7dCudY3Nwo3Iaz94wuag5ebYqMEBZYdG+L79V6jxWusEOLGGzOBsA
         Dc/I3Jd3Dot0IZ450wU3/l04e2j44PVNfnCvO5SHzX2KFV18dvoeJ+FZiz2iESemM1CW
         TBvON3zA8ZTHWPqQNRJeInrOC3miNZuljOkavgoW4goWCCOQtLxD5lSNJ0ytkDHuZFB3
         A/pAhKzJqEzx0iT0Im3J9ELNJ9hwI4MFLrqi1f0C5kQya/ThVIRLAg/r/ewVoH1T2v7B
         uY4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@arista.com header.s=googlenew header.b=fNKIGPAm;
       spf=pass (google.com: domain of echron@arista.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=echron@arista.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=arista.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c128sor9501040jac.2.2019.08.08.12.21.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 12:21:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of echron@arista.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@arista.com header.s=googlenew header.b=fNKIGPAm;
       spf=pass (google.com: domain of echron@arista.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=echron@arista.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=arista.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vUngqMTEp/ERl5g0oBf+1nOMPoXtRIRatQxU3Tkkcjo=;
        b=fNKIGPAmRXQM9DkEgQORDIpGnOWfzw2JEJgRIk8dKPXXwILZH/HqzXFZ71r5026EDW
         OJ2JfQPSJ/JoMxIKUKFtpiAWFNGN7DkdWJSNc6Q2ine9GaUjFWLH3bxiWqPOKeI9EVbZ
         yr4i5y8HqEr3f02zHIyH3MO6mkmYDh6UzKBbOOG0p0d5psyi9JeJjt4E+5qv7V+gNzt9
         KwMs9WhWsdX/xqjKbLzeoBgN3GNxbeepxziJgshw7Cz/8PSHv3Rxl0O7+lW//KO7DtXH
         ZrV7jprQ1stXRpl+Bfs2+c5WL/TPkSdsoASY+H2BKM4ACB4iNz4WtLFb/bt9yOdWgVyH
         oVoQ==
X-Google-Smtp-Source: APXvYqyci3As+rRu78YsOShQP72owa0tGYjOSwVoGj0xJhm9ZWUHq4ecfOIPxlZLvOOzQXz4oHkN0I2M5Q0l/3FGPeM=
X-Received: by 2002:a02:c519:: with SMTP id s25mr17952353jam.11.1565292102528;
 Thu, 08 Aug 2019 12:21:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190808183247.28206-1-echron@arista.com> <20190808185119.GF18351@dhcp22.suse.cz>
In-Reply-To: <20190808185119.GF18351@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Thu, 8 Aug 2019 12:21:30 -0700
Message-ID: <CAM3twVT0_f++p1jkvGuyMYtaYtzgEiaUtb8aYNCmNScirE4=og@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add killed process selection information
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: multipart/alternative; boundary="000000000000bddca0058f9ff797"
X-CLOUD-SEC-AV-Info: arista,google_mail,monitor
X-CLOUD-SEC-AV-Sent: true
X-Gm-Spam: 0
X-Gm-Phishy: 0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000bddca0058f9ff797
Content-Type: text/plain; charset="UTF-8"

It is helpful to the admin that looks at the kill message and records this
information. OOMs can come in bunches.
Knowing how much resource the oom selected process was using at the time of
the OOM event is very useful, these fields document key process and system
memory/swap values and can be quite helpful.

Also can't you disable printing the oom eligible task list? For systems
with very large numbers of oom eligible processes that would seem to be
very desirable.
We have some servers that have many thousands of processes and printing
them all, especially as there may be several oom events that occur can
occur in quick succession, this can be problematic and can result in print
rate limiting.
Having this information with this message is of extra value in that case.

We've included it on the many thousands of linux systems that we've shipped
and also on our internal linux systems and for us it has been helpful.

Also, on our systems we set the Killed process message to pr_err as opposed
pr_info as we want just that message being sent to the console.
Customers and our internal support people find this message in that format
valuable as they want to know when OOM events occur and so this message
gives them a decent amount to go on.
Very few messages go to the console, to avoid clutter, but this one that
people agree belongs there.
I'm not sure that change would be supported upstream but again in our
experience we've found it helpful, since you asked.

Thanks.

On Thu, Aug 8, 2019 at 11:51 AM Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 08-08-19 11:32:47, Edward Chron wrote:
> > For an OOM event: print oomscore, memory pct, oom adjustment of the
> process
> > that OOM kills and the totalpages value in kB (KiB) used in the
> calculation
> > with the OOM killed process message. This is helpful to document why the
> > process was selected by OOM at the time of the OOM event.
> >
> > Sample message output:
> > Jul 21 20:07:48 yoursystem kernel: Out of memory: Killed process 2826
> >  (processname) total-vm:1056800kB, anon-rss:1052784kB, file-rss:4kB,
> >  shmem-rss:0kB memory-usage:3.2% oom_score:1032 oom_score_adj:1000
> >  total-pages: 32791748kB
>
> A large part of this information is already printed in the oom eligible
> task list. Namely rss, oom_score_adj, there is also page tables
> consumption which might be a serious contributor as well. Why would you
> like to see oom_score, memory-usage and total-pages to be printed as
> well? How is that information useful?
> --
> Michal Hocko
> SUSE Labs
>

--000000000000bddca0058f9ff797
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">It is helpful to the admin that looks at the kill message =
and records this information. OOMs can come in bunches.<div>Knowing how muc=
h resource the oom selected process was using at the time of the OOM event =
is very useful, these fields document key process and system memory/swap va=
lues and can be quite helpful.</div><div><br><div>Also can&#39;t you disabl=
e printing the oom eligible task list? For systems with very large numbers =
of oom eligible processes that would seem to be very desirable.=C2=A0</div>=
<div>We have some servers that have many thousands of processes and printin=
g them all, especially as there may be several oom events that occur can oc=
cur in quick=C2=A0succession, this can be problematic and can result in pri=
nt rate limiting.</div><div>Having this information with this message is of=
 extra value in that case.</div></div><div><br></div><div>We&#39;ve include=
d it on the many thousands of linux systems that we&#39;ve shipped and also=
 on our internal linux systems and for us it has been helpful.</div><div><b=
r></div><div>Also, on our systems we set the Killed process message to pr_e=
rr as opposed pr_info as we want just that message being sent to the consol=
e.</div><div>Customers and our internal support people find this message in=
 that format valuable as they want to know when OOM events occur and so thi=
s message gives them a decent amount to go on.</div><div>Very few messages =
go to the console, to avoid clutter, but this one that people agree belongs=
 there.</div><div>I&#39;m not sure that change would be supported upstream =
but again in our experience we&#39;ve found it helpful, since you asked.</d=
iv><div><br></div><div>Thanks.</div></div><br><div class=3D"gmail_quote"><d=
iv dir=3D"ltr" class=3D"gmail_attr">On Thu, Aug 8, 2019 at 11:51 AM Michal =
Hocko &lt;<a href=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; wr=
ote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px=
 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On Thu 08-0=
8-19 11:32:47, Edward Chron wrote:<br>
&gt; For an OOM event: print oomscore, memory pct, oom adjustment of the pr=
ocess<br>
&gt; that OOM kills and the totalpages value in kB (KiB) used in the calcul=
ation<br>
&gt; with the OOM killed process message. This is helpful to document why t=
he<br>
&gt; process was selected by OOM at the time of the OOM event.<br>
&gt; <br>
&gt; Sample message output:<br>
&gt; Jul 21 20:07:48 yoursystem kernel: Out of memory: Killed process 2826<=
br>
&gt;=C2=A0 (processname) total-vm:1056800kB, anon-rss:1052784kB, file-rss:4=
kB,<br>
&gt;=C2=A0 shmem-rss:0kB memory-usage:3.2% oom_score:1032 oom_score_adj:100=
0<br>
&gt;=C2=A0 total-pages: 32791748kB<br>
<br>
A large part of this information is already printed in the oom eligible<br>
task list. Namely rss, oom_score_adj, there is also page tables<br>
consumption which might be a serious contributor as well. Why would you<br>
like to see oom_score, memory-usage and total-pages to be printed as<br>
well? How is that information useful?<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
</blockquote></div>

--000000000000bddca0058f9ff797--

