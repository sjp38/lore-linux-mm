Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 789AF6B009C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 10:41:48 -0500 (EST)
MIME-Version: 1.0
Message-ID: <d85b47d7-00d0-4ebd-afdf-1e69747d0a91@default>
Date: Tue, 13 Nov 2012 07:41:25 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
References: <1352600728-17766-1-git-send-email-kys@microsoft.com>
 <alpine.DEB.2.00.1211101830250.18494@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E35B45@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <alpine.DEB.2.00.1211121349130.23347@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E39FBC@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <c04bb062-bbce-4980-b2b3-fbbb18e64b66@default>
 <alpine.DEB.2.00.1211121547450.3841@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E3E0B5@BL2PRD0310MB375.namprd03.prod.outlook.com>
In-Reply-To: <426367E2313C2449837CD2DE46E7EAF930E3E0B5@BL2PRD0310MB375.namprd03.prod.outlook.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>, David Rientjes <rientjes@google.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com

> From: KY Srinivasan [mailto:kys@microsoft.com]
> Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
>=20
> > From: David Rientjes [mailto:rientjes@google.com]
> > Sent: Monday, November 12, 2012 6:49 PM
> > To: Dan Magenheimer
> > Cc: KY Srinivasan; Konrad Wilk; gregkh@linuxfoundation.org; linux-
> > kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> > apw@canonical.com; andi@firstfloor.org; akpm@linux-foundation.org; linu=
x-
> > mm@kvack.org; kamezawa.hiroyuki@gmail.com; mhocko@suse.cz;
> > hannes@cmpxchg.org; yinghan@google.com
> > Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
> >
> > On Mon, 12 Nov 2012, Dan Magenheimer wrote:
> >
> > > > > Why?  Is xen using it for a different inference?
> > > >
> > > > I think it is good to separate these patches. Dan (copied here) wro=
te the code
> > for the
> > > > Xen self balloon driver. If it is ok with him I can submit the patc=
h for Xen as
> > well.
> > >
> > > Hi KY --
> > >
> > > If I understand correctly, this would be only a cosmetic (function re=
naming)
> > change
> > > to the Xen selfballooning code.  If so, then I will be happy to Ack w=
hen I
> > > see the patch.  However, Konrad (konrad.wilk@oracle.com) is the maint=
ainer
> > > for all Xen code so you should ask him... and (from previous painful =
experience)
> > > it can be difficult to sync even very simple interdependent changes g=
oing
> > through
> > > different maintainers without breaking linux-next.  So I can't offer =
any
> > > help with that process, only commiseration. :-(
> > >
> >
> > I think this should be done in the same patch as the function getting
> > introduced with a cc to Konrad and routed through -mm; even better,
> > perhaps he'll have some useful comments for how this is used for xen th=
at
> > can be included for context.
> >
> Ok; I will send out a single patch. I am hoping this can be applied soon =
as Hyper-V balloon
> driver is queued behind this.
>=20
> Regards,
> K. Y

David --

Having caught up on the thread now, I'm a bit confused about your
requirement for KY to patch the Xen selfballooning code.

The data item we are talking about here, committed_as, is defined
by a kernel<->userland ABI, visible to userland via /proc/meminfo.
The Xen selfballoon driver accesses it within the kernel as
a built-in; this driver could potentially be loaded as a
module but currently cannot.

KY is simply asking that the data item be exported so that he can
use it from a new module.  No change to the Xen selfballoon driver
is necessary right now and requiring one only gets in the way of the
patch.  At some future time, the Xen selfballoon driver can, at its
leisure, switch to use the new exported function but need not
unless/until it is capable of being loaded as a module.

And, IIUC, you are asking that KY's proposed new function include a
comment about how it is used by Xen?  How many kernel globals/functions
document at their point of declaration the intent of all the in-kernel
users that use/call them?  That seems a bit unreasonable.  There is a
very long explanatory comment at the beginning of the Xen
selfballoon driver code already.

So I will ack KY's patch (I see it was just sent) but will leave
it up to Konrad and GregKH and Andrew to decide whether to
include the fragment patching the Xen selfballoon driver.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
