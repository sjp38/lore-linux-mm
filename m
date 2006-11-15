Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAFIKmYI007219
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 13:20:48 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAFIKkQn250160
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 13:20:46 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAFIKjsu022141
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 13:20:45 -0500
Message-ID: <455B5A7B.6010807@us.ibm.com>
Date: Wed, 15 Nov 2006 10:20:43 -0800
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: pagefault in generic_file_buffered_write() causing deadlock
References: <1163606265.7662.8.camel@dyn9047017100.beaverton.ibm.com> <20061115090005.c9ec6db5.akpm@osdl.org>
In-Reply-To: <20061115090005.c9ec6db5.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, ext4 <linux-ext4@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 15 Nov 2006 07:57:45 -0800
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
>   
>> We are looking at a customer situation (on 2.6.16-based distro) - where
>> system becomes almost useless while running some java & stress tests.
>>
>> Root cause seems to be taking a pagefault in generic_file_buffered_write
>> () after calling prepare_write. I am wondering 
>>
>> 1) Why & How this can happen - since we made sure to fault the user
>> buffer before prepare write.
>>     
>
> When using writev() we only fault in the first segment of the iovec.  If
> the second or succesive segment isn't mapped into pagetables we're
> vulnerable to the deadlock.
>
>   
Hmm.. Not it :(
Its coming from write() not writev().

[C00000002ABBF290] [C00000000039D58C] .do_page_fault+0x2e4/0x75c
[C00000002ABBF460] [C000000000004860] .handle_page_fault+0x20/0x54
--- Exception: 301 at .__copy_tofrom_user+0x11c/0x580
    LR = .generic_file_buffered_write+0x39c/0x7c8
[C00000002ABBF750] [C000000000095A94]
.generic_file_buffered_write+0x2c0/0x7c8 (
unreliable)
[C00000002ABBF8F0] [C0000000000962EC]
.__generic_file_aio_write_nolock+0x350/0x3
e0
[C00000002ABBFA20] [C000000000096908] .generic_file_aio_write+0x78/0x104
[C00000002ABBFAE0] [C0000000001649F0] .ext3_file_write+0x2c/0xd4
[C00000002ABBFB70] [C0000000000C5168] .do_sync_write+0xd4/0x130
[C00000002ABBFCF0] [C0000000000C5ED4] .vfs_write+0x128/0x20c
[C00000002ABBFD90] [C0000000000C664C] .sys_write+0x4c/0x8c
[C00000002ABBFE30] [C00000000000871C] syscall_exit+0x0/0x40

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
