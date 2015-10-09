Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C25006B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 05:25:09 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so82256714pac.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 02:25:09 -0700 (PDT)
Received: from mgwym02.jp.fujitsu.com (mgwym02.jp.fujitsu.com. [211.128.242.41])
        by mx.google.com with ESMTPS id bi5si1167996pbc.38.2015.10.09.02.25.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 02:25:08 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 737FAAC073E
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 18:25:05 +0900 (JST)
Subject: Re: [PATCH][RFC] mm: Introduce kernelcore=reliable option
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <561762DC.3080608@huawei.com>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <561787DA.4040809@jp.fujitsu.com>
Date: Fri, 9 Oct 2015 18:24:42 +0900
MIME-Version: 1.0
In-Reply-To: <561762DC.3080608@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, mel@csn.ul.ie, akpm@linux-foundation.org, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>

On 2015/10/09 15:46, Xishi Qiu wrote:
> On 2015/10/9 22:56, Taku Izumi wrote:
>
>> Xeon E7 v3 based systems supports Address Range Mirroring
>> and UEFI BIOS complied with UEFI spec 2.5 can notify which
>> ranges are reliable (mirrored) via EFI memory map.
>> Now Linux kernel utilize its information and allocates
>> boot time memory from reliable region.
>>
>> My requirement is:
>>    - allocate kernel memory from reliable region
>>    - allocate user memory from non-reliable region
>>
>> In order to meet my requirement, ZONE_MOVABLE is useful.
>> By arranging non-reliable range into ZONE_MOVABLE,
>> reliable memory is only used for kernel allocations.
>>
>
> Hi Taku,
>
> You mean set non-mirrored memory to movable zone, and set
> mirrored memory to normal zone, right? So kernel allocations
> will use mirrored memory in normal zone, and user allocations
> will use non-mirrored memory in movable zone.
>
> My question is:
> 1) do we need to change the fallback function?

For *our* requirement, it's not required. But if someone want to prevent
user's memory allocation from NORMAL_ZONE, we need some change in zonelist
walking.

> 2) the mirrored region should locate at the start of normal
> zone, right?

Precisely, "not-reliable" range of memory are handled by ZONE_MOVABLE.
This patch does only that.

>
> I remember Kame has already suggested this idea. In my opinion,
> I still think it's better to add a new migratetype or a new zone,
> so both user and kernel could use mirrored memory.

Hi, Xishi.

I and Izumi-san discussed the implementation much and found using "zone"
is better approach.

The biggest reason is that zone is a unit of vmscan and all statistics and
handling the range of memory for a purpose. We can reuse all vmscan and
information codes by making use of zones. Introdcing other structure will be messy.
His patch is very simple.

For your requirements. I and Izumi-san are discussing following plan.

  - Add a flag to show the zone is reliable or not, then, mark ZONE_MOVABLE as not-reliable.
  - Add __GFP_RELIABLE. This will allow alloc_pages() to skip not-reliable zone.
  - Add madivse() MADV_RELIABLE and modify page fault code's gfp flag with that flag.


Thanks,
-Kame





















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
