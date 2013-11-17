Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 81FCE6B0031
	for <linux-mm@kvack.org>; Sun, 17 Nov 2013 10:03:51 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so294748pdj.36
        for <linux-mm@kvack.org>; Sun, 17 Nov 2013 07:03:51 -0800 (PST)
Received: from psmtp.com ([74.125.245.203])
        by mx.google.com with SMTP id sn7si7324076pab.51.2013.11.17.07.03.48
        for <linux-mm@kvack.org>;
        Sun, 17 Nov 2013 07:03:50 -0800 (PST)
Received: from [192.168.178.21] ([85.177.123.247]) by mail.gmx.com (mrgmx002)
 with ESMTPSA (Nemesis) id 0MTTKZ-1WALzB3tdn-00SRQm for <linux-mm@kvack.org>;
 Sun, 17 Nov 2013 16:03:47 +0100
Message-ID: <5288DAD0.5020306@gmx.de>
Date: Sun, 17 Nov 2013 16:03:44 +0100
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

In the mean while I think that it is not the radix-tree itself where the hang is related to. With this patch :

diff --git a/mm/truncate.c b/mm/truncate.c
index 353b683..22a5926 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -355,6 +355,8 @@ EXPORT_SYMBOL(truncate_inode_pages_range);
  */
 void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
 {
+       if (lstart > 0)
+               printk ("lstart=%lld\n", lstart);
        truncate_inode_pages_range(mapping, lstart, (loff_t)-1);
 }
 EXPORT_SYMBOL(truncate_inode_pages);


against v3.12-10087-g1213959 I get in the syslog entires like :


Nov 17 14:07:12 trinity tfoerste: M=/mnt/nfsv4
Nov 17 14:07:27 trinity kernel: lstart=2147418111
Nov 17 14:07:30 trinity kernel: lstart=14531581
Nov 17 14:07:30 trinity kernel: lstart=8388607
Nov 17 14:07:30 trinity kernel: lstart=187
Nov 17 14:07:32 trinity kernel: lstart=2048
Nov 17 14:08:00 trinity kernel: lstart=11264
Nov 17 14:08:00 trinity kernel: lstart=44297
Nov 17 14:08:05 trinity kernel: lstart=31
Nov 17 14:08:34 trinity kernel: lstart=1542
Nov 17 14:08:35 trinity kernel: lstart=30
Nov 17 14:08:35 trinity kernel: lstart=2088809
Nov 17 14:08:37 trinity kernel: lstart=208
Nov 17 14:08:37 trinity kernel: lstart=7276806
Nov 17 14:08:37 trinity kernel: lstart=191
...
Nov 17 14:11:22 trinity tfoerste: M=/mnt/nfsv4
Nov 17 14:11:36 trinity kernel: lstart=255
Nov 17 14:11:36 trinity kernel: lstart=500676444
Nov 17 14:11:37 trinity kernel: lstart=1024
Nov 17 14:11:37 trinity kernel: lstart=12786775
Nov 17 14:11:37 trinity kernel: lstart=16728385
Nov 17 14:11:37 trinity kernel: lstart=44
Nov 17 14:11:37 trinity kernel: lstart=516
Nov 17 14:11:38 trinity kernel: lstart=17407
Nov 17 14:11:38 trinity kernel: lstart=31
Nov 17 14:11:38 trinity kernel: lstart=65534
Nov 17 14:11:39 trinity kernel: lstart=4302304271
Nov 17 14:11:40 trinity kernel: lstart=65536
Nov 17 14:11:40 trinity kernel: lstart=678625087
Nov 17 14:11:40 trinity kernel: lstart=190464262
Nov 17 14:11:41 trinity kernel: lstart=268435343
Nov 17 14:11:42 trinity kernel: lstart=109
Nov 17 14:11:42 trinity kernel: lstart=2088960
Nov 17 14:11:42 trinity kernel: lstart=989582838
Nov 17 14:11:42 trinity kernel: lstart=3838
Nov 17 14:11:42 trinity kernel: lstart=327
Nov 17 14:11:43 trinity kernel: lstart=119
Nov 17 14:12:14 trinity kernel: lstart=9949
Nov 17 14:12:14 trinity kernel: lstart=4096
Nov 17 14:12:15 trinity kernel: lstart=3
Nov 17 14:12:18 trinity sshd[9636]: pam_unix(sshd:session): session closed for user tfoerste
...

Does this helps ?

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
