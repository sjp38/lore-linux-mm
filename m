Message-ID: <3B8FDA36.5010206@interactivesi.com>
Date: Fri, 31 Aug 2001 13:40:54 -0500
From: Timur Tabi <ttabi@interactivesi.com>
MIME-Version: 1.0
Subject: kernel hangs in 118th call to vmalloc
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm writing a driver for the 2.4.2 kernel.  I need to use this kernel 
because this driver needs to be compatible with a stock Red Hat system. 
  Patches to the kernel are not an option.

The purpose of the driver is to locate a device that exists on a 
specific memory chip.  To help find it, I've written this routine:

#define CLEAR_BLOCK_SIZE 1048576UL        // must be a multiple of 1MB
#define CLEAR_BLOCK_COUNT ((PHYSICAL_HOP * 2) / CLEAR_BLOCK_SIZE)

void clear_out_memory(void)
{
     void *p[CLEAR_BLOCK_COUNT];
     unsigned i;
     unsigned long size = 0;

     for (i=0; i<CLEAR_BLOCK_COUNT; i++)
     {
         p[i] = vmalloc(CLEAR_BLOCK_SIZE);
         if (!p[i])
             break;
         size += CLEAR_BLOCK_SIZE;
     }

     while (--i)
         vfree(p[i]);

     printk("Paged %luMB of memory\n", size / 1048576UL);
}

What this routine does is call vmalloc() repeatedly for a number of 1MB 
chunks until it fails or until it's allocated 128MB (CLEAR_BLOCK_COUNT 
is equal to 128 in this case).  Then, it starts freeing them.

The side-effect of this routine is to page-out up to 128MB of RAM. 
Unfortunately, on a 128MB machine, the 118th call to vmalloc() hangs the 
system.  I was expecting it to return NULL instead.

Is this a bug in vmalloc()?  If so, is there a work-around that I can use?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
