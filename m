Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEF1D6B0007
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 09:53:02 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t4-v6so13684574plo.0
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 06:53:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 69-v6sor2774927pla.99.2018.08.01.06.53.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 06:53:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180801134628.ueyzwg2gszrvk2hc@breakpoint.cc>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
 <CA+55aFzYLgyNp1jsqsvUOjwZdO_1Piqj=iB=rzDShjScdNtkbg@mail.gmail.com>
 <CACT4Y+aYZumcc-Od5T1AnP4mwn8-FaWfxvfb93MnNwQPqG8TDw@mail.gmail.com>
 <CACT4Y+ZkgqDT77dshHg+hBtc9YPW-eZ8wVQA9LTDQ6q_y99oiQ@mail.gmail.com>
 <20180801103537.d36t3snzulyuge7g@breakpoint.cc> <CACT4Y+aHWpgDZygXv=smWwdVMWfjpedyajuVvvLDGMK-wFD5Lw@mail.gmail.com>
 <20180801114048.ufkr7zwmir7ps3vl@breakpoint.cc> <CACT4Y+ZNnYojj0x_DoUxeUREaEgzcf3UG=UW_P4vzsnZNjjgMQ@mail.gmail.com>
 <20180801134628.ueyzwg2gszrvk2hc@breakpoint.cc>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 1 Aug 2018 15:52:40 +0200
Message-ID: <CACT4Y+ay6+UTLMr4K_RTTubjzpGZXe2n7T8Q=kC=Q1baHshkHQ@mail.gmail.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Westphal <fw@strlen.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, David Miller <davem@davemloft.net>, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, Network Development <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Dave Airlie <airlied@linux.ie>, intel-gfx <intel-gfx@lists.freedesktop.org>, DRI <dri-devel@lists.freedesktop.org>, Eric Dumazet <edumazet@google.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>

On Wed, Aug 1, 2018 at 3:46 PM, Florian Westphal <fw@strlen.de> wrote:
> Dmitry Vyukov <dvyukov@google.com> wrote:
>> If that scenario is possible that a fix would be to make
>
> Looks possible.
>
>> __nf_conntrack_find_get ever return NULL iff it got NULL from
>> ____nf_conntrack_find (not if any of the checks has failed).
>
> I don't see why we need to restart on nf_ct_is_dying(), but other
> than that this seems ok.

Because it can be a wrong entry dying. When we check dying, we don't
yet know if we are looking at the right entry or not. If we
successfully acquire a reference, then recheck nf_ct_key_equal and
_then_ check dying, then we don't need to restart on dying. But with
the current check order, we need to restart on dying too.
