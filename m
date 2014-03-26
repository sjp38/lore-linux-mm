Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id E30E96B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 17:46:20 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so2518124pbc.2
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 14:46:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id et3si14409926pbc.377.2014.03.26.14.46.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 14:46:20 -0700 (PDT)
Message-ID: <5333492D.2030300@oracle.com>
Date: Wed, 26 Mar 2014 17:39:57 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG: Bad page state in process ksmd
References: <5332EE97.4050604@oracle.com> <20140326125525.4e8090096f647f654eb7329d@linux-foundation.org>
In-Reply-To: <20140326125525.4e8090096f647f654eb7329d@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On 03/26/2014 03:55 PM, Andrew Morton wrote:
> On Wed, 26 Mar 2014 11:13:27 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
>> Out of curiosity, is there a reason not to do bad flag checks when actually
>> setting flag? Obviously it'll be slower but it'll be easier catching these
>> issues.
>
> Tricky.  Each code site must determine what are and are not valid page
> states depending upon the current context.  The one place where we've
> made that effort is at the point where a page is returned to the free
> page pool.  Any other sites would require similar amounts of effort and
> each one would be different from all the others.
>
> We do this in a small way all over the place, against individual page
> flags.  grep PageLocked */*.c.

What if we define generic page types and group page flags under them?
It would be easier to put these checks in key sites around the code
and no need to fully customize them to each site.

For exmaple, swap_readpage() is doing this:

         VM_BUG_ON_PAGE(!PageLocked(page), page);
         VM_BUG_ON_PAGE(PageUptodate(page), page);

But what if instead of that we'd do:

	VM_BUG_ON_PAGE(!PageSwap(page), page);

Where PageSwap would test "not locked", "uptodate", and in addition
a set of "sanity" flags which it didn't make sense to test individually
everywhere (PageError()? PageReclaim()?).

I can add the infrastructure if that sounds good (and people promise to
work with me on defining page types). I'd be happy to do all the testing
involved in getting this to work right.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
