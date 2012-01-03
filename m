From: "Chanho Min" <chanho.min@lge.com>
Subject: RE: [PATCH] mm/backing-dev.c: fix crash when USB/SCSI device is detached
Date: Tue, 3 Jan 2012 20:22:50 +0900
Message-ID: <9980.1323297017$1325589822@news.gmane.org>
References: <004401ccc932$444a0070$ccde0150$@min@lge.com> <20120102095711.GA16570@localhost> <002e01ccc9c7$1928c940$4b7a5bc0$@min@lge.com> <20120103044933.GA31778@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Ri2Su-0002El-9S
	for glkm-linux-mm-2@m.gmane.org; Tue, 03 Jan 2012 12:23:36 +0100
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 8A69A6B006E
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 06:23:22 -0500 (EST)
In-Reply-To: <20120103044933.GA31778@localhost>
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Wu Fengguang' <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Jens Axboe' <axboe@kernel.dk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Rabin Vincent' <rabin.vincent@stericsson.com>, 'Linus Walleij' <linus.walleij@linaro.org>

>On Tue, Jan 03, 2012 at 12:23:44PM +0900, Chanho Min wrote:
>> >On Mon, Jan 02, 2012 at 06:38:21PM +0900, =
=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=C8=A3 wrote:
>> >> from Chanho Min <chanho.min@lge.com>
>> >>
>> >> System may crash in backing-dev.c when removal SCSI device is =
detached.
>> >> bdi task is killed by bdi_unregister()/'khubd', but task's point
>remains.
>> >> Shortly afterward, If 'wb->wakeup_timer' is expired before
>> >> del_timer()/bdi_forker_thread,
>> >> wakeup_timer_fn() may wake up the dead thread which cause the =
crash.
>> >> 'bdi->wb.task' should be NULL as this patch.
>> >
>> >Is it some race condition between del_timer() and del_timer_sync()?
>> >
>> >bdi_unregister() calls
>> >
>> >        del_timer_sync
>> >        bdi_wb_shutdown
>> >            kthread_stop
>> >
>> >in turn, and del_timer_sync() should guarantee wakeup_timer_fn() is
>> >no longer called to access the stopped task.
>> >
>>
>> It is not race condition. This happens when USB is removed during =
write-
>access.
>> bdi_wakeup_thread_delayed is called after kthread_stop, and timer is
>activated again.
>>
>> 	bdi_unregister
>> 		kthread_stop
>> 	bdi_wakeup_thread_delayed (sys_write mostly calls this)
>> 	timer fires
>
>Ah OK, the timer could be restarted in the mean while, which breaks
>the synchronization rule in del_timer_sync().
>
>I noticed a related fix is merged recently, does your test kernel
>contain this commit?
>

No, I will try to reproduce with this patch.=20
But, bdi_destroy is not called during write-access. Same result is =
expected.

>commit 7a401a972df8e184b3d1a3fc958c0a4ddee8d312
>Author: Rabin Vincent <rabin.vincent@stericsson.com>
>Date:   Fri Nov 11 13:29:04 2011 +0100
>
>    backing-dev: ensure wakeup_timer is deleted
>
>> Anyway,Is this safeguard to prevent from waking up killed thread?
>
>This patch makes no guarantee wakeup_timer_fn() will see NULL
>bdi->wb.task before the task is stopped, so there is still race
>conditions. And still, the complete fix would be to prevent
>wakeup_timer_fn() from being called at all.

If wakeup_timer_fn() see NULL bdi->wb.task, wakeup_timer_fn regards task =
as killed
and wake up forker thread instead of the defined thread.
Is this intended behavior of the bdi?

>
>Thanks,
>Fengguang
>
>> >> Signed-off-by: Chanho Min <chanho.min@lge.com>
>> >> ---
>> >>  mm/backing-dev.c |    1 +
>> >>  1 files changed, 1 insertions(+), 0 deletions(-)
>> >>
>> >> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
>> >> index 71034f4..4378a5e 100644
>> >> --- a/mm/backing-dev.c
>> >> +++ b/mm/backing-dev.c
>> >> @@ -607,6 +607,7 @@ static void bdi_wb_shutdown(struct =
backing_dev_info
>> >> *bdi)
>> >>         if (bdi->wb.task) {
>> >>                 thaw_process(bdi->wb.task);
>> >>                 kthread_stop(bdi->wb.task);
>> >> +               bdi->wb.task =3D NULL;
>> >>         }
>> >>  }
>> >>
>> >> --
>> >> 1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
