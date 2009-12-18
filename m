Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B07EC6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:09:55 -0500 (EST)
Message-ID: <4B2B8D2A.1020804@redhat.com>
Date: Fri, 18 Dec 2009 09:09:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091217193818.9FA9.A69D9226@jp.fujitsu.com> <4B2A22C0.8080001@redhat.com> <20091218184046.6547.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091218184046.6547.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: lwoodman@redhat.com, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 12/18/2009 05:27 AM, KOSAKI Motohiro wrote:
>> KOSAKI Motohiro wrote:

>> Finally, having said all that, the system still struggles reclaiming
>> memory with
>> ~10000 processes trying at the same time, you fix one bottleneck and it
>> moves
>> somewhere else.  The latest run showed all but one running process
>> spinning in
>> page_lock_anon_vma() trying for the anon_vma_lock.  I noticed that there
>> are
>> ~5000 vma's linked to one anon_vma, this seems excessive!!!
>>
>> I changed the anon_vma->lock to a rwlock_t and page_lock_anon_vma() to use
>> read_lock() so multiple callers could execute the page_reference_anon code.
>> This seems to help quite a bit.
>
> Ug. no. rw-spinlock is evil. please don't use it. rw-spinlock has bad
> performance characteristics, plenty read_lock block write_lock for very
> long time.
>
> and I would like to confirm one thing. anon_vma design didn't change
> for long year. Is this really performance regression? Do we strike
> right regression point?

In 2.6.9 and 2.6.18 the system would hit different contention
points before getting to the anon_vma lock.  Now that we've
gotten the other contention points out of the way, this one
has finally been exposed.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
