Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 46A928D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 18:53:26 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p2GMrLV2020161
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 15:53:21 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by kpbe17.cbf.corp.google.com with ESMTP id p2GMqENS007365
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 15:53:19 -0700
Received: by qyk7 with SMTP id 7so3695712qyk.12
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 15:53:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikshHSaqfs7_CzL3ofyAV96_NZsOw4dcNbPtnC1@mail.gmail.com>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
	<1299623475-5512-4-git-send-email-jack@suse.cz>
	<20110310000731.GE10346@redhat.com>
	<20110314204821.GC4998@quack.suse.cz>
	<20110315152310.GD24984@redhat.com>
	<AANLkTikshHSaqfs7_CzL3ofyAV96_NZsOw4dcNbPtnC1@mail.gmail.com>
Date: Wed, 16 Mar 2011 15:53:15 -0700
Message-ID: <AANLkTikMv02oQC685RhSNvKnN1bsP=KNRpWfTgnuXF9g@mail.gmail.com>
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>, jack@suse.cz
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

On Wed, Mar 16, 2011 at 2:26 PM, Curt Wohlgemuth <curtw@google.com> wrote:
> Hi Jan:
>
> On Tue, Mar 15, 2011 at 8:23 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
>> On Mon, Mar 14, 2011 at 09:48:21PM +0100, Jan Kara wrote:
>>> On Wed 09-03-11 19:07:31, Vivek Goyal wrote:
>>> > > +static void balance_dirty_pages(struct address_space *mapping,
>>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long wri=
te_chunk)
>>> > > +{
>>> > > + struct backing_dev_info *bdi =3D mapping->backing_dev_info;
>>> > > + struct balance_waiter bw;
>>> > > + struct dirty_limit_state st;
>>> > > + int dirty_exceeded =3D check_dirty_limits(bdi, &st);
>>> > > +
>>> > > + if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT ||
>>> > > + =A0 =A0 (dirty_exceeded =3D=3D DIRTY_MAY_EXCEED_LIMIT &&
>>> > > + =A0 =A0 =A0!bdi_task_limit_exceeded(&st, current))) {
>>> > > + =A0 =A0 =A0 =A0 if (bdi->dirty_exceeded &&
>>> > > + =A0 =A0 =A0 =A0 =A0 =A0 dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT)
>>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi->dirty_exceeded =3D 0;
>>> > > =A0 =A0 =A0 =A0 =A0 /*
>>> > > - =A0 =A0 =A0 =A0 =A0* Increase the delay for each loop, up to our =
previous
>>> > > - =A0 =A0 =A0 =A0 =A0* default of taking a 100ms nap.
>>> > > + =A0 =A0 =A0 =A0 =A0* In laptop mode, we wait until hitting the hi=
gher threshold
>>> > > + =A0 =A0 =A0 =A0 =A0* before starting background writeout, and the=
n write out all
>>> > > + =A0 =A0 =A0 =A0 =A0* the way down to the lower threshold. =A0So s=
low writers cause
>>> > > + =A0 =A0 =A0 =A0 =A0* minimal disk activity.
>>> > > + =A0 =A0 =A0 =A0 =A0*
>>> > > + =A0 =A0 =A0 =A0 =A0* In normal mode, we start background writeout=
 at the lower
>>> > > + =A0 =A0 =A0 =A0 =A0* background_thresh, to keep the amount of dir=
ty memory low.
>>> > > =A0 =A0 =A0 =A0 =A0 =A0*/
>>> > > - =A0 =A0 =A0 =A0 pause <<=3D 1;
>>> > > - =A0 =A0 =A0 =A0 if (pause > HZ / 10)
>>> > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pause =3D HZ / 10;
>>> > > + =A0 =A0 =A0 =A0 if (!laptop_mode && dirty_exceeded =3D=3D DIRTY_E=
XCEED_BACKGROUND)
>>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_start_background_writeback(bd=
i);
>>> > > + =A0 =A0 =A0 =A0 return;
>>> > > =A0 }
>>> > >
>>> > > - /* Clear dirty_exceeded flag only when no task can exceed the lim=
it */
>>> > > - if (!min_dirty_exceeded && bdi->dirty_exceeded)
>>> > > - =A0 =A0 =A0 =A0 bdi->dirty_exceeded =3D 0;
>>> > > + if (!bdi->dirty_exceeded)
>>> > > + =A0 =A0 =A0 =A0 bdi->dirty_exceeded =3D 1;
>>> >
>>> > Will it make sense to move out bdi_task_limit_exceeded() check in a
>>> > separate if condition statement as follows. May be this is little
>>> > easier to read.
>>> >
>>> > =A0 =A0 if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT) {
>>> > =A0 =A0 =A0 =A0 =A0 =A0 if (bdi->dirty_exceeded)
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi->dirty_exceeded =3D 0;
>>> >
>>> > =A0 =A0 =A0 =A0 =A0 =A0 if (!laptop_mode && dirty_exceeded =3D=3D DIR=
TY_EXCEED_BACKGROUND)
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_start_background_writebac=
k(bdi);
>>> >
>>> > =A0 =A0 =A0 =A0 =A0 =A0 return;
>>> > =A0 =A0 }
>>> >
>>> > =A0 =A0 if (dirty_exceeded =3D=3D DIRTY_MAY_EXCEED_LIMIT &&
>>> > =A0 =A0 =A0 =A0 !bdi_task_limit_exceeded(&st, current))
>>> > =A0 =A0 =A0 =A0 =A0 =A0 return;
>>> =A0 But then we have to start background writeback here as well. Which =
is
>>> actually a bug in the original patch as well! So clearly your way is mo=
re
>>> readable :) I'll change it. Thanks.
>>
>> I was thinking about that starting of bdi writeback here. But I was
>> assuming that if we are here then we most likely have visited above
>> loop of < DIRTY_MAY_EXCEED_LIMIT and started background writeback.
>
> Maybe I'm missing something, but at the point in balance_dirty_pages()
> where we kick the flusher thread , before we put the current task to
> sleep, how do you know that background writeback is taking place? =A0Are
> you simply assuming that in previous calls to balance_dirty_pages(),
> that background writeback has been started, and is still taking place
> at the time we need to do throttling?

Never mind, I see that I'm not completely familiar with the writeback
changes for 2.6.38.  I see where we'll kick of BG writeback in
wb_check_background_flush() once we kick the flusher thread.

Curt

>
> Thanks,
> Curt
>
>>
>> Thanks
>> Vivek
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemete=
r.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
