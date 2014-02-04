Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6164E6B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 18:45:54 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id j1so10022143iga.3
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 15:45:54 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0246.hostedemail.com. [216.40.44.246])
        by mx.google.com with ESMTP id mg9si36088245icc.11.2014.02.04.15.45.53
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 15:45:53 -0800 (PST)
Message-ID: <1391557549.2538.39.camel@joe-AO722>
Subject: Re: [PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in
 hibernate.c
From: Joe Perches <joe@perches.com>
Date: Tue, 04 Feb 2014 15:45:49 -0800
In-Reply-To: <20140204220534.28287.21049@capellas-linux>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
	 <1391546631-7715-3-git-send-email-sebastian.capella@linaro.org>
	 <1391548862.2538.34.camel@joe-AO722>
	 <20140204220534.28287.21049@capellas-linux>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Tue, 2014-02-04 at 14:05 -0800, Sebastian Capella wrote:
> Quoting Joe Perches (2014-02-04 13:21:02)
> > On Tue, 2014-02-04 at 12:43 -0800, Sebastian Capella wrote:
> > > Checkpatch reports several warnings in hibernate.c
> > > printk use removed, long lines wrapped, whitespace cleanup,
> > > extend short msleeps, while loops on two lines.
> > []
> > > diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
> > []
> > > @@ -765,7 +762,7 @@ static int software_resume(void)
> > >       if (isdigit(resume_file[0]) && resume_wait) {
> > >               int partno;
> > >               while (!get_gendisk(swsusp_resume_device, &partno))
> > > -                     msleep(10);
> > > +                     msleep(20);
> > 
> > What good is changing this from 10 to 20?
> > 
> > > @@ -776,8 +773,9 @@ static int software_resume(void)
> > >               wait_for_device_probe();
> > >  
> > >               if (resume_wait) {
> > > -                     while ((swsusp_resume_device = name_to_dev_t(resume_file)) == 0)
> > > -                             msleep(10);
> > > +                     while ((swsusp_resume_device =
> > > +                                     name_to_dev_t(resume_file)) == 0)
> > > +                             msleep(20);
> > 
> > here too.
> 
> Thanks Joe!
> 
> I'm happy to make whatever change is best.  I just ran into one
> checkpatch warning around a printk I indented and figured I'd try to get
> them all if I could.

Shutting up checkpatch for the sake of shutting of
checkpatch is sometimes not the right thing to do.

> The delays in question didn't appear timing critical as both are looping
> waiting for device discovery to complete.  They're only enabled when using
> the resumewait command line parameter.

Any time it happens faster doesn't hurt and
can therefore could resume faster no?

> Is this an incorrect checkpatch warning?  The message from checkpatch
> implies using msleep for smaller values can be misleading.

That's true, but it doesn't mean it's required
to change the code.

>   - Why not msleep for (1ms - 20ms)?                               
>     Explained originally here:                               
>       http://lkml.org/lkml/2007/8/3/250                
>     msleep(1~20) may not do what the caller intends, and     
>     will often sleep longer (~20 ms actual sleep for any     
>     value given in the 1~20ms range). In many cases this     
>     is not the desired behavior. 
> 
> When I look at kernel/timers.c in my current kernel, I see msleep is
> using msecs_to_jiffies + 1, and on my current platform this appears to
> be ~20msec as the jiffies are 10ms.

And on platforms where HZ is 1000, it's
still slightly faster.

I'd just leave it alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
