Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 007C06B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 21:15:02 -0400 (EDT)
Subject: Re: [BUG] 2.6.30-rc3-mmotm-090428-1814 -- bogus pointer deref
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090430113146.GA21997@csn.ul.ie>
References: <1241037299.6693.97.camel@lts-notebook>
	 <20090430113146.GA21997@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 30 Apr 2009 21:14:49 -0400
Message-Id: <1241140489.6656.14.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-numa <linux-numa@vger.kernel.org>, Doug Chapman <doug.chapman@hp.com>, Eric Whitney <eric.whitney@hp.com>, Bjorn Helgaas <bjorn.helgaas@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-04-30 at 12:31 +0100, Mel Gorman wrote:
> On Wed, Apr 29, 2009 at 04:34:59PM -0400, Lee Schermerhorn wrote:
> > I'm seeing this on an ia64 platform--HP rx8640--running the numactl
> > package regression test.  On ia64 a "NaT Consumption" [NaT = "not a
> > thing"] usually means a bogus pointer.  I verified that it also occurs
> > on 2.6.30-rc3-mmotm-090424-1814.  The regression test runs to completion
> > on a 4-node x86_64 platform for both the 04/27 and 04/28 mmotm kernels.
> > 
> > The bug occurs right after the test suite issues the message:
> > 
> > "testing numactl --interleave=all memhog 15728640"
> > 
> > -------------------------------
> > Console log:
> > 
> > numactl[7821]: NaT consumption 2216203124768 [2]
> > Modules linked in: ipv6 nfs lockd fscache nfs_acl auth_rpcgss sunrpc vfat fat dm_mirror dm_multipath scsi_dh pci_slot parport_pc lp parport sg sr_mod cdrom button e1000 tg3 libphy dm_region_hash dm_log dm_mod sym53c8xx mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: freq_table]
> > 
> > Pid: 7821, CPU 25, comm:              numactl
> > psr : 0000121008022038 ifs : 8000000000000004 ip  : [<a00000010014ec91>]    Not tainted (2.6.30-rc3-mmotm-090428-1631)
> > ip is at next_zones_zonelist+0x31/0x120
<snip>
> > 
> > I'll try to bisect to specific patch--probably tomorrow.

Mel:  I think you can rest easy.  I've duplicated the problem with a
kernel that truncates the mmotm 04/28 series just before your patches.
Hope it's not my cpuset-mm fix that occurs just before that!  I'll let
you know.

Did hit one or your BUG_ON's, tho'.  See below.

> > 
> 
> Can you also try with this minimal debugging patch applied and the full
> console log please? I'll keep thinking on it and hopefully I'll get inspired
> 
> diff --git a/mm/mm_init.c b/mm/mm_init.c
> index 4e0e265..82e17bb 100644
> --- a/mm/mm_init.c
> +++ b/mm/mm_init.c
> @@ -41,8 +41,6 @@ void mminit_verify_zonelist(void)
>  			listid = i / MAX_NR_ZONES;
>  			zonelist = &pgdat->node_zonelists[listid];
>  			zone = &pgdat->node_zones[zoneid];
> -			if (!populated_zone(zone))
> -				continue;
>  
>  			/* Print information about the zonelist */
>  			printk(KERN_DEBUG "mminit::zonelist %s %d:%s = ",
> diff --git a/mm/mmzone.c b/mm/mmzone.c
> index 16ce8b9..c8c54d1 100644
> --- a/mm/mmzone.c
> +++ b/mm/mmzone.c
> @@ -57,6 +57,10 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
>  					nodemask_t *nodes,
>  					struct zone **zone)
>  {
> +	/* Should be impossible, check for NULL or near-NULL values for z */
> +	BUG_ON(!z);
> +	BUG_ON((unsigned long )z < PAGE_SIZE);

The test w/o your patches hit the second BUG_ON().


> +
>  	/*
>  	 * Find the next suitable zone to use for the allocation.
>  	 * Only filter based on nodemask if it's set
> --
> To unsubscribe from this list: send the line "unsubscribe linux-numa" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
