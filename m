Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5C7586B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 14:37:27 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20100914234714.8AF506EA@kernel.beaverton.ibm.com>
	<20100915133303.0b232671.kamezawa.hiroyu@jp.fujitsu.com>
	<20100915135016.C9F1.A69D9226@jp.fujitsu.com>
	<1284531262.27089.15725.camel@nimitz>
Date: Wed, 15 Sep 2010 11:37:18 -0700
In-Reply-To: <1284531262.27089.15725.camel@nimitz> (Dave Hansen's message of
	"Tue, 14 Sep 2010 23:14:22 -0700")
Message-ID: <m1d3se7t0h.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [RFC][PATCH] update /proc/sys/vm/drop_caches documentation
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lnxninja@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Dave Hansen <dave@linux.vnet.ibm.com> writes:

> On Wed, 2010-09-15 at 13:53 +0900, KOSAKI Motohiro wrote:
>> > >  ==============================================================
>> > >  
>> > > diff -puN fs/drop_caches.c~update-drop_caches-documentation fs/drop_caches.c
>> > > --- linux-2.6.git/fs/drop_caches.c~update-drop_caches-documentation	2010-09-14 15:44:29.000000000 -0700
>> > > +++ linux-2.6.git-dave/fs/drop_caches.c	2010-09-14 15:58:31.000000000 -0700
>> > > @@ -47,6 +47,8 @@ int drop_caches_sysctl_handler(ctl_table
>> > >  {
>> > >  	proc_dointvec_minmax(table, write, buffer, length, ppos);
>> > >  	if (write) {
>> > > +		WARN_ONCE(1, "kernel caches forcefully dropped, "
>> > > +			     "see Documentation/sysctl/vm.txt\n");
>> > 
>> > Documentation updeta seems good but showing warning seems to be meddling to me.
>> 
>> Agreed.
>> 
>> If the motivation is blog's bogus rumor, this is no effective. I easily
>> imazine they will write "Hey, drop_caches may output strange message, 
>> but please ignore it!".
>
> Fair enough.  But, is there a point that we _should_ be warning?  If
> someone is doing this every minute, or every hour, something is pretty
> broken.  Should we at least be doing a WARN_ON() so that the TAINT_WARN
> is set?
>
> I'm worried that there are users out there experiencing real problems
> that aren't reporting it because "workarounds" like this just paper over
> the issue.

For what it is worth.  I had a friend ask me about a system that had 50%
of it's memory consumed by slab caches.  20GB out of 40GB.  The kernel
was suse? 2.6.27 so it's old, but if you are curious.
/proc/sys/vm/drop_caches does nothing in that case.

Thinking about it drop_caches is sufficiently limited I don't see
drop_caches being even to mask problems so Dave I think your basic
concern is overrated.

As for your documentation update your wording change seems to me to be
more obtuse, and in a scolding tone.  If you want people not to use
this facility you should educate people not scold them.

Perhaps something like:

Calling /proc/sys/vm/drop_caches pessimizes system performance.  The
pages freed by writing to drop_caches are easily repurposed when the
need arises, but the kernel instead of wasting those pages by leaving
them holding nothing, instead uses those pages to increase the size
of the filesystem cache.  The larger filesystem cache increases
the likely hood any filesystem access will get a cache hit and will not
need to read from disk.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
