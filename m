Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id A92876B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 02:37:26 -0400 (EDT)
Received: by mail-ia0-f182.google.com with SMTP id u8so4310547iag.27
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 23:37:25 -0700 (PDT)
Message-ID: <5161141C.8030007@gmail.com>
Date: Sun, 07 Apr 2013 14:37:16 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: page_alloc: Avoid marking zones full prematurely
 after zone_reclaim()
References: <20130320181957.GA1878@suse.de> <514A7163.5070700@gmail.com> <20130321081902.GD6094@dhcp22.suse.cz> <515E6FC4.5000202@gmail.com>
In-Reply-To: <515E6FC4.5000202@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hedi Berriche <hedi@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Ping!
On 04/05/2013 02:31 PM, Simon Jeons wrote:
> Hi Michal,
> On 03/21/2013 04:19 PM, Michal Hocko wrote:
>> On Thu 21-03-13 10:33:07, Simon Jeons wrote:
>>> Hi Mel,
>>> On 03/21/2013 02:19 AM, Mel Gorman wrote:
>>>> The following problem was reported against a distribution kernel when
>>>> zone_reclaim was enabled but the same problem applies to the mainline
>>>> kernel. The reproduction case was as follows
>>>>
>>>> 1. Run numactl -m +0 dd if=largefile of=/dev/null
>>>>     This allocates a large number of clean pages in node 0
>>> I confuse why this need allocate a large number of clean pages?
>> It reads from file and puts pages into the page cache. The pages are not
>> modified so they are clean. Output file is /dev/null so no pages are
>> written. dd doesn't call fadvise(POSIX_FADV_DONTNEED) on the input file
>> by default so pages from the file stay in the page cache
>
> I try this in v3.9-rc5:
> dd if=/dev/sda of=/dev/null bs=1MB
> 14813+0 records in
> 14812+0 records out
> 14812000000 bytes (15 GB) copied, 105.988 s, 140 MB/s
>
> free -m -s 1
>
>                    total       used       free     shared buffers     
> cached
> Mem:          7912       1181       6731          0 663        239
> -/+ buffers/cache:        277       7634
> Swap:         8011          0       8011
>
> It seems that almost 15GB copied before I stop dd, but the used pages 
> which I monitor during dd always around 1200MB. Weird, why?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
