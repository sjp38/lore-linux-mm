Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A23666B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 19:22:41 -0400 (EDT)
Message-ID: <4A4BEE1A.8090204@acm.org>
Date: Wed, 01 Jul 2009 17:15:38 -0600
From: Zan Lynx <zlynx@acm.org>
MIME-Version: 1.0
Subject: Re: Long lasting MM bug when swap is smaller than RAM
References: <20090630115819.38b40ba4.attila@kinali.ch>	<4A4ABD8F.40907@gmail.com>	<20090701100432.2d328e46.attila@kinali.ch> <20090701100834.1f740ad5.attila@kinali.ch>
In-Reply-To: <20090701100834.1f740ad5.attila@kinali.ch>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Attila Kinali <attila@kinali.ch>
Cc: Robert Hancock <hancockrwd@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Attila Kinali wrote:
> On Wed, 1 Jul 2009 10:04:32 +0200
> Attila Kinali <attila@kinali.ch> wrote:
> 
>>> But 
>>> swapping does not only occur if memory is running low. If disk usage is 
>>> high then non-recently used data may be swapped out to make more room 
>>> for disk caching.
>> Hmm..I didn't know this.. thanks!
> 
> This was the cause of the problem!
> 
> I just restarted svnserv, clamav and bind (the three applications
> using most memory) and suddenly swap cleared up.
> 
> Now the question is, why did they accumulate so much used swap
> space, while before the RAM upgrade, we hardly used the swap space at all?

I do not know about the others, but ClamAV suffers from pretty serious 
memory fragmentation.  What it does is load the updated signatures into 
a new memory allocation, verify them, then free the old signature 
allocation.  This results in a large hole in glibc's malloc structures 
and because of ClamAV's allocation pattern, this hole is difficult to 
reclaim.  This ClamAV memory fragmentation will continue to grow worse 
until the daemon is completely restarted.

Under memory pressure the kernel pushes least used pages out to swap, 
and these unused but still allocated pages of ClamAV are never again 
used, so out to swap they go.

I know this because the company I work for tried to fix the memory 
allocation fragmentation of ClamAV, but they did not like our patch and 
preferred to continue allowing the memory allocator to fragment in 
exchange for simpler code.

-- 
Zan Lynx
zlynx@acm.org

"Knowledge is Power.  Power Corrupts.  Study Hard.  Be Evil."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
