Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C28C56B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 01:03:40 -0400 (EDT)
Received: by mail-da0-f43.google.com with SMTP id u36so1924120dak.30
        for <linux-mm@kvack.org>; Sun, 14 Apr 2013 22:03:39 -0700 (PDT)
Message-ID: <516B8A26.7060402@gmail.com>
Date: Mon, 15 Apr 2013 13:03:34 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: System freezes when RAM is full (64-bit)
References: <5159DCA0.3080408@gmail.com> <20130403121220.GA14388@dhcp22.suse.cz> <515CC8E6.3000402@gmail.com> <20130404070856.GB29911@dhcp22.suse.cz> <515D89BE.2040609@gmail.com> <20130404151658.GJ29911@dhcp22.suse.cz> <515EA3B7.5030308@gmail.com> <20130405115914.GD31132@dhcp22.suse.cz> <515F3701.1080504@gmail.com> <20130412102020.GA20624@dhcp22.suse.cz>
In-Reply-To: <20130412102020.GA20624@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ivan Danov <huhavel@gmail.com>, linux-mm@kvack.org, 1162073@bugs.launchpad.net, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

Hi Michal,
On 04/12/2013 06:20 PM, Michal Hocko wrote:
> [CCing Mel and Johannes]
> On Fri 05-04-13 22:41:37, Ivan Danov wrote:
>> Here you can find attached the script, collecting the logs and the
>> logs themselves during the described process of freezing. It
>> appeared that the previous logs are corrupted, because both
>> /proc/vmstat and /proc/meminfo have been logging to the same file.
> Sorry for the late reply:
> $ grep MemFree: meminfo.1365194* | awk 'BEGIN{min=9999999}{val=$2; if(val<min)min=val; if(val>max)max=val; sum+=val; n++}END{printf "min:%d max:%d avg:%.2f\n", min, max, sum/n}'
> min:165256 max:3254516 avg:1642475.35
>
> So the free memory dropped down to 165M at minimum. This doesn't sound
> terribly low and the average free memory was even above 1.5G. But maybe
> the memory consumption peak was very short between 2 measured moments.
>
> The peak seems to be around this time:
> meminfo.1365194083:MemFree:          650792 kB
> meminfo.1365194085:MemFree:          664920 kB
> meminfo.1365194087:MemFree:          165256 kB  <<<
> meminfo.1365194089:MemFree:          822968 kB
> meminfo.1365194094:MemFree:          666940 kB
>
> Let's have a look at the memory reclaim activity
> vmstat.1365194085:pgscan_kswapd_dma32 760
> vmstat.1365194085:pgscan_kswapd_normal 10444
>
> vmstat.1365194087:pgscan_kswapd_dma32 760
> vmstat.1365194087:pgscan_kswapd_normal 10444
>
> vmstat.1365194089:pgscan_kswapd_dma32 5855
> vmstat.1365194089:pgscan_kswapd_normal 80621
>
> vmstat.1365194094:pgscan_kswapd_dma32 54333
> vmstat.1365194094:pgscan_kswapd_normal 285562
>
> [...]
> vmstat.1365194098:pgscan_kswapd_dma32 54333
> vmstat.1365194098:pgscan_kswapd_normal 285562
>
> vmstat.1365194100:pgscan_kswapd_dma32 55760
> vmstat.1365194100:pgscan_kswapd_normal 289493
>
> vmstat.1365194102:pgscan_kswapd_dma32 55760
> vmstat.1365194102:pgscan_kswapd_normal 289493
>
> So the background reclaim was active only twice for a short amount of
> time:
> - 1365194087 - 1365194094 - 53573 pages in dma32 and 275118 in normal zone
> - 1365194098 - 1365194100 - 1427 pages in dma32 and 3931 in normal zone
>
> The second one looks sane so we can ignore it for now but the first one
> scanned 1074M in normal zone and 209M in the dma32 zone. Either kswapd
> had hard time to find something to reclaim or it couldn't cope with the
> ongoing memory pressure.
>
> vmstat.1365194087:pgsteal_kswapd_dma32 373
> vmstat.1365194087:pgsteal_kswapd_normal 9057
>
> vmstat.1365194089:pgsteal_kswapd_dma32 3249
> vmstat.1365194089:pgsteal_kswapd_normal 56756
>
> vmstat.1365194094:pgsteal_kswapd_dma32 14731
> vmstat.1365194094:pgsteal_kswapd_normal 221733
>
> ...087-...089
> 	- dma32 scanned 5095, reclaimed 0
> 	- normal scanned 70177, reclaimed 0

This is not correct.
     - dma32 scanned 5095, reclaimed 2876, effective = 56%
     - normal scanned 70177, reclaimed 47699, effective = 68%

> ...089-...094
> 	-dma32 scanned 48478, reclaimed 2876
> 	- normal scanned 204941, reclaimed 164977

     - dma32 scanned 48478, reclaimed 11482, effective = 23%
     - normal scanned 204941, reclaimed 164977, effective = 80%

> This shows that kswapd was not able to reclaim any page at first and
> then it reclaimed a lot (644M in 5s) but still very ineffectively (5% in
> dma32 and 80% for normal) although normal zone seems to be doing much
> better.
>
> The direct reclaim was active during that time as well:
> vmstat.1365194089:pgscan_direct_dma32 0
> vmstat.1365194089:pgscan_direct_normal 0
>
> vmstat.1365194094:pgscan_direct_dma32 29339
> vmstat.1365194094:pgscan_direct_normal 86869
>
> which scanned 29339 in dma32 and 86869 in normal zone while it reclaimed:
>
> vmstat.1365194089:pgsteal_direct_dma32 0
> vmstat.1365194089:pgsteal_direct_normal 0
>
> vmstat.1365194094:pgsteal_direct_dma32 6137
> vmstat.1365194094:pgsteal_direct_normal 57677
>
> 225M in the normal zone but it was still not effective very much (~20%
> for dma32 and 66% for normal).
>
> vmstat.1365194087:nr_written 9013
> vmstat.1365194089:nr_written 9013
> vmstat.1365194094:nr_written 15387
>
> Only around 24M have been written out during the massive scanning.
>
> So we have two problems here I guess. First is that there is not much
> reclaimable memory when the peak consumption starts and then we have
> hard times to balance dma32 zone.
>
> vmstat.1365194087:nr_shmem 103548
> vmstat.1365194089:nr_shmem 102227
> vmstat.1365194094:nr_shmem 100679
>
> This tells us that you didn't have that many shmem pages allocated at
> the time (only 404M). So the /tmp backed by tmpfs shouldn't be the
> primary issue here.
>
> We still have a lot of anonymous memory though:
> vmstat.1365194087:nr_anon_pages 1430922
> vmstat.1365194089:nr_anon_pages 1317009
> vmstat.1365194094:nr_anon_pages 1540460
>
> which is around 5.5G. It is interesting that the number of these pages
> even drops first and then starts growing again (between 089..094 by 870M
> while we reclaimed around the same amount). This would suggest that the
> load started trashing on swap but:
>
> meminfo.1365194087:SwapFree:        1999868 kB
> meminfo.1365194089:SwapFree:        1999808 kB
> meminfo.1365194094:SwapFree:        1784544 kB
>
> tells us that we swapped out only 210M after 1365194089. So we had to

How about set vm.swapiness to 200?

> reclaim a lot of page cache during that time while the anonymous memory
> pressure was really high.
>
> vmstat.1365194087:nr_file_pages 428632
> vmstat.1365194089:nr_file_pages 378132
> vmstat.1365194094:nr_file_pages 192009
>
> the page cache pages dropped down by 920M which covers the anon increase.
>
> This all suggests that the workload is simply too aggressive and the
> memory reclaim doesn't cope with it.
>
> Let's check the active and inactive lists (maybe we are not aging pages properly):
> meminfo.1365194087:Active(anon):    5613412 kB
> meminfo.1365194087:Active(file):     261180 kB
>
> meminfo.1365194089:Active(anon):    4794472 kB
> meminfo.1365194089:Active(file):     348396 kB
>
> meminfo.1365194094:Active(anon):    5424684 kB
> meminfo.1365194094:Active(file):      77364 kB
>
> meminfo.1365194087:Inactive(anon):   496092 kB
> meminfo.1365194087:Inactive(file):  1033184 kB
>
> meminfo.1365194089:Inactive(anon):   853608 kB
> meminfo.1365194089:Inactive(file):   749564 kB
>
> meminfo.1365194094:Inactive(anon):  1313648 kB
> meminfo.1365194094:Inactive(file):    82008 kB
>
> While the file LRUs looks good active Anon LRUs seem to be too big. This
> either suggests a bug in aging or the working set is really that big.
> Considering the previous data (increase during the memory pressure) I
> would be inclined to the second option.
>
> Just out of curiosity what is the vm_swappiness setting? You've said
> that you have changed that from 0 but it seems like we would swap much
> more. It almost looks like the swappiness is 0. Could you double check?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
