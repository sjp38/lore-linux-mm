Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id BBC616B0034
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 12:43:14 -0400 (EDT)
Message-ID: <51F00415.8070104@sr71.net>
Date: Wed, 24 Jul 2013 09:43:01 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
References: <1374261785-1615-1-git-send-email-kys@microsoft.com> <20130722123716.GB24400@dhcp22.suse.cz> <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com> <51EEA11D.4030007@intel.com> <3318be0a96cb4d05838d76dc9d088cc0@SN2PR03MB061.namprd03.prod.outlook.com> <51EEA89F.9070309@intel.com> <9f351a549e76483d9148f87535567ea0@SN2PR03MB061.namprd03.prod.outlook.com>
In-Reply-To: <9f351a549e76483d9148f87535567ea0@SN2PR03MB061.namprd03.prod.outlook.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.cz>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>

On 07/23/2013 10:21 AM, KY Srinivasan wrote:
>> You have allocated some large, physically contiguous areas of memory
>> under heavy pressure.  But you also contend that there is too much
>> memory pressure to run a small userspace helper.  Under heavy memory
>> pressure, I'd expect large, kernel allocations to fail much more often
>> than running a small userspace helper.
> 
> I am only reporting what I am seeing. Broadly, I have two main failure conditions to
> deal with: (a) resource related failure (add_memory() returning -ENOMEM) and (b) not being
> able to online a segment that has been successfully hot-added. I have seen both these failures
> under high memory pressure. By supporting "in context" onlining, we can eliminate one failure
> case. Our inability to online is not a recoverable failure from the host's point of view - the memory
> is committed to the guest (since hot add succeeded) but is not usable since it is not onlined.

Could you please precisely report on what you are seeing in detail?
Where are the -ENOMEMs coming from?  Which allocation site?  Are you
seeing OOMs or page allocation failure messages on the console?

The operation was split up in to two parts for good reason.  It's
actually for your _precise_ use case.

A system under memory pressure is going to have troubles doing a
hot-add.  You need memory to add memory.  Of the two operations ("add"
and "online"), "add" is the one vastly more likely to fail.  It has to
allocate several large swaths of contiguous physical memory.  For that
reason, the system was designed so that you could "add" and "online"
separately.  The intention was that you could "add" far in advance and
then "online" under memory pressure, with the "online" having *VASTLY*
smaller memory requirements and being much more likely to succeed.

You're lumping the "allocate several large swaths of contiguous physical
memory" failures in to the same class as "run a small userspace helper".
 They are _really_ different problems.  Both prone to allocation
failures for sure, but _very_ separate problems.  Please don't conflate
them.

>> It _sounds_ like you really want to be able to have the host retry the
>> operation if it fails, and you return success/failure from inside the
>> kernel.  It's hard for you to tell if running the userspace helper
>> failed, so your solution is to move what what previously done in
>> userspace in to the kernel so that you can more easily tell if it failed
>> or succeeded.
>>
>> Is that right?
> 
> No; I am able to get the proper error code for recoverable failures (hot add failures
> because of lack of memory). By doing what I am proposing here, we can avoid one class
> of failures completely and I think this is what resulted in a better "hot add" experience in the
> guest.

I think you're taking a huge leap here: "We could not online memory,
thus we must take userspace out of the loop."

You might be right.  There might be only one way out of this situation.
 But you need to provide a little more supporting evidence before we all
arrive at the same conclusion.

BTW, it doesn't _require_ udev.  There could easily be another listener
for hotplug events.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
