Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 119BD6B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 08:46:57 -0400 (EDT)
Received: by oigx81 with SMTP id x81so74334364oig.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 05:46:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r67si6065901oie.56.2015.06.26.05.46.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jun 2015 05:46:54 -0700 (PDT)
Date: Fri, 26 Jun 2015 14:46:44 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [Xen-devel] [PATCHv1 6/8] xen/balloon: only hotplug additional
 memory if required
Message-ID: <20150626124644.GS14050@olila.local.net-space.pl>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
 <1435252263-31952-7-git-send-email-david.vrabel@citrix.com>
 <20150625211834.GO14050@olila.local.net-space.pl>
 <558D13BF.9030907@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <558D13BF.9030907@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org

On Fri, Jun 26, 2015 at 09:56:31AM +0100, David Vrabel wrote:
> On 25/06/15 22:18, Daniel Kiper wrote:
> > On Thu, Jun 25, 2015 at 06:11:01PM +0100, David Vrabel wrote:
> >> Now that we track the total number of pages (included hotplugged
> >> regions), it is easy to determine if more memory needs to be
> >> hotplugged.
> >>
> >> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> >> ---
> >>  drivers/xen/balloon.c |   16 +++++++++++++---
> >>  1 file changed, 13 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> >> index 960ac79..dd41da8 100644
> >> --- a/drivers/xen/balloon.c
> >> +++ b/drivers/xen/balloon.c
> >> @@ -241,12 +241,22 @@ static void release_memory_resource(struct resource *resource)
> >>   * bit set). Real size of added memory is established at page onlining stage.
> >>   */
> >>
> >> -static enum bp_state reserve_additional_memory(long credit)
> >> +static enum bp_state reserve_additional_memory(void)
> >>  {
> >> +	long credit;
> >>  	struct resource *resource;
> >>  	int nid, rc;
> >>  	unsigned long balloon_hotplug;
> >>
> >> +	credit = balloon_stats.target_pages - balloon_stats.total_pages;
> >> +
> >> +	/*
> >> +	 * Already hotplugged enough pages?  Wait for them to be
> >> +	 * onlined.
> >> +	 */
> >
> > Comment is wrong or at least misleading. Both values does not depend on onlining.
>
> If we get here and credit <=0 then the balloon is empty and we have

Right.

> already hotplugged enough sections to reach target.  We need to wait for

OK.

> userspace to online the sections that already exist.

This is not true. You do not need to online sections to reserve new
memory region. Onlining does not change balloon_stats.target_pages
nor balloon_stats.total_pages. You must increase balloon_stats.target_pages
above balloon_stats.total_pages to reserve new memory region. And
balloon_stats.target_pages increase is not related to onlining.

> >> +	if (credit <= 0)
> >> +		return BP_EAGAIN;
> >
> > Not BP_EAGAIN for sure. It should be BP_DONE but then balloon_process() will go
> > into loop until memory is onlined at least up to balloon_stats.target_pages.
> > BP_ECANCELED does work but it is misleading because it is not an error. So, maybe
> > we should introduce BP_STOP (or something like that) which works like BP_ECANCELED
> > and is not BP_ECANCELED.
>
> We don't want to spin while waiting for userspace to online a new

Right.

> section so BP_EAGAIN is correct here as it causes the balloon process to
> be rescheduled at a later time.

And this is wrong. We do not want that balloon process wakes up and
looks for onlined pages. Onlinig may happen long time after memory
reservation. So, it means that until all needed sections are not onlined
then balloon process will be woken up for nothing (I assume that nobody
changes balloon_stats.target_pages). xen_memory_notifier() does work
for us. It wakes up balloon process after onlinig and then it can
do relevant work.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
