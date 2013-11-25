Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f54.google.com (mail-qe0-f54.google.com [209.85.128.54])
	by kanga.kvack.org (Postfix) with ESMTP id DD20B6B00E7
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 13:53:34 -0500 (EST)
Received: by mail-qe0-f54.google.com with SMTP id cy11so2658358qeb.13
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:53:34 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id b15si431219qey.96.2013.11.25.10.53.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Nov 2013 10:53:34 -0800 (PST)
Message-ID: <52939C5A.3070208@zytor.com>
Date: Mon, 25 Nov 2013 10:52:10 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
References: <20131120171400.GI4138@linux.vnet.ibm.com> <20131121110308.GC10022@twins.programming.kicks-ass.net> <20131121125616.GI3694@twins.programming.kicks-ass.net> <20131121132041.GS4138@linux.vnet.ibm.com> <20131121172558.GA27927@linux.vnet.ibm.com> <20131121215249.GZ16796@laptop.programming.kicks-ass.net> <20131121221859.GH4138@linux.vnet.ibm.com> <20131122155835.GR3866@twins.programming.kicks-ass.net> <20131122182632.GW4138@linux.vnet.ibm.com> <20131122185107.GJ4971@laptop.programming.kicks-ass.net> <20131125173540.GK3694@twins.programming.kicks-ass.net>
In-Reply-To: <20131125173540.GK3694@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On 11/25/2013 09:35 AM, Peter Zijlstra wrote:
> 
> I think this means x86 needs help too.
> 
> Consider:
> 
> x = y = 0
> 
>   w[x] = 1  |  w[y] = 1
>   mfence    |  mfence
>   r[y] = 0  |  r[x] = 0
> 
> This is generally an impossible case, right? (Since if we observe y=0
> this means that w[y]=1 has not yet happened, and therefore x=1, and
> vice-versa).
> 
> Now replace one of the mfences with smp_store_release(l1);
> smp_load_acquire(l2); such that we have a RELEASE+ACQUIRE pair that
> _should_ form a full barrier:
> 
>   w[x] = 1   | w[y] = 1
>   w[l1] = 1  | mfence
>   r[l2] = 0  | r[x] = 0
>   r[y] = 0   |
> 
> At which point we can observe the impossible, because as per the rule:
> 
> 'reads may be reordered with older writes to different locations'
> 
> Our r[y] can slip before the w[x]=1.
> 

Yes, because although r[l2] and r[y] are ordered with respect to each
other, they are allowed to be executed before w[x] and w[l1].  In other
words, smp_store_release() followed by smp_load_acquire() to a different
location do not form a full barrier.  To the *same* location, they will.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
