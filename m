Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 589A66B01C6
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 06:21:55 -0400 (EDT)
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1276797878-28893-1-git-send-email-jack@suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 18 Jun 2010 12:21:36 +0200
Message-ID: <1276856496.27822.1698.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Thu, 2010-06-17 at 20:04 +0200, Jan Kara wrote:
> +/* Wait until write_chunk is written or we get below dirty limits */
> +void bdi_wait_written(struct backing_dev_info *bdi, long write_chunk)
> +{
> +       struct bdi_written_count wc =3D {
> +                                       .list =3D LIST_HEAD_INIT(wc.list)=
,
> +                                       .written =3D write_chunk,
> +                               };
> +       DECLARE_WAITQUEUE(wait, current);
> +       int pause =3D 1;
> +
> +       bdi_add_writer(bdi, &wc, &wait);
> +       for (;;) {
> +               if (signal_pending_state(TASK_KILLABLE, current))
> +                       break;
> +
> +               /*
> +                * Make the task just killable so that tasks cannot circu=
mvent
> +                * throttling by sending themselves non-fatal signals...
> +                */
> +               __set_current_state(TASK_KILLABLE);
> +               io_schedule_timeout(pause);
> +
> +               /*
> +                * The following check is save without wb_written_wait.lo=
ck
> +                * because once bdi_remove_writer removes us from the lis=
t
> +                * noone will touch us and it's impossible for list_empty=
 check
> +                * to trigger as false positive. The barrier is there to =
avoid
> +                * missing the wakeup when we are removed from the list.
> +                */
> +               smp_rmb();
> +               if (list_empty(&wc.list))
> +                       break;
> +
> +               if (!dirty_limits_exceeded(bdi))
> +                       break;
> +
> +               /*
> +                * Increase the delay for each loop, up to our previous
> +                * default of taking a 100ms nap.
> +                */
> +               pause <<=3D 1;
> +               if (pause > HZ / 10)
> +                       pause =3D HZ / 10;
> +       }
> +
> +       spin_lock_irq(&bdi->wb_written_wait.lock);
> +       __remove_wait_queue(&bdi->wb_written_wait, &wait);
> +       if (!list_empty(&wc.list))
> +               bdi_remove_writer(bdi, &wc);
> +       spin_unlock_irq(&bdi->wb_written_wait.lock);
> +}=20

OK, so the whole pause thing is simply because we don't get a wakeup
when we drop below the limit, right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
