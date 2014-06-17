Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 52FD46B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 23:45:48 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id j17so7146568oag.38
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 20:45:48 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id p14si17761122oel.23.2014.06.16.20.45.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 20:45:47 -0700 (PDT)
Message-ID: <539FB9E6.2030601@hp.com>
Date: Mon, 16 Jun 2014 23:45:42 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, thp: move invariant bug check out of loop in __split_huge_page_map
References: <1402947348-60655-1-git-send-email-Waiman.Long@hp.com> <20140616204934.GA14208@node.dhcp.inet.fi> <20140616205946.GB14208@node.dhcp.inet.fi>
In-Reply-To: <20140616205946.GB14208@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On 06/16/2014 04:59 PM, Kirill A. Shutemov wrote:
> On Mon, Jun 16, 2014 at 11:49:34PM +0300, Kirill A. Shutemov wrote:
>> On Mon, Jun 16, 2014 at 03:35:48PM -0400, Waiman Long wrote:
>>> In the __split_huge_page_map() function, the check for
>>> page_mapcount(page) is invariant within the for loop. Because of the
>>> fact that the macro is implemented using atomic_read(), the redundant
>>> check cannot be optimized away by the compiler leading to unnecessary
>>> read to the page structure.
> And atomic_read() is *not* atomic operation. It's implemented as
> dereferencing though cast to volatile, which suppress compiler
> optimization, but doesn't affect what CPU can do with the variable.
>
> So I doubt difference will be measurable anywhere.
>

Because it is treated as an volatile object, the compiler will have to 
reread the value of the relevant page structure field in every iteration 
of the loop (512 for x86) when pmd_write(*pmd) is true. I saw some 
slight improvement (about 2%) of a microbench that I wrote to break up 
1000 THPs with 1000 forked processes.

-Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
