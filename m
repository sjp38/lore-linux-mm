Date: Mon, 11 Jun 2001 12:32:35 -0400
From: cohutta <cohutta@MailAndNews.com>
Subject: RE: temp. mem mappings
Message-ID: <3B289FA9@MailAndNews.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Joseph A. Knapka" <jknapka@earthlink.net>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>===== Original Message From "Joseph A. Knapka" <jknapka@earthlink.net> =====
>"Stephen C. Tweedie" wrote:
>>
>> Hi,
>>
>> On Thu, Jun 07, 2001 at 09:38:06PM -0400, cohutta wrote:
>>
>> > >Right --- you can use alloc_pages but we haven't done the
>> > >initialisation of the kmalloc slabsl by this point.
>> >
>> > My testing indicates that i can't use __get_free_page(GFP_KERNEL)
>> > any time during setup_arch() [still x86].  It causes a BUG
>> > in slab.c (line 920) [linux 2.4.5].
>>
>> After paging_init(), it should be OK --- as long as there is enough
>> memory that you don't end up calling the VM try_to_free_page routines.
>> Those will definitely choke this early in boot.
>
>But we don't actually give the zone allocator any free pages
>until mem_init().

Right, so what Stephen warned about is happening:
__get_free_page() causes a BUG in slab.c via __alloc_pages()
-> try_to_free_pages() -> do_try_to_free_pages()
-> shrink_dcache_memory() -> kmem_cache_shrink() -> BUG().

/c/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
