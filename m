Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17u1pk-0001Kr-00
	for <linux-mm@kvack.org>; Tue, 24 Sep 2002 19:23:24 -0700
Date: Tue, 24 Sep 2002 19:23:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: 2.5.38-mm2 pdflush_list
Message-ID: <20020925022324.GP6070@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Program received signal SIGSEGV, Segmentation fault.
pdflush_operation (fn=0xc0142428 <background_writeout>, arg0=0)
    at /mnt/b/2.5.38/linux-2.5/include/linux/list.h:130
130     /mnt/b/2.5.38/linux-2.5/include/linux/list.h: No such file or directory.
        in /mnt/b/2.5.38/linux-2.5/include/linux/list.h
(gdb) bt
#0  pdflush_operation (fn=0xc0142428 <background_writeout>, arg0=0)
    at /mnt/b/2.5.38/linux-2.5/include/linux/list.h:130
#1  0xc01423cf in balance_dirty_pages (mapping=0xd749383c)
    at page-writeback.c:127
#2  0xc014241f in balance_dirty_pages_ratelimited (mapping=0xd749383c)
    at page-writeback.c:160
#3  0xc013300f in generic_file_write_nolock (file=0xd7c67bc0, iov=0xc6aa9f70, 
    nr_segs=1, ppos=0xd7c67be0) at filemap.c:1643
#4  0xc013313f in generic_file_write (file=0xd7c67bc0, 
    buf=0x804bda0 '\001' <repeats 200 times>..., count=65487, ppos=0xd7c67be0)
    at filemap.c:1675
#5  0xc014640c in vfs_write (file=0xd7c67bc0, 
    buf=0x804bda0 '\001' <repeats 200 times>..., count=65487, pos=0xd7c67be0)
    at read_write.c:214
#6  0xc01464ee in sys_write (fd=7, 
    buf=0x804bda0 '\001' <repeats 200 times>..., count=65487)
    at read_write.c:244
#7  0xc010746f in syscall_call () at process.c:685

There's a NULL in this circular list:

(gdb) p &pdflush_list
$15 = (struct list_head *) 0xc02b5bdc
(gdb) p pdflush_list
$16 = {next = 0xdbf23fe0, prev = 0xe0125fe0}
(gdb) p *(pdflush_list.next)
$17 = {next = 0x0, prev = 0xc02b5bdc}
(gdb) p *(pdflush_list.prev)
$18 = {next = 0xc02b5bdc, prev = 0xdbf23fe0}
(gdb) p *((pdflush_list.prev)->prev)
$19 = {next = 0x0, prev = 0xc02b5bdc}
(gdb) p *(((pdflush_list.prev)->prev)->prev)
$20 = {next = 0xdbf23fe0, prev = 0xe0125fe0}
(gdb) p *pdf
$21 = {who = 0x0, fn = 0, arg0 = 0, list = {next = 0x0, prev = 0xc02b5bdc}, 
  when_i_went_to_sleep = 0}



Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
