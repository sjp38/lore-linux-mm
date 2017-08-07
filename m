Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 844AA6B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 11:55:47 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id 7so11844031ywe.0
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 08:55:47 -0700 (PDT)
Received: from mail-yw0-x229.google.com (mail-yw0-x229.google.com. [2607:f8b0:4002:c05::229])
        by mx.google.com with ESMTPS id h123si1730473ywd.471.2017.08.07.08.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 08:55:46 -0700 (PDT)
Received: by mail-yw0-x229.google.com with SMTP id s143so5324680ywg.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 08:55:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170807134648.GI32434@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com> <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz>
From: =?UTF-8?Q?Colm_MacC=C3=A1rthaigh?= <colm@allcosts.net>
Date: Mon, 7 Aug 2017 17:55:45 +0200
Message-ID: <CAAF6GDcNoDUaDSxV6N12A_bOzo8phRUX5b8-OBteuN0AmeCv0g@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Content-Type: multipart/alternative; boundary="001a113f46703dcfb705562be17b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, Florian Weimer <fweimer@redhat.com>, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org

--001a113f46703dcfb705562be17b
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 7, 2017 at 3:46 PM, Michal Hocko <mhocko@kernel.org> wrote:

>
> > > The use case is libraries that store or cache information, and
> > > want to know that they need to regenerate it in the child process
> > > after fork.
>
> How do they know that they need to regenerate if they do not get SEGV?
> Are they going to assume that a read of zeros is a "must init again"? Isn't
> that too fragile? Or do they play other tricks like parse /proc/self/smaps
> and read in the flag?
>

Hi from a user space crypto maintainer :) Here's how we do exactly this it
in s2n:

https://github.com/awslabs/s2n/blob/master/utils/s2n_random.c , lines 62 -
91

and here's how LibreSSL does it:

https://github.com/libressl-portable/openbsd/blob/57dcd4329d83bff3dd67a293d5c4a53b795c587e/src/lib/libc/crypt/arc4random.h
(lines 37 on)
https://github.com/libressl-portable/openbsd/blob/57dcd4329d83bff3dd67a293d5c4a53b795c587e/src/lib/libc/crypt/arc4random.c
(Line 110)

OpenSSL and libc are in the process of adding similar DRBGs and would use a
WIPEONFORK. BoringSSL's maintainers are also interested as it adds
robustness.  I also recall it being a topic of discussion at the High
Assurance Cryptography Symposium (HACS) where many crypto maintainers meet
and several more maintainers there indicated it would be nice to have.

Right now on Linux we all either use pthread_atfork() to zero the memory on
fork, or getpid() and getppid() guards. The former can be evaded by direct
syscall() and other tricks (which things like Language VMs are prone to
doing), and the latter check is probabilistic as pids can repeat, though if
you use both getpid() and getppid() - which is slow! - the probability of
both PIDs colliding is very low indeed.

The result at the moment on Linux there's no bulletproof way to detect a
fork and erase a key or DRBG state. It would really be nice to be able to
match what we can do with MAP_INHERIT_ZERO and minherit() on BSD.
 madvise() does seem like the established idiom for behavior like this on
Linux.  I don't imagine it will be hard to use in practice, we can fall
back to existing behavior if the flag isn't accepted.

-- 
Colm

--001a113f46703dcfb705562be17b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Mon, Aug 7, 2017 at 3:46 PM, Michal Hocko <span dir=3D"ltr">&lt;<a h=
ref=3D"mailto:mhocko@kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt=
;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0p=
x 0px 0.8ex;border-left-width:1px;border-left-style:solid;border-left-color=
:rgb(204,204,204);padding-left:1ex"><span class=3D"gmail-"><br>
&gt; &gt; The use case is libraries that store or cache information, and<br=
>
&gt; &gt; want to know that they need to regenerate it in the child process=
<br>
&gt; &gt; after fork.<br>
<br>
</span>How do they know that they need to regenerate if they do not get SEG=
V?<br>
Are they going to assume that a read of zeros is a &quot;must init again&qu=
ot;? Isn&#39;t<br>
that too fragile? Or do they play other tricks like parse /proc/self/smaps<=
br>
and read in the flag?<br></blockquote><div><br></div><div>Hi from a user sp=
ace crypto maintainer :) Here&#39;s how we do exactly this it in s2n:</div>=
<div><br></div><div><a href=3D"https://github.com/awslabs/s2n/blob/master/u=
tils/s2n_random.c">https://github.com/awslabs/s2n/blob/master/utils/s2n_ran=
dom.c</a> , lines 62 - 91<br></div><div><br></div><div>and here&#39;s how L=
ibreSSL does it:</div><div><br></div><div><a href=3D"https://github.com/lib=
ressl-portable/openbsd/blob/57dcd4329d83bff3dd67a293d5c4a53b795c587e/src/li=
b/libc/crypt/arc4random.h">https://github.com/libressl-portable/openbsd/blo=
b/57dcd4329d83bff3dd67a293d5c4a53b795c587e/src/lib/libc/crypt/arc4random.h<=
/a> (lines 37 on)<br></div><div><a href=3D"https://github.com/libressl-port=
able/openbsd/blob/57dcd4329d83bff3dd67a293d5c4a53b795c587e/src/lib/libc/cry=
pt/arc4random.c">https://github.com/libressl-portable/openbsd/blob/57dcd432=
9d83bff3dd67a293d5c4a53b795c587e/src/lib/libc/crypt/arc4random.c</a> (Line =
110)<br></div><div><br></div><div>OpenSSL and libc are in the process of ad=
ding similar DRBGs and would use a WIPEONFORK. BoringSSL&#39;s maintainers =
are also interested as it adds robustness.=C2=A0 I also recall it being a t=
opic of discussion at the High Assurance Cryptography Symposium (HACS) wher=
e many crypto maintainers meet and several more maintainers there indicated=
 it would be nice to have.=C2=A0</div><div><br></div><div>Right now on Linu=
x we all either use pthread_atfork() to zero the memory on fork, or getpid(=
) and getppid() guards. The former can be evaded by direct syscall() and ot=
her tricks (which things like Language VMs are prone to doing), and the lat=
ter check is probabilistic as pids can repeat, though if you use both getpi=
d() and getppid() - which is slow! - the probability of both PIDs colliding=
 is very low indeed.=C2=A0</div><div><br></div><div>The result at the momen=
t on Linux there&#39;s no bulletproof way to detect a fork and erase a key =
or DRBG state. It would really be nice to be able to match what we can do w=
ith MAP_INHERIT_ZERO and minherit() on BSD. =C2=A0madvise() does seem like =
the established idiom for behavior like this on Linux.=C2=A0 I don&#39;t im=
agine it will be hard to use in practice, we can fall back to existing beha=
vior if the flag isn&#39;t accepted.=C2=A0</div></div><div><br></div>-- <br=
><div class=3D"gmail_signature">Colm</div>
</div></div>

--001a113f46703dcfb705562be17b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
