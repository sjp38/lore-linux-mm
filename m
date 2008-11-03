Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id mA3LLpQE007007
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 16:21:51 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA3LLpRB110740
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 16:21:51 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA3LLobD003681
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 16:21:50 -0500
Subject: Re: [PATCH] hibernation should work ok with memory hotplug
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081103125108.46d0639e.akpm@linux-foundation.org>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	 <200810291325.01481.rjw@sisk.pl>
	 <20081103125108.46d0639e.akpm@linux-foundation.org>
Content-Type: multipart/mixed; boundary="=-1fB6XySKyXfNKA6Hp6XS"
Date: Mon, 03 Nov 2008 13:21:48 -0800
Message-Id: <1225747308.12673.486.camel@nimitz>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, pavel@suse.cz, linux-kernel@vger.kernel.org, linux-pm@lists.osdl.org, Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

--=-1fB6XySKyXfNKA6Hp6XS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2008-11-03 at 12:51 -0800, Andrew Morton wrote:
> On Wed, 29 Oct 2008 13:25:00 +0100
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > On Wednesday, 29 of October 2008, Pavel Machek wrote:
> > > 
> > > hibernation + memory hotplug was disabled in kconfig because we could
> > > not handle hibernation + sparse mem at some point. It seems to work
> > > now, so I guess we can enable it.
> > 
> > OK, if "it seems to work now" means that it has been tested and confirmed to
> > work, no objection from me.
> 
> yes, that was not a terribly confidence-inspiring commit message.
> 
> 3947be1969a9ce455ec30f60ef51efb10e4323d1 said "For now, disable memory
> hotplug when swsusp is enabled.  There's a lot of churn there right
> now.  We'll fix it up properly once it calms down." which is also
> rather rubbery.  
> 
> Cough up, guys: what was the issue with memory hotplug and swsusp, and
> is it indeed now fixed?

I suck.  That commit message was horrid and I'm racking my brain now to
remember what I meant.  Don't end up like me, kids.

I've attached the message that I sent to the swsusp folks.  I never got
a reply from that as far as I can tell.

http://sourceforge.net/mailarchive/forum.php?thread_name=1118682535.22631.22.camel%40localhost&forum_name=lhms-devel

As I look at it now, it hasn't improved much since 2005.  Take a look at
kernel/power/snapshot.c::copy_data_pages().  It still assumes that the
list of zones that a system has is static.  Memory hotplug needs to be
excluded while that operation is going on.

page_is_saveable() checks for pfn_valid().  But, with memory hotplug,
things can become invalid at any time since no references are held or
taken on the page.  Or, a page that *was* invalid may become valid and
get missed.

The "missing a page" thing is probably correctable via the
zone_span_seqbegin() locks.  The "page becoming invalid" thing is
probably mostly fixable by acquiring a reference to the page itself.
I'd need to look how the locking on the hot remove side is working these
days to be much more constructive than that.

-- Dave

--=-1fB6XySKyXfNKA6Hp6XS
Content-Disposition: inline
Content-Description: Attached message - memory hotplug and software suspend
Content-Type: message/rfc822

Subject: memory hotplug and software suspend
From: Dave Hansen <haveblue@us.ibm.com>
To: swsusp@lister.fornax.hu
Cc: lhms <lhms-devel@lists.sourceforge.net>
Content-Type: text/plain
Date: Mon, 13 Jun 2005 10:08:55 -0700
Message-Id: <1118682535.22631.22.camel@localhost>
Mime-Version: 1.0
X-Mailer: Evolution 2.0.4 
X-Evolution-Transport: smtp://haveblue@us.ibm.com
X-Evolution-Account: nighthawk
X-Evolution-Fcc: email://1096948158.24203.2@spirit/Sent
X-Evolution-Format: text/plain
X-Evolution-Source: imap://dave@localhost/
Content-Transfer-Encoding: 7bit

Software suspend folks,

We're getting ready to submit memory hot-addition to the mainline
kernel.  The patches that we currently have work with everything, except
for the software suspend code currently in the kernel.

The issue is that, during a swsusp operation, a hardware memory hotplug
operation may occur.  For now, let's think about memory addition, and
ignore removal.

For example, let's look at copy_data_pages():

        for_each_zone(zone) {
		...
                for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn) {

In theory, while this loop is going on, a zone might be added, or a
zone's range might be expanded, making zone_pfn not start at the
beginning of a zone.  I think that can be fixed by using a new seqlock
that I plan to submit:

http://www.sr71.net/patches/2.6.12/2.6.12-rc5-mhp1/broken-out/C6-zone-span_seqlock.patch

and holding the new pgdat->size_lock around the call to the saveable()
function, to keep the pfn_valid().

http://www.sr71.net/patches/2.6.12/2.6.12-rc5-mhp1/broken-out/C5.2-pgdat_size_lock.patch

So, I have a couple of questions about swsusp.  Is the current code in
2.6.12-rc6 going to be around for a while?  If not, does anyone have a
problem with me making MEMORY_HOTPLUG depend on !SOFTWARE_SUSPEND for a
bit, until everything settles out, and we can fix them to work together
later?

-- Dave

--=-1fB6XySKyXfNKA6Hp6XS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
