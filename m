Message-ID: <4174CD76.8040801@shadowen.org>
Date: Tue, 19 Oct 2004 09:16:54 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] CONFIG_NONLINEAR for small systems
References: <4173D219.3010706@shadowen.org> <41749860.9070503@jp.fujitsu.com>
In-Reply-To: <41749860.9070503@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hiroyuki KAMEZAWA wrote:

> We have *future* issue to hotplug kernel memory and kernel's virtual 
> address renaming
> will be used for it.
> As you say, if kernel memory is not remaped,  keeping V=P+c looks good.
> But our current direction is to enable kernel-memory-hotplug, which
> needs kernel's virtual memory renaming, I think.

Yes, I think its very likely that memory hot-plug requires us to break 
V=P+c in a lot of cases - though perhaps not all.  Indeed it was that 
work that started me thinking about using a simplified form to solve 
other problems for my 'crippled' 32bit systems.

What I am trying to say in my comments to this patch is that although 
generalised NONLINEAR will need and should provide this remap, that 
there are a class of systems and problem which don't need it (and the 
costs associated with it).  I'd like to see them supported as a 
sub-option to NONLINEAR... ie as an nonlinear option to maintain V=P+c. 
  In that this style of layout would be one of those that nonlinear offers.

> NONLINEAR_OPTIMISED looks a bit complicated.
> Can replace them with some other name ? Hmm...NONLINEAR_NOREMAP ?

Yes, that is a dumb name, as later I would also see the option to keep 
V=P+c as an optimisation too.  I'll rename it.

>> This patch set is implemented as a proof-of-concept to show
>> that a simplified CONFIG_NONLINEAR based implementation could provide
>> sufficient flexibility to solve the problems for these systems.
>>
> Very interesting. But I'm not sure whether we can use more page->flags 
> bit :[.
> I recommend you not to use more page->flags bits.

It should not use anymore flags bits.  You probabally got that 
impression as I replace the MAX_NODES_SHIFT (at 6) with a 
FLAGS_TOTAL_SHIFT (at 8) in 100-cleanup-node-zone.  What this is doing 
is replacing the MAX_NODES_SHIFT and MAX_ZONE_SHIFT (at 2) as a upper 
bound on the number of bits available, 8 in total.  When the nonlinear 
patch is layered on top we then have NODES, ZONES and SECTIONS competing 
for space flags, but they cannot consume more than these 8 bits.  I then 
choose to drop the NODE and replace it with SECTION to maintain the size 
constraint.  Obviously on the 64bit systems there is almost no limit and 
all three are stored.

Thanks for looking.

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
