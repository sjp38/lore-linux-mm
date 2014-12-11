Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B16746B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 19:21:12 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id w10so3807506pde.11
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 16:21:12 -0800 (PST)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0141.outbound.protection.outlook.com. [207.46.100.141])
        by mx.google.com with ESMTPS id vs9si8948713pbc.142.2014.12.10.16.21.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 10 Dec 2014 16:21:11 -0800 (PST)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 2/2] Drivers: hv: balloon: Fix the deadlock issue in the
 memory hot-add code
Date: Thu, 11 Dec 2014 00:21:09 +0000
Message-ID: <BY2PR0301MB07118CFD9B32FEBE4E0C9921A0630@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1417826471-21131-1-git-send-email-kys@microsoft.com>
 <1417826498-21172-1-git-send-email-kys@microsoft.com>
 <1417826498-21172-2-git-send-email-kys@microsoft.com>
 <20141208150445.GB29102@dhcp22.suse.cz> <54864F27.8010008@jp.fujitsu.com>
 <20141209090843.GA11373@dhcp22.suse.cz> <5486CE2E.4070409@jp.fujitsu.com>
 <20141209105532.GB11373@dhcp22.suse.cz>
In-Reply-To: <20141209105532.GB11373@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@suse.cz]
> Sent: Tuesday, December 9, 2014 2:56 AM
> To: Yasuaki Ishimatsu
> Cc: KY Srinivasan; gregkh@linuxfoundation.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; linux-mm@kvack.org
> Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Fix the deadlock issue in =
the
> memory hot-add code
>=20
> On Tue 09-12-14 19:25:50, Yasuaki Ishimatsu wrote:
> > (2014/12/09 18:08), Michal Hocko wrote:
> [...]
> > >Doesn't udev retry the operation if it gets EBUSY or EAGAIN?
> >
> > It depend on implementation of udev.rules. So we can retry
> > online/offline operation in udev.rules.
> [...]
>=20
> # Memory hotadd request
> SUBSYSTEM=3D=3D"memory", ACTION=3D=3D"add",
> DEVPATH=3D=3D"/devices/system/memory/memory*[0-9]",
> TEST=3D=3D"/sys$devpath/state", RUN+=3D"/bin/sh -c 'echo online >
> /sys$devpath/state'"
>=20
> OK so this is not prepared for a temporary failures and retries.
>=20
> > >And again, why cannot we simply make the onlining fail or try_lock
> > >and retry internally if the event consumer cannot cope with errors?
> >
> > Did you mean the following Srinivasan's first patch looks good to you?
> >   https://lkml.org/lkml/2014/12/2/662
>=20
> Heh, I was just about to post this. Because I haven't noticed the previou=
s
> patch yet. Yeah, Something like that. Except that I would expect EAGAIN o=
r
> EBUSY rather than ERESTARTSYS which should never leak into userspace. And
> that would happen here AFAICS because signal_pending will not be true
> usually.
Michal,

I agree that the fix to this problem must be outside the clients of  add_me=
mory() and that
is the reason I had sent that patch:  https://lkml.org/lkml/2014/12/2/662. =
Let me know if
you want me to resend this patch with the correct return value.

Regards,

K. Y
>=20
> So there are two options. Either make the udev rule more robust and retry
> within RUN section or do the retry withing online_pages (try_lock and go =
into
> interruptible sleep which gets signaled by finished add_memory()). The la=
ter
> option is safer wrt. the userspace because the operation wouldn't fail
> unexpectedly.
> Another option would be generating the sysfs file after all the internal
> initialization is done and call it outside of the memory hotplug lock.
>=20
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
