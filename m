Date: Tue, 12 Jun 2007 12:19:12 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: mm: memory/cpu hotplug section mismatch.
Message-ID: <20070612031912.GA1377@linux-sh.org>
References: <20070611154428.GA27644@linux-sh.org> <20070611184046.GA6458@uranus.ravnborg.org> <20070612102236.E8BA.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070612102236.E8BA.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Sam Ravnborg <sam@ravnborg.org>, Randy Dunlap <randy.dunlap@oracle.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 12, 2007 at 10:50:33AM +0900, Yasunori Goto wrote:
> > > 
> > > If CONFIG_MEMORY_HOTPLUG=n __meminit == __init, and if
> > > CONFIG_HOTPLUG_CPU=n __cpuinit == __init. However, with one set and the
> > > other disabled, you end up with a reference between __init and a regular
> > > non-init function.
> > 
> > My plan is to define dedicated sections for both __devinit and __meminit.
> > Then we can apply the checks no matter the definition of CONFIG_HOTPLUG*
> 
> I prefer defining "__nodeinit" for __cpuinit and __meminit case to
> __devinit.   __devinit is used many devices like I/O, and it is
> useful for many desktop users. But, cpu/memory hotpluggable box
> is very rare. And it should be in init section for many people.
> 
> This kind of issue is caused by initialization of pgdat/zone.
> I think __nodeinit is enough and desirable.
> 
A #define __nodeinit __devinit is probably reasonable for clarity
purposes. But whatever we want to call it, the current __cpuinit for
zone_batchsize() has to be changed, as it will be freed with the rest of
the init code if CPU hotplug is disabled. If we want to do something
cleaner in the long run, that's fine, but changing to __devinit now at
least gets the semantics right for both the memory and cpu hotplug cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
