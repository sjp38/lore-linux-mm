Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 6A4706B0031
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 18:08:51 -0400 (EDT)
Message-ID: <51C8C36B.9020605@hurleysoftware.com>
Date: Mon, 24 Jun 2013 18:08:43 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] rwsem: do optimistic spinning for writer lock acquisition
References: <cover.1371855277.git.tim.c.chen@linux.intel.com>  <1371858700.22432.5.camel@schen9-DESK>  <51C558E2.1040108@hurleysoftware.com> <1372111092.22432.84.camel@schen9-DESK>
In-Reply-To: <1372111092.22432.84.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Alex Shi <alex.shi@intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 06/24/2013 05:58 PM, Tim Chen wrote:
> On Sat, 2013-06-22 at 03:57 -0400, Peter Hurley wrote:
>> Will this spin for full scheduler value on a reader-owned lock?
>>
>>> +		/* wait_lock will be acquired if write_lock is obtained */
>>> +		if (rwsem_try_write_lock(sem->count, true, sem)) {
>>> +			ret = 1;
>>> +			goto out;
>>> +		}
>>> +
>>> +		/*
>>> +		 * When there's no owner, we might have preempted between the
>>                                                           ^^^^^^^^
>>
>> Isn't pre-emption disabled?
>>
>
> Peter, on further review, this code is needed.  This code guard against
> the case of this thread preempting another thread in the middle
> of setting the  owner field.  Disabling preemption does not prevent this
> thread from preempting others, even though others cannot preempt
> this thread.

Yep; so the "we" in the quoted comment really refers to another thread
executing down_write_xxxx().

Thanks for the clarification.

Regards,
Peter Hurley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
