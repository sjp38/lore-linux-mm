Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 02DC16B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 07:06:40 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o200so5812523itg.19
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:06:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e129sor706225ita.113.2017.09.26.04.06.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 04:06:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170926102532.culqxb45xwzafomj@dhcp22.suse.cz>
References: <1505861015-11919-1-git-send-email-laoar.shao@gmail.com> <20170926102532.culqxb45xwzafomj@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 26 Sep 2017 19:06:37 +0800
Message-ID: <CALOAHbAbFedJ-h+QUWeeoAnpeEfpYe2T1GutFb56kBeL=2jN0A@mail.gmail.com>
Subject: Re: [PATCH v3] mm: introduce validity check on vm dirtiness settings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jan Kara <jack@suse.cz>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, Theodore Ts'o <tytso@mit.edu>, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2017-09-26 18:25 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 20-09-17 06:43:35, Yafang Shao wrote:
>> we can find the logic in domain_dirty_limits() that
>> when dirty bg_thresh is bigger than dirty thresh,
>> bg_thresh will be set as thresh * 1 / 2.
>>       if (bg_thresh >= thresh)
>>               bg_thresh = thresh / 2;
>>
>> But actually we can set vm background dirtiness bigger than
>> vm dirtiness successfully. This behavior may mislead us.
>> We'd better do this validity check at the beginning.
>
> This is an admin only interface. You can screw setting this up even
> when you keep consistency between the background and direct limits. In
> general we do not try to be clever for these knobs because we _expect_
> admins to do sane things. Why is this any different and why do we need
> to add quite some code to handle one particular corner case?
>

Of course we expect admins to do the sane things, but not all admins
are expert or faimilar with linux kernel source code.
If we have to read the source code to know what is the right thing to
do, I don't think this is a good interface, even for the admin.
Anyway, there's no document on that direct limits should not less than
background limits.


> To be honest I am not entirely sure this is worth the code and the
> future maintenance burden.
I'm not sure if this code is a burden for the future maintenance, but
I think that if we don't introduce this code it is a burden to the
admins.
BTW, the newest code is [patch v4].


>
>> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>> ---
>>  Documentation/sysctl/vm.txt |  6 +++
>>  mm/page-writeback.c         | 92 +++++++++++++++++++++++++++++++++++++++++----
>>  2 files changed, 90 insertions(+), 8 deletions(-)
>>
>> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
>> index 9baf66a..0bab85d 100644
>> --- a/Documentation/sysctl/vm.txt
>> +++ b/Documentation/sysctl/vm.txt
>> @@ -156,6 +156,9 @@ read.
>>  Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
>>  value lower than this limit will be ignored and the old configuration will be
>>  retained.
>> +Note: the value of dirty_bytes also cannot be set lower than
>> +dirty_background_bytes or the amount of memory corresponding to
>> +dirty_background_ratio.
>>
>>  ==============================================================
>>
>> @@ -176,6 +179,9 @@ generating disk writes will itself start writing out dirty data.
>>
>>  The total available memory is not equal to total system memory.
>>
>> +Note: dirty_ratio cannot be set lower than dirty_background_ratio or
>> +ratio corresponding to dirty_background_bytes.
>> +
>>  ==============================================================
>>
>>  dirty_writeback_centisecs
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 0b9c5cb..fadb1d7 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -511,15 +511,71 @@ bool node_dirty_ok(struct pglist_data *pgdat)
>>       return nr_pages <= limit;
>>  }
>>
>> +static bool vm_dirty_settings_valid(void)
>> +{
>> +     bool ret = true;
>> +     unsigned long bytes;
>> +
>> +     if (vm_dirty_ratio > 0) {
>> +             if (dirty_background_ratio >= vm_dirty_ratio) {
>> +                     ret = false;
>> +                     goto out;
>> +             }
>> +
>> +             bytes = global_dirtyable_memory() * PAGE_SIZE / 100 *
>> +                             vm_dirty_ratio;
>> +             if (dirty_background_bytes >= bytes) {
>> +                     ret = false;
>> +                     goto out;
>> +             }
>> +     }
>> +
>> +     if (vm_dirty_bytes > 0) {
>> +             if (dirty_background_bytes >= vm_dirty_bytes) {
>> +                     ret = false;
>> +                     goto out;
>> +             }
>> +
>> +             bytes = global_dirtyable_memory() * PAGE_SIZE / 100 *
>> +                             dirty_background_ratio;
>> +
>> +             if (bytes >= vm_dirty_bytes) {
>> +                     ret = false;
>> +                     goto out;
>> +             }
>> +     }
>> +
>> +     if ((vm_dirty_bytes == 0 && vm_dirty_ratio == 0) ||
>> +             (dirty_background_bytes == 0 && dirty_background_ratio == 0))
>> +             ret = false;
>> +
>> +out:
>> +     return ret;
>> +}
>> +
>>  int dirty_background_ratio_handler(struct ctl_table *table, int write,
>>               void __user *buffer, size_t *lenp,
>>               loff_t *ppos)
>>  {
>>       int ret;
>> +     int old_ratio = dirty_background_ratio;
>>
>>       ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
>> -     if (ret == 0 && write)
>> -             dirty_background_bytes = 0;
>> +
>> +     /* When dirty_background_ratio is 0 and dirty_background_bytes isn't 0,
>> +      * it's not correct to set dirty_background_bytes to 0 if we reset
>> +      * dirty_background_ratio to 0.
>> +      * So do nothing if the new ratio is not different.
>> +      */
>> +     if (ret == 0 && write && dirty_background_ratio != old_ratio) {
>> +             if (vm_dirty_settings_valid())
>> +                     dirty_background_bytes = 0;
>> +             else {
>> +                     dirty_background_ratio = old_ratio;
>> +                     ret = -EINVAL;
>> +             }
>> +     }
>> +
>>       return ret;
>>  }
>>
>> @@ -528,10 +584,20 @@ int dirty_background_bytes_handler(struct ctl_table *table, int write,
>>               loff_t *ppos)
>>  {
>>       int ret;
>> +     unsigned long old_bytes = dirty_background_bytes;
>>
>>       ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
>> -     if (ret == 0 && write)
>> -             dirty_background_ratio = 0;
>> +
>> +     /* the reson is same as above */
>> +     if (ret == 0 && write && dirty_background_bytes != old_bytes) {
>> +             if (vm_dirty_settings_valid())
>> +                     dirty_background_ratio = 0;
>> +             else {
>> +                     dirty_background_bytes = old_bytes;
>> +                     ret = -EINVAL;
>> +             }
>> +     }
>> +
>>       return ret;
>>  }
>>
>> @@ -544,8 +610,13 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
>>
>>       ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
>>       if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
>> -             writeback_set_ratelimit();
>> -             vm_dirty_bytes = 0;
>> +             if (vm_dirty_settings_valid()) {
>> +                     writeback_set_ratelimit();
>> +                     vm_dirty_bytes = 0;
>> +             } else {
>> +                     vm_dirty_ratio = old_ratio;
>> +                     ret = -EINVAL;
>> +             }
>>       }
>>       return ret;
>>  }
>> @@ -559,8 +630,13 @@ int dirty_bytes_handler(struct ctl_table *table, int write,
>>
>>       ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
>>       if (ret == 0 && write && vm_dirty_bytes != old_bytes) {
>> -             writeback_set_ratelimit();
>> -             vm_dirty_ratio = 0;
>> +             if (vm_dirty_settings_valid()) {
>> +                     writeback_set_ratelimit();
>> +                     vm_dirty_ratio = 0;
>> +             } else {
>> +                     vm_dirty_bytes = old_bytes;
>> +                     ret = -EINVAL;
>> +             }
>>       }
>>       return ret;
>>  }
>> --
>> 1.8.3.1
>>
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
