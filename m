Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A06076B0037
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 17:31:05 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so2040372pdj.24
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 14:31:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id jb8si10251349pbd.78.2014.09.12.14.31.04
        for <linux-mm@kvack.org>;
        Fri, 12 Sep 2014 14:31:04 -0700 (PDT)
Message-ID: <54136617.8070203@intel.com>
Date: Fri, 12 Sep 2014 14:31:03 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 00/10] Intel MPX support
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <54124379.5090502@intel.com> <alpine.DEB.2.10.1409121543090.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409121543090.4178@nanos>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/12/2014 12:21 PM, Thomas Gleixner wrote:
> On Thu, 11 Sep 2014, Dave Hansen wrote:
>> +When #BR fault is produced due to invalid entry, bounds table will be
>> +created in kernel on demand and kernel will not transfer this fault to
>> +userspace. So usersapce can't receive #BR fault for invalid entry, and
>> +it is not also necessary for users to create bounds tables by themselves.
>> +
>> +Certainly users can allocate bounds tables and forcibly point the bounds
>> +directory at them through XSAVE instruction, and then set valid bit
>> +of bounds entry to have this entry valid. But we have no way to track
>> +the memory usage of these user-created bounds tables. In regard to this,
>> +this behaviour is outlawed here.
> 
> So what's the point of declaring it outlawed? Nothing as far as I can
> see simply because you cannot enforce it. This is possible and people
> simply will do it.

All that we want to get across is: if the kernel didn't make the mess,
we're not going to clean it up.

Userspace is free to do whatever the heck it wants.  But, if it wants
the kernel to clean up the bounds tables, it needs to follow the rules
we're laying out here.

I think it boils down to two rules:
1. Don't move the bounds directory without telling the kernel.
2. The kernel will not free any memory which it did not allocate.

>> +2) We will not support the case that multiple bounds directory entries
>> +are pointed at the same bounds table.
>> +
>> +Users can be allowed to take multiple bounds directory entries and point
>> +them at the same bounds table. See more information "Intel(R) Architecture
>> +Instruction Set Extensions Programming Reference" (9.3.4).
>> +
>> +If userspace did this, it will be possible for kernel to unmap an in-use
>> +bounds table since it does not recognize sharing. So this behavior is
>> +also outlawed here.
> 
> Again, this is nothing you can enforce and just saying its outlawed
> does not prevent user space from doing it and then sending hard to
> decode bug reports where it complains about mappings silently
> vanishing under it.
> 
> So all you can do here is to write up a rule set how well behaving
> user space is supposed to use this facility and the kernel side of it. 

"Outlaw" was probably the wrong word.

I completely agree that all we can do is set up a set of rules for what
well-behaved userspace is expected to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
