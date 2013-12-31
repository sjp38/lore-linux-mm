Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f175.google.com (mail-gg0-f175.google.com [209.85.161.175])
	by kanga.kvack.org (Postfix) with ESMTP id A98BB6B0035
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 11:42:34 -0500 (EST)
Received: by mail-gg0-f175.google.com with SMTP id u2so2495845ggn.6
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 08:42:34 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n44si51649115yhn.265.2013.12.31.08.42.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Dec 2013 08:42:33 -0800 (PST)
Message-ID: <52C2F3DC.2020106@oracle.com>
Date: Tue, 31 Dec 2013 11:42:04 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/2] mm: additional page lock debugging
References: <1388281504-11453-1-git-send-email-sasha.levin@oracle.com> <20131230114317.GA8117@node.dhcp.inet.fi> <52C1A06B.4070605@oracle.com> <20131230224808.GA11674@node.dhcp.inet.fi> <52C2385A.8020608@oracle.com> <20131231162636.GD16438@laptop.programming.kicks-ass.net>
In-Reply-To: <20131231162636.GD16438@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, akpm@linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>

On 12/31/2013 11:26 AM, Peter Zijlstra wrote:
> On Mon, Dec 30, 2013 at 10:22:02PM -0500, Sasha Levin wrote:
>
>> I really want to use lockdep here, but I'm not really sure how to handle locks which live
>> for a rather long while instead of being locked and unlocked in the same function like
>> most of the rest of the kernel. (Cc Ingo, PeterZ).
>
> Uh what? Lockdep doesn't care about which function locks and unlocks a
> particular lock. Nor does it care how long its held for.

Sorry, I messed up trying to explain that.

There are several places in the code which lock a large amount of pages, something like:

	for (i = 0; i < (1 << order); i++)
		lock_page(&pages[i]);


This triggers two problems:

  - lockdep complains about deadlock since we try to lock another page while one is already
locked. I can clear that by allowing page locks to nest within each other, but that seems
wrong and we'll miss actual deadlock cases.

  - We may leave back to userspace with pages still locked. This is valid behaviour but lockdep
doesn't like that.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
