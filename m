Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 834DF6B0268
	for <linux-mm@kvack.org>; Sat,  9 Nov 2013 14:07:29 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id mc17so1208722pbc.35
        for <linux-mm@kvack.org>; Sat, 09 Nov 2013 11:07:29 -0800 (PST)
Received: from psmtp.com ([74.125.245.149])
        by mx.google.com with SMTP id dj3si10624649pbc.310.2013.11.09.11.07.27
        for <linux-mm@kvack.org>;
        Sat, 09 Nov 2013 11:07:28 -0800 (PST)
Received: from [192.168.178.21] ([85.177.156.93]) by mail.gmx.com (mrgmx103)
 with ESMTPSA (Nemesis) id 0M2L60-1VveET0jTA-00s85e for <linux-mm@kvack.org>;
 Sat, 09 Nov 2013 20:07:25 +0100
Message-ID: <527E87EA.8080700@gmx.de>
Date: Sat, 09 Nov 2013 20:07:22 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: [uml-devel] fuzz tested 32 bit user mode linux image hangs in
 radix_tree_next_chunk()
References: <526696BF.6050909@gmx.de>	<CAFLxGvy3NeRKu+KQCCm0j4LS60PYhH0bC8WWjfiPvpstPBjAkA@mail.gmail.com>	<5266A698.10400@gmx.de>	<5266B60A.1000005@nod.at>	<52715AD1.7000703@gmx.de> <CALYGNiPvJF1u8gXNcX1AZR5-VkGqJnaose84KBbdaoBAq8aoGQ@mail.gmail.com> <527AB23D.2060305@gmx.de> <527AB51B.1020005@nod.at>
In-Reply-To: <527AB51B.1020005@nod.at>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>

On 11/06/2013 10:31 PM, Richard Weinberger wrote:
> Am 06.11.2013 22:18, schrieb Toralf FA?rster:
>> On 11/06/2013 05:06 PM, Konstantin Khlebnikov wrote:
>>> In this case it must stop after scanning whole tree in line:
>>> /* Overflow after ~0UL */
>>> if (!index)
>>>   return NULL;
>>>
>>
>> A fresh current example with latest git tree shows that lines 769 and 770 do alternate :
> 
> Can you please ask gdb for the value of offset?
> 
> Thanks,
> //richard
> 

Still trying to get those values. One attempt to do that was to replace -O2 with -O0 in the Makefile,
but that resulted into this error :

  LD      kernel/built-in.o
  CC      mm/memory.o
In function a??zap_pmd_rangea??,
    inlined from a??zap_pud_rangea?? at mm/memory.c:1265:8,
    inlined from a??unmap_page_rangea?? at mm/memory.c:1290:8:
mm/memory.c:1220:23: error: call to a??__compiletime_assert_1220a?? declared with attribute error: BUILD_BUG failed
mm/memory.c: In function a??follow_page_maska??:
mm/memory.c:1530:18: error: call to a??__compiletime_assert_1530a?? declared with attribute error: BUILD_BUG failed
make[1]: *** [mm/memory.o] Error 1
make: *** [mm] Error 2


With -O1 it compiled at least.


>>
>> tfoerste@n22 ~/devel/linux $ sudo gdb /usr/local/bin/linux-v3.12-48-gbe408cd 16619 -n -batch -ex bt
>> 0x08296a8c in radix_tree_next_chunk (root=0x25, iter=0x462e7c64, flags=12) at lib/radix-tree.c:770
>> 770                                             if (node->slots[offset])
>> #0  0x08296a8c in radix_tree_next_chunk (root=0x25, iter=0x462e7c64, flags=12) at lib/radix-tree.c:770
>> #1  0x080cc1fe in find_get_pages (mapping=0x462ad470, start=0, nr_pages=14, pages=0xc) at mm/filemap.c:844
>> #2  0x080d5d6a in pagevec_lookup (pvec=0x462e7cc8, mapping=0x25, start=37, nr_pages=37) at mm/swap.c:914
>> #3  0x080d615a in truncate_inode_pages_range (mapping=0x462ad470, lstart=0, lend=-1) at mm/truncate.c:241
>> #4  0x080d64ff in truncate_inode_pages (mapping=0x25, lstart=51539607589) at mm/truncate.c:358
>>
>>
>>
>>
>> tfoerste@n22 ~/devel/linux $ sudo gdb /usr/local/bin/linux-v3.12-48-gbe408cd 16619 -n -batch -ex bt
>> radix_tree_next_chunk (root=0x28, iter=0x462e7c64, flags=18) at lib/radix-tree.c:769
>> 769                                     while (++offset < RADIX_TREE_MAP_SIZE) {
>> #0  radix_tree_next_chunk (root=0x28, iter=0x462e7c64, flags=18) at lib/radix-tree.c:769
>> #1  0x080cc1fe in find_get_pages (mapping=0x462ad470, start=0, nr_pages=14, pages=0x12) at mm/filemap.c:844
>> #2  0x080d5d6a in pagevec_lookup (pvec=0x462e7cc8, mapping=0x28, start=40, nr_pages=40) at mm/swap.c:914
>> #3  0x080d615a in truncate_inode_pages_range (mapping=0x462ad470, lstart=0, lend=-1) at mm/truncate.c:241
>> #4  0x080d64ff in truncate_inode_pages (mapping=0x28, lstart=77309411368) at mm/truncate.c:358
>> #5  0x0825e388 in hostfs_evict_inode (inode=0x462ad3b8) at fs/hostfs/hostfs_kern.c:242
>> #6  0x0811a8df in evict (inode=0x462ad3b8) at fs/inode.c:549
>>
>>
> 
> 


-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
