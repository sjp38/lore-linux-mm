Message-ID: <46DDE623.1090402@sgi.com>
Date: Tue, 04 Sep 2007 16:11:31 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] x86: Convert cpu_sibling_map to be a per cpu variable
 (v2) (fwd)
References: <Pine.LNX.4.64.0708312028400.24049@schroedinger.engr.sgi.com>	<46DDC017.4040301@sgi.com> <20070904141055.e00a60d7.akpm@linux-foundation.org>
In-Reply-To: <20070904141055.e00a60d7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, steiner@sgi.com, ak@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamalesh@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:
>> On Tue, 04 Sep 2007 13:29:11 -0700 Mike Travis <travis@sgi.com> wrote:

>>> ---------- Forwarded message ----------
>>> Date: Fri, 31 Aug 2007 19:49:03 -0700
>>> From: Andrew Morton <akpm@linux-foundation.org>
>>> To: travis@sgi.com
>>> Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
>>>     Christoph Lameter <clameter@sgi.com>
>>> Subject: Re: [PATCH 3/6] x86: Convert cpu_sibling_map to be a per cpu variable
>>>     (v2)
>>>
>>> On Fri, 24 Aug 2007 15:26:57 -0700 travis@sgi.com wrote:
>>>
>>>> Convert cpu_sibling_map from a static array sized by NR_CPUS to a
>>>> per_cpu variable.  This saves sizeof(cpumask_t) * NR unused cpus.
>>>> Access is mostly from startup and CPU HOTPLUG functions.
>>> ia64 allmodconfig:
>>>
>>> kernel/sched.c: In function `cpu_to_phys_group':                                                                             kernel/sched.c:5937: error: `per_cpu__cpu_sibling_map' undeclared (first use in this function)                               kernel/sched.c:5937: error: (Each undeclared identifier is reported only once
>>> kernel/sched.c:5937: error: for each function it appears in.)                                                                kernel/sched.c:5937: warning: type defaults to `int' in declaration of `type name'
>>> kernel/sched.c:5937: error: invalid type argument of `unary *'                                                               kernel/sched.c: In function `build_sched_domains':                                                                           kernel/sched.c:6172: error: `per_cpu__cpu_sibling_map' undeclared (first use in this function)                               kernel/sched.c:6172: warning: type defaults to `int' in declaration of `type name'                                           kernel/sched.c:6172: error: invalid type argument of `unary *'                                                               kernel/sched.c:6183: warning: type defaults to `int' in declaration of `type name'                                           kernel/sched.c:6183: error: invalid type argument of `unary *'                                                               
>> I'm thinking that the best approach would be to define a cpu_sibling_map() macro
>> to handle the cases where cpu_sibling_map is not a per_cpu variable?  Perhaps
>> something like:
>>
>> #ifdef CONFIG_SCHED_SMT
>> #ifndef cpu_sibling_map
>> #define cpu_sibling_map(cpu)    cpu_sibling_map[cpu]
>> #endif
>> #endif
>>
>> My question though, would include/linux/smp.h be the appropriate place for
>> the above define?  (That is, if the above approach is the correct one... ;-)
> 
> It'd be better to convert the unconverted architectures?

I can easily do the changes for ia64 and test them.  I don't have the capability
of testing on the powerpc.  

And are you asking for just the changes to fix the build problem, or the whole
set of the changes that were made for x86_64 and i386 in regards to converting
NR_CPU arrays to per cpu data?

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
