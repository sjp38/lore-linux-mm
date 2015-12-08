Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 860036B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 06:19:32 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so10751194pac.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 03:19:32 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id xp4si4622476pac.213.2015.12.08.03.19.31
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 03:19:31 -0800 (PST)
Subject: Re: [Intel-gfx] [PATCH v2 1/2] mm: Export nr_swap_pages
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <20151207134812.GA20782@dhcp22.suse.cz> <20151207164831.GA7256@cmpxchg.org>
 <5665CB78.7000106@intel.com> <20151207191346.GA3872@cmpxchg.org>
From: Dave Gordon <david.s.gordon@intel.com>
Message-ID: <5666BCC0.50507@intel.com>
Date: Tue, 8 Dec 2015 11:19:28 +0000
MIME-Version: 1.0
In-Reply-To: <20151207191346.GA3872@cmpxchg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>

On 07/12/15 19:13, Johannes Weiner wrote:
> On Mon, Dec 07, 2015 at 06:10:00PM +0000, Dave Gordon wrote:
>> Exporting random uncontrolled variables from the kernel to loaded modules is
>> not really considered best practice. It would be preferable to provide an
>> accessor function - which is just what the declaration says we have; the
>> implementation as a static inline (and/or macro) is what causes the problem
>> here.
>
> No, what causes the problem is thinking we can't trust in-kernel code.

We 'trust' kernel code not to be malicious, but not to be designed or 
implemented without mistakes. Keeping the impact of the mistakes as 
small and local as possible increases overall system reliability and 
makes debugging easier, which leads to the general principle of only 
exporting the minimum necessary interfaces. If no other module should 
write this data, then let's not export it as a read-write variable.

> If somebody screws up, we can fix it easily enough. Sure, we shouldn't
> be laying traps and create easy-to-misuse interfaces, but that's not
> what's happening here. There is no reason to add function overhead to
> what should be a single 'mov' instruction.

It could still be a macro or local inline within the mm code, but 
provide a read-only function-call interface for external use. That gives 
you maximum efficiency within the owning module, and makes it clear just 
what sort of access is allowed outside that code.

.Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
