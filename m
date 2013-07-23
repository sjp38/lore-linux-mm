Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A07496B0033
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 13:23:04 -0400 (EDT)
Received: from mail44-co1 (localhost [127.0.0.1])	by mail44-co1-R.bigfish.com
 (Postfix) with ESMTP id 2B4A4D8027C	for <linux-mm@kvack.org>; Tue, 23 Jul
 2013 17:23:02 +0000 (UTC)
Received: from CO1EHSMHS025.bigfish.com (unknown [10.243.78.253])	by
 mail44-co1.bigfish.com (Postfix) with ESMTP id CFF0E100047	for
 <linux-mm@kvack.org>; Tue, 23 Jul 2013 17:23:00 +0000 (UTC)
Received: from mail136-ch1 (localhost [127.0.0.1])	by
 mail136-ch1-R.bigfish.com (Postfix) with ESMTP id 86A05180217	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 23 Jul 2013 17:21:13 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
Date: Tue, 23 Jul 2013 17:21:08 +0000
Message-ID: <9f351a549e76483d9148f87535567ea0@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1374261785-1615-1-git-send-email-kys@microsoft.com>
 <20130722123716.GB24400@dhcp22.suse.cz>
 <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com>
 <51EEA11D.4030007@intel.com>
 <3318be0a96cb4d05838d76dc9d088cc0@SN2PR03MB061.namprd03.prod.outlook.com>
 <51EEA89F.9070309@intel.com>
In-Reply-To: <51EEA89F.9070309@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@suse.cz>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>



> -----Original Message-----
> From: Dave Hansen [mailto:dave.hansen@intel.com]
> Sent: Tuesday, July 23, 2013 12:01 PM
> To: KY Srinivasan
> Cc: Michal Hocko; gregkh@linuxfoundation.org; linux-kernel@vger.kernel.or=
g;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org; yinghan@google.com;
> jasowang@redhat.com; kay@vrfy.org
> Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlini=
ng
> memory blocks
>=20
> On 07/23/2013 08:54 AM, KY Srinivasan wrote:
> >> > Adding memory usually requires allocating some large, contiguous are=
as
> >> > of memory for use as mem_map[] and other VM structures.  That's real=
ly
> >> > hard to do under heavy memory pressure.  How are you accomplishing t=
his?
> > I cannot avoid failures because of lack of memory. In this case I notif=
y the host
> of
> > the failure and also tag the failure as transient. Host retries the ope=
ration after
> some
> > delay. There is no guarantee it will succeed though.
>=20
> You didn't really answer the question.
>=20
> You have allocated some large, physically contiguous areas of memory
> under heavy pressure.  But you also contend that there is too much
> memory pressure to run a small userspace helper.  Under heavy memory
> pressure, I'd expect large, kernel allocations to fail much more often
> than running a small userspace helper.

I am only reporting what I am seeing. Broadly, I have two main failure cond=
itions to
deal with: (a) resource related failure (add_memory() returning -ENOMEM) an=
d (b) not being
able to online a segment that has been successfully hot-added. I have seen =
both these failures
under high memory pressure. By supporting "in context" onlining, we can eli=
minate one failure
case. Our inability to online is not a recoverable failure from the host's =
point of view - the memory
is committed to the guest (since hot add succeeded) but is not usable since=
 it is not onlined.
>=20
> It _sounds_ like you really want to be able to have the host retry the
> operation if it fails, and you return success/failure from inside the
> kernel.  It's hard for you to tell if running the userspace helper
> failed, so your solution is to move what what previously done in
> userspace in to the kernel so that you can more easily tell if it failed
> or succeeded.
>=20
> Is that right?

No; I am able to get the proper error code for recoverable failures (hot ad=
d failures
because of lack of memory). By doing what I am proposing here, we can avoid=
 one class
of failures completely and I think this is what resulted in a better "hot a=
dd" experience in the
guest.

K. Y=20
>=20
>=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
