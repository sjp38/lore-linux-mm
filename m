Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCE56B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:16:43 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id k74-v6so6895548vkk.23
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 11:16:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r19-v6sor5352145uah.130.2018.07.31.11.16.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 11:16:41 -0700 (PDT)
MIME-Version: 1.0
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CANn89iLLQP2vA+2J-zxL3Fa75zNw=yRmv3Jg6vcEc=fYeEZ2ow@mail.gmail.com> <CACT4Y+Y6dhNgisDM9hdP-M-Rnk66DxZWcX7v39ESGJR8RY3asQ@mail.gmail.com>
In-Reply-To: <CACT4Y+Y6dhNgisDM9hdP-M-Rnk66DxZWcX7v39ESGJR8RY3asQ@mail.gmail.com>
From: Eric Dumazet <edumazet@google.com>
Date: Tue, 31 Jul 2018 11:16:28 -0700
Message-ID: <CANn89iLjk-mV3kZGASvZQtYaBDy9sbo=NW4Tt_V=dOP_-b=VNQ@mail.gmail.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Theodore Ts'o <tytso@mit.edu>, jack@suse.com, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com, rodrigo.vivi@intel.com, airlied@linux.ie, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jul 31, 2018 at 10:51 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
>
> Is it OK to overwrite ct->status? It seems that are some read and
> writes to it right after atomic_inc_not_zero.

If it is after a (successful) atomic_inc_not_zero(),
the object is guaranteed to be alive (not freed or about to be freed).

About readind/writing a specific field, all traditional locking rules apply.

For TCP socket, we would generally grab the socket lock before
reading/writing various fields.

ct->status seems to be manipulated with set_bit() and clear_bit()
which are SMP safe.
