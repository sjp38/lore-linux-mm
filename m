Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9UN8K4f006906
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 19:08:20 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9UN8Knf110502
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 17:08:20 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9UN8JY0011981
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 17:08:19 -0600
Message-ID: <4727B979.8030207@us.ibm.com>
Date: Tue, 30 Oct 2007 16:08:41 -0700
From: Badari <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: migratepage failures on reiserfs
References: <1193768824.8904.11.camel@dyn9047017100.beaverton.ibm.com> <20071030135442.5d33c61c@think.oraclecorp.com> <1193781245.8904.28.camel@dyn9047017100.beaverton.ibm.com> <20071030185840.48f5a10b@think.oraclecorp.com>
In-Reply-To: <20071030185840.48f5a10b@think.oraclecorp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: reiserfs-devel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Chris Mason wrote:
> On Tue, 30 Oct 2007 13:54:05 -0800
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
>   
>> On Tue, 2007-10-30 at 13:54 -0400, Chris Mason wrote:
>>     
>>> On Tue, 30 Oct 2007 10:27:04 -0800
>>> Badari Pulavarty <pbadari@us.ibm.com> wrote:
>>>
>>>       
>>>> Hi,
>>>>
>>>> While testing hotplug memory remove, I ran into this issue. Given
>>>> a range of pages hotplug memory remove tries to migrate those
>>>> pages.
>>>>
>>>> migrate_pages() keeps failing to migrate pages containing
>>>> pagecache pages for reiserfs files. I noticed that reiserfs
>>>> doesn't have ->migratepage() ops. So, fallback_migrate_page()
>>>> code tries to do try_to_release_page(). try_to_release_page()
>>>> fails to drop_buffers() since b_count == 1. Here is what my debug
>>>> shows:
>>>>
>>>> 	migrate pages failed pfn 258111/flags 3f00000000801
>>>> 	bh c00000000b53f6e0 flags 110029 count 1
>>>> 	
>>>> Any one know why the b_count == 1 and not getting dropped to
>>>> zero ? 
>>>>         
>>> If these are file data pages, the count is probably elevated as
>>> part of the data=ordered tracking.  You can verify this via
>>> b_private, or just mount data=writeback to double check.
>>>       
>> Chris,
>>
>> That was my first assumption. But after looking at
>> reiserfs_releasepage (), realized that it would do reiserfs_free_jh()
>> and clears the b_private. I couldn't easily find out who has the ref.
>> against this bh.
>>
>> bh c00000000bdaaf00 flags 110029 count 1 private 0
>>
>>     
>
> If I'm reading this correctly the buffer is BH_Lock | BH_Req, perhaps
> it is currently under IO?
>   
Its BH_Req | BH_Uptodate. Its not under IO.
> The page isn't locked, but data=ordered does IO directly on the buffer
> heads, without taking the page lock.
>
> The easy way to narrow our search is to try without data=ordered, it is
> certainly complicating things.
>   

I can try that, its my root filesystem :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
