Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 385186B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 10:32:06 -0500 (EST)
Received: by mail-vc0-f180.google.com with SMTP id ks9so530160vcb.25
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 07:32:06 -0800 (PST)
Received: from mail-ve0-x229.google.com (mail-ve0-x229.google.com [2607:f8b0:400c:c01::229])
        by mx.google.com with ESMTPS id yv5si204071veb.140.2014.02.19.07.31.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 07:31:58 -0800 (PST)
Received: by mail-ve0-f169.google.com with SMTP id oy12so544920veb.28
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 07:31:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140218225548.GI31892@mtj.dyndns.org>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
	<20140218225548.GI31892@mtj.dyndns.org>
Date: Wed, 19 Feb 2014 07:31:57 -0800
Message-ID: <CAGAzgso+TGOgj+N=yOgQXxYuuJQmug9DyfJ_djDw0Zj_LY0L0Q@mail.gmail.com>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
From: "dbasehore ." <dbasehore@chromium.org>
Content-Type: multipart/alternative; boundary=bcaec548a73bdd5e2f04f2c416d9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: bleung@chromium.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zento.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, sonnyrao@chromium.org, Andrew Morton <akpm@linux-foundation.org>, semenzato@chromium.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org

--bcaec548a73bdd5e2f04f2c416d9
Content-Type: text/plain; charset=UTF-8

On Feb 18, 2014 4:55 PM, "Tejun Heo" <tj@kernel.org> wrote:
>
> Hello,
>
> On Fri, Feb 14, 2014 at 08:12:17PM -0800, Derek Basehore wrote:
> > bdi_wakeup_thread_delayed used the mod_delayed_work function to
schedule work
> > to writeback dirty inodes. The problem with this is that it can delay
work that
> > is scheduled for immediate execution, such as the work from
sync_inodes_sb.
> > This can happen since mod_delayed_work can now steal work from a
work_queue.
> > This fixes the problem by using queue_delayed_work instead. This is a
> > regression from the move to the bdi workqueue design.
> >
> > The reason that this causes a problem is that laptop-mode will change
the
> > delay, dirty_writeback_centisecs, to 60000 (10 minutes) by default. In
the case
> > that bdi_wakeup_thread_delayed races with sync_inodes_sb, sync will be
stopped
> > for 10 minutes and trigger a hung task. Even if
dirty_writeback_centisecs is
> > not long enough to cause a hung task, we still don't want to delay sync
for
> > that long.
>
> Oops.
>
> > For the same reason, this also changes bdi_writeback_workfn to
immediately
> > queue the work again in the case that the work_list is not empty. The
same
> > problem can happen if the sync work is run on the rescue worker.
> >
> > Signed-off-by: Derek Basehore <dbasehore@chromium.org>
> > ---
> >  fs/fs-writeback.c | 5 +++--
> >  mm/backing-dev.c  | 2 +-
> >  2 files changed, 4 insertions(+), 3 deletions(-)
> >
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index e0259a1..95b7b8c 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -1047,8 +1047,9 @@ void bdi_writeback_workfn(struct work_struct
*work)
> >               trace_writeback_pages_written(pages_written);
> >       }
> >
> > -     if (!list_empty(&bdi->work_list) ||
> > -         (wb_has_dirty_io(wb) && dirty_writeback_interval))
> > +     if (!list_empty(&bdi->work_list))
> > +             mod_delayed_work(bdi_wq, &wb->dwork, 0);
> > +     else if (wb_has_dirty_io(wb) && dirty_writeback_interval)
> >               queue_delayed_work(bdi_wq, &wb->dwork,
> >                       msecs_to_jiffies(dirty_writeback_interval * 10));
>
> Can you please add some comments explaining why the specific variants
> are being used here?

Will do this weekend. I'm away from my computer until then.

>
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index ce682f7..3fde024 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -294,7 +294,7 @@ void bdi_wakeup_thread_delayed(struct
backing_dev_info *bdi)
> >       unsigned long timeout;
> >
> >       timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
> > -     mod_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
> > +     queue_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
>
> and here?
>
> Hmmm.... but doesn't this create an opposite problem?  Now a flush
> queued for an earlier time may be overridden by something scheduled
> later, no?
>
> Thanks.
>
> --
> tejun

--bcaec548a73bdd5e2f04f2c416d9
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Feb 18, 2014 4:55 PM, &quot;Tejun Heo&quot; &lt;<a href=3D"mailto:tj@ker=
nel.org">tj@kernel.org</a>&gt; wrote:<br>
&gt;<br>
&gt; Hello,<br>
&gt;<br>
&gt; On Fri, Feb 14, 2014 at 08:12:17PM -0800, Derek Basehore wrote:<br>
&gt; &gt; bdi_wakeup_thread_delayed used the mod_delayed_work function to s=
chedule work<br>
&gt; &gt; to writeback dirty inodes. The problem with this is that it can d=
elay work that<br>
&gt; &gt; is scheduled for immediate execution, such as the work from sync_=
inodes_sb.<br>
&gt; &gt; This can happen since mod_delayed_work can now steal work from a =
work_queue.<br>
&gt; &gt; This fixes the problem by using queue_delayed_work instead. This =
is a<br>
&gt; &gt; regression from the move to the bdi workqueue design.<br>
&gt; &gt;<br>
&gt; &gt; The reason that this causes a problem is that laptop-mode will ch=
ange the<br>
&gt; &gt; delay, dirty_writeback_centisecs, to 60000 (10 minutes) by defaul=
t. In the case<br>
&gt; &gt; that bdi_wakeup_thread_delayed races with sync_inodes_sb, sync wi=
ll be stopped<br>
&gt; &gt; for 10 minutes and trigger a hung task. Even if dirty_writeback_c=
entisecs is<br>
&gt; &gt; not long enough to cause a hung task, we still don&#39;t want to =
delay sync for<br>
&gt; &gt; that long.<br>
&gt;<br>
&gt; Oops.<br>
&gt;<br>
&gt; &gt; For the same reason, this also changes bdi_writeback_workfn to im=
mediately<br>
&gt; &gt; queue the work again in the case that the work_list is not empty.=
 The same<br>
&gt; &gt; problem can happen if the sync work is run on the rescue worker.<=
br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Derek Basehore &lt;<a href=3D"mailto:dbasehore@chr=
omium.org">dbasehore@chromium.org</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt; =C2=A0fs/fs-writeback.c | 5 +++--<br>
&gt; &gt; =C2=A0mm/backing-dev.c =C2=A0| 2 +-<br>
&gt; &gt; =C2=A02 files changed, 4 insertions(+), 3 deletions(-)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c<br>
&gt; &gt; index e0259a1..95b7b8c 100644<br>
&gt; &gt; --- a/fs/fs-writeback.c<br>
&gt; &gt; +++ b/fs/fs-writeback.c<br>
&gt; &gt; @@ -1047,8 +1047,9 @@ void bdi_writeback_workfn(struct work_struc=
t *work)<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 trace_writeback_=
pages_written(pages_written);<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 }<br>
&gt; &gt;<br>
&gt; &gt; - =C2=A0 =C2=A0 if (!list_empty(&amp;bdi-&gt;work_list) ||<br>
&gt; &gt; - =C2=A0 =C2=A0 =C2=A0 =C2=A0 (wb_has_dirty_io(wb) &amp;&amp; dir=
ty_writeback_interval))<br>
&gt; &gt; + =C2=A0 =C2=A0 if (!list_empty(&amp;bdi-&gt;work_list))<br>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mod_delayed_work(bdi_=
wq, &amp;wb-&gt;dwork, 0);<br>
&gt; &gt; + =C2=A0 =C2=A0 else if (wb_has_dirty_io(wb) &amp;&amp; dirty_wri=
teback_interval)<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 queue_delayed_wo=
rk(bdi_wq, &amp;wb-&gt;dwork,<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 msecs_to_jiffies(dirty_writeback_interval * 10));<br>
&gt;<br>
&gt; Can you please add some comments explaining why the specific variants<=
br>
&gt; are being used here?</p>
<p dir=3D"ltr">Will do this weekend. I&#39;m away from my computer until th=
en.</p>
<p dir=3D"ltr">&gt;<br>
&gt; &gt; diff --git a/mm/backing-dev.c b/mm/backing-dev.c<br>
&gt; &gt; index ce682f7..3fde024 100644<br>
&gt; &gt; --- a/mm/backing-dev.c<br>
&gt; &gt; +++ b/mm/backing-dev.c<br>
&gt; &gt; @@ -294,7 +294,7 @@ void bdi_wakeup_thread_delayed(struct backing=
_dev_info *bdi)<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 unsigned long timeout;<br>
&gt; &gt;<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 timeout =3D msecs_to_jiffies(dirty_writeback=
_interval * 10);<br>
&gt; &gt; - =C2=A0 =C2=A0 mod_delayed_work(bdi_wq, &amp;bdi-&gt;wb.dwork, t=
imeout);<br>
&gt; &gt; + =C2=A0 =C2=A0 queue_delayed_work(bdi_wq, &amp;bdi-&gt;wb.dwork,=
 timeout);<br>
&gt;<br>
&gt; and here?<br>
&gt;<br>
&gt; Hmmm.... but doesn&#39;t this create an opposite problem? =C2=A0Now a =
flush<br>
&gt; queued for an earlier time may be overridden by something scheduled<br=
>
&gt; later, no?<br>
&gt;<br>
&gt; Thanks.<br>
&gt;<br>
&gt; --<br>
&gt; tejun<br>
</p>

--bcaec548a73bdd5e2f04f2c416d9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
