Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id EFAF56B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 02:23:55 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so5740331wic.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:23:55 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id k6si2313746wiz.1.2015.05.06.23.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 23:23:54 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Thu, 7 May 2015 07:23:52 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1042517D8056
	for <linux-mm@kvack.org>; Thu,  7 May 2015 07:24:35 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t476NnXi7274904
	for <linux-mm@kvack.org>; Thu, 7 May 2015 06:23:49 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t476NmFw012384
	for <linux-mm@kvack.org>; Thu, 7 May 2015 00:23:49 -0600
Date: Thu, 7 May 2015 08:23:46 +0200
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 00/15] decouple pagefault_disable() from
 preempt_disable()
Message-ID: <20150507082346.3e8e045e@thinkpad-w530>
In-Reply-To: <20150506150158.0a927470007e8ea5f3278956@linux-foundation.org>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
	<20150506150158.0a927470007e8ea5f3278956@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

> > This series therefore does 2 things:
> > 
> > 
> > 1. Decouple pagefault_disable() from preempt_enable()
> > 
> > ...
> > 
> > 2. Reenable might_sleep() checks for might_fault()
> 
> All seems sensible to me.  pagefault_disabled has to go into the
> task_struct (rather than being per-cpu) because
> pagefault_disabled_inc() doesn't disable preemption, yes?
> 

Right, we can now get scheduled while in pagefault_disable() (if preemption
hasn't been disabled manually). So we have to store it per task/thread not per
cpu.

Actually even the preempt disable counter is only per-cpu for x86 and lives in
thread_info for all other archs (which is also not 100% clean but doesn't
matter at that point).

I had that pagefault disable counter in thread_info before, but that required
messing with asm-offsets of some arch (I had a proper version but this one
feels cleaner).

Thanks for having a look!

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
