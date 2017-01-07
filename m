Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1071C6B0069
	for <linux-mm@kvack.org>; Sat,  7 Jan 2017 13:37:43 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id c80so26933581iod.4
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 10:37:43 -0800 (PST)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id m94si3420430iod.161.2017.01.07.10.37.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Jan 2017 10:37:42 -0800 (PST)
Received: by mail-io0-x234.google.com with SMTP id j13so315340iod.3
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 10:37:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170107092746.GC5047@dhcp22.suse.cz>
References: <20170106095115.GG5556@dhcp22.suse.cz> <20170106100433.GH5556@dhcp22.suse.cz>
 <20170106121642.GJ5556@dhcp22.suse.cz> <1483740889.9712.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170107092746.GC5047@dhcp22.suse.cz>
From: Eric Dumazet <edumazet@google.com>
Date: Sat, 7 Jan 2017 10:37:41 -0800
Message-ID: <CANn89iL7JTkV_r9Wqqcrsz1GJmTfWtxD1TUV1YOKsv3rwN-+vQ@mail.gmail.com>
Subject: Re: weird allocation pattern in alloc_ila_locks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Tom Herbert <tom@herbertland.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat, Jan 7, 2017 at 1:27 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 06-01-17 14:14:49, Eric Dumazet wrote:

>> I believe the intent was to get NUMA spreading, a bit like what we have
>> in alloc_large_system_hash() when hashdist == HASHDIST_DEFAULT
>
> Hmm, I am not sure this works as expected then. Because it is more
> likely that all pages backing the vmallocked area will come from the
> local node than spread around more nodes. Or did I miss your point?

Well, you missed that vmalloc() is aware of NUMA policies.

If current process has requested interleave on 2 nodes (as it is done
at boot time on a dual node system),
then vmalloc() of 8 pages will allocate 4 pages on each node.

If you force/attempt a kmalloc() of one order-3 page, chances are very
high to get all memory on one single node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
