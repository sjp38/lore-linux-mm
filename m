Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 236806B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 11:51:38 -0400 (EDT)
Received: from mail91-co9 (localhost [127.0.0.1])	by mail91-co9-R.bigfish.com
 (Postfix) with ESMTP id BF2953C0176	for <linux-mm@kvack.org>; Tue, 23 Jul
 2013 15:51:35 +0000 (UTC)
Received: from CO9EHSMHS022.bigfish.com (unknown [10.236.132.254])	by
 mail91-co9.bigfish.com (Postfix) with ESMTP id 11C95B8004C	for
 <linux-mm@kvack.org>; Tue, 23 Jul 2013 15:51:33 +0000 (UTC)
Received: from mail165-db8 (localhost [127.0.0.1])	by
 mail165-db8-R.bigfish.com (Postfix) with ESMTP id ED98520024A	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 23 Jul 2013 15:51:00 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
Date: Tue, 23 Jul 2013 15:50:52 +0000
Message-ID: <1b32d8e17e2546908d42e6d702b13cfd@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1374261785-1615-1-git-send-email-kys@microsoft.com>
 <20130722123716.GB24400@dhcp22.suse.cz>
 <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com>
 <20130723150931.GM8677@dhcp22.suse.cz>
In-Reply-To: <20130723150931.GM8677@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>



> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@suse.cz]
> Sent: Tuesday, July 23, 2013 11:10 AM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org; yinghan@google.com;
> jasowang@redhat.com; kay@vrfy.org
> Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlini=
ng
> memory blocks
>=20
> On Tue 23-07-13 14:52:36, KY Srinivasan wrote:
> >
> >
> > > -----Original Message-----
> > > From: Michal Hocko [mailto:mhocko@suse.cz]
> > > Sent: Monday, July 22, 2013 8:37 AM
> > > To: KY Srinivasan
> > > Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> > > devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> > > andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> > > kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org;
> yinghan@google.com;
> > > jasowang@redhat.com; kay@vrfy.org
> > > Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for on=
lining
> > > memory blocks
> > >
> > > On Fri 19-07-13 12:23:05, K. Y. Srinivasan wrote:
> > > > The current machinery for hot-adding memory requires having udev
> > > > rules to bring the memory segments online. Export the necessary
> functionality
> > > > to to bring the memory segment online without involving user space =
code.
> > >
> > > Why? Who is going to use it and for what purpose?
> > > If you need to do it from the kernel cannot you use usermod helper
> > > thread?
> > >
> > > Besides that this is far from being complete. memory_block_change_sta=
te
> > > seems to depend on device_hotplug_lock and find_memory_block is
> > > currently called with mem_sysfs_mutex held. None of them is exported
> > > AFAICS.
> >
> > You are right; not all of the required symbols are exported (yet). Let
> > me answer your other questions first:
> >
> > The Hyper-V balloon driver can use this functionality. I have
> > prototyped the in-kernel "onlining" of hot added memory without
> > requiring any help from user level code that performs significantly
> > better than having user level code involved in the hot add process.
>=20
> What does significantly better mean here?

Less failures than before.
>=20
> > With this change, I am able to successfully hot-add and online the
> > hot-added memory even under extreme memory pressure which is what you
> > would want given that we are hot-adding memory to alleviate memory
> > pressure. The current scheme of involving user level code to close
> > this loop obviously does not perform well under high memory pressure.
>=20
> Hmm, this is really unexpected. Why the high memory pressure matters
> here? Userspace only need to access sysfs file and echo a simple string
> into a file. The reset is same regardless you do it from the userspace.

Could it be that we could fail to launch the user-space thread. The host  p=
resents
a large chunk of memory for "hot adding". Within the guest, I break this up=
 and hot-add
128MB chunks; as I loop through this process, I wait for the onlining to oc=
cur before proceeding
with the next hotadd operation. With user space code involved in the onlini=
ng process, I would=20
frequently timeout waiting for onlining to complete (under high memory load=
).
After I switched over to not involving the user space code, this problem do=
es not exist since
onlining is done "in context".
 =20
>=20
> > I can, if you prefer export all of the necessary functionality in one
> > patch.
>=20
> If this turns out really a valid use case then I would prefer exporting
> a high level function which would hide all the locking and direct
> manipulation with mem blocks.

I will take a crack at defining wrappers to hide some of the details. I wil=
l also
post the Hyper-V balloon driver patch that uses this functionality.

Regards,

K. Y=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
