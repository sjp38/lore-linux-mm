Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2D96B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 10:13:49 -0400 (EDT)
Received: by ykax123 with SMTP id x123so8561371yka.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:13:49 -0700 (PDT)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id m5si17111635yka.70.2015.07.29.07.13.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 07:13:48 -0700 (PDT)
Received: by ykax123 with SMTP id x123so8560961yka.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:13:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANN689HJX2ZL891uOd8TW9ct4PNH9d5odQZm86WMxkpkCWhA-w@mail.gmail.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<20150729123629.GI15801@dhcp22.suse.cz>
	<20150729135907.GT8100@esperanza>
	<CANN689HJX2ZL891uOd8TW9ct4PNH9d5odQZm86WMxkpkCWhA-w@mail.gmail.com>
Date: Wed, 29 Jul 2015 07:13:47 -0700
Message-ID: <CANN689GLasWAMGAjqmceEWcpnjjLGMbQYPx6uTAU=K4sT1NNnA@mail.gmail.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(resending as text, sorry for previous post which didn't make it to the ML)

On Wed, Jul 29, 2015 at 7:12 AM, Michel Lespinasse <walken@google.com> wrot=
e:
>
> On Wed, Jul 29, 2015 at 6:59 AM, Vladimir Davydov <vdavydov@parallels.com=
> wrote:
> >> I guess the primary reason to rely on the pfn rather than the LRU walk=
,
> >> which would be more targeted (especially for memcg cases), is that we
> >> cannot hold lru lock for the whole LRU walk and we cannot continue
> >> walking after the lock is dropped. Maybe we can try to address that
> >> instead? I do not think this is easy to achieve but have you considere=
d
> >> that as an option?
> >
> > Yes, I have, and I've come to a conclusion it's not doable, because LRU
> > lists can be constantly rotating at an arbitrary rate. If you have an
> > idea in mind how this could be done, please share.
> >
> > Speaking of LRU-vs-PFN walk, iterating over PFNs has its own advantages=
:
> >  - You can distribute a walk in time to avoid CPU bursts.
> >  - You are free to parallelize the scanner as you wish to decrease the
> >    scan time.
>
> There is a third way: one could go through every MM in the system and sca=
n their page tables. Doing things that way turns out to be generally faster=
 than scanning by physical address, because you don't have to go through RM=
AP for every page. But, you end up needing to take the mmap_sem lock of eve=
ry MM (in turn) while scanning them, and that degrades quickly under memory=
 load, which is exactly when you most need this feature. So, scan by addres=
s is still what we use here.
>
> My only concern about the interface is that it exposes the fact that the =
scan is done by address - if the interface only showed per-memcg totals, it=
 would make it possible to change the implementation underneath if we someh=
ow figure out how to work around the mmap_sem issue in the future. I don't =
think that is necessarily a blocker but this is something to keep in mind I=
MO.

--
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
