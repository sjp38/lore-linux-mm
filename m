Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id DC5526B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 15:48:00 -0400 (EDT)
Received: from mail128-db8 (localhost [127.0.0.1])	by
 mail128-db8-R.bigfish.com (Postfix) with ESMTP id D0BA6160462	for
 <linux-mm@kvack.org>; Wed, 24 Jul 2013 19:47:57 +0000 (UTC)
Received: from DB8EHSMHS021.bigfish.com (unknown [10.174.8.230])	by
 mail128-db8.bigfish.com (Postfix) with ESMTP id AA1934E0046	for
 <linux-mm@kvack.org>; Wed, 24 Jul 2013 19:47:06 +0000 (UTC)
Received: from mail114-va3 (localhost [127.0.0.1])	by
 mail114-va3-R.bigfish.com (Postfix) with ESMTP id 202DA1E05F6	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Wed, 24 Jul 2013 19:45:22 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
Date: Wed, 24 Jul 2013 19:45:12 +0000
Message-ID: <d1f80c05986b439cbeef12bcd595b264@BLUPR03MB050.namprd03.prod.outlook.com>
References: <1374261785-1615-1-git-send-email-kys@microsoft.com>
 <20130722123716.GB24400@dhcp22.suse.cz>
 <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com>
 <51EEA11D.4030007@intel.com>
 <3318be0a96cb4d05838d76dc9d088cc0@SN2PR03MB061.namprd03.prod.outlook.com>
 <51EEA89F.9070309@intel.com>
 <9f351a549e76483d9148f87535567ea0@SN2PR03MB061.namprd03.prod.outlook.com>
 <51F00415.8070104@sr71.net>
In-Reply-To: <51F00415.8070104@sr71.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.cz>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>



> -----Original Message-----
> From: Dave Hansen [mailto:dave@sr71.net]
> Sent: Wednesday, July 24, 2013 12:43 PM
> To: KY Srinivasan
> Cc: Dave Hansen; Michal Hocko; gregkh@linuxfoundation.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; andi@firstfloor.org; akpm@linux-foundation.org; linux-
> mm@kvack.org; kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org;
> yinghan@google.com; jasowang@redhat.com; kay@vrfy.org
> Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlini=
ng
> memory blocks
>=20
> On 07/23/2013 10:21 AM, KY Srinivasan wrote:
> >> You have allocated some large, physically contiguous areas of memory
> >> under heavy pressure.  But you also contend that there is too much
> >> memory pressure to run a small userspace helper.  Under heavy memory
> >> pressure, I'd expect large, kernel allocations to fail much more often
> >> than running a small userspace helper.
> >
> > I am only reporting what I am seeing. Broadly, I have two main failure
> conditions to
> > deal with: (a) resource related failure (add_memory() returning -ENOMEM=
)
> and (b) not being
> > able to online a segment that has been successfully hot-added. I have s=
een
> both these failures
> > under high memory pressure. By supporting "in context" onlining, we can
> eliminate one failure
> > case. Our inability to online is not a recoverable failure from the hos=
t's point of
> view - the memory
> > is committed to the guest (since hot add succeeded) but is not usable s=
ince it is
> not onlined.
>=20
> Could you please precisely report on what you are seeing in detail?
> Where are the -ENOMEMs coming from?  Which allocation site?  Are you
> seeing OOMs or page allocation failure messages on the console?

The ENOMEM failure I see from the call to hot add memory - the call to
add_memory(). Usually I don't see any OOM messages on the console.

>=20
> The operation was split up in to two parts for good reason.  It's
> actually for your _precise_ use case.

I agree and without this split, I could not implement the balloon driver wi=
th
hot-add.

>=20
> A system under memory pressure is going to have troubles doing a
> hot-add.  You need memory to add memory.  Of the two operations ("add"
> and "online"), "add" is the one vastly more likely to fail.  It has to
> allocate several large swaths of contiguous physical memory.  For that
> reason, the system was designed so that you could "add" and "online"
> separately.  The intention was that you could "add" far in advance and
> then "online" under memory pressure, with the "online" having *VASTLY*
> smaller memory requirements and being much more likely to succeed.
>=20
> You're lumping the "allocate several large swaths of contiguous physical
> memory" failures in to the same class as "run a small userspace helper".
>  They are _really_ different problems.  Both prone to allocation
> failures for sure, but _very_ separate problems.  Please don't conflate
> them.

I don't think I am conflating these two issues; I am sorry if I gave that=20
impression. All I am saying is that I see two classes of failures: (a) Our
inability to allocate memory to manage the memory that is being hot added
and (b) Our inability to bring the hot added memory online within a reasona=
ble
amount of time. I am not sure the cause for (b) and I was just speculating =
that
this could be memory related. What is interesting is that I have seen failu=
re related
to our inability to online the memory after having succeeded in hot adding =
the
memory.
=20
>=20
> >> It _sounds_ like you really want to be able to have the host retry the
> >> operation if it fails, and you return success/failure from inside the
> >> kernel.  It's hard for you to tell if running the userspace helper
> >> failed, so your solution is to move what what previously done in
> >> userspace in to the kernel so that you can more easily tell if it fail=
ed
> >> or succeeded.
> >>
> >> Is that right?
> >
> > No; I am able to get the proper error code for recoverable failures (ho=
t add
> failures
> > because of lack of memory). By doing what I am proposing here, we can a=
void
> one class
> > of failures completely and I think this is what resulted in a better "h=
ot add"
> experience in the
> > guest.
>=20
> I think you're taking a huge leap here: "We could not online memory,
> thus we must take userspace out of the loop."
>=20
> You might be right.  There might be only one way out of this situation.
>  But you need to provide a little more supporting evidence before we all
> arrive at the same conclusion.

I am not even suggesting that. All I am saying is that there should be a me=
chanism
for "in context" onlining of memory in addition to the existing sysfs mecha=
nism
for bringing memory online from a kernel context. Hyper-V balloon driver
can certainly use this functionality. I should be sending out the patches f=
or this
shortly.
>=20
> BTW, it doesn't _require_ udev.  There could easily be another listener
> for hotplug events.

Agreed; but structurally it is identical to having a udev rule.

Regards,

K. Y



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
