Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 45B7D6B0044
	for <linux-mm@kvack.org>; Thu,  3 May 2012 16:27:02 -0400 (EDT)
Message-ID: <4FA2EA08.9030109@redhat.com>
Date: Thu, 03 May 2012 16:26:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mlock: split the shmlock_user_lock spinlock into
 per user_struct spinlock
References: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com> <1336073474.6509.2.camel@twins>
In-Reply-To: <1336073474.6509.2.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: rajman mekaco <rajman.mekaco@gmail.com>, Ingo Molnar <mingo@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/03/2012 03:31 PM, Peter Zijlstra wrote:
> On Thu, 2012-05-03 at 23:04 +0530, rajman mekaco wrote:
>> The user_shm_lock and user_shm_unlock functions use a single global
>> spinlock for protecting the user->locked_shm.
>
> Are you very sure its only protecting user state? This changelog doesn't
> convince me you've gone through everything and found it good.
>
>> This is an overhead for multiple CPUs calling this code even if they
>> are having different user_struct.
>>
>> Remove the global shmlock_user_lock and introduce and use a new
>> spinlock inside of the user_struct structure.
>
> While I don't immediately see anything wrong with it, I doubt its
> useful. What workload run with enough users that this makes a difference
> one way or another?

When running with containers and/or LXC, I believe that
each UID in each container gets its own user_struct, but
you do raise a good question - what user programs call
mlock anyway, and how often?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
