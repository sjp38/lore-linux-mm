Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id DA3426B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 09:24:51 -0400 (EDT)
Message-ID: <51680B20.9090202@hitachi.com>
Date: Fri, 12 Apr 2013 22:24:48 +0900
From: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch 0/2] mm: Add parameters to make kernel behavior at
 memory error on dirty cache selectable
References: <51662D5B.3050001@hitachi.com> <1365664306-rvrpdnsl-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365664306-rvrpdnsl-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

(2013/04/11 16:11), Naoya Horiguchi wrote:
> Hi Tanino-san,
> 
> On Thu, Apr 11, 2013 at 12:26:19PM +0900, Mitsuhiro Tanino wrote:
> ...
>> Solution
>> ---------
>> The patch proposes a new sysctl interface, vm.memory_failure_dirty_panic,
>> in order to prevent data corruption comes from data lost problem.
>> Also this patch displays information of affected file such as device name,
>> inode number, file offset and file type if the file is mapped on a memory
>> and the page is dirty cache.
>>
>> When SRAO machine check occurs on a dirty page cache, corresponding
>> data cannot be recovered any more. Therefore, the patch proposes a kernel
>> option to keep a system running or force system panic in order
>> to avoid further trouble such as data corruption problem of application.
>>
>> System administrator can select an error action using this option
>> according to characteristics of target system.
> 
> Can we do this in userspace?
> mcelog can trigger scripts when a MCE which matches the user-configurable
> conditions happens, so I think that we can trigger a kernel panic by
> chekcing kernel messages from the triggered script.
> For that purpose, I recently fixed the dirty/clean messaging in commit
> ff604cf6d4 "mm: hwpoison: fix action_result() to print out dirty/clean".

Hi Horiguchi-san,

Thank you for your comment.
I know mcelog has error trigger scripts such as page-error-trigger.

However, if userspace process triggers a kernel panic, I am afraid that
the following case is not handled.

- Several SRAO memory errors occur at the same time.
- Then, some of memory errors are related to mcelog and the others are
  related to dirty cache.

In my understanding, mcelog process is killed if memory error is related
to mcelog process and mcelog can not cause a kernel panic in this case.


>> Use Case
>> ---------
>> This option is intended to be adopted in KVM guest because it is
>> supposed that Linux on KVM guest operates customers business and
>> it is big impact to lost or corrupt customers data by memory failure.
>>
>> On the other hand, this option does not recommend to apply KVM host
>> as following reasons.
>>
>> - Making KVM host panic has a big impact because all virtual guests are
>>   affected by their host panic. Affected virtual guests are forced to stop
>>   and have to be restarted on the other hypervisor.
> 
> In this reasoning, you seem to assume that important data (business data)
> are only handled on guest OS. That's true in most cases, but not always.
> I think that the more general approach for this use case is that
> we trigger kernel panic if memory errors happened on dirty pagecaches
> used by 'important' processes (for example by adding process flags
> controlled by prctl(),) and set it on qemu processes.
> 
>> - If disk cached model of qemu is set to "none", I/O type of virtual
>>   guests becomes O_DIRECT and KVM host does not cache guest's disk I/O.
>>   Therefore, if SRAO machine check is reported on a dirty page cache
>>   in KVM host, its virtual machines are not affected by the machine check.
>>   So the host is expected to keep operating instead of kernel panic.
> 
> What to do if there're multiple guests, and some have "none" cache and
> others have other types?
> I think that we need more flexible settings for this use case.

OK. If I find another helpful use case, I would propose it.


>>
>> Past discussion
>> --------------------
>> This problem was previously discussed in the kernel community, 
>> (refer: mail threads pertaining to
>> http://marc.info/?l=linux-kernel&m=135187403804934&w=4). 
>>
>>>> - I worry that if a hardware error occurs, it might affect a large
>>>>   amount of memory all at the same time.  For example, if a 4G memory
>>>>   block goes bad, this message will be printed a million times?
>>
>> As Andrew mentioned in the above threads, if 4GB memory blocks goes bad,
>> error messages will be printed a million times and this behavior loses
>> a system reliability.
> 
> Maybe "4G memory block goes bad" is not a MCE SRAO but a MCE with higher
> severity, so we have no choice but to make kernel panic.

Yes. I agree with your opinion.

Regards,
Mitsuhiro Tanino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
