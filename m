Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l91HmHB6017979
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 13:48:17 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l91Hkmju626220
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 13:46:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l91HkmTm005763
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 13:46:48 -0400
Subject: Re: Hotplug memory remove
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
References: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
	 <20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 01 Oct 2007 10:49:46 -0700
Message-Id: <1191260987.29581.14.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-02 at 01:14 +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 01 Oct 2007 08:37:43 -0700
> Badari Pulavarty <pbadari@gmail.com> wrote:
> > 1) Other than remove_memory(), I don't see any other arch-specific
> > code that needs to be provided. Even remove_memory() looks pretty
> > arch independent. Isn't it ?
> > 
> Yes, maybe arch independent. Current codes is based on assumption
> that some arch may needs some code before/after hotremove.
> If no arch needs, we can merge all. 

Yeah. Lets not worry about it yet. All I wanted to make sure,
if there is any arch specific work you did so far..

> 
> > 2) I copied remove_memory() from IA64 to PPC64. When I am testing
> > hotplug-remove (echo offline > state), I am not able to remove
> > any memory at all. I get different type of failures like ..
> > 
> > memory offlining 6e000 to 6f000 failed
> > 
> I'm not sure about this...does this memory is in ZONE_MOVABLE ?
> If not ZONE_MOVABLE, offlining can be fail because of not-removable
> kernel memory. 

I tried offlining different sections of memory. There is no easy 
way to tell if it belonged to ZONE_MOVABLE or not. I was
using /proc/page_owner to find out suitable sections to offline.

> 
> > - OR -
> > 
> > Offlined Pages 0
> > 
> Hmm, About "Offlined Pages 0" case, maybe memory resource is not
> registered. At memory hotremove works based on registered memory resource.
> (For handling memory hole.)
> 
> Does PPC64 resister conventinal memory to memory resource ?
> This information can be shown in /proc/iomem.
> In current code, removable memory must be registerred in /proc/iomem.
> Could you confirm ?

I am little confused. Can you point me to the code where you have
this assumption ? Why does it have to be registered in /proc/meminfo ?
You find the section and try to offline it by migrating pages from that
section. If its fails to free up the pages, fail the remove. Isn't it ?

On my ppc64 machine, I don't see nothing but iomemory in /proc/meminfo.

> > I am wondering, how did you test it on IA64 ? Am I missing something ?
> > How can I find which "sections" of the memory are free to remove ?
> > I am using /proc/page_owner to figure it out for now.
> > 
> create ZONE_MOVBALE with kernelcore= boot option and offlined memory in it.

Will try that.

Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
