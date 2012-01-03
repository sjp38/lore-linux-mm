Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 7886D6B004D
	for <linux-mm@kvack.org>; Mon,  2 Jan 2012 22:47:25 -0500 (EST)
From: "'Chanho Min'" <chanho.min@lge.com>
Subject: RE: [PATCH] mm/backing-dev.c: fix crash when USB/SCSI device is detached
Date: Tue, 3 Jan 2012 12:47:23 +0900
Message-ID: <003001ccc9ca$66dbf650$3493e2f0$@min@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Wu Fengguang' <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Jens Axboe' <axboe@kernel.dk>, 'Andrew Morton' <akpm@linux-foundation.org>

>On Mon, Jan 02, 2012 at 06:38:21PM +0900,     =C8=A3 wrote:
>> from Chanho Min <chanho.min@lge.com>
>>
>> System may crash in backing-dev.c when removal SCSI device is =
detached.
>> bdi task is killed by bdi_unregister()/'khubd', but task's point =
remains.
>> Shortly afterward, If 'wb->wakeup_timer' is expired before=20
>> del_timer()/bdi_forker_thread,
>> wakeup_timer_fn() may wake up the dead thread which cause the crash.
>> 'bdi->wb.task' should be NULL as this patch.
>
>Is it some race condition between del_timer() and del_timer_sync()?
>
>bdi_unregister() calls
>
>        del_timer_sync
>        bdi_wb_shutdown
>            kthread_stop
>
>in turn, and del_timer_sync() should guarantee wakeup_timer_fn() is no=20
>longer called to access the stopped task.
>

It is not race condition. This happens when USB is removed during =
write-access.
bdi_wakeup_thread_delayed is called after kthread_stop, and timer is =
activated again.

	bdi_unregister
		kthread_stop
	bdi_wakeup_thread_delayed (sys_write mostly calls this)
	timer fires

Anyway,Is this safeguard to prevent from waking up killed thread?

Thanks,
Chanho

>Thanks,
>Fengguang
>
>
>> Signed-off-by: Chanho Min <chanho.min@lge.com>
>> ---
>>  mm/backing-dev.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/backing-dev.c b/mm/backing-dev.c index=20
>> 71034f4..4378a5e 100644
>> --- a/mm/backing-dev.c
>> +++ b/mm/backing-dev.c
>> @@ -607,6 +607,7 @@ static void bdi_wb_shutdown(struct=20
>> backing_dev_info
>> *bdi)
>>         if (bdi->wb.task) {
>>                 thaw_process(bdi->wb.task);
>>                 kthread_stop(bdi->wb.task);
>> +               bdi->wb.task =3D NULL;
>>         }
>>  }
>>
>> --
>> 1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
