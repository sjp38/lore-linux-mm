From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Date: Sat, 05 Apr 2008 23:18:25 +0530
Message-ID: <47F7BB69.3000502@linux.vnet.ibm.com>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain> <6599ad830804040112q3dd5333aodf6a170c78e61dc8@mail.gmail.com> <47F5E69C.9@linux.vnet.ibm.com> <6599ad830804040150j4946cf92h886bb26000319f3b@mail.gmail.com> <47F5F3FA.7060709@linux.vnet.ibm.com> <6599ad830804041211r37848a6coaa900d8bdac40fbe@mail.gmail.com> <47F79102.6090406@linux.vnet.ibm.com> <6599ad830804051023v69caa3d4h6e26ccb420bca899@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754072AbYDERt2@vger.kernel.org>
In-Reply-To: <6599ad830804051023v69caa3d4h6e26ccb420bca899@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Paul Menage wrote:
> On Sat, Apr 5, 2008 at 7:47 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  Repeating my question earlier
>>
>>  Can we delay setting task->cgroups = &init_css_set for the group_leader, until
>>  all threads have exited?
> 
> Potentially, yes. It also might make more sense to move the
> exit_cgroup() for all threads to a later point rather than special
> case delayed group leaders.
> 

Yes, that makes sense. I think that patch should be independent of this one
though? What do you think?

>> If the user is unable to remove a cgroup node, it will
>>  be due a valid reason, the group_leader is still around, since the threads are
>>  still around. The user in that case should wait for notify_on_release.
>>
>>  >
>>  > To me, it seems that setting up a *virtual address space* cgroup
>>  > hierarchy and then putting half your threads in one group and half in
>>  > the another is asking for trouble. We need to not break in that
>>  > situation, but I'm not sure it's a case to optimize for.
>>
>>  That could potentially happen, if the virtual address space cgroup and cpu
>>  control cgroup were bound together in the same hierarchy by the sysadmin.
> 
> Yes, I agree it could potentially happen. But it seems like a strange
> thing to do if you're planning to be not have the same groupings for
> cpu and va.
> 

It's easier to set it up that way. Usually the end user gets the same SLA for
memory, CPU and other resources, so it makes sense to bind the controllers together.

>>  I measured the overhead of removing the delay_group_leader optimization and
>>  found a 4% impact on throughput (with volanomark, that is one of the
>>  multi-threaded benchmarks I know of).
> 
> Interesting, I thought (although I've never actually looked at the
> code) that volanomark was more of a scheduling benchmark than a
> process start/exit benchmark. How frequently does it have processes
> (not threads) exiting?
> 

I could not find any other interesting benchmark for benchmarking fork/exits. I
know that volanomark is heavily threaded, so I used it. The threads quickly exit
after processing the messages, I thought that would be a good test to see the
overhead.

> How many runs was that over? Ingo's recently posted volanomark tests
> against -rc7 showed ~3% random variation between runs.

I ran the test four times. I took the average of runs, I did see some variation
between runs, I did not calculate the standard deviation.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
