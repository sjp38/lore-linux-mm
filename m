Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 49B4D6B025E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 19:53:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p64so122607732pfb.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 16:53:35 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id s18si685956pal.122.2016.07.13.16.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 16:53:34 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id t190so23262108pfb.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 16:53:34 -0700 (PDT)
Date: Wed, 13 Jul 2016 16:53:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: System freezes after OOM
In-Reply-To: <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp> <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713145638.GM28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 13 Jul 2016, Mikulas Patocka wrote:

> What are the real problems that f9054c70d28bc214b2857cf8db8269f4f45a5e23 
> tries to fix?
> 

It prevents the whole system from livelocking due to an oom killed process 
stalling forever waiting for mempool_alloc() to return.  No other threads 
may be oom killed while waiting for it to exit.

> Do you have a stacktrace where it deadlocked, or was just a theoretical 
> consideration?
> 

schedule
schedule_timeout
io_schedule_timeout
mempool_alloc
__split_and_process_bio
dm_request
generic_make_request
submit_bio
mpage_readpages
ext4_readpages
__do_page_cache_readahead
ra_submit
filemap_fault
handle_mm_fault
__do_page_fault
do_page_fault
page_fault

> Mempool users generally (except for some flawed cases like fs_bio_set) do 
> not require memory to proceed. So if you just loop in mempool_alloc, the 
> processes that exhasted the mempool reserve will eventually return objects 
> to the mempool and you should proceed.
> 

That's obviously not the case if we have hundreds of machines timing out 
after two hours waiting for that fault to succeed.  The mempool interface 
cannot require that users return elements to the pool synchronous with all 
allocators so that we can happily loop forever, the only requirement on 
the interface is that mempool_alloc() must succeed.  If the context of the 
thread doing mempool_alloc() allows access to memory reserves, this will 
always be allowed by the page allocator.  This is not a mempool problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
