Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 707016B000C
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 16:20:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d18-v6so4603728edp.0
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 13:20:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j44-v6si7685846eda.76.2018.08.06.13.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 13:20:22 -0700 (PDT)
Date: Mon, 6 Aug 2018 22:20:17 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Message-ID: <20180806202017.lrzihv42b4mtcgrn@quack2.suse.cz>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
 <CA+55aFzYLgyNp1jsqsvUOjwZdO_1Piqj=iB=rzDShjScdNtkbg@mail.gmail.com>
 <CACT4Y+aYZumcc-Od5T1AnP4mwn8-FaWfxvfb93MnNwQPqG8TDw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+aYZumcc-Od5T1AnP4mwn8-FaWfxvfb93MnNwQPqG8TDw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, Network Development <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Dave Airlie <airlied@linux.ie>, intel-gfx <intel-gfx@lists.freedesktop.org>, DRI <dri-devel@lists.freedesktop.org>, Eric Dumazet <edumazet@google.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>

On Wed 01-08-18 10:46:35, Dmitry Vyukov wrote:
> I guess it would be useful to have such extensive comment for each
> SLAB_TYPESAFE_BY_RCU use explaining why it is needed and how all the
> tricky aspects are handled.
> 
> For example, the one in jbd2 is interesting because it memsets the
> whole object before freeing it into SLAB_TYPESAFE_BY_RCU slab:
> 
> memset(jh, JBD2_POISON_FREE, sizeof(*jh));
> kmem_cache_free(jbd2_journal_head_cache, jh);
> 
> I guess there are also tricky ways how it can all work in the end
> (type-stable state is only a byte, or we check for all possible
> combinations of being overwritten with JBD2_POISON_FREE). But at first
> sight it does look fishy.

The RCU access is used from a single place:

fs/jbd2/transaction.c: jbd2_write_access_granted()

There are also quite some comments explaining why what it does is safe. The
overwrite by JBD2_POISON_FREE is much older than this RCU stuff (honestly I
didn't know about it until this moment) and has nothing to do with the
safety of RCU access.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
