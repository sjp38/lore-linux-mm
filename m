MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
In-Reply-To: <20050804113941.GP8266@wotan.suse.de>
References: <20050804113941.GP8266@wotan.suse.de>
Content-class: urn:content-classes:message
Subject: Re: Getting rid of SHMMAX/SHMALL ?
Date: Thu, 4 Aug 2005 07:58:45 -0400
Message-ID: <Pine.LNX.4.61.0508040757220.15854@chaos.analogic.com>
From: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Reply-To: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, cr@sap.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Aug 2005, Andi Kleen wrote:

>
> I noticed that even 64bit architectures have a ridiculously low
> max limit on shared memory segments by default:
>
> #define SHMMAX 0x2000000                 /* max shared seg size (bytes) */
> #define SHMMNI 4096                      /* max num of segs system wide */
> #define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16)) /* max shm system wide (pages) */
>
> Even on 32bit architectures it is far too small and doesn't
> make much sense. Does anybody remember why we even have this limit?
>
> IMHO per process shm mappings should just be controlled by the normal
> process and global mappings with the same heuristics as tmpfs
> (by default max memory / 2 or more if shmfs is mounted with more)
> Actually I suspect databases will usually want to use more
> so it might even make sense to support max memory - 1/8*max_memory
>
> I would propose to get rid of of shmmax completely
> and only keep the old shmall sysctl for compatibility.
>
> Comments?
>
> -Andi


It doesn't seem to be used very much. Here's the `grep` of the
entire 2.6.12 source-tree:


size_t	shm_ctlmax = SHMMAX;
./ipc/shm.c
                     (actually only bits 25..16 get used since SHMMAX is so low)
./include/asm-m68k/shm.h
 	KERN_SHMMAX=34,         /* long: Maximum shared memory segment */
./include/linux/sysctl.h
  * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
#define SHMMAX 0x2000000		 /* max shared seg size (bytes) */
#define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16)) /* max shm system wide (pages) */
./include/linux/shm.h
                     (actually only bits 25..16 get used since SHMMAX is so low)
./include/asm-h8300/shm.h
#ifndef SHMMAX
#define SHMMAX          0x003fa000
./include/asm-arm26/shmparam.h
 		.ctl_name	= KERN_SHMMAX,
./kernel/sysctl.c



Cheers,
Dick Johnson
Penguin : Linux version 2.6.12 on an i686 machine (5537.79 BogoMips).
Warning : 98.36% of all statistics are fiction.
.
I apologize for the following. I tried to kill it with the above dot :

****************************************************************
The information transmitted in this message is confidential and may be privileged.  Any review, retransmission, dissemination, or other use of this information by persons or entities other than the intended recipient is prohibited.  If you are not the intended recipient, please notify Analogic Corporation immediately - by replying to this message or by sending an email to DeliveryErrors@analogic.com - and destroy all copies of this information, including any attachments, without reading or disclosing them.

Thank you.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
