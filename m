Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 9FA836B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 07:53:58 -0500 (EST)
Received: from mail234-tx2 (localhost [127.0.0.1])	by
 mail234-tx2-R.bigfish.com (Postfix) with ESMTP id 2CAE5380143	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue,  6 Nov 2012 12:53:05 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/2] mm: Export vm_committed_as
Date: Tue, 6 Nov 2012 12:53:01 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF930DFBA2F@SN2PRD0310MB382.namprd03.prod.outlook.com>
References: <1349654347-18337-1-git-send-email-kys@microsoft.com>
 <1349654386-18378-1-git-send-email-kys@microsoft.com>
 <20121008004358.GA12342@kroah.com>
 <426367E2313C2449837CD2DE46E7EAF930A1FB31@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20121008133539.GA15490@kroah.com>
 <20121009124755.ce1087b4.akpm@linux-foundation.org>
 <426367E2313C2449837CD2DE46E7EAF930DF7FBB@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20121105134456.f655b85a.akpm@linux-foundation.org>
 <426367E2313C2449837CD2DE46E7EAF930DFA7B8@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20121106090539.GB21167@dhcp22.suse.cz>
In-Reply-To: <20121106090539.GB21167@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "apw@canonical.com" <apw@canonical.com>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>



> -----Original Message-----
> From: Michal Hocko [mailto:mstsxfx@gmail.com] On Behalf Of Michal Hocko
> Sent: Tuesday, November 06, 2012 4:06 AM
> To: KY Srinivasan
> Cc: Andrew Morton; Greg KH; olaf@aepfle.de; linux-kernel@vger.kernel.org;
> andi@firstfloor.org; apw@canonical.com; devel@linuxdriverproject.org; lin=
ux-
> mm@kvack.org; Hiroyuki Kamezawa; Johannes Weiner; Ying Han
> Subject: Re: [PATCH 1/2] mm: Export vm_committed_as
>=20
> On Mon 05-11-12 22:12:25, KY Srinivasan wrote:
> >
> >
> > > -----Original Message-----
> > > From: Andrew Morton [mailto:akpm@linux-foundation.org]
> > > Sent: Monday, November 05, 2012 4:45 PM
> > > To: KY Srinivasan
> > > Cc: Greg KH; olaf@aepfle.de; linux-kernel@vger.kernel.org;
> andi@firstfloor.org;
> > > apw@canonical.com; devel@linuxdriverproject.org; linux-mm@kvack.org;
> > > Hiroyuki Kamezawa; Michal Hocko; Johannes Weiner; Ying Han
> > > Subject: Re: [PATCH 1/2] mm: Export vm_committed_as
> > >
> > > On Sat, 3 Nov 2012 14:09:38 +0000
> > > KY Srinivasan <kys@microsoft.com> wrote:
> > >
> > > >
> > > >
> > > > > >
> > > > > > Ok, but you're going to have to get the -mm developers to agree=
 that
> > > > > > this is ok before I can accept it.
> > > > >
> > > > > Well I guess it won't kill us.
> > > >
> > > > Andrew,
> > > >
> > > > I presumed this was an Ack from you with regards to exporting the
> > > > symbol. Looks like Greg is waiting to hear from you before he can c=
heck
> > > > these patches in. Could you provide an explicit Ack.
> > > >
> > >
> > > Well, I do have some qualms about exporting vm_committed_as to module=
s.
> > >
> > > vm_committed_as is a global thing and only really makes sense in a
> > > non-containerised system.  If the application is running within a
> > > memory cgroup then vm_enough_memory() and the global overcommit
> policy
> > > are at best irrelevant and misleading.
> > >
> > > If use of vm_committed_as is indeed a bad thing, then exporting it to
> > > modules might increase the amount of badness in the kernel.
> > >
> > >
> > > I don't think these qualms are serious enough to stand in the way of
> > > this patch, but I'd be interested in hearing the memcg developers'
> > > thoughts on the matter?
> > >
> > >
> > > Perhaps you could provide a detailed description of why your module
> > > actually needs this?  Precisely what information is it looking for
> > > and why?  If we know that then perhaps a more comfortable alternative
> > > can be found.
> >
> > The Hyper-V host has a policy engine for managing available physical
> > memory across competing virtual machines. This policy decision
> > is based on a number of parameters including the memory pressure
> > reported by the guest. Currently, the pressure calculation is based
> > on the memory commitment made by the guest. From what I can tell, the
> > ratio of currently allocated physical memory to the current memory
> > commitment made by the guest (vm_committed_as) is used as one of the
> > parameters in making the memory balancing decision on the host. This
> > is what Windows guests report to the host. So, I need some measure of
> > memory commitments made by the Linux guest. This is the reason I want
> > export vm_committed_as.
>=20
> So IIUC it will be guest who reports the value and the guest runs in the
> ring-0 so it is not in any user process context, right?
> If this is correct then memcg doesn't play any role here.

Thanks Michal. Yes, the kernel driver reports this metric to the host.
Andrew, let me know how I should proceed here.

Thanks,

K. Y


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
