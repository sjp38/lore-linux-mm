Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 833E76B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:02:01 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so20983086pab.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 15:02:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fy2si84580pbb.129.2015.05.06.15.02.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 15:02:00 -0700 (PDT)
Date: Wed, 6 May 2015 15:01:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC 00/15] decouple pagefault_disable() from
 preempt_disable()
Message-Id: <20150506150158.0a927470007e8ea5f3278956@linux-foundation.org>
In-Reply-To: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <dahi@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Wed,  6 May 2015 19:50:24 +0200 David Hildenbrand <dahi@linux.vnet.ibm.com> wrote:

> As Peter asked me to also do the decoupling in one shot, this is
> the new series.
> 
> I recently discovered that might_fault() doesn't call might_sleep()
> anymore. Therefore bugs like:
> 
>   spin_lock(&lock);
>   rc = copy_to_user(...);
>   spin_unlock(&lock);
> 
> would not be detected with CONFIG_DEBUG_ATOMIC_SLEEP. The code was
> changed to disable false positives for code like:
> 
>   pagefault_disable();
>   rc = copy_to_user(...);
>   pagefault_enable();
> 
> Whereby the caller wants do deal with failures.

hm, that was a significant screwup.  I wonder how many bugs we
subsequently added.

>
> ..
>

> This series therefore does 2 things:
> 
> 
> 1. Decouple pagefault_disable() from preempt_enable()
> 
> ...
> 
> 2. Reenable might_sleep() checks for might_fault()

All seems sensible to me.  pagefault_disabled has to go into the
task_struct (rather than being per-cpu) because
pagefault_disabled_inc() doesn't disable preemption, yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
