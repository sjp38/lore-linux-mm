Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id C17366B0261
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 19:06:10 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id x186so91244507vkd.1
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 16:06:10 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 103si1298264ual.244.2016.12.18.16.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 16:06:09 -0800 (PST)
Subject: Re: [RFC PATCH 04/14] sparc64: load shared id into context register 1
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
 <20161217.221442.430708127662119954.davem@davemloft.net>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <62091365-2797-ed99-847f-7281f4666633@oracle.com>
Date: Sun, 18 Dec 2016 16:06:01 -0800
MIME-Version: 1.0
In-Reply-To: <20161217.221442.430708127662119954.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@oracle.com, nitin.m.gupta@oracle.com, vijay.ac.kumar@oracle.com, julian.calaby@gmail.com, adam.buchbinder@gmail.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org

On 12/17/2016 07:14 PM, David Miller wrote:
> From: Mike Kravetz <mike.kravetz@oracle.com>
> Date: Fri, 16 Dec 2016 10:35:27 -0800
> 
>> In current code, only context ID register 0 is set and used by the MMU.
>> On sun4v platforms that support MMU shared context, there is an additional
>> context ID register: specifically context register 1.  When searching
>> the TLB, the MMU will find a match if the virtual address matches and
>> the ID contained in context register 0 -OR- context register 1 matches.
>>
>> Load the shared context ID into context ID register 1.  Care must be
>> taken to load register 1 after register 0, as loading register 0
>> overwrites both register 0 and 1.  Modify code loading register 0 to
>> also load register one if applicable.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> You can't make these register accesses if the feature isn't being
> used.
> 
> Considering the percentage of applications which will actually use
> this thing, incuring the overhead of even loading the shared context
> register is simply unacceptable.

Ok, let me try to find a way to eliminate these loads unless the application
is using shared context.

Part of the issue is a 'backwards compatibility' feature of the processor
which loads/overwrites register 1 every time register 0 is loaded.  Somewhere
in the evolution of the processor, a feature was added so that register 0
could be loaded without overwriting register 1.  That could be used to
eliminate the extra load in some/many cases.  But, that would likely lead
to more runtime kernel patching based on processor level.  And, I don't
really want to add more of that if possible.  Or, perhaps we only enable
the shared context ID feature on processors which have the ability to work
around the backwards compatibility feature.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
