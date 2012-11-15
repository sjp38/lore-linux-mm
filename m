Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C599F6B006C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 16:25:07 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1499606pad.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 13:25:07 -0800 (PST)
Date: Thu, 15 Nov 2012 13:25:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
In-Reply-To: <20121115085224.GA4635@lizard>
Message-ID: <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com>
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com> <20121107114321.GA32265@shutemov.name> <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com>
 <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com> <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
 <20121115085224.GA4635@lizard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Thu, 15 Nov 2012, Anton Vorontsov wrote:

> Hehe, you're saying that we have to have cgroups=y. :) But some folks were
> deliberately asking us to make the cgroups optional.
> 

Enabling just CONFIG_CGROUPS (which is enabled by default) and no other 
current cgroups increases the size of the kernel text by less than 0.3% 
with x86_64 defconfig:

   text	   data	    bss	    dec	    hex	filename
10330039	1038912	1118208	12487159	 be89f7	vmlinux.disabled
10360993	1041624	1122304	12524921	 bf1d79	vmlinux.enabled

I understand that users with minimally-enabled configs for an optimized 
memory footprint will have a higher percentage because their kernel is 
already smaller (~1.8% increase for allnoconfig), but I think the cost of 
enabling the cgroups code to be able to mount a vmpressure cgroup (which 
I'd rename to be "mempressure" to be consistent with "memcg" but it's only 
an opinion) is relatively small and allows for a much more maintainable 
and extendable feature to be included: it already provides the 
cgroup.event_control interface that supports eventfd that makes 
implementation much easier.  It also makes writing a library on top of the 
cgroup to be much easier because of the standardization.

I'm more concerned about what to do with the memcg memory thresholds and 
whether they can be replaced with this new cgroup.  If so, then we'll have 
to figure out how to map those triggers to use the new cgroup's interface 
in a way that doesn't break current users that open and pass the fd of 
memory.usage_in_bytes to cgroup.event_control for memcg.

> OK, here is what I can try to do:
> 
> - Implement memory pressure cgroup as you described, by doing so we'd make
>   the thing play well with cpusets and memcg;
> 
> - This will be eventfd()-based;
> 

Should be based on cgroup.event_control, see how memcg interfaces its 
memory thresholds with this in Documentation/cgroups/memory.txt.

> - Once done, we will have a solution for pretty much every major use-case
>   (i.e. servers, desktops and Android, they all have cgroups enabled);
> 

Excellent!  I'd be interested in hearing anybody else's opinions, 
especially those from the memcg world, so we make sure that everybody is 
happy with the API that you've described.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
