Received: by nz-out-0506.google.com with SMTP id f1so109426nzc
        for <linux-mm@kvack.org>; Wed, 02 May 2007 05:14:12 -0700 (PDT)
Message-ID: <3ae72650705020514m1e36caadtc9d64b5439b0cd03@mail.gmail.com>
Date: Wed, 2 May 2007 14:14:11 +0200
From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative! (-1)
In-Reply-To: <20070502074305.GA7761@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org>
	 <46338AEB.2070109@imap.cc>
	 <20070428141024.887342bd.akpm@linux-foundation.org>
	 <4636248E.7030309@imap.cc>
	 <20070430112130.b64321d3.akpm@linux-foundation.org>
	 <46364346.6030407@imap.cc>
	 <20070430124638.10611058.akpm@linux-foundation.org>
	 <46383742.9050503@imap.cc>
	 <20070502001000.8460fb31.akpm@linux-foundation.org>
	 <20070502074305.GA7761@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tilman Schmidt <tilman@imap.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On 5/2/07, Greg KH <gregkh@suse.de> wrote:
> On Wed, May 02, 2007 at 12:10:00AM -0700, Andrew Morton wrote:
> > On Wed, 02 May 2007 09:01:22 +0200 Tilman Schmidt <tilman@imap.cc> wrote:
> >
> > > Am 30.04.2007 21:46 schrieb Andrew Morton:
> > > > Not really - everything's tangled up.  A bisection search on the
> > > > 2.6.21-rc7-mm2 driver tree would be the best bet.
> > >
> > > And the winner is:
> > >
> > > gregkh-driver-driver-core-make-uevent-environment-available-in-uevent-file.patch
> > >
> > > Reverting only that from 2.6.21-rc7-mm2 gives me a working kernel
> > > again.
> >
> > cripes.
> >
> > +static ssize_t show_uevent(struct device *dev, struct device_attribute *attr,
> > +                          char *buf)
> > +{
> > +       struct kobject *top_kobj;
> > +       struct kset *kset;
> > +       char *envp[32];
> > +       char data[PAGE_SIZE];
> >
> > That won't work too well with 4k stacks.

Yeah, sorry.

> Wait, even though this isn't good, it shouldn't have been hit by anyone,
> that file used to not be readable, so I doubt userspace would have been
> trying to read it...
>
> Tilman, what version of HAL and udev do you have on your machine?
>
> Kay, did you get the 'read the uevent file' code already into udev
> and/or HAL?

Only udevtest uses this at the moment, but that is only used for debugging.
It's probably the brain-dead libsysfs, which opens and reads every
file in /sys, even when nobody is interested in the data.

Thanks,
Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
