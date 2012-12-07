Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id AAF2F6B009A
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 17:59:09 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 7 Dec 2012 15:59:09 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1D60119D803E
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 15:59:06 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB7Mx5o6379622
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 15:59:05 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB7Mx5u4016765
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 15:59:05 -0700
Message-ID: <50C274B1.90408@linux.vnet.ibm.com>
Date: Fri, 07 Dec 2012 14:58:57 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Debugging: Keep track of page owners
References: <20121207212417.FAD8DAED@kernel.stglabs.ibm.com> <20121207142614.428b8a54.akpm@linux-foundation.org> <50C26FA7.9010000@linux.vnet.ibm.com> <20121207144428.98b3eaf4.akpm@linux-foundation.org>
In-Reply-To: <20121207144428.98b3eaf4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On 12/07/2012 02:44 PM, Andrew Morton wrote:
> AFACIT that difference was undescribed.  I can see that the new version
> uses the stack-tracing infrastructure, but the change to
> pagetypeinfo_showmixedcount_print() is a mystery.

Ahhh, I assume you're talking about this hunk:

>> @@ -976,10 +976,7 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
>>  
>>                         pagetype = allocflags_to_migratetype(page->gfp_mask);
>>                         if (pagetype != mtype) {
>> -                               if (is_migrate_cma(pagetype))
>> -                                       count[MIGRATE_MOVABLE]++;
>> -                               else
>> -                                       count[mtype]++;
>> +                               count[mtype]++;
>>                                 break;
>>                         }

That was to fix the comment that Laura Abbott made about it miscounting
MIGRATE_CMA pages.

My patch-sending scripts were choking a bit on the text description in
your patch.  I'm using a long-ago-forked copy of your patch-utils and
the DESC/EDESC in the patch I imported is giving them fits when I send
via email and stripping large parts of the description.  I'm happy to
resend via email, too, but here, the raw patch (will the full description):

	https://www.sr71.net/~dave/linux/pageowner.patch

The important description that the scripts managed to strip out when
emailed was this:

Updated 12/4/2012 - should apply to 3.7 kernels.  I did a quick
sniff-test to make sure that this boots and produces some sane
output, but it's not been exhaustively tested.

 * Moved file over to debugfs (no reason to keep polluting /proc)
 * Now using generic stack tracking infrastructure
 * Added check for MIGRATE_CMA pages to explicitly count them
   as movable.

The new snprint_stack_trace() probably belongs in its own patch
if this were to get merged, but it won't kill anyone as it stands.

-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
