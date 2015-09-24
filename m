Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id E5B1582F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:41:10 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so84563775ioi.2
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:41:10 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id e4si5230152igt.51.2015.09.24.10.41.10
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 10:41:10 -0700 (PDT)
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <20150924092320.GA26876@gmail.com> <20150924093026.GA29699@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560435B4.1010603@sr71.net>
Date: Thu, 24 Sep 2015 10:41:08 -0700
MIME-Version: 1.0
In-Reply-To: <20150924093026.GA29699@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 09/24/2015 02:30 AM, Ingo Molnar wrote:
>> To answer your question in the comment: it looks useful to have some sort of 
>> 'extended page fault error code' information here, which shows why the page fault 
>> happened. With the regular error_code it's easy - with protection keys there's 16 
>> separate keys possible and user-space might not know the actual key value in the 
>> pte.
> 
> Btw., alternatively we could also say that user-space should know what protection 
> key it used when it created the mapping - there's no need to recover it for every 
> page fault.

That's true.  We don't, for instance, tell userspace whether it was a
write that caused a fault.

But, other than smaps we don't have *any* way to tell userspace what
protection key a page has.  I think some mechanism is going to be
required for this to be reasonably debuggable.

> OTOH, as long as we don't do a separate find_vma(), it looks cheap enough to look 
> up the pkey value of that address and give it to user-space in the signal frame.

I still think that find_vma() in this case is pretty darn cheap,
definitely if you compare it to the cost of the entire fault path.

> Btw., how does pkey support interact with hugepages?

Surprisingly little.  I've made sure that everything works with huge
pages and that the (huge) PTEs and VMAs get set up correctly, but I'm
not sure I had to touch the huge page code at all.  I have test code to
ensure that it works the same as with small pages, but everything worked
pretty naturally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
