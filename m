Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 71A5D6B0038
	for <linux-mm@kvack.org>; Sun, 14 Dec 2014 13:45:23 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so10331588pad.23
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 10:45:23 -0800 (PST)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bbn0107.outbound.protection.outlook.com. [157.56.111.107])
        by mx.google.com with ESMTPS id fi4si10922866pad.19.2014.12.14.10.45.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 14 Dec 2014 10:45:21 -0800 (PST)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 2/2] Drivers: hv: balloon: Fix the deadlock issue in the
 memory hot-add code
Date: Sun, 14 Dec 2014 18:45:17 +0000
Message-ID: <BY2PR0301MB07116E6E7D337FD68A7FD14DA06E0@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1417826471-21131-1-git-send-email-kys@microsoft.com>
 <1417826498-21172-1-git-send-email-kys@microsoft.com>
 <1417826498-21172-2-git-send-email-kys@microsoft.com>
 <20141208150445.GB29102@dhcp22.suse.cz> <54864F27.8010008@jp.fujitsu.com>
 <20141209090843.GA11373@dhcp22.suse.cz> <5486CE2E.4070409@jp.fujitsu.com>
 <20141209105532.GB11373@dhcp22.suse.cz>
 <BY2PR0301MB07118CFD9B32FEBE4E0C9921A0630@BY2PR0301MB0711.namprd03.prod.outlook.com>
 <20141211125829.GA19435@dhcp22.suse.cz>
In-Reply-To: <20141211125829.GA19435@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@suse.cz]
> Sent: Thursday, December 11, 2014 4:58 AM
> To: KY Srinivasan
> Cc: Yasuaki Ishimatsu; gregkh@linuxfoundation.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; linux-mm@kvack.org
> Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Fix the deadlock issue in =
the
> memory hot-add code
>=20
> On Thu 11-12-14 00:21:09, KY Srinivasan wrote:
> >
> >
> > > -----Original Message-----
> > > From: Michal Hocko [mailto:mhocko@suse.cz]
> > > Sent: Tuesday, December 9, 2014 2:56 AM
> > > To: Yasuaki Ishimatsu
> > > Cc: KY Srinivasan; gregkh@linuxfoundation.org; linux-
> > > kernel@vger.kernel.org; devel@linuxdriverproject.org;
> > > olaf@aepfle.de; apw@canonical.com; linux-mm@kvack.org
> > > Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Fix the deadlock
> > > issue in the memory hot-add code
> > >
> > > On Tue 09-12-14 19:25:50, Yasuaki Ishimatsu wrote:
> > > > (2014/12/09 18:08), Michal Hocko wrote:
> > > [...]
> > > > >Doesn't udev retry the operation if it gets EBUSY or EAGAIN?
> > > >
> > > > It depend on implementation of udev.rules. So we can retry
> > > > online/offline operation in udev.rules.
> > > [...]
> > >
> > > # Memory hotadd request
> > > SUBSYSTEM=3D=3D"memory", ACTION=3D=3D"add",
> > > DEVPATH=3D=3D"/devices/system/memory/memory*[0-9]",
> > > TEST=3D=3D"/sys$devpath/state", RUN+=3D"/bin/sh -c 'echo online >
> > > /sys$devpath/state'"
> > >
> > > OK so this is not prepared for a temporary failures and retries.
> > >
> > > > >And again, why cannot we simply make the onlining fail or
> > > > >try_lock and retry internally if the event consumer cannot cope wi=
th
> errors?
> > > >
> > > > Did you mean the following Srinivasan's first patch looks good to y=
ou?
> > > >   https://lkml.org/lkml/2014/12/2/662
> > >
> > > Heh, I was just about to post this. Because I haven't noticed the
> > > previous patch yet. Yeah, Something like that. Except that I would
> > > expect EAGAIN or EBUSY rather than ERESTARTSYS which should never
> > > leak into userspace. And that would happen here AFAICS because
> > > signal_pending will not be true usually.
> > Michal,
> >
> > I agree that the fix to this problem must be outside the clients of
> > add_memory() and that is the reason I had sent that patch:
> > https://lkml.org/lkml/2014/12/2/662. Let me know if you want me to
> > resend this patch with the correct return value.
>=20
> Please think about the other suggested options as well.

Thanks Michal. I will look at the other options you have listed as well.

K. Y
>=20
> > Regards,
> >
> > K. Y
> > >
> > > So there are two options. Either make the udev rule more robust and
> > > retry within RUN section or do the retry withing online_pages
> > > (try_lock and go into interruptible sleep which gets signaled by
> > > finished add_memory()). The later option is safer wrt. the userspace
> > > because the operation wouldn't fail unexpectedly.
> > > Another option would be generating the sysfs file after all the
> > > internal initialization is done and call it outside of the memory hot=
plug
> lock.
> > >
> > > --
> > > Michal Hocko
> > > SUSE Labs
>=20
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
