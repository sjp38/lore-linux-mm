Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2B2886B0259
	for <linux-mm@kvack.org>; Thu,  2 May 2013 06:56:46 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Thu, 2 May 2013 06:56:45 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1F867C90048
	for <linux-mm@kvack.org>; Thu,  2 May 2013 06:56:42 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r42AugsU340256
	for <linux-mm@kvack.org>; Thu, 2 May 2013 06:56:42 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r42AufZv006748
	for <linux-mm@kvack.org>; Thu, 2 May 2013 06:56:42 -0400
Date: Thu, 2 May 2013 18:56:37 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
Message-ID: <20130502105637.GD4441@localhost.localdomain>
References: <20130424044848.GI2672@localhost.localdomain>
 <20130424094732.GB31960@dhcp22.suse.cz>
 <0000013e3cb0340d-00f360e3-076b-478e-b94c-ddd4476196ce-000000@email.amazonses.com>
 <20130425060705.GK2672@localhost.localdomain>
 <0000013e427023d7-9456c313-8654-420c-b85a-cb79cc3c4ffc-000000@email.amazonses.com>
 <20130426062436.GB4441@localhost.localdomain>
 <0000013e46cba821-d5c54c99-3b5c-4669-9a54-9fb8f4ee516f-000000@email.amazonses.com>
 <20130427112418.GC4441@localhost.localdomain>
 <0000013e5645b356-09aa6796-0a95-40f1-8ec5-6e2e3d0c434f-000000@email.amazonses.com>
 <20130429145711.GC1172@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130429145711.GC1172@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Mon, Apr 29, 2013 at 04:57:11PM +0200, Michal Hocko wrote:
> On Mon 29-04-13 14:50:08, Christoph Lameter wrote:
> > On Sat, 27 Apr 2013, Han Pingtian wrote:
> > 
> > > and it is called so many times that the boot cannot be finished. So
> > > maybe the memory isn't freed even though __free_slab() get called?
> > 
> > Ok that suggests an issue with the page allocator then.
> 
> You seem to have CONFIG_MEMCG_KMEM enabled. Do you see the same issue
> when this is disabled? The kmem accounting should be disabled unless a
> specific limit is set but it would be better to know that this is not
> the factor.
> 
I have tested to disable CONFIG_MEMCG_KMEM. But it doesn't solve this
problem, I can still trigger the OOM by compiling kernel.

Now I suspect the problem comes from the driver "ibmvscsi". Because on another
power 7 system, which doesn't use ibmvscsi, there is no such OOM
problem here. For now, looks like only systems using ibmvscsi can
trigger this OOM problem. I have rebooted one of the ibmvscsi systems
with "init=/bin/sh" and compared the loaded modules with one of the
none-ibmvscsi system with "comm":

	$ comm -13 --check-order none-ibmvscsi.txt ibmvscsi.txt
	ibmvscsi
	nx_crypto
	scsi_transport_srp

the scsi_transport_srp is used by ibmvscsi and I can rmmod the 
nx_crypto out. Then I launched the compiling process on the
single-user-booted ibmvscsi system. The OOM can still be
produced on it.

Looks like "ibmvscsi" + "slub" can trigger this problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
