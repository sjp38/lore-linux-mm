Date: Sun, 25 Jan 2004 07:49:28 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Discontiguous memory issue
Message-ID: <302450000.1075045767@[10.10.2.4]>
In-Reply-To: <BAY9-DAV24DwVCAwCfZ00015113@hotmail.com>
References: <BAY9-DAV24DwVCAwCfZ00015113@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aman <amanullah_khan@hotmail.com>, MM Linux <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I am working on a customized board which has S3C2410 as its processor.
> I have applied the following Linux patches patch-2.4.18-rmk6 and 
> patch-2.4.18-RMK6-SWL5.
> There are  two types of custom hardware with me. One has 64MB contiguous
> SDRAM and the other has 32 MB with following discontiguous physical 
> memory  map.
> 
> 1. 0x30000000 to 0x307fffff size is 8MB
> 2. 0x31000000 to 0x317fffff size is 8MB
> 3. 0x32000000 to 0x327fffff size is 8MB
> 4. 0x33000000 to 0x337fffff size is 8MB
> 
> RAMDISK location 0x31000000 (Maximum size is 7 MB) and ZIMAGE
> location 0x31700000
> 
> In the 64 MB hardware, Linux runs without any issues. Because the patch is
> for 64MB  contiguous memory. I am able to boot the 32 MB hardware 
> with the same kernel used for 64MB. But in 32MB hardware, it crashes 
> when I  run some of our applications. I assume that this is because the 
> kernel is not configured for the discontiguous memory map.
> 
> I did the following changes to support discontiguous memory.
> 
> 1. I changed the MEM_SIZE macro to 32 * 1024 * 1024
> (include/as/arch/s3c2410.h)
> 2. Changed the macros in the include/asm/arch/memory.h
> 3. modified the fixup_s3c2410 () function in 
> arch/arm/mach-s3c2410/arch.c to support 4 memory banks.
> 4. Enabled CONFIG_DISCONTIGMEM option
> 
> After doing the above changes, Linux crashes during the bootup.
> Is my understanding correct ?
> I have attached the modified files.
> Any help regarding the discontiguous memory configuration will be grateful.
> 
> Thanking you in advance.

Where exactly during bootup are you crashing? If it's before console_init,
you're going to have some kind of early printk function to do a crude dump
to the screen or serial port or something. If it's after, then dump all 
the pgdats, and see if it looks good.

Fundamentally, you need to create the pgdats, and fill them out properly,
describing to the main VM where your memory regions start and end. Most
of them are in pfn units (page frame number = physaddr / PAGE_SIZE).
I didn't bother sorting through your files to see if you're doing that ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
