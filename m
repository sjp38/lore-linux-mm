Date: Sat, 6 Oct 2007 09:41:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Hotplug memory remove
Message-Id: <20071006094115.8b488e55.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071005172128.GA19681@linux.intel.com>
References: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
	<20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
	<20071005172128.GA19681@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: pbadari@gmail.com, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 5 Oct 2007 10:21:28 -0700
Mark Gross <mgross@linux.intel.com> wrote:

> > I'm not sure about this...does this memory is in ZONE_MOVABLE ?
> > If not ZONE_MOVABLE, offlining can be fail because of not-removable
> > kernel memory. 
> 
> How could I mark a nid's worth of memory as ZONE_MOVABLE?  I've been
> reading through this code and it appears to somewhat arbitrarily choose
> some portion of the memory to be ZONE_MOVABLE per pxm and some kernel
> parameters.  But I'm having a hard time finding the proper place to set
> up the nodes.
> 
It's not available now.

One idea is to ignore memory of some PXMs specified by kerenel boot param.
Later, you can hot-add specified PXM memory as MOVABLE.
Then, boot sequence will be
--
   bootstrap , ignore some memory here.
   init memory, driver, etc
   hot-add ignored memory
   online hot-added memory by user scripts. (from rc script ?)
--
For doing this, we need
 - a switch to hot-add memory as MOVABLE (will be easy patch)
 - a code for ignoring memory at boot but remember them for later hotadd
   (maybe needs arch specific codes)
 - a code for hot add memory before rc script (initcall is suitable ?) 

Needs some amount of arch-specific codes, but maybe simple.
Why I recommend above is it will be complex to avoid some PXM's memory
to be used as bootmem or for some other purpose(slab, hash, etc...).

If your firmware (efi?) doesn't show memory for hot removal at boot time,
this idea will be simpler..


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
