Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 686096B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 18:42:12 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p7CMg9ws002664
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 15:42:09 -0700
Received: from qyk34 (qyk34.prod.google.com [10.241.83.162])
	by hpaq3.eem.corp.google.com with ESMTP id p7CMee8h018994
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 15:42:07 -0700
Received: by qyk34 with SMTP id 34so2019085qyk.19
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 15:42:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110812204349.GA31255@quack.suse.cz>
References: <1313174707-4267-1-git-send-email-curtw@google.com>
	<20110812204349.GA31255@quack.suse.cz>
Date: Fri, 12 Aug 2011 15:42:07 -0700
Message-ID: <CAO81RMbe6bNECR3pbecnscUZVSgBM7tLDJtovpSfESLtrFHKCA@mail.gmail.com>
Subject: Re: [PATCH 1/2] writeback: Add a 'reason' to wb_writeback_work
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi Jan:

On Fri, Aug 12, 2011 at 1:43 PM, Jan Kara <jack@suse.cz> wrote:
> On Fri 12-08-11 11:45:06, Curt Wohlgemuth wrote:
>> This creates a new 'reason' field in a wb_writeback_work
>> structure, which unambiguously identifies who initiates
>> writeback activity. =A0A 'wb_stats' enumeration has been added
>> to writeback.h, to enumerate the possible reasons.
>>
>> The 'writeback_work_class' tracepoint event class is updated
>> to include the symbolic 'reason' in all trace events.
>>
>> The 'writeback_queue_io' tracepoint now takes a work object,
>> in order to print out the 'reason' for queue_io.
>>
>> And the 'writeback_inodes_sbXXX' family of routines has had
>> a wb_stats parameter added to them, so callers can specify
>> why writeback is being started.
>>
>> Signed-off-by: Curt Wohlgemuth <curtw@google.com>
> =A0The patch looks good. Just two minor comments below. So you can
> add:
> =A0Acked-by: Jan Kara <jack@suse.cz>
>
>> @@ -647,11 +651,12 @@ long writeback_inodes_wb(struct bdi_writeback *wb,=
 long nr_pages)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_pages =A0 =A0 =A0 =3D nr_pages,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .sync_mode =A0 =A0 =A0=3D WB_SYNC_NONE,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .range_cyclic =A0 =3D 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .reason =A0 =A0 =A0 =A0 =3D WB_STAT_BALANCE_DI=
RTY,
>> =A0 =A0 =A0 };
>>
>> =A0 =A0 =A0 spin_lock(&wb->list_lock);
>> =A0 =A0 =A0 if (list_empty(&wb->b_io))
>> - =A0 =A0 =A0 =A0 =A0 =A0 queue_io(wb, NULL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 queue_io(wb, &work);
>> =A0 =A0 =A0 __writeback_inodes_wb(wb, &work);
>> =A0 =A0 =A0 spin_unlock(&wb->list_lock);
>>
> =A0Umm, for consistency it would make more sense for writeback_inodes_wb(=
)
> to take reason argument as well. Also strictly speaking, this function ha=
s
> two callers - balance_dirty_pages() and bdi_forker_thread()...

Yeah, good idea.

>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index d196074..53c995e 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -737,8 +737,9 @@ static void balance_dirty_pages(struct address_space=
 *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_balance_dirty_start(bdi);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bdi_nr_reclaimable > task_bdi_thresh) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages_written +=3D writeback_i=
nodes_wb(&bdi->wb,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0write_chunk);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long wrote;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wrote =3D writeback_inodes_wb(=
&bdi->wb, write_chunk);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages_written +=3D wrote;
> =A0What is this hunk for?

Oops.  This should have been in the "PATCH 2/2" , not this one.  v2 of
these patches are in the mail.

Thanks,
Curt

>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
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
