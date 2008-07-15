Date: Tue, 15 Jul 2008 13:18:40 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: xfs bug in 2.6.26-rc9
Message-ID: <20080715031840.GB29319@disturbed>
References: <alpine.DEB.1.10.0807110939520.30192@uplift.swm.pp.se> <20080711084248.GU29319@disturbed> <alpine.DEB.1.10.0807111215040.30192@uplift.swm.pp.se> <487B019B.9090401@sgi.com> <20080714121332.GX29319@disturbed> <487C07A4.70202@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <487C07A4.70202@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lachlan McIlroy <lachlan@sgi.com>
Cc: Mikael Abrahamsson <swmike@swm.pp.se>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 15, 2008 at 12:12:52PM +1000, Lachlan McIlroy wrote:
> Dave Chinner wrote:
>> On Mon, Jul 14, 2008 at 05:34:51PM +1000, Lachlan McIlroy wrote:
>>> This is a race between xfs_fsr and a mmap write. xfs_fsr acquires the
>>> iolock and then flushes the file and because it has the iolock it doesn't
>>> expect any new delayed allocations to occur.  A mmap write can allocate
>>> delayed allocations without acquiring the iolock so is able to get in
>>> after the flush but before the ASSERT.
>>
>> Christoph and I were contemplating this problem with ->page_mkwrite
>> reecently. The problem is that we can't, right now, return an
>> EAGAIN-like error to ->page_mkwrite() and have it retry the
>> page fault. Other parts of the page faulting code can do this,
>> so it seems like a solvable problem.
>>
>> The basic concept is that if we can return a EAGAIN result we can
>> try-lock the inode and hold the locks necessary to avoid this race
>> or prevent the page fault from dirtying the page until the
>> filesystem is unfrozen.
> Why do we need to try-lock the inode?  Will we have an ABBA deadlock
> if we block on the iolock in ->page_mkwrite()?

Yes. With the mmap_sem. Look at the rules in mm/filemap.c
and replace i_mutex with iolock....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
