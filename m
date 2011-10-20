Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2DF136B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 23:59:23 -0400 (EDT)
Date: Thu, 20 Oct 2011 11:59:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 1/2] nfs: writeback pages wait queue
Message-ID: <20111020035918.GA26746@localhost>
References: <20111003134228.090592370@intel.com>
 <1318248846.14400.21.camel@laptop>
 <20111010130722.GA11387@localhost>
 <20111010131051.GA16847@localhost>
 <20111018085147.GA27805@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111018085147.GA27805@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> @@ -424,6 +419,10 @@ int nfs_writepages(struct address_space 
>  	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
>  	nfs_pageio_complete(&pgio);
>  
> +	nfs_wait_congested(wbc->sync_mode == WB_SYNC_ALL,
> +			   &nfss->backing_dev_info,
> +			   nfss->writeback_wait);
> +
>  	clear_bit_unlock(NFS_INO_FLUSHING, bitlock);
>  	smp_mb__after_clear_bit();
>  	wake_up_bit(bitlock, NFS_INO_FLUSHING);

The "wakeup NFS_INO_FLUSHING after congestion wait" logic looks
strange, so I tried moving the nfs_wait_congested() _after_
wake_up_bit()...and got write_bw regressions.

OK, not knowing what's going on underneath, I'll just stick to the current form.

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+  
------------------------  ------------------------  
                  417.26        -5.5%       394.24  TOTAL write_bw
                 5179.00       -12.6%      4529.00  TOTAL nfs_nr_commits
               340466.00       -37.2%    213939.00  TOTAL nfs_nr_writes
                  722.54       +17.6%       849.42  TOTAL nfs_commit_size
                    3.75        +6.3%         3.99  TOTAL nfs_write_size
                15477.38       -14.5%     13235.34  TOTAL nfs_write_queue_time
                  517.54       +13.0%       585.00  TOTAL nfs_write_rtt_time
                16011.09       -13.5%     13848.09  TOTAL nfs_write_execute_time
                  714.65       -43.4%       404.65  TOTAL nfs_commit_queue_time
                12787.93        +9.2%     13960.35  TOTAL nfs_commit_rtt_time
                13519.94        +6.4%     14387.44  TOTAL nfs_commit_execute_time

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                   44.42        -0.8%        44.05  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   78.49        -8.0%        72.22  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   69.96        -2.4%        68.30  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                   70.59        -3.8%        67.88  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   76.76        -8.7%        70.09  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   77.04        -6.9%        71.70  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  417.26        -5.5%       394.24  TOTAL write_bw

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                 2683.00        -1.8%      2634.00  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  811.00       -43.8%       456.00  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                 1049.00       -16.7%       874.00  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  474.00        -8.4%       434.00  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   56.00       -23.2%        43.00  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                  106.00       -17.0%        88.00  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                 5179.00       -12.6%      4529.00  TOTAL nfs_nr_commits

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                17641.00        -2.2%     17257.00  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
               177296.00       -54.1%     81335.00  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                26346.00       +41.6%     37309.00  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                22279.00       +12.7%     25107.00  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                67612.00       -59.7%     27271.00  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                29292.00       -12.4%     25660.00  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
               340466.00       -37.2%    213939.00  TOTAL nfs_nr_writes

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                    4.97        +1.1%         5.03  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   29.00       +63.5%        47.43  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   19.99       +17.0%        23.40  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                   44.66        +5.3%        47.03  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                  408.94       +18.6%       485.03  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                  214.96       +12.3%       241.50  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  722.54       +17.6%       849.42  TOTAL nfs_commit_size

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                    0.76        +1.5%         0.77  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                    0.13      +100.4%         0.27  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                    0.80       -31.1%         0.55  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                    0.95       -14.4%         0.81  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                    0.34      +125.8%         0.76  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                    0.78        +6.5%         0.83  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    3.75        +6.3%         3.99  TOTAL nfs_write_size

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                  460.14       -29.9%       322.63  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  718.69       +68.2%      1208.67  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                 5203.60       -26.1%      3843.39  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  427.40       +93.4%       826.64  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 7369.68       -18.0%      6041.98  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 1297.87       -23.6%       992.02  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                15477.38       -14.5%     13235.34  TOTAL nfs_write_queue_time

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                  134.58        -8.9%       122.60  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   33.24       +48.8%        49.46  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   89.69       -19.4%        72.31  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  129.86       -35.3%        84.03  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   48.33      +239.4%       164.05  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   81.84       +13.1%        92.55  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  517.54       +13.0%       585.00  TOTAL nfs_write_rtt_time

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                  595.23       -25.1%       445.75  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  753.68       +67.4%      1261.46  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                 5294.55       -26.0%      3917.11  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  559.44       +63.1%       912.46  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 7424.41       -16.2%      6221.64  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 1383.78       -21.3%      1089.67  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                16011.09       -13.5%     13848.09  TOTAL nfs_write_execute_time

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                    2.34        +2.5%         2.40  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                    1.59      +488.4%         9.37  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                    2.63       +47.0%         3.86  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                   68.22        -6.5%        63.78  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                  618.34       -52.9%       291.44  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   21.54       +56.9%        33.80  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  714.65       -43.4%       404.65  TOTAL nfs_commit_queue_time

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                  766.76        +1.7%       779.63  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  344.34       +49.3%       514.10  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                  431.90       +15.0%       496.81  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                 3743.78        +5.6%      3954.60  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 3699.59       +14.0%      4216.05  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 3801.55        +5.2%      3999.17  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                12787.93        +9.2%     13960.35  TOTAL nfs_commit_rtt_time

3.1.0-rc9-ioless-full-nfs-ino-flushing-next-20111014+  3.1.0-rc9-ioless-full-nfs-wakeup-wait-next-20111014+
------------------------  ------------------------
                  769.38        +1.7%       782.27  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  346.06       +51.3%       523.52  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                  434.96       +15.2%       501.07  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                 3813.17        +5.4%      4020.45  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 4318.75        +4.4%      4507.51  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 3837.62        +5.6%      4052.61  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                13519.94        +6.4%     14387.44  TOTAL nfs_commit_execute_time

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
