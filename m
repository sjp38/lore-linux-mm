Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 260786B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 17:36:23 -0400 (EDT)
Received: by weys10 with SMTP id s10so921572wey.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 14:36:21 -0700 (PDT)
Message-ID: <501C4471.4090706@gmail.com>
Date: Fri, 03 Aug 2012 23:36:49 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com> <1344003788-1417-2-git-send-email-levinsasha928@gmail.com> <20120803171515.GH15477@google.com> <501C407D.9080900@gmail.com> <20120803213017.GK15477@google.com>
In-Reply-To: <20120803213017.GK15477@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

On 08/03/2012 11:30 PM, Tejun Heo wrote:
>> I think hash_for_for_each_possible() is useful if the comparison
>> > condition is more complex than a simple comparison of one of the
>> > object members with the key - there's no need to force it on all the
>> > users.
> I don't know.  What's the difference?  In terms of LOC, it might even
> not save any thanks to the extra function definition, right?  I don't
> think it's saving enough complexity to justify a separate rather
> unusual interface.

The function definition itself is just a macro, for example:

	#define MM_SLOTS_HASH_CMP(mm_slot, obj) ((mm_slot)->mm == (obj))

As an alternative, what do you think about simplifying that to be just a 'cond' instead of a function? Something like:

	hash_get(&mm_slots_hash, mm, struct mm_slot, hash, mm);

In that case, the last param ("mm") will get unrolled to a condition like this:

	if ((obj)->mm == key)

Which will be simple and easy for the user.


The only reason I want to keep this interface is that most cases I've stumbled so far were easy short comparisons of a struct member with the key, and I don't want to make them more complex than they need to be. I probably will switch hash_get() to use hash_for_each_possible() as well, which will cut down on how hash_get() is a separate case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
