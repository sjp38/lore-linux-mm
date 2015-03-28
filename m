Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE946B0038
	for <linux-mm@kvack.org>; Sat, 28 Mar 2015 00:18:30 -0400 (EDT)
Received: by ykcn8 with SMTP id n8so46570501ykc.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 21:18:29 -0700 (PDT)
Received: from mail-yh0-x22b.google.com (mail-yh0-x22b.google.com. [2607:f8b0:4002:c01::22b])
        by mx.google.com with ESMTPS id h70si2563860yhd.1.2015.03.27.21.18.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 21:18:29 -0700 (PDT)
Received: by yhjf44 with SMTP id f44so44444108yhj.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 21:18:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150327093023.GA32047@worktop.ger.corp.intel.com>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
	<20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
	<CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
	<20150327091613.GE27490@worktop.programming.kicks-ass.net>
	<20150327093023.GA32047@worktop.ger.corp.intel.com>
Date: Sat, 28 Mar 2015 09:48:28 +0530
Message-ID: <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Mar 27, 2015 at 3:00 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Fri, Mar 27, 2015 at 10:16:13AM +0100, Peter Zijlstra wrote:

>> So the issue seems to be that we need base->running_timer in order to
>> tell if a callback is running, right?
>>
>> We could align the base on 8 bytes to gain an extra bit in the pointer
>> and use that bit to indicate the running state. Then these sites can
>> spin on that bit while we can change the actual base pointer.
>
> Even though tvec_base has ____cacheline_aligned stuck on, most are
> allocated using kzalloc_node() which does not actually respect that but
> already guarantees a minimum u64 alignment, so I think we can use that
> third bit without too much magic.

Right. So what I tried earlier was very much similar to you are suggesting.
The only difference was that I haven't made much attempts towards
saving memory.

But Thomas didn't like it for sure and I believe that Rant will hold true for
what you are suggesting as well, isn't it ?

http://lists.linaro.org/pipermail/linaro-kernel/2013-November/008866.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
