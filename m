Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B980A6B000A
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 11:52:47 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id m2-v6so13867070plt.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:52:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 196-v6si16499218pgg.588.2018.08.01.08.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 Aug 2018 08:52:46 -0700 (PDT)
Date: Wed, 1 Aug 2018 08:51:36 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Misuse of constructors
Message-ID: <20180801155136.GB4039@bombadil.infradead.org>
References: <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
 <CA+55aFzYLgyNp1jsqsvUOjwZdO_1Piqj=iB=rzDShjScdNtkbg@mail.gmail.com>
 <30ee6c72-dc90-275a-8e23-54221f393cb0@virtuozzo.com>
 <c03fd1ca-0169-4492-7d6f-2df7a91bff5e@gmail.com>
 <CACT4Y+bLbDunoz+0qB=atbQXJ9Gu3N6+UXPwNnqMbq5RyZu1mQ@mail.gmail.com>
 <cf751136-c459-853a-0210-abf16f54ad17@gmail.com>
 <CACT4Y+b6aCHMTQD21fSf2AMZoH5g8p-FuCVHviMLF00uFV+zGg@mail.gmail.com>
 <01000164f60f3f12-b1253c6e-ee57-49fc-aed8-0944ab4fd7a2-000000@email.amazonses.com>
 <CANn89i+KtwtLvSw1c=Ux8okKP+XyMxzYbuKhYb2qhYeMw=NTzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANn89i+KtwtLvSw1c=Ux8okKP+XyMxzYbuKhYb2qhYeMw=NTzg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, jack@suse.com, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com, rodrigo.vivi@intel.com, airlied@linux.ie, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, linux-fsdevel@vger.kernel.org

On Wed, Aug 01, 2018 at 08:37:07AM -0700, Eric Dumazet wrote:
> The idea of having a ctor() would only be a win if all the fields that
> can be initialized in the ctor are contiguous and fill an integral
> number of cache lines.

Let's state it more generally: Having a ctor is only a win if it allows
the user to avoid reading or writing a significant number of cachelines.

For example, the radix tree node occupies nine cachelines (576 bytes).
The typical user will touch two of those cacheliens (the header and the
cacheline which contains the slot of interest).  That's seven cachelines
which don't even need to be read, let alone written.

I think filesystems are particularly prone to this antipattern of
initialising some of their inode with a ctor and the remainder at
alloc_inode() time (compare the locations of the struct members touched
by inode_init_always() and inode_init_once()).
