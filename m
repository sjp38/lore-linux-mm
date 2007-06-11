Date: Mon, 11 Jun 2007 14:01:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mm: memory/cpu hotplug section mismatch.
Message-Id: <20070611140145.05726c0f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070611043543.GA22910@linux-sh.org>
References: <20070611043543.GA22910@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007 13:35:43 +0900
Paul Mundt <lethal@linux-sh.org> wrote:

> When building with memory hotplug enabled and cpu hotplug disabled, we
> end up with the following section mismatch:
> 
> WARNING: mm/built-in.o(.text+0x4e58): Section mismatch: reference to
> .init.text: (between 'free_area_init_node' and '__build_all_zonelists')
> 
> This happens as a result of:
> 
> 	-> free_area_init_node()
> 	  -> free_area_init_core()
> 	    -> zone_pcp_init() <-- all __meminit up to this point
> 	      -> zone_batchsize() <-- marked as __cpuinit
> 
> This happens because CONFIG_HOTPLUG_CPU=n sets __cpuinit to __init, but
> CONFIG_MEMORY_HOTPLUG=y unsets __meminit.
> 
> Changing zone_batchsize() to __init_refok fixes this.
> 

It seems this zone_batchsize() is called by cpu-hotplug and memory-hotplug.
So, __init_refok doesn't look good, here.

maybe we can use __devinit here. (Because HOTPLUG_CPU and MEMORY_HOTPLUG are
depend on CONFIG_HOTPLUG.)

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
