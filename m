Message-ID: <3EB0071B.2020308@google.com>
Date: Wed, 30 Apr 2003 10:25:47 -0700
From: Ross Biro <rossb@google.com>
MIME-Version: 1.0
Subject: [BUG 2.4] Buffers Span Zones
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

This is probably old hat to all of you, but...

I mentioned this on the LKML, but didn't get a response, so I thought I 
would mention it here.  It appears that in the 2.4 kernels, kswapd is 
not aware that buffer heads can be in one zone while the buffers 
themselves are in another zone.  This can lead to fake out of memory 
messages when lowmem is under preasure and highmem is not.

I believe something like

                /* Buffers span classzones because heads are low and
                   the buffer itself may be elsewhere. */
        if (!memclass(page->zone, classzone)) {
                        struct buffer_head *bh;
                        int zonebuffers = 0;
                        if (!page->buffers)
                                continue;
                        bh = page->buffers;
                        do {
                                if (memclass(virt_to_page(bh)->zone,
                                             classzone)) {
                                        zonebuffers=1;
                                        break;
                                }
                                bh = bh->b_this_page;
                        } while (bh != page->buffers);
                       
                        if (!zonebuffers)
                                continue;
                }

in shrink cache in place of
if (!memclass(page->zone, classzone)) {
    continue;
}


To keep from killing the page cache, after the buffer heads are freed, I 
repeate the check

if (!memclass(page->zone, classzone)) {
    continue;
}

It also appears that in buffer.c balance_dirty_state really needs to be 
zone aware as well.  It might also be nice to replace many of the 
current->policy |= YIELD; schedule(); pairs with real waits for memory 
to free up a bit.  If dirty pages or associated structures are filling 
up most of the memory, then the problem will go away if we just wait a bit.

I've found that changing PAGE_OFFSET to reduce the amount of lowmem has 
been a very good way to exercies the VM.  I've been able to cause all 
sorts of interesting problems by having ~20M of lowmem and 3G of 
highmem. I assume that many of these problems would occur on systems 
with 1G of lowmem and 16-20G of highmem.

Please CC me on any responses.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
