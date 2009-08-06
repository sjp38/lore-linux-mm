Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 251626B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 16:16:26 -0400 (EDT)
Message-ID: <4A7B3A2C.60500@vmware.com>
Date: Thu, 06 Aug 2009 22:16:44 +0200
From: =?UTF-8?B?VGhvbWFzIEhlbGxzdHLDtm0=?= <thellstrom@vmware.com>
MIME-Version: 1.0
Subject: Re: shmem + TTM  oops
References: <4A7ACC90.2000808@tungstengraphics.com> <Pine.LNX.4.64.0908062045270.944@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908062045270.944@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: =?UTF-8?B?VGhvbWFzIEhlbGxzdHLDtm0=?= <thomas@tungstengraphics.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins skrev:
> On Thu, 6 Aug 2009, Thomas HellstrA?m wrote:
>   
>> Hi!
>> I've been debugging a strange problem for a while, and it'd be nice to have
>> some more eyes on this.
>>
>> When the TTM graphics memory manager decides it's using too much memory, it
>> copies the contents of the buffer to shmem objects and releases the buffers.
>> This is because shmem objects are pageable whereas TTM buffers are not. When
>> the TTM buffers are accessed in one way or another, it copies contents back.
>> Seems to work fairly nice, but not really optimal.
>>
>> When the X server is VT switched, TTM optionally switches out all buffers to
>> shmem objects, but when the contents are read back, some shmem objects have
>> corrupted swap entry top directory. The member
>> shmem_inode_info::i_indirect[0] usually contains a value 0xffffff60 or
>> something similar, causing an oops in shmem_truncate_range() when the shmem
>> object is freed. Before that, readback seems to work OK. The corruption is
>> happening after X server VT switch when TTM is supposed to be idle. The shmem
>> objects have been verified to have swap entry directories after all buffer
>> objects have been swapped out.
>>     
>
> Not a symptom I've ever come across: I agree strange.  A few questions:
>
> What architecture? I assume x86 32-bit; if so, what happens on 64-bit?
> if not x86, what is your PAGE_SIZE?
>
> What size are these objects i.e. how many pages?
>
> What release? I'm assuming 2.6.31-rc5 and various earlier.
>
> What slab allocator? what if you choose another (SLUB versus SLAB)?
> Please turn on all the slab/slub debugging you can.
>
> And you say i_indirect "usually contains a value 0xffffff60 or something
> similar": please give other examples of what you find there (if possible,
> with a rough idea of their frequency e.g. is 0xffffff60 the most common?).
>
> Does there appear to be corruption of any other nearby fields?
>
> Thanks.
>
>   
>> If anyone could shed some light over this, it would be very helpful. Relevant
>> TTM code is fairly straightforward looks like this. The process that copies
>> out to shmem objects may not be the same process that copies in:
>>     
>
> I didn't notice anything wrong with your code; and it wouldn't
> be easy for it to corrupt that field of shmem_inode_info.
>
> Hugh
Hugh,

Thanks for looking at this.
After further debugging it seems this is not relevant to the shmem code. 
It looks like a (possibly misconfigured) hrtimer in the graphics driver 
corrupts the shmem_inode_info data from within interrupt context, so 
this appears to be a false alarm. The hrtimer was supposed to be idled 
at vt switch, but apparently not.

Thanks,
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
