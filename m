Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id CC2A06B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:48:50 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so2450609pbc.24
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:48:50 -0800 (PST)
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
        by mx.google.com with ESMTPS id yy4si2720448pbc.219.2014.02.06.15.48.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 15:48:49 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so2389243pab.33
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:48:48 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <20140205150101.f6fbe53db7d30a09854a5c5c@linux-foundation.org>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
 <1391546631-7715-2-git-send-email-sebastian.capella@linaro.org>
 <20140205135052.4066b67689cbf47c551d30a9@linux-foundation.org>
 <20140205225552.16730.1677@capellas-linux>
 <20140205150101.f6fbe53db7d30a09854a5c5c@linux-foundation.org>
Message-ID: <20140206234846.10826.57970@capellas-linux>
Subject: Re: [PATCH v7 1/3] mm: add kstrdup_trimnl function
Date: Thu, 06 Feb 2014 15:48:46 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joe Perches <joe@perches.com>, David Rientjes <rientjes@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, Pavel Machek <pavel@ucw.cz>

Quoting Andrew Morton (2014-02-05 15:01:01)
> On Wed, 05 Feb 2014 14:55:52 -0800 Sebastian Capella <sebastian.capella@l=
inaro.org> wrote:
> =

> > Quoting Andrew Morton (2014-02-05 13:50:52)
> > > On Tue,  4 Feb 2014 12:43:49 -0800 Sebastian Capella <sebastian.capel=
la@linaro.org> wrote:
> > > =

> > > > kstrdup_trimnl creates a duplicate of the passed in
> > > > null-terminated string.  If a trailing newline is found, it
> > > > is removed before duplicating.  This is useful for strings
> > > > coming from sysfs that often include trailing whitespace due to
> > > > user input.
> > > =

> > > hm, why?  I doubt if any caller of this wants to retain leading and/or
> > > trailing spaces and/or tabs.
> > =

> > Hi Andrew,
> > =

> > I agree the common case doesn't usually need leading or trailing whites=
pace.
> > =

> > Pavel and others pointed out that a valid filename could contain
> > newlines/whitespace at any position.
> =

> The number of cases in which we provide the kernel with a filename via
> sysfs will be very very small, or zero.
> =

> If we can go through existing code and find at least a few sites which
> can usefully employ kstrdup_trimnl() then fine, we have evidence.  But
> I doubt if we can do that?
Hi Andrew,

I went through all of the store functions I could find and, though I
found a lot of examples handling \n, I found no other examples
specifically parsing filenames.  Most deal with integers.  Those parsing
commands often use sysfs_streq or otherwise are doing some custom
behavior that wouldn't suit a utility function.

For my purposes, it looks like v2 of the patch seems like the best
starting point based on all of the feedback I've received.  So I'm
moving back to a custom solution for parsing this input.  Unless
someone objects or has comments, I'll post something like the
function below.

static ssize_t resume_store(struct kobject *kobj, struct kobj_attribute *at=
tr,
			    const char *buf, size_t n)
{
	dev_t res;
	int len =3D n;
	char *name;

	if (len && buf[len-1] =3D=3D '\n')
		len--;
	name =3D kstrndup(buf, len, GFP_KERNEL);
	if (!name)
		return -ENOMEM;

	res =3D name_to_dev_t(name);
	kfree(name);
	if (!res)
		return -EINVAL;

	lock_system_sleep();
	swsusp_resume_device =3D res;
	unlock_system_sleep();
	printk(KERN_INFO "PM: Starting manual resume from disk\n");
	noresume =3D 0;
	software_resume();
	return n;
}


Thanks,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
