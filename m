Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 16DA16B0098
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 18:50:47 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so1033895wgg.8
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:50:47 -0800 (PST)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id fk8si1093509wib.80.2014.02.25.15.50.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 15:50:46 -0800 (PST)
Received: by mail-we0-f172.google.com with SMTP id u56so1056044wes.17
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:50:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5E6DB7F9-41E0-4DCC-A14B-49E2F4134A1C@suse.de>
References: <1393284484-27637-1-git-send-email-agraf@suse.de>
 <20140225171528.GJ4407@cmpxchg.org> <20140225171940.GS6835@laptop.programming.kicks-ass.net>
 <5E6DB7F9-41E0-4DCC-A14B-49E2F4134A1C@suse.de>
From: Kay Sievers <kay@vrfy.org>
Date: Wed, 26 Feb 2014 00:50:24 +0100
Message-ID: <CAPXgP10dB6a9BkgZNjPwHSRChfXfSAjhkpzjWwqYwGa+8JwgaQ@mail.gmail.com>
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Feb 26, 2014 at 12:16 AM, Alexander Graf <agraf@suse.de> wrote:
>
>
>>> Am 26.02.2014 um 01:19 schrieb Peter Zijlstra <peterz@infradead.org>:
>>>
>>>> On Tue, Feb 25, 2014 at 12:15:28PM -0500, Johannes Weiner wrote:
>>>> On Tue, Feb 25, 2014 at 12:28:04AM +0100, Alexander Graf wrote:
>>>> Configuration of tunables and Linux virtual memory settings has traditionally
>>>> happened via sysctl. Thanks to that there are well established ways to make
>>>> sysctl configuration bits persistent (sysctl.conf).
>>>>
>>>> KSM introduced a sysfs based configuration path which is not covered by user
>>>> space persistent configuration frameworks.
>>>>
>>>> In order to make life easy for sysadmins, this patch adds all access to all
>>>> KSM tunables via sysctl as well. That way sysctl.conf works for KSM as well,
>>>> giving us a streamlined way to make KSM configuration persistent.
>>>>
>>>> Reported-by: Sasche Peilicke <speilicke@suse.com>
>>>> Signed-off-by: Alexander Graf <agraf@suse.de>
>>>> ---
>>>> kernel/sysctl.c |   10 +++++++
>>>> mm/ksm.c        |   78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>>> 2 files changed, 88 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>>>> index 332cefc..2169a00 100644
>>>> --- a/kernel/sysctl.c
>>>> +++ b/kernel/sysctl.c
>>>> @@ -217,6 +217,9 @@ extern struct ctl_table random_table[];
>>>> #ifdef CONFIG_EPOLL
>>>> extern struct ctl_table epoll_table[];
>>>> #endif
>>>> +#ifdef CONFIG_KSM
>>>> +extern struct ctl_table ksm_table[];
>>>> +#endif
>>>>
>>>> #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
>>>> int sysctl_legacy_va_layout;
>>>> @@ -1279,6 +1282,13 @@ static struct ctl_table vm_table[] = {
>>>>   },
>>>>
>>>> #endif /* CONFIG_COMPACTION */
>>>> +#ifdef CONFIG_KSM
>>>> +    {
>>>> +        .procname    = "ksm",
>>>> +        .mode        = 0555,
>>>> +        .child        = ksm_table,
>>>> +    },
>>>> +#endif
>>>
>>> ksm can be a module, so this won't work.
>>>
>>> Can we make those controls proper module parameters instead?
>>
>> You can do dynamic sysctl registration and removal. Its its own little
>> filesystem of sorts.
>
> Hm. Doesn't this open another big can of worms? If we have ksm as a module and our sysctl helpers try to enable ksm on boot, they may not be able to because the module hasn't been loaded yet.
>
> So in that case, we want to always register the sysctl and dynamically load the ksm module when the sysctl gets accessed - similar to how we can do stub devices that load modiles, no?

The files sysctl tries to write to at bootup need to be all there
right from the start, otherwise there can't be anything to access, and
no way to trigger any module load.

The auto-load stuff in /dev works by userspace creating dead device
nodes with the proper dev_t before the device exists, which is a very
different model.

sysctl is not suitable for any instantiated or conditional data like
loadable module, devices, ... Things need to be there right from the
start, later registered facilities will not be noticed by sysctl in
userspace and are therefore not hooked into system management. If any
values should be applied from userspace, this will not really work
out.

There a network devices configs doing that today, and they don't
really work that well; it's a gigantic stupid hack in userspace to
fiddle with /proc/sys/ when a netdev shows up, no model to copy to any
new facility.

Usually, loadable module parameter need to live in /sys/module/ or
/sys/bus/, where uevents are generated and udev can pick up the event
and apply system configuration.

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
