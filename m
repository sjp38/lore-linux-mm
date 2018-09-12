Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 144048E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:49:25 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id e14-v6so1870746qtp.17
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:49:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b143-v6si1027120qka.158.2018.09.12.08.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 08:49:24 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] fs/dcache: Eliminate branches in
 nr_dentry_negative accounting
References: <1536693506-11949-1-git-send-email-longman@redhat.com>
 <1536693506-11949-5-git-send-email-longman@redhat.com>
 <20180912023610.GB20056@bombadil.infradead.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <bf7592c3-dc1d-635e-8bb0-717f6e8a54d9@redhat.com>
Date: Wed, 12 Sep 2018 11:49:22 -0400
MIME-Version: 1.0
In-Reply-To: <20180912023610.GB20056@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 09/11/2018 10:36 PM, Matthew Wilcox wrote:
> On Tue, Sep 11, 2018 at 03:18:26PM -0400, Waiman Long wrote:
>> Because the accounting of nr_dentry_negative depends on whether a dentry
>> is a negative one or not, branch instructions are introduced to handle
>> the accounting conditionally. That may potentially slow down the task
>> by a noticeable amount if that introduces sizeable amount of additional
>> branch mispredictions.
>>
>> To avoid that, the accounting code is now modified to use conditional
>> move instructions instead, if supported by the architecture.
> You're substituting your judgement here for the compiler's.  I don't
> see a reason why the compiler couldn't choose to use a cmov in order
> to do this:
>
> 	if (dentry->d_flags & DCACHE_LRU_LIST)
> 		this_cpu_inc(nr_dentry_negative);
>
> unless our macrology has got too clever for the compilre to see through
> it.  In which case, the right answer is to simplify the percpu code,
> not to force the compiler to optimise the code in the way that makes
> sense for your current microarchitecture.
>
I had actually looked at the x86 object file generated to verify that it
did use cmove with the patch and use branch without. It is possible that
there are other twists to make that happen with the above expression. I
will need to run some experiments to figure it out. In the mean time, I
am fine with dropping this patch as it is a micro-optimization that
doesn't change the behavior at all.

Cheers,
Longman
