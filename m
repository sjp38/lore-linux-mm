Message-ID: <469F71E7.4050200@bull.net>
Date: Thu, 19 Jul 2007 16:15:03 +0200
From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
MIME-Version: 1.0
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>	<20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>	<469F5372.7010703@bull.net> <20070719220118.73f40346.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070719220118.73f40346.kamezawa.hiroyu@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

> But is it too costly that flushing icache page only if a page is newly
> installed into the system (PG_arch1) && it is mapped as executable ?

Well it was a bit long time ago, I measured on a Tiger box with
CPUs of 1.3 GHz:

Flushing a page of 64 Kbytes, with modified data in D-cache
(it's slower that not having modified data in the D-cache):

13.1 ... 14.7 usec.

You may have quicker machines, but having more CPUs or a NUMA architecture
can slow it down considerably:
- more CPUs have to agree that that's the moment to carry out a flush
- NUMA adds delay

We may have, say 1 Gbyte / sec local i/o activity (using some RAIDs).
Assume a few % of this 1 Gbyte is the program execution, or program swap in.
It gives some hundreds of new exec pages / sec =>
some msec-s can be lost each sec.

I can agree that it should not be a big deal :-)

> I don't want to leak this (stupid) corner case to the file system layer.
> Hmm...can't we do clever flushing (like your idea) in VM layer ?

As the VM layer is designed to be independent of the page read in stuff...

Thanks,

Zoltan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
