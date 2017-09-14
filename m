Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 01CBF6B0253
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 04:14:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d8so4790169pgt.1
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 01:14:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 99sor7566987pla.117.2017.09.14.01.14.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Sep 2017 01:14:03 -0700 (PDT)
Date: Thu, 14 Sep 2017 17:13:58 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 04/20] mm: VMA sequence count
Message-ID: <20170914081358.GG599@jagdpanzerIV.localdomain>
References: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1504894024-2750-5-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170913115354.GA7756@jagdpanzerIV.localdomain>
 <44849c10-bc67-b55e-5788-d3c6bb5e7ad1@linux.vnet.ibm.com>
 <20170914003116.GA599@jagdpanzerIV.localdomain>
 <441ff1c6-72a7-5d96-02c8-063578affb62@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <441ff1c6-72a7-5d96-02c8-063578affb62@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi,

On (09/14/17 09:55), Laurent Dufour wrote:
[..]
> > so if there are two CPUs, one doing write_seqcount() and the other one
> > doing read_seqcount() then what can happen is something like this
> > 
> > 	CPU0					CPU1
> > 
> > 						fs_reclaim_acquire()
> > 	write_seqcount_begin()
> > 	fs_reclaim_acquire()			read_seqcount_begin()
> > 	write_seqcount_end()
> > 
> > CPU0 can't write_seqcount_end() because of fs_reclaim_acquire() from
> > CPU1, CPU1 can't read_seqcount_begin() because CPU0 did write_seqcount_begin()
> > and now waits for fs_reclaim_acquire(). makes sense?
> 
> Yes, this makes sense.
> 
> But in the case of this series, there is no call to
> __read_seqcount_begin(), and the reader (the speculative page fault
> handler), is just checking for (vm_seq & 1) and if this is true, simply
> exit the speculative path without waiting.
> So there is no deadlock possibility.

probably lockdep just knows that those locks interleave at some
point.


by the way, I think there is one path that can spin

find_vma_srcu()
 read_seqbegin()
  read_seqcount_begin()
   raw_read_seqcount_begin()
    __read_seqcount_begin()

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
