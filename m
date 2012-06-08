Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 5E1616B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 16:03:22 -0400 (EDT)
Date: Fri, 8 Jun 2012 16:03:17 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: oomkillers gone wild.
Message-ID: <20120608200317.GA18693@redhat.com>
References: <20120604152710.GA1710@redhat.com>
 <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com>
 <20120605174454.GA23867@redhat.com>
 <20120605185239.GA28172@redhat.com>
 <alpine.DEB.2.00.1206081256330.19054@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206081256330.19054@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Jun 08, 2012 at 12:57:36PM -0700, David Rientjes wrote:
 > On Tue, 5 Jun 2012, Dave Jones wrote:
 > 
 > >   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME 
 > > 142524 142420  99%    9.67K  47510	  3   1520320K task_struct
 > > 142560 142417  99%    1.75K   7920	 18    253440K signal_cache
 > > 142428 142302  99%    1.19K   5478	 26    175296K task_xstate
 > > 306064 289292  94%    0.36K   6956	 44    111296K debug_objects_cache
 > > 143488 143306  99%    0.50K   4484	 32     71744K cred_jar
 > > 142560 142421  99%    0.50K   4455       32     71280K task_delay_info
 > > 150753 145021  96%    0.45K   4308	 35     68928K kmalloc-128
 > > 
 > > Why so many task_structs ? There's only 128 processes running, and most of them
 > > are kernel threads.
 > > 
 > 
 > Do you have CONFIG_OPROFILE enabled?

it's modular (though I should just turn it off, I never use it these days), but not loaded.

 > > /sys/kernel/slab/task_struct/alloc_calls shows..
 > > 
 > >  142421 copy_process.part.21+0xbb/0x1790 age=8/19929576/48173720 pid=0-16867 cpus=0-7
 > > 
 > > I get the impression that the oom-killer hasn't cleaned up properly after killing some of
 > > those forked processes.
 > > 
 > > any thoughts ?
 > > 
 > 
 > If we're leaking task_struct's, meaning that put_task_struct() isn't 
 > actually freeing them when the refcount goes to 0, then it's certainly not 
 > because of the oom killer which only sends a SIGKILL to the selected 
 > process.
 > 
 > Have you tried kmemleak?

I'll give that a shot on Monday. thanks,

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
