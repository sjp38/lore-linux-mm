Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D69D26B0083
	for <linux-mm@kvack.org>; Sat, 26 May 2012 17:24:12 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3929060pbb.14
        for <linux-mm@kvack.org>; Sat, 26 May 2012 14:24:12 -0700 (PDT)
Date: Sat, 26 May 2012 14:23:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: the max size of block device on 32bit os,when using
 do_generic_file_read() proceed.
In-Reply-To: <201205242138175936268@gmail.com>
Message-ID: <alpine.LSU.2.00.1205261402170.2582@eggly.anvils>
References: <201205242138175936268@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: majianpeng <majianpeng@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 24 May 2012, majianpeng wrote:
>   Hi all:
> 		I readed a raid5,which size 30T.OS is RHEL6 32bit.
> 	    I reaed the raid5(as a whole,not parted) and found read address which not i wanted.
> 		So I tested the newest kernel code,the problem is still.
> 		I review the code, in function do_generic_file_read()
> 
> 		index = *ppos >> PAGE_CACHE_SHIFT;
> 		index is u32.and *ppos is long long.
> 		So when *ppos is larger than 0xFFFF FFFF *  PAGE_CACHE_SHIFT(16T Byte),then the index is error.
> 
> 		I wonder this .In 32bit os ,block devices size do not large then 16T,in other words, if block devices larger than 16T,must parted.

I am not surprised that the page cache limitation prevents you from
reading the whole device with a 32-bit kernel.  See MAX_LFS_FILESIZE in
include/linux/fs.h.  Our answer to that is just to use a 64-bit kernel.

#if BITS_PER_LONG==32
#define MAX_LFS_FILESIZE (((u64)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1) 
#elif BITS_PER_LONG==64
#define MAX_LFS_FILESIZE 0x7fffffffffffffffUL
#endif

But I am a little surprised that you get as far as 16TiB (with 4k page):
I would have expected you to be stopped just before 8TiB (although I
suspect that the limitation to 8TiB rather than 16TiB is unnecessary).

And if I understand you correctly, read() or pread() gave you no error
at those large offsets, but supplied data from the low offset instead?

That does surprise me - have we missed a check there?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
