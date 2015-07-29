Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 504EE6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 10:12:16 -0400 (EDT)
Received: by ykba194 with SMTP id a194so8570106ykb.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:12:16 -0700 (PDT)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id o188si18666571yko.52.2015.07.29.07.12.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 07:12:14 -0700 (PDT)
Received: by ykdu72 with SMTP id u72so8476184ykd.2
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:12:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150729135907.GT8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<20150729123629.GI15801@dhcp22.suse.cz>
	<20150729135907.GT8100@esperanza>
Date: Wed, 29 Jul 2015 07:12:13 -0700
Message-ID: <CANN689HJX2ZL891uOd8TW9ct4PNH9d5odQZm86WMxkpkCWhA-w@mail.gmail.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
From: Michel Lespinasse <walken@google.com>
Content-Type: multipart/alternative; boundary=001a113a36f06560a9051c042cc2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

--001a113a36f06560a9051c042cc2
Content-Type: text/plain; charset=UTF-8

On Wed, Jul 29, 2015 at 6:59 AM, Vladimir Davydov <vdavydov@parallels.com>
wrote:
>> I guess the primary reason to rely on the pfn rather than the LRU walk,
>> which would be more targeted (especially for memcg cases), is that we
>> cannot hold lru lock for the whole LRU walk and we cannot continue
>> walking after the lock is dropped. Maybe we can try to address that
>> instead? I do not think this is easy to achieve but have you considered
>> that as an option?
>
> Yes, I have, and I've come to a conclusion it's not doable, because LRU
> lists can be constantly rotating at an arbitrary rate. If you have an
> idea in mind how this could be done, please share.
>
> Speaking of LRU-vs-PFN walk, iterating over PFNs has its own advantages:
>  - You can distribute a walk in time to avoid CPU bursts.
>  - You are free to parallelize the scanner as you wish to decrease the
>    scan time.

There is a third way: one could go through every MM in the system and scan
their page tables. Doing things that way turns out to be generally faster
than scanning by physical address, because you don't have to go through
RMAP for every page. But, you end up needing to take the mmap_sem lock of
every MM (in turn) while scanning them, and that degrades quickly under
memory load, which is exactly when you most need this feature. So, scan by
address is still what we use here.

My only concern about the interface is that it exposes the fact that the
scan is done by address - if the interface only showed per-memcg totals, it
would make it possible to change the implementation underneath if we
somehow figure out how to work around the mmap_sem issue in the future. I
don't think that is necessarily a blocker but this is something to keep in
mind IMO.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--001a113a36f06560a9051c042cc2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 29, 2015 at 6:59 AM, Vladimir Davydov &lt;<a href=3D"mailto:vda=
vydov@parallels.com">vdavydov@parallels.com</a>&gt; wrote:<br>&gt;&gt; I gu=
ess the primary reason to rely on the pfn rather than the LRU walk,<br>&gt;=
&gt; which would be more targeted (especially for memcg cases), is that we<=
br>&gt;&gt; cannot hold lru lock for the whole LRU walk and we cannot conti=
nue<br>&gt;&gt; walking after the lock is dropped. Maybe we can try to addr=
ess that<br>&gt;&gt; instead? I do not think this is easy to achieve but ha=
ve you considered<br>&gt;&gt; that as an option?<br>&gt;<br>&gt; Yes, I hav=
e, and I&#39;ve come to a conclusion it&#39;s not doable, because LRU<br>&g=
t; lists can be constantly rotating at an arbitrary rate. If you have an<br=
>&gt; idea in mind how this could be done, please share.<br>&gt;<br>&gt; Sp=
eaking of LRU-vs-PFN walk, iterating over PFNs has its own advantages:<br>&=
gt; =C2=A0- You can distribute a walk in time to avoid CPU bursts.<br>&gt; =
=C2=A0- You are free to parallelize the scanner as you wish to decrease the=
<br>&gt; =C2=A0 =C2=A0scan time.<br><br>There is a third way: one could go =
through every MM in the system and scan their page tables. Doing things tha=
t way turns out to be generally faster than scanning by physical address, b=
ecause you don&#39;t have to go through RMAP for every page. But, you end u=
p needing to take the mmap_sem lock of every MM (in turn) while scanning th=
em, and that degrades quickly under memory load, which is exactly when you =
most need this feature. So, scan by address is still what we use here.<br><=
br>My only concern about the interface is that it exposes the fact that the=
 scan is done by address - if the interface only showed per-memcg totals, i=
t would make it possible to change the implementation underneath if we some=
how figure out how to work around the mmap_sem issue in the future. I don&#=
39;t think that is necessarily a blocker but this is something to keep in m=
ind IMO.<br><br>-- <br>Michel &quot;Walken&quot; Lespinasse<br>A program is=
 never fully debugged until the last user dies.<br>

--001a113a36f06560a9051c042cc2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
