Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7853C6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 08:58:51 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id k184so50712588wme.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 05:58:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si85556078wjh.265.2017.01.05.05.58.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 05:58:49 -0800 (PST)
Subject: Re: [patch] mm, thp: add new background defrag option
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
Date: Thu, 5 Jan 2017 14:58:47 +0100
MIME-Version: 1.0
In-Reply-To: <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/05/2017 11:13 AM, Mel Gorman wrote:
> On Wed, Jan 04, 2017 at 03:41:59PM -0800, David Rientjes wrote:
>> There is no thp defrag option that currently allows MADV_HUGEPAGE regions 
>> to do direct compaction and reclaim while all other thp allocations simply 
>> trigger kswapd and kcompactd in the background and fail immediately.
>>
>> The "defer" setting simply triggers background reclaim and compaction for 
>> all regions, regardless of MADV_HUGEPAGE, which makes it unusable for our 
>> userspace where MADV_HUGEPAGE is being used to indicate the application is 
>> willing to wait for work for thp memory to be available.
>>
>> The "madvise" setting will do direct compaction and reclaim for these
>> MADV_HUGEPAGE regions, but does not trigger kswapd and kcompactd in the 
>> background for anybody else.
>>
>> For reasonable usage, there needs to be a mesh between the two options.  
>> This patch introduces a fifth mode, "background", that will do direct 
>> reclaim and compaction for MADV_HUGEPAGE regions and trigger background 
>> reclaim and compaction for everybody else so that hugepages may be 
>> available in the near future.
>>
>> A proposal to allow direct reclaim and compaction for MADV_HUGEPAGE 
>> regions as part of the "defer" mode, making it a very powerful setting and 
>> avoids breaking userspace, was offered: 
>> http://marc.info/?t=148236612700003.  This additional mode is a 
>> compromise.
>>
>> This patch also cleans up the helper function for storing to "enabled" 
>> and "defrag" since the former supports three modes while the latter 
>> supports five and triple_flag_store() was getting unnecessarily messy.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>> ---
>>  I don't understand Mel's suggestion of "defer-fault" as option naming.
>>
> 
> defer-fault was intended to reflect "defer faults but not anything else"
> with the only sensible alternative being madvise requests. While not a

Hmm that's probably why it's hard to understand, because "madvise
request" is just setting a vma flag, and the THP allocation (and defrag)
still happens at fault.

I'm not a fan of either name, so I've tried to implement my own
suggestion. Turns out it was easier than expected, as there's no kernel
boot option for "defer", just for "enabled", so that particular worry
was unfounded.

And personally I think that it's less confusing when one can enable defer
and madvise together (and not any other combination), than having to dig
up the difference between "defer" and "background".

I have only tested the sysfs manipulation, not actual THP, but seems to me
that alloc_hugepage_direct_gfpmask() already happens to process the flags
in a way that it works as expected.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 10eedbf14421..cc5ae86169a8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -150,7 +150,16 @@ static ssize_t triple_flag_store(struct kobject *kobj,
 				 enum transparent_hugepage_flag deferred,
 				 enum transparent_hugepage_flag req_madv)
 {
-	if (!memcmp("defer", buf,
+	if (!memcmp("defer madvise", buf,
+			min(sizeof("defer madvise")-1, count))
+	    || !memcmp("madvise defer", buf,
+			min(sizeof("madvise defer")-1, count))) {
+		if (enabled == deferred)
+			return -EINVAL;
+		clear_bit(enabled, &transparent_hugepage_flags);
+		set_bit(req_madv, &transparent_hugepage_flags);
+		set_bit(deferred, &transparent_hugepage_flags);
+	} else if (!memcmp("defer", buf,
 		    min(sizeof("defer")-1, count))) {
 		if (enabled == deferred)
 			return -EINVAL;
@@ -251,9 +260,12 @@ static ssize_t defrag_show(struct kobject *kobj,
 {
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
 		return sprintf(buf, "[always] defer madvise never\n");
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
-		return sprintf(buf, "always [defer] madvise never\n");
-	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags)) {
+		if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
+			return sprintf(buf, "always [defer] [madvise] never\n");
+		else
+			return sprintf(buf, "always [defer] madvise never\n");
+	} else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
 		return sprintf(buf, "always defer [madvise] never\n");
 	else
 		return sprintf(buf, "always defer madvise [never]\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
