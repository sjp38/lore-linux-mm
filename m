Received: from mail.intermedia.net ([207.5.44.129])
	by kvack.org (8.8.7/8.8.7) with SMTP id NAA17014
	for <linux-mm@kvack.org>; Wed, 26 May 1999 13:40:55 -0400
Received: from [134.96.127.180] by mail.colorfullife.com (NTMail 3.03.0017/1.abcr) with ESMTP id xa383731 for <linux-mm@kvack.org>; Wed, 26 May 1999 10:41:46 -0700
Message-ID: <374C3237.2D89878@colorfullife.com>
Date: Wed, 26 May 1999 19:41:11 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
Reply-To: masp0008@stud.uni-sb.de
MIME-Version: 1.0
Subject: Re: kernel_lock() profiling results
References: <3748111C.3F040C1F@colorfullife.com> <14156.8862.155397.630098@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "David S. Miller" <davem@dm.cobaltmicro.com>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
>         ftp://ftp.uk.linux.org/pub/linux/sct/performance
> 
> contains a patch Dave Miller and I put together to drop the kernel lock
> during a number of key user mode copies.

1) Andrea noticed that 'unlock_kernel()' only releases the kernel lock
if the lock was obtained once.
He added two new functions: one stores the current lock depth,
releases the lock and sets current->lock_depth =-1.
The other reverses that.

I think we need these functions:
* it's save to call the functions without the kernel_lock held.
* the unlock is effective for recursive calls.

2) Here's a excerpt from an email I wrote a few days ago:
> I've modified uaccess.h, and I have now a list of all functions which
> called copy_to/from_user() for more than 512 bytes (apache, make clean;
> make fs; find /usr/bin)
> 
> * read_file_actor()
> * ext2_file_write()
> * block_read()
> * copy_mount_options()  << really rare
> * proc_file_read()      << rare??
> * pipe_write()
> * pipe_read()
> * 2*vt_ioctl() << could be remote gdb.
> * tcp_do_sendmsg()
> * copy_strings()        << only during fork()?
> 
> Additionally, the following functions could also release the kernel
> lock:
> * padzero() in binfmt_elf:
>         This function clears up to 4096 bytes user memory.
>         The average should be 2048.
> * update_vm_mapping():
>         the function can wait in wait_on_page(), we should break nothing
> * get_free_page():
>         if GFP_WAIT, for memset(,0,PAGE_SIZE)
I didn't use NFS, knfsd, other fs except ext2.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
