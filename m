Date: Wed, 19 Sep 2007 22:43:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/8] oom: save zonelist pointer for oom killer calls
In-Reply-To: <eada2a070709191651i24185d1ep9e0d1829e115ee79@mail.gmail.com>
Message-ID: <alpine.DEB.0.9999.0709192235170.22371@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com>  <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com>  <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com>  <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
  <Pine.LNX.4.64.0709191204590.2241@schroedinger.engr.sgi.com>  <alpine.DEB.0.9999.0709191330520.26978@chino.kir.corp.google.com>  <Pine.LNX.4.64.0709191353440.3136@schroedinger.engr.sgi.com>  <alpine.DEB.0.9999.0709191416380.30290@chino.kir.corp.google.com>
 <eada2a070709191651i24185d1ep9e0d1829e115ee79@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Pepper <lnxninja@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Tim Pepper wrote:

> When no zones in the current zonelist are on the list of OOM zones,
> then all the current zones are added to the list of OOM zones...or
> none of them depending on how badly OOM'd we are.  Tricky.
> 

That's not quite how I intended it to be read, but your analysis of the 
return values of try_set_zone_oom() are correct.

It was intended to return non-zero (i.e. the OOM killer is still invoked) 
if the zonelist couldn't be added to our list simply because the kzalloc() 
failed.  This is after the test to see if any of the zones are already 
marked as being in the OOM killer and they weren't (the only reason we 
didn't immediately return 0).  So the return value is correct and the OOM 
killer should still be invoked.

But yeah, it's cleaner if we change all_unreclaimable to an
unsigned int flags and convert all current testers of the 
all_unreclaimable value to use it.  Then we can simply set a bit, 
ZONE_OOM, to identify such zones.

> If any single zone in the current zonelist matches in the list of OOM
> zones, none of the current zones are added to the list of OOM zones.
> Given the patch header comments, this was done on purpose.  But
> doesn't that leave your list of OOM zones incomplete and open you to
> OOM killing in parallel on a given zone?
> 

They aren't added to the list because we aren't going to invoke the OOM 
killer for them, we're going to return 0 to __alloc_pages(), the only 
caller of try_set_zone_oom(), and that will put the task to sleep and then 
retry the allocation that it failed on when it wakes up:

	if (!try_set_zoom_oom(zonelist)) {
		schedule_timeout_uninterruptible(1);
		goto restart;
	}

The only time we return 1 is when none of the zones from the 
__alloc_pages() zonelist was found already to be marked in the OOM killer 
and thus it _prevents_ parallel OOM killings.

> Or is that all ok in that you're trying to minimise needlessly OOM
> killing something when possible but are willing to throw in the towel
> when things are tending towards royally hosed?
> 

The entire patchset is aimed toward serialization and trying to avoid 
needlessly killing tasks when killing one would alleviate the condition.  
The current OOM killer performs very badly for this.

> At any rate this seems complex with subtly varying behaviour that left
> me wondering if it really works as advertised.  I imagine without the
> kzmalloc and instead checking/setting bits in bitmasks the code would
> be cleaner.
> 

There's an easy way to check if it works as advertised, and that's to 
apply the patchset to Linus' latest git and trying it out.  I'm fairly 
happy with the results and I consider it to be much better than the 
current behavior.  I've tested it pretty thoroughly.

But I do agree that checking bits in an unsigned int flags member of 
struct zone will be better, but I intend to still mimic the behavior of a 
trylock for serialization.  try_set_zone_oom() will simply be implemented 
differently.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
