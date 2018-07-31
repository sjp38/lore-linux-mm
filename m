Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8CD96B026B
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:51:31 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p5-v6so5091274pfh.11
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:51:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h67-v6sor3627679pgc.361.2018.07.31.10.51.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 10:51:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANn89iLLQP2vA+2J-zxL3Fa75zNw=yRmv3Jg6vcEc=fYeEZ2ow@mail.gmail.com>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CANn89iLLQP2vA+2J-zxL3Fa75zNw=yRmv3Jg6vcEc=fYeEZ2ow@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 31 Jul 2018 19:51:09 +0200
Message-ID: <CACT4Y+Y6dhNgisDM9hdP-M-Rnk66DxZWcX7v39ESGJR8RY3asQ@mail.gmail.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com, rodrigo.vivi@intel.com, David Airlie <airlied@linux.ie>, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jul 31, 2018 at 7:41 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Tue, Jul 31, 2018 at 10:36 AM Christopher Lameter <cl@linux.com> wrote:
>
>>
>> If there is refcounting going on then why use SLAB_TYPESAFE_BY_RCU?
>
> To allow fast reuse of objects, without going through call_rcu() and
> reducing cache efficiency.
>
> I believe this is mentioned in Documentation/RCU/rculist_nulls.txt


Is it OK to overwrite ct->status? It seems that are some read and
writes to it right after atomic_inc_not_zero.
