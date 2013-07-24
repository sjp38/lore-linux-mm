Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 3A0ED6B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 17:10:45 -0400 (EDT)
Received: from mail204-db9 (localhost [127.0.0.1])	by
 mail204-db9-R.bigfish.com (Postfix) with ESMTP id 104D420124	for
 <linux-mm@kvack.org>; Wed, 24 Jul 2013 21:10:43 +0000 (UTC)
Received: from DB9EHSMHS027.bigfish.com (unknown [10.174.16.225])	by
 mail204-db9.bigfish.com (Postfix) with ESMTP id 79D868004A	for
 <linux-mm@kvack.org>; Wed, 24 Jul 2013 21:10:41 +0000 (UTC)
Received: from mail52-db9 (localhost [127.0.0.1])	by mail52-db9-R.bigfish.com
 (Postfix) with ESMTP id 7BEC1E005F	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Wed, 24 Jul 2013 21:10:10 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 2/2] Drivers: hv: balloon: Online the hot-added memory
 "in context"
Date: Wed, 24 Jul 2013 21:10:03 +0000
Message-ID: <330d6f16f1a341dbaf5028797bcad305@BLUPR03MB050.namprd03.prod.outlook.com>
References: <1374701355-30799-1-git-send-email-kys@microsoft.com>
 <1374701399-30842-1-git-send-email-kys@microsoft.com>
 <1374701399-30842-2-git-send-email-kys@microsoft.com>
 <51F0414F.3060600@sr71.net>
In-Reply-To: <51F0414F.3060600@sr71.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>



> -----Original Message-----
> From: Dave Hansen [mailto:dave@sr71.net]
> Sent: Wednesday, July 24, 2013 5:04 PM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org;
> yinghan@google.com
> Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Online the hot-added memor=
y "in
> context"
>=20
> On 07/24/2013 02:29 PM, K. Y. Srinivasan wrote:
> >  		/*
> > -		 * Wait for the memory block to be onlined.
> > -		 * Since the hot add has succeeded, it is ok to
> > -		 * proceed even if the pages in the hot added region
> > -		 * have not been "onlined" within the allowed time.
> > +		 * Before proceeding to hot add the next segment,
> > +		 * online the segment that has been hot added.
> >  		 */
> > -		wait_for_completion_timeout(&dm_device.ol_waitevent,
> 5*HZ);
> > +		online_memory_block(start_pfn);
>=20
> Ahhhhh....  You've got a timeout in the code in order to tell the
> hypervisor that you were successfully able to add the memory?  The
> userspace addition code probably wasn't running within this timeout
> period.  right?

As I have always said, the onlining would not occur within a specified amou=
nt
of time (under some conditions). The timeout here is to ensure that we are =
able=20
to online the memory before attempting to hot-add more memory. With the abi=
lity
to online memory from within the kernel, we don't need this timeout and the=
 code is
much more predictable.

Regards,

K. Y



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
