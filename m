Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EFE9328024C
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:50:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b4so10218548wmb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:50:37 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id d62si527508wmd.4.2016.09.29.03.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 03:50:36 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id b130so124204446wmc.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:50:36 -0700 (PDT)
Subject: Re: Soft lockup in __slab_free (SLUB)
References: <57E8D270.8040802@kyup.com>
 <20160928053114.GC22706@js1304-P5Q-DELUXE> <57EB6DF5.2010503@kyup.com>
 <20160929014024.GA29250@js1304-P5Q-DELUXE>
 <20160929021100.GI14933@linux.vnet.ibm.com>
 <20160929025559.GE29250@js1304-P5Q-DELUXE> <57ECBE8D.6000703@kyup.com>
 <20160929102743.GL14933@linux.vnet.ibm.com>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <57ECF1FA.6010908@kyup.com>
Date: Thu, 29 Sep 2016 13:50:34 +0300
MIME-Version: 1.0
In-Reply-To: <20160929102743.GL14933@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, brouer@redhat.com



On 09/29/2016 01:27 PM, Paul E. McKenney wrote:
> On Thu, Sep 29, 2016 at 10:11:09AM +0300, Nikolay Borisov wrote:
[SNIP]

>> What in particular should I be looking for in ftrace? tracing the stacks
>> on the stuck cpu?
> 
> To start with, how about the sequence of functions that the stuck
> CPU is executing?

Unfortunately I do not know how to reproduce the issue, but it is being
reproduced byt our production load - which is creating backups in this
case. They are created by rsyncing files to a loop-back attached files
wihch are then unmounted and unmapped.From this crash it is evident that
the hang occurs while a volume is being unmounted.

But the callstack is in my hang report, no? I have the crashdump with me
so if you are interested in anything in particular I can go look for it.
I believe an inode eviction was requested, since destroy_inode, which
utilizes ext4_i_callback is called in the eviction + some errors paths.
And this eviction is executed on this particular CPU. What in particular
are you looking for?

Unfortunately it's impossible for me to run:

trace-cmd record -p function_graph -F <command that causes the issue>

[SNIP]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
