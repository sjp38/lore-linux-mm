Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1JBTI3n194974
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 22:29:19 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JBGxY0141342
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 22:16:59 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JBDSWr022556
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 22:13:29 +1100
Message-ID: <45D98654.2020005@in.ibm.com>
Date: Mon, 19 Feb 2007 16:43:24 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH][1/4] RSS controller setup
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop> <20070219065026.3626.36882.sendpatchset@balbir-laptop> <20070219005727.da2acdab.akpm@linux-foundation.org> <6599ad830702190118r20b477d3q254c167c2fc2732@mail.gmail.com>
In-Reply-To: <6599ad830702190118r20b477d3q254c167c2fc2732@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 2/19/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>> This output is hard to parse and to extend.  I'd suggest either two
>> separate files, or multi-line output:
>>
>> usage: %lu kB
>> limit: %lu kB
> 
> Two separate files would be the container usage model that I
> envisaged, inherited from the way cpusets does things.
> 
> And in this case, it should definitely be the limit in one file,
> readable and writeable, and the usage in another, probably only
> readable.
> 
> Having to read a file called memctlr_usage to find the current limit
> sounds wrong.
> 

That sound right, I'll fix this.

> Hmm, I don't appear to have documented this yet, but I think a good
> naming scheme for container files is <subsystem>.<whatever> - i.e.
> these should be memctlr.usage and memctlr.limit. The existing
> grandfathered Cpusets names violate this, but I'm not sure there's a
> lot we can do about that.
> 

Why <subsystem>.<whatever>, dots are harder to parse using regular
expressions and sound DOS'ish. I'd prefer "_" to separate the
subsystem and whatever :-)

>> > +static int memctlr_populate(struct container_subsys *ss,
>> > +                             struct container *cont)
>> > +{
>> > +     int rc;
>> > +     if ((rc = container_add_file(cont, &memctlr_usage)) < 0)
>> > +             return rc;
>> > +     if ((rc = container_add_file(cont, &memctlr_limit)) < 0)
>>
>> Clean up the first file here?
> 
> Containers don't currently provide an API for a subsystem to clean up
> files from a directory - that's done automatically when the directory
> is deleted.
> 
> I think I'll probably change the API for container_add_file to return
> void, but mark an error in the container itself if something goes
> wrong - that way rather than all the subsystems having to check for
> error, container_populate_dir() can do so at the end of calling all
> the subsystems' populate methods.
> 

It should be easy to add container_remove_file() instead of marking
an error.

> Paul


-- 
	Warm Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
