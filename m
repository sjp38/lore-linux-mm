Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19F6C6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 11:29:42 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id i42so10926650otb.0
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 08:29:42 -0700 (PDT)
Received: from mail-ot0-x244.google.com (mail-ot0-x244.google.com. [2607:f8b0:4003:c0f::244])
        by mx.google.com with ESMTPS id i64si1992171oia.144.2017.06.08.08.29.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 08:29:41 -0700 (PDT)
Received: by mail-ot0-x244.google.com with SMTP id t31so3801364ota.2
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 08:29:41 -0700 (PDT)
Subject: Re: Sleeping BUG in khugepaged for i586
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
 <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
From: Larry Finger <Larry.Finger@lwfinger.net>
Message-ID: <a94e1315-aded-0984-327e-e091e76b4a66@lwfinger.net>
Date: Thu, 8 Jun 2017 10:29:38 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/07/2017 03:56 PM, David Rientjes wrote:
> On Wed, 7 Jun 2017, Vlastimil Babka wrote:
> 
>>>> Hmm I'd expect such spin lock to be reported together with mmap_sem in
>>>> the debugging "locks held" message?
>>>
>>> My bisection of the problem is about half done. My latest good version is commit
>>> 7b8cd33 and the latest bad one is 2ea659a. Only about 7 steps to go.
>>
>> Hmm, your bisection will most likely just find commit 338a16ba15495
>> which added the cond_resched() at mm/khugepaged.c:655. CCing David who
>> added it.
>>
> 
> I agree it's probably going to bisect to 338a16ba15495 since it's the
> cond_resched() at the line number reported, but I think there must be
> something else going on.  I think the list of locks held by khugepaged is
> correct because it matches with the implementation.  The preempt_count(),
> as suggested by Andrew, does not.  If this is reproducible, I'd like to
> know what preempt_count() is.
> 

The BUG output is reproducible. By the time the box finishes booting, there are 
at least 2 of them logged. My bisection shows that commit 338a16ba15495 is the 
bad one. I added a pr_info() to output the value of preempt_count() just before 
the cond_resched() statement. The count was always 1 whether the BUG was 
triggered or not.

If there are other things you would like logged at that point, or any other 
diagnostics, please let me know.

Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
