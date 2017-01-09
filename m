Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF9F6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 05:04:16 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id wr1so2797810wjc.7
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 02:04:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22si9806850wmh.29.2017.01.09.02.04.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 02:04:14 -0800 (PST)
Subject: Re: [patch] mm, thp: add new background defrag option
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
 <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
 <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
 <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
Date: Mon, 9 Jan 2017 11:04:11 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/06/2017 11:20 PM, David Rientjes wrote:
> On Fri, 6 Jan 2017, Vlastimil Babka wrote:
> 
>> Deciding between "defer" and "background" is however confusing, and also
>> doesn't indicate that the difference is related to madvise.
>>
> 
> Any suggestions for a better name for "background" are more than welcome.  

Why not just "madvise+defer"?

>> I don't like bikesheding, but as this is about user-space API, more care
>> should be taken than for implementation details that can change. Even
>> though realistically there will be in 99% of cases only two groups of
>> users setting this
>> - experts like you who know what they are doing, and confusing names
>> won't prevent them from making the right choice
>> - people who will blindly copy/paste from the future cargo-cult websites
>> (if they ever get updated from the enabled="never" recommendations), who
>> likely won't stop and think about the other options.
>>
> 
> I think the far majority will go with a third option: simply use the 
> kernel default and be unaware of other settings or consider it to be the 
> most likely choice solely because it is the kernel default.

Sure, my prediction was only about "users setting this" :) Agreed that
those will be a small minority of all users.

[...]

> So whether it's better to do echo background or echo "madvise defer" is 
> not important to me, I simply imagine that the combination will be more 
> difficult to describe to users.  It would break our userspace to currently 
> tests for "[madvise]" and reports that state as strictly madvise to our 
> mission control, but I can work around that; not sure if others would 
> encounter the same issue (would "[defer madvise]" or "[defer] [madvise]" 
> break fewer userspaces?).

OK, well I'm reluctant to break existing userspace knowingly over such
silliness. Also apparently sysfs files in general should accept only one
value, so I'm not going to push my approach.

> I'd leave it to Andrew to decide whether sysfs files should accept 
> multiple modes or not.  If you are to propose a patch to do so, I'd 
> encourage you to do the same cleanup of triple_flag_store() that I did and 
> make the gfp mask construction more straight-forward.  If you'd like to 
> suggest a different name for "background", I'd be happy to change that if 
> it's more descriptive.

Suggestion is above. I however think your cleanup isn't really needed,
we can simply keep the existing 3 internal flags, and "madvise+defer"
would enable two of them, like in my patch. Nothing says that internally
each option should correspond to exactly one flag.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
