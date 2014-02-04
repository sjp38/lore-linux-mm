Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id BDE826B0031
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 17:05:32 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id jt11so9120517pbb.1
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 14:05:32 -0800 (PST)
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
        by mx.google.com with ESMTPS id r3si26293366pbh.40.2014.02.04.14.05.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 14:05:31 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so9066956pab.35
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 14:05:31 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <1391548862.2538.34.camel@joe-AO722>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
 <1391546631-7715-3-git-send-email-sebastian.capella@linaro.org>
 <1391548862.2538.34.camel@joe-AO722>
Message-ID: <20140204220534.28287.21049@capellas-linux>
Subject: Re: [PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in
 hibernate.c
Date: Tue, 04 Feb 2014 14:05:34 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

Quoting Joe Perches (2014-02-04 13:21:02)
> On Tue, 2014-02-04 at 12:43 -0800, Sebastian Capella wrote:
> > Checkpatch reports several warnings in hibernate.c
> > printk use removed, long lines wrapped, whitespace cleanup,
> > extend short msleeps, while loops on two lines.
> []
> > diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
> []
> > @@ -765,7 +762,7 @@ static int software_resume(void)
> >       if (isdigit(resume_file[0]) && resume_wait) {
> >               int partno;
> >               while (!get_gendisk(swsusp_resume_device, &partno))
> > -                     msleep(10);
> > +                     msleep(20);
> =

> What good is changing this from 10 to 20?
> =

> > @@ -776,8 +773,9 @@ static int software_resume(void)
> >               wait_for_device_probe();
> >  =

> >               if (resume_wait) {
> > -                     while ((swsusp_resume_device =3D name_to_dev_t(re=
sume_file)) =3D=3D 0)
> > -                             msleep(10);
> > +                     while ((swsusp_resume_device =3D
> > +                                     name_to_dev_t(resume_file)) =3D=
=3D 0)
> > +                             msleep(20);
> =

> here too.

Thanks Joe!

I'm happy to make whatever change is best.  I just ran into one
checkpatch warning around a printk I indented and figured I'd try to get
them all if I could.

The delays in question didn't appear timing critical as both are looping
waiting for device discovery to complete.  They're only enabled when using
the resumewait command line parameter.

Is this an incorrect checkpatch warning?  The message from checkpatch
implies using msleep for smaller values can be misleading.

WARNING: msleep < 20ms can sleep for up to 20ms; see
Documentation/timers/timers-howto.txt
+  msleep(10);

From=20Documentation/timers/timers-howto.txt

SLEEPING FOR ~USECS OR SMALL MSECS ( 10us - 20ms):                       =

  * Use usleep_range                                               =


  - Why not msleep for (1ms - 20ms)?                               =

    Explained originally here:                               =

      http://lkml.org/lkml/2007/8/3/250                =

    msleep(1~20) may not do what the caller intends, and     =

    will often sleep longer (~20 ms actual sleep for any     =

    value given in the 1~20ms range). In many cases this     =

    is not the desired behavior. =


When I look at kernel/timers.c in my current kernel, I see msleep is
using msecs_to_jiffies + 1, and on my current platform this appears to
be ~20msec as the jiffies are 10ms.

Thanks,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
