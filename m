Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 425CB440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:41:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y64so588592wmd.6
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:41:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d125si1556819wmf.44.2017.08.24.05.41.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 05:41:42 -0700 (PDT)
Date: Thu, 24 Aug 2017 14:41:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 196729] New: System becomes unresponsive when swapping -
 Regression since 4.10.x
Message-ID: <20170824124139.GJ5943@dhcp22.suse.cz>
References: <bug-196729-27@https.bugzilla.kernel.org/>
 <20170822155530.928b377fa636bbea28e1d4df@linux-foundation.org>
 <20170823133848.GA2652@dhcp22.suse.cz>
 <3069262.adKtTK0b29@wopr.lan.crc.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3069262.adKtTK0b29@wopr.lan.crc.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Haigh <netwiz@crc.id.au>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org

On Thu 24-08-17 00:30:40, Steven Haigh wrote:
> On Wednesday, 23 August 2017 11:38:48 PM AEST Michal Hocko wrote:
> > On Tue 22-08-17 15:55:30, Andrew Morton wrote:
> > > (switched to email.  Please respond via emailed reply-to-all, not via the
> > > bugzilla web interface).
> > 
> > > On Tue, 22 Aug 2017 11:17:08 +0000 bugzilla-daemon@bugzilla.kernel.org 
> wrote:
> > [...]
> > 
> > > Sadly I haven't been able to capture this information
> > > 
> > > > fully yet due to said unresponsiveness.
> > 
> > Please try to collect /proc/vmstat in the bacground and provide the
> > collected data. Something like
> > 
> > while true
> > do
> > 	cp /proc/vmstat > vmstat.$(date +%s)
> > 	sleep 1s
> > done
> > 
> > If the system turns out so busy that it won't be able to fork a process
> > or write the output (which you will see by checking timestamps of files
> > and looking for holes) then you can try the attached proggy
> > ./read_vmstat output_file timeout output_size
> > 
> > Note you might need to increase the mlock rlimit to lock everything into
> > memory.
> 
> Thanks Michal,
> 
> I have upgraded PCs since I initially put together this data - however I was 
> able to get strange behaviour by pulling out an 8Gb RAM stick in my new system 
> - leaving it with only 8Gb of RAM.
> 
> All these tests are performed with Fedora 26 and kernel 4.12.8-300.fc26.x86_64
> 
> I have attached 3 files with output.
> 
> 8Gb-noswap.tar.gz contains the output of /proc/vmstat running on 8Gb of RAM 
> with no swap. Under this scenario, I was expecting the OOM reaper to just kill 
> the game when memory allocated became too high for the amount of physical RAM. 
> Interestingly, you'll notice a massive hang in the output before the game is 
> terminated. I didn't see this before.

I have checked few gaps. E.g. vmstat.1503496391 vmstat.1503496451 which
is one minute. The most notable thing is that there are only very few
pagecache pages
			[base]		[diff]
nr_active_file  	1641    	3345
nr_inactive_file        1630    	4787

So there is not much to reclaim without swap. The more important thing
is that we keep reclaiming and refaulting that memory

workingset_activate     5905591 	1616391
workingset_refault      33412538        10302135
pgactivate      	42279686        13219593
pgdeactivate    	48175757        14833350

pgscan_kswapd   	379431778       126407849
pgsteal_kswapd  	49751559        13322930

so we are effectivelly trashing over the very small amount of
reclaimable memory. This is something that we cannot detect right now.
It is even questionable whether the OOM killer would be an appropriate
action. Your system has recovered and then it is always hard to decide
whether a disruptive action is more appropriate. One minute of
unresponsiveness is certainly annoying though. Your system is obviously
under provisioned to load you want to run obviously.

It is quite interesting to see that we do not really have too many
direct reclaimers during this time period
allocstall_normal       30      	1
allocstall_movable      490     	88
pgscan_direct_throttle  0       	0
pgsteal_direct  	24434   	4069
pgscan_direct   	38678   	5868
 
> 8Gb-swap-on-file.tar.gz contains the output of /proc/vmstat still with 8Gb of 
> RAM - but creating a file with swap on the PCIe SSD /swapfile with size 8Gb 
> via:
> 	# dd if=/dev/zero of=/swapfile bs=1G count=8
> 	# mkswap /swapfile
> 	# swapon /swapfile
> 
> Some times (all in UTC+10):
> 23:58:30 - Start loading the saved game
> 23:59:38 - Load ok, all running fine
> 00:00:15 - Load Chrome
> 00:01:00 - Quit the game
> 
> The game seemed to run ok with no real issue - and a lot was swapped to the 
> swap file. I'm wondering if it was purely the speed of the PCIe SSD that 
> caused this appearance - as the creation of the file with dd completed at 
> ~1.4GB/sec.

Swap IO tends to be really scattered and the IO performance is not really
great even on a fast storage AFAIK.
 
Anyway your original report sounded like a regression. Were you able to
run the _same_ workload on an older kernel without these issues?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
