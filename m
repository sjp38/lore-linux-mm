Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id A37596B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:29:52 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so3405363yha.7
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:29:52 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id v1si22057522yhg.226.2013.11.25.15.29.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Nov 2013 15:29:51 -0800 (PST)
Message-ID: <5293DD20.4020904@zytor.com>
Date: Mon, 25 Nov 2013 15:28:32 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
References: <20131120171400.GI4138@linux.vnet.ibm.com>	 <20131121110308.GC10022@twins.programming.kicks-ass.net>	 <20131121125616.GI3694@twins.programming.kicks-ass.net>	 <20131121132041.GS4138@linux.vnet.ibm.com>	 <20131121172558.GA27927@linux.vnet.ibm.com>	 <20131121215249.GZ16796@laptop.programming.kicks-ass.net>	 <20131121221859.GH4138@linux.vnet.ibm.com>	 <20131122155835.GR3866@twins.programming.kicks-ass.net>	 <20131122182632.GW4138@linux.vnet.ibm.com>	 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>	 <20131125173540.GK3694@twins.programming.kicks-ass.net>	 <52939C5A.3070208@zytor.com> <1385420302.11046.539.camel@schen9-DESK>
In-Reply-To: <1385420302.11046.539.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On 11/25/2013 02:58 PM, Tim Chen wrote:
> 
> Peter,
> 
> Want to check with you on Paul's example, 
> where we are indeed writing and reading to the same
> lock location when passing the lock on x86 with smp_store_release and
> smp_load_acquire.  So the unlock and lock sequence looks like:
> 
>         CPU 0 (releasing)       CPU 1 (acquiring)
>         -----                   -----
>         ACCESS_ONCE(X) = 1;     while (ACCESS_ONCE(lock) == 1)
>                                   continue;
>         ACCESS_ONCE(lock) = 0;  
>                                 r1 = ACCESS_ONCE(Y);
> 

Here we can definitely state that the read from Y must have happened
after X was set to 1 (assuming lock starts out as 1).

> observer CPU 2:
> 
>         CPU 2
>         -----
>         ACCESS_ONCE(Y) = 1;
>         smp_mb();
>         r2 = ACCESS_ONCE(X);
> 
> If the write and read to lock act as a full memory barrier, 
> it would be impossible to
> end up with (r1 == 0 && r2 == 0), correct?
> 

It would be impossible to end up with r1 == 1 && r2 == 0, I presume
that's what you meant.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
