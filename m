Message-ID: <4414E2CB.7060604@yahoo.com.au>
Date: Mon, 13 Mar 2006 14:11:07 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/3] radix tree: RCU lockless read-side
References: <20060207021822.10002.30448.sendpatchset@linux.site>	 <20060207021831.10002.84268.sendpatchset@linux.site>	 <661de9470603110022i25baba63w4a79eb543c5db626@mail.gmail.com>	 <44128EDA.6010105@yahoo.com.au> <661de9470603121904h7e83579boe3b26013f771c0f2@mail.gmail.com>
In-Reply-To: <661de9470603121904h7e83579boe3b26013f771c0f2@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> On 3/11/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>Balbir Singh wrote:
>>
>>><snip>
>>>
>>>>               if (slot->slots[i]) {
>>>>-                       results[nr_found++] = slot->slots[i];
>>>>+                       results[nr_found++] = &slot->slots[i];
>>>>                       if (nr_found == max_items)
>>>>                               goto out;
>>>>               }
>>>
>>>
>>>A quick clarification - Shouldn't accesses to slot->slots[i] above be
>>>protected using rcu_derefence()?
>>>
>>
>>I think we're safe here -- this is the _address_ of the pointer.
>>However, when dereferencing this address in _gang_lookup,
>>I think we do need rcu_dereference indeed.
>>
> 
> 
> Yes, I saw the address operator, but we still derefence "slots" to get
> the address.
> 

But we should have already rcu_dereference()ed "slot", right
(in the loop above this one)? That means we are now able to
dereference it, and the data at the other end will be valid.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
