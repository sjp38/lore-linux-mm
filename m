Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id CE5286B0038
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:35:02 -0400 (EDT)
Received: by wgme6 with SMTP id e6so12014294wgm.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:35:02 -0700 (PDT)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com. [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id k2si18433295wia.122.2015.06.11.14.35.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 14:35:01 -0700 (PDT)
Received: by wgbgq6 with SMTP id gq6so11989346wgb.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:35:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5579FABE.4050505@fb.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
	<1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
	<5579FABE.4050505@fb.com>
Date: Thu, 11 Jun 2015 17:35:00 -0400
Message-ID: <CAATkVEw93KaUQuNJY9hxA+q2dxPb2AAxicojkjDfXDZU5VGxtg@mail.gmail.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
From: Debabrata Banerjee <dbavatar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Shaohua Li <shli@fb.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>, Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Joshua Hunt <johunt@akamai.com>, "Banerjee, Debabrata" <dbanerje@akamai.com>

There is no "background" it doesn't matter if this activity happens
synchronously or asynchronously, unless you're sensitive to the
latency on that single operation. If you're driving all your cpu's and
memory hard then this is work that still takes resources. If there's a
kernel thread with compaction running, then obviously your process is
not.

Your patch should help in that not every atomic allocation failure
should mean yet another run at compaction/reclaim.

-Deb

On Thu, Jun 11, 2015 at 5:16 PM, Chris Mason <clm@fb.com> wrote:

> networking is asking for 32KB, and the MM layer is doing what it can to
> provide it.  Are the gains from getting 32KB contig bigger than the cost
> of moving pages around if the MM has to actually go into compaction?
> Should we start disk IO to give back 32KB contig?
>
> I think we want to tell the MM to compact in the background and give
> networking 32KB if it happens to have it available.  If not, fall back
> to smaller allocations without doing anything expensive.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
