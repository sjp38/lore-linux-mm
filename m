Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4A0C16B004A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 04:09:07 -0400 (EDT)
Message-ID: <4CC146B1.8060906@kernel.dk>
Date: Fri, 22 Oct 2010 10:09:21 +0200
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: Deadlock possibly caused by too_many_isolated.
References: <AANLkTimVu+5gTDs8przJVP2EbWC=FX-zWW7aH08BtrHC@mail.gmail.com> <20101020055717.GA12752@localhost> <20101020150346.1832.A69D9226@jp.fujitsu.com> <20101020092739.GA23869@localhost> <4CBEE888.2090606@kernel.dk> <20101022053755.GB16804@localhost> <20101022080725.GA22594@localhost>
In-Reply-To: <20101022080725.GA22594@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Torsten Kaiser <just.for.lkml@googlemail.com>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On 2010-10-22 10:07, Wu Fengguang wrote:
>>> We surely need 1 set aside for each level of that stack that will
>>> potentially consume one. 1 should be enough for the generic pool, and
>>> then clones will use a separate pool. So md and friends should really
>>> have a pool per device, so that stacking will always work properly.
>>
>> Agreed for the deadlock problem.
>>
>>> There should be no throughput concerns, it should purely be a safe guard
>>> measure to prevent us deadlocking when doing IO for reclaim.
>>
>> It's easy to verify whether the minimal size will have negative
>> impacts on IO throughput. In Torsten's case, increase BIO_POOL_SIZE
>> by one and check how it performs.
> 
> Sorry it seems simply increasing BIO_POOL_SIZE is not enough to fix
> possible deadlocks. We need adding new mempool(s). Because when there
> BIO_POOL_SIZE=2 and there are two concurrent reclaimers each take 1
> reservation, they will deadlock each other when trying to take the
> next bio at the raid1 level.

Yes, plus it's not a practical solution since you don't know how deep
the stack is. As I wrote in the initial email, each consumer needs it's
own private mempool (and just 1 entry should suffice).

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
