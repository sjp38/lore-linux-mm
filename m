Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 46EE16B0008
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 13:13:32 -0500 (EST)
Received: from mail268-va3 (localhost [127.0.0.1])	by
 mail268-va3-R.bigfish.com (Postfix) with ESMTP id E847B1580301	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Mon,  4 Mar 2013 18:11:06 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] mm: Export split_page().
Date: Mon, 4 Mar 2013 18:10:56 +0000
Message-ID: <7c3247b488834be19a155df40c61523f@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1362364075-14564-1-git-send-email-kys@microsoft.com>
 <20130304020747.GA8265@kroah.com>
 <3a362e994ab64efda79ae3c80342db95@SN2PR03MB061.namprd03.prod.outlook.com>
 <20130304022508.GA8638@kroah.com>
 <b863089d05f442fb9dfc90faa158a001@SN2PR03MB061.namprd03.prod.outlook.com>
 <5134D476.3040302@linux.vnet.ibm.com>
In-Reply-To: <5134D476.3040302@linux.vnet.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> Sent: Monday, March 04, 2013 12:06 PM
> To: KY Srinivasan
> Cc: Greg KH; linux-kernel@vger.kernel.org; devel@linuxdriverproject.org;
> olaf@aepfle.de; apw@canonical.com; andi@firstfloor.org; akpm@linux-
> foundation.org; linux-mm@kvack.org
> Subject: Re: [PATCH 1/1] mm: Export split_page().
>=20
> On 03/03/2013 06:36 PM, KY Srinivasan wrote:
> >> I guess the most obvious question about exporting this symbol is, "Why
> >> doesn't any of the other hypervisor balloon drivers need this?  What i=
s
> >> so special about hyper-v?"
> >
> > The balloon protocol that Hyper-V has specified is designed around the =
ability
> to
> > move 2M pages. While the protocol can handle 4k allocations, it is goin=
g to be
> very chatty
> > with 4K allocations.
>=20
> What does "very chatty" mean?  Do you think that there will be a
> noticeable performance difference ballooning 2M pages vs 4k?

The balloon protocol that Hyper-V host specified allows you to specify page
ranges - start_pfn: num_pfn. With 2M pages the number of messages that need
to be exchanges is significantly fewer than with 4K page allocations.
>=20
> > Furthermore, the Memory Balancer on the host is also designed to work
> > best with memory moving around in 2M chunks. While I have not seen the
> code on the Windows
> > host that does this memory balancing, looking at how Windows guests beh=
ave
> in this environment,
> > (relative to Linux) I have to assume that the 2M allocations that Windo=
ws
> guests do are a big part of
> > the difference we see.
>=20
> You've been talking about differences.  Could you elaborate on what the
> differences in behavior are that you are trying to rectify here?

As I look at how smoothly memory is balanced on Windows guests with changin=
g load conditions
in the guest relative to what I see with Linux, I see Linux taking more tim=
e to reach the steady state
during a balancing operation.  I will experiment with 2M allocations and re=
port if this issue is addressed.

>=20
> >> Or can those other drivers also need/use it as well, and they were jus=
t
> >> too chicken to be asking for the export?  :)
> >
> > The 2M balloon allocations would make sense if the host is designed
> accordingly.
>=20
> How does the guest decide which size pages to allocate?  It seems like a
> relatively bad idea to be inflating the balloon with 2M pages from the
> guest in the case where the guest is under memory pressure _and_
> fragmented.

I want to start with 2M allocations and if they fail, fall back onto lower =
order allocations.
As I said, the host can support 4K allocations and that will be the final f=
allback position
(that is what I have currently implemented). If the guest memory is fragmen=
ted, then
obviously we will go in for lower order allocations.

Regards,

K. Y=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
