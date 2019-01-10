Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7FC8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:21:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f31so4738509edf.17
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:21:28 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q2-v6si732782ejn.56.2019.01.10.10.21.26
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 10:21:26 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: Re: [PATCH v7 09/25] ACPI / APEI: Generalise the estatus queue's
 notify code
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-10-james.morse@arm.com>
 <20181211174449.GM27375@zn.tnic>
Message-ID: <3f0f9005-f383-8a03-c7f9-15b50c099f94@arm.com>
Date: Thu, 10 Jan 2019 18:21:21 +0000
MIME-Version: 1.0
In-Reply-To: <20181211174449.GM27375@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

Hi Boris,

On 11/12/2018 17:44, Borislav Petkov wrote:
> On Mon, Dec 03, 2018 at 06:05:57PM +0000, James Morse wrote:
>> Refactor the estatus queue's pool notification routine from
>> NOTIFY_NMI's handlers. This will allow another notification
>> method to use the estatus queue without duplicating this code.
>>
>> This patch adds rcu_read_lock()/rcu_read_unlock() around the list
> 
> s/This patch adds/Add/
> 
>> list_for_each_entry_rcu() walker. These aren't strictly necessary as
>> the whole nmi_enter/nmi_exit() window is a spooky RCU read-side
>> critical section.
>>
>> _in_nmi_notify_one() is separate from the rcu-list walker for a later
>> caller that doesn't need to walk a list.

>> +static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
>> +{
>> +	int ret = NMI_DONE;
>> +
>> +	if (!atomic_add_unless(&ghes_in_nmi, 1, 1))
>> +		return ret;
>> +
>> +	if (!ghes_estatus_queue_notified(&ghes_nmi))
>> +		ret = NMI_HANDLED;
> 
> So this reads kinda the other way around, at least to me:
> 
> 	"if the queue was *not* notified, the NMI was handled."
> 
> Maybe rename to this:
> 
> 	err = process_queue(&ghes_nmi);
> 	if (!err)
> 		ret = NMI_HANDLED;
> 
> to make it clearer...

(yup, that's clearer).

But now we've opened pandora's box of naming-things: This thing isn't really
processing anything, its walking a list of 'maybe it was one of these' and
copying anything it finds into the estatus-queue to be handled later.

I've evidently overloaded 'notified' to mean this.
__process_error() doesn't process anything either, it does the add-to-queue.

'spool' is the word that best conveys what's going on here, I should probably
use that 'in_nmi' prefix more to make it clear this has to be nmi safe.

Something like:
ghes_notify_nmi() -> in_nmi_spool_from_list(list) -> in_nmi_queue_one_entry(ghes).



Thanks,

James
