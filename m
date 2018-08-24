Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C51156B2EA2
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:11:22 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id a37-v6so7147764wrc.5
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 01:11:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h5-v6sor2480928wrm.83.2018.08.24.01.11.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 01:11:21 -0700 (PDT)
MIME-Version: 1.0
References: <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz> <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
 <20180806181638.GE10003@dhcp22.suse.cz> <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
 <CADF2uSp7MKYWL7Yu5TDOT4qe0v-0iiq+Tv9J6rnzCSgahXbNaA@mail.gmail.com>
 <20180821064911.GW29735@dhcp22.suse.cz> <11b4f8cd-6253-262f-4ae6-a14062c58039@suse.cz>
 <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
 <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz> <20180823122111.GG29735@dhcp22.suse.cz>
 <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com> <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
In-Reply-To: <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Fri, 24 Aug 2018 10:11:09 +0200
Message-ID: <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="000000000000bfca56057429eb2d"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

--000000000000bfca56057429eb2d
Content-Type: text/plain; charset="UTF-8"

>
> 1. Send the current value of /sys/kernel/mm/transparent_hugepage/defrag
> 2. Unless it's 'defer' or 'never' already, try changing it to 'defer'.
>

 /sys/kernel/mm/transparent_hugepage/defrag is
always defer defer+madvise [madvise] never

I *think* I already played around with these values, as far as I remember
`never`
almost caused the system to hang, or at least while I switched back to
madvise.
shall I switch it to defer and observe (all hosts are running fine by just
now) or
switch to defer while it is in the bad state?
and when doing this, should improvement be measurable immediately?
I need to know how long to hold this, before dropping caches becomes
necessary.

> Ah, checked the trace and it seems to be "php-cgi". Interesting that
> they use madvise(MADV_HUGEPAGE). Anyway the above still applies.

you know, that's at least an interesting hint. look at this:
https://ckon.wordpress.com/2015/09/18/php7-opcache-performance/

this was experimental there, but a more recent version seems to have it on
by default, since I need to disable it on request (implies to me that it is
on by default).
it is however *disabled* in the runtime configuration (and not in effect, I
just confirmed that)

It would be interesting to know whether madvise(MADV_HUGEPAGE) is then
active
somewhere else, since it is in the dump as you observed.

Please note that `killing` php-cgi would not make any difference then,
since these processes
are started by request for every user and killed after whatever script is
finished. this may
invoke about 10-50 forks, depending on load, (with different system users)
every second.

That also *may* explain why it is not so much deterministic (sometimes
earlier/sooner, sometimes
on one host and not on the other), since there are multiple php-cgi
versions available
and not everyone is using the same version - most people stick to legacy
versions.

--000000000000bfca56057429eb2d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_quote"><blockquote class=3D"gmail_quot=
e" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204)=
;padding-left:1ex">
1. Send the current value of /sys/kernel/mm/transparent_hugepage/defrag<br>
2. Unless it&#39;s &#39;defer&#39; or &#39;never&#39; already, try changing=
 it to &#39;defer&#39;.<br></blockquote><div><br></div><div>=C2=A0/sys/kern=
el/mm/transparent_hugepage/defrag is<br></div><div>always defer defer+madvi=
se [madvise] never<br></div><div><br></div><div>I *think* I already played =
around with these values, as far as I remember `never`</div><div>almost cau=
sed the system to hang, or at least while I switched back to madvise.</div>=
<div>shall I switch it to defer and observe (all hosts are running fine by =
just now) or</div><div>switch to defer while it is in the bad state?</div><=
div>and when doing this, should improvement be measurable immediately?<br><=
/div><div>I need to know how long to hold this, before dropping caches beco=
mes necessary.<br></div><div><br></div><div>&gt; Ah, checked the trace and =
it seems to be &quot;php-cgi&quot;. Interesting that<br>&gt; they use madvi=
se(MADV_HUGEPAGE). Anyway the above still applies.<span class=3D"gmail-im">=
<br></span></div><div><span class=3D"gmail-im"><br></span></div><div><span =
class=3D"gmail-im">you know, that&#39;s at least an interesting hint. look =
at this:</span></div><div><span class=3D"gmail-im"><a href=3D"https://ckon.=
wordpress.com/2015/09/18/php7-opcache-performance/">https://ckon.wordpress.=
com/2015/09/18/php7-opcache-performance/</a><br></span></div><div><span cla=
ss=3D"gmail-im"><br></span></div><div><span class=3D"gmail-im">this was exp=
erimental there, but a more recent version seems to have it on</span></div>=
<div><span class=3D"gmail-im">by default, since I need to disable it on req=
uest (implies to me that it is on by default).</span></div><div><span class=
=3D"gmail-im">it is however *disabled* in the runtime configuration (and no=
t in effect, I just confirmed that)<br></span></div><div><span class=3D"gma=
il-im"><br></span></div><div><span class=3D"gmail-im">It would be interesti=
ng to know whether madvise(MADV_HUGEPAGE) is then active</span></div><div><=
span class=3D"gmail-im">somewhere else, since it is in the dump as you obse=
rved.<br></span></div><br><div><span class=3D"gmail-im">Please note that `k=
illing` php-cgi would not make any difference then, since these processes</=
span></div><div><span class=3D"gmail-im">are started by request for every u=
ser and killed after whatever script is finished. this may</span></div><div=
><span class=3D"gmail-im">invoke about 10-50 forks, depending on load, (wit=
h different system users) every second.<br></span></div><div><span class=3D=
"gmail-im"><br></span></div><div><span class=3D"gmail-im">That also *may* e=
xplain why it is not so much deterministic (sometimes earlier/sooner, somet=
imes</span></div><div><span class=3D"gmail-im">on one host and not on the o=
ther), since there are multiple php-cgi versions available</span></div><div=
><span class=3D"gmail-im">and not everyone is using the same version - most=
 people stick to legacy versions.</span></div><div><span class=3D"gmail-im"=
><br></span></div></div></div>

--000000000000bfca56057429eb2d--
