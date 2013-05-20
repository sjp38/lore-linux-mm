From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: QEMU NUMA and memory allocation problem
Date: Mon, 20 May 2013 11:03:43 +0800
Message-ID: <24921.0344547921$1369019055@news.gmane.org>
References: <5194ABFD.8040200@cn.fujitsu.com>
 <51998489.804@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <51998489.804@cn.fujitsu.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Cc: aarcange@redhat.com, a.p.zijlstra@chello.nl, qemu-devel <qemu-devel@nongnu.org>, linux-mm <linux-mm@kvack.org>, mgorman@suse.de, Paolo Bonzini <pbonzini@redhat.com>, mingo@kernel.org, Wanlong Gao <gaowanlong@cn.fujitsu.com>, ehabkost@redhat.com
List-Id: linux-mm.kvack.org

On Mon, May 20, 2013 at 10:03:53AM +0800, Wanlong Gao wrote:
>Adding CC AutoNUMA folks:
>
>Paolo said that:
>
>> Pinning memory to host NUMA nodes is not implemented.  Something like
>> AutoNUMA would be able to balance the memory the right way.
>> 
>> Paolo
>
>And Eduardo said that:
>> I had plans to implement a mechanism to allow external tools to
>> implement manual pinning, but it is not one of my top priorities. It's
>> the kind of mechanism that may be obsolete since birth, if we have
>> AutoNUMA working and doing the right thing.
>> 
>> -- Eduardo 
>

Hi Wanlong,

>But I didn't see any change when I enabled the AutoNUMA on my host.
>Can AutoNUMA folks teach me why?
>Or any plans to handle this problem in AutoNUMA? 
>

AutoNUMA is not merged currently, the foundation(automatic NUMA
balancing) that either the policy for schednuma or autonuma can be
rebased on implemented by Mel has already merged.

Regards,
Wanpeng Li 

>
>Thanks,
>Wanlong Gao
>
>
>
>> Hi,
>> 
>> We just met a problem of QEMU memory allocation.
>> Here is the description:
>> 
>> On my host, I have two nodes,
>> # numactl -H
>> available: 2 nodes (0-1)
>> node 0 cpus: 0 2
>> node 0 size: 4010 MB
>> node 0 free: 3021 MB
>> node 1 cpus: 1 3
>> node 1 size: 4030 MB
>> node 1 free: 2881 MB
>> node distances:
>> node   0   1 
>>   0:  10  20 
>>   1:  20  10 
>> 
>> 
>> 
>> I created a guest using the following XML:
>> 
>> ...
>>   <memory unit='KiB'>1048576</memory>
>>   <currentMemory unit='KiB'>1048576</currentMemory>
>>   <vcpu placement='static'>2</vcpu>
>>   <cputune>
>>     <vcpupin vcpu='0' cpuset='2'/>
>>     <vcpupin vcpu='1' cpuset='3'/>
>>   </cputune>
>>   <numatune>
>>     <memory mode='strict' nodeset='0-1'/>
>>   </numatune>
>>   <cpu>
>>     <topology sockets='2' cores='1' threads='1'/>
>>     <numa>
>>       <cell cpus='0' memory='524288'/>
>>       <cell cpus='1' memory='524288'/>
>>     </numa>
>>   </cpu>
>> ...
>> 
>> As you can see, I assigned 1G memory to this guest, pined vcpu0 to the host CPU 2,
>> it's in host node0, pined vcpu1 to the host CPU 3 that is in host node1.
>> The guest also has two nodes, each node contains 512M memory.
>> 
>> Now, I started the guest, then printed the host numa state :
>> # numactl -H
>> available: 2 nodes (0-1)
>> node 0 cpus: 0 2
>> node 0 size: 4010 MB
>> node 0 free: 2647 MB  <=== freecell of node0
>> node 1 cpus: 1 3
>> node 1 size: 4030 MB
>> node 1 free: 2746 MB
>> node distances:
>> node   0   1 
>>   0:  10  20 
>>   1:  20  10 
>> 
>> Then I tried to allocate memory from guest node0 using the following code:
>>> #include <memory.h>
>>> #include <numa.h>
>>>
>>> #define MEM (1024*1024*300)
>>>
>>> int main(void)
>>> {
>>> 	char *p = numa_alloc_onnode(MEM, 0);
>>> 	memset(p, 0, MEM);
>>> 	sleep(1000);
>>> 	numa_free(p, MEM);
>>> 	return 0;
>>> }
>> 
>> And printed the host numa state, it shows that this 300M memory is allocated from host node0,
>> 
>> # numactl -H
>> available: 2 nodes (0-1)
>> node 0 cpus: 0 2
>> node 0 size: 4010 MB
>> node 0 free: 2345 MB	<===== reduced ~300M
>> node 1 cpus: 1 3
>> node 1 size: 4030 MB
>> node 1 free: 2767 MB
>> node distances:
>> node   0   1 
>>   0:  10  20 
>>   1:  20  10 
>> 
>> 
>> Then, I tried the same method to allocate 300M memory from guest node1, and printed the host
>> numa state:
>> 
>> # numactl -H
>> available: 2 nodes (0-1)
>> node 0 cpus: 0 2
>> node 0 size: 4010 MB
>> node 0 free: 2059 MB	<=== reduced ~300M
>> node 1 cpus: 1 3
>> node 1 size: 4030 MB
>> node 1 free: 2767 MB	<=== no change
>> node distances:
>> node   0   1 
>>   0:  10  20 
>>   1:  20  10 
>> 
>> 
>> To see that this 300M memory is allocated from host node0 again, but not host node1 as
>> I expected.
>> 
>> We think that QEMU can't handled this numa memory allocation well, and it will cause the
>> cross node memory access performance regression.
>> 
>> Any thoughts? Or, am I missing something?
>> 
>> 
>> Thanks,
>> Wanlong Gao
>> 
>> 
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
