Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 193A66B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 10:13:59 -0500 (EST)
Date: Wed, 9 Jan 2013 16:13:54 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] writeback: fix writeback cache thrashing
Message-ID: <20130109151354.GA17353@quack.suse.cz>
References: <1356847190-7986-1-git-send-email-linkinjeon@gmail.com>
 <20130105031817.GA8650@localhost>
 <CAKYAXd-kTOBwZfW=17Ta0wLB4HWzkk5ta3AdT0cPRK3z2zsLUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKYAXd-kTOBwZfW=17Ta0wLB4HWzkk5ta3AdT0cPRK3z2zsLUA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, liwanp@linux.vnet.ibm.com, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Jan Kara <jack@suse.cz>, Dave Chinner <dchinner@redhat.com>, Simon Jeons <simon.jeons@gmail.com>

On Wed 09-01-13 17:26:36, Namjae Jeon wrote:
<snip>
> But in one normal scenario, the changes actually results in
> performance degradation.
> 
> Results for a??dda?? thread on two devices:
> Before applying Patch:
> #> dd if=/dev/zero of=/mnt/sdb2/file1 bs=1048576 count=800 &
> #> dd if=/dev/zero of=/mnt/sda6/file2 bs=1048576 count=2000 &
> #>
> #> 2000+0 records in
> 2000+0 records out
> 2097152000 bytes (2.0GB) copied, 77.205276 seconds, 25.9MB/s  -> USB
> HDD WRITE Speed
> 
> [2]+ Done dd if=/dev/zero of=/mnt/sda6/file2 bs=1048576 count=2000
> #>
> #>
> #> 800+0 records in
> 800+0 records out
> 838860800 bytes (800.0MB) copied, 154.528362 seconds, 5.2MB/s -> USB
> Flash WRITE Speed
> 
> After applying patch:
> #> dd if=/dev/zero of=/mnt/sdb2/file1 bs=1048576 count=800 &
> dd if=/
> #> dd if=/dev/zero of=/mnt/sda6/file2 bs=1048576 count=2000 &
> #>
> #> 2000+0 records in
> 2000+0 records out
> 2097152000 bytes (2.0GB) copied, 123.844770 seconds, 16.1MB/s ->USB
> HDD WRITE Speed
> 800+0 records in
> 800+0 records out
> 838860800 bytes (800.0MB) copied, 141.352945 seconds, 5.7MB/s -> USB
> Flash WRITE Speed
> 
> [2]+ Done dd if=/dev/zero of=/mnt/sda6/file2 bs=1048576 count=2000
> [1]+ Done dd if=/dev/zero of=/mnt/sdb2/file1 bs=1048576 count=800
> 
> So, after applying our changes:
> 1) USB HDD Write speed dropped from 25.9 -> 16.1 MB/s
> 2) USB Flash Write speed increased marginally from 5.2 -> 5.7 MB/s
> 
> Normally if we have a USB Flash and HDD plugged in system. And if we
> initiate the a??dda?? on both the devices. Once dirty memory is more than
> the background threshold, flushing starts for all BDI (The write-back
> for the devices will be kicked by the condition):
> If (global_page_state(NR_FILE_DIRTY) +
> global_page_state(NR_UNSTABLE_NFS) > background_thresh))
> 	return true;
> As the slow device and the fast device always make sure that there is
> enough DIRTY data in memory to kick write-back.
> Since, USB Flash is slow, the DIRTY pages corresponding to this device
> is much higher, resulting in returning a??truea?? everytime from
> over_bground_thresh. So, even though HDD might have only few KB of
> dirty data, it is also flushed immediately.
> This frequent flushing of HDD data results in gradually increasing the
> bdi_dirty_limit() for HDD.
  Interesting. Thanks for testing! So is this just a problem with initial
writeout fraction estimation. I.e. if you first let dd to USB HDD run for a
couple of seconds to ramp up its fraction and only then start writeout to
USB flash, is there still a problem with USB HDD throughput with the
changed over_bground_thresh() function?

> But, when we introduce the change to control per BDI i.e.,
>  if (global_page_state(NR_FILE_DIRTY) +
>          global_page_state(NR_UNSTABLE_NFS) > background_thresh &&
>          reclaimable * 2 + bdi_stat_error(bdi) * 2 > bdi_bground_thresh)
> 
> Now, in this case, when we consider the same scenario, writeback for
> HDD will only be kicked only if a??reclaimable * 2 + bdi_stat_error(bdi)
> * 2 > bdi_bground_thresha??
> But this condition is not true a lot many number of times, so
> resulting in false.
  I'm surprised it's not true so often... dd(1) should easily fill the
caches. But maybe we are oscilating between below-background-threshold
and at-dirty-limit situations rather quickly. Do you have recordings of
BDI_RECLAIMABLE and BDI_DIRTY from the problematic run?

> This continuous failure to start write-back for HDD actually results
> in lowering the bdi_dirty_limit for HDD, in a way PAUSING the writer
> thread for HDD.
> This is actually resulting in less number of WRITE operations per
> second for HDD. As, the a??dda?? on USB HDD will be put to long sleep(MAX
> PAUSE) in balance_dirty_pages.
> 
> While for USB Flash, its bdi_dirty_limit is kept on increasing as it
> is getting more chance to flush dirty data in over_bground_thresh. As,
> bdi_reclaimable > bdi_dirty_limit is true. So, resulting more number
> of WRITE operation per second for USB Flash.
> From these observations, we feel that these changes might not be
> needed. Please let us know in case we are missing on any point here,
> we can further check more on this.
  Well, at least we know changing the condition has unexpected side
effects. I'd like to understand those before discarding the idea - because
in your setup flusher thread must end up writing rather small amount of
pages in each run when it's running continuously and that's not too good
either...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
