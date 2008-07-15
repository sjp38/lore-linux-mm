Message-ID: <487C07A4.70202@sgi.com>
Date: Tue, 15 Jul 2008 12:12:52 +1000
From: Lachlan McIlroy <lachlan@sgi.com>
Reply-To: lachlan@sgi.com
MIME-Version: 1.0
Subject: Re: xfs bug in 2.6.26-rc9
References: <alpine.DEB.1.10.0807110939520.30192@uplift.swm.pp.se> <20080711084248.GU29319@disturbed> <alpine.DEB.1.10.0807111215040.30192@uplift.swm.pp.se> <487B019B.9090401@sgi.com> <20080714121332.GX29319@disturbed>
In-Reply-To: <20080714121332.GX29319@disturbed>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lachlan McIlroy <lachlan@sgi.com>, Mikael Abrahamsson <swmike@swm.pp.se>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Chinner wrote:
> On Mon, Jul 14, 2008 at 05:34:51PM +1000, Lachlan McIlroy wrote:
>> Mikael Abrahamsson wrote:
>>> On Fri, 11 Jul 2008, Dave Chinner wrote:
>>>
>>>> That aside, what was the assert failure reported prior to the oops?  
>>>> i.e. paste the lines in the log before the ---[ cut here ]--- line?  
>>>> One of them will start with 'Assertion failed:', I think....
>>> These ones?
>>>
>>> Jul  8 04:44:56 via kernel: [554197.888008] Assertion failed: whichfork 
>>> == XFS_ATTR_FORK || ip->i_delayed_blks == 0, file: fs/xfs/xfs_bmap.c,  
>>> line: 5879
>>> Jul  9 03:25:21 via kernel: [42940.748007] Assertion failed: whichfork  
>>> == XFS_ATTR_FORK || ip->i_delayed_blks == 0, file: fs/xfs/xfs_bmap.c,  
>>> line: 5879
>> 	xfs_ilock(ip, XFS_IOLOCK_SHARED);
>>
>> 	if (whichfork == XFS_DATA_FORK &&
>> 		(ip->i_delayed_blks || ip->i_size > ip->i_d.di_size)) {
>> 		/* xfs_fsize_t last_byte = xfs_file_last_byte(ip); */
>> 		error = xfs_flush_pages(ip, (xfs_off_t)0,
>> 					       -1, 0, FI_REMAPF);
>> 		if (error) {
>> 			xfs_iunlock(ip, XFS_IOLOCK_SHARED);
>> 		return error;
>> 		}
>> 	}
>>
>> 	ASSERT(whichfork == XFS_ATTR_FORK || ip->i_delayed_blks == 0);
>>
>> This is a race between xfs_fsr and a mmap write. xfs_fsr acquires the
>> iolock and then flushes the file and because it has the iolock it doesn't
>> expect any new delayed allocations to occur.  A mmap write can allocate
>> delayed allocations without acquiring the iolock so is able to get in
>> after the flush but before the ASSERT.
> 
> Christoph and I were contemplating this problem with ->page_mkwrite
> reecently. The problem is that we can't, right now, return an
> EAGAIN-like error to ->page_mkwrite() and have it retry the
> page fault. Other parts of the page faulting code can do this,
> so it seems like a solvable problem.
> 
> The basic concept is that if we can return a EAGAIN result we can
> try-lock the inode and hold the locks necessary to avoid this race
> or prevent the page fault from dirtying the page until the
> filesystem is unfrozen.
Why do we need to try-lock the inode?  Will we have an ABBA deadlock
if we block on the iolock in ->page_mkwrite()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
