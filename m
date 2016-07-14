Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B12E86B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 16:22:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p64so175580831pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:22:43 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id t4si5603007pfb.266.2016.07.14.13.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 13:22:42 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id dx3so31868197pab.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:22:42 -0700 (PDT)
Date: Thu, 14 Jul 2016 13:22:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: System freezes after OOM
In-Reply-To: <alpine.LRH.2.02.1607140818250.15554@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.10.1607141316240.68666@chino.kir.corp.google.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp> <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713145638.GM28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1607140818250.15554@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com

On Thu, 14 Jul 2016, Mikulas Patocka wrote:

> > schedule
> > schedule_timeout
> > io_schedule_timeout
> > mempool_alloc
> > __split_and_process_bio
> > dm_request
> > generic_make_request
> > submit_bio
> > mpage_readpages
> > ext4_readpages
> > __do_page_cache_readahead
> > ra_submit
> > filemap_fault
> > handle_mm_fault
> > __do_page_fault
> > do_page_fault
> > page_fault
> 
> Device mapper should be able to proceed if there is no available memory. 
> If it doesn't proceed, there is a bug in it.
> 

The above stack trace has nothing to do with the device mapper with 
pre-f9054c70d28b behavior.  It simply is calling into mempool_alloc() and 
no elements are being returned to the mempool that allow it to return.

Recall that in the above situation, the whole system is oom; nothing can 
allocate memory.  The oom killer has selected the above process to be oom 
killed, so all other processes on the system trying to allocate memory 
will stall in the page allocator waiting for this process to exit.

The natural response to this situation is to allow access to memory 
reserves, if possible, so that mempool_alloc() may return.  There is no 
guarantee that _anything_ can return memory to the mempool, especially in 
a system oom condition where nothing can make forward progress.  Insisting 
that should be guaranteed is not helpful.

> I'd like to ask - what device mapper targets did you use in this case? Are 
> there some other deadlocked processes? (show sysrq-t, sysrq-w when this 
> happened)
> 

Every process on the system is deadlocked because they cannot get memory 
through the page allocator until the above process exits.  That is how the 
oom killer works: select a process, kill it, give it access to memory 
reserves so it may exit and free its memory, and wait.

> Did the machine lock up completely with that stacktrace, or was it just 
> slowed down?
> 

Hundreds of machines locked up and rebooted after a two hour watchdog 
timeout.

> > That's obviously not the case if we have hundreds of machines timing out 
> > after two hours waiting for that fault to succeed.  The mempool interface 
> > cannot require that users return elements to the pool synchronous with all 
> > allocators so that we can happily loop forever, the only requirement on 
> 
> Mempool users must return objects to the mempool.
> 

Not possible when the system is livelocked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
