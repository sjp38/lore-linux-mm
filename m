From: Gerhard Wiesinger <lists@wiesinger.com>
Subject: Re: Still OOM problems with 4.9er kernels
Date: Fri, 9 Dec 2016 17:58:14 +0100
Message-ID: <fd029311-f0fe-3d1f-26d2-1f87576b14da@wiesinger.com>
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161209160946.GE4334@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209160946.GE4334@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>
List-Id: linux-mm.kvack.org

On 09.12.2016 17:09, Michal Hocko wrote:
> On Fri 09-12-16 16:52:07, Gerhard Wiesinger wrote:
>> On 09.12.2016 14:40, Michal Hocko wrote:
>>> On Fri 09-12-16 08:06:25, Gerhard Wiesinger wrote:
>>>> Hello,
>>>>
>>>> same with latest kernel rc, dnf still killed with OOM (but sometimes
>>>> better).
>>>>
>>>> ./update.sh: line 40:  1591 Killed                  ${EXE} update ${PARAMS}
>>>> (does dnf clean all;dnf update)
>>>> Linux database.intern 4.9.0-0.rc8.git2.1.fc26.x86_64 #1 SMP Wed Dec 7
>>>> 17:53:29 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
>>>>
>>>> Updated bug report:
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=1314697
>>> Could you post your oom report please?
>> E.g. a new one with more than one included, first one after boot ...
>>
>> Just setup a low mem VM under KVM and it is easily triggerable.
> What is the workload?

just run dnf clean all;dnf update
(and the other tasks running on those machine. The normal load on most 
of these machines is pretty VERY LOW, e.g. running just an apache httpd 
doing nothing or e.g. running samba domain controller doing nothing)

So my setups are low mem VMs so that KVM host has most of the caching 
effects shared.

I'm running this setup since Fedora 17 under kernel-3.3.4-5.fc17.x86_64 
and had NO problems.

Problems started with 4.4.3-300.fc23.x86_64 and got worser in each major 
kernel versions (for upgrades I had even give the VMs temporarilly more 
memory for the upgrade situation).
(from my bug report at
https://bugzilla.redhat.com/show_bug.cgi?id=1314697
Previous kernel version on guest/host was rocket stable. Revert to 
kernel-4.3.5-300.fc23.x86_64 also solved it.)

For completeness the actual kernel parameters on all hosts and VMs.
vm.dirty_background_ratio=3
vm.dirty_ratio=15
vm.overcommit_memory=2
vm.overcommit_ratio=80
vm.swappiness=10

With kernel 4.9.0rc7 or rc8 it was getting better. But still not there 
where it should be (and was already).

>
>> Still enough virtual memory available ...
> Well, you will always have a lot of virtual memory...

And why is it not used, e.g. swapped and gets into an OOM situation?

>
>> 4.9.0-0.rc8.git2.1.fc26.x86_64
>>
>> [  624.862777] ksoftirqd/0: page allocation failure: order:0, mode:0x2080020(GFP_ATOMIC)
> [...]
>> [95895.765570] kworker/1:1H: page allocation failure: order:0, mode:0x2280020(GFP_ATOMIC|__GFP_NOTRACK)
> These are atomic allocation failures and should be recoverable.
> [...]
>
>> [97883.838418] httpd invoked oom-killer:  gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=0, order=0,  oom_score_adj=0
> But this is a real OOM killer invocation because a single page allocation
> cannot proceed.
>
> [...]
>> [97883.882611] Mem-Info:
>> [97883.883747] active_anon:2915 inactive_anon:3376 isolated_anon:0
>>                  active_file:3902 inactive_file:3639 isolated_file:0
>>                  unevictable:0 dirty:205 writeback:0 unstable:0
>>                  slab_reclaimable:9856 slab_unreclaimable:9682
>>                  mapped:3722 shmem:59 pagetables:2080 bounce:0
>>                  free:748 free_pcp:15 free_cma:0
> there is still some page cache which doesn't seem to be neither dirty
> nor under writeback. So it should be theoretically reclaimable but for
> some reason we cannot seem to reclaim that memory.
> There is still some anonymous memory and free swap so we could reclaim
> it as well but it all seems pretty down and the memory pressure is
> really large

Yes, it might be large on the update situation, but that should be 
handled by a virtual memory system by the kernel, right?

>
>> [97883.890766] Node 0 active_anon:11660kB inactive_anon:13504kB
>> active_file:15608kB inactive_file:14556kB unevictable:0kB isolated(anon):0kB
>> isolated(file):0kB mapped:14888kB dirty:820kB writeback:0kB shmem:0kB
>> shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 236kB writeback_tmp:0kB
>> unstable:0kB pages_scanned:168352 all_unreclaimable? yes
> all_unreclaimable also agrees that basically nothing is reclaimable.
> That was one of the criterion to hit the OOM killer prior to the rewrite
> in 4.6 kernel. So I suspect that older kernels would OOM under your
> memory pressure as well.


See comments above.

Thnx.


Ciao,

Gerhard
