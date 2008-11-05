Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA5L08p2023329
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 16:00:08 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA5L3mTA046526
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 16:03:48 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA5L3b1Z030165
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 16:03:37 -0500
Subject: Re: [PATCH] [REPOST #2] mm: show node to memory section
	relationship with symlinks in sysfs
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081105123609.878085be.akpm@linux-foundation.org>
References: <20081103234808.GA13716@us.ibm.com>
	 <20081105123609.878085be.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 05 Nov 2008 13:03:44 -0800
Message-Id: <1225919024.11514.4.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, pbadari@us.ibm.com, mel@csn.ul.ie, lcm@us.ibm.com, mingo@elte.hu, greg@kroah.com, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-11-05 at 12:36 -0800, Andrew Morton wrote:
> Dumb question: why do this with a symlink forest instead of, say, cat
> /proc/sys/vm/mem-sections?

The basic problem is that we on/offline memory based on sections and not
nodes.  But, physically, people care about nodes.

So, the question we're answering is "to which sections does this node's
memory belong?".  We could just put all this data in one big file and
have:

$ cat /proc/sys/vm/mem-sections?
node: section numbers
0: 1 2 3 4 5
1: 5 6 7 8
2: 99 100 101 102

But, we have the nodes in sysfs and we also have the sections in sysfs
and I don't want Greg to be mean to me.  He's scary.  We could simply
dump the section numbers in sysfs, but the first thing userspace is
going to do is:

for section in /sys/devices/system/node/node1/memory*; do
	nr=$(cat $section)
	cat foo > /sys/devices/system/memory/memory$nr/bar
done

Making the symlinks makes it harder for us to screw this process up,
both in the kernel and in userspace.  Plus, symlinks are easy to code up
in sysfs. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
