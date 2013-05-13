Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 73EA26B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 03:14:06 -0400 (EDT)
Date: Mon, 13 May 2013 17:14:00 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 00/31] kmemcg shrinkers
Message-ID: <20130513071359.GM32675@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368382432-25462-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org

On Sun, May 12, 2013 at 10:13:21PM +0400, Glauber Costa wrote:
> Initial notes:
> ==============
> 
> Mel, Dave, this is the last round of fixes I have for the series. The fixes are
> few, and I was mostly interested in getting this out based on an up2date tree
> so Dave can verify it. This should apply fine ontop of Friday's linux-next.
> Alternatively, please grab from branch "kmemcg-lru-shrinker" at:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git
> 
> Main changes from *v5:
> * Rebased to linux-next, and fix the conflicts with the dcache.
> * Make sure LRU_RETRY only retry once
> * Prevent the bcache shrinker to scan the caches when disabled (by returning
>   0 in the count function)
> * Fix i915 return code when mutex cannot be acquired.
> * Only scan less-than-batch objects in memcg scenarios

Ok, this is behaving a *lot* better than v5 in terms of initial
balance and sustained behaviour under pure inode/dentry press
workloads. The previous version was all over the place, not to
mention unstable and prone to unrealted lockups in the block layer.

However, I'm not sure that the LRUness of reclaim is working
correctly at this point. When I switch from a write only workload to
a read-only workload (i.e. fsmark finishes and find starts), I see
this:

 OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
1923037 1807201  93%    1.12K  68729       28   2199328K xfs_inode
1914624 490812  25%    0.22K  53184       36    425472K xfs_ili

Note the xfs_ili slab capacity - there's half a million objects
still in the cache, and they are only present on *dirty* inodes.
Now, the read-only workload is iterating through a cold-cache lookup
workload of 50 million inodes - at roughly 150,000/s. It's a
touch-once workload, so shoul dbe turning the cache over completely
every 10 seconds. However, in the time it's taken for me to explain
this:

 OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
1954493 1764661  90%    1.12K  69831       28   2234592K xfs_inode
1643868 281962  17%    0.22K  45663       36    365304K xfs_ili   

Only 200k xfs_ili's have been freed. So the rate of reclaim of them
is roughly 5k/s. Given the read-only nature of this workload, they
should be gone from the cache in a few seconds. Another indication
of problems here is the level of internal fragmentation of the
xfs_ili slab. They should cycle out of the cache in LRU manner, just
like inodes - the modify workload is a "touch once" workload as
well, so there should be no internal fragmentation of the slab
cache.

The stats I have of cache residency during the read-only part of the
workload looks really bad. No steady state is reached, while on 3.9
a perfect steady state is reached within seconds and maintained
until the workload changes. Part way through the read-only workload,
this happened:

[  562.673080] sh (5007): dropped kernel caches: 3
[  629.617303] lowmemorykiller: send sigkill to 3953 (winbindd), adj 0, size 195
[  629.625499] lowmemorykiller: send sigkill to 3439 (pmcd), adj 0, size 158

And when the read-only workload finishes it's walk, I then start
another "touch once" workload that removes all the files. that
triggered:

[ 1002.183604] lowmemorykiller: send sigkill to 5827 (winbindd), adj 0, size 246
[ 1002.187822] lowmemorykiller: send sigkill to 3904 (winbindd), adj 0, size 134

Yeah, that stupid broken low memory killer is now kicking in,
killing random processes - last run it killed two of the rm
processes doing work, this time it killed winbindd and the PCP
collection daemon that I use for remote stats monitoring.

So, yeah, there's still some broken stuff in this patchset that
needs fixing.  The script that I'm running to trigger these problems
is pretty basic - it's the same workload I've been using for the
past 3 years for measuring metadata performance of filesystems:

$ cat ./fsmark-50-test-xfs.sh 
#!/bin/bash

sudo umount /mnt/scratch > /dev/null 2>&1
sudo mkfs.xfs -f $@ -l size=131072b,sunit=8 /dev/vdc
sudo mount -o nobarrier,logbsize=256k /dev/vdc /mnt/scratch
sudo chmod 777 /mnt/scratch
cd /home/dave/src/fs_mark-3.3/
time ./fs_mark  -D  10000  -S0  -n  100000  -s  0  -L  63 \
        -d  /mnt/scratch/0  -d  /mnt/scratch/1 \
        -d  /mnt/scratch/2  -d  /mnt/scratch/3 \
        -d  /mnt/scratch/4  -d  /mnt/scratch/5 \
        -d  /mnt/scratch/6  -d  /mnt/scratch/7 \
        | tee >(stats --trim-outliers | tail -1 1>&2)
sync
sleep 30
sync

echo walking files
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
time (
        for d in /mnt/scratch/[0-9]* ; do

                for i in $d/*; do
                        (
                                echo $i
                                find $i -ctime 1 > /dev/null
                        ) > /dev/null 2>&1
                done &
        done
        wait
)

echo removing files
for f in /mnt/scratch/* ; do time rm -rf $f &  done
wait
$

It's running on an 8p, 4GB RAM, 4-node fake numa virtual machine
with a 100TB sparse image file being used for the test filesystem.

I'll spend some time over the next few days trying to work out what
is causing these issues....

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
