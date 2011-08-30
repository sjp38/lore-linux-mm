Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 13A97900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 14:13:53 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p7UIDpth023208
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 11:13:52 -0700
Received: from qwh5 (qwh5.prod.google.com [10.241.194.197])
	by wpaz17.hot.corp.google.com with ESMTP id p7UICoQR011909
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 11:13:50 -0700
Received: by qwh5 with SMTP id 5so5283887qwh.34
        for <linux-mm@kvack.org>; Tue, 30 Aug 2011 11:13:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110829163645.GG5672@quack.suse.cz>
References: <1314038327-22645-1-git-send-email-curtw@google.com>
	<1314038327-22645-3-git-send-email-curtw@google.com>
	<20110829163645.GG5672@quack.suse.cz>
Date: Tue, 30 Aug 2011 11:13:50 -0700
Message-ID: <CAO81RMbyXvz214mTvjEg3NBpJ01JUw8+Goux4NoWZrZ_RCzLrA@mail.gmail.com>
Subject: Re: [PATCH 3/3 v3] writeback: Add writeback stats for pages written
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi Jan:

On Mon, Aug 29, 2011 at 9:36 AM, Jan Kara <jack@suse.cz> wrote:
> On Mon 22-08-11 11:38:47, Curt Wohlgemuth wrote:
>> Add a new file, /proc/writeback, which displays
>> machine global data for how many pages were cleaned for
>> which reasons.
> =A0I'm not sure about the placement in /proc/writeback - maybe I'd be
> happier if it was somewhere under /sys/kernel/debug but I don't really ha=
ve
> a better suggestion and I don't care that much either. Maybe Christoph or
> Andrew have some idea?

I'm open to suggestions...

> ...
>> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
>> index bdda069..5168ac9 100644
>> --- a/include/linux/writeback.h
>> +++ b/include/linux/writeback.h
>> @@ -59,6 +59,7 @@ enum wb_reason {
>> =A0 =A0 =A0 WB_REASON_TRY_TO_FREE_PAGES,
>> =A0 =A0 =A0 WB_REASON_SYNC,
>> =A0 =A0 =A0 WB_REASON_PERIODIC,
>> + =A0 =A0 WB_REASON_FDATAWRITE,
>> =A0 =A0 =A0 WB_REASON_LAPTOP_TIMER,
>> =A0 =A0 =A0 WB_REASON_FREE_MORE_MEM,
>> =A0 =A0 =A0 WB_REASON_FS_FREE_SPACE,
>> @@ -67,6 +68,7 @@ enum wb_reason {
>> =A0 =A0 =A0 WB_REASON_MAX,
>> =A0};
>>
>> +
> =A0The additional empty line doesn't make much sense here?

Sigh.  Yes, I do like whitespace, but not usually this much; I'll fix them =
all.

>> =A0/*
>> =A0 * A control structure which tells the writeback code what to do. =A0=
These are
>> =A0 * always on the stack, and hence need no locking. =A0They are always=
 initialised
>> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
>> index 474bcfe..6613391 100644
>> --- a/mm/backing-dev.c
>> +++ b/mm/backing-dev.c
> ...
>> @@ -56,9 +60,77 @@ void bdi_lock_two(struct bdi_writeback *wb1, struct b=
di_writeback *wb2)
>> =A0 =A0 =A0 }
>> =A0}
>>
>> +
> =A0And another empty line here?
>
>> +static const char *wb_stats_labels[WB_REASON_MAX] =3D {
>> + =A0 =A0 [WB_REASON_BALANCE_DIRTY] =3D "page: balance_dirty_pages",
>> + =A0 =A0 [WB_REASON_BACKGROUND] =3D "page: background_writeout",
>> + =A0 =A0 [WB_REASON_TRY_TO_FREE_PAGES] =3D "page: try_to_free_pages",
>> + =A0 =A0 [WB_REASON_SYNC] =3D "page: sync",
>> + =A0 =A0 [WB_REASON_PERIODIC] =3D "page: periodic",
>> + =A0 =A0 [WB_REASON_FDATAWRITE] =3D "page: fdatawrite",
>> + =A0 =A0 [WB_REASON_LAPTOP_TIMER] =3D "page: laptop_periodic",
>> + =A0 =A0 [WB_REASON_FREE_MORE_MEM] =3D "page: free_more_memory",
>> + =A0 =A0 [WB_REASON_FS_FREE_SPACE] =3D "page: fs_free_space",
>> +};
> =A0I don't think it's good to have two enum->string translation tables fo=
r
> reasons. That's prone to errors which is in fact proven by the fact that
> you ommitted FORKER_THREAD reason here.

Ah, thanks for catching the omitted reason.  I assume you mean the
table above, and

   +#define show_work_reason(reason)

from the patch 2/3 (in the trace events file).  Hmm, that could be a
challenge, given the limitations on what you can do in trace macros.
I'll think on this though.

Thanks,
Curt

>
>> @@ -157,6 +248,7 @@ static inline void bdi_debug_unregister(struct backi=
ng_dev_info *bdi)
>> =A0}
>> =A0#endif
>>
>> +
> =A0Another empty line here? You seem to like them ;)
>
>> =A0static ssize_t read_ahead_kb_store(struct device *dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct d=
evice_attribute *attr,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const ch=
ar *buf, size_t count)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honz=
a
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
