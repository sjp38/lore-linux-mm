Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1BLTZrc012619
	for <linux-mm@kvack.org>; Mon, 11 Feb 2008 16:29:35 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1BLTZ2T158674
	for <linux-mm@kvack.org>; Mon, 11 Feb 2008 14:29:35 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1BLTZrq026236
	for <linux-mm@kvack.org>; Mon, 11 Feb 2008 14:29:35 -0700
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080211114818.74c9dcc7.akpm@linux-foundation.org>
References: <1202750598.25604.3.camel@dyn9047017100.beaverton.ibm.com>
	 <20080211114818.74c9dcc7.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 11 Feb 2008 13:32:32 -0800
Message-Id: <1202765553.25604.12.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, greg@kroah.com, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-02-11 at 11:48 -0800, Andrew Morton wrote:
> On Mon, 11 Feb 2008 09:23:18 -0800
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
> > Hi Andrew,
> > 
> > While testing hotplug memory remove against -mm, I noticed
> > that unregister_memory() is not cleaning up /sysfs entries
> > correctly. It also de-references structures after destroying
> > them (luckily in the code which never gets used). So, I cleaned
> > up the code and fixed the extra reference issue.
> > 
> > Could you please include it in -mm ?
> > 
> > Thanks,
> > Badari
> > 
> > register_memory()/unregister_memory() never gets called with
> > "root". unregister_memory() is accessing kobject_name of
> > the object just freed up. Since no one uses the code,
> > lets take the code out. And also, make register_memory() static.  
> > 
> > Another bug fix - before calling unregister_memory()
> > remove_memory_block() gets a ref on kobject. unregister_memory()
> > need to drop that ref before calling sysdev_unregister().
> > 
> 
> I'd say this:
> 
> > Subject: [-mm PATCH] register_memory/unregister_memory clean ups
> 
> is rather tame.  These are more than cleanups!  These sound like
> machine-crashing bugs.  Do they crash machines?  How come nobody noticed
> it?
> 

No they don't crash machine - mainly because, they never get called
with "root" argument (where we have the bug). They were never tested
before, since we don't have memory remove work yet. All it does
is, it leave /sysfs directory laying around and causing next
memory add failure. 

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
