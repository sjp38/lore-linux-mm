Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E2C4F6B02D9
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 04:18:38 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o7K8IaXJ010870
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:18:36 -0700
Received: from ywi4 (ywi4.prod.google.com [10.192.9.4])
	by wpaz17.hot.corp.google.com with ESMTP id o7K8IZfD022301
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:18:35 -0700
Received: by ywi4 with SMTP id 4so1206753ywi.17
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:18:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100820031647.GC5502@localhost>
References: <1282251447-16937-1-git-send-email-mrubin@google.com>
 <1282251447-16937-4-git-send-email-mrubin@google.com> <20100820031647.GC5502@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Fri, 20 Aug 2010 01:18:15 -0700
Message-ID: <AANLkTik1=FRc53o9L8z6PGeA4wcLBaeBv_eLVzCUpypg@mail.gmail.com>
Subject: Re: [PATCH 3/3] writeback: Reporting dirty thresholds in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

Thank you for your quick reply and comments.

On Thu, Aug 19, 2010 at 8:16 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Thu, Aug 19, 2010 at 01:57:27PM -0700, Michael Rubin wrote:
>> The kernel already exposes the desired thresholds in /proc/sys/vm with
>> dirty_background_ratio and background_ratio. Instead the kernel may
>> alter the number requested without giving the user any indication that
>> is the case.
>
> You mean the 5% lower bound in global_dirty_limits()? Let's rip it :)
>
>> Knowing the actual ratios the kernel is honoring can help app developers
>> understand how their buffered IO will be sent to the disk.
>>
>> =A0 =A0 =A0 $ grep threshold /proc/vmstat
>> =A0 =A0 =A0 nr_pages_dirty_threshold 409111
>> =A0 =A0 =A0 nr_pages_dirty_background_threshold 818223
>
> It's redundant to have _pages in the names. /proc/vmstat has the
> tradition to use nr_dirty instead of nr_pages_dirty.
>
> They do look like useful counters to export, especially when we do
> dynamic dirty limits in future.
>
>> Signed-off-by: Michael Rubin <mrubin@google.com>
>> ---
>> =A0include/linux/mmzone.h | =A0 =A02 ++
>> =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A08 ++++++++
>> =A02 files changed, 10 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index f160481..7c4a3bf 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -114,6 +114,8 @@ enum zone_stat_item {
>> =A0#endif
>> =A0 =A0 =A0 NR_PAGES_ENTERED_WRITEBACK, /* number of times pages enter w=
riteback */
>> =A0 =A0 =A0 NR_FILE_PAGES_DIRTIED, =A0 =A0 =A0/* number of times pages g=
et dirtied */
>> + =A0 =A0 NR_PAGES_DIRTY_THRESHOLD, =A0 /* writeback threshold */
>> + =A0 =A0 NR_PAGES_DIRTY_BG_THRESHOLD,/* bg writeback threshold */
>
> s/_PAGES//

Cool. Thanks.

>
>> =A0 =A0 =A0 NR_VM_ZONE_STAT_ITEMS };
>>
>> =A0/*
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index e177a40..8b5bc78 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -17,6 +17,7 @@
>> =A0#include <linux/vmstat.h>
>> =A0#include <linux/sched.h>
>> =A0#include <linux/math64.h>
>> +#include <linux/writeback.h>
>>
>> =A0#ifdef CONFIG_VM_EVENT_COUNTERS
>> =A0DEFINE_PER_CPU(struct vm_event_state, vm_event_states) =3D {{0}};
>> @@ -742,6 +743,8 @@ static const char * const vmstat_text[] =3D {
>> =A0#endif
>> =A0 =A0 =A0 "nr_pages_entered_writeback",
>> =A0 =A0 =A0 "nr_file_pages_dirtied",
>> + =A0 =A0 "nr_pages_dirty_threshold",
>> + =A0 =A0 "nr_pages_dirty_background_threshold",
>
> s/_pages//

Got it.

>
>> =A0#ifdef CONFIG_VM_EVENT_COUNTERS
>> =A0 =A0 =A0 "pgpgin",
>> @@ -901,6 +904,7 @@ static void *vmstat_start(struct seq_file *m, loff_t=
 *pos)
>> =A0#ifdef CONFIG_VM_EVENT_COUNTERS
>> =A0 =A0 =A0 unsigned long *e;
>> =A0#endif
>> + =A0 =A0 unsigned long dirty_thresh, dirty_bg_thresh;
>> =A0 =A0 =A0 int i;
>>
>> =A0 =A0 =A0 if (*pos >=3D ARRAY_SIZE(vmstat_text))
>> @@ -918,6 +922,10 @@ static void *vmstat_start(struct seq_file *m, loff_=
t *pos)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENOMEM);
>> =A0 =A0 =A0 for (i =3D 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 v[i] =3D global_page_state(i);
>> +
>> + =A0 =A0 get_dirty_limits(&dirty_thresh, &dirty_bg_thresh, NULL, NULL);
>
> 2.6.36-rc1 will need this:
>
> =A0 =A0 =A0 =A0global_dirty_limits(v + NR_DIRTY_THRESHOLD, v + NR_DIRTY_B=
G_THRESHOLD);

Yeah I noticed when I rebased. Thanks.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
