Message-ID: <46CD9281.3050600@shadowen.org>
Date: Thu, 23 Aug 2007 14:58:25 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] SGI Altix cross partition memory (XPMEM)
References: <20070810010659.GA25427@sgi.com>	<20070810011435.GD25427@sgi.com>	<20070809231542.f6dcce8c.akpm@linux-foundation.org>	<20070822170011.GA20155@sgi.com>	<20070822110422.65c990e5.akpm@linux-foundation.org>	<20070822191516.GA24018@sgi.com> <20070822124928.19bf0431.akpm@linux-foundation.org>
In-Reply-To: <20070822124928.19bf0431.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dean Nelson <dcn@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 22 Aug 2007 14:15:16 -0500
> Dean Nelson <dcn@sgi.com> wrote:
> 
>> On Wed, Aug 22, 2007 at 11:04:22AM -0700, Andrew Morton wrote:
>>> On Wed, 22 Aug 2007 12:00:11 -0500
>>> Dean Nelson <dcn@sgi.com> wrote:
>>>
>>>>   3) WARNING: declaring multiple variables together should be avoided
>>>>
>>>> checkpatch.pl is erroneously commplaining about the following found in five
>>>> different functions in arch/ia64/sn/kernel/xpmem_pfn.c.
>>>>
>>>> 	int n_pgs = xpmem_num_of_pages(vaddr, size);
>>> What warning does it generate here?
>> The WARNING #3 above "declaring multiple variables together should be avoided".
>> There is only one variable being declared, which happens to be initialized by
>> the function xpmem_num_of_pages().
> 
> Ah, I think I recall seeing a report of that earlier.  Maybe it's been fixed?

Yep that got fixed.  Though the consensus was there were too many good
uses for the multiple define form that it got put on ice after that too.

>> ...
>>>> I've switched from using nopage to using fault. I read that it is intended
>>>> that nopfn also goes away. If this is the case, then the BUG_ON if VM_PFNMAP
>>>> is set would make __do_fault() a rather unfriendly replacement for do_no_pfn().
>>>>
>>>>> - xpmem_attach() does smp_processor_id() in preemptible code.  Lucky that
>>>>>   ia64 doesn't do preempt?
>>>> Actually, the code is fine as is even with preemption configured on. All it's
>>>> doing is ensuring that the thread was previously pinned to the CPU it's
>>>> currently running on. If it is, it can't be moved to another CPU via
>>>> preemption, and if it isn't, the check will fail and we'll return -EINVAL
>>>> and all is well.
>>> OK.  Running smp_processor_id() from within preemptible code will generate
>>> a warning, but the code is sneaky enough to prevent that warning if the
>>> calling task happens to be pinned to a single CPU.
>> Would it make more sense in this particular case to replace the call to
>> smp_processor_id() in xpmem_attach() with a call to raw_smp_processor_id()
>> instead, and add a comment explaining why?
> 
> Your call ;)  Either will be OK, I expect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
